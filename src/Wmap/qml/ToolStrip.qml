﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2


Rectangle {
    id:         _root


    color:      MyWindowsColor.window
    width:       MyWindowItmeSize.defaultFontPixelWidth * 5
    height:     buttonStripColumn.height + (buttonStripColumn.anchors.margins * 2)
    radius:     _radius
    border.width:   1

    property string title:              "Title"
    property alias  model:              repeater.model
    property var    showAlternateIcon                   ///< List of bool values, one for each button in strip - true: show alternate icon, false: show normal icon
    property var    rotateImage                         ///< List of bool values, one for each button in strip - true: animation rotation, false: static image
    property var    animateImage                        ///< List of bool values, one for each button in strip - true: animate image, false: static image
    property var    buttonEnabled                       ///< List of bool values, one for each button in strip - true: button enabled, false: button disabled
    property var    buttonVisible                       ///< List of bool values, one for each button in strip - true: button visible, false: button invisible
    property real   maxHeight                           ///< Maximum height for control, determines whether text is hidden to make control shorter

    signal clicked(int index, bool checked)

    readonly property real  _radius:                MyWindowItmeSize.defaultFontPixelWidth / 2
    readonly property real  _margin:                MyWindowItmeSize.defaultFontPixelWidth / 2
    readonly property real  _buttonSpacing:         MyWindowItmeSize.defaultFontPixelWidth

    property bool _showOptionalElements: true

    ExclusiveGroup { id: dropButtonsExclusiveGroup }

    function uncheckAll() {
        dropButtonsExclusiveGroup.current = null
        // Signal all toggles as off
        for (var i=0; i<model.length; i++) {
            if (model[i].toggle === true) {
                _root.clicked(i, false)
            }
        }
    }
	
    DeadMouseArea {
        anchors.fill: parent
    }

    Column {
        id:                 buttonStripColumn
        anchors.margins:    MyWindowItmeSize.defaultFontPixelWidth  / 2
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right

        CommonLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            text:                       title
            visible:                    _showOptionalElements
        }

        Item { width: 1; height: _buttonSpacing; visible: _showOptionalElements }

        Rectangle {
            anchors.left:       parent.left
            anchors.right:      parent.right
            height:             1
            color:              MyWindowsColor.text
            visible:            _showOptionalElements
        }

        Repeater {
            id: repeater

            delegate: Column {
                id:         buttonColumn
                width:      buttonStripColumn.width
                visible:    _root.buttonVisible ? _root.buttonVisible[index] : true

                property bool checked: false
                property ExclusiveGroup exclusiveGroup: dropButtonsExclusiveGroup


                property bool   _buttonEnabled:         _root.buttonEnabled ? _root.buttonEnabled[index] : true
                property var    _iconSource:            modelData.iconSource
                property var    _alternateIconSource:   modelData.alternateIconSource
                property var    _source:                (_root.showAlternateIcon && _root.showAlternateIcon[index]) ? _alternateIconSource : _iconSource
                property bool   rotateImage:            _root.rotateImage ? _root.rotateImage[index] : false
                property bool   animateImage:           _root.animateImage ? _root.animateImage[index] : false

                onExclusiveGroupChanged: {
                    if (exclusiveGroup) {
                        exclusiveGroup.bindCheckable(buttonColumn)
                    }
                }

                onRotateImageChanged: {
                    if (rotateImage) {
                        imageRotation.running = true
                    } else {
                        imageRotation.running = false
                        button.rotation = 0
                    }
                }

                onAnimateImageChanged: {
                    if (animateImage) {
                        opacityAnimation.running = true
                    } else {
                        opacityAnimation.running = false
                        button.opacity = 1
                    }
                }

                Item {
                    width:      1
                    height:     _buttonSpacing
                    visible:    index == 0 ? _showOptionalElements : true
                }

                FocusScope {
                    id:             scope
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    height:         width * 0.8

                    Rectangle {
                        anchors.fill:   parent
                        color:          checked ? MyWindowsColor.buttonHighlight : MyWindowsColor.button

                        ColoredImage {
                            id:                 button
                            height:             parent.height
                            width:              height
                            anchors.centerIn:   parent
                            source:             _source
                            sourceSize.height:  height
                            fillMode:           Image.PreserveAspectFit
                            mipmap:             true
                            smooth:             true
                            color:              checked ? MyWindowsColor.buttonHighlightText : MyWindowsColor.buttonText

                            RotationAnimation on rotation {
                                id:             imageRotation
                                loops:          Animation.Infinite
                                from:           0
                                to:             360
                                duration:       500
                                running:        false
                            }

                            NumberAnimation on opacity {
                                id:         opacityAnimation
                                running:    false
                                from:       0
                                to:         1.0
                                loops:      Animation.Infinite
                                duration:   2000
                            }
                        }

                        MouseArea {
                            // Size of mouse area is expanded to make touch easier
                            anchors.leftMargin:     -buttonStripColumn.anchors.margins
                            anchors.rightMargin:    -buttonStripColumn.anchors.margins
                            anchors.left:           parent.left
                            anchors.right:          parent.right
                            anchors.top:            parent.top
                            height:                 parent.height + (_showOptionalElements? buttonLabel.height + buttonColumn.spacing : 0)
                            visible:                _buttonEnabled
                            preventStealing:        true

                            onClicked: {
                                scope.focus = true
                                if (modelData.dropPanelComponent === undefined) {
                                    dropPanel.hide()
                                    if (modelData.toggle === true) {
                                        checked = !checked
                                    } else {
                                        // dropPanel.hide above will close panel, but we need to do this to clear toggles
                                        uncheckAll()
                                    }
                                    _root.clicked(index, checked)
                                } else {
                                    if (checked) {
                                        dropPanel.hide()    // hide affects checked, so this needs to be duplicated inside not outside if
                                    } else {
                                        dropPanel.hide()    // hide affects checked, so this needs to be duplicated inside not outside if
                                        uncheckAll()
                                        checked = true
                                        var panelEdgeTopPoint = mapToItem(_root, width, 0)
                                        dropPanel.show(panelEdgeTopPoint, height, modelData.dropPanelComponent)
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    width:      1
                    height:     MyWindowItmeSize.defaultFontPixelHeight * 0.25
                    visible:    _showOptionalElements
                }

                CommonLabel {
                    id:                         buttonLabel
                    anchors.horizontalCenter:   parent.horizontalCenter
                    font.pointSize:             MyWindowItmeSize.smallFontPointSize
                    text:                       modelData.name
                    visible:                    _showOptionalElements
                    enabled:                    _buttonEnabled
                }
            }
        }
    }
        DropPanel {
        id:         dropPanel
        toolStrip:  _root
    }
}
