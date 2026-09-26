import Quickshell
import QtQuick

// No UI: summoning the plugin hands off to bin/omany, which opens or focuses
// the Herdr window and starts the default agent there.
Item {
  id: root

  property var shell: null
  property var manifest: null

  readonly property string pluginId: (manifest && manifest.id) || "io.github.aiob3.omany"
  readonly property string pluginDir: manifest && manifest.__sourceDir ? String(manifest.__sourceDir) : (Quickshell.env("HOME") + "/.config/omarchy/plugins/" + pluginId)

  function launch(other) {
    var args = [root.pluginDir + "/bin/omany"]
    if (other) args.push("--other")
    Quickshell.execDetached(args)
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide(root.pluginId)
  }

  // summon payload {"agent":"other"} starts the counterpart of the default agent.
  function open(payloadJson) {
    var other = false
    try { other = JSON.parse(String(payloadJson || "{}")).agent === "other" } catch (e) {}
    root.launch(other)
  }
  function toggle() { root.launch(false) }
  function close() {}
}
