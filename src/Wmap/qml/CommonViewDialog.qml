/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import "."




FactPanel {
    property real defaultTextWidth:   MyWindowItmeSize.defaultFontPixelWidth
    property real defaultTextHeight:    MyWindowItmeSize.defaultFontPixelHeight


    signal hideDialog

    Keys.onReleased: {
        if (event.key === Qt.Key_Escape) {
            reject()
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            accept()
            event.accepted = true
        }
    }

    function accept() {
        if (acceptAllowed) {
            Qt.inputMethod.hide()
            hideDialog()
        }
    }

    function reject() {
        if (rejectAllowed) {
            Qt.inputMethod.hide()
            hideDialog()
        }
    }

    color:MyWindowsColor.windowShadeDark
}
