//@ pragma Env QT_SCALE_FACTOR=1.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import 'components' as Components
import qs.configuration

Scope {
  id: root

  Components.PopoutVolume {}

  // Horizontal Amadeus-style top bar for Niri
  WlrLayershell {
    id: bar
    anchors {
      top: true
      left: true
      right: true
    }
    margins {
      top: 6
      left: 8
      right: 8
    }

    layer: WlrLayer.Top
    exclusiveZone: height + 6

    implicitHeight: 36
    color: "transparent"

    Rectangle {
      anchors.fill: parent
      color: Colors.barBackground
      radius: 4
      border.width: 2
      border.color: Colors.barBorder

      // Three-zone layout so clock can sit true-center
      Item {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.topMargin: 4
        anchors.bottomMargin: 4

        // —— LEFT: nix logo · volume · cpu/ram · workspaces ——
        // (no weather — avoids wttr.in / location telemetry)
        RowLayout {
          id: leftRow
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8
          height: parent.height

          Components.BarProfilePicture {}
          Components.BarVolumeControl {}

          Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter
            radius: 3
            color: Colors.moduleBackground
            border.width: 1
            border.color: Colors.moduleBorder

            property real cpuUsage: 0
            property real ramUsage: 0

            Process {
              id: cpuProcess
              command: ["sh", "-c", "top -bn1 | grep '%Cpu(s):' | awk '{print $2}' | sed 's/%us,//'"]
              running: true
              stdout: SplitParser {
                onRead: data => {
                  const usage = parseFloat(data.trim())
                  if (!isNaN(usage)) parent.cpuUsage = Math.round(usage)
                }
              }
            }

            Process {
              id: ramProcess
              command: ["sh", "-c", "free | grep Mem: | awk '{printf \"%.0f\", ($2-$7)/$2*100}'"]
              running: true
              stdout: SplitParser {
                onRead: data => {
                  const usage = parseInt(data.trim())
                  if (!isNaN(usage)) parent.ramUsage = usage
                }
              }
            }

            Timer {
              interval: 2000
              running: true
              repeat: true
              onTriggered: {
                cpuProcess.running = true
                ramProcess.running = true
              }
            }

            RowLayout {
              anchors.centerIn: parent
              spacing: 2
              Components.RadialIndicator {
                percent: parent.parent.cpuUsage
                indicatorColor: Colors.ramIndicator
                backgroundColor: Colors.indicatorBackground
                size: 18
              }
              Components.RadialIndicator {
                percent: parent.parent.ramUsage
                indicatorColor: Colors.cpuIndicator
                backgroundColor: Colors.indicatorBackground
                size: 18
              }
            }
          }

          // Workspaces immediately after CPU/RAM
          Components.NiriWorkspaces {}
        }

        // —— CENTER: clock ——
        Rectangle {
          id: clockBox
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          height: 24
          width: clockText.implicitWidth + 14
          radius: 3
          color: Colors.moduleBackground
          border.width: 1
          border.color: Colors.moduleBorder
          z: 2

          property string currentTime: Qt.formatDateTime(new Date(), "hh:mm")

          Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockBox.currentTime = Qt.formatDateTime(new Date(), "hh:mm")
          }

          Text {
            id: clockText
            anchors.centerIn: parent
            text: clockBox.currentTime
            color: Colors.ramIndicator
            font.family: "Iosevka Nerd Font"
            font.pixelSize: 13
          }
        }

        // —— RIGHT: tray · media · battery · power ——
        RowLayout {
          id: rightRow
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8
          height: parent.height

          Components.BarSystemTray {}
          Components.Player {}
          Components.BarBatteryInternet {}
          Components.Power {}
        }
      }
    }
  }
}
