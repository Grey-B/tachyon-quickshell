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

            implicitHeight: shapeHeight

            Process {
                id: netProc
                command: ["sh", "-c", "eth=$(nmcli -t -f type,state dev 2>/dev/null | grep '^ethernet:connected'); if [ -n \"$eth\" ]; then echo 'ethernet:Ethernet'; else wifi=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2); if [ -n \"$wifi\" ]; then echo \"wifi:$wifi\"; else echo 'disconnected:'; fi; fi"]
                running: true

                stdout: StdioCollector {
                onStreamFinished: {
                    const result = text.trim()
                    const colonIdx = result.indexOf(':')
                    const type = result.substring(0, colonIdx)
                    const info = result.substring(colonIdx + 1)
                    root.networkType = type
                    root.networkInfo = info || "Disconnected"
                }
                }
            }

            // Update your timer to run processes
            // Timer {
            //     interval: 2000
            //     running: true
            //     repeat: true
            //     onTriggered: {
            //         netProc.running = true
            //     }
            // }

            PwObjectTracker {
                objects: [Pipewire.defaultAudioSink]
            }

            Shape {
                id: leftBar
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }

                width: root.shapeWidth
                height: root.shapeHeight

                ShapePath {
                    fillColor: Colors.bg1
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

            Shape {
                id: centerBar
                anchors.centerIn: parent

                width: root.shapeWidth
                height: root.shapeHeight

                ShapePath {
                    fillColor: Colors.bg1
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

            Shape {
                id: rightBar
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                width: root.shapeWidth
                height: root.shapeHeight

                ShapePath {
                    fillColor: Colors.bg1
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
                    anchors.rightMargin: 64
                    spacing: 12

                    // System Tray
                    Rectangle {
                        implicitHeight: 24
                        color: "transparent"

                        RowLayout {
                        id: trayIcons
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
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
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }                        
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
                            anchors.verticalCenter: parent.verticalCenter
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
                        implicitWidth: nowPlayingContent.width + 8
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
                                width: Math.min(implicitWidth, 160)
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