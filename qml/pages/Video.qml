import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import Sailfish.Media 1.0
import org.nemomobile.thumbnailer 1.0

Page {
    id: page
    property string chan
    property string channame
    allowedOrientations: Orientation.All

    PageHeader {
        title: channame
    }

    ProgressCircle {
        id: progressCircle

        anchors.centerIn: parent
        visible: false

        Timer {
            interval: 32
            repeat: true
            onTriggered: progressCircle.value = (progressCircle.value + 0.005) % 1.0
            running: visible
        }
    }

    Item {
        id: player
        property string source: "http://192.168.0.3:9981/stream/channelid/"+chan
        //property string source: "http://netrunnerlinux.com/vids/default-panel-script.mkv"
        property Item _videoItem
        property Item _controlsItem

        // Playing: true, Paused: false
        property bool playing

        // Pauses playback.
        property bool suspend

        // Hint that the application is not active, or the player isn't the current item
        // and that the overlay should be hidden to prevent any rendering artifacts.  This
        // could be taken further and the video item itself unloaded in future.
        property bool active: true

        // Read only.
        property int position: _videoItem !== null ? _videoItem.position : 0.0
        property int duration: _videoItem !== null ? _videoItem.duration : 0.0
        property bool seekable: _videoItem !== null && _videoItem.seekable

        property real playbackRate: 1.0

        property real _scale: implicitHeight !== 0 ? height / implicitHeight : 1.0

        function play() {
            playing = true
        }

        function pause() {
            playing = false
        }

        function stop() {
            if (_videoItem !== null)
                _videoItem.stop()
        }

        function seek(position) {
            if (_videoItem !== null)
                _videoItem.position = position
        }

        implicitWidth: _videoItem === null || _videoItem.implicitWidth === 0
                ? poster.implicitWidth
                : _videoItem.implicitWidth
        implicitHeight: _videoItem === null || _videoItem.implicitHeight === 0
                ? poster.implicitHeight
                : _videoItem.implicitHeight


        onSourceChanged: if (_videoItem) _videoItem.destroy()

        onPlayingChanged: {
            if (playing) {
                if (_videoItem === null)
                    _videoItem = videoComponent.createObject(player)
                _videoItem.visible = true
            }
            _updatePlaybackState()
        }

        onActiveChanged: _updatePlaybackState()
        onSuspendChanged: _updatePlaybackState()

        function _updatePlaybackState() {
            if (!_videoItem) {
                return
            }

            if (player.playing && player.active && !player.suspend) {
                _videoItem.play()
            } else if (player.playing
                        || player.active
                        || _videoItem.playbackState != MediaPlayer.Stopped) {
                _videoItem.pause()
            } else {
                player.stop()
            }
        }


        Thumbnail {
                id: poster

                anchors.centerIn: parent

                width: poster.implicitWidth * player._scale
                height: poster.implicitHeight * player._scale

                sourceSize.width: screen.height
                sourceSize.height: screen.height

                priority: Thumbnail.HighPriority
                fillMode: Thumbnail.PreserveAspectFit
                visible: _videoItem === null || !_videoItem.visible
            }


        Component {
            id: videoComponent

            GStreamerVideoOutput {
                id: _videoItem

                property alias playbackState: _mediaPlayer.playbackState
                property alias position: _mediaPlayer.position
                property alias duration: _mediaPlayer.duration
                property alias seekable: _mediaPlayer.seekable

                function play() { _mediaPlayer.play() }
                function pause() { _mediaPlayer.pause() }
                function stop() { _mediaPlayer.stop() }

                width: _videoItem.implicitWidth * player._scale
                height: _videoItem.implicitHeight * player._scale

                anchors.centerIn: parent
                source: _mediaPlayer

                visible: player.active
                        && _mediaPlayer.status >= MediaPlayer.Loaded
                        && _mediaPlayer.status <= MediaPlayer.EndOfMedia

                MediaPlayer {
                    id: _mediaPlayer
                    source: player.source
                    playbackRate: player.playbackRate
                    onError: {
                                        errorTxt.text = error;
                                        errorDetail.text = errorString;
                                    }

                    onPlaybackStateChanged: {
                        if (playbackState != MediaPlayer.PlayingState) {
                            player.playing = false
                        }
                        if (playbackState == MediaPlayer.StoppedState) {
                            visible = false
                        }
                    }
                }
            }
        }
    }
}
