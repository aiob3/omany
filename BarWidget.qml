import QtQuick
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

  // assets/icon.svg (Remix Icon exchange-dollar-line, Apache-2.0), inlined so it
  // follows the theme's foreground color.
  readonly property string iconPath: "M19.379 15.106A8.001 8.001 0 0 0 8.035 5.056l-.993-1.737a10 10 0 0 1 9.962.023c4.49 2.593 6.21 8.143 4.118 12.77l1.342.775l-4.166 2.214l-.165-4.714zM4.629 8.9a8.001 8.001 0 0 0 11.345 10.05l.992 1.737a10 10 0 0 1-9.962-.024c-4.49-2.593-6.21-8.142-4.117-12.77L1.545 7.12L5.71 4.905l.165 4.714zm3.875 5.103h5.5a.5.5 0 1 0 0-1h-4a2.5 2.5 0 0 1 0-5h1v-1h2v1h2.5v2h-5.5a.5.5 0 0 0 0 1h4a2.5 2.5 0 0 1 0 5h-1v1h-2v-1h-2.5z"

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
      Image {
        width: button.opticalSize
        height: button.opticalSize
        sourceSize.width: button.opticalSize * 2
        sourceSize.height: button.opticalSize * 2
        fillMode: Image.PreserveAspectFit
        source: "data:image/svg+xml;utf8," + encodeURIComponent(
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="'
          + button.foreground + '" d="' + root.iconPath + '"/></svg>')
      }
    }
  }
}
