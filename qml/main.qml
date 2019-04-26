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

    // todo!sv setting focus to true should be enough, but it isn't,
    // I don't think I understand focus well enough... good enough for now,
    // allows direct keyboard navigation
    Component.onCompleted: { content_background.forceActiveFocus(); }


    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        nameFilters: [ "Presentation files (*.qml)", "All files (*)" ]

        onAccepted: {
            root.currentPage = cpp_util.urlToLocalFile(fileDialog.fileUrl);
            editor.openFile(root.currentPage);
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

                width: parent.width - view.width
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
                    id: view

                    width:  parent.width
                    height: parent.height - 30

                    TextArea {
                        id: editor

                        font.family: "consolas"
                        selectByMouse: true

                        function openFile(fileName){
                            text = cpp_util.readFile(root.currentPage);
                        }

                        Component.onCompleted: { openFile(root.currentPage); }

                        property var loaded_object: null
                        property bool _disableTextSignal: false

                        function createWrappedObject(qml, xpos)
                        {
                            try {
                                var new_object = Qt.createQmlObject(qml, content_rectangle);
                            } catch(error){
                                // todo!sv see https://doc.qt.io/qt-5/qml-qtqml-qt.html#createQmlObject-method,
                                // can get the required info for highlighting directly from the error, no need
                                // to parse text
                                console.error(error);
                            }

                            return new_object;
                        }

                        onTextChanged: {
                            if (_disableTextSignal){
                                return;
                            }

                            var new_object = createWrappedObject(text, 0);

                            // Only destroy the old if the new is valid, otherwise we keep the old around
                            if (new_object){
                                if (loaded_object){
                                    loaded_object.destroy();
                                }
                                loaded_object = new_object;

                                cpp_util.writeFile(root.currentPage, text);
                            }
                        }
                    }
                }

                states: [
                    State {
                        name: "fullscreen"

                        PropertyChanges { target: root; visibility: Window.FullScreen}
                        PropertyChanges { target: view; width: 0; visible: false }
                        PropertyChanges { target: content_background; focus: true }
                    }
                ]
            }
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
}
