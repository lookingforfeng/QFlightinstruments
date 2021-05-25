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
import QtLocation       5.3
import QtPositioning    5.3
import QtQuick.Dialogs  1.2



/// QGCMapPolygon map visuals
Item {
    id: _root

    property MyMap    mapControl                                  ///< Map control to place item in
    property var    mapPolygon                                  ///< QGCMapPolygon object
    property bool   interactive:       true //mapPolygon.interactive
    property color  interiorColor:      "transparent"
    property real   interiorOpacity:    1
    property int    borderWidth:        0
    property color  borderColor:        "black"
    property string missionSavePath:   "path?" //QGroundControl.settingsManager.appSettings.missionSavePath

    property var    _polygonComponent
    property var    _dragHandlesComponent
    property var    _splitHandlesComponent
    property var    _centerDragHandleComponent
    property bool   _circle:                    false
    property real   _circleRadius
    property bool   _editCircleRadius:          false
    property bool   _visible: false

    property real _zorderDragHandle:    5 + 3   // Highest to prevent splitting when items overlap
    property real _zorderSplitHandle:   5 + 2
    property real _zorderCenterHandle:  5 + 1   // Lowest such that drag or split takes precedence



    function addVisuals() {
        if  (!_polygonComponent)
        {
            _polygonComponent = polygonComponent.createObject(mapControl)
        }
        mapControl.addMapItem(_polygonComponent)
    }

    function removeVisuals() {
        _polygonComponent.destroy()
    }

    function addHandles() {
        if (!_dragHandlesComponent) {
            _dragHandlesComponent = dragHandlesComponent.createObject(mapControl)
            _splitHandlesComponent = splitHandlesComponent.createObject(mapControl)
            _centerDragHandleComponent = centerDragHandleComponent.createObject(mapControl)
        }
        _centerDragHandleComponent.addCenterDrag();
    }

    function removeHandles() {
        if (_dragHandlesComponent) {
            _dragHandlesComponent.destroy()
            _dragHandlesComponent = undefined
        }
        if (_splitHandlesComponent) {
            _splitHandlesComponent.destroy()
            _splitHandlesComponent = undefined
        }
        if (_centerDragHandleComponent) {
            _centerDragHandleComponent.destroy()
            _centerDragHandleComponent = undefined
        }
    }

    /// Calculate the default/initial 4 sided polygon
    function defaultPolygonVertices() {

        //±ßÔµ¿ÕÓàµÄÃæ»ý
        var margin_area=0.5

        // Initial polygon is inset to take 2/3rds space
        var rect = Qt.rect(mapControl.centerViewport.x, mapControl.centerViewport.y, mapControl.centerViewport.width, mapControl.centerViewport.height)
        rect.x += (rect.width * margin_area) / 2
        rect.y += (rect.height * margin_area) / 2
        rect.width *= margin_area
        rect.height *= margin_area


        var centerCoord =       mapControl.toCoordinate(Qt.point(rect.x + (rect.width / 2), rect.y + (rect.height / 2)),   false /* clipToViewPort */)
        var topLeftCoord =      mapControl.toCoordinate(Qt.point(rect.x, rect.y),                                          false /* clipToViewPort */)
        var topRightCoord =     mapControl.toCoordinate(Qt.point(rect.x + rect.width, rect.y),                             false /* clipToViewPort */)
        var bottomLeftCoord =   mapControl.toCoordinate(Qt.point(rect.x, rect.y + rect.height),                            false /* clipToViewPort */)
        var bottomRightCoord =  mapControl.toCoordinate(Qt.point(rect.x + rect.width, rect.y + rect.height),               false /* clipToViewPort */)

        // Initial polygon has max width and height of 3000 meters
        //        var halfWidthMeters =   Math.min(topLeftCoord.distanceTo(topRightCoord), 3000) / 2
        //        var halfHeightMeters =  Math.min(topLeftCoord.distanceTo(bottomLeftCoord), 3000) / 2

        var halfWidthMeters =  topLeftCoord.distanceTo(topRightCoord) / 2
        var halfHeightMeters = topLeftCoord.distanceTo(bottomLeftCoord) / 2
        topLeftCoord =      centerCoord.atDistanceAndAzimuth(halfWidthMeters, -90).atDistanceAndAzimuth(halfHeightMeters, 0)
        topRightCoord =     centerCoord.atDistanceAndAzimuth(halfWidthMeters, 90).atDistanceAndAzimuth(halfHeightMeters, 0)
        bottomLeftCoord =   centerCoord.atDistanceAndAzimuth(halfWidthMeters, -90).atDistanceAndAzimuth(halfHeightMeters, 180)
        bottomRightCoord =  centerCoord.atDistanceAndAzimuth(halfWidthMeters, 90).atDistanceAndAzimuth(halfHeightMeters, 180)

        return [ topLeftCoord, topRightCoord, bottomRightCoord, bottomLeftCoord, centerCoord  ]
    }

    /// Add an initial 4 sided polygon
    function addInitialPolygon() {
        if (mapPolygon.count < 3) {
            var initialVertices = defaultPolygonVertices()
            mapPolygon.appendVertex(initialVertices[0])
            mapPolygon.appendVertex(initialVertices[1])
            mapPolygon.appendVertex(initialVertices[2])
            mapPolygon.appendVertex(initialVertices[3])

        }
    }

    /// Reset polygon back to initial default
    function resetPolygon() {
        var initialVertices = defaultPolygonVertices()
        mapPolygon.clear()
        for (var i=0; i<4; i++) {
            mapPolygon.appendVertex(initialVertices[i])
        }
        _circle = false
    }

    function setCircleRadius(center, radius) {
        var unboundCenter = center.atDistanceAndAzimuth(0, 0)
        _circleRadius = radius
        var segments = 16
        var angleIncrement = 360 / segments
        var angle = 0
        mapPolygon.clear()
        for (var i=0; i<segments; i++) {
            var vertex = unboundCenter.atDistanceAndAzimuth(_circleRadius, angle)
            mapPolygon.appendVertex(vertex)
            angle += angleIncrement
        }
        _circle = true
    }

    /// Reset polygon to a circle which fits within initial polygon
    function resetCircle() {
        var initialVertices = defaultPolygonVertices()
        var width = initialVertices[0].distanceTo(initialVertices[1])
        var height = initialVertices[1].distanceTo(initialVertices[2])
        var radius = Math.min(width, height) / 2
        var center = initialVertices[4]
        setCircleRadius(center, radius)
    }


    onInteractiveChanged: {
        if (interactive) {
            addHandles()
        } else {
            removeHandles()
        }
    }

    Component.onCompleted: {
        addInitialPolygon()
        addVisuals()
        if (interactive) {
            addHandles()
        }

    }

    Component.onDestruction: {
        removeVisuals()
        removeHandles()
    }


    Component {
        id: polygonComponent

        MapPolygon {
            color:          interiorColor
            opacity:        interiorOpacity
            border.color:   borderColor
            border.width:   borderWidth
            path:           mapPolygon.path
            visible: _visible
        }

    }

    Component {
        id: splitHandleComponent

        MapQuickItem {
            id:             mapQuickItem
            anchorPoint.x:  dragHandle.width / 2
            anchorPoint.y:  dragHandle.height / 2
            visible:        !_circle && _visible

            property int vertexIndex

            sourceItem: Rectangle {
                id:         dragHandle
                width:      MyWindowItmeSize.defaultFontPixelHeight * 1.5
                height:     width
                radius:     width / 2
                border.color:      "white"
                color:      "transparent"
                opacity:    .50
                z:          _zorderSplitHandle

                CommonLabel {
                    anchors.horizontalCenter:   parent.horizontalCenter
                    anchors.verticalCenter:     parent.verticalCenter
                    text:                       "+"
                }

                CommonMouseArea {
                    fillItem:   parent
                    onClicked:  mapPolygon.splitPolygonSegment(mapQuickItem.vertexIndex)
                }
            }
        }
    }

    Component {
        id: splitHandlesComponent

        Repeater {
            model: mapPolygon.path

            delegate: Item {
                property var _splitHandle
                property var _vertices:     mapPolygon.path

                function _setHandlePosition() {
                    var nextIndex = index + 1
                    if (nextIndex > _vertices.length - 1) {
                        nextIndex = 0
                    }
                    var distance = _vertices[index].distanceTo(_vertices[nextIndex])
                    var azimuth = _vertices[index].azimuthTo(_vertices[nextIndex])
                    _splitHandle.coordinate = _vertices[index].atDistanceAndAzimuth(distance / 2, azimuth)
                }

                Component.onCompleted: {
                    _splitHandle = splitHandleComponent.createObject(mapControl)
                    _splitHandle.vertexIndex = index
                    _setHandlePosition()
                    mapControl.addMapItem(_splitHandle)
                }

                Component.onDestruction: {
                    if (_splitHandle) {
                        _splitHandle.destroy()
                    }
                }
            }
        }
    }

    // Control which is used to drag polygon vertices
    Component {
        id: dragAreaComponent

        MissionItemIndicatorDrag {
            id:         dragArea
            mapControl: _root.mapControl
            z:          _zorderDragHandle
            visible:    !_circle&& _visible

            property int polygonVertex

            property bool _creationComplete: false

            Component.onCompleted: _creationComplete = true

            onItemCoordinateChanged: {
                if (_creationComplete) {
                    // During component creation some bad coordinate values got through which screws up draw
                    mapPolygon.adjustVertex(polygonVertex, itemCoordinate)
                }
            }


        }
    }

    Component {
        id: centerDragHandle
        MapQuickItem {
            id:             mapQuickItem
            anchorPoint.x:  dragHandle.width  * 0.5
            anchorPoint.y:  dragHandle.height * 0.5
            z:              _zorderDragHandle
            visible: _visible
            sourceItem: Rectangle {
                id:             dragHandle
                width:          MyWindowItmeSize.defaultFontPixelHeight * 1.5
                height:         width
                radius:         width * 0.5
                color:          Qt.rgba(1,1,1,0.8)
                border.color:   Qt.rgba(0,0,0,0.25)
                border.width:   1
                CommonColoredImage {
                    width:      parent.width
                    height:     width
                    color:      Qt.rgba(0,0,0,1)
                    mipmap:     true
                    fillMode:   Image.PreserveAspectFit
                    source:     "/image/MapCenter.svg"
                    sourceSize.height:  height
                    anchors.centerIn:   parent
                }
                Label{

                    id: areaText
                    anchors.horizontalCenter: dragHandle.horizontalCenter
                    anchors.verticalCenter:  dragHandle.verticalCenter
                    anchors.verticalCenterOffset: -dragHandle.width
                    font.pixelSize: 25
                    color:"yellow"
                    text: mapPolygon.area.toFixed(2)+" sq.km"
                }
            }
        }
    }

    Component {
        id: dragHandleComponent

        MapQuickItem {
            id:             mapQuickItem
            anchorPoint.x:  dragHandle.width  / 2
            anchorPoint.y:  dragHandle.height / 2
            z:              _zorderDragHandle
            visible:        !_circle&& _visible

            property int polygonVertex

            sourceItem: Rectangle {
                id:             dragHandle
                width:          MyWindowItmeSize.defaultFontPixelHeight * 1.5
                height:         width
                radius:         width * 0.5
                color:          Qt.rgba(1,1,1,0.8)
                border.color:   Qt.rgba(0,0,0,0.25)
                border.width:   1
            }
        }
    }

    // Add all polygon vertex drag handles to the map
    Component {
        id: dragHandlesComponent

        Repeater {
            model: mapPolygon.pathModel

            delegate: Item {
                property var _visuals: [ ]

                Component.onCompleted: {
                    var dragHandle = dragHandleComponent.createObject(mapControl)
                    dragHandle.coordinate = Qt.binding(function() { return object.coordinate })
                    dragHandle.polygonVertex = Qt.binding(function() { return index })
                    _root.mapControl.addMapItem(dragHandle)
                    var dragArea = dragAreaComponent.createObject(mapControl, { "itemIndicator": dragHandle, "itemCoordinate": object.coordinate })
                    dragArea.polygonVertex = Qt.binding(function() { return index })
                    _visuals.push(dragHandle)
                    _visuals.push(dragArea)
                }

                Component.onDestruction: {
                    for (var i=0; i<_visuals.length; i++) {
                        _visuals[i].destroy()
                    }
                    _visuals = [ ]
                }
            }
        }
    }

    /* Component {
        id: editPositionDialog

        EditPositionDialog {
            coordinate: mapPolygon.center
            onCoordinateChanged: mapPolygon.center = coordinate
        }
    }*/

    Component {
        id: centerDragAreaComponent

        MissionItemIndicatorDrag {
            mapControl:                 _root.mapControl
            z:                          _zorderCenterHandle
            onItemCoordinateChanged:    mapPolygon.center = itemCoordinate
            onDragStart:                mapPolygon.centerDrag = true
            onDragStop:                 mapPolygon.centerDrag = false



            function setRadiusFromDialog() {
                var radius = radiusField.text//QGroundControl.appSettingsDistanceUnitsToMeters(radiusField.text)
                setCircleRadius(mapPolygon.center, radius)
                _editCircleRadius = false
            }

            Rectangle {
                anchors.margins:    _margin
                anchors.left:       parent.right
                width:              radiusColumn.width + (_margin *2)
                height:             radiusColumn.height + (_margin *2)
                color:              MyWindowsColor.window
                border.color:       MyWindowsColor.text
                visible:            _editCircleRadius&& _visible

                Column {
                    id:                 radiusColumn
                    anchors.margins:    _margin
                    anchors.left:       parent.left
                    anchors.top:        parent.top
                    spacing:            _margin

                    CommonLabel { text: qsTr("Radius:") }

                    CommonTextField {
                        id:                 radiusField
                        showUnits:          true
                        unitsLabel:        "m" //QGroundControl.appSettingsDistanceUnitsString
                        text:              "m" //QGroundControl.metersToAppSettingsDistanceUnits(_circleRadius).toFixed(2)
                        onEditingFinished:  setRadiusFromDialog()
                        inputMethodHints:   Qt.ImhFormattedNumbersOnly
                    }
                }

                CommonLabel {
                    anchors.right:  radiusColumn.right
                    anchors.top:    radiusColumn.top
                    text:           "X"

                    CommonMouseArea {
                        fillItem:   parent
                        onClicked:  setRadiusFromDialog()
                    }
                }
            }
        }
    }

    Component {
        id: centerDragHandleComponent

        Item {
            property var dragHandle
            property var dragArea

            function  addCenterDrag()
            {
                if (!dragHandle)
                {
                    dragHandle = centerDragHandle.createObject(mapControl)
                    dragHandle.coordinate = Qt.binding(function() { return mapPolygon.center })
                }
                mapControl.addMapItem(dragHandle)
                if(!dragArea)
                {
                    dragArea = centerDragAreaComponent.createObject(mapControl, { "itemIndicator": dragHandle, "itemCoordinate": mapPolygon.center })
                }
            }
            Component.onCompleted: {
                addCenterDrag()
            }

            Component.onDestruction: {
                dragHandle.destroy()
                dragArea.destroy()
            }
        }
    }
}

