import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import 'components' as Components

Rectangle {
  Layout.fillHeight: true
  Layout.fillWidth: true
  color: "transparent"

  ColumnLayout {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    Layout.fillHeight: true
    Layout.fillWidth: true
    spacing: 6
    y: (parent.height - height) / 12

    Components.NiriWorkspaces {}
  }
}
