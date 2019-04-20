import QtQuick 2.7
import QtQuick.Controls 2.2

Column {
    id: root

    property int active_child: 0
    function previous()
    {
        if (active_child < 0){
            return false;
        }

        if (! children[active_child].previous()){
            if (active_child == 0){
                return false;
            }

            active_child -= 1;
            children[active_child].previous();
        }
    }

    function next()
    {
        if (! children[active_child].next()){
            if (active_child + 1 === children.length){
                return false;
            }

            active_child += 1;
            children[active_child].next();
        }
    }

    anchors { fill: parent; topMargin: 10 }
    spacing: 10
}
