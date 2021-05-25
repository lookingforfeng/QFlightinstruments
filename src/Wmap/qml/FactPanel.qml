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
import "."




FocusScope {
    property alias color: rectangle.color

    property string __missingParams:    ""
    property string __errorMsg:         ""

    function showMissingParameterOverlay(missingParamName) {
        if (__missingParams.length != 0) {
            __missingParams = __missingParams.concat(", ")
        }
        __missingParams = __missingParams.concat(missingParamName)
        __missingParamsOverlay.visible = true
    }

    function showError(errorMsg) {
        __errorMsg = errorMsg
        __missingParamsOverlay.visible = true
    }

    Rectangle {
        id:     rectangle
        color: MyWindowsColor.window

        Rectangle {
            id:             __missingParamsOverlay
            anchors.fill:   parent
            z:              9999
            visible:        false
            color:          MyWindowsColor.window
            opacity:        0.85

            CommonLabel {
                anchors.fill:   parent
                wrapMode:       Text.WordWrap
                text:           __errorMsg.length ? __errorMsg : qsTr("Parameters(s) missing: %1").arg(__missingParams)
            }
        }
    }
}
