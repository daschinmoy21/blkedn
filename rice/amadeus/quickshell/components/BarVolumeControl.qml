import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.configuration

Rectangle {
  Layout.alignment: Qt.AlignVCenter
  Layout.preferredWidth: 72
  Layout.preferredHeight: 24
  width: 72
  height: 24
  radius: 3
  color: hoverHandler.hovered ? Colors.volumeBackgroundHover : Colors.moduleBackground

  HoverHandler { id: hoverHandler }

  border.width: 1
  border.color: hoverHandler.hovered ? Colors.volumeBorderHover : Colors.moduleBorder

  Behavior on border.color {
    ColorAnimation { duration: 400 }
  }

  readonly property PwNode sink: Pipewire.defaultAudioSink
  property bool muted: sink?.audio?.muted ?? false
  property real volume: sink?.audio?.volume ?? 0

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
  }

  RowLayout {
    anchors.centerIn: parent
    spacing: 4

    Image {
      Layout.preferredWidth: 12
      Layout.preferredHeight: 12
      source: Qt.resolvedUrl("../svg/" + (muted ? "speaker-dark" : "speaker") + ".svg")
      opacity: muted ? 0.6 : 1.0
    }

    Rectangle {
      id: volumeBar
      Layout.preferredWidth: 42
      Layout.preferredHeight: 6
      color: Colors.volumeBarBackground
      radius: 1

      Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: {
          const len = muted ? 2 : parent.width * volume
          return Math.max(0, Math.min(parent.width, len))
        }
        height: parent.height
        radius: 1
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0; color: Colors.volumeGradientStart }
          GradientStop { position: 1; color: Colors.volumeGradientEnd }
        }

        Behavior on width {
          NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    onClicked: {
      if (sink?.audio)
        sink.audio.muted = !muted
    }

    onWheel: wheel => {
      if (sink?.audio && !muted) {
        const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
        sink.audio.volume = Math.max(0, Math.min(1, volume + delta))
      }
    }
  }
}
