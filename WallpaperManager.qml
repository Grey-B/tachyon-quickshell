import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Scope {
  id: root

  property string searchText: ""
  property string previewPath: ""

  function applyWallpaper(path) {
    WallpaperService.setWallpaper(path);
  }

  IpcHandler {
    target: "wallpaper"

    function toggle(): void {
      wallpaperPanel.visible = !wallpaperPanel.visible;
      if (wallpaperPanel.visible) {
        root.searchText = "";
        root.previewPath = "";
        searchInput.forceActiveFocus();
        if (WallpaperService.wallpapers.length === 0) WallpaperService.rescan();
      }
    }
  }

  property var filteredWallpapers: {
    const q = searchText.toLowerCase();
    if (q === "") return WallpaperService.wallpapers;
    return WallpaperService.wallpapers.filter(p => {
      const name = p.split("/").pop().toLowerCase();
      return name.includes(q);
    });
  }

  PanelWindow {
    id: wallpaperPanel
    visible: false
    focusable: true
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-wallpaper"

    exclusionMode: ExclusionMode.Ignore

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    // Dark overlay backdrop
    MouseArea {
      anchors.fill: parent
      onClicked: wallpaperPanel.visible = false

      Rectangle {
        anchors.fill: parent
        color: "transparent"
      }
    }

    // Main wallpaper picker box
    Rectangle {
      anchors.centerIn: parent
      width: 720
      height: 560
      radius: 16
      gradient: Gradient {
            GradientStop { position: 0.0; color: Colors.bgLight }
            GradientStop { position: 1.0; color: Colors.bgDark }
        }
      border.color: Colors.shadow
      border.width: 1

      MouseArea {
        anchors.fill: parent
        onClicked: event => event.accepted = true
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
          Layout.fillWidth: true
          spacing: 12

          Text {
            text: "󰸉  Wallpaper"
            color: Colors.textAccent
            font.pixelSize: 14
            font.family: Fonts.fontFamily
            font.bold: true
          }

          Item { Layout.fillWidth: true }

          Text {
            text: root.filteredWallpapers.length + " images"
            color: Colors.textPrimary
            font.pixelSize: 11
            font.family: Fonts.fontFamily
          }

          // Refresh button
          Rectangle {
            width: 28
            height: 28
            radius: 14
            color: refreshHover.containsMouse ? Colors.bgDark : "transparent"
            Accessible.role: Accessible.Button
            Accessible.name: "Refresh wallpaper list"

            Text {
              anchors.centerIn: parent
              text: "󰑐"
              color: Colors.bgLight
              font.pixelSize: 14
              font.family: Fonts.fontFamily
            }

            MouseArea {
              id: refreshHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: WallpaperService.rescan()
            }
          }
        }

        // Search
        Rectangle {
          Layout.fillWidth: true
          height: 36
          radius: 8
          color: Colors.bgDark
          border.color: searchInput.activeFocus ? Colors.textAccent : Colors.shadow
          border.width: 1

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            Text {
              text: ""
              color: Colors.textPrimary
              font.pixelSize: 13
              font.family: Fonts.fontFamily
              Layout.alignment: Qt.AlignVCenter
            }

            TextInput {
              id: searchInput
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignVCenter
              color: Colors.textPrimary
              font.pixelSize: 13
              font.family: Fonts.fontFamily
              clip: true
              selectByMouse: true
              Accessible.role: Accessible.EditableText
              Accessible.name: "Search wallpapers"
              onTextChanged: root.searchText = text

              Keys.onEscapePressed: {
                if (root.previewPath !== "") {
                  root.previewPath = "";
                } else {
                  wallpaperPanel.visible = false;
                }
              }
            }

            Text {
              text: "Search wallpapers..."
              color: Colors.textPrimary
              font.pixelSize: 13
              font.family: Fonts.fontFamily
              visible: searchInput.text === "" && !searchInput.activeFocus
            }
          }
        }

        // Wallpaper grid
        GridView {
          id: wallpaperGrid
          Layout.fillWidth: true
          Layout.fillHeight: true
          cellWidth: Math.floor(width / 4)
          cellHeight: cellWidth * 0.6 + 8
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          model: root.filteredWallpapers

          delegate: Item {
            required property string modelData
            required property int index

            Accessible.role: Accessible.Button
            Accessible.name: modelData.split("/").pop() + (WallpaperService.currentWallpaper === modelData ? ", current wallpaper" : "")

            width: wallpaperGrid.cellWidth
            height: wallpaperGrid.cellHeight

            Rectangle {
              anchors.fill: parent
              anchors.margins: 4
              radius: 8
              color: Colors.bgDark
              border.color: WallpaperService.currentWallpaper === modelData ? Colors.textAccent : (imgHover.containsMouse ? Colors.shadow : "transparent")
              border.width: WallpaperService.currentWallpaper === modelData ? 2 : 1
              clip: true

              Image {
                anchors.fill: parent
                anchors.margins: 2
                source: "file://" + modelData
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 200
                sourceSize.height: 120
                asynchronous: true

                Rectangle {
                  anchors.fill: parent
                  color: Colors.bgDark
                  visible: parent.status !== Image.Ready

                  Text {
                    anchors.centerIn: parent
                    text: "󰋩"
                    color: Colors.textPrimary
                    font.pixelSize: 24
                    font.family: Fonts.fontFamily
                  }
                }
              }

              // Filename label
              Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 22
                color: Qt.rgba(0, 0, 0, 0.6)

                Text {
                  anchors.centerIn: parent
                  text: modelData.split("/").pop()
                  color: "#ffffff"
                  font.pixelSize: 9
                  font.family: Fonts.fontFamily
                  elide: Text.ElideMiddle
                  width: parent.width - 8
                  horizontalAlignment: Text.AlignHCenter
                }
              }

              // Active indicator
              Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 6
                width: 20
                height: 20
                radius: 10
                color: Colors.textAccent
                visible: WallpaperService.currentWallpaper === modelData

                Text {
                  anchors.centerIn: parent
                  text: ""
                  color: Colors.bgLight
                  font.pixelSize: 12
                  font.family: Fonts.fontFamily
                }
              }

              MouseArea {
                id: imgHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                  if (mouse.button === Qt.RightButton) {
                    root.previewPath = modelData;
                  } else {
                    root.applyWallpaper(modelData);
                  }
                }
              }
            }
          }

          // Empty state
          Text {
            anchors.centerIn: parent
            text: "󰋩  No wallpapers found\nAdd images to ~/Pictures/Wallpapers/"
            color: Colors.textPrimary
            font.pixelSize: 13
            font.family: Fonts.fontFamily
            horizontalAlignment: Text.AlignHCenter
            visible: wallpaperGrid.count === 0
          }
        }

        // Footer
        RowLayout {
          Layout.fillWidth: true
          spacing: 16

          Row {
            spacing: 4
            Rectangle {
              width: hintClick.width + 8; height: 18; radius: 4; color: Colors.bgMuted
              Text { id: hintClick; anchors.centerIn: parent; text: "click"; color: Colors.textPrimary; font.pixelSize: 10; font.family: Fonts.fontFamily }
            }
            Text { text: "apply"; color: Colors.textPrimary; font.pixelSize: 10; font.family: Fonts.fontFamily; anchors.verticalCenter: parent.verticalCenter }
          }

          Row {
            spacing: 4
            Rectangle {
              width: hintRight.width + 8; height: 18; radius: 4; color: Colors.bgMuted
              Text { id: hintRight; anchors.centerIn: parent; text: "right-click"; color: Colors.textPrimary; font.pixelSize: 10; font.family: Fonts.fontFamily }
            }
            Text { text: "preview"; color: Colors.textPrimary; font.pixelSize: 10; font.family: Fonts.fontFamily; anchors.verticalCenter: parent.verticalCenter }
          }

          Row {
            spacing: 4
            Text { text: "Backend: " + WallpaperService.backend; color: Colors.textPrimary; font.pixelSize: 10; font.family: Fonts.fontFamily; anchors.verticalCenter: parent.verticalCenter }
          }

          Item { Layout.fillWidth: true }
        }
      }
    }

    // Preview overlay
    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0, 0, 0, 0.85)
      visible: root.previewPath !== ""

      MouseArea {
        anchors.fill: parent
        onClicked: root.previewPath = ""
      }

      Image {
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: parent.height * 0.8
        source: root.previewPath !== "" ? "file://" + root.previewPath : ""
        fillMode: Image.PreserveAspectFit
        asynchronous: true
      }

      // Apply button
      Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 40
        width: applyRow.width + 32
        height: 40
        radius: 20
        color: Colors.textAccent
        Accessible.role: Accessible.Button
        Accessible.name: "Apply wallpaper"

        Row {
          id: applyRow
          anchors.centerIn: parent
          spacing: 8

          Text {
            text: ""
            color: Colors.bgLight
            font.pixelSize: 14
            font.family: Fonts.fontFamily
            anchors.verticalCenter: parent.verticalCenter
          }
          Text {
            text: "Apply Wallpaper"
            color: Colors.bgLight
            font.pixelSize: 13
            font.family: Fonts.fontFamily
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.applyWallpaper(root.previewPath);
            root.previewPath = "";
          }
        }
      }
    }
  }
}