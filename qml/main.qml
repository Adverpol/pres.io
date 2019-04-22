import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2


Window {
    id: root

    visible: true
    width: 1600
    height: 800
    title: qsTr("pres.io")

    property int page_index: 0
    readonly property var pages: ["page1.qml", "page2.qml"]
    readonly property string current_page: pages[page_index]

    // todo!sv setting focus to true should be enough, but it isn't,
    // I don't think I understand focus well enough... good enough for now,
    // allows direct keyboard navigation
    Component.onCompleted: { content_background.forceActiveFocus(); }

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
                        if (! content_rectangle.children[0].next()){
                            if (root.page_index + 1 < root.pages.length){
                                root.page_index += 1;
                                editor.setNextPage(root.current_page);
                            }
                        }

                    } else if (event.key === Qt.Key_Left){
                        if (! content_rectangle.children[0].previous()){
                            if (root.page_index > 0){
                                root.page_index -= 1;
                                editor.setPreviousPage(root.current_page);
                            }
                        }
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

            ScrollView {
                id: view

                width: 0.4*parent.width
                height: parent.height

                TextArea {
                    id: editor

                    font.family: "Courier New"

                    Component.onCompleted: { text = cpp_util.readFile(root.current_page); }

                    property var loaded_objects: []

                    function createWrappedObjec(qml, xpos){
                        var wrapper_object = Qt.createQmlObject("import QtQuick 2.7; Item { width:" + content_rectangle.width  + ";"
                                                                + "height:" + content_rectangle.height + ";"
                                                                + "x: " + xpos + ";"
                                                                + "function next(){ return children[0].next(); } "
                                                                + "function previous(){ return children[0].previous(); } "
                                                                + " Behavior on x { NumberAnimation{ duration: 400; } }"
                                                                + "}", content_rectangle);
                        if (wrapper_object === null)
                            return null;

                        var new_object = Qt.createQmlObject(qml, wrapper_object);
                        return [wrapper_object, new_object];
                    }

                    function destroyLoadedObjects(){
                        for (var i = loaded_objects.length-1; i >=0; --i){
                            if (loaded_objects[i]){
                                // Delete late enough to allow animations to finish. Should probably
                                // use a SeauentialAnimation instead to have proper timing.
                                loaded_objects[i].destroy(500);
                            }
                        }
                    }

                    function setPage(pageFile, xpos){
                        var new_objects = createWrappedObjec(cpp_util.readFile(root.current_page),
                                                             xpos);

                        if (new_objects[0]){
                            if (loaded_objects.length > 0 && loaded_objects[0]){
                                loaded_objects[0].x = -xpos
                                destroyLoadedObjects();
                            }

                            new_objects[0].x = 0;
                            loaded_objects = new_objects;
                        }
                    }

                    function setNextPage(pageFile){
                        setPage(pageFile, content_rectangle.width);
                    }

                    function setPreviousPage(pageFile){
                        setPage(pageFile, - content_rectangle.width);
                    }

                    onTextChanged: {
                        var new_objects = createWrappedObjec(text, 0);

                        // Only destroy the old if the new is valid, otherwise we keep the old around
                        if (new_objects.length > 0 && new_objects[0]){
                            destroyLoadedObjects();
                            loaded_objects = new_objects;

                            cpp_util.writeFile(root.current_page, text);
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

        MouseArea {
            id: footer
            width: parent.width
            height: 20
            hoverEnabled: true
            anchors { bottom: parent.bottom }
            Rectangle {
                anchors { fill: parent }
                opacity: 0.7
                visible: footer.containsMouse

                Row {
                    anchors { fill: parent }
                    spacing: 5
                    ToolButton {
                        height: parent.height
                        width: height
                        text: root.visibility === Window.Windowed ? "\u279a" : "\u2798"
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
