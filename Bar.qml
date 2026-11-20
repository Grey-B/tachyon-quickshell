import Quickshell
import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Quickshell.Io

Scope {
    id: root

    property int shapeWidth: 400
    property int shapeHeight: 30
    property int slant: 30

    property var activePlayer: {
        const players = Mpris.players.values;
        if (!players || players.length === 0) return null;
        for (const p of players) {
        if (p.playbackState === MprisPlaybackState.Playing) return p;
        }
        return players[0];
    }
        
    Variants {
        model: Quickshell.screens

        PanelWindow {

            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: 5
                left: 8
                right: 8
            }

            implicitHeight: shapeHeight + 6

            PwObjectTracker {
                objects: [Pipewire.defaultAudioSink]
            }

            // Left shadow
            Shape {
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    leftMargin: 0
                    bottomMargin: -4
                }
                width: root.shapeWidth
                height: root.shapeHeight

                ShapePath {

                    fillColor: Colors.shadow
                    strokeColor: "transparent"

                    startX: root.slant
                    startY: 0

                    PathLine {
                        x: root.shapeWidth
                        y: 0
                    }

                    PathLine {
                        x: root.shapeWidth - root.slant
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: 0
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: root.slant
                        y: 0
                    }
                }
            }

            // Left bar
            Shape {
                id: leftBar
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }

                width: root.shapeWidth
                height: root.shapeHeight

                ShapePath {
                    fillGradient: RadialGradient {
                        centerX: root.shapeWidth / 5; centerY: root.shapeHeight / 2
                        centerRadius: 200
                        focalX: centerX; focalY: centerY
                        GradientStop { position: 0.0; color: Colors.bg1 }
                        GradientStop { position: 1.0; color: Colors.bg2 }
                    }
                    strokeColor: "transparent"

                    startX: root.slant
                    startY: 0

                    PathLine {
                        x: root.shapeWidth
                        y: 0
                    }

                    PathLine {
                        x: root.shapeWidth - root.slant
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: 0
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: root.slant
                        y: 0
                    }
                }

                RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 32
                spacing: 8

                // Workspaces
                Repeater {
                    model: 8
                    Rectangle {
                        implicitWidth: 24 + (isActive ? 8 : 0)
                        implicitHeight: Fonts.fontSize
                        radius: 12
                        property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                        property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                        color: isActive ? Colors.main2 : (ws ? Colors.main1 : Colors.main3)
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("workspace " + (index + 1))
                        }
                    }
                }
                }
            }

            // Center shadow
            Shape {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    leftMargin: 4
                    bottomMargin: -4
                }
                width: root.shapeWidth
                height: root.shapeHeight

                ShapePath {

                    fillColor: Colors.shadow
                    strokeColor: "transparent"

                    startX: root.slant
                    startY: 0

                    PathLine {
                        x: root.shapeWidth
                        y: 0
                    }

                    PathLine {
                        x: root.shapeWidth - root.slant
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: 0
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: root.slant
                        y: 0
                    }
                }
            }

            // Center bar
            Shape {
                id: centerBar
                anchors.centerIn: parent

                width: root.shapeWidth
                height: root.shapeHeight

                ShapePath {
                    fillGradient: RadialGradient {
                        centerX: root.shapeWidth / 5; centerY: root.shapeHeight / 2
                        centerRadius: 200
                        focalX: centerX; focalY: centerY
                        GradientStop { position: 0.0; color: Colors.bg1 }
                        GradientStop { position: 1.0; color: Colors.bg2 }
                    }
                    strokeColor: "transparent"

                    startX: root.slant
                    startY: 0

                    PathLine {
                        x: root.shapeWidth
                        y: 0
                    }

                    PathLine {
                        x: root.shapeWidth - root.slant
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: 0
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: root.slant
                        y: 0
                    }
                }

                // Clock
                Text {
                    id: clock
                    anchors.centerIn: parent
                    color: Colors.main1
                    font {
                        family: Fonts.fontFamily
                        pixelSize: Fonts.fontSize
                        bold: true }
                    text: Qt.formatDateTime(new Date(), "ddd, dd MMM - HH:mm")
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, dd MMM - HH:mm")
                    }
                }
            }

            // Right shadow
            Shape {
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: 4
                    bottomMargin: -4
                }
                width: root.shapeWidth
                height: root.shapeHeight

                ShapePath {

                    fillColor: Colors.shadow
                    strokeColor: "transparent"

                    startX: root.slant
                    startY: 0

                    PathLine {
                        x: root.shapeWidth
                        y: 0
                    }

                    PathLine {
                        x: root.shapeWidth - root.slant
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: 0
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: root.slant
                        y: 0
                    }
                }
            }

            // Right bar
            Shape {
                id: rightBar
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                width: root.shapeWidth
                height: root.shapeHeight

                ShapePath {
                    fillGradient: RadialGradient {
                        centerX: root.shapeWidth / 5; centerY: root.shapeHeight / 2
                        centerRadius: 200
                        focalX: centerX; focalY: centerY
                        GradientStop { position: 0.0; color: Colors.bg1 }
                        GradientStop { position: 1.0; color: Colors.bg2 }
                    }
                    strokeColor: "transparent"

                    startX: root.slant
                    startY: 0

                    PathLine {
                        x: root.shapeWidth
                        y: 0
                    }

                    PathLine {
                        x: root.shapeWidth - root.slant
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: 0
                        y: root.shapeHeight
                    }

                    PathLine {
                        x: root.slant
                        y: 0
                    }
                }

                RowLayout {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    anchors.leftMargin: 32
                    anchors.rightMargin: 40
                    spacing: 12

                    // System Tray
                    Rectangle {
                        implicitHeight: 24
                        implicitWidth: trayIcons.width + 8
                        radius: 12
                        color: Colors.shadow

                        visible: trayIcons.width > 2

                        RowLayout {
                        id: trayIcons
                        anchors.centerIn: parent
                        spacing: 2
                        Repeater {
                            model: SystemTray.items

                            MouseArea {
                            id: trayDelegate
                            required property SystemTrayItem modelData

                            Accessible.role: Accessible.Button
                            Accessible.name: modelData.tooltipTitle || modelData.title || "System tray item"

                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24

                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                            onClicked: (mouse) => {
                                if (mouse.button === Qt.LeftButton) {
                                modelData.activate()
                                } else if (mouse.button === Qt.RightButton) {
                                if (modelData.hasMenu) {
                                    menuAnchor.open()
                                }
                                } else if (mouse.button === Qt.MiddleButton) {
                                modelData.secondaryActivate()
                                }
                            }

                            IconImage {
                                anchors.centerIn: parent
                                source: trayDelegate.modelData.icon
                                implicitSize: 16
                            }

                            QsMenuAnchor {
                                id: menuAnchor
                                menu: trayDelegate.modelData.menu

                                anchor.window: trayDelegate.QsWindow.window
                                anchor.adjustment: PopupAdjustment.Flip
                                anchor.onAnchoring: {
                                const window = trayDelegate.QsWindow.window;
                                const widgetRect = window.contentItem.mapFromItem(
                                    trayDelegate, 0, trayDelegate.height,
                                    trayDelegate.width, trayDelegate.height);
                                menuAnchor.anchor.rect = widgetRect;
                                }
                            }
                            }
                        }
                        }
                    }

                    // Divisor
                    Item {
                        implicitWidth: 20
                        visible: trayIcons.width > 2
                        Rectangle {
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            width: 1
                            height: 20
                            color: Colors.main1
                        }
                    }

                    // Volume
                    Rectangle {
                        implicitHeight: 24
                        color: "transparent"

                        Accessible.role: Accessible.StaticText
                        Accessible.name: {
                        const sink = Pipewire.defaultAudioSink;
                        if (!sink || !sink.audio) return "Volume";
                        if (sink.audio.muted) return "Volume: muted";
                        return "Volume: " + Math.round(sink.audio.volume * 100) + "%";
                        }

                        Row {
                        id: volContent
                        anchors.centerIn: parent
                        spacing: 6

                        Text {        
                            text: {
                                const sink = Pipewire.defaultAudioSink;
                                if (!sink || !sink.audio || sink.audio.muted || sink.audio.volume <= 0) return "󰖁";
                                if (sink.audio.volume < 0.33) return "󰕿";
                                if (sink.audio.volume < 0.66) return "󰖀";
                                return "󰕾";
                            }
                            color: {
                                const sink = Pipewire.defaultAudioSink;
                                if (!sink || !sink.audio || sink.audio.muted) return Colors.main3;
                                return Colors.main1;
                            }
                            font.pixelSize: Fonts.fontSize
                            font.family: Fonts.fontFamily
                        }

                        Text {
                            text: {
                                const sink = Pipewire.defaultAudioSink;
                                if (!sink || !sink.audio) return "–";
                                if (sink.audio.muted) return "Mute";
                                return Math.round(sink.audio.volume * 100) + "%";
                            }
                            color: Colors.main1
                            font.pixelSize: Fonts.fontSize
                            font.family: Fonts.fontFamily
                        }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton
                            onClicked: {
                                const sink = Pipewire.defaultAudioSink;
                                if (sink && sink.audio) sink.audio.muted = !sink.audio.muted;
                            }
                            onWheel: (wheel) => {
                                const sink = Pipewire.defaultAudioSink;
                                if (!sink || !sink.audio) return;
                                const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                                sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + delta));
                            }
                        }
                    }
                    
                    // Divisor
                    Item {
                        visible: root.activePlayer !== null
                        implicitWidth: 20
                        Rectangle {
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            width: 1
                            height: 20
                            color: Colors.main1
                        }
                    }

                    // Now Playing
                    Rectangle {
                        implicitHeight: 24
                        implicitWidth: nowPlayingContent.width
                        color: "transparent"
                        visible: root.activePlayer !== null

                        Accessible.role: Accessible.Button
                        Accessible.name: {
                            if (!root.activePlayer) return "No media";
                            const artist = root.activePlayer.trackArtist || "";
                            const title = root.activePlayer.trackTitle || "";
                            return "Now playing: " + title;
                        }

                        Row {
                            id: nowPlayingContent
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.activePlayer && root.activePlayer.isPlaying ? "󰏤" : "󰐊"
                                color: Colors.main1
                                font.family: Fonts.fontFamily
                                font.pixelSize: Fonts.fontSize
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: {
                                    if (!root.activePlayer) return "";
                                    const title = root.activePlayer.trackTitle || "";
                                    return title;
                                }
                                color: Colors.main1
                                font.family: Fonts.fontFamily
                                font.pixelSize: Fonts.smallFontSize
                                elide: Text.ElideRight
                                width: Math.min(implicitWidth, 150)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activePlayer.togglePlaying()
                        }
                    }
                }
            }
        }
    }
}