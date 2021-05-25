import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import "."

Rectangle{
    anchors.fill: parent
    color:MyWindowsColor.window

    readonly property real _defaultTextHeight:  MyWindowItmeSize.defaultFontPixelHeight
    readonly property real _defaultTextWidth:   MyWindowItmeSize.defaultFontPixelWidth
    readonly property real _horizontalMargin:   _defaultTextWidth / 2
    readonly property real _verticalMargin:     _defaultTextHeight / 2

    Component.onCompleted: {
        __rightPanel.source="qrc:/qml/offlineMap.qml"
    }

    Flickable{
        id:                 buttonList
        width:              buttonColumn.width
        anchors.topMargin:  _verticalMargin
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        anchors.leftMargin: _horizontalMargin
        anchors.left:       parent.left
        contentHeight:      buttonColumn.height + _verticalMargin
        flickableDirection: Flickable.VerticalFlick
        clip:               true
        z:5

        ColumnLayout{
            id:         buttonColumn
            spacing:    _verticalMargin
            CommonLabel {
                Layout.fillWidth:       true
                text:                   qsTr("       应用设置        ")
                wrapMode:               Text.WordWrap
                horizontalAlignment:    Text.AlignHCenter
                visible:                true
            }
            CommonButton{
                height: 20
                text: qsTr("离线地图设置")
                Layout.fillWidth:   true
                onClicked: {
                    if(__rightPanel.source !== "qrc:/qml/offlineMap.qml") {
                        __rightPanel.source = "qrc:/qml/offlineMap.qml"
                    }
                    checked = true
                }
            }
        } 
    }

    Rectangle {
        id:                     divider
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.leftMargin:     _horizontalMargin
        anchors.left:           buttonList.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        width:                  1
        color:                  MyWindowsColor.windowShade
    }

    //-- Panel Contents
    Loader {
        id:                     __rightPanel
        anchors.leftMargin:     _horizontalMargin
        anchors.rightMargin:    _horizontalMargin
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.left:           divider.right
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
    }
}



