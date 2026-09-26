import QtQuick
import QtQuick.Effects
import Quickshell
import qs.Commons
import qs.Ui

// Bar icon: left click opens the default agent in Herdr, right click the other
// one. Settings live in the bar's own settings form (manifest schema); bin/omany
// reads them from shell.json on every launch.
BarWidget {
  id: root
  moduleName: "io.github.aiob3.omany"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property string pluginDir: (Quickshell.env("HOME") || "") + "/.config/omarchy/plugins/io.github.aiob3.omany"
  readonly property color foreground: bar ? bar.barForeground : Color.foreground

  // Icon: assets/icon-white.svg (Remix Icon exchange-dollar-line, Apache-2.0).

  // The first load puts the icon right after the clock, once. After that it only
  // moves when Position changes in its settings, so moving it by hand (or with
  // Omaplug) sticks.
  readonly property string position: (settings && settings.position) || ""
  onPositionChanged: if (position) Quickshell.execDetached([root.pluginDir + "/bin/omany-place", position])
  Component.onCompleted: Quickshell.execDetached([root.pluginDir + "/bin/omany-place", "--first-run"])

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
    tooltipText: "omany: click for your agent, right-click for the other one"
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
