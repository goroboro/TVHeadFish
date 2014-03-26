import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    property string hostName
    property string portNumber
    property string errorTxt
    property string tagId: 'None'
    property string pageTitle: 'Channels'
    ListModel { id: tagsmodel }
    Component.onCompleted: {
        loadTags(hostName,portNumber,tagId);
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
                text: "Finished Recordings"
                onClicked: pageStack.replace(Qt.resolvedUrl("RecordingsPage.qml"),{ hostName: hostName, portNumber: portNumber })
            }
            MenuItem {
                text: "Scheduled Recordings"
                onClicked: pageStack.replace(Qt.resolvedUrl("UpcomingRecordings.qml"),{ hostName: hostName, portNumber: portNumber })
            }
        }

        ListModel {  id:channels }
        model: channels
        anchors.fill: parent
        header: PageHeader {
            id: heading
            title: pageTitle
        }
        delegate: BackgroundItem {
            id: delegate

            IconButton{
                id: iconButton
                icon.source: typeof(model.icon_public_url) == "undefined" ? "tv-icon.png" : model.icon_public_url
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


    function loadTags(hostName,portNumber,tagId){
        tagsmodel.clear()
        var tagReq = new XMLHttpRequest();
        var tagparams = "table=channeltags&op=get"
        var url = "http://"+hostName+":"+portNumber+"/tablemgr"
       tagReq.open("POST",url,true);
       tagReq.onreadystatechange = function()
        {
            if ( tagReq.readyState == tagReq.DONE)
            {
                if ( tagReq.status == 200)
                {
                    var jsonObject = eval('(' + tagReq.responseText + ')');
                    if(tagId==='None'){
                        loadChannels(hostName,portNumber,jsonObject.entries[0].id)
                        pageTitle=jsonObject.entries[0].name
                    }
                    var menuItems = ''
                    for (var i = 0; i < jsonObject.entries.length; i++) {
                        if(jsonObject.entries[i].enabled==1){
                            //console.log(jsonObject.entries[i].name)
                            tagsmodel.append(jsonObject.entries[i])

                            menuItems = menuItems + 'MenuItem {\ntext: "'+jsonObject.entries[i].name+'";\nonClicked:pageStack.replace(Qt.resolvedUrl("ChannelsPage.qml"),{ hostName: "'+hostName+'", portNumber: "'+portNumber+'", tagId: "'+jsonObject.entries[i].id+'" })\n}\n'

                            if(tagId==jsonObject.entries[i].id){
                                //console.log('loading channels for tag: '+tagId)
                                loadChannels(hostName,portNumber,tagId)
                                pageTitle=jsonObject.entries[i].name
                            }
                        }
                    }
                    //console.log("got tags")
                    var qmlText='import QtQuick 2.0;\nimport Sailfish.Silica 1.0;\nPushUpMenu {\nid: tagMenu\n'+menuItems+'\n}'
                    //console.log(qmlText)
                    Qt.createQmlObject(qmlText, listView, "tagMenu")
                }
                else if (tagReq.status==0) {
                    errorTxt="Unable to connect to "+url
                    console.log('tags url wrong')
                }
                else {
                    errorTxt=tagReq.status+": "+tagReq.statusText
                    console.log('tags error'+tagReq.responseText)
                }
            }
        }
        tagReq.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        tagReq.send(tagparams);
    }

    // this function is included locally, but you can also include separately via a header definition
   function loadChannels(hostName,portNumber,tag) {
       channels.clear();
         var xhr = new XMLHttpRequest();
         var params = "sort=number&dir=ASC"
         var url = "http://"+hostName+":"+portNumber+"/api/channel/grid"
        xhr.open("POST",url,true);
        xhr.onreadystatechange = function()
         {
             if ( xhr.readyState == xhr.DONE)
             {
                 if ( xhr.status == 200)
                 {
                     var jsonObject = eval('(' + xhr.responseText + ')');
                     jsonObject.entries.sort(function(a, b){
                         return a.number-b.number
                        })
                     for (var i = 0; i < jsonObject.entries.length; i++) {
                         if(jsonObject.entries[i].tags.join(" ").indexOf(tag)>=0){
                             channels.append(jsonObject.entries[i])
                             //console.log(i+": "+jsonObject.entries[i].name)
                         }
                     }
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





