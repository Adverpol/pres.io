import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.2


Window {
    id: root

    visible: true
    width: 1600
    height: 800
    title: qsTr("pres.io")

    Row {
        id: main_row

        anchors { fill: parent }

        Rectangle {
            id: content_wrapper

            width: parent.width - view.width
            height: parent.height

            color: '#222222'

            focus: true
            Keys.onPressed: {
                if (event.key === Qt.Key_Right){
                    children[0].next();
                } else if (event.key === Qt.Key_Left){
                    children[0].previous();
                }
            }

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

                border { color: "black"; width: 1 }

                width: reqWidth
                height: reqHeight

                anchors { centerIn: parent }
                color: "#eeeeee"
                scale: getScale()
            }
        }

        ScrollView {
            id: view

            width: 0.4*parent.width
            height: parent.height

            TextArea {
                font.family: "Courier New"

                Component.onCompleted: { text = cpp_util.readFile("content.txt"); }

                property var loaded_object: null

                onTextChanged: {
                    var new_object = Qt.createQmlObject(text, content_rectangle);

                    // Only destroy the old if the new is valid, otherwise we keep the old around
                    if (new_object){
                        if (loaded_object){
                            loaded_object.destroy();
                        }
                        loaded_object = new_object;

                        cpp_util.writeFile("content.txt", text);
                    }
                }
            }
        }

        states: [
            State {
                name: "fullscreen"

                PropertyChanges { target: root; visibility: Window.FullScreen}
                PropertyChanges { target: view; width: 0; visible: false }
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
