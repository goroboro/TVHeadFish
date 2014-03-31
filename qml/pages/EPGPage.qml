import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    property string hostName
    property string portNumber
    property string errorTxt
    property string ecgId: 'None'
    property string pageTitle: 'Programme Schedule'
    ListModel { id: ecgmodel }
    Component.onCompleted: {
        loadECG(hostName,portNumber,ecgId);
    }
    SilicaListView {
        id: listView
        ViewPlaceholder {
            id: error
            enabled: errorTxt
            text: qsTr(errorTxt)
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
                text: "Finished Recordings"
                onClicked: pageStack.replace(Qt.resolvedUrl("RecordingsPage.qml"),{ hostName: hostName, portNumber: portNumber })
            }
            MenuItem {
                text: "Scheduled Recordings"
                onClicked: pageStack.replace(Qt.resolvedUrl("UpcomingRecordings.qml"),{ hostName: hostName, portNumber: portNumber })
            }
        }

        ListModel {  id:epg }
        model: epg
        anchors.fill: parent
        header: PageHeader {
            id: heading
            title: pageTitle
        }
        delegate: BackgroundItem {
            id: delegate
            Label {
                id: itemTitle
                x: Theme.paddingLarge
                text: title
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                font.pixelSize: Theme.fontSizeSmall
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            Label {
                x: Theme.paddingLarge
                text: channel+' ('+ Qt.formatDateTime(new Date(start * 1000), "dd/MM HH:mm")+'-'+ Qt.formatDateTime(new Date(end * 1000), "HH:mm")+')'
                anchors.verticalCenter: parent.verticalCenter
                anchors.top: itemTitle.bottom
                anchors.leftMargin: 10
                font.pixelSize: Theme.fontSizeExtraSmall
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: pageStack.push(Qt.resolvedUrl("ProgramPage.qml"),{
                                          hostName: hostName,
                                          portNumber: portNumber,
                                          chanName: channel,
                                          chid: channelid,
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


    function loadECG(hostName,portNumber,ecgId){
        ecgmodel.clear()
        var ecgReq = new XMLHttpRequest();
        var url = "http://"+hostName+":"+portNumber+"/ecglist"
       ecgReq.open("GET",url,true);
       ecgReq.onreadystatechange = function()
        {
            if ( ecgReq.readyState == ecgReq.DONE)
            {
                if ( ecgReq.status == 200)
                {
                    var jsonObject = eval('(' + ecgReq.responseText + ')');
                    if(ecgId==='None'){
                        loadEPG(hostName,portNumber,'None')
                    }
                    var menuItems = ''
                    for (var i = 0; i < jsonObject.entries.length; i++) {
                            //console.log(jsonObject.entries[i].name)
                            ecgmodel.append(jsonObject.entries[i])

                            menuItems = menuItems + 'MenuItem {\ntext: "'+jsonObject.entries[i].name+'";\nonClicked:pageStack.replace(Qt.resolvedUrl("EPGPage.qml"),{ hostName: "'+hostName+'", portNumber: "'+portNumber+'", ecgId: "'+jsonObject.entries[i].code+'" })\n}\n'

                            if(ecgId==jsonObject.entries[i].code){
                                //console.log('loading channels for tag: '+tagId)
                                loadEPG(hostName,portNumber,ecgId)
                                pageTitle=jsonObject.entries[i].name
                            }
                    }
                    //console.log("got tags")
                    var qmlText='import QtQuick 2.0;\nimport Sailfish.Silica 1.0;\nPushUpMenu {\nid: ecgMenu\n'+menuItems+'\n}'
                    //console.log(qmlText)
                    Qt.createQmlObject(qmlText, listView, "ecgMenu")
                }
                else if (ecgReq.status==0) {
                    errorTxt="Unable to connect to "+url
                    console.log('tags url wrong')
                }
                else {
                    errorTxt=ecgReq.status+": "+ecgReq.statusText
                    console.log('tags error'+ecgReq.responseText)
                }
            }
        }
        ecgReq.send();
    }

    // this function is included locally, but you can also include separately via a header definition
   function loadEPG(hostName,portNumber,eid) {
       epg.clear();
         var xhr = new XMLHttpRequest();
         if(eid==='None'){
             var params = "start=0&limit=30";
         }
         else {
             var params = "start=0&limit=100&contenttype="+eid;
         }
         var url = "http://"+hostName+":"+portNumber+"/epg"
        xhr.open("POST",url,true);
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        xhr.setRequestHeader("Content-length", params.length);
        xhr.setRequestHeader("Connection", "close");
        xhr.onreadystatechange = function()
         {
             if ( xhr.readyState == xhr.DONE)
             {
                 if (xhr.status == 200) {
                             var jsonObject = eval('(' + xhr.responseText + ')');
                             jsonObject.entries.sort(function(a, b){
                             return a.start-b.start
                             })
                             epg.append(jsonObject.entries)
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





