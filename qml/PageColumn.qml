import QtQuick 2.10
import QtQuick.Controls 2.2

// To keep the PageColumn at the end:
//
// onPositioningComplete: { setActiveChild(children.length-1); }
// // To prevent flickering
// Behavior on y {}


Column {
    id: root

    // Makes sure the correct padding is in place on first opening the column.
    // padding on previous/next is manually added.
    topPadding: 50

    // Distance between items
    spacing: 50

    property int activeChild: 0

    function previous()
    {
        if (activeChild < 0 || children.length === 0){
            return false;
        }

        if(! children[activeChild].previous()){
            if (activeChild == 0){
                return false;
            }

            activeChild -= 1;
        }

        return true;
    }

    function next()
    {
        if (activeChild >= children.length)
            return false;

        if (! children[activeChild].next()){
            if (activeChild + 1 === children.length){
                return false;
            }

            activeChild += 1;            

            // Immediately advance the new child. It shoudl've been e.g.
            // almost transparant, immediately 'next-ing' makes it
            // visible which prevents having to hit the right arrow twice
            // when advancing to a next item.
            children[activeChild].next();
        }

        return true;
    }

    function setActiveChild(index){
        if (index >= 0 && index < children.length){
            activeChild = index;
        }
    }

    onActiveChildChanged: {
        y = - children[activeChild].y + topPadding;
    }

    onPositioningComplete: {
        // Needed when changing the active child before all items are laid out,
        // which happens when restoring state
        y = - children[activeChild].y + topPadding;
    }

    Behavior on y { NumberAnimation { duration: cpp_util.isActive ? 300 : 0 } }
}
