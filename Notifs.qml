import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Scope {
  id: root

  NotificationServer {
    id: server
    actionsSupported: true
    bodySupported: true
    imageSupported: true

    onNotification: n => n.tracked = true
  }

  PanelWindow {
    id: basePanel
    
    anchors { top: true; right: true }
    margins { top: 48; right: 8 }
    implicitWidth: 380
    implicitHeight: Math.max(1, column.implicitHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    ColumnLayout {
      id: column
      width: parent.width
      spacing: 10

      Repeater {
        model: server.trackedNotifications

        Rectangle {
          id: card
          required property var modelData

          Layout.fillWidth: true
          Layout.preferredHeight: layout.implicitHeight + 20
          radius: 8
          color: Colors.bgDark
          border.width: 1
          border.color: modelData.urgency === NotificationUrgency.Critical
          ? Colors.textError : Colors.textPrimary

          ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            
            Rectangle {
              Layout.preferredHeight: innerTop.height
              Layout.preferredWidth: parent.width
              radius: 20
              color: Colors.bgLight
              border.width: 2
              border.color: Colors.textPrimary

              RowLayout {
                id: innerTop
                anchors.margins: 12
                spacing: 12
              
                Image {
                  id: img
                  Layout.preferredHeight: 36
                  Layout.preferredWidth: 36
                  Layout.alignment: Qt.AlignTop
                  fillMode: Image.PreserveAspectFit
                  visible: source.toString() !== ""
                  source: card.modelData.image || card.modelData.appIcon || ""
                  layer.enabled: true
                  layer.effect: OpacityMask {
                    maskSource: Item {
                      width: img.width
                      height: img.height
                      Rectangle {
                        anchors.centerIn: parent
                        width: img.adapt ? img.width : Math.min(img.width, img.height)
                        height: img.adapt ? img.height : width
                        radius: Math.min(width, height)
                      }
                    }
                  }
                }

                Text {
                  Layout.fillWidth: true
                  text: card.modelData.summary
                  color: Colors.textPrimary
                  font.family: Fonts.fontFamily
                  font.pixelSize: Fonts.fontSize
                  font.bold: true
                  elide: Text.ElideRight
                }
              }
            }
            

            Rectangle {
              Layout.preferredHeight: body.height
              Layout.preferredWidth: parent.width
              color: "transparent"
              border.width: 1
              border.color: Colors.textPrimary
              radius: 4

              Text {
                id: body
                anchors.margins: 8
                visible: text !== ""
                text: card.modelData.body
                color: Colors.textPrimary
                font.family: Fonts.fontFamily
                font.pixelSize: Fonts.smallFontSize
                wrapMode: Text.WordWrap
              }
            }
          }
        }
      }
    }
  }
}
