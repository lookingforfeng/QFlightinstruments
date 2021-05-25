import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtGraphicalEffects 1.0
import "."


FocusScope {

    id:             _root
    anchors.left:   parent.left
    anchors.right:  parent.right
    height:         column.height

    property alias          text:           label.text
    property bool           checked:        true
    property bool           showSpacer:     true
    property ExclusiveGroup exclusiveGroup: null

    property real   _sectionSpacer: MyWindowItmeSize.defaultFontPixelWidth / 2  // spacing between section headings

    onExclusiveGroupChanged: {
        if (exclusiveGroup)
            exclusiveGroup.bindCheckable(_root)
    }


    CommonMouseArea {
        anchors.fill: parent

        onClicked: {
            _root.focus = true
            checked = !checked
        }

        ColumnLayout {
            id:             column
            anchors.left:   parent.left
            anchors.right:  parent.right

            Item {
                height:     _sectionSpacer
                width:      1
                visible:    showSpacer
            }

            CommonLabel {
                id:                 label
                Layout.fillWidth:   true

                CommonColoredImage {
                    id:                     image
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width:                  label.height / 2
                    height:                 width
                    source:                 "/image/arrow-down.png"
                    color:                  MyWindowsColor.text
                    visible:                !_root.checked
                }
            }

            Rectangle {
                Layout.fillWidth:   true
                height:             1
                color:              MyWindowsColor.text
            }
        }
    }
}
