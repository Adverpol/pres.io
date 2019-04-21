import QtQuick 2.7
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.12

Item {
    id: root
    width: parent.width - 100
    height: 300

    anchors { horizontalCenter: parent.horizontalCenter }

    function next(){
        if (bullets_view.active_index + 1 < bullets_view.count){
            bullets_view.active_index += 1;
            return true;
        } else {
            return false;
        }
    }

    function previous(){
        if (bullets_view.active_index < 0){
            return false;
        }

        bullets_view.active_index -= 1;
        return true;
    }

    property alias model: bullets_view.model

    Rectangle {
        id: background

        radius: 5
        anchors { fill: parent }
        color: "white"
        visible: false // Shown as part of DropShadow
    }

    DropShadow {
        anchors.fill: source
        source: background

        cached: true
        horizontalOffset: 35
        verticalOffset: 35
        radius: 50.0
        samples: 80

        color: "#80000000"
        smooth: true
    }

    ListView {
        id: bullets_view

        anchors { fill: parent }

        property int active_index: -1

        delegate: bullet_delegate
    }

    Component {
        id: bullet_delegate

        Row {
            id: delegate_root
            property int bullet_size: 12

            opacity: index > delegate_root.ListView.view.active_index ? 0.1 : 1

            anchors { left: parent.left; leftMargin: 15 }
            spacing: 5

            Rectangle {width: bullet_size
                height: bullet_size;
                radius: bullet_size
                anchors { top: parent.top; topMargin: 25 }
                color: "black"
                //visible: false
            }

            //Label { text: index+1 + "."; anchors { top: parent.top; topMargin: 6} }

            TextArea {
                id: test
                text: model.text
                readOnly: true
                font.pointSize: 32
            }
        }
    }
}
