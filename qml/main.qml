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
        anchors { fill: parent }

        Rectangle {
            id: content_rectangle

            width: 0.6*parent.width
            height: parent.height

            color: '#eeeeee'

            focus: true
            Keys.onPressed: {
                if (event.key === Qt.Key_Right){
                    children[0].next();
                } else if (event.key === Qt.Key_Left){
                    children[0].previous();
                }
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
    }
}
