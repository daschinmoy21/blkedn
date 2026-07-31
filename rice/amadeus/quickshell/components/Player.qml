import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.configuration

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

  // Ignore browser MPRIS (Helium/Chromium/Chrome) so tabs don't hijack the widget
  readonly property var ignoreTokens: ["helium", "chromium", "chrome"]

  property var activePlayer: null
  property string artUrl: ""
  property bool playing: false
  property string fallbackIcon: Quickshell.shellPath("svg/headphones.svg")

  readonly property bool hasArt: artUrl !== "" && albumArt.status === Image.Ready

  function playerIgnored(p) {
    if (!p)
      return true
    const hay = [p.identity || "", p.desktopEntry || "", p.dbusName || ""].join(" ").toLowerCase()
    for (let i = 0; i < ignoreTokens.length; i++) {
      if (hay.indexOf(ignoreTokens[i]) !== -1)
        return true
    }
    return false
  }

  function normalizeArt(url) {
    const a = (url || "").trim()
    if (a === "")
      return ""
    if (a.startsWith("/") && !a.startsWith("file:"))
      return "file://" + a
    return a
  }

  function pickPlayer() {
    const list = Mpris.players.values
    let playingP = null
    let pausedP = null
    let otherP = null

    for (let i = 0; i < list.length; i++) {
      const p = list[i]
      if (playerIgnored(p))
        continue
      if (p.isPlaying || p.playbackState === MprisPlaybackState.Playing) {
        playingP = p
        break
      }
      if (!pausedP && p.playbackState === MprisPlaybackState.Paused)
        pausedP = p
      else if (!otherP)
        otherP = p
    }

    const next = playingP || pausedP || otherP || null
    if (next !== activePlayer)
      activePlayer = next

    playing = !!(activePlayer && (activePlayer.isPlaying || activePlayer.playbackState === MprisPlaybackState.Playing || activePlayer.playbackState === MprisPlaybackState.Paused))
    updateArt()
  }

  function updateArt() {
    const p = activePlayer
    if (!p) {
      artUrl = ""
      artFallback.running = false
      return
    }

    const mprisArt = normalizeArt(p.trackArtUrl || "")
    if (mprisArt !== "") {
      artUrl = mprisArt
      return
    }

    // Optional fallback when MPRIS art is empty
    artFallback.running = true
  }

  function control(action) {
    const p = activePlayer
    if (!p)
      return
    if (action === "previous" && p.canGoPrevious)
      p.previous()
    else if (action === "next" && p.canGoNext)
      p.next()
    else if (action === "toggle" && p.canTogglePlaying)
      p.togglePlaying()
    Qt.callLater(pickPlayer)
  }

  Component.onCompleted: pickPlayer()

  // Re-pick when players appear/disappear
  Connections {
    target: Mpris.players
    function onObjectInsertedPost() { playerModule.pickPlayer() }
    function onObjectRemovedPost() { playerModule.pickPlayer() }
  }

  // Track art / playback state on the selected player
  Connections {
    target: playerModule.activePlayer
    function onTrackArtUrlChanged() { playerModule.updateArt() }
    function onMetadataChanged() { playerModule.updateArt() }
    function onIsPlayingChanged() { playerModule.pickPlayer() }
    function onPlaybackStateChanged() { playerModule.pickPlayer() }
    function onPostTrackChanged() { playerModule.updateArt() }
  }

  // Cheap poll so late metadata / new players still refresh without complex wiring
  Timer {
    interval: 1200
    running: true
    repeat: true
    onTriggered: playerModule.pickPlayer()
  }

  // Fallback: playerctl, ignoring browser players
  Process {
    id: artFallback
    running: false
    command: ["playerctl", "-i", "chromium,Helium,chrome,Chrome,Chromium", "metadata", "mpris:artUrl"]
    stdout: SplitParser {
      onRead: art => {
        const a = playerModule.normalizeArt(art)
        if (a !== "" && a.indexOf("No players") === -1)
          playerModule.artUrl = a
        else if (!playerModule.activePlayer || !(playerModule.activePlayer.trackArtUrl))
          playerModule.artUrl = ""
      }
    }
    stderr: SplitParser {
      onRead: err => {
        if (err.indexOf("No player") !== -1 || err.indexOf("does not") !== -1) {
          if (!playerModule.activePlayer || !(playerModule.activePlayer.trackArtUrl))
            playerModule.artUrl = ""
        }
      }
    }
  }

  // Album art (preferred when available)
  Image {
    id: albumArt
    anchors.fill: parent
    anchors.margins: 1
    visible: playerModule.hasArt
    source: playerModule.artUrl
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: true
    sourceSize.width: 56
    sourceSize.height: 56
  }

  // Headphones fallback
  Image {
    anchors.centerIn: parent
    width: 16
    height: 16
    visible: !playerModule.hasArt
    source: playerModule.fallbackIcon
    sourceSize.width: 32
    sourceSize.height: 32
    opacity: playerModule.playing ? 1.0 : 0.65
  }

  // Subtle playing ring
  Rectangle {
    anchors.fill: parent
    radius: parent.radius
    color: "transparent"
    border.width: playerModule.playing && playerModule.activePlayer && playerModule.activePlayer.isPlaying ? 1 : 0
    border.color: Colors.playerBorderHover
    visible: playerModule.playing && playerModule.activePlayer && playerModule.activePlayer.isPlaying
  }

  // Left: previous · Right: next · Middle: play/pause
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true

    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton)
        playerModule.control("previous")
      else if (mouse.button === Qt.RightButton)
        playerModule.control("next")
      else if (mouse.button === Qt.MiddleButton)
        playerModule.control("toggle")
    }
  }
}
