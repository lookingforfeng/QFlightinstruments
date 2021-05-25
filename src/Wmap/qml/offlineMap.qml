import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtQuick.Layouts          1.2
import QtLocation               5.3
import QtPositioning            5.3
import "."

import MyMapEngineManager_R 1.0


CommonView {
    id:             offlineMapView
    anchors.fill:   parent

    property var    _currentSelection:  null
    property real   _margins:           MyWindowItmeSize.defaultFontPixelWidth * 0.5
    property real   _buttonSize:        MyWindowItmeSize.defaultFontPixelWidth * 12
    property real   _bigButtonSize:     MyWindowItmeSize.defaultFontPixelWidth * 16
    property bool   _showPreview:       true
    property var    _mapAdjustedColor:  _map.isSatelliteMap ? "white" : "black"
    property bool   isMapInteractive:   false
    readonly property real sliderTouchArea: WindowItmeSize.defaultFontPixelWidth *3
    readonly property real minZoomLevel:    1
    readonly property real maxZoomLevel:    20
    property real   _adjustableFontPointSize: WindowItmeSize.defaultFontPointSize
    property bool   _tooManyTiles:      MyMapEngineManager_instance.mapEngineManager.tileCount > _maxTilesForDownload
    readonly property int _maxTilesForDownload: 100000
    property var    savedCenter:        undefined
    property real   savedZoom:          3
    property string savedMapType:       ""
    property bool   _defaultSet:        offlineMapView && offlineMapView._currentSelection && offlineMapView._currentSelection.defaultSet


    Component.onCompleted: {
        MyMapEngineManager_instance.mapEngineManager.loadTileSets()
        MyMapEngineManager_instance.mapEngineManager.fetchElevation = false
        handleChanges()
        //updateMap()
        // savedCenter = _map.toCoordinate(Qt.point(_map.width / 2, _map.height / 2), false /* clipToViewPort */)
    }

    Connections {
        target: MyMapEngineManager_instance.mapEngineManager
        onTileSetsChanged: {
            setName.text = MyMapEngineManager_instance.mapEngineManager.getUniqueName()
        }
    }

    function handleChanges() {
        if(isMapInteractive) {
            var xl = 0
            var yl = 0
            var xr = _map.width.toFixed(0) - 1  // Must be within boundaries of visible map
            var yr = _map.height.toFixed(0) - 1 // Must be within boundaries of visible map
            var c0 = _map.toCoordinate(Qt.point(xl, yl), false /* clipToViewPort */)
            var c1 = _map.toCoordinate(Qt.point(xr, yr), false /* clipToViewPort */)
            MyMapEngineManager_instance.mapEngineManager.updateForCurrentView(c0.longitude, c0.latitude, c1.longitude, c1.latitude, sliderMinZoom.value, sliderMaxZoom.value, _map.activeMapType)
        }
    }

    function addNewSet() {
        isMapInteractive = true
        handleChanges()
        _map.visible = true
        _tileSetList.visible = false
        infoView.visible = false
        addNewSetView.visible = true
    }

    function showList() {
        isMapInteractive = false
        _map.visible = false
        _tileSetList.visible = true
        infoView.visible = false
        addNewSetView.visible = false
        MyMapEngineManager_instance.mapEngineManager.resetAction();
    }

    function showInfo() {
        isMapInteractive = false
        if(_currentSelection && !offlineMapView._currentSelection.deleting) {
            enterInfoView()
        } else
            showList()
    }

    function enterInfoView() {
        _map.visible = true
        isMapInteractive = false
        savedCenter = _map.toCoordinate(Qt.point(_map.width / 2, _map.height / 2), false /* clipToViewPort */)
        savedZoom = _map.zoomLevel
        savedMapType = _map.activeMapType.name
        if(!offlineMapView._currentSelection.defaultSet) {
            //mapType = offlineMapView._currentSelection.mapTypeStr
            _map.center = midPoint(offlineMapView._currentSelection.topleftLat, offlineMapView._currentSelection.bottomRightLat, offlineMapView._currentSelection.topleftLon, offlineMapView._currentSelection.bottomRightLon)
            //-- Delineate Set Region
            var x0 = offlineMapView._currentSelection.topleftLon
            var x1 = offlineMapView._currentSelection.bottomRightLon
            var y0 = offlineMapView._currentSelection.topleftLat
            var y1 = offlineMapView._currentSelection.bottomRightLat
            mapBoundary.topLeft     = QtPositioning.coordinate(y0, x0)
            mapBoundary.bottomRight = QtPositioning.coordinate(y1, x1)
            mapBoundary.visible = true
            // Some times, for whatever reason, the bounding box is correct (around ETH for instance), but the rectangle is drawn across the planet.
            // When that happens, the "_map.fitViewportToMapItems()" below makes the map to zoom to the entire earth.
            //console.log("Map boundary: " + mapBoundary.topLeft + " " + mapBoundary.bottomRight)
            _map.fitViewportToMapItems()
        }
        _tileSetList.visible = false
        addNewSetView.visible = false
        infoView.visible = true
    }

    function midPoint(lat1, lat2, lon1, lon2) {
        var dLon = toRadian(lon2 - lon1);
        lat1 = toRadian(lat1);
        lat2 = toRadian(lat2);
        lon1 = toRadian(lon1);
        var Bx = Math.cos(lat2) * Math.cos(dLon);
        var By = Math.cos(lat2) * Math.sin(dLon);
        var lat3 = Math.atan2(Math.sin(lat1) + Math.sin(lat2), Math.sqrt((Math.cos(lat1) + Bx) * (Math.cos(lat1) + Bx) + By * By));
        var lon3 = lon1 + Math.atan2(By, Math.cos(lat1) + Bx);
        return QtPositioning.coordinate(toDegree(lat3), toDegree(lon3))
    }

    function toRadian(deg) {
        return deg * Math.PI / 180
    }

    function toDegree(rad) {
        return rad * 180 / Math.PI
    }

    function leaveInfoView() {
        mapBoundary.visible = false
        _map.center = savedCenter
        _map.zoomLevel = savedZoom
       // mapType = savedMapType
    }


    // 总视图--
    FactPanel {
        id:                 panel
        anchors.fill:       parent

        //大地图--
        MyMap{
            id:_map
            z:1
            anchors.fill: parent
            visible: false
            mapName: "offlinemap"
            property bool isSatelliteMap:true

            onCenterChanged:    handleChanges()
            onZoomLevelChanged: handleChanges()
            onWidthChanged:     handleChanges()
            onHeightChanged:    handleChanges()

            //在信息显示窗口中显示区域
            MapRectangle {
                id:             mapBoundary
                border.width:   2
                border.color:   "red"
                color:          Qt.rgba(1,0,0,0.05)
                smooth:         true
                antialiasing:   true
            }

            //比例尺
            MapScale {
                anchors.leftMargin:    MyWindowItmeSize.defaultFontPixelWidth / 2
                anchors.bottomMargin:   anchors.leftMargin
                anchors.left:           parent.left
                anchors.bottom:         parent.bottom
                mapControl:             _map
            }

            //
            Rectangle {
                id:                 infoView
                anchors.margins:    WindowItmeSize.defaultFontPixelHeight
                anchors.right:      parent.right
                anchors.verticalCenter: parent.verticalCenter
                width:              tileInfoColumn.width  + (WindowItmeSize.defaultFontPixelWidth  * 2)
                height:             tileInfoColumn.height + (WindowItmeSize.defaultFontPixelHeight * 2)
                color:              Qt.rgba(MyWindowsColor.window.r, MyWindowsColor.window.g, MyWindowsColor.window.b, 0.85)
                radius:             WindowItmeSize.defaultFontPixelWidth * 0.5
                visible:            false

                property bool       _extraButton: {
                    if(!offlineMapView._currentSelection)
                        return false;
                    var curSel = offlineMapView._currentSelection;
                    return !_defaultSet && ((!curSel.complete && !curSel.downloading) || (!curSel.complete && curSel.downloading));
                }

                property real       _labelWidth:    WindowItmeSize.defaultFontPixelWidth * 10
                property real       _valueWidth:    WindowItmeSize.defaultFontPixelWidth * 14
                Column {
                    id:                 tileInfoColumn
                    anchors.margins:    WindowItmeSize.defaultFontPixelHeight * 0.5
                    spacing:            WindowItmeSize.defaultFontPixelHeight * 0.5
                    anchors.centerIn:   parent
                    CommonLabel {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        wrapMode:       Text.WordWrap
                        text:           offlineMapView._currentSelection ? offlineMapView._currentSelection.name : ""
                        font.pointSize: false ? WindowItmeSize.defaultFontPointSize : WindowItmeSize.mediumFontPointSize
                        horizontalAlignment: Text.AlignHCenter
                        visible:        _defaultSet
                    }
                    CommonTextField {
                        id:             editSetName
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        visible:        !_defaultSet
                        text:           offlineMapView._currentSelection ? offlineMapView._currentSelection.name : ""
                    }
                    CommonLabel {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        wrapMode:       Text.WordWrap
                        text: {
                            if(offlineMapView._currentSelection) {
                                if(offlineMapView._currentSelection.defaultSet)
                                    return qsTr("System Wide Tile Cache");
                                else
                                    return "(" + offlineMapView._currentSelection.mapTypeStr + ")"
                            } else
                                return "";
                        }
                        horizontalAlignment: Text.AlignHCenter
                    }
                    //-- Tile Sets
                    Row {
                        spacing:    WindowItmeSize.defaultFontPixelWidth
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:    !_defaultSet //&& mapType !== "Airmap Elevation Data"
                        CommonLabel {  text: qsTr("Zoom Levels:"); width: infoView._labelWidth; }
                        CommonLabel {  text: offlineMapView._currentSelection ? (offlineMapView._currentSelection.minZoom + " - " + offlineMapView._currentSelection.maxZoom) : ""; horizontalAlignment: Text.AlignRight; width: infoView._valueWidth; }
                    }
                    Row {
                        spacing:    WindowItmeSize.defaultFontPixelWidth
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:    !_defaultSet
                        CommonLabel {  text: qsTr("Total:"); width: infoView._labelWidth; }
                        CommonLabel {  text: (offlineMapView._currentSelection ? offlineMapView._currentSelection.totalTileCountStr : "") + " (" + (offlineMapView._currentSelection ? offlineMapView._currentSelection.totalTilesSizeStr : "") + ")"; horizontalAlignment: Text.AlignRight; width: infoView._valueWidth; }
                    }
                    Row {
                        spacing:    WindowItmeSize.defaultFontPixelWidth
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:    offlineMapView && offlineMapView._currentSelection && !_defaultSet && offlineMapView._currentSelection.uniqueTileCount > 0
                        CommonLabel {  text: qsTr("Unique:"); width: infoView._labelWidth; }
                        CommonLabel {  text: (offlineMapView._currentSelection ? offlineMapView._currentSelection.uniqueTileCountStr : "") + " (" + (offlineMapView._currentSelection ? offlineMapView._currentSelection.uniqueTileSizeStr : "") + ")"; horizontalAlignment: Text.AlignRight; width: infoView._valueWidth; }
                    }

                    Row {
                        spacing:    WindowItmeSize.defaultFontPixelWidth
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:    offlineMapView && offlineMapView._currentSelection && !_defaultSet && !offlineMapView._currentSelection.complete
                        CommonLabel {  text: qsTr("Downloaded:"); width: infoView._labelWidth; }
                        CommonLabel {  text: (offlineMapView._currentSelection ? offlineMapView._currentSelection.savedTileCountStr : "") + " (" + (offlineMapView._currentSelection ? offlineMapView._currentSelection.savedTileSizeStr : "") + ")"; horizontalAlignment: Text.AlignRight; width: infoView._valueWidth; }
                    }
                    Row {
                        spacing:    WindowItmeSize.defaultFontPixelWidth
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:    offlineMapView && offlineMapView._currentSelection && !_defaultSet && !offlineMapView._currentSelection.complete && offlineMapView._currentSelection.errorCount > 0
                        CommonLabel {  text: qsTr("Error Count:"); width: infoView._labelWidth; }
                        CommonLabel {  text: offlineMapView._currentSelection ? offlineMapView._currentSelection.errorCountStr : ""; horizontalAlignment: Text.AlignRight; width: infoView._valueWidth; }
                    }
                    //-- Default Tile Set
                    Row {
                        spacing:    WindowItmeSize.defaultFontPixelWidth
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:    _defaultSet
                        CommonLabel { text: qsTr("Size:"); width: infoView._labelWidth; }
                        CommonLabel { text: offlineMapView._currentSelection ? offlineMapView._currentSelection.savedTileSizeStr  : ""; horizontalAlignment: Text.AlignRight; width: infoView._valueWidth; }
                    }
                    Row {
                        spacing:    WindowItmeSize.defaultFontPixelWidth
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:    _defaultSet
                        CommonLabel { text: qsTr("Tile Count:"); width: infoView._labelWidth; }
                        CommonLabel { text: offlineMapView._currentSelection ? offlineMapView._currentSelection.savedTileCountStr : ""; horizontalAlignment: Text.AlignRight; width: infoView._valueWidth; }
                    }
                    Row {
                        spacing:    WindowItmeSize.defaultFontPixelWidth
                        anchors.horizontalCenter: parent.horizontalCenter
                        CommonButton {
                            text:       qsTr("Resume Download")
                            visible:    offlineMapView._currentSelection && offlineMapView._currentSelection && !_defaultSet && (!offlineMapView._currentSelection.complete && !offlineMapView._currentSelection.downloading)
                            width:      WindowItmeSize.defaultFontPixelWidth * 16
                            onClicked: {
                                if(offlineMapView._currentSelection)
                                    offlineMapView._currentSelection.resumeDownloadTask()
                            }
                        }
                        CommonButton {
                            text:       qsTr("Cancel Download")
                            visible:    offlineMapView._currentSelection && offlineMapView._currentSelection && !_defaultSet && (!offlineMapView._currentSelection.complete && offlineMapView._currentSelection.downloading)
                            width:      WindowItmeSize.defaultFontPixelWidth * 16
                            onClicked: {
                                if(offlineMapView._currentSelection)
                                    offlineMapView._currentSelection.cancelDownloadTask()
                            }
                        }
                        CommonButton {
                            text:       qsTr("Delete")
                            width:      WindowItmeSize.defaultFontPixelWidth * (infoView._extraButton ? 6 : 10)
                            onClicked:
                            {
                                MyMapEngineManager_instance.mapEngineManager.deleteTileSet(offlineMapView._currentSelection)
                                leaveInfoView()
                                showList()
                            }
                        }
                        CommonButton {
                            text:       qsTr("Ok")
                            width:      WindowItmeSize.defaultFontPixelWidth * (infoView._extraButton ? 6 : 10)
                            visible:    !_defaultSet
                            enabled:    editSetName.text !== ""
                            onClicked: {
                                if(editSetName.text !== _currentSelection.name) {
                                    QGroundControl.mapEngineManager.renameTileSet(_currentSelection, editSetName.text)
                                }
                                leaveInfoView()
                                showList()
                            }
                        }
                        CommonButton {
                            text:       _defaultSet ? qsTr("Close") : qsTr("Cancel")
                            width:      WindowItmeSize.defaultFontPixelWidth * (infoView._extraButton ? 6 : 10)
                            onClicked: {
                                leaveInfoView()
                                showList()
                            }
                        }
                    }
                }

            }

            //小地图们
            Item {
                id:             addNewSetView
                anchors.fill:   parent
                visible:false

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin:     _margins
                    anchors.left:           parent.left
                    spacing:                _margins

                    CommonButton {
                        text:       "显示预览"
                        visible:    !_showPreview
                        onClicked:  _showPreview = !_showPreview
                    }
                    //小地图1
                    Map {
                        id:minZoomPreview
                        z:1
                        width:              addNewSetView.width / 4
                        height:             addNewSetView.height / 4
                        center:             _map.center
                        activeMapType:      _map.activeMapType
                        zoomLevel:         sliderMinZoom.value
                        visible:            _showPreview
                        plugin:  Plugin { name: "QGroundControl" }

                        Rectangle {
                            anchors.fill:   parent
                            border.color:   _mapAdjustedColor
                            color:          "transparent"

                            CommonLabel {
                                anchors.centerIn:   parent
                                color:      _map.isSatelliteMap?"white":"balck"
                                style:      Text.Outline
                                styleColor: _map.isSatelliteMap?"balck":"white"
                                text:               qsTr("最小缩放: %1").arg(sliderMinZoom.value)
                            }
                            MouseArea {
                                anchors.fill:   parent
                                onClicked:      _showPreview = false
                            }
                        }
                    }//小地图1

                    //小地图2
                    Map {
                        id:maxZoomPreview
                        z:1
                        width:              addNewSetView.width / 4
                        height:             addNewSetView.height / 4
                        center:             _map.center
                        activeMapType:      _map.activeMapType
                        zoomLevel:         sliderMaxZoom.value
                        visible:            _showPreview
                        plugin:  Plugin { name: "QGroundControl" }

                        Rectangle {
                            anchors.fill:   parent
                            border.color:   _mapAdjustedColor
                            color:          "transparent"

                            CommonLabel {
                                anchors.centerIn:   parent
                                color:      _map.isSatelliteMap?"white":"balck"
                                style:      Text.Outline
                                styleColor: _map.isSatelliteMap?"balck":"white"
                                text:               qsTr("最大缩放: %1").arg(sliderMaxZoom.value)
                            }
                            MouseArea {
                                anchors.fill:   parent
                                onClicked:      _showPreview = false
                            }
                        }
                    }//小地图2
                }
            }
            //小地图们


        }//大地图


        //新增窗口
        //-- Add new set dialog
        Rectangle {

            anchors.margins:    WindowItmeSize.defaultFontPixelWidth
            anchors.verticalCenter: parent.verticalCenter
            anchors.right:      parent.right
            visible:            addNewSetView.visible
            width:              WindowItmeSize.defaultFontPixelWidth * 28
            height:             Math.min(parent.height - (anchors.margins * 2), addNewSetFlickable.y + addNewSetColumn.height + addNewSetLabel.anchors.margins)
            color:              Qt.rgba(MyWindowsColor.window.r, MyWindowsColor.window.g, MyWindowsColor.window.b, 0.85)
            radius:             WindowItmeSize.defaultFontPixelWidth * 0.5
            z:5

            //-- Eat mouse events
            DeadMouseArea {
                anchors.fill: parent
            }

            CommonLabel {
                id:                 addNewSetLabel
                anchors.margins:    WindowItmeSize.defaultFontPixelHeight / 2
                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.right:      parent.right
                wrapMode:           Text.WordWrap
                text:               qsTr("下载离线地图")
                font.pointSize:    WindowItmeSize.mediumFontPointSize
                horizontalAlignment: Text.AlignHCenter
            }

            Flickable {
                id:                     addNewSetFlickable
                anchors.leftMargin:     WindowItmeSize.defaultFontPixelWidth
                anchors.rightMargin:    anchors.leftMargin
                anchors.topMargin:      WindowItmeSize.defaultFontPixelWidth / 3
                anchors.bottomMargin:   anchors.topMargin
                anchors.top:            addNewSetLabel.bottom
                anchors.left:           parent.left
                anchors.right:          parent.right
                anchors.bottom:         parent.bottom
                clip:                   true
                contentHeight:          addNewSetColumn.height

                Column {
                    id:                 addNewSetColumn
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            WindowItmeSize.defaultFontPixelHeight * (WindowItmeSize.isTinyScreen ? 0.25 : 0.5)

                    Column {
                        spacing:            WindowItmeSize.isTinyScreen ? 0 : WindowItmeSize.defaultFontPixelHeight * 0.25
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        CommonLabel { text: qsTr("Name:") }
                        CommonTextField {
                            id:             setName
                            anchors.left:   parent.left
                            anchors.right:  parent.right
                        }
                    }

                    Column {
                        spacing:            WindowItmeSize.isTinyScreen ? 0 : WindowItmeSize.defaultFontPixelHeight * 0.25
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        CommonLabel {
                            text:       qsTr("Map type:")
                            visible:    true
                        }
                        CommonLabel {
                            id:             mapCombo
                            text:       _map.activeMapType.name
                            visible:    true
                        }


                    }

                    Rectangle {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        height:         zoomColumn.height + WindowItmeSize.defaultFontPixelHeight * 0.5
                        color:          MyWindowsColor.window
                        border.color:   MyWindowsColor.text
                        radius:         WindowItmeSize.defaultFontPixelWidth * 0.5

                        Column {
                            id:                 zoomColumn
                            spacing:            WindowItmeSize.isTinyScreen ? 0 : WindowItmeSize.defaultFontPixelHeight * 0.5
                            anchors.margins:    WindowItmeSize.defaultFontPixelHeight * 0.25
                            anchors.top:        parent.top
                            anchors.left:       parent.left
                            anchors.right:      parent.right

                            CommonLabel {
                                text:           qsTr("Min/Max Zoom Levels")
                                font.pointSize: _adjustableFontPointSize
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Slider {
                                id:                         sliderMinZoom
                                anchors.left:               parent.left
                                anchors.right:              parent.right
                                height:                     sliderTouchArea * 1.25
                                minimumValue:               minZoomLevel
                                maximumValue:               maxZoomLevel
                                stepSize:                   1
                                updateValueWhileDragging:   true
                                property real _savedZoom
                                Component.onCompleted:      Math.max(sliderMinZoom.value = _map.zoomLevel - 4, 2)
                                onValueChanged: {
                                    if(sliderMinZoom.value > sliderMaxZoom.value) {
                                        sliderMaxZoom.value = sliderMinZoom.value
                                    }
                                    handleChanges()
                                }
                                style: SliderStyle {
                                    groove: Rectangle {
                                        implicitWidth:  sliderMinZoom.width
                                        implicitHeight: 4
                                        color:         MyWindowsColor.colorBlue
                                        radius:         4
                                    }
                                    handle: Rectangle {
                                        anchors.centerIn: parent
                                        color:          MyWindowsColor.button
                                        border.color:   MyWindowsColor.buttonText
                                        border.width:   1
                                        implicitWidth:  sliderTouchArea
                                        implicitHeight: sliderTouchArea
                                        radius:         sliderTouchArea * 0.5
                                        Label {
                                            text:               sliderMinZoom.value
                                            anchors.centerIn:   parent
                                            font.family:        WindowItmeSize.normalFontFamily
                                            font.pointSize:     WindowItmeSize.smallFontPointSize
                                            color:              MyWindowsColor.buttonText
                                        }
                                    }
                                }
                            } // Slider - min zoom

                            Slider {
                                id:                         sliderMaxZoom
                                anchors.left:               parent.left
                                anchors.right:              parent.right
                                height:                     sliderTouchArea * 1.25
                                minimumValue:               minZoomLevel
                                maximumValue:               maxZoomLevel
                                stepSize:                   1
                                updateValueWhileDragging:   true
                                property real _savedZoom
                                Component.onCompleted:      Math.min(sliderMaxZoom.value = _map.zoomLevel + 2, 20)
                                onValueChanged: {
                                    if(sliderMaxZoom.value < sliderMinZoom.value) {
                                        sliderMinZoom.value = sliderMaxZoom.value
                                    }
                                    handleChanges()
                                }
                                style: SliderStyle {
                                    groove: Rectangle {
                                        implicitWidth:  sliderMaxZoom.width
                                        implicitHeight: 4
                                        color:          MyWindowsColor.colorBlue
                                        radius:         4
                                    }
                                    handle: Rectangle {
                                        anchors.centerIn: parent
                                        color:          MyWindowsColor.button
                                        border.color:   MyWindowsColor.buttonText
                                        border.width:   1
                                        implicitWidth:  sliderTouchArea
                                        implicitHeight: sliderTouchArea
                                        radius:         sliderTouchArea * 0.5
                                        Label {
                                            text:               sliderMaxZoom.value
                                            anchors.centerIn:   parent
                                            font.family:        WindowItmeSize.normalFontFamily
                                            font.pointSize:     WindowItmeSize.smallFontPointSize
                                            color:              MyWindowsColor.buttonText
                                        }
                                    }
                                }
                            } // Slider - max zoom

                            GridLayout {
                                columns:    2
                                rowSpacing: WindowItmeSize.isTinyScreen ? 0 : WindowItmeSize.defaultFontPixelHeight * 0.5
                                CommonLabel {
                                    text:           qsTr("Tile Count:")
                                    font.pointSize: _adjustableFontPointSize
                                }
                                CommonLabel {
                                    text:            MyMapEngineManager_instance.mapEngineManager.tileCountStr
                                    font.pointSize: _adjustableFontPointSize
                                }

                                CommonLabel {
                                    text:           qsTr("Est Size:")
                                    font.pointSize: _adjustableFontPointSize
                                }
                                CommonLabel {
                                    text:           MyMapEngineManager_instance.mapEngineManager.tileSizeStr
                                    font.pointSize: _adjustableFontPointSize
                                }
                            }
                        } // Column - Zoom info
                    } // Rectangle - Zoom info

                    Label {
                        text:       qsTr("Too many tiles")
                        visible:    _tooManyTiles
                        color:      MyWindowsColor.warningText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Row {
                        id: addButtonRow
                        spacing: WindowItmeSize.defaultFontPixelWidth
                        anchors.horizontalCenter: parent.horizontalCenter
                        CommonButton {
                            text:       qsTr("Download")
                            width:      (addNewSetColumn.width * 0.5) - (addButtonRow.spacing * 0.5)
                            enabled:    setName.text.length > 0
                            onClicked: {
                                if(MyMapEngineManager_instance.mapEngineManager.findName(setName.text)) {
                                    duplicateName.visible = true
                                } else {
                                    MyMapEngineManager_instance.mapEngineManager.startDownload(setName.text, _map.activeMapType.name);
                                    showList()
                                }
                            }
                        }
                        CommonButton {
                            text:       qsTr("Cancel")
                            width:      (addNewSetColumn.width * 0.5) - (addButtonRow.spacing * 0.5)
                            onClicked: {
                                showList()
                            }
                        }
                    }

                } // Column
            } // QGCFlickable
        } // Rectangle - Add new set dialog

        //缓存列表视图
        Flickable{
            id:                 _tileSetList
            anchors.topMargin:  MyWindowItmeSize.defaultFontPointSize
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            anchors.left:       parent.left
            anchors.right:        parent.right
            contentHeight:      buttonColumn.height + _verticalMargin
            flickableDirection: Flickable.VerticalFlick
            clip:               true
            z:5

            Column {
                id:         _cacheList
                width:      (MyWindowItmeSize.defaultFontPixelWidth  * 70).toFixed(0)
                spacing:    MyWindowItmeSize.defaultFontPixelHeight * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                ExclusiveGroup { id: selectionGroup }
                OfflineMapButton {
                    id:             firstButton
                    text:           qsTr("Add New Set")
                    width:          _cacheList.width
                    height:         MyWindowItmeSize.defaultFontPixelHeight * 2
                    currentSet:     _currentSelection
                    exclusiveGroup: selectionGroup
                    onClicked: {
                        offlineMapView._currentSelection = null
                        addNewSet()
                    }
                }

                Repeater {
                    model: MyMapEngineManager_instance.mapEngineManager.tileSets
                    delegate: OfflineMapButton {
                        text:           object.name
                        size:           object.downloadStatus
                        tiles:          object.totalTileCount
                        complete:       object.complete
                        width:          firstButton.width
                        height:         MyWindowItmeSize.defaultFontPixelHeight *  2
                        exclusiveGroup: selectionGroup
                        currentSet:     _currentSelection
                        tileSet:        object

                        onClicked: {
                            offlineMapView._currentSelection = object
                            showInfo()
                        }
                    }
                }
//                CommonLabel{
//                    text:"航空工业成飞/技术中心"
//                }
            }

        }
        //缓存列表视图

    } // 总视图










}
