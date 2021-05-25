import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Layouts          1.2
import "."



TextField {
    id:                 root
    textColor:          MyWindowsColor.textFieldText
    implicitHeight:     MyWindowItmeSize.implicitTextFieldHeight
    activeFocusOnPress: true

    property bool   showUnits:  false
    property bool   showHelp:   false
    property string unitsLabel: ""

    signal helpClicked

    property real _helpLayoutWidth: 0

    Component.onCompleted: selectAllIfActiveFocus()
    onActiveFocusChanged: selectAllIfActiveFocus()


    onEditingFinished: {
        if (MyWindowItmeSize.isMobile) {
            // Toss focus on mobile after Done on virtual keyboard. Prevent strange interactions.
            focus = false
        }
    }

    function selectAllIfActiveFocus() {
        if (activeFocus) {
            selectAll()
        }
    }

    CommonLabel {
        id:             unitsLabelWidthGenerator
        text:           unitsLabel
        width:          contentWidth + parent.__contentHeight * 0.666
        visible:        false
        antialiasing:   true
    }

    style: TextFieldStyle {
        font.pointSize: MyWindowItmeSize.defaultFontPointSize
        background: Item {
            id: backgroundItem

            property bool showHelp: control.showHelp && control.activeFocus

            Rectangle {
                anchors.fill:           parent
                anchors.bottomMargin:   -1
                color:                  "#44ffffff"
            }

            Rectangle {
                anchors.fill:           parent
                border.color:           root.activeFocus ? "#47b" : "#999"
                color:                  MyWindowsColor.textField
            }

            RowLayout {
                id:                     unitsHelpLayout
                anchors.top:            parent.top
                anchors.bottom:         parent.bottom
                anchors.rightMargin:    backgroundItem.showHelp ? 0 : control.__contentHeight * 0.333
                anchors.right:          parent.right
                spacing:                MyWindowItmeSize.defaultFontPixelWidth / 4

                Component.onCompleted:  control._helpLayoutWidth = unitsHelpLayout.width
                onWidthChanged:         control._helpLayoutWidth = unitsHelpLayout.width

                Text {
                    Layout.alignment:   Qt.AlignVCenter
                    text:               control.unitsLabel
                    font.pointSize:     backgroundItem.showHelp ? MyWindowItmeSize.smallFontPointSize : MyWindowItmeSize.defaultFontPointSize
                    font.family:        MyWindowItmeSize.normalFontFamily
                    antialiasing:       true
                    color:              control.textColor
                    visible:            control.showUnits
                }

                Rectangle {
                    Layout.margins:     2
                    Layout.leftMargin:  0
                    Layout.rightMargin: 1
                    Layout.fillHeight:  true
                    width:              helpLabel.contentWidth * 3
                    color:              control.textColor
                    visible:            backgroundItem.showHelp

                    CommonLabel {
                        id:                 helpLabel
                        anchors.centerIn:   parent
                        color:              MyWindowsColor.textField
                        text:               qsTr("?")
                    }
                }
            }

            MouseArea {
                anchors.margins:    MyWindowItmeSize.isMobile ? -(MyWindowItmeSize.defaultFontPixelWidth * 0.66) : 0 // Larger touch area for mobile
                anchors.fill:       unitsHelpLayout
                enabled:            control.activeFocus
                onClicked:          root.helpClicked()
            }
        }

        padding.right: control._helpLayoutWidth //control.showUnits ? unitsLabelWidthGenerator.width : control.__contentHeight * 0.333
    }
}
