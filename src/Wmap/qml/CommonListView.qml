import QtQuick 2.3
import "."



/// QGC version of ListVIew control that shows horizontal/vertial scroll indicators
ListView {
    id:             root
    boundsBehavior: Flickable.StopAtBounds

    property color indicatorColor: MyWindowsColor.text


    Component.onCompleted: {
        var indicatorComponent = Qt.createComponent("QGCFlickableVerticalIndicator.qml")
        indicatorComponent.createObject(root)
        indicatorComponent = Qt.createComponent("QGCFlickableHorizontalIndicator.qml")
        indicatorComponent.createObject(root)
    }
}
