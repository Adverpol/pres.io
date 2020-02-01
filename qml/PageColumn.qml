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

        var advance = true;
        if ('previous' in children[activeChild]){
            advance = !children[activeChild].previous();
        }

        if(advance){
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

        var advance = true;
        if ('next' in children[activeChild]){
            advance = !children[activeChild].next();
        }

        if (advance){
            if (activeChild + 1 === children.length){
                return false;
            }

            activeChild += 1;            

            // Immediately advance the new child. It should've been e.g.
            // almost transparant, immediately 'next-ing' makes it
            // visible which prevents having to hit the right arrow twice
            // when advancing to a next item.
            if ('next' in children[activeChild]){
                children[activeChild].next();
            }
        }

        return true;
    }

    function setActiveChild(index){
        if (index >= 0 && index < children.length){
            activeChild = index;
        }
    }

    function getPresentationState(){
        var childState = {};
        if ('getPresentationState' in children[activeChild]){
            childState = children[activeChild].getPresentationState();
        } else {
            console.info(children[activeChild] + " doesn't have getPresentationState")
        }

        return {"active": activeChild,
            "childState": childState};
    }

    function setPresentationState(state){
        if (! state){
            console.info("Trying to set invalid state");
            return;
        }

        setActiveChild(state.active);

        if ('setPresentationState' in children[activeChild]){
            children[activeChild].setPresentationState(state["childState"]);
        } else {
            console.info(children[activeChild] + " doesn't have setPresentationState")
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
