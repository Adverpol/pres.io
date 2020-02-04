import QtQuick 2.7

// Could be more general to deal with any number of children. Not sure how to
// replace the item aliases for that. Should also re-use PageColumn logic.
Row {
    id: root

    property alias left_item:  left_loader.sourceComponent
    property alias right_item: right_loader.sourceComponent

    width:  parent.width
    height: Math.max(children[0].height, children[1].height)

    function next(){
        if (left_loader.item.next()){
            return true;
        }

        return right_loader.item.next();
    }

    function previous(){
        if (right_loader.item.previous()){
            return true;
        }

        return left_loader.item.previous();
    }

    // Wrap in an item to avoid setting loader width directly, most of the presentation
    // components set their own sensible width with some padding and we want to keep
    // that
    Item {
        width: 0.5*parent.width
        height: left_loader.children.length > 0 ? left_loader.children[0].height : 0
        Loader {
            id: left_loader
            anchors { fill: parent }
        }
    }

    Item {
        width: 0.5*parent.width
        height: right_loader.children.length > 0 ? right_loader.children[0].height : 0

        Loader {
            id: right_loader
            anchors { fill: parent }
        }
    }
}
