import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import "."


RadioButton {
    id:root


    property var    color:          MyWindowsColor.text    ///< Text color
    property int    textStyle:      Text.Normal
    property color  textStyleColor: MyWindowsColor.text
    property bool   textBold:       false


    style: RadioButtonStyle {
        label: Item {
            implicitWidth:          text.implicitWidth + MyWindowItmeSize.defaultFontPixelWidth * 0.25
            implicitHeight:         MyWindowItmeSize.implicitRadioButtonHeight
            baselineOffset:         text.y + text.baselineOffset

            Rectangle {
                anchors.fill:       text
                anchors.margins:    -1
                anchors.leftMargin: -3
                anchors.rightMargin:-3
                visible:            control.activeFocus
                height:             MyWindowItmeSize.defaultFontPixelWidth * 0.25
                radius:             height * 0.5
                color:              "#224f9fef"
                border.color:       "#47b"
                opacity:            0.6
            }

            Text {
                id:                 text
                text:               control.text
                font.pointSize:     MyWindowItmeSize.defaultFontPointSize
                font.family:        MyWindowItmeSize.normalFontFamily
                font.bold:          control.textBold
                antialiasing:       true
                color:              root.color
                style:              root.textStyle
                styleColor:         root.textStyleColor
                anchors.centerIn:   parent
            }
        }

        indicator: Rectangle {
            width:          MyWindowItmeSize.radioButtonIndicatorSize
            height:         width
            color:          "white"
            border.color:   control.MyWindowsColor.text
            antialiasing:   true
            radius:         height / 2

            Rectangle {
                anchors.centerIn:   parent
                width:              Math.round(parent.width * 0.5)
                height:             width
                antialiasing:       true
                radius:             height / 2
                color:              "black"
                opacity:            control.checked ? (control.enabled ? 1 : 0.5) : 0
            }
        }
    }
}
