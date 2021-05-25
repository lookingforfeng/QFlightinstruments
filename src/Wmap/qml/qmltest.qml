import QtQuick 2.0
import QtQuick.Controls 2.2

Item {
    id:root
    width: 400
    height: 400
    objectName: "QMLWindow"
    signal sendToWidget(string textInput)
    signal receFromWidget(string rectext)
   function load(str)
   {
       m_txt.text=str
   }
    Rectangle{
        anchors.fill: parent
        color: "lightsteelblue"
        Column{
            anchors.centerIn: parent
            spacing: 30
            TextInput{
                id:m_txt
                text:"hello qml"
            }
            Button{
                id:btn
                text:"clicked me"
                onClicked:root.sendToWidget(m_txt.text)
            }
        }
    }
Component.onCompleted: {

                root.receFromWidget.connect(root.load)
}
Component.onDestruction:  root.receFromWidget.disconnect(root.load)

}
