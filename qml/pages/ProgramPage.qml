import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    property string hostName
    property string portNumber
    property string chanName
    property string chid
    property string progId
    property string progTitle
    property string progDescr
    property string start
    property string end
    property string duration
    property string streamUrl: "http://"+hostName+":"+portNumber+"/stream/channel/"+chid

    SilicaFlickable {
        id: progView
        anchors.fill: parent
        PageHeader {
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
                onClicked: pageStack.replace(Qt.resolvedUrl("Player.qml"),{ streamUrl: streamUrl, channame: chanName })
            }
        }
        Item{
            id: progData
            Component.onCompleted: onSchedule(hostName,portNumber,progTitle,start)
            width: page.width
            anchors.top: pageHeader.bottom
        Label {
                id: progtitle
                x: Theme.paddingLarge
                text: progTitle+' ('+ Qt.formatDateTime(new Date(start * 1000), "HH:mm")+'-'+ Qt.formatDateTime(new Date(end * 1000), "HH:mm")+')'
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                color: Theme.primaryColor
        }
        TextArea {
            id: progdescr
            anchors.top: progtitle.bottom
            text: progDescr + '\n Duration: '+duration
            width: parent.width
        }
        Button {
            id: recordBtn
            anchors.top: progdescr.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Record This"
            onClicked: {
                recordThis(hostName,portNumber,progId)
            }
        }
        Text {
            id: isRecording
            anchors.top: progdescr.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Scheduled for Record"
            visible: false
            color: Theme.primaryColor
        }
        }



        VerticalScrollDecorator {}
    }



    // this function is included locally, but you can also include separately via a header definition
   function recordThis(hostName,portNumber,progId) {
       var http = new XMLHttpRequest()
       var url = "http://"+hostName+":"+portNumber+"/dvr";
       console.log("Attempting to record "+progId+ "at "+url)
               var params = "eventId="+progId+"&op=recordEvent"
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
                                       if(jsonObject.success){
                                           recordBtn.visible=false
                                           isRecording.visible=true
                                       }
                                   }
                               } else {
                                   console.log("error: " + http.status)
                               }
                           }
                       }
               http.send(params);
           }

   function onSchedule(hostName,portNumber,progTitle,start) {
       var http = new XMLHttpRequest()
       var url = "http://"+hostName+":"+portNumber+"/dvrlist_upcoming";
       console.log("Checking if "+progTitle+ " at "+start+" is in the scheduled recordings list")
               http.open("GET", url);
               http.onreadystatechange = function() { // Call a function when the state changes.
                           if (http.readyState == 4) {
                               if (http.status == 200) {
                                   {
                                       var jsonObject = eval('(' + http.responseText + ')');
                                       for (var i = 0; i < jsonObject.entries.length; i++) {
                                           if (jsonObject.entries[i].title == progTitle && jsonObject.entries[i].start == start){
                                               console.log('scheduled recording for '+ jsonObject.entries[i].start)
                                           recordBtn.visible=false
                                           isRecording.visible=true
                                           }
                                       }
                                   }
                               } else {
                                   console.log("error: " + http.status)
                               }
                           }
                       }
               http.send();
           }
}
