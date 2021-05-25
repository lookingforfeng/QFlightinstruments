import QtQuick          2.3
import QtQuick.Controls 1.2
import "."


/// File Button controls used by QGCFileDialog control
Rectangle {
    implicitWidth:  MyWindowItmeSize.implicitButtonWidth
    implicitHeight: MyWindowItmeSize.implicitButtonHeight
    color:          highlight ? MyWindowsColor.buttonHighlight : MyWindowsColor.button
    border.color:   highlight ? MyWindowsColor.buttonHighlightText : MyWindowsColor.buttonText

    property alias  text:       label.text
    property bool   highlight:  false

    signal clicked
    signal hamburgerClicked

    property real _margins: MyWindowItmeSize.defaultFontPixelWidth / 2




    CommonLabel {
        id:                     label
        anchors.margins:         _margins
        anchors.left:           parent.left
        anchors.right:          hamburger.left
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        verticalAlignment:      Text.AlignVCenter
        horizontalAlignment:    Text.AlignHCenter
        color:                  highlight ? MyWindowsColor.buttonHighlightText : MyWindowsColor.buttonText
        elide:                  Text.ElideRight
    }

    CommonColoredImage {
        id:                     hamburger
        anchors.rightMargin:    _margins
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        width:                  _hamburgerSize
        height:                 _hamburgerSize
        sourceSize.height:      _hamburgerSize
        source:                 "qrc:/qmlimages/Hamburger.svg"
        color:                  highlight ? MyWindowsColor.buttonHighlightText : MyWindowsColor.buttonText

        property real _hamburgerSize: parent.height * 0.75
    }

    CommonMouseArea {
        anchors.fill:   parent
        onClicked:      parent.clicked()
    }

    CommonMouseArea {
        anchors.leftMargin: -_margins * 2
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        anchors.right:      parent.right
        anchors.left:       hamburger.left
        onClicked:          parent.hamburgerClicked()
    }
}
