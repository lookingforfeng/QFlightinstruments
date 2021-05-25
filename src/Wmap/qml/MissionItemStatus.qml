import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import "."



Rectangle {
    id:         root
    radius:     MyWindowItmeSize.defaultFontPixelWidth * 0.5
    color:      MyWindowsColor.window
    opacity:    0.80
    clip:       true


    property var missionItems                ///< List of all available mission items

    property real maxWidth:          parent.width
    readonly property real _margins: MyWindowItmeSize.defaultFontPixelWidth

    onMaxWidthChanged: {
        var calcLength = (statusListView.count + 1) * (statusListView.count ? statusListView.contentItem.children[0].width : 1)
        root.width = root.maxWidth > calcLength ? calcLength : root.maxWidth
    }


    CommonLabel {
        id:                     label
        anchors.top:            parent.bottom
        width:                  parent.height
        text:                   qsTr("航点高度")
        horizontalAlignment:    Text.AlignHCenter
        rotation:               -90
        transformOrigin:        Item.TopLeft
    }

    CommonListView {
        id:                     statusListView
        anchors.margins:        _margins
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.leftMargin:     MyWindowItmeSize.defaultFontPixelHeight
        anchors.left:           parent.left
        anchors.right:          parent.right
        model:                  missionItems
        highlightMoveDuration:  250
        orientation:            ListView.Horizontal
        spacing:                0
        clip:                   true
        //currentIndex:           _missionController.currentPlanViewIndex

        onCountChanged: {
            var calcLength = (statusListView.count + 1) * (statusListView.count ? statusListView.contentItem.children[0].width : 1)
            root.width = root.maxWidth > calcLength ? calcLength : root.maxWidth
        }

        delegate: Item {
            height:     statusListView.height
            width:      display ? (indicator.width + spacing)  : 0
            visible:    display

            property real availableHeight:      height - indicator.height
            property bool _coordValid:          object.coordinate.isValid
            property bool _terrainAvailable:    !isNaN(object.terrainPercent)
            property real _terrainPercent:      _terrainAvailable ? object.terrainPercent : 1

            readonly property bool display: true//object.specifiesCoordinate && !object.isStandaloneCoordinate
            readonly property real spacing: MyWindowItmeSize.defaultFontPixelWidth * MyWindowItmeSize.smallFontPointRatio

            Rectangle {
                anchors.bottom:             parent.bottom
                anchors.horizontalCenter:   parent.horizontalCenter
                width:                      indicator.width
                height:                     _terrainAvailable ? Math.max(availableHeight * _terrainPercent, 1) : parent.height
                color:                      _terrainAvailable ? (object.terrainCollision ? "red": MyWindowsColor.text) : "yellow"
                visible:                    _coordValid
            }

            MissionItemIndexLabel {
                id:                         indicator
                anchors.horizontalCenter:   parent.horizontalCenter
                y:                          availableHeight - (availableHeight * object.altPercent)
                small:                      true
                checked:                    object.isCurrentItem
                label:                      object.abbreviation.charAt(0)
                index:                      object.abbreviation.charAt(0) > 'A' && object.abbreviation.charAt(0) < 'z' ? -1 : object.sequenceNumber
                visible:                    true
            }
        }
    }
}


