import QtQuick          2.3
import QtQuick.Controls 1.2


Rectangle {
    id:             mapButton
    anchors.margins: MyWindowItmeSize.defaultFontPixelWidth
    color:          _showHighlight ? MyWindowsColor.buttonHighlight : MyWindowsColor.button
    border.width:   _showBorder ? 1: 0
    border.color:   MyWindowsColor.buttonText

    property var    tileSet:    null
    property var    currentSet: null
    property bool   checked:    false
    property bool   complete:   false
    property alias  text:       nameLabel.text
    property int    tiles:      0
    property string size:       ""

    property bool   _showHighlight: (_pressed | _hovered | checked)
    property bool   _showBorder:    false
    property int    _lastGlobalMouseX: 0
    property int    _lastGlobalMouseY: 0
    property bool   _pressed:          false
    property bool   _hovered:          false

    signal clicked()

    property ExclusiveGroup exclusiveGroup:  null
    onExclusiveGroupChanged: {
        if (exclusiveGroup) {
            checked = false
            exclusiveGroup.bindCheckable(mapButton)
        }
    }
    onCheckedChanged: {
        if(checked) {
            currentSet = tileSet
        }
    }

    Row {
        anchors.centerIn: parent
        CommonLabel {
            id:     nameLabel
            width:  mapButton.width * 0.4
            color:  _showHighlight ? MyWindowsColor.buttonHighlightText : MyWindowsColor.buttonText
            anchors.verticalCenter: parent.verticalCenter
        }
        CommonLabel {
            id:     sizeLabel
            width:  mapButton.width * 0.4
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
            color:  _showHighlight ? MyWindowsColor.buttonHighlightText : MyWindowsColor.buttonText
            text:   mapButton.size + (tiles > 0 ? " (" + tiles + " tiles)" : "")
        }
        Item {
            width: MyWindowItmeSize.defaultFontPixelWidth * 2
            height: 1
        }
        //完成与否的颜色指示
        Rectangle {
            width:   sizeLabel.height * 0.5
            height:  sizeLabel.height * 0.5
            radius:  width / 2
            color:   complete ? "#31f55b" : "#fc5656"
            opacity: sizeLabel.text.length > 0 ? 1 : 0
            anchors.verticalCenter: parent.verticalCenter
        }
        Item {
            width:  MyWindowItmeSize.defaultFontPixelWidth * 2
            height: 1
        }
        CommonColoredImage
        {
            width:      sizeLabel.height * 0.8
            height:     sizeLabel.height * 0.8
            sourceSize.height:  height
            source:     "/image/buttonRight.svg"
            mipmap:     true
            fillMode:   Image.PreserveAspectFit
            color:      _showHighlight ? MyWindowsColor.buttonHighlightText : MyWindowsColor.buttonText
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        onEntered:  {
            _hovered = true
        }
        onExited:   {
            _hovered = false
        }
        onPressed:  {
            _pressed = true
        }
        onReleased: {
            _pressed = false
        }
        onClicked: {
            checked = true
            mapButton.clicked()
        }
    }


}
