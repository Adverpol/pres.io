import QtQuick 2.7
import QtQuick.Controls 2.2

Button {
    id: root

    width: leftMenu.width
    height: 75
    text: "<button>"
    padding: 0

    spacing: 0

    background: Rectangle {
        width: root.width
        height: root.height
        color: root.down ? "#444444" : "transparent"

        Text {
            text: root.text
            font: root.font
            color: "white"

            width: parent.height
            height: parent.width

            y: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            rotation: -90
            transformOrigin: Item.TopLeft
        }
    }

    contentItem: Item {}
}
