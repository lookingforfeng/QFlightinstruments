/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Controls.Private 1.0
import "."



Slider {
    id:             _root
    implicitHeight: MyWindowItmeSize.implicitSliderHeight

    // Value indicator starts display from zero instead of min value
    property bool zeroCentered: false
    property bool displayValue: false

    style: SliderStyle {
        groove: Item {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth:  Math.round(MyWindowItmeSize.defaultFontPixelHeight * 4.5)
            implicitHeight: Math.round(MyWindowItmeSize.defaultFontPixelHeight * 0.3)

            Rectangle {
                radius:         height / 2
                anchors.fill:   parent
                color:          MyWindowsColor.button
                border.width:   1
                border.color:   MyWindowsColor.buttonText
            }

            Item {
                id:     indicatorBar
                clip:   true
                x:      _root.zeroCentered ? zeroCenteredIndicatorStart : 0
                width:  _root.zeroCentered ? centerIndicatorWidth : styleData.handlePosition
                height: parent.height

                property real zeroValuePosition:            (Math.abs(control.minimumValue) / (control.maximumValue - control.minimumValue)) * parent.width
                property real zeroCenteredIndicatorStart:   Math.min(styleData.handlePosition, zeroValuePosition)
                property real zeroCenteredIndicatorStop:    Math.max(styleData.handlePosition, zeroValuePosition)
                property real centerIndicatorWidth:         zeroCenteredIndicatorStop - zeroCenteredIndicatorStart

                Rectangle {
                    anchors.fill:   parent
                    color:          MyWindowsColor.colorBlue
                    border.color:   Qt.darker(color, 1.2)
                    radius:         height/2
                }
            }
        }

        handle: Rectangle {
            anchors.centerIn: parent
            color:          MyWindowsColor.button
            border.color:   MyWindowsColor.buttonText
            border.width:   1
            implicitWidth:  _radius * 2
            implicitHeight: _radius * 2
            radius:         _radius
            property real _radius: Math.round(MyWindowItmeSize.defaultFontPixelHeight * 0.75)
            Label {
                text:               _root.value.toFixed(0)
                visible:            _root.displayValue
                anchors.centerIn:   parent
                font.family:        MyWindowItmeSize.normalFontFamily
                font.pointSize:     MyWindowItmeSize.smallFontPointSize
                color:              MyWindowsColor.buttonText
            }
        }
    }
}
