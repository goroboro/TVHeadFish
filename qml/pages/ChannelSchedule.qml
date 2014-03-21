import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    property string hostName
    property string portNumber
    property string chanName
    property string chid
    property string streamUrl: "http://"+hostName+":"+portNumber+"/stream/channel/"+chid

    SilicaListView {
        id: listView
        header: PageHeader {
            id: pageHeader
            title: chanName
        }

        PullDownMenu {
            MenuItem {
                text: "Scheduled Recordings"
                onClicked: pageStack.replace(Qt.resolvedUrl("UpcomingRecordings.qml"),{ hostName: hostName, portNumber: portNumber })
            }
            MenuItem {
                text: "Finished Recordings"
                onClicked: pageStack.replace(Qt.resolvedUrl("RecordingsPage.qml"),{ hostName: hostName, portNumber: portNumber })
            }
            MenuItem {
                text: "Watch "+chanName+" Live"
                onClicked: pageStack.push(Qt.resolvedUrl("Player.qml"),{ streamUrl: streamUrl, channame: chanName })
            }
        }
        Component.onCompleted: loadChanSched(hostName,portNumber,chid)
        ListModel {  id:chansched }
        model: chansched
        anchors.fill: parent
        delegate: BackgroundItem {
            id: delegate
            Label {
                x: Theme.paddingLarge
                text: title+' ('+ Qt.formatDateTime(new Date(start * 1000), "HH:mm")+'-'+ Qt.formatDateTime(new Date(end * 1000), "HH:mm")+')'
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: pageStack.push(Qt.resolvedUrl("ProgramPage.qml"),{
                                          hostName: hostName,
                                          portNumber: portNumber,
                                          chanName: chanName,
                                          chid: chid,
                                          progId: id,
                                          progTitle: title,
                                          progDescr: description,
                                          start: start,
                                          end: end,
                                          duration: duration
                                      })

        }
        VerticalScrollDecorator {}
    }



    // this function is included locally, but you can also include separately via a header definition
   function loadChanSched(hostName,portNumber,chid) {
       chansched.clear()
       var http = new XMLHttpRequest()
       var url = "http://"+hostName+":"+portNumber+"/epg";
               var params = "start=0&limit=20&channel="+chid;
               http.open("POST", url, true);

               // Send the proper header information along with the request
               http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
               http.setRequestHeader("Content-length", params.length);
               http.setRequestHeader("Connection", "close");

               http.onreadystatechange = function() { // Call a function when the state changes.
                           if (http.readyState == 4) {
                               if (http.status == 200) {
                                   {
                                       var jsonObject = eval('(' + http.responseText + ')');
                                       chansched.append(jsonObject.entries)
                                   }
                               } else {
                                   console.log("error: " + http.status)
                               }
                           }
                       }
               http.send(params);
           }

}
