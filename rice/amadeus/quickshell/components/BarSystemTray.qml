import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import qs.configuration

// Tray patterns adapted from DankMaterialShell SystemTrayBar.qml:
// - fix icon ?path= / absolute paths
// - left: activate (or menu if onlyMenu)
// - right: QsMenuAnchor when hasMenu, else SNI ContextMenu dbus fallback
Rectangle {
  id: trayRoot
  Layout.alignment: Qt.AlignVCenter
  Layout.preferredHeight: 24
  Layout.preferredWidth: Math.max(28, trayRow.implicitWidth + 12)
  visible: SystemTray.items.values.length > 0
  radius: 3
  color: hoverHandler.hovered ? Colors.trayBackgroundHover : Colors.moduleBackground

  HoverHandler { id: hoverHandler }

  border.width: 1
  border.color: hoverHandler.hovered ? Colors.trayBorderHover : Colors.moduleBorder

  Behavior on border.color {
    ColorAnimation { duration: 400 }
  }

  // DMS trayIconSourceFor — many SNI icons need file:// rewriting
  function trayIconSource(trayItem) {
    let icon = trayItem && trayItem.icon
    if (typeof icon !== "string" || icon === "")
      return ""
    if (icon.includes("?path=")) {
      const split = icon.split("?path=")
      if (split.length !== 2)
        return icon
      const name = split[0]
      const path = split[1]
      let fileName = name.substring(name.lastIndexOf("/") + 1)
      if (fileName.startsWith("dropboxstatus"))
        fileName = "hicolor/16x16/status/" + fileName
      return "file://" + path + "/" + fileName
    }
    if (icon.startsWith("/") && !icon.startsWith("file://"))
      return "file://" + icon
    return icon
  }

  // DMS callContextMenuFallback — when hasMenu is false or QsMenu fails
  function callContextMenuFallback(trayItemId, globalX, globalY) {
    if (!trayItemId)
      return
    const script = [
      'ITEMS=$(dbus-send --session --print-reply --dest=org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.freedesktop.DBus.Properties.Get string:org.kde.StatusNotifierWatcher string:RegisteredStatusNotifierItems 2>/dev/null)',
      'while IFS= read -r line; do',
      '  line="${line#*\\"}"',
      '  line="${line%\\"}"',
      '  [ -z "$line" ] && continue',
      '  BUS="${line%%/*}"',
      '  OBJ="/${line#*/}"',
      '  ID=$(dbus-send --session --print-reply --dest="$BUS" "$OBJ" org.freedesktop.DBus.Properties.Get string:org.kde.StatusNotifierItem string:Id 2>/dev/null | grep -oP \'(?<=\\")(.*?)(?=\\")\' | tail -1)',
      '  if [ "$ID" = "$1" ]; then',
      '    dbus-send --session --type=method_call --dest="$BUS" "$OBJ" org.kde.StatusNotifierItem.ContextMenu int32:"$2" int32:"$3"',
      '    exit 0',
      '  fi',
      'done <<< "$ITEMS"'
    ].join("\n")
    Quickshell.execDetached(["bash", "-c", script, "_", String(trayItemId), String(globalX), String(globalY)])
  }

  RowLayout {
    id: trayRow
    anchors.centerIn: parent
    spacing: 4

    Repeater {
      model: SystemTray.items

      Item {
        id: trayItem
        required property var modelData

        Layout.preferredWidth: 22
        Layout.preferredHeight: 22
        implicitWidth: 22
        implicitHeight: 22

        Image {
          id: iconImg
          anchors.centerIn: parent
          width: 16
          height: 16
          source: trayRoot.trayIconSource(trayItem.modelData)
          sourceSize.width: 16
          sourceSize.height: 16
          asynchronous: true
          smooth: true
          mipmap: true
          visible: status === Image.Ready
        }

        // Letter fallback if icon fails
        Text {
          anchors.centerIn: parent
          visible: !iconImg.visible
          text: {
            const id = trayItem.modelData?.id || "?"
            return id.charAt(0).toUpperCase()
          }
          color: "#A9A9A9"
          font.pixelSize: 10
          font.family: "Iosevka Nerd Font"
        }

        QsMenuAnchor {
          id: menuAnchor
          menu: trayItem.modelData.menu
          // Anchor to this item (DMS/docs: menu won't show without valid anchor)
          anchor.item: trayItem
          anchor.edges: Edges.Bottom | Edges.Left
          anchor.gravity: Edges.Bottom | Edges.Right
          anchor.margins.top: 6
        }

        function openDbusMenu() {
          if (!trayItem.modelData.hasMenu || !trayItem.modelData.menu) {
            return false
          }
          try {
            menuAnchor.menu = trayItem.modelData.menu
            menuAnchor.anchor.item = trayItem
            menuAnchor.anchor.updateAnchor()
            menuAnchor.open()
            return true
          } catch (e) {
            return false
          }
        }

        function openContextMenu(mouse) {
          // 1) Prefer QsMenuAnchor when DBusMenu is exposed
          if (openDbusMenu())
            return

          // 2) secondaryActivate (caelestia / many clients)
          try {
            trayItem.modelData.secondaryActivate()
          } catch (e) {
          }

          // 3) DMS dbus ContextMenu fallback with global screen coords
          const gp = ma.mapToGlobal(mouse.x, mouse.y)
          trayRoot.callContextMenuFallback(
            trayItem.modelData.id,
            Math.round(gp.x),
            Math.round(gp.y)
          )
        }

        function activateLeft() {
          if (!trayItem.modelData)
            return
          // DMS: onlyMenu → open menu; else activate
          if (trayItem.modelData.onlyMenu) {
            if (trayItem.modelData.hasMenu)
              openDbusMenu()
            return
          }
          trayItem.modelData.activate()
        }

        MouseArea {
          id: ma
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: true
          preventStealing: true

          onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
              trayItem.activateLeft()
            } else if (mouse.button === Qt.RightButton) {
              trayItem.openContextMenu(mouse)
            } else if (mouse.button === Qt.MiddleButton) {
              try {
                trayItem.modelData.secondaryActivate()
              } catch (e) {
              }
            }
          }

          onWheel: wheel => {
            try {
              trayItem.modelData.scroll(wheel.angleDelta.y, false)
            } catch (e) {
            }
          }
        }
      }
    }
  }
}
