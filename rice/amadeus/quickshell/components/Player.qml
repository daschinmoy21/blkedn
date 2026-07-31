import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.configuration

// Media widget inspired by DankMaterialShell MprisController + TrackArtService:
// - Quickshell Mpris (not playerctl)
// - blacklist Helium / Chromium so browser tabs don't own the widget
// - trackArtUrl / metadata mpris:artUrl / YouTube thumbnail fallback
Rectangle {
  id: playerModule
  Layout.alignment: Qt.AlignVCenter
  Layout.preferredWidth: 28
  Layout.preferredHeight: 28
  width: 28
  height: 28
  radius: 3
  color: Colors.moduleBackground
  border.width: 1
  border.color: hoverHandler.hovered ? Colors.playerBorderHover : Colors.moduleBorder
  clip: true

  HoverHandler { id: hoverHandler }

  Behavior on border.color {
    ColorAnimation { duration: 200 }
  }

  // Substrings matched against identity + desktopEntry (case-insensitive)
  readonly property var excludePlayers: [
    "helium",
    "chromium",
    "chrome",
    "google-chrome",
    "brave",
    "vivaldi",
    "msedge",
    "edge",
    "opera"
  ]

  readonly property var availablePlayers: {
    const players = Mpris.players.values
    if (!players || players.length === 0)
      return []
    return players.filter(p => !isExcluded(p))
  }

  // Prefer Playing, else first non-idle
  readonly property var activePlayer: {
    const list = availablePlayers
    if (!list || list.length === 0)
      return null
    const playing = list.find(p => p.isPlaying)
    if (playing)
      return playing
    // Prefer paused with a title over empty stopped chromium leftovers
    const withTitle = list.find(p => p.trackTitle && p.trackTitle.length > 0)
    return withTitle || list[0]
  }

  readonly property bool hasPlayer: activePlayer !== null
  readonly property bool playing: !!(activePlayer && activePlayer.isPlaying)

  function isExcluded(p) {
    if (!p)
      return true
    const identity = (p.identity || "").toLowerCase()
    const desktop = (("desktopEntry" in p && p.desktopEntry) ? String(p.desktopEntry) : "").toLowerCase()
    const dbus = (("dbusName" in p && p.dbusName) ? String(p.dbusName) : "").toLowerCase()
    const blob = identity + " " + desktop + " " + dbus
    return excludePlayers.some(ex => blob.includes(ex))
  }

  // DMS TrackArtService.getArtworkUrl simplified
  function getArtUrl(player) {
    if (!player)
      return ""

    if (player.trackArtUrl)
      return normalizeUrl(player.trackArtUrl)

    if (player.metadata && player.metadata["mpris:artUrl"]) {
      const u = player.metadata["mpris:artUrl"].toString()
      if (u)
        return normalizeUrl(u)
    }

    // YouTube: no artUrl — derive thumbnail from watch URL
    if (player.metadata && player.metadata["xesam:url"]) {
      const url = player.metadata["xesam:url"].toString()
      if (url.includes("youtube.com") || url.includes("youtu.be")) {
        const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/
        const match = url.match(regExp)
        if (match && match[2] && match[2].length === 11)
          return "https://img.youtube.com/vi/" + match[2] + "/hqdefault.jpg"
      }
    }

    return ""
  }

  function normalizeUrl(u) {
    if (!u)
      return ""
    const s = String(u)
    if (s.startsWith("/") && !s.startsWith("file:"))
      return "file://" + s
    return s
  }

  property string artUrl: ""
  property string lastValidArtUrl: ""

  // Keep art reactive to active player + track changes
  function refreshArt() {
    const u = getArtUrl(activePlayer)
    artUrl = u
    if (u)
      lastValidArtUrl = u
  }

  onActivePlayerChanged: {
    lastValidArtUrl = ""
    refreshArt()
  }

  Connections {
    target: playerModule.activePlayer
    function onTrackArtUrlChanged() { playerModule.refreshArt() }
    function onTrackTitleChanged() { playerModule.refreshArt() }
    function onMetadataChanged() { playerModule.refreshArt() }
    function onIsPlayingChanged() { playerModule.refreshArt() }
  }

  Component.onCompleted: refreshArt()

  // Poll lightly — some players fill art late
  Timer {
    interval: 1500
    running: true
    repeat: true
    onTriggered: playerModule.refreshArt()
  }

  readonly property string displayArt: artUrl || lastValidArtUrl
  readonly property bool hasArt: displayArt !== ""

  // Album art
  Image {
    id: albumArt
    anchors.fill: parent
    anchors.margins: 1
    visible: hasArt
    source: displayArt
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: true
    sourceSize.width: 64
    sourceSize.height: 64
    onStatusChanged: {
      // Drop broken art so headphones show
      if (status === Image.Error) {
        if (playerModule.artUrl === source)
          playerModule.artUrl = ""
        if (playerModule.lastValidArtUrl === source)
          playerModule.lastValidArtUrl = ""
      }
    }
  }

  // Headphones fallback
  Image {
    anchors.centerIn: parent
    width: 16
    height: 16
    visible: !hasArt || albumArt.status !== Image.Ready
    source: Quickshell.shellPath("svg/headphones.svg")
    sourceSize.width: 32
    sourceSize.height: 32
    opacity: playing ? 1.0 : 0.65
  }

  Rectangle {
    anchors.fill: parent
    radius: parent.radius
    color: "transparent"
    border.width: playing ? 1 : 0
    border.color: Colors.playerBorderHover
    visible: playing
  }

  // L prev · R next · M play/pause (on non-excluded player)
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    onClicked: mouse => {
      const p = playerModule.activePlayer
      if (!p)
        return
      if (mouse.button === Qt.LeftButton) {
        if (p.canGoPrevious)
          p.previous()
      } else if (mouse.button === Qt.RightButton) {
        if (p.canGoNext)
          p.next()
      } else if (mouse.button === Qt.MiddleButton) {
        if (p.canTogglePlaying)
          p.togglePlaying()
      }
    }
  }
}
