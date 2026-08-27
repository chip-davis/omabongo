import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "dev.omabongo.bongocat"

  property bool permissionError: false
  property bool sawAnyOutput: false
  property bool lastPawWasLeft: false

  // "up" | "left" | "right" | "sleeping"
  property string pose: "up"


  property bool tooltipHovered: false

  function assetFor(p) {
    switch (p) {
      case "left": return "assets/bongo-left-down.svg"
      case "right": return "assets/bongo-right-down.svg"
      case "sleeping": return "assets/bongo-sleeping.svg"
      default: return "assets/bongo-both-up.svg"
    }
  }

  function onKeyTap() {
    sleepTimer.restart()
    lastPawWasLeft = !lastPawWasLeft
    pose = lastPawWasLeft ? "left" : "right"
    tapReleaseTimer.restart()
  }

  implicitWidth: barSize
  implicitHeight: barSize

  Image {
    id: sprite
    anchors.fill: parent
    anchors.margins: Style.space(2)
    source: root.assetFor(root.pose)
    fillMode: Image.PreserveAspectFit
    sourceSize.width: root.barSize
    sourceSize.height: root.barSize
    smooth: true
  }

  Text {
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    text: "⚠"
    visible: root.permissionError
    font.pixelSize: Style.font.caption
    color: "#ffb454"
  }


  Timer {
    id: tapReleaseTimer
    interval: 110
    onTriggered: if (root.pose !== "sleeping") root.pose = "up"
  }

  Timer {
    id: sleepTimer
    interval: 20000
    running: true
    onTriggered: root.pose = "sleeping"
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
    anchors.fill: parent
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
