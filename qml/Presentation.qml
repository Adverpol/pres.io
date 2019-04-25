import QtQuick 2.7
import QtQuick.Controls 2.3

SwipeView {
    id: root

    clip: true
    anchors { fill: parent }

    function next(){
        if (! currentItem.next()){
            incrementCurrentIndex();
        }
        return true;
    }

    function previous(){
        if (! currentItem.previous()){
            decrementCurrentIndex();
        }
        return true;
    }
}
