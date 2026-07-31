import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.configuration

Rectangle {
  id: root

  Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
  implicitWidth: workspaceRow.implicitWidth + 22
  implicitHeight: 22
  radius: 3
  color: hoverHandler.hovered ? Colors.workspaceBackgroundHover : Colors.moduleBackground

  property int activeWorkspaceId: -1

  HoverHandler { id: hoverHandler }

  border.width: 1
  border.color: hoverHandler.hovered ? Colors.workspaceBorderHover : Colors.moduleBorder

  Behavior on border.color {
    ColorAnimation { duration: 400 }
  }

  ListModel {
    id: workspaceModel
  }

  function focusedOutput(workspaces) {
    let outputs = []
    let focusedOutputName
    let hasOutputState = false

    workspaces.forEach(workspace => {
      if (workspace.output === undefined || workspace.output === null)
        return

      if (outputs.indexOf(workspace.output) === -1)
        outputs.push(workspace.output)

      if (workspace.is_active !== undefined && workspace.is_focused !== undefined)
        hasOutputState = true

      if (workspace.is_focused === true)
        focusedOutputName = workspace.output
    })

    return outputs.length > 1 && hasOutputState ? focusedOutputName : undefined
  }

  function loadWorkspaces(workspaces) {
    const output = focusedOutput(workspaces)
    const visibleWorkspaces = output === undefined
      ? workspaces
      : workspaces.filter(workspace => workspace.output === output)

    workspaceModel.clear()
    root.activeWorkspaceId = -1
    const sorted = visibleWorkspaces.slice().sort((a, b) => Number(a.idx) - Number(b.idx))
    sorted.forEach(workspace => {
      workspaceModel.append({
        workspaceId: Number(workspace.id),
        workspaceIndex: Number(workspace.idx),
        focused: !!workspace.is_focused,
        active: !!workspace.is_focused,
        urgent: !!workspace.is_urgent
      })
      if (workspace.is_focused)
        root.activeWorkspaceId = Number(workspace.id)
    })
  }

  function handleSnapshot(line) {
    try {
      loadWorkspaces(JSON.parse(line))
    } catch (error) {
    }
  }

  function markActiveWorkspace(id) {
    root.activeWorkspaceId = id
    for (let i = 0; i < workspaceModel.count; i++)
      workspaceModel.setProperty(i, "active", workspaceModel.get(i).workspaceId === id)
  }

  function focusWorkspaceByIndex(idx) {
    // Detached process avoids Process.running reuse quirks
    Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(idx)])
  }

  function handleEvent(line) {
    try {
      const event = JSON.parse(line)
      if (event.WorkspacesChanged) {
        loadWorkspaces(event.WorkspacesChanged.workspaces || [])
      } else if (event.WorkspaceActivated) {
        const activation = event.WorkspaceActivated
        const id = Number(activation.id)
        let workspace
        for (let i = 0; i < workspaceModel.count; i++) {
          if (workspaceModel.get(i).workspaceId === id) {
            workspace = workspaceModel.get(i)
            break
          }
        }

        const isFocused = typeof activation.focused === "boolean"
          ? activation.focused
          : workspace && workspace.focused
        if (isFocused)
          markActiveWorkspace(id)
      } else if (event.WorkspaceUrgencyChanged) {
        const id = Number(event.WorkspaceUrgencyChanged.id)
        for (let i = 0; i < workspaceModel.count; i++) {
          if (workspaceModel.get(i).workspaceId === id)
            workspaceModel.setProperty(i, "urgent", !!event.WorkspaceUrgencyChanged.urgent)
        }
      }
    } catch (error) {
    }
  }

  Process {
    id: workspaceSnapshot
    command: ["niri", "msg", "--json", "workspaces"]
    running: true
    stdout: SplitParser {
      onRead: line => root.handleSnapshot(line)
    }
  }

  Process {
    id: eventStream
    command: ["niri", "msg", "--json", "event-stream"]
    running: true
    stdout: SplitParser {
      onRead: line => root.handleEvent(line)
    }
    onExited: running = true
  }

  // Refresh snapshot periodically so UI stays in sync if events are missed
  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: workspaceSnapshot.running = true
  }

  RowLayout {
    id: workspaceRow
    anchors.centerIn: parent
    spacing: 3

    Repeater {
      model: workspaceModel

      Rectangle {
        required property int workspaceId
        required property int workspaceIndex
        required property bool focused
        required property bool active
        required property bool urgent

        // Larger hit target than the visual pill
        implicitWidth: active ? 40 : 14
        implicitHeight: 16
        color: "transparent"

        Rectangle {
          anchors.centerIn: parent
          width: active ? 36 : 10
          height: 4
          radius: 1
          color: urgent ? Colors.batteryLow : active ? Colors.workspaceActive
            : parentHover.hovered ? Colors.workspaceHover : Colors.workspaceInactive

          Behavior on width {
            NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
          }
        }

        HoverHandler { id: parentHover }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.focusWorkspaceByIndex(workspaceIndex)
        }
      }
    }
  }
}
