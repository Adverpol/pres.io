import QtQuick 2.7
import QtQuick.Controls 2.2

import presio 1.0

Item {
    id: root
    width: parent.width - 100
    height: bullets_view.contentHeight + wrap_column.anchors.bottomMargin + title_background.height

    property alias text: text_model.text
    property alias title: title_text.text
    property alias active_index: bullets_view.active_index
    property alias count: bullets_view.count

    property int fontSize: 26
    property int titleFontSize: 30
    // Don't use the bullet count: having a title without any bullets/text is also supported,
    // want to be able to hide/show the title
    property bool isActive: false

    opacity: isActive ? 1 : 0.04

    anchors { horizontalCenter: parent.horizontalCenter }

    function next(){
        if (! isActive){
            isActive = true;

            // After activating the title we can return. If there is no title we now have
            // an empty white rectangle, that's not pretty so move on to activate the first
            // item
            if (title_text.text){
                return true;
            }
        }

        if (bullets_view.active_index + 1 < bullets_view.count){
            bullets_view.active_index += 1;
            return true;
        } else {
            return false;
        }
    }

    function previous(){
        if (bullets_view.active_index < 0){
            isActive = false;
            return false;
        }

        bullets_view.active_index -= 1;

        if (bullets_view.active_index < 0 && ! title_text.text){
            // In case of bullets without title, don't go back to an empty white rectangle
            // but immediately go back to the previous presentation item
            isActive = false;
            return false;
        } else {
            return true;
        }
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
        id: wrap_column

        anchors { fill: parent; bottomMargin: 10 }

        Rectangle {
            id: title_background

            width: parent.width
            height: visible ? 60 : 0
            radius: 5
            color: 'steelblue'

            // Make bottom two corners unrounded
            Rectangle {
                id: background_hack

                color: parent.color
                // hack: painted over title_background, if both have opacity 0.1 then the part where
                // they overlap is actually darker, so just hide this one in semi-transparent mode,
                // this is pretty much invisible wheras the overlap is noticable
                visible: root.isActive
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
            height: root.height - title_text.height

            property int active_index: -1

            spacing: 5
            model: text_model
            delegate: bullet_delegate
            clip: true
        }
    }

    Component {
        id: bullet_delegate

        Row {
            id: delegate_root
            property int bullet_size: 12
            property int token_width: 40

            opacity: isActive ? index > delegate_root.ListView.view.active_index ? 0.02
                                                                                 : 1
                              : 1

            anchors { left: parent.left; right: parent.right; leftMargin: 15 }
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
                width: parent.width - ((is_number || is_bullet) ? token_width + 5
                                                                : 0)
                // hack to display a newline for an empty line, avoids fiddling with heights.
                text: item_text ? item_text : " "
                readOnly: true
                font.pointSize: root.fontSize
                textFormat: TextEdit.RichText
                wrapMode: Text.WordWrap
            }
        }
    }
}
