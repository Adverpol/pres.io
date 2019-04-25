import QtQuick 2.7
import QtQuick.Controls 2.3

SwipeView {
    id: root

    clip: true
    anchors { fill: parent }

    // Actually important: means clicks on the slide itself are not
    // 'eaten' for swipes -> they go to the background which uses
    // it for setting focus, which is important to direct key events
    // to moving the presentation back/forward.
    interactive: false

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
