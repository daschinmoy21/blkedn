import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import qs.configuration

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
          anchors.centerIn: parent
          width: 16
          height: 16
          source: {
            const icon = trayItem.modelData.icon || ""
            if (icon.startsWith("/") && !icon.startsWith("file:"))
              return "file://" + icon
            return icon
          }
          sourceSize.width: 16
          sourceSize.height: 16
          smooth: true
        }

        ToolTip.visible: ma.containsMouse && !!(trayItem.modelData.tooltipTitle || trayItem.modelData.title)
        ToolTip.delay: 400
        ToolTip.text: trayItem.modelData.tooltipTitle || trayItem.modelData.title || ""

        // Platform menu via Quickshell's menu anchor (DBusMenu path)
        QsMenuAnchor {
          id: menuAnchor
          menu: trayItem.modelData.hasMenu ? trayItem.modelData.menu : null
          anchor {
            item: trayItem
            edges: Edges.Bottom | Edges.Left
            gravity: Edges.Bottom | Edges.Right
            margins.top: 6
          }
        }

        function openDbusMenu(mouseX, mouseY) {
          if (!trayItem.modelData.hasMenu)
            return false

          // 1) Preferred: QsMenuAnchor (works for most SNI DBus menus)
          if (trayItem.modelData.menu) {
            try {
              menuAnchor.menu = trayItem.modelData.menu
              menuAnchor.anchor.updateAnchor()
              menuAnchor.open()
              return true
            } catch (e) {
              // fall through
            }
          }

          // 2) SNI Display() with window-relative coordinates
          const win = trayItem.QsWindow ? trayItem.QsWindow.window : null
          if (win) {
            try {
              // Map click (or icon bottom) into the window content item
              const content = win.contentItem
              let rx = mouseX
              let ry = mouseY
              if (content) {
                const p = ma.mapToItem(content, mouseX, mouseY)
                rx = p.x
                ry = p.y
              } else {
                // Fallback: map item origin into global-ish window space via mapToItem(null)
                const p = trayItem.mapToItem(null, 0, trayItem.height)
                rx = p.x
                ry = p.y
              }
              trayItem.modelData.display(win, Math.round(rx), Math.round(ry))
              return true
            } catch (e2) {
              // fall through
            }
          }

          return false
        }

        MouseArea {
          id: ma
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: true
          preventStealing: true

          onClicked: mouse => {
            // Middle: secondary activate (spec)
            if (mouse.button === Qt.MiddleButton) {
              trayItem.modelData.secondaryActivate()
              return
            }

            // Left: activate, unless onlyMenu → open menu
            if (mouse.button === Qt.LeftButton) {
              if (trayItem.modelData.onlyMenu && trayItem.modelData.hasMenu) {
                if (!trayItem.openDbusMenu(mouse.x, mouse.y))
                  trayItem.modelData.secondaryActivate()
              } else {
                trayItem.modelData.activate()
              }
              return
            }

            // Right: open DBus menu when available
            if (mouse.button === Qt.RightButton) {
              if (trayItem.modelData.hasMenu) {
                if (!trayItem.openDbusMenu(mouse.x, mouse.y))
                  trayItem.modelData.secondaryActivate()
              } else {
                trayItem.modelData.secondaryActivate()
              }
            }
          }

          onWheel: wheel => {
            trayItem.modelData.scroll(wheel.angleDelta.y, false)
          }
        }
      }
    }
  }
}
