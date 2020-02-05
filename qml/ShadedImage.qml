import QtQuick 2.7
//import QtQuick.Controls 2.2
//import QtGraphicalEffects 1.12

ShadedRectangle {
    id: root

    property alias source: img.source

    width: img.width
    height: img.height
    anchors { horizontalCenter: parent.horizontalCenter }
    opacity: 0.02

    Behavior on opacity {NumberAnimation {duration: cpp_util.isActive ? 200 : 0}}

    function next(){
        if (opacity < 1){
            opacity = 1;
            return true;
        }

        return false;
    }

    function previous(){
        opacity = 0.02;
        // Don't first hide and then go back, hide and imm
        return false;
    }

    Image {
        id: img
    }
}
