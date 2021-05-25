import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtQuick.Layouts          1.2
import QtLocation               5.3
import QtPositioning            5.3
import "."


//验证添加不同的插件
Item {
   /* Rectangle{
        id:root
        anchors.fill: parent
        color:MyWindowsColor.windowShadeDark
        property real lat:30.67

        Component.onCompleted:{
            addrect()

        }

        function addrect()
        {
            var i
            for( i=1;i<=5;i++)
            {

            var onetransectpoint = transectpoint.createObject(minZoomPreview)
            onetransectpoint.coordinate = QtPositioning.coordinate(lat,104.07)


            var onerect = rects.createObject(maxZoomPreview)
            onerect.coordinate = QtPositioning.coordinate(lat,104.07)

            onetransectpoint.myrect=onerect

            maxZoomPreview.addMapItem(onerect)
            minZoomPreview.addMapItem(onetransectpoint)

            lat+=1.5
            }

        }


        //小地图1
        Map {
            id:minZoomPreview
            z:1
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width:              root.width / 2.1
            height:             root.height
            center:             QtPositioning.coordinate(30.67,104.07)
            function updateActiveMapType() {

                var fullMapName = "Mapbox Hybrid Map"
                for (var i = 0; i < minZoomPreview.supportedMapTypes.length; i++) {
                    if (fullMapName === minZoomPreview.supportedMapTypes[i].name) {
                        minZoomPreview.activeMapType = minZoomPreview.supportedMapTypes[i]
                        return
                    }
                }
            }

            Component.onCompleted: {
                updateActiveMapType()
            }
            zoomLevel:         6
            visible:            true
            plugin:  Plugin { name: "QGroundControl" }


        }//小地图1

        //小地图2
        Map {
            id:maxZoomPreview
            z:1
            width:              root.width / 2.1
            height:             root.height
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            center:             QtPositioning.coordinate(30.67,104.07)
            function updateActiveMapType() {

                var fullMapName = "Mapbox Hybrid Map"
                for (var i = 0; i < maxZoomPreview.supportedMapTypes.length; i++) {
                    if (fullMapName === maxZoomPreview.supportedMapTypes[i].name) {
                        maxZoomPreview.activeMapType = maxZoomPreview.supportedMapTypes[i]
                        return
                    }
                }
            }

            Component.onCompleted: {
                updateActiveMapType()
            }
            zoomLevel:         6
            visible:            true
            plugin:  Plugin { name: "QGroundControl" }


        }//小地图2

        //Transect point  自动规划航点显示
        Component {
            id: transectpoint

            MapQuickItem {
                id:             transectpointvisual1
                anchorPoint.x:  20
                anchorPoint.y:  20
                z:              10
                visible:        true
                property  MapQuickItem myrect
                sourceItem:  Rectangle{
                    width: 50
                    height: 50
                    // anchors.fill: parent
                    color:"green"
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            transectpointvisual1.myrect.width=30
                        }

                    }
                }
            }
        }

        Component {
            id: rects
            MapQuickItem {
                id:             transectpointvisual2
                anchorPoint.x:  20
                anchorPoint.y:  20
                width: 300
                z:              10
                visible:        true
                sourceItem: Rectangle{
                    width: transectpointvisual2.width
                    height: 50
                    // anchors.fill: parent
                    color:"blue"
                }

            }
        }







    }

*/




}
