import QtQuick 2.7
//import QtQuick.Controls 2.2
//import QtGraphicalEffects 1.12

ShadedRectangle {
    id: root

    property alias source: img.source

    width: img.width
    height: img.height
    anchors { horizontalCenter: parent.horizontalCenter }

    Image {
        id: img
    }
}
