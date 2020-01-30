import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.3


Window {
    id: root

    visible: true
    width: 1600
    height: 800
    title: qsTr("pres.io")

    property string currentPage: "presentation.qml"

    property var errors: []

    // todo!sv setting focus to true should be enough, but it isn't,
    // I don't think I understand focus well enough... good enough for now,
    // allows direct keyboard navigation
    Component.onCompleted: {
        content_background.forceActiveFocus();
        if (cpp_util.lastUsedFile !== ""){
            root.currentPage = cpp_util.lastUsedFile;
        }

        editor.openFile(root.currentPage);
    }

    onErrorsChanged:
    {
        error_painter.requestPaint();
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        nameFilters: [ "Presentation files (*.qml)", "All files (*)" ]

        onAccepted: {
            root.currentPage = cpp_util.urlToLocalFile(fileDialog.fileUrl);
            editor.openFile(root.currentPage);
            cpp_util.lastUsedFile = root.currentPage
        }
    }

    // Is this even necessary?
    FocusScope {
        anchors { fill: parent }

        Row {
            id: main_row

            anchors { fill: parent }

            Rectangle {
                id: content_background

                width: parent.width
//                width: parent.width - editor_scroll_view.width
                height: parent.height

                color: '#222222'

                focus: true
                Keys.onPressed: {
                    if (event.key === Qt.Key_Right){
                        // children[0] is the swipe view we create dynamically
                        content_rectangle.children[0].next();
                    } else if (event.key === Qt.Key_Left){
                        content_rectangle.children[0].previous();
                    }
                }

                // Put it behind the content to allow clicking in e.g. a snippet
                MouseArea {
                    id: focus_area

                    anchors { fill: parent }
                    onClicked: {
                        // Removes focus from e.g. text input, this ensures
                        // key navigation of the presentation works
                        content_background.forceActiveFocus();
                    }
                }

                Item {
                    id: content_margins

                    // Some padding around the 'slide', could adjust in fullscreen mode
                    anchors { fill: parent; margins: 10 }

                    Rectangle {
                        id: content_rectangle

                        // Desired screen width/height, visible area is this size and is then scaled up/down to
                        // fit on the screen.
                        property int reqWidth: 1600
                        property int reqHeight: 900

                        function getScale(){
                            var scale = Math.min(parent.width/reqWidth, parent.height/reqHeight);
                            return scale;
                        }

                        width: reqWidth
                        height: reqHeight

                        anchors { centerIn: parent }
                        color: "#eeeeee"
                        scale: getScale()
                    }
                }
            }

            Column {
                visible: false

                width: 0.4*parent.width
                height: parent.height

                Item {
                    width:  parent.width
                    height: 30

                    Button {
                        anchors { fill: parent }
                        text: root.currentPage
                        leftPadding: 5
                        // verticalAlignment: Text.AlignVCenter
                        onClicked: fileDialog.open()
                    }
                }



                ScrollView {
                    id: editor_scroll_view

                    width:  parent.width
                    height: parent.height - 130

                    clip: true

                    Row {
                        Rectangle {
                            width: 40
                            height: editor_scroll_view.implicitHeight
                            color: "#eee"

                            Canvas {
                                id: error_painter

                                anchors { fill: parent }

                                height: 2*parent.height
                                clip: false

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.resetTransform();
                                    ctx.clearRect(0, 0, width, height);
                                    ctx.fillStyle = Qt.rgba(1, 1, 0.2, 1);

                                    for (var idx in root.errors){
                                        var mid = 0.5*(errors[idx].ylow+errors[idx].yhigh);
                                        ctx.fillRect(0, mid-6, width, 11);
                                    }

                                    ctx.textAlign = "end";
                                    ctx.textBaseline = "middle";
                                    for (var line = 0; line < editor.lineCount; ++line){
                                        ctx.strokeText("" + (line+1), width-10, (line+0.5)*editor.lineHeight);
                                    }
                                }
                            }
                        }

                        TextEdit {
                            id: editor

                            font.family: "consolas"
                            selectByMouse: true

                            function openFile(fileName){
                                text = cpp_util.readFile(root.currentPage);
                            }

                            property var loaded_object: null
                            property bool _disableTextSignal: false
                            readonly property double lineHeight: implicitHeight / Math.max(1, lineCount);

                            function parseError(error)
                            {
                                var error_data = [];

                                // todo!sv see https://doc.qt.io/qt-5/qml-qtqml-qt.html#createQmlObject-method,
                                // can get the required info for highlighting directly from the error, no need
                                // to parse text
                                // lineNumber, columnNumber, message

                                for (var idx in error.qmlErrors){
                                    // -1 to have cursor on error, not one past
                                    // -1 extra to convert to zero-based
                                    var linePos = Math.max(0, error.qmlErrors[idx].lineNumber-1) * lineHeight;
                                    error_data.push({ylow: linePos,
                                                        yhigh: linePos+lineHeight,
                                                        lineNumber: error.qmlErrors[idx].lineNumber,
                                                        columnNumber: error.qmlErrors[idx].columnNumber,
                                                        message: error.qmlErrors[idx].message});
                                    //                                console.error(error.qmlErrors);
                                }

                                return error_data;
                            }

                            function createWrappedObject(qml, xpos, state)
                            {
                                var error_data = []
                                try {
                                    var new_object = Qt.createQmlObject(qml, content_rectangle);
                                    new_object.setPresentationState(state);
                                } catch(error){
                                    console.error(error);
                                    error_data = parseError(error);
                                }

                                root.errors = error_data;

                                return new_object;
                            }

                            function load(text)
                            {
                                if (_disableTextSignal){
                                    return;
                                }

                                cpp_util.isActive = false;

                                var state = null;
                                if (loaded_object){
                                    try {
                                        state = loaded_object.getPresentationState();
                                    } catch (error){
                                        // This catch is important: if getPresentationState errors out
                                        // e.g. because it's being typed, subsequent code will not be run
                                        // i.e. user is for ever unable to complete getPresentationState
                                        console.error(error);
                                        root.errors = parseError(error);
                                    }
                                }

                                var new_object = createWrappedObject(text, 0, state);

                                // Only destroy the old if the new is valid, otherwise we keep the old around
                                if (new_object){
                                    if (loaded_object){
                                        loaded_object.destroy();
                                    }
                                    loaded_object = new_object;

//                                    cpp_util.writeFile(root.currentPage, text);
                                }
                                // comment/uncomment to (not) have dynamic transitions
//                                cpp_util.isActive = true;
                            }

                            onTextChanged: load(text)

                            Timer{
                                repeat: true
                                interval: 5000
                                running: true

                                onTriggered: editor.openFile(root.currentPage)
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 100
                    color: "#eee"

                    ListView {
                        id: errors_list
                        anchors { fill: parent; topMargin: 5 }
                        clip: true

                        model: root.errors
                        delegate: error_delegate
                    }
                }
            } // Column

            states: [
                State {
                    name: "fullscreen"

                    PropertyChanges { target: root; visibility: Window.FullScreen}
                    PropertyChanges { target: editor_scroll_view; width: 0; visible: false }
                    PropertyChanges { target: content_background; focus: true }
                }
            ]
        }

        MouseArea {
            id: leftMenu
            width: 25
            height: parent.height
            hoverEnabled: true
            anchors { left: parent.left }
            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom }
                width: parent.width
                x: leftMenu.containsMouse ? 0 : -parent.width
                color: "#333333"

                Behavior on x { NumberAnimation{ duration: 100} }

                Column {
                    width:  25
                    height: 25
                    spacing: 5
                    anchors { verticalCenter: parent.verticalCenter }

                    ToolButton {
                        id: control

                        hoverEnabled: true
                        height: leftMenu.width
                        width:  leftMenu.width
                        font.pointSize: 16
                        text: root.visibility === Window.Windowed ? "\u279a" : "\u2798"

                        contentItem: Text {
                            text: control.text
                            font: control.font
                            color: "#eeeeee"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: 25
                            implicitHeight: 25
                            color: Qt.lighter("#444444", control.down ? 1.4 : 1)
                            visible: control.down || control.hovered
                        }

                        onClicked: {
                            if (root.visibility === Window.FullScreen){
                                main_row.state = "";
                            } else {
                                main_row.state = "fullscreen";
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: error_delegate

        Item{
            width: parent.width
            height: 20

            Row {
                anchors { fill: parent; leftMargin: 5 }

                Label {
                    width: 40
                    text: modelData.lineNumber + ":" + modelData.columnNumber
                }

                Label {
                    text: modelData.message
                }
            }
        }
    }
}
