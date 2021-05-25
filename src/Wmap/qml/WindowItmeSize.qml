pragma Singleton
import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Window 2.2

Item {
    id: _screenTools

    //字体大小设置
    property int baseSize : 12      //这个值要与系统设置的字体的大小一致
    property real defaultFontPointSize
    property real defaultFontPixelHeight
    property real defaultFontPixelWidth
    property real smallFontPointSize
    property real mediumFontPointSize
    property real largeFontPointSize
    property real toolbarheight
    readonly property real smallFontPointRatio:      0.75
    readonly property real mediumFontPointRatio:     1.25
    readonly property real largeFontPointRatio:      1.5
    property real realPixelDensity:   Screen.pixelDensity
    property real realPixelRatio: {
        return Screen.devicePixelRatio
    }
    property bool isMobile:         false
    readonly property real minTouchMillimeters: 10      ///< Minimum touch size in millimeters
    property real minTouchPixels:               0       ///< Minimum touch size in pixels
    property real implicitButtonWidth:              Math.round(defaultFontPixelWidth *  (isMobile ? 7.0 : 5.0))
    property real implicitButtonHeight:             Math.round(defaultFontPixelHeight * (isMobile ? 2.0 : 1.6))
    property real implicitCheckBoxHeight:           Math.round(defaultFontPixelHeight * (isMobile ? 2.0 : 1.0))
    property real implicitRadioButtonHeight:        implicitCheckBoxHeight
    property real implicitTextFieldHeight:          Math.round(defaultFontPixelHeight * (isMobile ? 2.0 : 1.6))
    property real implicitComboBoxHeight:           Math.round(defaultFontPixelHeight * (isMobile ? 2.0 : 1.6))
    property real implicitComboBoxWidth:            Math.round(defaultFontPixelWidth *  (isMobile ? 7.0 : 5.0))
    property real implicitSliderHeight:             isMobile ? Math.max(defaultFontPixelHeight, minTouchPixels) : defaultFontPixelHeight
    property real checkBoxIndicatorSize:            Math.round(defaultFontPixelHeight * (isMobile ? 1.5 : 1.0))
    property real radioButtonIndicatorSize:         checkBoxIndicatorSize
    readonly property string normalFontFamily:      "opensans"
    readonly property string demiboldFontFamily:    "opensans-demibold"
    property real availableHeight: 1080
    property real availableWidth: 1920



    Text {
        id:     _textMeasure
        text:   "X"
        font.family:    normalFontFamily
        property real   fontWidth:    contentWidth
        property real   fontHeight:   contentHeight
        Component.onCompleted: {
            _screenTools._setBasePointSize(baseSize);
        }
    }

    function _setBasePointSize(pointSize) {
        _textMeasure.font.pointSize = pointSize
        defaultFontPointSize    = pointSize
        defaultFontPixelHeight  = Math.round(_textMeasure.fontHeight/2.0)*2
        defaultFontPixelWidth   = Math.round(_textMeasure.fontWidth/2.0)*2
        smallFontPointSize      = defaultFontPointSize  * _screenTools.smallFontPointRatio
        mediumFontPointSize     = defaultFontPointSize  * _screenTools.mediumFontPointRatio
        largeFontPointSize      = defaultFontPointSize  * _screenTools.largeFontPointRatio
        minTouchPixels          = Math.round(minTouchMillimeters * realPixelDensity * realPixelRatio)
        if (minTouchPixels / Screen.height > 0.15) {
            // If using physical sizing takes up too much of the vertical real estate fall back to font based sizing
            minTouchPixels      = defaultFontPixelHeight * 3
        }
        toolbarheight=pointSize*3.2
    }










}
