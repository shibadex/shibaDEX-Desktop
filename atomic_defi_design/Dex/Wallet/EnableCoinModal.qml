//! Qt Imports
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

//! Project Imports
import Qaterial 1.0 as Qaterial

import AtomicDEX.CoinType 1.0
import "../Components"
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

MultipageModal
{
    id: root

    property var coin_cfg_model: API.app.portfolio_pg.global_cfg_mdl

    function setCheckState(checked) 
    {
        coin_cfg_model.all_disabled_proxy.set_all_state(checked)
    }

    function filterCoins(text) 
    {
        coin_cfg_model.all_disabled_proxy.setFilterFixedString(text === undefined ? input_coin_filter.textField.text : text)
    }

    width: 676
    height: 720

    onOpened: 
    {
        filterCoins("");
        setCheckState(false);
        coin_cfg_model.checked_nb = 0;
        input_coin_filter.forceActiveFocus();
    }

    onClosed: 
    {
        filterCoins("");
        setCheckState(false);
        coin_cfg_model.checked_nb = 0;
    }

    MultipageModalContent
    {
        titleText: qsTr("Enable assets")
        titleAlignment: Qt.AlignHCenter

        // Search input
        SearchField
        {
            id: input_coin_filter

            searchIconLeftMargin: 20
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            textField.placeholderText: qsTr("Search asset")

            textField.onTextChanged: filterCoins()
        }

        Item
        {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 5
            Layout.fillWidth: true
            Layout.preferredHeight: 25

            DexCheckBox
            {
                id: _selectAllCheckBox

                visible: list.visible
                checked: coin_cfg_model.checked_nb === setting_modal.enableable_coins_count - API.app.portfolio_pg.portfolio_mdl.length
                anchors.left: parent.left
                boxWidth: 20
                boxHeight: 20
                width: 20

                DefaultMouseArea
                {
                    anchors.fill: parent
                    onClicked: setCheckState(!parent.checked)
                }

                DefaultText
                {
                    anchors.left: parent.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Select all assets")
                }
            }
        }

        HorizontalLine { Layout.topMargin: 5; Layout.alignment: Qt.AlignHCenter; Layout.fillWidth: true }

        DefaultListView
        {
            id: list
            visible: coin_cfg_model.all_disabled_proxy.length > 0
            model: coin_cfg_model.all_disabled_proxy

            Layout.topMargin: -5
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 300
            Layout.fillWidth: true

            delegate: DexCheckBox
            {
                readonly property bool backend_checked: model.checked

                enabled: _selectAllCheckBox.checked ? checked : true
                boxWidth: 20
                boxHeight: 20
                spacing: 0

                onBackend_checkedChanged: if (checked !== backend_checked) checked = backend_checked
                onCheckStateChanged:
                {
                    if (checked !== backend_checked)
                    {
                        var data_index = coin_cfg_model.all_disabled_proxy.index(index, 0)
                        if ((coin_cfg_model.all_disabled_proxy.setData(data_index, checked, Qt.UserRole + 11)) === false)
                        {
                            checked = false
                        }
                    }
                }

                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.right
                    spacing:6

                    // Icon
                    DefaultImage
                    {
                        id: icon
                        Layout.leftMargin: 8
                        Layout.alignment: Qt.AlignVCenter
                        source: General.coinIcon(model.ticker)
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18
                    }
                    DefaultText
                    {
                        Layout.leftMargin: 4
                        Layout.alignment: Qt.AlignVCenter
                        text: model.name + " (" + model.ticker + ")"
                    }
                    CoinTypeTag
                    {
                        id: typeTag
                        Layout.leftMargin: 6
                        Layout.alignment: Qt.AlignVCenter
                        type: model.type
                    }

                    CoinTypeTag
                    {
                        Layout.leftMargin: 6
                        Layout.alignment: Qt.AlignVCenter
                        enabled: General.isIDO(model.ticker)
                        visible: enabled
                        type: "IDO"
                    }

                    CoinTypeTag
                    {
                        Layout.leftMargin: 6
                        Layout.alignment: Qt.AlignVCenter
                        enabled: API.app.portfolio_pg.global_cfg_mdl.get_coin_info(model.ticker).is_wallet_only
                        visible: enabled
                        type: "WALLET ONLY"
                    }
                }
            }
        }

        Item
        {
            Layout.topMargin: 6
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            DexLabel
            {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: coin_cfg_model.all_disabled_proxy.length > 0 ?
                          qsTr("You can still enable %1 assets. Selected: %2.")
                              .arg(setting_modal.enableable_coins_count - API.app.portfolio_pg.portfolio_mdl.length - coin_cfg_model.checked_nb)
                              .arg(coin_cfg_model.checked_nb) :
                          qsTr("All assets are already enabled!")

                color: Dex.CurrentTheme.textPlaceholderColor
            }
        }

        HorizontalLine { Layout.preferredWidth: 500; Layout.alignment: Qt.AlignHCenter }
        
        Item
        {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            DexTransparentButton
            {
                anchors.left: parent.left
                text: qsTr("Change assets limit")
                topPadding: 5
                bottomPadding: 5
                Layout.preferredHeight: 35
                onClicked:
                {
                    setting_modal.selectedMenuIndex = 0; 
                    setting_modal.open()
                }
            }
            DexTransparentButton
            {
                anchors.right: parent.right
                text: qsTr("Add a custom asset to the list")
                topPadding: 5
                bottomPadding: 5
                Layout.preferredHeight: 35
                iconSource: Qaterial.Icons.plus
                onClicked: {
                    root.close()
                    add_custom_coin_modal.open()
                }
            }
        }

        RowLayout
        {
            Layout.fillWidth: true
            DefaultButton
            {
                Layout.preferredWidth: 199
                text: qsTr("Close")
                radius: 20
                onClicked: root.close()
            }
            Item { Layout.fillWidth: true }
            DexGradientAppButton
            {
                Layout.preferredWidth: 199
                visible: coin_cfg_model.length > 0
                enabled: coin_cfg_model.checked_nb > 0
                text: qsTr("Enable")
                radius: 20
                onClicked:
                {
                    API.app.enable_coins(coin_cfg_model.get_checked_coins())
                    setCheckState(false)
                    coin_cfg_model.checked_nb = 0
                    root.close()
                }
            }
        }
    }
}
