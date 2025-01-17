﻿import QtQuick 2.0
import QtLocation 5.9
import"."
import QtQuick.Controls 1.4

import QGCMapPalette_R 1.0
import QtQuick.Layouts  1.2
import QtPositioning    5.3

import QGCMapPolygon_R 1.0


CommonView{
    id:         _qgcView
    viewPanel:  panel
    z:          10
    width:MyWindowItmeSize.availableWidth
    height: MyWindowItmeSize .availableHeight+MyWindowItmeSize.toolbarheight

    readonly property int   _decimalPlaces:             8
    readonly property real  _horizontalMargin:          MyWindowItmeSize.defaultFontPixelWidth  / 2
    readonly property real  _margin:                    MyWindowItmeSize.defaultFontPixelHeight * 0.5
    readonly property real  _rightPanelWidth:           Math.min(MyWindowItmeSize.availableWidth / 3, MyWindowItmeSize.defaultFontPixelWidth * 30)

    readonly property real  _toolButtonTopMargin:       parent.height - MyWindowItmeSize .availableHeight + (MyWindowItmeSize.defaultFontPixelHeight / 2)
    property bool   _addWaypointOnClick:        false
    property var _visualItem
    property real _leftToolWidth:   toolStrip.x + toolStrip.width
    property real   _toolbarHeight:             _qgcView.height -MyWindowItmeSize.availableHeight
    property rect centerViewport: Qt.rect(_leftToolWidth, _toolbarHeight, myeditorMap.width - _leftToolWidth - _rightPanelWidth, myeditorMap.height  - _toolbarHeight)
    readonly property int       _layerMission:              1
    readonly property int       _layerGeoFence:             2
    readonly property int       _layerRallyPoints:          3
    property int    _editingLayer:              _layerMission

    property int map_toolbox_state : 0

    /*
    标志当前工具状态
    0--普通
    1--测距前
    2--测距第一点已获取
    3--测距第二点已获取
    6--测角前
    7--测角角点
    8--测角第第一方向
    9--测角第第二方向
    10--获取航点
    */

    function  hideall_measure()
    {
        distace_line.visible=false;
        distance_lable.visible=false;
        distance_point1.visible=false;
        distance_point2.visible=false;

        angle_line1.visible=false;
        angle_line2.visible=false;
        angle_point_center.visible=false;
        angle_lable.visible=false;
        map_mousearea.hoverEnabled=false;
        areaPolygon._visible=false
    }
    //角度计算
    function get_diff()
    {
        var  azimuth1=angle_point1.coordinate.azimuthTo(angle_point_center.coordinate)
        var  azimuth2=angle_point2.coordinate.azimuthTo(angle_point_center.coordinate)
        var diff
        if((azimuth2-azimuth1)>180)
            diff=360-(azimuth2-azimuth1)
        else if((azimuth2-azimuth1)<0&&(azimuth2-azimuth1)>-180)
            diff=-(azimuth2-azimuth1)
        else if((azimuth2-azimuth1)<=-180)
            diff=360+(azimuth2-azimuth1)
        else
            diff=azimuth2-azimuth1
        return diff
    }

    //----------------地图操作函数----------------begin
    signal map_error(string error_msg)
    signal measure_distance(double m_distance)
    signal measure_angle(double m_angle)
    signal cur_Point(double lat,double lng)
    signal clicked_Point(double lat,double lng)
    signal marker_clicked(double lat ,double lng,string name)
    signal marker_position_changed(double lat ,double lng,string name)
    signal mapCenterChanged(double lat,double lng)

    property double map_zoom_level: myeditorMap.zoomLevel
    property double mapcenter_lat: myeditorMap.center.latitude
    property double mapcenter_lng: myeditorMap.center.longitude

	//设置地图的整体偏转
	function setBearing(bearing)
	{
		myeditorMap.bearing=bearing
	}

    //图片图标
    function addMarker(name,image_file,lat,lng,color)
    {
        if (maker_componet.status == Component.Ready)
		{
			var makerobj=  maker_componet.createObject(myeditorMap, { "coordinate": QtPositioning.coordinate(lat,lng)});
		}
        makerobj.name=name;
        makerobj.sourceItem.children[0].source="file:///"+image_file
        makerobj.sourceItem.children[0].color=color;
        myeditorMap.addMapItem(makerobj)
        return makerobj
    }

    //带编号的图标
    function addMarker1(name,index,lat,lng,color)
    {
        if (index_point_componet.status == Component.Ready)
            var makerobj=  index_point_componet.createObject(myeditorMap, { "coordinate": QtPositioning.coordinate(lat,lng)});
        makerobj.name=name;
        makerobj.labelindex=index
        makerobj.default_color=color
        myeditorMap.addMapItem(makerobj)
        return makerobj
    }

    //文字
    function addTextMarker(name,text,lat,lng,color)
    {
        var m_coord=QtPositioning.coordinate(lat,lng)
        if (lable_maker_componet.status == Component.Ready)
            var makerobj=  lable_maker_componet.createObject(myeditorMap, { "coordinate":m_coord});
        makerobj.name=name;
        makerobj.color=color
        makerobj.text=text
        myeditorMap.addMapItem(makerobj)
        return makerobj
    }

    //矩形
    function addRectangle(name,lat1,lng1,lat2,lng2,borer_width,border_color,fill_color,fill_opacity)
    {
        if (map_rec_componet.status == Component.Ready)
            var makerobj=  map_rec_componet.createObject(myeditorMap);
        makerobj.name=name;
        makerobj.border.width=borer_width
        makerobj.border.color=border_color
        makerobj.color=fill_color
        makerobj.opacity=fill_opacity
        makerobj.bottomRight=QtPositioning.coordinate(lat2,lng2)
        makerobj.topLeft=QtPositioning.coordinate(lat1,lng1)
        myeditorMap.addMapItem(makerobj)
        return makerobj
    }

    //圆形
    function addCircle(name,lat,lng,radius,borer_width,border_color,fill_color,fill_opacity)
    {
        if (map_circle_componet.status == Component.Ready)
            var makerobj=  map_circle_componet.createObject(myeditorMap);
        makerobj.name=name;
        makerobj.border.width=borer_width
        makerobj.border.color=border_color
        makerobj.color=fill_color
        makerobj.opacity=fill_opacity
        makerobj.center=QtPositioning.coordinate(lat,lng)
        makerobj.radius=radius
        myeditorMap.addMapItem(makerobj)
        return makerobj
    }

    //航线
    function addLine(name,line_width,line_color)
    {		
        if (map_line_componet.status == Component.Ready)
            var makerobj=  map_line_componet.createObject(myeditorMap);
		
        makerobj.name=name;
        makerobj.line.width=line_width
        makerobj.line.color=line_color
        myeditorMap.addMapItem(makerobj)
        return makerobj
    }

	//直接通过线对象增加航点
	function addLine_point(obj,lat,lng)
    {
		obj.addCoordinate(QtPositioning.coordinate(lat,lng))
    }

    //航线删除点
    function deleteLine_point(obj,lat,lng)
    {
		obj.removeCoordinate(QtPositioning.coordinate(lat,lng))
    }


    //多边形
    function addRegion(name,border_width,border_color,fill_color,fill_opacity)
    {
        if (map_region_componet.status == Component.Ready)
            var makerobj=  map_region_componet.createObject(myeditorMap);
        makerobj.name=name;
        makerobj.border.width=border_width
        makerobj.border.color=border_color
        makerobj.opacity=fill_opacity
        makerobj.color=fill_color
        myeditorMap.addMapItem(makerobj)
        return makerobj
    }

    //向多边行中增加控制点，航线增加点
    function addRegion_point(obj,lat,lng)
    {
		obj.addCoordinate(QtPositioning.coordinate(lat,lng))
    }

    //旋转图标
    function rotateMarker(obj,angle)
    {
		obj.rotation=angle
    }

    //删除图标
    function deleteMarker(obj)
    {
		myeditorMap.removeMapItem(obj)
    }

    //移动图标
    function moveMarker(obj,lat,lng)
    {
		obj.coordinate=QtPositioning.coordinate(lat,lng)
    }

    //设置地图中心
    function setMapCenter(lat, lng)
    {
        myeditorMap.center= QtPositioning.coordinate(lat,lng)
    }

    function getMapCenter()
    {
        mapCenter(myeditorMap.center.latitude,myeditorMap.center.longitude)
    }

    function  getZoomLevel()
    {
        zoomLevel(myeditorMap.zoomLevel)
    }

    function  setZoomLevel( zoom_level )
    {
        if(zoom_level<2||zoom_level>20)
            map_error("超出缩放等级范围！")
        else
            myeditorMap.zoomLevel=zoom_level
    }

    function  setMapType( type_num )
    {
        if(type_num===0||type_num===1||type_num===2)
        {
            myeditorMap.updateActiveMapType(type_num)
        }
        else
        {
            map_error("没有这种类型！请确认地图类型号：1--街道地图，0--卫星地图，2--混合地图")
        }
    }

    function setMarkerHighlight(obj ,highlight,color)
    {
	    obj.highlight_color=color
        obj.highlight=highlight
    }

    function showPolygon()
    {
        areaPolygon.resetPolygon()
        areaPolygon._visible=true
    }

    function hidePolygon()
    {
        areaPolygon._visible=false
    }

    //操作相关组件
    MapPolygonVisuals {
        id:                 areaPolygon
        mapControl:         myeditorMap
        mapPolygon:         QGCMapPolygon_instance
        interactive:        true
        borderWidth:        1
        borderColor:        "yellow"
        interiorColor:     '#00eaff'
        interiorOpacity:    0.5
        _visible: false
    }

    Component{
        id:maker_componet
        MapQuickItem {
            id: airplan
            property string name:"default_name"
            property string marker_color
            z:100
            anchorPoint.x: image.width/2
            anchorPoint.y: image.height/2
            coordinate: QtPositioning.coordinate(40,100)
            onCoordinateChanged: {
                marker_position_changed(coordinate.latitude,coordinate.longitude,name)
            }

            sourceItem:Grid{
                ColoredImage  {
                    id: image
                    source: "/image/MapAddMission.svg"
                    width: 50
                    height: width
                    color: airplan.marker_color
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked:
                {
                    marker_clicked(coordinate.latitude,coordinate.longitude,name)
                }
                //drag.target: parent
            }
        }
    }

    //文字图标组件
    Component{
        id:lable_maker_componet
        MapQuickItem {
            id: lable_maker
            z:10
            property string name:"default_name"
            property alias text:lable_maker_lable.text
            property alias color: lable_maker_lable.color
            anchorPoint.x: lable_maker_lable.width/2
            anchorPoint.y: lable_maker_lable.height/2
            coordinate: QtPositioning.coordinate(40,100)
            sourceItem:Grid{
                CommonLabel  {
                    id: lable_maker_lable
                    color: "red"
                }
            }
        }
    }

    //带编号航点组件
    Component {
        id: index_point_componet
        MapQuickItem {
            id:             index_point_item
            anchorPoint.x:  sourceItem.width  / 2
            anchorPoint.y:  sourceItem.height / 2
            z:              highlight?20:15
            property int labelindex:0
            property string name:"default_name"
            property bool highlight:false
            property color highlight_color:"red"
            property color default_color:"yellow"
            property color color:highlight?highlight_color:default_color
            //图标闪烁
            /*	Timer {
                id:blink_timer
                interval: 500
                running: highlight
                repeat: true
                onTriggered:
                {
                    if(color===highlight_color)
                    {
                        color=default_color;
                    }
                    else
                    {
                        color=highlight_color;
                    }
                }
            }*/

			//转发点击事件
            MouseArea {
                id:mouse_area                
                anchors.fill: parent
                cursorShape:highlight?Qt.PointingHandCursor:Qt.ArrowCursor
                property double record_lng:0
                property double record_lat:0
				onClicked:
                {
                    marker_clicked(record_lat,record_lng,name)
                }
				//转发拖动事件
				MouseArea {				    
					id:mouse_area_child
					enabled:highlight
					drag.target: index_point_item
					drag.threshold:1
					anchors.fill: parent
					onReleased:
					{
						marker_position_changed(mouse_area.record_lat,mouse_area.record_lng,index_point_item.name)
					}
				}
            }
            onCoordinateChanged: {
                mouse_area.record_lng=coordinate.longitude
                mouse_area.record_lat=coordinate.latitude
            }

            sourceItem:
                Grid{
                Rectangle{
                    height: MyWindowItmeSize.defaultFontPointSize*2
                    width:  MyWindowItmeSize.defaultFontPointSize*2
                    radius: height/2
                    color: MyWindowsColor.buttonHighlight
                    border.width: 2.5
                    border.color: index_point_item.color
                    Label{
                        id:indexmaker_lable
                        x:0
                        y:0
                        text:index_point_item.labelindex
                        font.pointSize: MyWindowItmeSize.defaultFontPointSize*0.9
                        color: index_point_item.color
                        anchors.centerIn: parent
                        font.bold: true
                    }
                }
            }
        }
    }

    //航线组件
    Component{
        id:map_line_componet
        MapPolyline {
            property string name: "default_name"
            id:map_line
            line.width: 3
            line.color: '#00eaff'
            z:10
        }
    }

    //多边形组件
    Component{
        id:map_region_componet
        MapPolygon {
            property string name: "default_name"
            id:map_region
            border.width: 3
            border.color: '#00eaff'
            z:10
        }
    }

    //矩形组件
    Component{
        id:map_rec_componet
        MapRectangle {
            property string name: "default_name"
            id:map_rec
            border.width: 3
            border.color: '#00eaff'
            opacity:0.5
            color:"green"
            z:5
        }
    }

    //圆形组件
    Component{
        id:map_circle_componet
        MapCircle {
            property string name: "default_name"
            id:map_circle
            border.width: 3
            border.color: '#00eaff'
            opacity:0.5
            color:"green"
            z:5
        }
    }


    //---------------地图操作函数------------------end


    QGCMapPalette_instance { id: mapPal; lightColors: true }

    FactPanel {
        id:             panel
        anchors.fill:   parent

        //地图
        MyMap{
            id:myeditorMap
            z:1
            anchors.fill: parent

            readonly property real animationDuration: 400

            Behavior on zoomLevel {
                NumberAnimation {
                    duration:       myeditorMap.animationDuration
                    easing.type:    Easing.InOutQuad
                }
            }

            onCenterChanged: {
                mapCenterChanged(myeditorMap.center.latitude,myeditorMap.center.longitude)
            }
            //不加这个会导致有时候获取不到中心值
            onMapReadyChanged:
            {
                mapCenterChanged(myeditorMap.center.latitude,myeditorMap.center.longitude)
            }

            //距离测量相关组件--------begin
            MapQuickItem {
                id: distance_point1
                anchorPoint.x: image1.width/2
                anchorPoint.y: image1.height
                coordinate: QtPositioning.coordinate(0,0)
                sourceItem:ColoredImage  {
                    id: image1
                    source: "/image/position.svg"
                    width: 30
                    height: width
                    color: "#fcff00"
                }
                visible: false
            }
            MapQuickItem {
                id: distance_point2
                anchorPoint.x: image2.width/2
                anchorPoint.y: image2.height
                coordinate:QtPositioning.coordinate(0,0)
                sourceItem:ColoredImage  {
                    id: image2
                    source: "/image/position.svg"
                    width: 30
                    height: width
                    color: "#fcff00"
                }
                visible: false
            }
            MapQuickItem {
                id: distance_lable
                anchorPoint.x: distacne_comlable.width/2
                anchorPoint.y: distacne_comlable.height/2
                coordinate:myeditorMap.get_mid()
                z:20
                sourceItem:CommonLabel  {
                    id: distacne_comlable
                    text:((distance_point1.coordinate.distanceTo(distance_point2.coordinate))/1000).toFixed(2)+"km"
                    color: "#fcff00"
                    font.pointSize: 15
                }
                visible: false
            }

            function get_mid()
            {
                var distace =distance_point1.coordinate.distanceTo(distance_point2.coordinate)
                var  azimuth=distance_point1.coordinate.azimuthTo(distance_point2.coordinate)
                return distance_point2.coordinate.atDistanceAndAzimuth(-distace/2, azimuth)
            }

            MapPolyline {
                id:distace_line
                line.width: 3
                line.color: '#00eaff'
                z:5
                path: [
                    distance_point1.coordinate,
                    distance_point2.coordinate,
                ]
            }
            //距离测量相关组件--------end

            //角度测量相关组件--------begin
            MapQuickItem {
                id: angle_point_center
                anchorPoint.x: angle_point_source.width/2
                anchorPoint.y: angle_point_source.height/2
                coordinate: QtPositioning.coordinate(0,0)
                sourceItem:ColoredImage  {
                    id: angle_point_source
                    source: "qrc:/image/bullseye.svg"
                    width: 30
                    height: width
                    color: "#fcff00"
                }
                visible: false
            }
            MapQuickItem {
                id: angle_point1
                anchorPoint.x: angle_point1_source.width/2
                anchorPoint.y: angle_point1_source.height/2
                coordinate: QtPositioning.coordinate(0,0)
                sourceItem:ColoredImage  {
                    id: angle_point1_source
                    source: "qrc:/image/bullseye.svg"
                    width: 30
                    height: width
                    color: "#fcff00"
                    opacity: 0
                }
                visible: true
            }
            MapQuickItem {
                id: angle_point2
                anchorPoint.x: angle_point2_source.width/2
                anchorPoint.y: angle_point2_source.height/2
                coordinate: QtPositioning.coordinate(0,0)
                sourceItem:ColoredImage  {
                    id: angle_point2_source
                    source: "qrc:/image/bullseye.svg"
                    width: 30
                    height: width
                    color: "#fcff00"
                    opacity: 0
                }
                visible: true
            }

            MapPolyline {
                id:angle_line1
                line.width: 3
                line.color:'#00eaff'
                z:10
                path: [
                    angle_point_center.coordinate,
                    angle_point1.coordinate
                ]
                visible: false
            }

            MapPolyline {
                id:angle_line2
                line.width: 3
                line.color: '#00eaff'
                z:10
                path: [
                    angle_point_center.coordinate,
                    angle_point2.coordinate
                ]
                visible: false
            }


            MapQuickItem {
                id: angle_lable
                anchorPoint.x: angle_comlable.width/2
                anchorPoint.y: angle_comlable.height*2
                z:20
                sourceItem:CommonLabel  {
                    id: angle_comlable
                    color: "#fcff00"
                    font.pointSize: 15
                }
                visible: false

                Binding{
                    target: angle_lable
                    property: "coordinate"
                    value: angle_point_center.coordinate
                }
                Binding{
                    target: angle_comlable
                    property: "text"
                    value: get_diff().toFixed(2)+"deg"
                }
            }
            //角度测量相关组件--------end

            MouseArea{
                id:map_mousearea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true

                function addAllDistanceTakeItem()
                {
                    myeditorMap.addMapItem(distance_point1)
                    myeditorMap.addMapItem(distance_point2)
                    myeditorMap.addMapItem(distace_line)
                    myeditorMap.addMapItem(distance_lable)
                }

                function addAllAngleTakeItem()
                {
                    myeditorMap.addMapItem(angle_point_center)
                    myeditorMap.addMapItem(angle_point1)
                    myeditorMap.addMapItem(angle_line1)
                    myeditorMap.addMapItem(angle_point2)
                    myeditorMap.addMapItem(angle_line2)
                    myeditorMap.addMapItem(angle_lable)
                }

                onPressed: {
                    if(map_toolbox_state==1)
                    {
                        addAllDistanceTakeItem()

                        distance_point1.coordinate=myeditorMap.toCoordinate(Qt.point(mouseX,mouseY),false)
                        distance_point2.coordinate=myeditorMap.toCoordinate(Qt.point(mouseX,mouseY),false)
                        distance_point1.visible=true
                        distance_point2.visible=true
                        distace_line.visible=true
                        distance_lable.visible=true
                        map_toolbox_state=2
                        map_mousearea.hoverEnabled=true
                        return
                    }
                    if(map_toolbox_state==2)
                    {
                        addAllDistanceTakeItem()

                        myeditorMap.addMapItem(distance_point1)
                        map_mousearea.hoverEnabled=false
                        map_toolbox_state=3
                        var cur_distance=(distance_point1.coordinate.distanceTo(distance_point2.coordinate))/1000
                        measure_distance(cur_distance)
                        return
                    }
                    if(map_toolbox_state==6)
                    {
                        addAllAngleTakeItem()
                        angle_point_center.coordinate=myeditorMap.toCoordinate(Qt.point(mouseX,mouseY),false)
                        angle_point1.coordinate=myeditorMap.toCoordinate(Qt.point(mouseX,mouseY),false)
                        angle_point_center.visible=true
                        angle_point1.sourceItem.opacity=0.3
                        angle_line1.visible=true
                        map_toolbox_state=7
                        map_mousearea.hoverEnabled=true
                        return
                    }
                    if(map_toolbox_state==7)
                    {
                        addAllAngleTakeItem()
                        map_toolbox_state=8
                        angle_point2.coordinate=myeditorMap.toCoordinate(Qt.point(mouseX,mouseY),false)
                        angle_point1.sourceItem.opacity=0
                        angle_point2.sourceItem.opacity=0.3
                        angle_line2.visible=true
                        angle_lable.visible=true
                        map_mousearea.hoverEnabled=true
                        return
                    }
                    if(map_toolbox_state==8)
                    {
                        addAllAngleTakeItem()
                        map_toolbox_state=9
                        angle_point2.sourceItem.opacity=0
                        map_mousearea.hoverEnabled=false
                        measure_angle(get_diff())
                        return
                    }
                    if(map_toolbox_state===10)
                    {
                        var cur_coordinate=myeditorMap.toCoordinate(Qt.point(mouseX,mouseY),false)
                        clicked_Point(cur_coordinate.latitude,cur_coordinate.longitude)
                        return
                    }
                }
                onPositionChanged: {
                    if(map_toolbox_state==2)
                    {
                        distance_point2.coordinate=myeditorMap.toCoordinate(Qt.point(mouseX,mouseY),false)
                        return
                    }
                    if(map_toolbox_state==7)
                    {
                        angle_point1.coordinate=myeditorMap.toCoordinate(Qt.point(mouseX,mouseY),false)
                        return
                    }
                    if(map_toolbox_state==8)
                    {
                        angle_point2.coordinate=myeditorMap.toCoordinate(Qt.point(mouseX,mouseY),false)
                        return
                    }
                    var cur_position_coord=myeditorMap.toCoordinate(Qt.point(mouseX,mouseY),false)
                    lat_lng_text.text="lat:"+cur_position_coord.latitude.toFixed(8)+"  lng:"+cur_position_coord.longitude.toFixed(8)
                }
                onPressAndHold:
                {
                    var cur_position_coord=myeditorMap.toCoordinate(Qt.point(mouseX,mouseY),false)
                    lat_lng_text.text="lat:"+cur_position_coord.latitude.toFixed(8)+"  lng:"+cur_position_coord.longitude.toFixed(8)
                }
            }

            //任务栏
            ToolStrip {
                id:                 toolStrip
                anchors.leftMargin: MyWindowItmeSize.defaultFontPixelWidth
                anchors.left:       parent.left
                anchors.topMargin: MyWindowItmeSize.toolbarheight/4//+MyWindowItmeSize.toolbarheight//MyWindowItmeSize.toolbarheight+20//_toolButtonTopMargin //_toolButtonTopMargin//+MyWindowItmeSize.toolbarheight
                anchors.top:        parent.top
                color:              MyWindowsColor.window
                title:              qsTr("工具")
                z:                  30
                showAlternateIcon:  [ false, false, false, false, false, false, false, false ]
                rotateImage:        [ false, false, false, false, false, false, false, false ]
                animateImage:       [ false, false, false, false, false, false, false, false ]
                buttonEnabled:      [ false, true, true, true, true, true, true, true ]
                buttonVisible:      [ false, true, false, true, true, true, true, true ]
                maxHeight:          mapScale.y - toolStrip.y

                model: [
                    {
                        name:                   qsTr("文件"),
                        iconSource:             "/image/MapSync.svg",
                        alternateIconSource:    "/image/MapSyncChanged.svg",
                        // dropPanelComponent:     syncDropPanel
                    },
                    {
                        name:                   qsTr("选点"),
                        iconSource:             "qrc:/image/666-postion.svg",
                        toggle:                 true
                    },
                    {
                        name:                   qsTr("ROI"),
                        iconSource:             "/image/MapAddMission.svg",
                        toggle:                 true
                    },
                    {
                        name:               qsTr("角度"),
                        iconSource:         "qrc:/image/666-share-alt.svg",
                        toggle:                 true
                    },
                    {
                        name:               qsTr("距离"),
                        iconSource:         "qrc:/image/666-distance.svg",
                        toggle:                 true
                    },
                    {
                        name:               qsTr("面积"),
                        iconSource:         "qrc:/image/123.png",
                        toggle:                 true
                    },
                    {
                        name:               qsTr("放大"),
                        iconSource:         "qrc:/image/666-zoom-in.svg"
                    },
                    {
                        name:               qsTr("缩小"),
                        iconSource:         "qrc:/image/666-zoom-out.svg"
                    }
                ]

                /*
            标志当前工具状态
            0--普通
            1--测距前
            2--测距第一点已获取
            3--测距第二点已获取
            6--测角前
            7--测角角点
            8--测角第第一方向
            10--获取航点
                */

                onClicked: {
                    switch (index) {
                    case 1://地图选点
                        if(checked)
                        {
                            hideall_measure()
                            map_toolbox_state=10
                        }
                        else
                        {
                            map_toolbox_state=0
                        }
                        break
                    case 3://角度测量
                        if(checked)
                        {
                            hideall_measure()
                            map_toolbox_state=6
                            map_mousearea.hoverEnabled=true
                        }
                        else
                        {
                            map_toolbox_state=0
                            hideall_measure()
                        }
                        break
                    case 4://距离测量
                        if(checked)
                        {
                            hideall_measure()
                            map_toolbox_state=1
                            map_mousearea.hoverEnabled=true
                        }
                        else
                        {
                            map_toolbox_state=0
                            hideall_measure()
                        }
                        break
                    case 5://面积
                        if(checked)
                        {
                            myeditorMap.addMapItem(areaPolygon)
                            areaPolygon.addVisuals()
                            areaPolygon.addHandles()

                            hideall_measure()
                            areaPolygon.resetPolygon()
                            areaPolygon._visible=true
                        }
                        else
                        {
                            hideall_measure()
                            areaPolygon._visible=false
                        }
                        break

                    case 6://放大
                        myeditorMap.zoomLevel += 0.5
                        break
                    case 7://缩小
                        myeditorMap.zoomLevel -= 0.5
                        break
                    }
                }
            }
            //任务栏

            //经纬度显示
            CommonLabel {
                id: lat_lng_text
                color:        myeditorMap.isSatelliteMap?"balck":"white"
                font.family:         MyWindowItmeSize.demiboldFontFamily
                anchors.top:         parent.top
                anchors.right:       parent.right
                anchors.topMargin:   5
                anchors.rightMargin: 5
                horizontalAlignment: Text.AlignRight
                verticalAlignment:   Text.AlignHCenter
                text:                "lat:0  lng:0"
                z:90
            }
        }
        //地图
    }

    MapScale {
        id:                 mapScale
        anchors.margins:    MyWindowItmeSize.defaultFontPixelHeight * (0.66)
        anchors.bottom:     parent.bottom
        anchors.left:       parent.left
        mapControl:         myeditorMap
    }



}



