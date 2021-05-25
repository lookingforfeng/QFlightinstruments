import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import "."
import QtGraphicalEffects 1.0



Button {
    activeFocusOnPress: true

    property bool primary:      false                               ///< primary button for a group of buttons
    property real pointSize:   MyWindowItmeSize.defaultFontPointSize    ///< Point size for button text

    // property var    _qgcPal:            QGCPalette { colorGroupEnabled: enabled }
    property bool   _showHighlight:     (pressed | hovered | checked) //&& !__forceHoverOff
    property bool   _showBorder:        false
    property int __lastGlobalMouseX:    0
    property int __lastGlobalMouseY:    0
    property int _horizontalPadding:    MyWindowItmeSize.defaultFontPixelWidth
    property int _verticalPadding:      Math.round(MyWindowItmeSize.defaultFontPixelHeight / 2)

    // This fixes the issue with button hover where if a Button is near the edge oa QQuickWidget you can
    // move the mouse fast enough such that the MouseArea does not trigger an onExited. This is turn
    // cause the hover property to not be cleared correctly.

    /* property bool __forceHoverOff: false



      Connections {
        target: __behavior
      onMouseXChanged: {
            __lastGlobalMouseX = ScreenTools.mouseX()
            __lastGlobalMouseY = ScreenTools.mouseY()
        }
        onMouseYChanged: {
            __lastGlobalMouseX = ScreenTools.mouseX()
            __lastGlobalMouseY = ScreenTools.mouseY()
        }
        onEntered: { __forceHoverOff = false; hoverTimer.start() }
        onExited: { __forceHoverOff = false; hoverTimer.stop() }
    }

    Timer {
        id:         hoverTimer
        interval:   250
        repeat:     true
        onTriggered: {
            __forceHoverOff = (__lastGlobalMouseX !== ScreenTools.mouseX() || __lastGlobalMouseY !== ScreenTools.mouseY());
        }
    }*/

    style: ButtonStyle {
        /*! The padding between the background and the label components. */
        padding {
            top:    _verticalPadding
            bottom: _verticalPadding
            left:   _horizontalPadding
            right:  _horizontalPadding
        }

        /*! This defines the background of the button. */
        background: Rectangle {
            id:background
            implicitWidth:  MyWindowItmeSize.implicitButtonWidth
            implicitHeight: MyWindowItmeSize.implicitButtonHeight
            border.width:   _showBorder ? 1: 0
            border.color:   MyWindowsColor.buttonText
           // color:          MyWindowsColor.button
            color:          _showHighlight ? MyWindowsColor.buttonHighlight :(primary ? MyWindowsColor.primaryButton : MyWindowsColor.button)

        }



        /*! This defines the label of the button.  */
        label: Item {
            implicitWidth:          row.implicitWidth
            implicitHeight:         row.implicitHeight
            baselineOffset:         row.y + text.y + text.baselineOffset

            Row {
                id:                 row
                anchors.centerIn:   parent
                spacing:            MyWindowItmeSize.defaultFontPixelWidth * 0.25

                Image {
                    source:                 control.iconSource
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id:                     text
                    anchors.verticalCenter: parent.verticalCenter
                    antialiasing:           true
                    text:                   control.text
                    font.pointSize:         pointSize
                    font.family:            MyWindowItmeSize.normalFontFamily
                    color:                  _showHighlight ?
                                                MyWindowsColor.buttonHighlightText :
                                                (primary ? MyWindowsColor.primaryButtonText : MyWindowsColor.buttonText)




                }


            }
        }
    }
}
