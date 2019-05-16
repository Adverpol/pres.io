import QtQuick 2.7
import QtQuick.Controls 2.2

import presio 1.0

Item {
    id: root
    width: parent.width - 100
    height: 300

    property alias text: text_model.text
    property alias title: title_text.text
    property alias active_index: bullets_view.active_index
    property alias count: bullets_view.count

    property int fontSize: 28
    property int titleFontSize: 32

    anchors { horizontalCenter: parent.horizontalCenter }

    function next(){
        if (bullets_view.active_index + 1 < bullets_view.count){
            bullets_view.active_index += 1;
            return true;
        } else {
            return false;
        }
    }

    function previous(){
        if (bullets_view.active_index < 0){
            return false;
        }

        bullets_view.active_index -= 1;
        return true;
    }

    function getPresentationState(){
        return {"active_index": bullets_view.active_index};
    }

    function setPresentationState(savedState){
        bullets_view.active_index = savedState["active_index"];
    }

    ShadedRectangle {
        id: background
        anchors { fill: parent }
        color: "white"
    }

    TextModel {
        id: text_model
    }

    Column {
        anchors { fill: parent }

        spacing: 15

        Rectangle {
            id: title_background

            width: parent.width
            height: 60
            radius: 5
            color: 'steelblue'

            // Make bottom two corners unrounded
            Rectangle {
                id: background_hack

                color: parent.color
                height: Math.max(0, parent.height - parent.radius)

                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            }

            visible: title_text.text.length > 0

            Label {
                id: title_text

                anchors { fill: parent; leftMargin: 15 }

                font.pointSize: root.titleFontSize

                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }

        ListView {
            id: bullets_view

            width: parent.width
            height: root.height - title_text.height - 15

            property int active_index: -1

            spacing: 5
            model: text_model
            delegate: bullet_delegate
        }
    }

    Component {
        id: bullet_delegate

        Row {
            id: delegate_root
            property int bullet_size: 12
            property int token_width: 40

            opacity: index > delegate_root.ListView.view.active_index ? 0.1 : 1

            anchors { left: parent.left; leftMargin: 15 }
            spacing: 5

            Item {
                id: indent_spacer
                width: indent * 35
                height: parent.height
            }

            Item {
                width: token_width
                // Puts the enumeration symbol central in front of the first line
                height: line_text.positionToRectangle(0).height
                visible: is_bullet

                Rectangle {
                    width: bullet_size
                    height: bullet_size;
                    radius: bullet_size
                    anchors { top: parent.top; topMargin: 25 }
                    color: "black"
                    anchors { centerIn: parent }
                }
            }

            Label {
                width: token_width
                height: parent.height
                visible: is_number
                text: number + "."
                font.pointSize: root.fontSize
            }

            TextEdit {
                id: line_text
                // hack to display a newline for an empty line, avoids fiddling with heights.
                text: item_text ? item_text : " "
                readOnly: true
                font.pointSize: root.fontSize
            }
        }
    }
}
