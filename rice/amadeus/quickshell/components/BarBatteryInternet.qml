import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.configuration

Rectangle {
  Layout.alignment: Qt.AlignVCenter
  Layout.preferredWidth: 56
  Layout.preferredHeight: 24
  radius: 3
  color: hoverHandler.hovered ? Colors.moduleBackgroundHover : Colors.moduleBackground
  border.width: 1
  border.color: hoverHandler.hovered ? Colors.moduleBorderHover : Colors.moduleBorder

  HoverHandler { id: hoverHandler }

  property real batteryLevel: 100
  property bool internetConnected: false

  function getBatteryColor(percent) {
    if (percent >= 50) return Colors.batteryHealthy
    if (percent >= 30) return Colors.batteryMedium
    return Colors.batteryLow
  }

  Process {
    id: batteryProcess
    running: true
    // Prefer BAT0, fall back to BAT1 / capacity files
    command: ["sh", "-c", "for b in /sys/class/power_supply/BAT*/capacity; do [ -r \"$b\" ] && cat \"$b\" && exit 0; done; echo 100"]
    stdout: SplitParser {
      onRead: percent => {
        const n = parseInt(percent.trim())
        if (!isNaN(n)) batteryLevel = n
      }
    }
  }

  Process {
    id: internetProcess
    running: true
    command: ["ping", "-c1", "-W2", "1.1.1.1"]
    property string fullOutput: ""
    stdout: SplitParser {
      onRead: out => { fullOutput += out + "\n" }
    }
    onExited: code => {
      internetConnected = (code === 0)
      fullOutput = ""
    }
  }

  Timer {
    interval: 10000
    running: true
    repeat: true
    onTriggered: {
      batteryProcess.running = true
      internetProcess.running = true
    }
  }

  RowLayout {
    anchors.centerIn: parent
    spacing: 4

    // Mini battery glyph
    Rectangle {
      Layout.preferredWidth: 18
      Layout.preferredHeight: 10
      radius: 1
      color: Colors.batteryBackground
      border.color: getBatteryColor(batteryLevel)
      border.width: 1

      Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 2
        width: Math.max(0, (parent.width - 5) * (batteryLevel / 100))
        height: parent.height - 4
        radius: 0.5
        color: getBatteryColor(batteryLevel)
      }
    }

    Image {
      Layout.preferredWidth: 14
      Layout.preferredHeight: 14
      source: Quickshell.shellPath("svg/" + (internetConnected ? "connected" : "disconnected") + ".svg")
      sourceSize.width: 20
      sourceSize.height: 20
    }
  }

  // Click: open nmtui/network — use niri spawn of nm-connection-editor if present
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      Quickshell.execDetached(["sh", "-c", "command -v nm-connection-editor >/dev/null && nm-connection-editor || true"])
      batteryProcess.running = true
      internetProcess.running = true
    }
  }
}
