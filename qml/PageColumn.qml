import QtQuick 2.7
import QtQuick.Controls 2.2

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
            y = - children[activeChild].y + topPadding;
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
            y = - children[activeChild].y + topPadding;
        }

        return true;
    }

    Behavior on y { NumberAnimation { duration: 300 } }
}
