import QtQuick 2.3
import "."


/// Works just like a regular MouseArea except:
///     1) It supports the ability to show touch extents based on QGroundControl.showTouchAreas
///     2) You can specify fillItem and it will automatically fill to the size and adjust touch areas on mobile
MouseArea {

    anchors.leftMargin:     fillItem ? -_touchMarginHorizontal : 0
    anchors.rightMargin:    fillItem ? -_touchMarginHorizontal : 0
    anchors.topMargin:      fillItem ? -_touchMarginVertical : 0
    anchors.bottomMargin:   fillItem ? -_touchMarginVertical : 0
    anchors.fill:           fillItem ? fillItem : undefined

    property var    fillItem
    property bool   debugMobile:    false   ///< Allows you to debug mobile sizing on desktop builds

    property real _itemWidth:               fillItem ? fillItem.width : width
    property real _itemHeight:              fillItem ? fillItem.height : height
    property real _touchWidth:              Math.max(_itemWidth, MyWindowItmeSize.minTouchPixels)
    property real _touchHeight:             Math.max(_itemHeight, MyWindowItmeSize.minTouchPixels)
    property real _touchMarginHorizontal:  MyWindowItmeSize.isMobile ? (_touchWidth - _itemWidth) / 2 : 0
    property real _touchMarginVertical:    MyWindowItmeSize.isMobile ? (_touchHeight - _itemHeight) / 2 : 0

    Rectangle {
        anchors.fill:   parent
        border.color:   "red"
        border.width:   0
        color:          "transparent"
    }
}
