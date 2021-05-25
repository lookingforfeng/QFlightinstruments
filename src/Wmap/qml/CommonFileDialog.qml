import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.2
import QGCControllers 1.0
import "."


/// This control is meant to be a direct replacement for the standard Qml FileDialog control.
/// It differs for mobile builds which uses a completely custom file picker.
Item {
    id:         _root
    visible:    false

    property var    qgcView
    property string folder              // Due to Qt bug with file url parsing this must be an absolute path
    property var    nameFilters
    property string fileExtension       // Primary file extension to search for
    property string fileExtension2: ""  // Secondary file extension to search for
    property string title
    property bool   selectExisting
    property bool   selectFolder

    property bool   _openForLoad:   true
    property real   _margins:       MyWindowItmeSize.defaultFontPixelHeight / 2
    property bool   _mobileDlg:    false //QGroundControl.corePlugin.options.useMobileFileDialog
    property var    _rgExtensions

    Component.onCompleted: setupFileExtensions()

    onFileExtensionChanged: setupFileExtensions()
    onFileExtension2Changed: setupFileExtensions()

    function setupFileExtensions() {
        if (fileExtension2 == "") {
            _rgExtensions = [ fileExtension ]
        } else {
            _rgExtensions = [ fileExtension, fileExtension2 ]
        }
    }

    function openForLoad() {
        _openForLoad = true
        if (_mobileDlg && folder.length !== 0) {
            qgcView.showDialog(mobileFileOpenDialog, title, qgcView.showDialogDefaultWidth, StandardButton.Cancel)
        } else {
            fullFileDialog.open()
        }
    }

    function openForSave() {
        _openForLoad = false
        if (_mobileDlg && folder.length !== 0) {
            qgcView.showDialog(mobileFileSaveDialog, title, qgcView.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
        } else {
            fullFileDialog.open()
        }
    }

    function close() {
        fullFileDialog.close()
    }

    signal acceptedForLoad(string file)
    signal acceptedForSave(string file)
    signal rejected

    QGCFileDialogController { id: controller }

    // On Qt 5.9 android versions there is the following bug: https://bugreports.qt.io/browse/QTBUG-61424
    // This prevents FileDialog from being used. So we have a temp hack workaround for it which just no-ops
    // the FileDialog fallback mechanism on android 5.9 builds.

    HackFileDialog{
        id:             fullFileDialog
        folder:         "file:///" + _root.folder
        nameFilters:    _root.nameFilters ? _root.nameFilters : []
        title:          _root.title
        selectExisting: _root.selectExisting
        selectMultiple: false
        selectFolder:   _root.selectFolder

        onAccepted: {
            if (_openForLoad) {
                _root.acceptedForLoad(controller.urlToLocalFile(fileUrl))
            } else {
                _root.acceptedForSave(controller.urlToLocalFile(fileUrl))
            }
        }
        onRejected: _root.rejected()
    }

    Component {
        id: mobileFileOpenDialog

        CommonViewDialog {
            CommonFlickable {
                anchors.fill:   parent
                contentHeight:  fileOpenColumn.height

                Column {
                    id:             fileOpenColumn
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    spacing:        MyWindowItmeSize.defaultFontPixelHeight / 2

                    Repeater {
                        id:     fileList
                        model:  controller.getFiles(folder, _rgExtensions)

                        FileButton {
                            id:             fileButton
                            anchors.left:   parent.left
                            anchors.right:  parent.right
                            text:           modelData

                            onClicked: {
                                hideDialog()
                                _root.acceptedForLoad(controller.fullyQualifiedFilename(folder, modelData, fileExtension))
                            }

                            onHamburgerClicked: {
                                highlight = true
                                hamburgerMenu.fileToDelete = controller.fullyQualifiedFilename(folder, modelData, fileExtension)
                                hamburgerMenu.popup()
                            }

                            Menu {
                                id: hamburgerMenu

                                property string fileToDelete

                                onAboutToHide: fileButton.highlight = false

                                MenuItem {
                                    text:           qsTr("Delete")
                                    onTriggered:    controller.deleteFile(hamburgerMenu.fileToDelete);
                                }
                            }
                        }
                    }

                    CommonLabel {
                        text:       qsTr("No files")
                        visible:    fileList.model.length === 0
                    }
                }
            }
        }
    }

    Component {
        id: mobileFileSaveDialog

        CommonViewDialog {
            function accept() {
                if (filenameTextField.text == "") {
                    return
                }
                if (!replaceMessage.visible) {
                    if (controller.fileExists(controller.fullyQualifiedFilename(folder, filenameTextField.text, fileExtension))) {
                        replaceMessage.visible = true
                        return
                    }
                }
                _root.acceptedForSave(controller.fullyQualifiedFilename(folder, filenameTextField.text, fileExtension))
                hideDialog()
            }

            CommonFlickable {
                anchors.fill:   parent
                contentHeight:  fileSaveColumn.height

                Column {
                    id:             fileSaveColumn
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    spacing:        MyWindowItmeSize.defaultFontPixelHeight / 2

                    RowLayout {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        spacing:        MyWindowItmeSize.defaultFontPixelWidth

                        CommonLabel { text: qsTr("New file name:") }

                        CommonTextField {
                            id:                 filenameTextField
                            Layout.fillWidth:   true
                            onTextChanged:      replaceMessage.visible = false
                        }
                    }

                    CommonLabel {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        wrapMode:       Text.WordWrap
                        text:           qsTr("File names must end with .%1 file extension. If missing it will be added.").arg(fileExtension)
                    }

                    CommonLabel {
                        id:             replaceMessage
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        wrapMode:       Text.WordWrap
                        text:           qsTr("The file %1 exists. Click Save again to replace it.").arg(filenameTextField.text)
                        visible:        false
                        color:         MyWindowsColor.warningText
                    }

                    SectionHeader {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        text:           qsTr("Save to existing file:")
                    }

                    Repeater {
                        model: controller.getFiles(folder, [ fileExtension ])

                        FileButton {
                            anchors.left:   parent.left
                            anchors.right:  parent.right
                            text:           modelData

                            onClicked: {
                                hideDialog()
                                _root.acceptedForSave(controller.fullyQualifiedFilename(folder, modelData, fileExtension))
                            }

                            onHamburgerClicked: {
                                highlight = true
                                hamburgerMenu.fileToDelete = controller.fullyQualifiedFilename(folder, modelData, fileExtension)
                                hamburgerMenu.popup()
                            }

                            Menu {
                                id: hamburgerMenu

                                property string fileToDelete

                                onAboutToHide: {
                                    fileButton.highlight = false
                                    hideDialog()

                                }
                                MenuItem {
                                    text:           qsTr("Delete")
                                    onTriggered:    controller.deleteFile(hamburgerMenu.fileToDelete);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
