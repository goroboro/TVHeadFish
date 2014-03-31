import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    property string hostName
    property string portNumber
    property string chanName
    property string recId
    property string recTitle
    property string recDescr
    property string start
    property string end
    property string duration
    property string schedState
    property string url

    SilicaFlickable {
        id: progView
        anchors.fill: parent
        PageHeader {
            id: pageHeader
            title: chanName
        }
        Component.objectName: {
            if (schedState == "scheduled") {
                isScheduled.visible = true
            }
            else if (schedState=="recording"){
                isScheduled.visible = true
                isScheduled.text="Currently Recording"
            }
            else if (url) {
                    isRecorded.visible = true
            }
        }

        PullDownMenu {
            MenuItem {
                text: "Channels"
                onClicked: pageStack.replace(Qt.resolvedUrl(
                                                 "ChannelsPage.qml"), {
                                                 hostName: hostName,
                                                 portNumber: portNumber
                                             })
            }
            MenuItem {
                text: "Scheduled Recordings"
                onClicked: pageStack.replace(Qt.resolvedUrl(
                                                 "UpcomingRecordings.qml"), {
                                                 hostName: hostName,
                                                 portNumber: portNumber
                                             })
            }
            MenuItem {
                text: "Finished Recordings"
                onClicked: pageStack.replace(Qt.resolvedUrl(
                                                 "RecordingsPage.qml"), {
                                                 hostName: hostName,
                                                 portNumber: portNumber
                                             })
            }
        }
        Item {
            id: progData
            width: page.width
            anchors.top: pageHeader.bottom
            Label {
                id: progtitle
                x: Theme.paddingLarge
                text: recTitle + ' (' + Qt.formatDateTime(
                          new Date(start * 1000),
                          "HH:mm") + '-' + Qt.formatDateTime(
                          new Date(end * 1000), "HH:mm") + ')'
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                color: Theme.primaryColor
            }
            TextArea {
                id: progdescr
                anchors.top: progtitle.bottom
                text: recDescr + '\nDuration: ' + duration + '\nChannel:' + chanName
                width: parent.width
            }
            Text {
                id: isScheduled
                anchors.top: progdescr.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Scheduled for Record"
                visible: false
                color: Theme.primaryColor
            }
            Button {
                id: isRecorded
                anchors.top: progdescr.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Watch this Recording"
                property string streamUrl: "http://" + hostName + ":" + portNumber + "/" + url
                onClicked: pageStack.push(Qt.resolvedUrl("Player.qml"), {
                                              streamUrl: streamUrl,
                                              channame: recTitle
                                          })
                visible: false
            }
        }

        VerticalScrollDecorator {
        }
    }

}
