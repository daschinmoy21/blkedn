import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.configuration

Rectangle {
  Layout.alignment: Qt.AlignVCenter
  Layout.preferredWidth: Math.max(36, weatherText.implicitWidth + 28)
  Layout.preferredHeight: 24
  radius: 3
  color: hoverHandler.hovered ? Colors.weatherBackgroundHover : Colors.weatherBackground
  border.width: 1
  border.color: hoverHandler.hovered ? Colors.weatherBorderHover : Colors.moduleBorder

  HoverHandler { id: hoverHandler }

  property string temperature: "…"

  Process {
    id: weatherProcess
    running: true
    command: ["curl", "-s", "--max-time", "5", "https://wttr.in/?format=%t"]
    stdout: SplitParser {
      onRead: t => {
        if (t && t.trim() !== "")
          temperature = t.trim()
      }
    }
  }

  Timer {
    interval: 600000
    running: true
    repeat: true
    onTriggered: weatherProcess.running = true
  }

  RowLayout {
    anchors.centerIn: parent
    spacing: 3

    Image {
      Layout.preferredWidth: 14
      Layout.preferredHeight: 14
      source: Quickshell.shellPath("svg/weather.svg")
      sourceSize.width: 20
      sourceSize.height: 20
    }

    Text {
      id: weatherText
      text: temperature
      color: Colors.weatherTemperature
      font.family: "Iosevka Nerd Font"
      font.pixelSize: 11
    }
  }

  // Click to refresh weather
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: weatherProcess.running = true
  }
}
