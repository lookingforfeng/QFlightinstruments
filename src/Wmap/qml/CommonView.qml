/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/// @file
///     @author Don Gagne <don@thegagnes.com>

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import "."

FactPanel {
    id: _rootItem
    property bool   completedSignalled:   false
    property var    viewPanel

    /// This is signalled when the top level Item reaches Component.onCompleted. This allows
    /// the view subcomponent to connect to this signal and do work once the full ui is ready
    /// to go.
    signal completed

    function _checkForEarlyDialog(title) {
        if (!completedSignalled) {
            console.warn(qsTr("showDialog called before QGCView.completed signalled"), title)
        }
    }

    /// Shows a QGCViewDialog component
    ///     @param compoent QGCViewDialog component
    ///     @param title Title for dialog
    ///     @param charWidth Width of dialog in characters
    ///     @param buttons Buttons to show in dialog using StandardButton enum

    readonly property int showDialogFullWidth:      -1  ///< Use for full width dialog
    readonly property int showDialogDefaultWidth:   40  ///< Use for default dialog width

    function showDialog(component, title, charWidth, buttons) {
        if (_checkForEarlyDialog(title)) {
            return
        }

        var dialogComponent = Qt.createComponent("QGCViewDialogContainer.qml")
        if (dialogComponent.status === Component.Error) {
            console.log("Error loading QGCViewDialogContainer.qml: ", dialogComponent.errorString())
            return
        }
        var dialogWidth = charWidth === showDialogFullWidth ? parent.width :MyWindowItmeSize.defaultFontPixelWidth * charWidth
        var dialog = dialogComponent.createObject(_rootItem,
                                                  {
                                                      "anchors.fill":       _rootItem,
                                                      "dialogWidth":        dialogWidth,
                                                      "dialogTitle":        title,
                                                      "dialogComponent":    component,
                                                      "viewPanel":          viewPanel
                                                  })
        dialog.setupDialogButtons(buttons)
        dialog.focus = true
        viewPanel.enabled = false
    }

    function showMessage(title, message, buttons) {
        _messageDialogText = message
        showDialog(_messageDialog, title, showDialogDefaultWidth, buttons)
    }

    property real defaultTextWidth:     MyWindowItmeSize.defaultFontPixelWidth
    property real defaultTextHeight:    MyWindowItmeSize.defaultFontPixelHeight

    property string _messageDialogText

    function _signalCompleted() {
        // When we use this control inside a QGCQmlWidgetHolder Component.onCompleted is signalled
        // before the width and height are adjusted. So we need to wait for width and heigth to be
        // set before we signal our own completed signal.
        if (!completedSignalled && width != 0 && height != 0) {
            completedSignalled = true
            completed()
        }
    }

    Component.onCompleted:  _signalCompleted()
    onWidthChanged:         _signalCompleted()
    onHeightChanged:        _signalCompleted()

    Component {
        id: _messageDialog

        CommonViewMessage {
            message: _messageDialogText
        }
    }
}
