import QtQuick 2.7
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.12

Item {
    id: root

    property alias color: background.color

    Rectangle {
        id: background

        radius: 5
        anchors { fill: parent }
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
}
