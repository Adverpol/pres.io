import QtQuick 2.7
import QtQuick.Controls 2.2


Item {
    function next(){ return false; }
    function previous(){ return false; }

    width:  500
    height: 500

    property alias title: title_field.text
    property alias subtitle: subtitle_field.text
    property alias author: author_field.text

    function getPresentationState(){
    }

    function setPresentationState(savedState){
    }

    function do_print(printer, state){
        printer.printMarkdown(state,
                              "**" + title + "**\n\n"
                              + "*" + subtitle + "*\n\n"
                              + author)
    }

    Column {
        anchors { fill: parent; topMargin: 250}
        spacing: 10

        ShadedRectangle {
            width: parent.width - 200
            height: 200
            anchors { horizontalCenter: parent.horizontalCenter }
            color: 'steelblue'

            Column {
                id: title_column
                spacing: 50

                anchors { fill: parent; topMargin: 20 }

                TextEdit {
                    id: title_field
                    readOnly: true

                    width: parent.width
                    height: 50
                    font.pointSize: 38
                    color: "white"

                    horizontalAlignment: Text.AlignHCenter
                }

                TextEdit {
                    id: subtitle_field
                    readOnly: true

                    width: parent.width
                    height: 50
                    font.pointSize: 34
                    font.italic: true
                    color: "white"

                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        TextEdit {
            id: author_field
            readOnly: true

            width: parent.width
            height: 150
            font.pointSize: 28

            verticalAlignment: Text.AlignBottom
            horizontalAlignment: Text.AlignHCenter
        }


        TextEdit {
            readOnly: true

            width: parent.width
            height: 50
            font.pointSize: 20

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            text: Qt.formatDateTime(new Date(Date.now()), "dd/MM/yyyy")
        }
    }
}
