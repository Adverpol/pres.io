import QtQuick 2.7

Text {
    id: root

    function next(){
        if (opacity < 1){
            opacity = 1;
            return true;
        }

        return false;
    }

    function previous(){
        opacity = 0.1;
        // Don't first hide and then go back, hide and imm
        return false;
    }

    function do_print(printer, state){
        printer.printMarkdown(state, '## ' + text);
    }

    verticalAlignment: Text.AlignVCenter
    font.family: "Cantarell Thin"
    anchors.horizontalCenter: parent.horizontalCenter
    text: "<Title>"
    font.pointSize: 50
    opacity: 0.1

    Behavior on opacity {NumberAnimation {duration: cpp_util.isActive ? 200 : 0}}
}
