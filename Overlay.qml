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

  // extra: [] for the default agent, ["--other"] or ["--slot", "s"|"x"].
  function launch(extra) {
    var args = [root.pluginDir + "/bin/omany"].concat(extra || [])
    Quickshell.execDetached(args)
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide(root.pluginId)
  }

  // summon payloads: {"agent":"other"} starts the counterpart of the default
  // agent; {"slot":"s"} or {"slot":"x"} starts the agent assigned to that slot;
  // {"agent":"<name>"} starts that agent, so any key can open any agent.
  function open(payloadJson) {
    var data = {}
    try { data = JSON.parse(String(payloadJson || "{}")) || {} } catch (e) {}
    if (data.slot === "s" || data.slot === "x") root.launch(["--slot", data.slot])
    else if (data.agent === "other") root.launch(["--other"])
    else if (typeof data.agent === "string" && /^[a-z][a-z0-9-]*$/.test(data.agent)) root.launch(["--agent", data.agent])
    else root.launch([])
  }
  function toggle() { root.launch([]) }
  function close() {}
}
