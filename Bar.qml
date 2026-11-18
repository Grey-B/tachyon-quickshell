import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

PanelWindow {
    id: root

    property int shapeWidth: 400
    property int shapeHeight: 30
    property int slant: 30

    property int cpuUsage: 0
    property int memUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

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
        id: cpuProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var total = parseInt(parts[1]) || 1
                var used = parseInt(parts[2]) || 0
                memUsage = Math.round(100 * used / total)
                }
            }
        Component.onCompleted: running = true
    }

    // Update your timer to run both processes
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
        }
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
            Text {
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                text: index + 1
                color: isActive ? Colors.main2 : (ws ? Colors.main1 : Colors.main3)
                font { 
                    family: Fonts.fontFamily
                    pixelSize: Fonts.fontSize
                    bold: true }
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
            anchors.fill: parent
            anchors.leftMargin: 32
            anchors.rightMargin: 32
            spacing: 8

            // CPU
            Text {
                text: "CPU: " + memUsage + "%"
                color: memUsage >= 80 ? Colors.main3 : Colors.main1
                font { 
                    family: Fonts.fontFamily
                    pixelSize: Fonts.fontSize
                    bold: true
                }
            }
        }
    }
}