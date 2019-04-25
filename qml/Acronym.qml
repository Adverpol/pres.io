import QtQuick 2.7
import QtQuick.Controls 2.2

Column {
    id: root

    property var strings: ["This", "Is", "An", "Acronym"]

    width: parent.width
    height: 400

    // Distance between abbreviation and full text
    spacing: 75

    anchors { horizontalCenter: parent.horizontalCenter }

    function next(){
        if (detail.state === ""){
            detail.state = "visible";
            return true;
        } else {
            return false;
        }
    }

    function previous(){
        if (detail.state !== ""){
            detail.state = "";
            return true;
        } else {
            return false;
        }
    }

    ListView {
        id: view

        anchors { horizontalCenter: parent.horizontalCenter }
        width: count * 155 - 5
        height: 150
        spacing: 5
        model: parent.strings

        delegate: letterDelegate

        orientation: ListView.Horizontal

    }

    Component {
        id: letterDelegate

        Item {
            width: 150
            height: 150
            ShadedRectangle {
                anchors { fill: parent }
            }

            Label {
                anchors { centerIn: parent }
                text: modelData[0]
                font.pointSize: 42
            }
        }
    }

    TextEdit {
        id: detail
        width: parent.width
        font.pointSize: 50

        horizontalAlignment: Text.AlignHCenter
        textFormat: TextEdit.RichText
        readOnly: true

        text: {
            var parsed = "";
            for (var idx in parent.strings){
                if (idx > 0){
                    parsed += ' '
                }
                parsed += "<b>" + parent.strings[idx][0] + "</b>"
                        + parent.strings[idx].substring(1);
            }
            parsed;
        }

        opacity: 0

        Behavior on opacity {NumberAnimation {duration: 500}}

        states: [
            State {
                name: "visible"
                PropertyChanges { target: detail; opacity: 1 }
            }
        ]
    }
}
