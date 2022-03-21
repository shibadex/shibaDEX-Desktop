import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import bignumberjs 1.0

import "../Components"
import "../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

MultipageModal
{
    id: root

    readonly property bool empty_data: !send_result || !send_result.withdraw_answer

    property bool needFix: false
    property bool errorView: false
    property bool segwit: false
    property bool segwit_success: false
    property var segwit_callback
    property var address_data

    readonly property var default_send_result: ({ has_error: false, error_message: "",
                                                    withdraw_answer: {
                                                        total_amount_fiat: "", tx_hex: "", date: "", "fee_details": { total_fee: "" }
                                                    },
                                                    explorer_url: "", max: false })
    property var send_result: default_send_result

    readonly property bool is_send_busy: api_wallet_page.is_send_busy
    property var send_rpc_result: api_wallet_page.send_rpc_data
    readonly property bool is_validate_address_busy: api_wallet_page.validate_address_busy 
    readonly property bool is_convert_address_busy: api_wallet_page.convert_address_busy
    readonly property string address: api_wallet_page.converted_address

    readonly property bool auth_succeeded: api_wallet_page.auth_succeeded

    readonly property bool is_broadcast_busy: api_wallet_page.is_broadcast_busy
    property string broadcast_result: api_wallet_page.broadcast_rpc_data
    property bool async_param_max: false

    property alias address_field: input_address
    property alias amount_field: input_amount

    function getCryptoAmount() { return _preparePage.cryptoSendMode ? input_amount.text : equivalentAmount.value }

    function prepareSendCoin(address, amount, with_fees, fees_amount, is_special_token, gas_limit, gas_price) {
        let max = parseFloat(current_ticker_infos.balance) === parseFloat(amount)

        // Save for later check
        async_param_max = max

        if(with_fees && max === false && !is_special_token)
            max = parseFloat(amount) + parseFloat(fees_amount) >= parseFloat(current_ticker_infos.balance)

        const fees_info = {
            fees_amount,
            gas_price,
            gas_limit: gas_limit === "" ? 0 : parseInt(gas_limit)
        }
        api_wallet_page.send(address, amount, max, with_fees, fees_info)
    }

    function sendCoin() {
        api_wallet_page.broadcast(send_result.withdraw_answer.tx_hex, false, send_result.withdraw_answer.max, input_amount.text)
    }

    function isSpecialToken() {
        return General.isTokenType(current_ticker_infos.type)
    }

    function isERC20() {
        return current_ticker_infos.type === "ERC-20" || current_ticker_infos.type === "BEP-20" || current_ticker_infos.type == "Matic"
    }

    function hasErc20CaseIssue(addr) {
        if(!isERC20()) return false
        if(addr.length <= 2) return false

        addr = addr.substring(2) // Remove 0x
        return addr === addr.toLowerCase() || addr === addr.toUpperCase()
    }

    function reset() {
        send_result = default_send_result
        input_address.text = ""
        input_amount.text = ""
        input_custom_fees.text = ""
        input_custom_fees_gas.text = ""
        input_custom_fees_gas_price.text = ""
        custom_fees_switch.checked = false
        root.currentIndex = 0
    }

    function feeIsHigherThanAmount() {
        if(!custom_fees_switch.checked) return false

        const amt = parseFloat(getCryptoAmount())
        const fee_amt = parseFloat(input_custom_fees.text)

        return amt < fee_amt
    }

    function hasFunds() {
        if(!General.hasEnoughFunds(true, api_wallet_page.ticker, "", "", _preparePage.cryptoSendMode ? input_amount.text : equivalentAmount.value))
            return false

        if(custom_fees_switch.checked) {
            if(isSpecialToken()) {
                const gas_limit = parseFloat(input_custom_fees_gas.text)
                const gas_price = parseFloat(input_custom_fees_gas_price.text)

                const unit = current_ticker_infos.type === "ERC-20" ? 1000000000 : 100000000
                const fee_parent_token = (gas_limit * gas_price)/unit

                const parent_ticker = current_ticker_infos.type === "ERC-20" ? "ETH" : "QTUM"
                if(api_wallet_page.ticker === parent_ticker) {
                    const amount = parseFloat(getCryptoAmount())
                    const total_needed = amount + fee_parent_token
                    if(!General.hasEnoughFunds(true, parent_ticker, "", "", total_needed.toString()))
                        return false
                }
                else {
                    if(!General.hasEnoughFunds(true, parent_ticker, "", "", fee_parent_token.toString()))
                        return false
                }
            }
            else {
                if(feeIsHigherThanAmount()) return false

                if(!General.hasEnoughFunds(true, api_wallet_page.ticker, "", "", input_custom_fees.text))
                    return false
            }
        }

        return true
    }

    function feesAreFilled() {
        return  (!custom_fees_switch.checked || (
                       (!isSpecialToken() && input_custom_fees.acceptableInput) ||
                       (isSpecialToken() && input_custom_fees_gas.acceptableInput && input_custom_fees_gas_price.acceptableInput &&
                                       parseFloat(input_custom_fees_gas.text) > 0 && parseFloat(input_custom_fees_gas_price.text) > 0)
                     )
                 )
    }

    function fieldAreFilled() {
        return input_address.text != "" &&
             ((input_amount.text != "" && input_amount.acceptableInput && parseFloat(input_amount.text) > 0)) &&
             feesAreFilled()
    }

    function setMax() {
        input_amount.text = current_ticker_infos.balance
    }

    width: 650

    closePolicy: Popup.NoAutoClose

    onClosed:
    {
        if (segwit)
        {
            segwit_callback()
        }
        segwit = false
        reset()
    }

    onSend_rpc_resultChanged: {
        if (is_send_busy === false) {
            return
        }

        // Local var, faster
        const result = General.clone(send_rpc_result)

        if(result.error_code) {
            root.close()
            console.log("Send Error:", result.error_code, " Message:", result.error_message)
            toast.show(qsTr("Failed to send"), General.time_toast_important_error, result.error_message)
        }
        else {
            if(!result || !result.withdraw_answer) {
                reset()
                return
            }

            const max = async_param_max
            send_result.withdraw_answer.max = max

            if(max) input_amount.text = API.app.is_pin_cfg_enabled() ? General.absString(result.withdraw_answer.my_balance_change) : result.withdraw_answer.total_amount

            // Change page
            root.currentIndex = 1
        }

        send_result = result
    }

    onAuth_succeededChanged: {
        if (!auth_succeeded) {
            console.log("Double verification failed, cannot confirm sending.")
        }
        else {
            console.log("Double verification succeeded, validate sending.");
        }
    }

    onBroadcast_resultChanged: {
        if (is_broadcast_busy === false) {
            return
        }

        if(root.visible && broadcast_result !== "") {
            if(broadcast_result.indexOf("error") !== -1) {
                reset()
                showError(qsTr("Failed to Send"), General.prettifyJSON(broadcast_result))
            }
            else {
                root.currentIndex = 2
            }
        }
    }

    onIs_validate_address_busyChanged:
    {
        if (!is_validate_address_busy)
        {
            address_data = api_wallet_page.validate_address_data
            if (address_data.reason !== "")
            {
                errorView = true;
                reason.text = address_data.reason;
            }
            else
            {
                errorView = false;
            }
            if (address_data.convertible)
            {
                reason.text =  address_data.reason;
                if (needFix!==true) needFix = true;
            }
        }
    }

    onIs_convert_address_busyChanged:
    {
        if (!is_convert_address_busy)
        {
            if (needFix === true)
            {
                needFix = false
                input_address.text = api_wallet_page.converted_address
            }
        }
    }

    // Prepare Page
    MultipageModalContent
    {
        id: _preparePage

        titleText: qsTr("Prepare to send ") + current_ticker_infos.name
        titleAlignment: Qt.AlignHCenter

        property bool cryptoSendMode: true

        DefaultRectangle
        {

            enabled: !root.segwit && !root.is_send_busy

            Layout.preferredWidth: 420
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter

            color: input_address.background.color
            radius: input_address.background.radius

            DefaultTextField
            {
                id: input_address

                width: 390
                height: 44

                placeholderText: qsTr("Address of the recipient")
                onTextChanged: api_wallet_page.validate_address(text)
                forceFocus: true
            }

            Rectangle
            {
                width: 30
                height: 30
                radius: 7
                anchors.right: parent.right
                anchors.rightMargin: 13
                anchors.verticalCenter: parent.verticalCenter

                color: addrbookIconMouseArea.containsMouse ? Dex.CurrentTheme.buttonColorHovered : "transparent"

                DefaultMouseArea
                {
                    id: addrbookIconMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: contact_list.open()
                }
            }

            DefaultImage
            {
                id: addrbookIcon
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 12
                source: General.image_path + "addressbook.png"
            }

            ColorOverlay
            {
                anchors.fill: addrbookIcon
                source: addrbookIcon
                color: Dex.CurrentTheme.foregroundColor
            }
        }

        // ERC-20 Lowercase issue
        RowLayout
        {
            visible: errorView && input_address.text !== ""
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true

            DefaultText
            {
                id: reason

                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Dex.CurrentTheme.noColor
                text_value: qsTr("The address has to be mixed case.")
            }

            DefaultButton
            {
                enabled: !root.is_send_busy
                visible: needFix

                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 10
                Layout.preferredWidth: 50
                Layout.preferredHeight: 28

                text: qsTr("Fix")

                onClicked: api_wallet_page.convert_address(input_address.text, address_data.to_address_format)
            }
        }

        // Amount to send
        AmountField
        {
            id: input_amount

            enabled: !root.is_send_busy

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 420
            Layout.preferredHeight: 44
            Layout.topMargin: 32

            placeholderText: qsTr("Amount to send")

            onTextEdited:
            {
                if (text.length === 0)
                {
                    text = "";
                    return;
                }
            }

            DefaultText
            {
                anchors.right: maxBut.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                text: _preparePage.cryptoSendMode ? API.app.wallet_pg.ticker : API.app.settings_pg.current_currency
                font.pixelSize: 16
            }

            Rectangle
            {
                id: maxBut
                anchors.right: parent.right
                anchors.rightMargin: 11
                anchors.verticalCenter: parent.verticalCenter
                width: 46
                height: 23
                radius: 7
                color: maxButMouseArea.containsMouse ? Dex.CurrentTheme.buttonColorHovered : Dex.CurrentTheme.buttonColorEnabled

                DefaultText
                {
                    anchors.centerIn: parent
                    text: qsTr("MAX")
                }

                DefaultMouseArea
                {
                    id: maxButMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:
                    {
                        if (_preparePage.cryptoSendMode)
                        {
                            input_amount.text = current_ticker_infos.balance;
                        }
                        else
                        {
                            let cryptoBalance = new BigNumber(current_ticker_infos.balance);
                            input_amount.text = cryptoBalance.multipliedBy(current_ticker_infos.current_currency_ticker_price).toFixed(8);
                        }
                    }
                }
            }
        }

        // Crypto/fiat switch
        RowLayout
        {
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 380

            DefaultText
            {
                id: equivalentAmount

                property string value: "0"

                enabled: !(new BigNumber(current_ticker_infos.current_currency_ticker_price).isLessThanOrEqualTo(0))
                visible: enabled

                text:
                {
                    if (!enabled)
                    {
                        return qsTr("Fiat amount: Unavailable");
                    }
                    else if (_preparePage.cryptoSendMode)
                    {
                        return qsTr("Fiat amount: %1").arg(General.formatFiat('', value, API.app.settings_pg.current_fiat_sign));
                    }
                    else
                    {
                        return qsTr("%1 amount: %2").arg(API.app.wallet_pg.ticker).arg(value);
                    }
                }

                Connections
                {
                    target: input_amount

                    function onTextEdited()
                    {
                        let imputAmount = new BigNumber(input_amount.text);
                        if (input_amount.text === "" || imputAmount.isLessThanOrEqualTo(0))
                            equivalentAmount.value = "0"
                        else if (_preparePage.cryptoSendMode)
                            equivalentAmount.value = imputAmount.multipliedBy(current_ticker_infos.current_currency_ticker_price).toFixed(8);
                        else
                            equivalentAmount.value = imputAmount.dividedBy(current_ticker_infos.current_currency_ticker_price).toFixed(8);
                    }

                    function onTextChanged()
                    {
                        onTextEdited()
                    }
                }
            }

            Item { }

            Rectangle
            {
                enabled: equivalentAmount.enabled
                visible: equivalentAmount.visible

                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: cryptoFiatSwitchText.width + cryptoFiatSwitchIcon.width + 20
                Layout.preferredHeight: 32
                radius: 16

                color: cryptoFiatSwitchMouseArea.containsMouse ? Dex.CurrentTheme.buttonColorHovered : Dex.CurrentTheme.buttonColorEnabled

                Rectangle
                {
                    id: cryptoFiatSwitchIcon
                    width: 28
                    height: 28
                    radius: width / 2
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: Dex.CurrentTheme.backgroundColor

                    DefaultText
                    {
                        id: fiat_symbol
                        visible: _preparePage.cryptoSendMode && API.app.settings_pg.current_currency_sign != "KMD"
                        font.pixelSize: 18
                        anchors.centerIn: parent
                        text: API.app.settings_pg.current_currency_sign
                    }

                    DefaultImage
                    {
                        visible: !fiat_symbol.visible
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        source: General.coinIcon(API.app.wallet_pg.ticker)
                    }
                }

                DefaultText
                {
                    id: cryptoFiatSwitchText
                    anchors.left: cryptoFiatSwitchIcon.right
                    anchors.leftMargin: 7
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 12
                    text:
                    {
                        if (_preparePage.cryptoSendMode) qsTr("Specify in Fiat");
                        else                             qsTr("Specify in Crypto");
                    }
                }

                DefaultMouseArea
                {
                    id: cryptoFiatSwitchMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:
                    {
                        _preparePage.cryptoSendMode = !_preparePage.cryptoSendMode
                        let temp = input_amount.text
                        input_amount.text = equivalentAmount.value;
                        equivalentAmount.value = temp;
                    }
                }
            }
        }

        // Custom fees switch
        DexSwitch
        {
            id: custom_fees_switch
            enabled: !root.is_send_busy
            Layout.topMargin: 32
            text: qsTr("Enable Custom Fees")
            onCheckedChanged: input_custom_fees.text = ""
        }

        // Custom fees warning
        DefaultText
        {
            visible: custom_fees_switch.checked
            font.pixelSize: 14
            color: Dex.CurrentTheme.noColor
            text_value: qsTr("Only use custom fees if you know what you are doing!")
        }

        // Custom Fees section
        ColumnLayout
        {
            visible: custom_fees_switch.checked

            Layout.preferredWidth: parent.width
            Layout.topMargin: 8

            // Normal coins, Custom fees input
            AmountField
            {
                visible: !isSpecialToken()

                id: input_custom_fees

                enabled: !root.is_send_busy

                Layout.preferredWidth: 380
                Layout.preferredHeight: 38
                Layout.alignment: Qt.AlignHCenter

                placeholderText: qsTr("Enter the custom fee") + " [" + api_wallet_page.ticker + "]"
            }

            // Token coins
            ColumnLayout
            {
                visible: isSpecialToken()
                Layout.alignment: Qt.AlignHCenter

                // Gas input
                AmountIntField
                {
                    id: input_custom_fees_gas

                    enabled: !root.is_send_busy

                    Layout.preferredWidth: 380
                    Layout.preferredHeight: 38

                    placeholderText: qsTr("Gas Limit") + " [" + General.tokenUnitName(current_ticker_infos.type) + "]"
                }

                // Gas price input
                AmountIntField
                {
                    id: input_custom_fees_gas_price

                    enabled: !root.is_send_busy

                    Layout.preferredWidth: 380
                    Layout.preferredHeight: 38

                    placeholderText: qsTr("Gas price") + " [" + General.tokenUnitName(current_ticker_infos.type) + "]"
                }
            }

            // Fee is higher than amount error
            DefaultText
            {
                id: fee_error
                visible: feeIsHigherThanAmount()

                Layout.alignment: Qt.AlignHCenter

                wrapMode: Text.Wrap
                color: Style.colorRed
                text_value: qsTr("Custom Fee can't be higher than the amount")
            }
        }

        // Not enough funds error
        DefaultText
        {
            Layout.topMargin: 16
            wrapMode: Text.Wrap
            visible: !fee_error.visible && !hasFunds()

            color: Dex.CurrentTheme.noColor

            text_value: qsTr("Not enough funds.") + "\n" + qsTr("You have %1", "AMT TICKER").arg(General.formatCrypto("", API.app.get_balance(api_wallet_page.ticker), api_wallet_page.ticker))
        }

        DefaultBusyIndicator { visible: root.is_send_busy }

        // Footer
        RowLayout
        {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20

            DefaultButton
            {
                text: qsTr("Close")

                Layout.alignment: Qt.AlignLeft
                Layout.preferredWidth: parent.width / 100 * 48
                Layout.preferredHeight: 48

                label.font.pixelSize: 16
                radius: 18

                onClicked: root.close()
            }

            Item { Layout.fillWidth: true }

            OutlineButton
            {
                enabled: fieldAreFilled() && hasFunds() && !errorView && !root.is_send_busy

                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: parent.width / 100 * 48

                text: qsTr("Prepare")

                onClicked: prepareSendCoin(input_address.text, getCryptoAmount(), custom_fees_switch.checked, input_custom_fees.text,
                                           isSpecialToken(), input_custom_fees_gas.text, input_custom_fees_gas_price.text)
            }
        }

        // Modal to pick up a contact's address.
        ModalLoader
        {
            id: contact_list
            sourceComponent: SendModalContactList
            {
                onClosed:
                {
                    if (selected_address === "") return

                    input_address.text = selected_address
                    selected_address = ""
                    console.debug("SendModal: Selected %1 address from addressbook.".arg(input_address.text))
                }
            }
        }
    }

    // Send Page
    MultipageModalContent
    {
        titleText: qsTr("Send")

        // Address
        TextEditWithTitle
        {
            title: qsTr("Recipient's address")
            text: input_address.text
        }

        // Amount
        TextEditWithTitle
        {
            title: qsTr("Amount")

            text:
            {
                let amount = getCryptoAmount()
                !amount ? "" : General.formatCrypto(
                    '',
                    amount,
                    api_wallet_page.ticker,
                    API.app.get_fiat_from_amount(api_wallet_page.ticker, amount),
                    API.app.settings_pg.current_fiat
                )
            }
        }

        // Fees
        TextEditWithTitle
        {
            title: qsTr("Fees")
            text:
            {
                let amount = send_result.withdraw_answer.fee_details.amount
                !amount ? "" : General.formatCrypto(
                    '',
                    amount,
                    current_ticker_infos.fee_ticker,
                    API.app.get_fiat_from_amount(current_ticker_infos.fee_ticker, amount),
                    API.app.settings_pg.current_fiat
                )
            }
        }

        // Date
        TextEditWithTitle
        {
            title: qsTr("Date")
            text: empty_data ? "" :
                  send_result.withdraw_answer.date
        }

        DefaultBusyIndicator
        {
            visible: root.is_broadcast_busy
        }

        // Buttons
        footer:
        [
            Item
            {
                Layout.fillWidth: true
            },
            DexAppButton
            {
                text: qsTr("Back")
                leftPadding: 40
                rightPadding: 40
                radius: 18
                onClicked: root.currentIndex = 0
                enabled: !root.is_broadcast_busy
            },
            Item
            {
                Layout.fillWidth: true
            },
            DexAppOutlineButton
            {
                text: qsTr("Send")
                onClicked: sendCoin()
                leftPadding: 40
                rightPadding: 40
                radius: 18
                enabled: !root.is_broadcast_busy
            },
            Item
            {
                Layout.fillWidth: true
            }
        ]
    }

    // Result Page
    SendResult
    {
        result: send_result
        address: input_address.text
        tx_hash: broadcast_result
        custom_amount: getCryptoAmount()

        function onClose()
        {
            if (root.segwit) root.segwit_success = true
            root.close()
        }
    }
}
