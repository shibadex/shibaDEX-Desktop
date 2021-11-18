import QtQuick 2.15
import Qaterial 1.0 as Qaterial

import App 1.0
import Dex.Themes 1.0 as Dex

DexRectangle
{
    id: control

    property int padding: 12
    property int spacing: 4
    property int verticalAlignment: Qt.AlignVCenter
    property int horizontalAlignment: Qt.AlignHCenter
    property int verticalPadding: 2
    property int horizontalPadding: 2


    // old button property
    property alias text_obj: _label
    property alias containsMouse: _controlMouseArea.containsMouse

    property bool text_left_align: false

    property int minWidth: 90

    property real textScale: 1

    property string button_type: "default"

    property alias label: _label
    property alias font: _label.font
    property alias leftPadding: _contentRow.leftPadding
    property alias rightPadding: _contentRow.rightPadding
    property alias topPadding: _contentRow.topPadding
    property alias bottomPadding: _contentRow.bottomPadding

    property string text: ""
    property string iconSource: ""

    signal clicked()

    radius: 5
    gradient: Gradient
    {
        orientation: Qt.Horizontal
        GradientStop
        {
            position: 0.1255
            color: enabled ? 
                    Dex.CurrentTheme.gradientButtonPressedStartColor : _controlMouseArea.containsMouse ?
                    Dex.CurrentTheme.gradientButtonHoveredStartColor : _controlMouseArea.containsPress ?
                    Dex.CurrentTheme.gradientButtonStartColor : Dex.CurrentTheme.gradientButtonDisabledStartColor
        }
        GradientStop
        {
            position: 0.933
            color: enabled ? 
                    Dex.CurrentTheme.gradientButtonPressedEndColor : _controlMouseArea.containsMouse ?
                    Dex.CurrentTheme.gradientButtonHoveredEndColor : _controlMouseArea.containsPress ?
                    Dex.CurrentTheme.gradientButtonEndColor : Dex.CurrentTheme.gradientButtonDisabledEndColor
        }
    }
    height: _label.implicitHeight + (padding * verticalPadding)
    width: _contentRow.implicitWidth + (padding * horizontalPadding)

    Row
    {
        id: _contentRow

        anchors
        {
            horizontalCenter: parent.horizontalAlignment == Qt.AlignHCenter ? parent.horizontalCenter : undefined
            verticalCenter: parent.verticalAlignment == Qt.AlignVCenter ? parent.verticalCenter : undefined
        }

        spacing: _icon.visible ? parent.spacing : 0

        Qaterial.ColorIcon
        {
            id: _icon
            iconSize: _label.font.pixelSize + 2
            visible: control.iconSource === "" ? false : true
            source: control.iconSource
            color: _label.color
            anchors.verticalCenter: parent.verticalCenter
        }

        DexLabel
        {
            id: _label
            anchors.verticalCenter: parent.verticalCenter
            font: DexTypo.button
            text: control.text
            color: enabled ? _controlMouseArea.containsMouse ? _controlMouseArea.containsPress ?
                    Dex.CurrentTheme.gradientButtonTextPressedColor :
                    Dex.CurrentTheme.gradientButtonTextHoveredColor :
                    Dex.CurrentTheme.gradientButtonTextEnabledColor :
                    Dex.CurrentTheme.gradientButtonTextDisabledColor
        }
    }
    DexMouseArea
    {
        id: _controlMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.clicked()
    }
}
