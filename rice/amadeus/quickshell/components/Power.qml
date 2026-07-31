import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.configuration

Item {
  id: powerRoot
  Layout.alignment: Qt.AlignVCenter
  Layout.preferredWidth: 28
  Layout.preferredHeight: 28
  width: 28
  height: 28

  property bool menuOpen: false
  // "" | "logout" | "reboot" | "shutdown"
  property string confirmAction: ""

  function runAction(name) {
    if (name === "lock") {
      Quickshell.execDetached(["loginctl", "lock-session"])
      closeMenu()
    } else if (name === "logout") {
      Quickshell.execDetached(["niri", "msg", "action", "quit", "--skip-confirmation"])
      closeMenu()
    } else if (name === "reboot") {
      Quickshell.execDetached(["systemctl", "reboot"])
      closeMenu()
    } else if (name === "shutdown") {
      Quickshell.execDetached(["systemctl", "poweroff"])
      closeMenu()
    }
  }

  function requestAction(name) {
    // Lock is safe — no second confirm
    if (name === "lock") {
      runAction("lock")
      return
    }
    confirmAction = name
  }

  function closeMenu() {
    menuOpen = false
    confirmAction = ""
  }

  // Power icon button
  Rectangle {
    id: powerBtn
    anchors.fill: parent
    radius: 3
    color: hoverHandler.hovered || menuOpen ? Colors.powerBackgroundHover : Colors.powerBackground
    border.width: 1
    border.color: hoverHandler.hovered || menuOpen ? Colors.powerBorderHover : Colors.powerBorder

    HoverHandler { id: hoverHandler }

    Behavior on border.color {
      ColorAnimation { duration: 200 }
    }

    Image {
      anchors.centerIn: parent
      width: 16
      height: 16
      source: Quickshell.shellPath("svg/power.svg")
      sourceSize.width: 26
      sourceSize.height: 26
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true
      onClicked: {
        if (menuOpen)
          closeMenu()
        else {
          confirmAction = ""
          menuOpen = true
        }
      }
    }
  }

  // Floating confirmation / power menu
  LazyLoader {
    active: powerRoot.menuOpen

    component: PanelWindow {
      id: powerMenu
      // Centered overlay dialog
      anchors.top: true
      anchors.left: true
      anchors.right: true
      anchors.bottom: true
      color: "transparent"
      exclusiveZone: 0
      // Above normal windows
      // layer defaults ok for PanelWindow

      // Dim backdrop — click outside to cancel
      Rectangle {
        anchors.fill: parent
        color: "#99000A0E"

        MouseArea {
          anchors.fill: parent
          onClicked: powerRoot.closeMenu()
        }
      }

      // Dialog card
      Rectangle {
        id: card
        anchors.centerIn: parent
        width: 280
        height: confirmCol.implicitHeight + 28
        radius: 6
        color: Colors.barBackground
        border.width: 2
        border.color: Colors.barBorder

        // Stop clicks from closing via backdrop
        MouseArea {
          anchors.fill: parent
          onClicked: {}
        }

        ColumnLayout {
          id: confirmCol
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: 14
          spacing: 10

          Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: powerRoot.confirmAction === ""
              ? "Power"
              : powerRoot.confirmAction === "logout"
                ? "Log out of Niri?"
                : powerRoot.confirmAction === "reboot"
                  ? "Reboot the system?"
                  : "Shut down the system?"
            color: Colors.timeText
            font.family: "Iosevka Nerd Font"
            font.pixelSize: 15
            font.bold: true
          }

          Text {
            Layout.fillWidth: true
            visible: powerRoot.confirmAction !== ""
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: "This cannot be undone from here."
            color: "#A9A9A9"
            font.family: "Iosevka Nerd Font"
            font.pixelSize: 11
          }

          // Main actions
          ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: powerRoot.confirmAction === ""

            Repeater {
              model: [
                { id: "lock", label: "Lock screen", danger: false },
                { id: "logout", label: "Log out", danger: true },
                { id: "reboot", label: "Reboot", danger: true },
                { id: "shutdown", label: "Shut down", danger: true }
              ]

              Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                radius: 4
                color: btnHover.hovered
                  ? (modelData.danger ? Colors.powerBackgroundHover : Colors.moduleBackgroundHover)
                  : Colors.moduleBackground
                border.width: 1
                border.color: btnHover.hovered
                  ? (modelData.danger ? Colors.powerBorderHover : Colors.moduleBorderHover)
                  : Colors.moduleBorder

                HoverHandler { id: btnHover }

                Text {
                  anchors.centerIn: parent
                  text: modelData.label
                  color: modelData.danger ? Colors.batteryLow : "#C9C9C9"
                  font.family: "Iosevka Nerd Font"
                  font.pixelSize: 13
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: powerRoot.requestAction(modelData.id)
                }
              }
            }

            Rectangle {
              Layout.fillWidth: true
              Layout.preferredHeight: 32
              radius: 4
              color: cancelHover.hovered ? Colors.moduleBackgroundHover : "transparent"
              border.width: 1
              border.color: Colors.moduleBorder

              HoverHandler { id: cancelHover }

              Text {
                anchors.centerIn: parent
                text: "Cancel"
                color: "#767B7D"
                font.family: "Iosevka Nerd Font"
                font.pixelSize: 12
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: powerRoot.closeMenu()
              }
            }
          }

          // Second-step confirm
          ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: powerRoot.confirmAction !== ""

            Rectangle {
              Layout.fillWidth: true
              Layout.preferredHeight: 36
              radius: 4
              color: yesHover.hovered ? Colors.powerBackgroundHover : Colors.powerBackground
              border.width: 1
              border.color: Colors.powerBorderHover

              HoverHandler { id: yesHover }

              Text {
                anchors.centerIn: parent
                text: powerRoot.confirmAction === "logout" ? "Yes, log out"
                  : powerRoot.confirmAction === "reboot" ? "Yes, reboot"
                  : "Yes, shut down"
                color: Colors.batteryLow
                font.family: "Iosevka Nerd Font"
                font.pixelSize: 13
                font.bold: true
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: powerRoot.runAction(powerRoot.confirmAction)
              }
            }

            Rectangle {
              Layout.fillWidth: true
              Layout.preferredHeight: 32
              radius: 4
              color: noHover.hovered ? Colors.moduleBackgroundHover : Colors.moduleBackground
              border.width: 1
              border.color: Colors.moduleBorder

              HoverHandler { id: noHover }

              Text {
                anchors.centerIn: parent
                text: "No, go back"
                color: "#A9A9A9"
                font.family: "Iosevka Nerd Font"
                font.pixelSize: 12
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: powerRoot.confirmAction = ""
              }
            }
          }
        }
      }
    }
  }
}
