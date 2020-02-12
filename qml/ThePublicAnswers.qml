import QtQuick 2.7
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.12


Column {
    id: root
    spacing: 50

    property alias question: question_input.text
    property var model: []

    property bool isShown: false

    onModelChanged: {
        for (var i = 0; i < model.length; ++i){
            answers.append(
                {"answer": model[i],
                 "guessed": false}
            )
        }
    }

    function next(){
        if (! root.isShown)
        {
            root.isShown = true;
            return true;
        }

        for (var i = 0; i < answers.count; ++i){
            if ( answers.get(i).guessed !== true){
                answers.setProperty(i, "guessed", true);
                return true;
            }
        }

        return false;
    }

    function previous(){
        for (var i = answers.count-1; i >= 0; --i){
            if ( answers.get(i).guessed === true){
                answers.setProperty(i, "guessed", false);
                return true;
            }
        }

        if (root.isShown)
        {
            root.isShown = false;
            // If we get there we've hidden the last answer -> immediately go back to
            // previous item i.e. hiding the TPA itself does not use a single back-arrow
            return false;
        }

        return false;
    }

    function do_print(printer, state){
        var string = "### " + question + "\n\n";
        for (var idx in model){
            string += "1. " + model[idx] + "\n";
        }

        printer.printMarkdown(state, string);
    }

    width: parent.width
    anchors { left: parent.left; right: parent.right; margins: 20 }

    TextInput{
        id: question_input

        text: "Your question here?"

        opacity: root.isShown ? 1 : 0.02

        font.pointSize: 40
        anchors { horizontalCenter: parent.horizontalCenter }
    }

    TextField {
        placeholderText: "Next guess..."
        font.pointSize: 25
        anchors { horizontalCenter: parent.horizontalCenter }
        width: 500
        height: 75
        opacity: root.isShown ? 1 : 0.05

        onAccepted: {
            // Check if there is exactly one answer that substring matches
            var found = [];
            for (var i = 0; i < answers.count; ++i){
                if (answers.get(i).answer.toUpperCase().includes(text.toUpperCase())){
                    found.push(i);
                }
            }

            if (found.length === 1){
                answers.setProperty(found[0], "guessed", true);
            }

            text = "";
        }
    }

    ListModel {
        id: answers
    }

    GridView {
        id: grid
        // 2-column setup
        height: cellHeight * Math.ceil(answers.count*0.5)
        width: 1300
        anchors { horizontalCenter: parent.horizontalCenter }
        flow: GridView.FlowLeftToRight
        // Half of 1300
        cellWidth: 650
        cellHeight: 100
        opacity: root.isShown ? 1 : 0.1

        model: answers
        delegate: answerDelegate
    }

    Component {
        id: answerDelegate

        Item {
            width: grid.cellWidth; height: grid.cellHeight;

            Rectangle {
                anchors { fill: parent; margins: 5}
                TextInput {
                    id: answer_text
                    text: answer
                    font.pointSize: 25
                    anchors { fill: parent }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    visible: guessed
                }

                GaussianBlur {
                    anchors.fill: answer_text
                    source: answer_text
                    radius: 20
                    samples: 41
                    opacity: 0.2
                    visible: ! guessed
                }
            }
        }
    }
}
