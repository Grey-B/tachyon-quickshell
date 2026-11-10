import Quickshell
import QtQuick
import QtQuick.Shapes

PanelWindow {
    id: root

    property int shapeWidth: 400
    property int shapeHeight: 30
    property int slant: 32

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

    Shape {
        anchors.centerIn: parent

        width: root.shapeWidth
        height: root.shapeHeight

        ShapePath {
            fillColor: "#FFFFFF"
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
}