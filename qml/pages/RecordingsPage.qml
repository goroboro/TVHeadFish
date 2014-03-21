import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    property string hostName
    property string portNumber
    property string recName

    SilicaListView {
        id: listView
        PullDownMenu {
            MenuItem {
                text: "Channels"
                onClicked: pageStack.replace(Qt.resolvedUrl("ChannelsPage.qml"),{ hostName: hostName, portNumber: portNumber })
            }
            MenuItem {
                text: "Scheduled Recordings"
                onClicked: pageStack.replace(Qt.resolvedUrl("UpcomingRecordings.qml"),{ hostName: hostName, portNumber: portNumber })
            }
        }
        header: PageHeader {
            id: pageHeader
            title: "Finished Recordings"
        }
        Component.onCompleted: loadRecordings(hostName,portNumber)
        ListModel {  id:recordings }
        model: recordings
        anchors.fill: parent
        delegate: BackgroundItem {
            id: delegate
            Label {
                x: Theme.paddingLarge
                text: title
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            property string streamUrl: "http://"+hostName+":"+portNumber+"/"+url
            onClicked: pageStack.push(Qt.resolvedUrl("Player.qml"),{ streamUrl: streamUrl, channame: title })
        }
        VerticalScrollDecorator {}
    }



    // this function is included locally, but you can also include separately via a header definition
   function loadRecordings(hostName,portNumber) {
       recordings.clear()
       var http = new XMLHttpRequest()
       var url = "http://"+hostName+":"+portNumber+"/dvrlist_finished";
               http.open("GET", url, true);

               http.onreadystatechange = function() { // Call a function when the state changes.
                           if (http.readyState == 4) {
                               if (http.status == 200) {
                                   {
                                       var jsonObject = eval('(' + http.responseText + ')');
                                       recordings.append(jsonObject.entries)
                                   }
                               } else {
                                   console.log("error: " + http.status)
                               }
                           }
                       }
               http.send();
           }

}
