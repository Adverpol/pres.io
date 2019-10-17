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
            return true;
        }

        return false;
    }

    width: parent.width
    anchors { left: parent.left; right: parent.right; margins: 20 }

    TextInput{
        id: question_input

        opacity: root.isShown ? 1 : 0.05

        text: "Your question here?"

        font.pointSize: 40
        anchors { horizontalCenter: parent.horizontalCenter }
    }

    TextField {
        placeholderText: "Next guess..."
        font.pointSize: 25
        anchors { horizontalCenter: parent.horizontalCenter }
        width: 500
        height: 75

        onAccepted: {
            for (var i = 0; i < answers.count; ++i){
                if (text.toUpperCase() === answers.get(i).answer.toUpperCase()){
                    answers.setProperty(i, "guessed", true);
                    break;
                }
            }
            text = "";
        }
    }

    ListModel {
        id: answers
    }

    GridView {
        id: grid
        height: 200
        width: 1300
        anchors { horizontalCenter: parent.horizontalCenter }
        flow: GridView.FlowTopToBottom
        cellWidth: 650
        cellHeight: 100

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
