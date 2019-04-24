import QtQuick 2.7
import QtQuick.Particles 2.0

Item {
anchors { fill: parent }

function next(){ return false; }
function previous(){ return false; }

Rectangle {
id: rect

width:  600
height: 200
color: "lightsteelblue"
anchors { centerIn: parent }

property color from_color: "#ffff22"
property color to_color: "#ff0000"
property int duration: 2500

SequentialAnimation on color {
loops: Animation.Infinite
ColorAnimation { from: rect.from_color; to: rect.to_color; duration: rect.duration }
ColorAnimation { from: rect.to_color; to: rect.from_color; duration: rect.duration }
}

} // rect

} // item
