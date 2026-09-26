import QtQuick
import QtQuick.Effects
import Quickshell
import qs.Commons
import qs.Ui

// Bar icon: left click opens the default agent in Herdr, right click the other
// one. Settings live in the bar's own settings form (manifest schema); bin/omany
// reads them from shell.json on every launch.
Panel {
  id: root
  moduleName: "io.github.aiob3.omany"
  manageIpc: false

  readonly property string pluginDir: (Quickshell.env("HOME") || "") + "/.config/omarchy/plugins/io.github.aiob3.omany"
  readonly property color foreground: bar ? bar.barForeground : Color.foreground

  // Icon: assets/icon-white.svg (Remix Icon exchange-dollar-line, Apache-2.0).

  // Keep the icon in the section picked in its settings; omany-place is a no-op
  // when it is already there.
  readonly property string position: (settings && settings.position) || "center"
  onPositionChanged: Quickshell.execDetached([root.pluginDir + "/bin/omany-place", root.position])
  Component.onCompleted: Quickshell.execDetached([root.pluginDir + "/bin/omany-place", root.position])

  function launch(other) {
    var args = [root.pluginDir + "/bin/omany"]
    if (other) args.push("--other")
    Quickshell.execDetached(args)
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "$"
    onPressed: function(buttonCode) {
      root.launch(buttonCode === Qt.RightButton)
    }

    iconComponent: Component {
      Item {
        // White source tinted with the bar's foreground, so it follows the theme.
        Image {
          id: mark
          anchors.fill: parent
          source: "file://" + root.pluginDir + "/assets/icon-white.svg"
          sourceSize.width: button.opticalSize * 2
          sourceSize.height: button.opticalSize * 2
          fillMode: Image.PreserveAspectFit
          visible: false
        }
        MultiEffect {
          anchors.fill: mark
          source: mark
          colorization: 1.0
          colorizationColor: button.foreground
        }
      }
    }
  }
}
