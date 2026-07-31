import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.configuration

// Leftmost bar control: NixOS logo (launcher / overview)
Rectangle {
  Layout.alignment: Qt.AlignVCenter
  Layout.preferredWidth: 26
  Layout.preferredHeight: 26
  width: 26
  height: 26
  radius: 3
  color: Colors.moduleBackground
  clip: true
  border.width: 1
  border.color: Colors.moduleBorder

  Image {
    anchors.centerIn: parent
    width: 18
    height: 18
    // White snowflake on dark Amadeus module bg
    source: Quickshell.shellPath("svg/nixos-logo.svg")
    sourceSize.width: 48
    sourceSize.height: 48
    fillMode: Image.PreserveAspectFit
    smooth: true
    mipmap: true
  }

  // Left: app launcher · Right: niri overview
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton) {
        Quickshell.execDetached(["rofi", "-show", "drun"])
      } else {
        Quickshell.execDetached(["niri", "msg", "action", "toggle-overview"])
      }
    }
  }
}
