import QtQuick 2.12
import QtQuick.Controls 2.2

import "../Constants"
import Dex.Themes 1.0 as Dex

Rectangle
{
    property int  searchIconLeftMargin: 13
    property bool forceFocus: false
    property var searchModel: API.app.portfolio_pg.global_cfg_mdl.all_proxy
    property alias searchIcon: _searchIcon
    property alias textField: _textField

    color: Dex.CurrentTheme.accentColor
    radius: 18
    signal searchBarTextChanged(var patternStr)

    onSearchBarTextChanged: searchModel.setFilterFixedString(_textField.text)

    DexImage
    {
        id: _searchIcon
        anchors.left: parent.left
        anchors.leftMargin: searchIconLeftMargin
        anchors.verticalCenter: parent.verticalCenter

        width: 12
        height: 12

        source: General.image_path + "exchange-search.svg"

        DexColorOverlay
        {
            anchors.fill: parent
            source: parent
            color: Dex.CurrentTheme.textPlaceholderColor
        }
    }

    DefaultTextField
    {
        id: _textField

        anchors.left: _searchIcon.right
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - x - 5
        height: parent.height

        background: null

        placeholderText: qsTr("Search")
        placeholderTextColor: Dex.CurrentTheme.textPlaceholderColor
        onTextChanged: searchBarTextChanged(text)
        font.pixelSize: 14
        Component.onCompleted:
        {
            if (forceFocus) _textField.forceActiveFocus()
        }
    }
}
