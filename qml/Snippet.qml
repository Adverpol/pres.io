import QtQuick 2.7
import QtQuick.Controls 2.2

import storio 1.0

Item {
    id: root

    property string code: ""
    property int border: 10

    width:  parent.width - 2*border
    height: 100
    anchors { horizontalCenter: parent.horizontalCenter }

    TextArea {
        id: snippet

        width: parent.width
        height: parent.height

        background: Rectangle { radius: 5; anchors { fill: parent } color: "#2e2f30" }

        color: "white"
        text: cpp_util.syntaxHighlight(cpp_util.plainToRichText(code, font.family))
        font.family: "Courier New"
        textFormat: TextEdit.RichText

        onEditingFinished: {
            // getText to get unformatted
//            console.info('FORMATTED', getFormattedText(0, length));
//            console.info(getText(0, length));

            var rich = cpp_util.plainToRichText(getText(0, length), font.family);
            text = cpp_util.syntaxHighlight(rich);
        }

        onPressed: output.text = ""
    }

    TextArea {
        id: output

        visible: text.length > 0
        width: 0.5*parent.width - 10
        height: parent.height - 10
        anchors { right: parent.right; top: parent.top; margins: 5}
        readOnly: true

        font.family: "Courier"
        background: Rectangle { radius: 5; opacity: 0.8; anchors { fill: parent; } }
    }

    Launcher { id: launcher }

    ToolButton {
        height: 25
        width: 25
        anchors { bottom: parent.bottom; right: parent.right; margins: 5 }
        text: '\u25b6' // play button

        onClicked: {
            cpp_util.writeFile('__snippet.cpp', cpp_util.richToPlainText(snippet.text));
            var res = launcher.launch('g++ -o __snippet __snippet.cpp');
            output.text = res;
            if (output.text.length === 0){
                output.text += launcher.launch('./__snippet');
            }
        }
    }
}
