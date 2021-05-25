import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtQuick.Dialogs  1.2

// 主工具栏
Rectangle {
    id:                 _root
    height:           MyWindowItmeSize.toolbarheight
    width:            MyWindowItmeSize.toolbarheight
    color:              Qt.rgba(0,0,0,0.85)
    visible:            false
    anchors.bottomMargin: 1
    radius: MyWindowItmeSize.toolbarheight/2

    signal showSettingsView
    signal showPlanView

    function checkSetting() {
        settingsButton.checked = false
        planButton.checked = false

        settingsButton.visible=false
        planButton.visible=true
    }

    function checkPlan() {
        settingsButton.checked = false
        planButton.checked = false
        planButton.visible=false
        settingsButton.visible=true
    }

    //鼠标事件隔绝层
    DeadMouseArea {
        anchors.fill: parent
    }

    Row {
        id:                     logoRow
        anchors.bottomMargin:   1
       // anchors.left:           parent.left+(parent.width-logoRow.width)/2
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.horizontalCenter: parent.Center
        x:(parent.width-logoRow.width)/2

        //设置图标
        ToolBarButton {
            id:                 settingsButton
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             "/image/simple_setting_icon.svg"
            onClicked:          _root.showSettingsView()
            visible:        false
        }

        //任务规划图标
        ToolBarButton {
            id:                 planButton
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             "/image/map_icon.svg"
            onClicked:          _root.showPlanView()
            visible: false
        }
    }
}

