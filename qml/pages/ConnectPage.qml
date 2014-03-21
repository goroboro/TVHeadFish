import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0 as LS

Page {
    id: page
    Component.onCompleted: {
        console.debug("Load Database...")
        initialize()
    }
    SilicaFlickable {
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: item.height

        Item {
            id: item
            anchors.fill: parent
            height: page.height
            Component.onCompleted: getSettings()

            TextField {
                id: hostName
                property string dbHost
                placeholderText: "Hostname or IP address"
                text: dbHost ? dbHost : ''
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 20
            }

            TextField {
                id: portNumber
                property string dbPort
                placeholderText: "Port (e.g. 9981)"
                text: dbPort ? dbPort : ''
                anchors.top: hostName.bottom
                width: parent.width - 20
            }

            Button {
                id: searchBtn
                anchors.top: portNumber.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Connect"
                onClicked: {
                    addSettings(hostName.text,portNumber.text)
                    pageStack.push(Qt.resolvedUrl("ChannelsPage.qml"), {
                                       hostName: hostName.text,
                                       portNumber: portNumber.text
                                   })
                }
            }

        }
    }

    function getDatabase() {
        return LS.LocalStorage.openDatabaseSync("TVHeadFish", "0.1", "StorageDatabase", 100000);
    }

    function initialize() {
        var db = getDatabase();
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(id INTEGER PRIMARY KEY AUTOINCREMENT, hostname TEXT, port TEXT)');
                    });
    }

    // This function is used to write tune into the database
    function addSettings(hostname,port) {
        var db = getDatabase();
        var res = "";
        db.transaction(function(tx) {
            var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?,?);', [1,hostname,port]);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
                console.log ("Error saving to database");
            }
        }
        );
        return res;
    }


    function getSettings() {
        var db = getDatabase();
        var respath="";
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM settings;');
            if (rs.rows.length > 0) {
                //console.log("Item in db")
                hostName.dbHost=rs.rows.item(0).hostname
                //console.log(rs.rows.item(0).hostname)
                portNumber.dbPort=rs.rows.item(0).port
                //console.log(rs.rows.item(0).port)
            }

        })
    }



}


