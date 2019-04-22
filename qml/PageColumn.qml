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

        while(! children[active_child].previous()){
            if (active_child == 0){
                return false;
            }

            active_child -= 1;
        }

        return true;
    }

    function next()
    {
        if (active_child >= children.length)
            return false;

        while (! children[active_child].next()){
            if (active_child + 1 === children.length){
                return false;
            }

            active_child += 1;
        }

        return true;
    }

    anchors { top: parent.top; bottom: parent.bottom; topMargin: 50 }
    width: parent.width
    spacing: 50
}
