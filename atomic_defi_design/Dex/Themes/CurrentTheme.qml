pragma Singleton

import Dex.Graphics 1.0 as Dex
import "DefaultTheme.js" as DexDefaultTheme

ThemeData
{
    enum ColorMode
    {
        None,
        Light,
        Dark
    }

    readonly property var defaultTheme: DexDefaultTheme.getHardcoded()

    property string _themeName

    signal themeChanged()

    function getColorMode()
    {
        if (_themeName.endsWith(" - Light")) return CurrentTheme.ColorMode.Light;
        if (_themeName.endsWith(" - Dark")) return CurrentTheme.ColorMode.Dark;
        return CurrentTheme.ColorMode.None;
    }

    function hasColorMode(colorMode)
    {
        let currentColorMode = getColorMode();
        let colorModeStr = _themeName;

        if (currentColorMode !== colorMode && colorMode === CurrentTheme.ColorMode.Light)
            colorModeStr = colorModeStr.replace(" - Dark", " - Light");
        else if (currentColorMode !== colorMode && colorMode === CurrentTheme.ColorMode.Dark)
            colorModeStr = colorModeStr.replace(" - Light", " - Dark");

        return DexFilesystem.exists(DexFilesystem.getThemeFolder(colorModeStr))
    }

    function hasDarkAndLightMode() { return hasColorMode(CurrentTheme.ColorMode.Light) && hasColorMode(CurrentTheme.ColorMode.Dark); }

    function switchColorMode()
    {
        let colorMode = getColorMode();
        let current = _themeName
        let currentLabel = current.replace(" - Light", "").replace(" - Dark", "")
        let currentMode = current.replace(" - ", "").replace(currentLabel, "")
        current = currentLabel + " - " + (currentMode === "Dark" ? "Light" : "Dark");
        loadFromFilesystem(current);
        return current
    }

    function loadFromFilesystem(themeName)
    {
        console.info("Dex.Themes.CurrentTheme.loadFromFilesystem: loading %1...".arg(themeName))

        try
        {
            if (!DexFilesystem.exists(DexFilesystem.getThemeFolder(themeName))) throw `${themeName} does not exist in the filesystem.`;

            _themeName = themeName

            let themeData = atomic_qt_utilities.load_theme(themeName);
            loadColors(themeData);
            loadLogo(themeName);

            printCurrentValues();

            themeChanged();

            console.info("Dex.Themes.CurrentTheme.loadFromFilesystem: %1 is loaded".arg(themeName));
        }
        catch (error)
        {
            console.error(`${themeName} is broken: ${error}. Trying to load a default theme.`);
            if (!DexFilesystem.exists(DexFilesystem.getThemeFolder("Default - Light")))
            {
                console.error("Default themes have been moved... Why did you do that ? I need to load an hardcoded one now.")
                loadColors(defaultTheme);
                loadLogo();
                themeChanged();
            }
            else loadFromFilesystem("Default - Light");
        }
    }

    function loadColors(themeData)
    {
        accentColor                         = Dex.Color.argbStrFromRgbaStr(themeData.accentColor || defaultTheme.accentColor);
        foregroundColor                     = Dex.Color.argbStrFromRgbaStr(themeData.foregroundColor || defaultTheme.foregroundColor);
        foregroundColor2                    = Dex.Color.argbStrFromRgbaStr(themeData.foregroundColor2 || defaultTheme.foregroundColor2);
        foregroundColor3                    = Dex.Color.argbStrFromRgbaStr(themeData.foregroundColor3 || defaultTheme.foregroundColor3);
        backgroundColor                     = Dex.Color.argbStrFromRgbaStr(themeData.backgroundColor || defaultTheme.backgroundColor);
        backgroundColorDeep                 = Dex.Color.argbStrFromRgbaStr(themeData.backgroundColorDeep || defaultTheme.backgroundColorDeep);

        buttonColorDisabled                 = Dex.Color.argbStrFromRgbaStr(themeData.buttonColorDisabled || defaultTheme.buttonColorDisabled);
        buttonColorEnabled                  = Dex.Color.argbStrFromRgbaStr(themeData.buttonColorEnabled || defaultTheme.buttonColorEnabled);
        buttonColorHovered                  = Dex.Color.argbStrFromRgbaStr(themeData.buttonColorHovered || defaultTheme.buttonColorHovered);
        buttonColorPressed                  = Dex.Color.argbStrFromRgbaStr(themeData.buttonColorPressed || defaultTheme.buttonColorPressed);
        buttonTextDisabledColor             = Dex.Color.argbStrFromRgbaStr(themeData.buttonTextDisabledColor || defaultTheme.buttonTextDisabledColor);
        buttonTextEnabledColor              = Dex.Color.argbStrFromRgbaStr(themeData.buttonTextEnabledColor || defaultTheme.buttonTextEnabledColor);
        buttonTextHoveredColor              = Dex.Color.argbStrFromRgbaStr(themeData.buttonTextHoveredColor || defaultTheme.buttonTextHoveredColor);
        buttonTextPressedColor              = Dex.Color.argbStrFromRgbaStr(themeData.buttonTextPressedColor || defaultTheme.buttonTextPressedColor);

        gradientButtonStartColor            = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonStartColor || defaultTheme.gradientButtonStartColor);
        gradientButtonEndColor              = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonEndColor || defaultTheme.gradientButtonEndColor);
        gradientButtonDisabledStartColor    = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonDisabledStartColor || defaultTheme.gradientButtonDisabledStartColor);
        gradientButtonDisabledEndColor      = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonDisabledEndColor || defaultTheme.gradientButtonDisabledEndColor);
        gradientButtonHoveredStartColor     = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonHoveredStartColor || defaultTheme.gradientButtonHoveredStartColor);
        gradientButtonHoveredEndColor       = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonHoveredEndColor || defaultTheme.gradientButtonHoveredEndColor);
        gradientButtonPressedStartColor     = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonPressedStartColor || defaultTheme.gradientButtonPressedStartColor);
        gradientButtonPressedEndColor       = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonPressedEndColor || defaultTheme.gradientButtonPressedEndColor);
        gradientButtonTextEnabledColor      = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonTextEnabledColor || defaultTheme.gradientButtonTextEnabledColor);
        gradientButtonTextDisabledColor     = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonTextDisabledColor || defaultTheme.gradientButtonTextDisabledColor);
        gradientButtonTextHoveredColor      = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonTextHoveredColor || defaultTheme.gradientButtonTextHoveredColor);
        gradientButtonTextPressedColor      = Dex.Color.argbStrFromRgbaStr(themeData.gradientButtonTextPressedColor || defaultTheme.gradientButtonTextPressedColor);

        checkBoxGradientStartColor          = Dex.Color.argbStrFromRgbaStr(themeData.checkBoxGradientStartColor || defaultTheme.checkBoxGradientStartColor);
        checkBoxGradientEndColor            = Dex.Color.argbStrFromRgbaStr(themeData.checkBoxGradientEndColor || defaultTheme.checkBoxGradientEndColor);

        switchGradientStartColor            = Dex.Color.argbStrFromRgbaStr(themeData.switchGradientStartColor || defaultTheme.switchGradientStartColor);
        switchGradientEndColor              = Dex.Color.argbStrFromRgbaStr(themeData.switchGradientEndColor || defaultTheme.switchGradientEndColor);
        switchGradientStartColor2           = Dex.Color.argbStrFromRgbaStr(themeData.switchGradientStartColor2 || defaultTheme.switchGradientStartColor2);
        switchGradientEndColor2             = Dex.Color.argbStrFromRgbaStr(themeData.switchGradientEndColor2 || defaultTheme.switchGradientEndColor2);

        comboBoxBackgroundColor                 = Dex.Color.argbStrFromRgbaStr(themeData.comboBoxBackgroundColor || defaultTheme.comboBoxBackgroundColor);
        comboBoxArrowsColor                     = Dex.Color.argbStrFromRgbaStr(themeData.comboBoxArrowsColor || defaultTheme.comboBoxArrowsColor);
        comboBoxDropdownItemHighlightedColor    = Dex.Color.argbStrFromRgbaStr(themeData.comboBoxDropdownItemHighlightedColor || defaultTheme.comboBoxDropdownItemHighlightedColor);

        modalPageCounterGradientStartColor  = Dex.Color.argbStrFromRgbaStr(themeData.modalPageCounterGradientStartColor || defaultTheme.modalPageCounterGradientStartColor);
        modalPageCounterGradientEndColor    = Dex.Color.argbStrFromRgbaStr(themeData.modalPageCounterGradientEndColor || defaultTheme.modalPageCounterGradientEndColor);

        notifPopupBackgroundColor           = Dex.Color.argbStrFromRgbaStr(themeData.notifPopupBackgroundColor || defaultTheme.notifPopupBackgroundColor);
        notifPopupTextColor                 = Dex.Color.argbStrFromRgbaStr(themeData.notifPopupTextColor || defaultTheme.notifPopupTextColor);
        notifPopupTimerColor                = Dex.Color.argbStrFromRgbaStr(themeData.notifPopupTimerColor || defaultTheme.notifPopupTimerColor);
        notifPopupTimerBackgroundColor      = Dex.Color.argbStrFromRgbaStr(themeData.notifPopupTimerBackgroundColor || defaultTheme.notifPopupTimerBackgroundColor);
        notifPopupIconStartColor            = Dex.Color.argbStrFromRgbaStr(themeData.notifPopupIconStartColor || defaultTheme.notifPopupIconStartColor);
        notifPopupIconEndColor              = Dex.Color.argbStrFromRgbaStr(themeData.notifPopupIconEndColor || defaultTheme.notifPopupIconEndColor);

        scrollBarIndicatorColor             = Dex.Color.argbStrFromRgbaStr(themeData.scrollBarIndicatorColor || defaultTheme.scrollBarIndicatorColor);
        scrollBarBackgroundColor            = Dex.Color.argbStrFromRgbaStr(themeData.scrollBarBackgroundColor || defaultTheme.scrollBarBackgroundColor);

        tabSelectedColor                    = Dex.Color.argbStrFromRgbaStr(themeData.tabSelectedColor || defaultTheme.tabSelectedColor);

        textDisabledColor                   = Dex.Color.argbStrFromRgbaStr(themeData.textDisabledColor || defaultTheme.textDisabledColor);
        textSelectionColor                  = Dex.Color.argbStrFromRgbaStr(themeData.textSelectionColor || defaultTheme.textSelectionColor);
        textPlaceholderColor                = Dex.Color.argbStrFromRgbaStr(themeData.textPlaceholderColor || defaultTheme.textPlaceholderColor);
        textSelectedColor                   = Dex.Color.argbStrFromRgbaStr(themeData.textSelectedColor || defaultTheme.textSelectedColor);

        textFieldBackgroundColor            = Dex.Color.argbStrFromRgbaStr(themeData.textFieldBackgroundColor || defaultTheme.textFieldBackgroundColor);
        textFieldActiveBackgroundColor      = Dex.Color.argbStrFromRgbaStr(themeData.textFieldActiveBackgroundColor || defaultTheme.textFieldActiveBackgroundColor);
        textFieldPrefixColor                = Dex.Color.argbStrFromRgbaStr(themeData.textFieldPrefixColor || defaultTheme.textFieldPrefixColor);
        textFieldSuffixColor                = Dex.Color.argbStrFromRgbaStr(themeData.textFieldSuffixColor || defaultTheme.textFieldSuffixColor);

        chartTradingLineBackgroundColor     = Dex.Color.argbStrFromRgbaStr(themeData.chartTradingLineBackgroundColor || defaultTheme.chartTradingLineBackgroundColor);
        chartTradingLineColor               = Dex.Color.argbStrFromRgbaStr(themeData.chartTradingLineColor || defaultTheme.chartTradingLineColor);

        innerBackgroundColor                = Dex.Color.argbStrFromRgbaStr(themeData.innerBackgroundColor || defaultTheme.innerBackgroundColor);

        floatingBackgroundColor             = Dex.Color.argbStrFromRgbaStr(themeData.floatingBackgroundColor || defaultTheme.floatingBackgroundColor);

        rangeSliderBackgroundColor                  = Dex.Color.argbStrFromRgbaStr(themeData.rangeSliderBackgroundColor || defaultTheme.rangeSliderBackgroundColor);
        rangeSliderDistanceColor                    = Dex.Color.argbStrFromRgbaStr(themeData.rangeSliderDistanceColor || defaultTheme.rangeSliderDistanceColor);
        rangeSliderIndicatorBackgroundStartColor    = Dex.Color.argbStrFromRgbaStr(themeData.rangeSliderIndicatorBackgroundStartColor || defaultTheme.rangeSliderIndicatorBackgroundStartColor);
        rangeSliderIndicatorBackgroundEndColor      = Dex.Color.argbStrFromRgbaStr(themeData.rangeSliderIndicatorBackgroundEndColor || defaultTheme.rangeSliderIndicatorBackgroundEndColor);

        loginWalletIconColorStart                   = Dex.Color.argbStrFromRgbaStr(themeData.loginWalletIconColorStart || defaultTheme.loginWalletIconColorStart)
        loginWalletIconColorEnd                     = Dex.Color.argbStrFromRgbaStr(themeData.loginWalletIconColorEnd || defaultTheme.loginWalletIconColorEnd)

        sidebarBgColor                      = Dex.Color.argbStrFromRgbaStr(themeData.sidebarBgColor || defaultTheme.sidebarBgColor);
        sidebarVersionTextColor             = Dex.Color.argbStrFromRgbaStr(themeData.sidebarVersionTextColor || defaultTheme.sidebarVersionTextColor);
        sidebarCursorStartColor             = Dex.Color.argbStrFromRgbaStr(themeData.sidebarCursorStartColor || defaultTheme.sidebarCursorStartColor);
        sidebarCursorEndColor               = Dex.Color.argbStrFromRgbaStr(themeData.sidebarCursorEndColor || defaultTheme.sidebarCursorEndColor);
        sidebarLineTextHovered              = Dex.Color.argbStrFromRgbaStr(themeData.sidebarLineTextHovered || defaultTheme.sidebarLineTextHovered);
        sidebarLineTextSelected             = Dex.Color.argbStrFromRgbaStr(themeData.sidebarLineTextSelected || defaultTheme.sidebarLineTextSelected);

        tradeBuyModeSelectorBackgroundColorStart            = Dex.Color.argbStrFromRgbaStr(themeData.tradeBuyModeSelectorBackgroundColorStart || defaultTheme.tradeBuyModeSelectorBackgroundColorStart);
        tradeBuyModeSelectorBackgroundColorEnd              = Dex.Color.argbStrFromRgbaStr(themeData.tradeBuyModeSelectorBackgroundColorEnd || defaultTheme.tradeBuyModeSelectorBackgroundColorEnd);
        tradeSellModeSelectorBackgroundColorStart           = Dex.Color.argbStrFromRgbaStr(themeData.tradeSellModeSelectorBackgroundColorStart || defaultTheme.tradeSellModeSelectorBackgroundColorStart);
        tradeSellModeSelectorBackgroundColorEnd             = Dex.Color.argbStrFromRgbaStr(themeData.tradeSellModeSelectorBackgroundColorEnd || defaultTheme.tradeSellModeSelectorBackgroundColorEnd);
        tradeMarketModeSelectorNotSelectedBackgroundColor   = Dex.Color.argbStrFromRgbaStr(themeData.tradeMarketModeSelectorNotSelectedBackgroundColor || defaultTheme.tradeMarketModeSelectorNotSelectedBackgroundColor);

        okColor                             = Dex.Color.argbStrFromRgbaStr(themeData.okColor || defaultTheme.okColor);
        noColor                             = Dex.Color.argbStrFromRgbaStr(themeData.noColor || defaultTheme.noColor);

        arrowUpColor                        = Dex.Color.argbStrFromRgbaStr(themeData.arrowUpColor || defaultTheme.arrowUpColor);
        arrowDownColor                      = Dex.Color.argbStrFromRgbaStr(themeData.arrowDownColor || defaultTheme.arrowDownColor);

        lineSeparatorColor                  = Dex.Color.argbStrFromRgbaStr(themeData.lineSeparatorColor || defaultTheme.lineSeparatorColor);
    }

    function loadLogo(themeName)
    {
        let themePath   = DexFilesystem.getThemeFolder(themeName);
        let _logoPath    = `${themePath}/dex-logo.png`;
        let _bigLogoPath = `${themePath}/dex-logo-big.png`;

        logoPath    = DexFilesystem.exists(_logoPath) ? `file:///${_logoPath}` : "qrc:///assets/images/logo/dex-logo.png";
        bigLogoPath = DexFilesystem.exists(_bigLogoPath) ? `file:///${_bigLogoPath}` : "qrc:///assets/images/dex-logo-big.png";
    }

    // Prints current loaded theme values.
    function printCurrentValues()
    {
        console.info("Dex.Themes.CurrentTheme.printValues.accentColor : %1".arg(accentColor));
        console.info("Dex.Themes.CurrentTheme.printValues.foregroundColor : %1".arg(foregroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.backgroundColor : %1".arg(backgroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.backgroundColorDeep : %1".arg(backgroundColorDeep));

        console.info("Dex.Themes.CurrentTheme.printValues.buttonColorDisabled : %1".arg(buttonColorDisabled));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonColorEnabled : %1".arg(buttonColorEnabled));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonColorHovered : %1".arg(buttonColorHovered));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonColorPressed : %1".arg(buttonColorPressed));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonTextDisabledColor : %1".arg(buttonTextDisabledColor));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonTextEnabledColor : %1".arg(buttonTextEnabledColor));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonTextHoveredColor : %1".arg(buttonTextHoveredColor));
        console.info("Dex.Themes.CurrentTheme.printValues.buttonTextPressedColor : %1".arg(buttonTextPressedColor));

        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonStartColor : %1".arg(gradientButtonStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonEndColor : %1".arg(gradientButtonEndColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonDisabledStartColor : %1".arg(gradientButtonDisabledStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonDisabledEndColor : %1".arg(gradientButtonDisabledEndColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonHoveredStartColor : %1".arg(gradientButtonHoveredStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonHoveredEndColor : %1".arg(gradientButtonHoveredEndColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonPressedStartColor : %1".arg(gradientButtonPressedStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonPressedEndColor : %1".arg(gradientButtonPressedEndColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonTextEnabledColor : %1".arg(gradientButtonTextEnabledColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonTextDisabledColor : %1".arg(gradientButtonTextDisabledColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonTextHoveredColor : %1".arg(gradientButtonTextHoveredColor));
        console.info("Dex.Themes.CurrentTheme.printValues.gradientButtonTextPressedColor : %1".arg(gradientButtonTextPressedColor));

        console.info("Dex.Themes.CurrentTheme.printValues.checkBoxGradientStartColor : %1".arg(checkBoxGradientStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.checkBoxGradientEndColor : %1".arg(checkBoxGradientEndColor));

        console.info("Dex.Themes.CurrentTheme.printValues.switchGradientStartColor : %1".arg(switchGradientStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.switchGradientEndColor : %1".arg(switchGradientEndColor));
        console.info("Dex.Themes.CurrentTheme.printValues.switchGradientStartColor2 : %1".arg(switchGradientStartColor2));
        console.info("Dex.Themes.CurrentTheme.printValues.switchGradientEndColor2 : %1".arg(switchGradientEndColor2));

        console.info("Dex.Themes.CurrentTheme.printValues.comboBoxBackgroundColor : %1".arg(comboBoxBackgroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.comboBoxArrowsColor : %1".arg(comboBoxArrowsColor));
        console.info("Dex.Themes.CurrentTheme.printValues.comboBoxDropdownItemHighlightedColor : %1".arg(comboBoxDropdownItemHighlightedColor));

        console.info("Dex.Themes.CurrentTheme.printValues.modalPageCounterGradientStartColor : %1".arg(modalPageCounterGradientStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.modalPageCounterGradientEndColor : %1".arg(modalPageCounterGradientEndColor));

        console.info("Dex.Themes.CurrentTheme.printValues.notifPopupBackgroundColor : %1".arg(notifPopupBackgroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.notifPopupTextColor : %1".arg(notifPopupTextColor));
        console.info("Dex.Themes.CurrentTheme.printValues.notifPopupTimerColor : %1".arg(notifPopupTimerColor));
        console.info("Dex.Themes.CurrentTheme.printValues.notifPopupTimerBackgroundColor : %1".arg(notifPopupTimerBackgroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.notifPopupIconStartColor : %1".arg(notifPopupIconStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.notifPopupIconEndColor : %1".arg(notifPopupIconEndColor));

        console.info("Dex.Themes.CurrentTheme.printValues.scrollBarIndicatorColor : %1".arg(scrollBarIndicatorColor));
        console.info("Dex.Themes.CurrentTheme.printValues.scrollBarBackgroundColor : %1".arg(scrollBarBackgroundColor));

        console.info("Dex.Themes.CurrentTheme.printValues.tabSelectedColor : %1".arg(tabSelectedColor));

        console.info("Dex.Themes.CurrentTheme.printValues.textSelectionColor : %1".arg(textSelectionColor));
        console.info("Dex.Themes.CurrentTheme.printValues.textPlaceholderColor : %1".arg(textPlaceholderColor));
        console.info("Dex.Themes.CurrentTheme.printValues.textSelectedColor : %1".arg(textSelectedColor));

        console.info("Dex.Themes.CurrentTheme.printValues.textFieldActiveBackgroundColor : %1".arg(textFieldActiveBackgroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.textFieldBackgroundColor : %1".arg(textFieldBackgroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.textFieldPrefixColor : %1".arg(textFieldPrefixColor));
        console.info("Dex.Themes.CurrentTheme.printValues.textFieldSuffixColor : %1".arg(textFieldSuffixColor));

        console.info("Dex.Themes.CurrentTheme.printValues.chartTradingLineBackgroundColor : %1".arg(chartTradingLineBackgroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.chartTradingLineColor : %1".arg(chartTradingLineColor));

        console.info("Dex.Themes.CurrentTheme.printValues.innerBackgroundColor : %1".arg(innerBackgroundColor));

        console.info("Dex.Themes.CurrentTheme.printValues.floatingBackgroundColor : %1".arg(floatingBackgroundColor));

        console.info("Dex.Themes.CurrentTheme.printValues.rangeSliderBackgroundColor : %1".arg(rangeSliderBackgroundColor));
        console.info("Dex.Themes.CurrentTheme.printValues.rangeSliderDistanceColor : %1".arg(rangeSliderDistanceColor));
        console.info("Dex.Themes.CurrentTheme.printValues.rangeSliderIndicatorBackgroundStartColor : %1".arg(rangeSliderIndicatorBackgroundStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.rangeSliderIndicatorBackgroundEndColor : %1".arg(rangeSliderIndicatorBackgroundEndColor));

        console.info("Dex.Themes.CurrentTheme.printValues.loginWalletIconColorStart : %1".arg(loginWalletIconColorStart));
        console.info("Dex.Themes.CurrentTheme.printValues.loginWalletIconColorEnd : %1".arg(loginWalletIconColorEnd));

        console.info("Dex.Themes.CurrentTheme.printValues.sidebarBgColor : %1".arg(sidebarBgColor));
        console.info("Dex.Themes.CurrentTheme.printValues.sidebarVersionTextColor : %1".arg(sidebarVersionTextColor));
        console.info("Dex.Themes.CurrentTheme.printValues.sidebarCursorStartColor : %1".arg(sidebarCursorStartColor));
        console.info("Dex.Themes.CurrentTheme.printValues.sidebarCursorEndColor : %1".arg(sidebarCursorEndColor));
        console.info("Dex.Themes.CurrentTheme.printValues.sidebarLineTextHovered : %1".arg(sidebarLineTextHovered));
        console.info("Dex.Themes.CurrentTheme.printValues.sidebarLineTextSelected : %1".arg(sidebarLineTextSelected));

        console.info("Dex.Themes.CurrentTheme.printValues.tradeBuyModeSelectorBackgroundColorStart : %1".arg(tradeBuyModeSelectorBackgroundColorStart));
        console.info("Dex.Themes.CurrentTheme.printValues.tradeBuyModeSelectorBackgroundColorEnd : %1".arg(tradeBuyModeSelectorBackgroundColorEnd));
        console.info("Dex.Themes.CurrentTheme.printValues.tradeSellModeSelectorBackgroundColorStart : %1".arg(tradeSellModeSelectorBackgroundColorStart));
        console.info("Dex.Themes.CurrentTheme.printValues.tradeSellModeSelectorBackgroundColorEnd : %1".arg(tradeSellModeSelectorBackgroundColorEnd));
        console.info("Dex.Themes.CurrentTheme.printValues.tradeMarketModeSelectorNotSelectedBackgroundColor : %1".arg(tradeMarketModeSelectorNotSelectedBackgroundColor));

        console.info("Dex.Themes.CurrentTheme.printValues.okColor : %1".arg(okColor));
        console.info("Dex.Themes.CurrentTheme.printValues.noColor : %1".arg(noColor));

        console.info("Dex.Themes.CurrentTheme.printValues.arrowUpColor : %1".arg(arrowUpColor));
        console.info("Dex.Themes.CurrentTheme.printValues.arrowDownColor : %1".arg(arrowDownColor));

        console.info("Dex.Themes.CurrentTheme.printValues.lineSeparatorColor : %1".arg(lineSeparatorColor));

        console.info("Dex.Themes.CurrentTheme.printValues.logoPath : %1".arg(logoPath));
        console.info("Dex.Themes.CurrentTheme.printValues.bigLogoPath : %1".arg(bigLogoPath));
    }
}
