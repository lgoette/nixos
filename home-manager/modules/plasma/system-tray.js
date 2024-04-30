// Custom script extention to configure the system tray applet
// Created by: @Faupi
// Expanded by: @lgoette

// Subtitutes from Nix
var getSubstitute = (text) => (text.match(/^@.*@$/) ? null : text); // Keep var so it can be redeclared if snippet gets used multiple times
hiddenItems = getSubstitute("@hiddenItems@");
shownItems = getSubstitute("@shownItems@");
extraItems = getSubstitute("@extraItems@");
scaleIconsToFit = getSubstitute("@scaleIconsToFit@");
iconSpacing = getSubstitute("@iconSpacing@");
popupHeight = getSubstitute("@popupHeight@");
popupWidth = getSubstitute("@popupWidth@");

// Find system tray config link in the panel, add the rules to it
var systemtrayId;
for (let i = 0; i < panel.widgetIds.length; i++) {
  appletWidget = panel.widgetById(panel.widgetIds[i]);
  if (appletWidget.type === "org.kde.plasma.systemtray") {
    systemtrayId = appletWidget.readConfig("SystrayContainmentId");
    if (systemtrayId) {
      const systray = desktopById(systemtrayId);
      // General config
      systray.currentConfigGroup = ["General"];
      if (hiddenItems != null)
        systray.writeConfig("hiddenItems", hiddenItems.split(","));
      if (shownItems != null)
        systray.writeConfig("shownItems", shownItems.split(","));
      if (extraItems != null)
        systray.writeConfig("extraItems", extraItems.split(","));
      if (scaleIconsToFit != null)
        systray.writeConfig("scaleIconsToFit", scaleIconsToFit === "true");
      if (iconSpacing != null)
        systray.writeConfig("iconSpacing", iconSpacing);
        
      // Popup dialog config
      systray.currentConfigGroup = this;
      if (popupHeight != null)
        systray.writeConfig("popupHeight", popupHeight);
      if (popupWidth != null)
        systray.writeConfig("popupWidth", popupWidth);
    
      systray.reloadConfig();
      break;
    }
  }
}
