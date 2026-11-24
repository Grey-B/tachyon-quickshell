import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Scope {
  id: root
  property bool centerOpen: false

  ListModel { id: history }

  NotificationServer {
    id: server
    actionsSupported: true
    bodySupported: true
    imageSupported: true

    onNotification: n => {
      history.insert(0, {
        summary: n.summary,
        body: n.body,
        appName: n.appName,
        urgency: n.urgency,
        time: Qt.formatDateTime(new Date(), "HH:mm")
      })
      n.tracked = true
    }
  }

  IpcHandler {
    target: "notifications"
    function toggle(): void { root.centerOpen = !root.centerOpen }
    function show(): void { root.centerOpen = true }
    function hide(): void { root.centerOpen = false }
  }

  //Notification center
  PanelWindow {
    id: notifCenter
    visible: root.centerOpen

    anchors { top: true; right: true }
    margins { top: 48; right: 8 }
    implicitWidth: 380
    implicitHeight: centerCol.implicitHeight + 24
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    
    Rectangle {
      anchors.fill: parent
      radius: 10
      color: Colors.bgDark
      border.width: 2
      border.color: Colors.textAccent
    }

    ColumnLayout {
      id: centerCol
      anchors.fill: parent
      anchors.margins: 12
      spacing: 10

      RowLayout {
        Layout.fillWidth: true

        Text {
          Layout.fillWidth: true
          text: "Notifications"
          color: Colors.textAccent
          font.family: Fonts.fontFamily
          font.pixelSize: Fonts.fontSize
          font.bold: true
        }

        Rectangle {
          implicitHeight: clearAllText.height
          implicitWidth: clearAllText.width
          color: Colors.textError
          radius: 12

          Text {
            anchors.fill: parent
            id: clearAllText
            text: "Clear all"
            visible: history.count > 0
            color: Colors.shadow
            font.family: Fonts.fontFamily
            font.pixelSize: Fonts.smallFontSize
          }

          MouseArea {
            anchors.fill: parent
            onClicked: history.clear()
          }
        }
      }
    }
  }

  // Notifications
  PanelWindow {
      id: notifsPanel
    
    anchors { top: true; right: true }
    margins { top: 48; right: 8 }
    implicitWidth: 380
    implicitHeight: Math.max(1, columnNotifs.implicitHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    ColumnLayout {
      id: columnNotifs
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
          gradient: Gradient {
            GradientStop { position: 0.0; color: Colors.bgDark}
            GradientStop { position: 1.0; color: Colors.bgLight }
          }
          border.width: 2
          border.color: modelData.urgency === NotificationUrgency.Critical
          ? Colors.textError : Colors.textPrimary

          Timer {
            running: card.modelData.urgency !== NotificationUrgency.Critical
            interval: 5000
            onTriggered: card.modelData.dismiss()
          }

          ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            
            Rectangle {
              Layout.preferredHeight: title.height
              Layout.preferredWidth: parent.width
              radius: 20
              color: Colors.bgLight
              border.width: 2
              border.color: Colors.textPrimary

              RowLayout {
                id: title
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12
              
                Image {
                  id: img
                  Layout.preferredHeight: 40
                  Layout.preferredWidth: 40
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
              Layout.preferredHeight: body.height + 32
              Layout.preferredWidth: parent.width
              color: "transparent"
              border.width: 1
              border.color: Colors.textPrimary
              radius: 4

              Text {
                id: body
                anchors.topMargin: 16
                anchors.bottomMargin: 16
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.top: parent.top
                anchors.left: parent.left

                visible: text !== ""
                text: card.modelData.body
                color: Colors.textPrimary
                font.family: Fonts.fontFamily
                font.pixelSize: Fonts.smallFontSize
                wrapMode: Text.WordWrap
              }
            }
          }

          MouseArea {
            anchors.fill: parent
            onClicked: card.modelData.dismiss()
          }
        }
      }
    }
  }
}
