import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.chip-davis.omabongo"

  property bool permissionError: false
  property bool sawAnyOutput: false
  property bool leftPaw: false

  // "up" | "left" | "right" | "sleeping"
  property string pose: "up"


  property bool tooltipHovered: false
  property real spriteScale: 2.2
  property real sleepAfterMs: 20000
  property real tapDurationMs: 110
  property real upDurationMs: 60
  property bool sleepEnabled: true
  property bool alternatePaws: false

  FileView {
    id: configFile
    path: Quickshell.env("HOME") + "/.config/omabongo/config.json"
    watchChanges: true      // live-reload when you hand-edit the file
    printErrors: false      // suppress the "file doesn't exist" spam on first run
    onLoaded: root.applyConfig(text())
    onLoadFailed: function(error) { root.applyConfig("") }   // missing file → defaults
    onFileChanged: reload()  // watchChanges fires this; triggers onLoaded again
  }

  function applyConfig(raw) {
    var text = String(raw || "").trim()
    var parsed = {}
    if (text) {
      try {
        parsed = JSON.parse(text)
      } catch (e) {
        console.warn("omabongo config.json parse failed, using defaults:", e)
        parsed = {}
      }
    }
    root.spriteScale = (typeof parsed.scale === "number") ? parsed.scale : 2.2
    root.sleepAfterMs = (typeof parsed.sleepAfterMs === "number") ? parsed.sleepAfterMs : 20000
    root.tapDurationMs = (typeof parsed.tapDurationMs === "number") ? parsed.tapDurationMs : 110
    root.upDurationMs = (typeof parsed.upDurationMs === "number") ? parsed.upDurationMs : 60
    root.sleepEnabled = (typeof parsed.sleepEnabled === "boolean") ? parsed.sleepEnabled : true
    root.alternatePaws = (typeof parsed.alternatePaws === "boolean") ? parsed.alternatePaws : false
  }

  function assetFor(p) {
    switch (p) {
      case "left": return "assets/bongo-left-down.svg"
      case "right": return "assets/bongo-right-down.svg"
      case "sleeping": return "assets/bongo-sleeping.svg"
      default: return "assets/bongo-both-up.svg"
    }
  }

  property string pendingPose: "up"

  function onKeyTap() {
    sleepTimer.restart()
    tapReleaseTimer.stop()
    leftPaw = root.alternatePaws ? !leftPaw : (Math.random() < 0.5)
    pendingPose = leftPaw ? "left" : "right"
    pose = "up"          // always pass through "up" so repeated same-side taps still pulse
    pawDownTimer.restart()
  }

  // Bar.qml doesn't clip widget slots, so we can size the sprite well past
  // the strip's own height (barSize is only ~26px by default) and let it
  // overflow above/below — reads much better than a cramped icon-sized cat.
  readonly property real spriteSize: barSize * root.spriteScale

  implicitWidth: spriteSize
  implicitHeight: barSize

  Image {
    id: sprite
    anchors.centerIn: parent
    width: root.spriteSize
    height: root.spriteSize
    source: root.assetFor(root.pose)
    fillMode: Image.PreserveAspectFit
    sourceSize.width: root.spriteSize
    sourceSize.height: root.spriteSize
    smooth: true
  }

  Text {
    anchors.right: sprite.right
    anchors.bottom: sprite.bottom
    text: "⚠"
    visible: root.permissionError
    font.pixelSize: Style.font.caption
    color: "#ffb454"
  }


  Timer {
    id: pawDownTimer
    interval: root.upDurationMs
    onTriggered: {
      root.pose = root.pendingPose
      tapReleaseTimer.restart()
    }
  }

  Timer {
    id: tapReleaseTimer
    interval: root.tapDurationMs
    onTriggered: if (root.pose !== "sleeping") root.pose = "up"
  }

  Timer {
    id: sleepTimer
    interval: root.sleepAfterMs
    running: true
    onTriggered: if (root.sleepEnabled) root.pose = "sleeping"
  }

  Process {
    id: inputProc
    command: ["libinput", "debug-events"]
    running: true

    stdout: SplitParser {
      splitMarker: "\n"
      onRead: function(line) {
        root.sawAnyOutput = true
        if (line.indexOf("KEYBOARD_KEY") !== -1 && line.indexOf("pressed") !== -1) {
          root.onKeyTap()
        }
      }
    }

    onExited: function(exitCode) {
      root.permissionError = true
    }
  }

  Timer {
    interval: 4000
    running: true
    onTriggered: {
      if (!root.sawAnyOutput) root.permissionError = true
    }
  }

  MouseArea {
    anchors.fill: sprite
    hoverEnabled: true
    onEntered: {
      root.tooltipHovered = true
      if (!root.bar) return
      root.bar.showTooltip(root, root.permissionError
        ? "Bongo Cat: add yourself to the 'input' group (sudo usermod -aG input $USER, then log out/in) to enable key detection"
        : "Bongo Cat")
    }
    onExited: {
      root.tooltipHovered = false
      if (root.bar) root.bar.hideTooltip(root)
    }
  }
}
