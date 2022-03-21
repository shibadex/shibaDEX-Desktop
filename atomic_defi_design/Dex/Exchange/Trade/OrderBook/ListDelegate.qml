import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex
import bignumberjs 1.0

Item
{
    property bool isAsk

    DefaultMouseArea
    {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: true
        onClicked:
        {
            if(is_mine) return

            if(enough_funds_to_pay_min_volume)
            {
                exchange_trade.orderSelected = true
                orderList.currentIndex = index

                selectOrder(isAsk, coin, price, quantity, price_denom,
                            price_numer, quantity_denom, quantity_numer,
                            min_volume, base_min_volume, base_max_volume,
                            rel_min_volume, rel_max_volume, base_max_volume_denom,
                            base_max_volume_numer, uuid)

                order_form.visible = General.flipFalse(order_form.visible)
                order_form.hidden = General.flipTrue(order_form.hidden)
                if (!order_form.hidden) order_form.contentVisible = General.flipFalse(order_form.contentVisible)
            }
        }

        AnimatedRectangle
        {
            visible: mouse_area.containsMouse
            width: parent.width
            height: parent.height
            color: Dex.CurrentTheme.foregroundColor
            opacity: 0.1
        }

        Rectangle
        {
            anchors.verticalCenter: parent.verticalCenter
            width: 6
            height: 6
            radius: width / 2
            visible: is_mine
            color: isAsk ? Dex.CurrentTheme.noColor : Dex.CurrentTheme.okColor
        }

        // Progress bar
        Rectangle
        {
            anchors.bottom: parent.bottom
            height: 2
            width: parent.width
            radius: 3
            color: Dex.CurrentTheme.backgroundColor

            Rectangle
            {
                id: depth_bar
                anchors.top: parent.top
                height: 2
                width: 0
                Behavior on width { NumberAnimation { duration: 1000 } }
                radius: 3
                opacity: 0.8
                color: isAsk ? Dex.CurrentTheme.noColor : Dex.CurrentTheme.okColor
                Component.onCompleted: width = ((depth * 100) * (mouse_area.width + 40)) / 100
            }
        }

        RowLayout
        {
            id: row
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
            onWidthChanged: progress.width = ((depth * 100) * (width + 40)) / 100

            // error icon
            DefaultAlertIcon
            {
                visible: !enough_funds_to_pay_min_volume
                iconSize: 12
                
                tooltipText:
                {
                    let relMaxTakerVol = parseFloat(API.app.trading_pg.orderbook.rel_max_taker_vol.decimal);
                    let baseMaxTakerVol = parseFloat(API.app.trading_pg.orderbook.base_max_taker_vol.decimal);

                    qsTr("This order requires a minimum amount of %1 %2. %3")
                        .arg(parseFloat(min_volume).toFixed(8))
                        .arg(isAsk ? API.app.trading_pg.market_pairs_mdl.right_selected_coin : API.app.trading_pg.market_pairs_mdl.left_selected_coin)
                        .arg(relMaxTakerVol > 0 || baseMaxTakerVol > 0 ? "Your max balance after fees is: %1".arg(isAsk ? relMaxTakerVol.toFixed(8) : baseMaxTakerVol.toFixed(8)) : "")
                }
            }

            // Price
            DefaultText
            {
                Layout.preferredWidth: (parent.width / 100) * 33
                text: { new BigNumber(price).toFixed(8) }
                font.family: DexTypo.fontFamily
                font.pixelSize: 12
                color: isAsk ? Dex.CurrentTheme.noColor : Dex.CurrentTheme.okColor
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
            }

            // Quantity
            DefaultText
            {
                Layout.preferredWidth: (parent.width / 100) * 30
                text: { new BigNumber(quantity).toFixed(6) }
                font.family: DexTypo.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
                onTextChanged: depth_bar.width = ((depth * 100) * (mouse_area.width + 40)) / 100
            }

            // Total
            DefaultText
            {
                Layout.preferredWidth: (parent.width / 100) * 30
                rightPadding: (is_mine) && (mouse_area.containsMouse || cancel_button.containsMouse) ? 30 : 0
                font.family: DexTypo.fontFamily
                font.pixelSize: 12
                text: { new BigNumber(total).toFixed(6) }
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight

                Behavior on rightPadding { NumberAnimation { duration: 150 } }
            }
        }
    }

    Qaterial.ColorIcon
    {
        id: cancel_button_text
        property bool requested_cancel: false
        visible: is_mine && !requested_cancel

        source: Qaterial.Icons.close
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 1
        anchors.right: parent.right
        anchors.rightMargin:  mouse_area.containsMouse || cancel_button.containsMouse ? 12 : 6
        Behavior on iconSize
        {
            NumberAnimation
            {
                duration: 200
            }
        }

        iconSize: mouse_area.containsMouse || cancel_button.containsMouse? 16 : 0

        color: cancel_button.containsMouse ?
            Qaterial.Colors.red : mouse_area.containsMouse ?
            DexTheme.foregroundColor: Qaterial.Colors.red

        DefaultMouseArea
        {
            id: cancel_button
            anchors.fill: parent
            hoverEnabled: true


            onClicked:
            {
                if(!is_mine) return

                cancel_button_text.requested_cancel = true
                cancelOrder(uuid)
            }
        }
    }

    AnimatedRectangle
    {
        visible: !enough_funds_to_pay_min_volume && mouse_area.containsMouse
        color: Dex.CurrentTheme.backgroundColor
        anchors.fill: parent
        opacity: .3
    }
}
