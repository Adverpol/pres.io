import QtQuick 2.7
import QtQuick.Controls 2.2

Column {
    id: root

    // Makes sure the correct padding is in place on first opening the column.
    // padding on previous/next is manually added.
    topPadding: 50

    // Distance between items
    spacing: 50

    property int active_child: 0

    function previous()
    {
        if (active_child < 0){
            return false;
        }

        if(! children[active_child].previous()){
            if (active_child == 0){
                return false;
            }

            active_child -= 1;
            y = - children[active_child].y + topPadding;
        }

        return true;
    }

    function next()
    {
        if (active_child >= children.length)
            return false;

        if (! children[active_child].next()){
            if (active_child + 1 === children.length){
                return false;
            }

            active_child += 1;
            y = - children[active_child].y + topPadding;
        }

        return true;
    }

    Behavior on y { NumberAnimation { duration: 300 } }
}
