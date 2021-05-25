import QtQuick          2.3
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0



Item {
    id:     _root
    width:  height
    state:  "HelpShown"
    clip:   true

    property alias          source:         icon.source
    property bool           checked:        false

    signal clicked()

    readonly property real _topBottomMargins: MyWindowItmeSize.defaultFontPixelHeight / 2

    ColoredImage {
        id:                     icon
        anchors.left:           parent.left
        anchors.right:          parent.right
        anchors.topMargin:      _topBottomMargins
        anchors.top:            parent.top
        anchors.bottomMargin:   _topBottomMargins
        anchors.bottom:         parent.bottom
        sourceSize.height:      parent.height
        fillMode:               Image.PreserveAspectFit
        color:                  checked ?MyWindowsColor.buttonHighlight : MyWindowsColor.buttonText

    }

//    Rectangle {
//        anchors.left:   parent.left
//        anchors.right:  parent.right
//        anchors.bottom: parent.bottom
//        height:         _topBottomMargins * 0.25
//        color:         MyWindowsColor.buttonHighlight
//        visible:        checked
//    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            checked = true
            _root.clicked()
        }
    }
}
