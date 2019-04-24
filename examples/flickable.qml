import QtQuick 2.7
import QtQuick.Controls 2.3

SwipeView
{
clip: true
anchors { fill: parent }

function next(){
incrementCurrentIndex();
return true;
}

function previous(){
decrementCurrentIndex();
return true;
}


Flickable {
//width: parent.parent.width
//height: 5
//contentWidth: 300
// does something wrt the size of the parent canvas: if contentHeight exceeds it, 
// flicking becomes active.
contentHeight: {
// is there a better way to do this? 
var height = 0;
for (var childId in contentItem.children){
height += contentItem.children[childId].height;
}

console.info(height);
height;
}


Rectangle {
id: first
width: 300
height: 900
color: "red"
}

Rectangle {
width: 300
height: 50
anchors { top: first.bottom }
color: "yellow"
}
}

Rectangle {
width: 550
height: 50
color: "white"
border { width: 10; color: "red" }
}
}
