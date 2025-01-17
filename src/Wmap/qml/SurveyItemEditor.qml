import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs  1.2
import QtQuick.Extras   1.4
import QtQuick.Layouts  1.2
import "."



Rectangle {
    id:         _root
    height:     visible ? (editorColumn.height + (_margin * 2)) : 0
    width:      availableWidth
    color:      MyWindowsColor.windowShadeDark
    radius:     _radius

    // The following properties must be available up the hierarchy chain
    //property real   availableWidth    ///< Width for control
    //property var    missionItem       ///< Mission Item for editor

    property real   _margin:                    MyWindowItmeSize.defaultFontPixelWidth / 2
    property real   _fieldWidth:                MyWindowItmeSize.defaultFontPixelWidth * 10.5
    property var missionItem
    //property var    _vehicle:                   QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle : QGroundControl.multiVehicleManager.offlineEditingVehicle
    //property real   _cameraMinTriggerInterval:  missionItem.cameraCalc.minTriggerInterval.rawValue

    function polygonCaptureStarted() {
        missionItem.clearPolygon()
    }

    function polygonCaptureFinished(coordinates) {
        for (var i=0; i<coordinates.length; i++) {
            missionItem.addPolygonCoordinate(coordinates[i])
        }
    }

    function polygonAdjustVertex(vertexIndex, vertexCoordinate) {
        missionItem.adjustPolygonCoordinate(vertexIndex, vertexCoordinate)
    }

    function polygonAdjustStarted() { }
    function polygonAdjustFinished() { }


    Column {
        id:                 editorColumn
        anchors.margins:    _margin
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        spacing:            _margin

        CommonLabel {
            anchors.left:   parent.left
            anchors.right:  parent.right
            text:           qsTr("WARNING: Photo interval is below minimum interval (%1 secs) supported by camera.").arg(_cameraMinTriggerInterval.toFixed(1))
            wrapMode:       Text.WordWrap
            color:          MyWindowsColor.warningText
            visible:        missionItem.cameraShots > 0 && _cameraMinTriggerInterval !== 0 && _cameraMinTriggerInterval > missionItem.timeBetweenShots
        }

        /*CameraCalc {
            cameraCalc:             missionItem.cameraCalc
            vehicleFlightIsFrontal: true
            distanceToSurfaceLabel: qsTr("Altitude")
            frontalDistanceLabel:   qsTr("Trigger Distance")
            sideDistanceLabel:      qsTr("Spacing")
        }*/

        SectionHeader {
            id:     transectsHeader
            text:   qsTr("Transects")
        }

        GridLayout {
            id:             transectsGrid
            anchors.left:   parent.left
            anchors.right:  parent.right
            columnSpacing:  _margin
            rowSpacing:     _margin
            columns:        2
            visible:        transectsHeader.checked

            CommonLabel { text: qsTr("Angle") }
            /*FactTextField {
                fact:                   missionItem.gridAngle
                Layout.fillWidth:       true
                onUpdated:              angleSlider.value = missionItem.gridAngle.value
            }*/
            CommonSlider {
                id:                     angleSlider
                minimumValue:           0
                maximumValue:           359
                stepSize:               1
                tickmarksEnabled:       false
                Layout.fillWidth:       true
                Layout.columnSpan:      2
                Layout.preferredHeight: MyWindowItmeSize.defaultFontPixelHeight * 1.5
                onValueChanged:         missionItem.gridAngle.value = value
                Component.onCompleted:  value = missionItem.gridAngle.value
                updateValueWhileDragging: true
            }

            CommonLabel { text: qsTr("Turnaround dist") }
            /*FactTextField {
                fact:               missionItem.turnAroundDistance
                Layout.fillWidth:   true
            }*/

            CommonButton {
                Layout.columnSpan:  2
                text:               qsTr("Rotate Entry Point")
                onClicked:          missionItem.rotateEntryPoint();
            }
           /* QGCLabel { text: qsTr("EntryPointInt") }
            FactTextField {
                fact:                   missionItem.gridAngle
                Layout.fillWidth:       true
            }

            FactCheckBox {
                text:               qsTr("Hover and capture image")
                fact:               missionItem.hoverAndCapture
                visible:            missionItem.hoverAndCaptureAllowed
                enabled:            !missionItem.followTerrain
                Layout.columnSpan:  2
                onClicked: {
                    if (checked) {
                        missionItem.cameraTriggerInTurnAround.rawValue = false
                    }
                }
            }

            FactCheckBox {
                text:               qsTr("Refly at 90 deg offset")
                fact:               missionItem.refly90Degrees
                enabled:            !missionItem.followTerrain
                Layout.columnSpan:  2
            }

            FactCheckBox {
                text:               qsTr("Images in turnarounds")
                fact:               missionItem.cameraTriggerInTurnAround
                enabled:            missionItem.hoverAndCaptureAllowed ? !missionItem.hoverAndCapture.rawValue : true
                Layout.columnSpan:  2
            }

            FactCheckBox {
                text:               qsTr("Fly alternate transects")
                fact:               missionItem.flyAlternateTransects
                visible:            _vehicle.fixedWing || _vehicle.vtol
                Layout.columnSpan:  2
            }

            QGCCheckBox {
                id:                 relAlt
                Layout.alignment:   Qt.AlignLeft
                text:               qsTr("Relative altitude")
                checked:            missionItem.cameraCalc.distanceToSurfaceRelative
                enabled:            missionItem.cameraCalc.isManualCamera && !missionItem.followTerrain
                visible:            QGroundControl.corePlugin.options.showMissionAbsoluteAltitude || (!missionItem.cameraCalc.distanceToSurfaceRelative && !missionItem.followTerrain)
                Layout.columnSpan:  2
                onClicked:          missionItem.cameraCalc.distanceToSurfaceRelative = checked

                Connections {
                    target: missionItem.cameraCalc
                    onDistanceToSurfaceRelativeChanged: relAlt.checked = missionItem.cameraCalc.distanceToSurfaceRelative
                }
            }*/
        }

        SectionHeader {
            id:         terrainHeader
            text:       qsTr("Terrain")
            checked:    missionItem.followTerrain
        }

        ColumnLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        _margin
            visible:        terrainHeader.checked

           /* QGCCheckBox {
                id:         followsTerrainCheckBox
                text:       qsTr("Vehicle follows terrain")
                checked:    missionItem.followTerrain
                onClicked:  missionItem.followTerrain = checked
            }*/

            GridLayout {
                Layout.fillWidth:   true
                columnSpacing:      _margin
                rowSpacing:         _margin
                columns:            2
                visible:            followsTerrainCheckBox.checked

                CommonLabel { text: qsTr("Tolerance") }
               /* FactTextField {
                    fact:               missionItem.terrainAdjustTolerance
                    Layout.fillWidth:   true
                }

                QGCLabel { text: qsTr("Max Climb Rate") }
                FactTextField {
                    fact:               missionItem.terrainAdjustMaxClimbRate
                    Layout.fillWidth:   true
                }

                QGCLabel { text: qsTr("Max Descent Rate") }
                FactTextField {
                    fact:               missionItem.terrainAdjustMaxDescentRate
                    Layout.fillWidth:   true
                }*/
            }
        }

        SectionHeader {
            id:     statsHeader
            text:   qsTr("Statistics")
        }

       // TransectStyleComplexItemStats { }
    } // Column
} // Rectangle
