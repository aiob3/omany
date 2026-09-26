import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Bar icon + panel: the four slots (A default, Z other, S and X free), agents
// running in the Herdr workspace, installed agents, and settings. Launching and
// focusing go through bin/omany; the snapshot comes from bin/omany-state.
Panel {
  id: root
  moduleName: "io.github.aiob3.omany"
  manageIpc: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property string pluginDir: (Quickshell.env("HOME") || "") + "/.config/omarchy/plugins/io.github.aiob3.omany"
  readonly property color foreground: bar ? bar.barForeground : Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.4)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string iconUrl: "file://" + pluginDir + "/assets/icon-white.svg"

  property var st: ({ default: "", other: "", slots: { s: "", x: "" }, agents: [], online: false,
                      running: [], settings: { workspace: "", cwd: "", loadSkill: true, position: "center" } })
  property bool showSettings: false

  readonly property var installedNames: namesWithState("installed")
  readonly property var installerNames: namesWithState("installer")

  function namesWithState(state) {
    var out = []
    var list = st.agents || []
    for (var i = 0; i < list.length; i++) if (list[i].state === state) out.push(list[i].name)
    return out
  }

  // The first load puts the icon right after the clock, once. After that it only
  // moves when Position changes, so moving it by hand (or with Omaplug) sticks.
  readonly property string position: (settings && settings.position) || ""
  onPositionChanged: if (position) Quickshell.execDetached([root.pluginDir + "/bin/omany-place", position])
  Component.onCompleted: Quickshell.execDetached([root.pluginDir + "/bin/omany-place", "--first-run"])

  function refresh() { if (!stateProcess.running) stateProcess.running = true }

  function run(args) {
    Quickshell.execDetached([root.pluginDir + "/bin/omany"].concat(args || []))
    root.close()
  }

  function setOption(key, value, json) {
    var cmd = ["omarchy", "bar", "set", root.moduleName, key, String(value)]
    if (json) cmd.push("--json")
    Quickshell.execDetached(cmd)
    refreshTimer.restart()
  }

  onOpenedChanged: if (opened) {
    refresh()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  Process {
    id: stateProcess
    command: [root.pluginDir + "/bin/omany-state"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try { root.st = JSON.parse(String(text || "{}")) } catch (e) { console.warn("omany: invalid state", e) }
      }
    }
  }

  // Keeps "Running now" current while the panel is open.
  Timer { interval: 3000; running: root.opened; repeat: true; onTriggered: root.refresh() }
  Timer { id: refreshTimer; interval: 600; onTriggered: root.refresh() }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "$"
    tooltipText: root.opened ? "" : "omany"
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.LeftButton) root.toggle()
    }
    iconComponent: Component { Mark { size: button.opticalSize; tint: button.foreground } }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(430))
    contentHeight: panel.fittedContentHeight(contentColumn.implicitHeight, Style.space(680))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: contentColumn
          width: parent.width
          spacing: Style.space(12)

          PanelHero {
            width: parent.width
            title: "omany"
            meta: root.st.online ? "AGENTS IN HERDR" : "HERDR NOT RUNNING"
            detail: (root.st.running || []).length + " running"
            foreground: root.foreground
            fontFamily: root.fontFamily
            iconComponent: Component { Mark { size: Style.font.display; tint: root.foreground } }
          }

          PanelSeparator { foreground: root.foreground }

          PanelSectionHeader {
            width: parent.width
            text: "OPEN IN HERDR"
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          SlotRow { width: parent.width; keyName: "A"; agent: root.st.default || ""; note: "Omarchy default"; runArgs: [] }
          SlotRow { width: parent.width; keyName: "Z"; agent: root.st.other || ""; note: "other agent"; runArgs: ["--other"] }
          SlotRow { width: parent.width; keyName: "S"; agent: root.st.slots ? root.st.slots.s : ""; slotKey: "slotS"; runArgs: ["--slot", "s"] }
          SlotRow { width: parent.width; keyName: "X"; agent: root.st.slots ? root.st.slots.x : ""; slotKey: "slotX"; runArgs: ["--slot", "x"] }

          PanelSeparator { foreground: root.foreground }

          PanelSectionHeader {
            width: parent.width
            text: "RUNNING NOW  ·  " + (root.st.settings ? root.st.settings.workspace : "")
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          Text {
            visible: (root.st.running || []).length === 0
            width: parent.width
            text: root.st.online ? "No agents in this workspace yet." : "Herdr is not running."
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
          }

          Repeater {
            model: root.st.running || []
            Item {
              required property var modelData
              width: contentColumn.width
              implicitHeight: Math.max(runName.implicitHeight, focusButton.implicitHeight)
              height: implicitHeight
              Text {
                id: runName
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "●  " + modelData.name
                color: modelData.status === "working" ? Color.accent : (modelData.status === "blocked" ? Color.urgent : root.foreground)
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
              }
              Text {
                anchors.right: focusButton.left
                anchors.rightMargin: Style.space(10)
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.status
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }
              Button {
                id: focusButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "Focus"
                foreground: root.foreground
                fontFamily: root.fontFamily
                bordered: true
                onClicked: root.run(["--focus", modelData.target || modelData.name])
              }
            }
          }

          PanelSeparator { foreground: root.foreground }

          PanelSectionHeader {
            width: parent.width
            text: "INSTALLED AGENTS"
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: root.installedNames.join("  ·  ")
              + (root.installerNames.length ? "\nInstall on first use: " + root.installerNames.join(", ") : "")
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            lineHeight: 1.3
          }

          PanelSeparator { foreground: root.foreground }

          Button {
            width: parent.width
            text: root.showSettings ? "Hide settings" : "Settings"
            iconText: "󰒓"
            foreground: root.foreground
            fontFamily: root.fontFamily
            bordered: true
            onClicked: root.showSettings = !root.showSettings
          }

          Column {
            visible: root.showSettings
            width: parent.width
            spacing: Style.space(10)

            SettingRow {
              label: "Position"
              Dropdown {
                width: Style.spacing.dropdownWidth
                showLabel: false
                fontFamily: root.fontFamily
                options: ["center", "left", "right"]
                value: root.st.settings ? root.st.settings.position : "center"
                onChanged: function(v) { root.setOption("position", v) }
              }
            }
            SettingRow {
              label: "Other agent (Z)"
              Dropdown {
                width: Style.spacing.dropdownWidth
                showLabel: false
                fontFamily: root.fontFamily
                options: ["auto"].concat(root.installedNames)
                value: (root.settings && root.settings.otherAgent) || "auto"
                onChanged: function(v) { root.setOption("otherAgent", v) }
              }
            }
            SettingRow {
              label: "Herdr workspace"
              TextField {
                width: Style.spacing.dropdownWidth
                text: root.st.settings ? root.st.settings.workspace : ""
                foreground: root.foreground
                onEditingFinished: if (root.st.settings && text !== root.st.settings.workspace) root.setOption("workspace", text)
              }
            }
            SettingRow {
              label: "Working folder"
              TextField {
                width: Style.spacing.dropdownWidth
                text: root.st.settings ? root.st.settings.cwd : ""
                placeholderText: "same as omarchy agent"
                foreground: root.foreground
                onEditingFinished: if (root.st.settings && text !== root.st.settings.cwd) root.setOption("cwd", text)
              }
            }
            SettingRow {
              label: "Load the Omarchy skill"
              ToggleSwitch {
                checked: root.st.settings ? root.st.settings.loadSkill : true
                foreground: root.foreground
                // Controlled switch: `checked` still holds the old value here.
                onToggled: root.setOption("loadSkill", checked ? "false" : "true", true)
              }
            }
          }
        }
      }
    }
  }

  // Icon: assets/icon-white.svg (Remix Icon exchange-dollar-line, Apache-2.0),
  // tinted so it follows the theme.
  component Mark: Item {
    id: mark
    property real size: 16
    property color tint: root.foreground
    width: size
    height: size
    Image {
      id: markImage
      anchors.fill: parent
      source: root.iconUrl
      sourceSize.width: mark.size * 2
      sourceSize.height: mark.size * 2
      fillMode: Image.PreserveAspectFit
      visible: false
    }
    MultiEffect {
      anchors.fill: markImage
      source: markImage
      colorization: 1.0
      colorizationColor: mark.tint
    }
  }

  // One slot: key, agent, and an Open button. S and X pick their agent right here.
  component SlotRow: Item {
    id: slot
    property string keyName: ""
    property string agent: ""
    property string note: ""
    property string slotKey: ""
    property var runArgs: []
    implicitHeight: Math.max(keyLabel.implicitHeight, runButton.implicitHeight, picker.visible ? picker.implicitHeight : 0)
    height: implicitHeight

    Text {
      id: keyLabel
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      width: Style.space(28)
      text: slot.keyName
      color: Color.accent
      font.family: root.fontFamily
      font.pixelSize: Style.font.subtitle
      font.bold: true
    }
    Text {
      visible: !slot.slotKey
      anchors.left: keyLabel.right
      anchors.verticalCenter: parent.verticalCenter
      text: (slot.agent || "—") + (slot.note ? "   " + slot.note : "")
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
    }
    Dropdown {
      id: picker
      visible: !!slot.slotKey
      anchors.left: keyLabel.right
      anchors.verticalCenter: parent.verticalCenter
      width: Style.spacing.dropdownWidth
      showLabel: false
      fontFamily: root.fontFamily
      options: ["none"].concat(root.installedNames)
      value: slot.agent || "none"
      onChanged: function(v) { root.setOption(slot.slotKey, v) }
    }
    Button {
      id: runButton
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      iconText: "󰐊"
      text: "Open"
      foreground: root.foreground
      fontFamily: root.fontFamily
      bordered: true
      enabled: !!slot.agent
      opacity: enabled ? 1 : 0.4
      onClicked: root.run(slot.runArgs)
    }
  }

  component SettingRow: Item {
    id: settingRow
    property string label: ""
    default property alias control: holder.data
    width: parent ? parent.width : 0
    implicitHeight: Math.max(settingLabel.implicitHeight, holder.height)
    height: implicitHeight
    Text {
      id: settingLabel
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: settingRow.label
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
    }
    Item {
      id: holder
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      width: childrenRect.width
      height: childrenRect.height
    }
  }
}
