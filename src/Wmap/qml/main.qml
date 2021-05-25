import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.3
import QtLocation       5.3
import QtPositioning    5.3
import QtQuick.Dialogs  1.2

Item {
   id: mainwindow
    visible: true
    height: 1080
    width: 1920

    onHeightChanged: {
        MyWindowItmeSize.availableHeight = mainwindow.height - mianToolBar.height
    }

    onWidthChanged:
    {
        MyWindowItmeSize.availableWidth=mainwindow.width
    }

    Component.onCompleted:
    {
        mianToolBar.checkPlan()
    }

    function showPlanView() {
        _planview.visible=true;
        _setting.visible=false;
        mianToolBar.checkPlan()
    }

    function showSettingsView() {
        _planview.visible=false;
        _setting.visible=true;
        mianToolBar.checkSetting()
		_setting.source="qrc:/qml/AppSettings.qml"

    }


    //工具栏
    MyToolBar{
        id:                 mianToolBar
        height:             MyWindowItmeSize.toolbarheight
        anchors.right:      parent.right
        anchors.bottom:     parent.bottom
        z:                  90
        visible : false
        onShowSettingsView: mainwindow.showSettingsView()
        onShowPlanView:mainwindow.showPlanView()
        DeadMouseArea {
            id:             toolbarBlocker
            enabled:        false
            anchors.fill:   parent
        }
    }

    PlanView{
        id:_planview
        anchors.fill:       parent
        visible:            true
        z:5
        objectName: "lookingfeng_wmap"
    }

	Loader {
        id:_setting
        anchors.fill:       parent
        visible: false
        z:5
    }
}


