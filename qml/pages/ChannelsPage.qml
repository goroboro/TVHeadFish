import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    property string hostName
    property string portNumber
    property string errorTxt

    SilicaListView {
        id: listView
        ViewPlaceholder {
            id: error
            enabled: errorTxt
            text: qsTr(errorTxt)
        }
        PullDownMenu {
            MenuItem {
                text: "Finished Recordings"
                onClicked: pageStack.replace(Qt.resolvedUrl("RecordingsPage.qml"),{ hostName: hostName, portNumber: portNumber })
            }
            MenuItem {
                text: "Scheduled Recordings"
                onClicked: pageStack.replace(Qt.resolvedUrl("UpcomingRecordings.qml"),{ hostName: hostName, portNumber: portNumber })
            }
        }
        Component.onCompleted: loadChannels(hostName,portNumber)
        ListModel {  id:channels }
        model: channels
        anchors.fill: parent
        header: PageHeader {
            title: "TV Channels"
        }
        delegate: BackgroundItem {
            id: delegate
            IconButton{
                id: iconButton
                //icon.source: chicon ? chicon : 'tv-icon.png' #this doesn't work with the new API... I need to work out how to get channel icons
                icon.source: 'tv-icon.png'
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 20
                icon.scale: 0.5

            }
            Label {
                x: Theme.paddingLarge
                text: name
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: iconButton.right
                anchors.leftMargin: 10
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: pageStack.push(Qt.resolvedUrl("ChannelSchedule.qml"),{ hostName: hostName, portNumber: portNumber, chanName: name, chid: uuid })
        }
        VerticalScrollDecorator {}
    }




    // this function is included locally, but you can also include separately via a header definition
   function loadChannels(hostName,portNumber) {
       channels.clear();
         var xhr = new XMLHttpRequest();
       var params = "sort=name&dir=ASC"
         var url = "http://"+hostName+":"+portNumber+"/api/channel/grid"
        xhr.open("POST",url,true);
        xhr.onreadystatechange = function()
         {
             if ( xhr.readyState == xhr.DONE)
             {
                 if ( xhr.status == 200)
                 {
                     var jsonObject = eval('(' + xhr.responseText + ')');
                     channels.append(jsonObject.entries)
                 }
                 else if (xhr.status==0) {
                     errorTxt="Unable to connect to "+url
                 }
                 else {
                     errorTxt=xhr.status+": "+xhr.statusText
                 }
             }
         }
         xhr.send(params);
     }

}





