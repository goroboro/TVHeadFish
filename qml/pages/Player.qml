// Large chunks of this code are lifted from Leszek Lesner's: LLsVideoPlayer
// Github repo where I stole this from https://github.com/llelectronics/videoPlayer
// Existing license info:
/*
Copyright (C) 2013 Leszek Lesner
Contact: Leszek Lesner <leszek.lesner@web.de>
All rights reserved.

You may use this file under the terms of BSD license as follows:

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of the Jolla Ltd nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import Sailfish.Media 1.0
import "helper"

Page {
    id: page
    allowedOrientations: Orientation.All
    property int videoDuration
    property string streamUrl
    property string channame
    property string title: videoPoster.player.metaData.title ? videoPoster.player.metaData.title : ""
    property string artist: videoPoster.player.metaData.albumArtist ? videoPoster.player.metaData.albumArtist : ""
    property alias videoPoster: videoPoster
    signal updateCover

    PageHeader {
        title: channame
        visible: page.orientation === Orientation.Portrait ? true : false
    }

    function videoPauseTrigger() {
        // this seems not to work somehow
        if (videoPoster.player.playbackState == MediaPlayer.PlayingState) videoPoster.player.pause();
        else if (videoPoster.source.toString().length !== 0) videoPoster.player.play();
        if (videoPoster.controls.opacity === 0.0) videoPoster.toggleControls();

    }

    SilicaFlickable {
        anchors.fill: parent

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
            id: mediaItem
            property bool active : true
            visible: active

            VideoPoster {
                id: videoPoster
                width: page.orientation === Orientation.Portrait ? Screen.width : Screen.height
                height: page.height

                player: mediaPlayer

                //duration: videoDuration
                active: mediaItem.active
                source: streamUrl
                onPlayClicked: toggleControls();

                function toggleControls() {
                    //console.debug("Controls Opacity:" + controls.opacity);
                    if (controls.opacity === 0.0) {
                        //console.debug("Show controls");
                        controls.opacity = 1.0;
                    }
                    else {
                        //console.debug("Hide controls");
                        controls.opacity = 0.0;
                    }
                    page.showNavigationIndicator = !page.showNavigationIndicator
                }


                onClicked: {
                    if (mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                        //console.debug("Mouse values:" + mouse.x + " x " + mouse.y)
                        var middleX = width / 2
                        var middleY = height / 2
                        if ((mouse.x >= middleX - 21 && mouse.x <= middleX + 21) && (mouse.y >= middleY - 21 && mouse.y <= middleY + 21)) {
                            mediaPlayer.pause();
                            if (controls.opacity === 0.0) toggleControls();
                            progressCircle.visible = false;
                        }
                        else {
                            toggleControls();
                        }
                    } else {
                        //mediaPlayer.play()
                        console.debug("clicked something else")
                        toggleControls();
                    }
                }
            }
        }
    }
    children: [
        GStreamerVideoOutput {
            id: video

            source: MediaPlayer {
                id: mediaPlayer
                onDurationChanged: {
                    videoPoster.duration = (duration/1000);
                }
                autoPlay: true
                onStatusChanged: {
                    if (mediaPlayer.status === MediaPlayer.Loading || mediaPlayer.status === MediaPlayer.Buffering || mediaPlayer.status === MediaPlayer.Stalled) progressCircle.visible = true;
                    else progressCircle.visible = false;
                }
            }

            visible: mediaPlayer.status >= MediaPlayer.Loaded && mediaPlayer.status <= MediaPlayer.EndOfMedia
            width: parent.width
            height: parent.height
            anchors.centerIn: page

            ScreenBlank {
                suspend: mediaPlayer.playbackState == MediaPlayer.PlayingState
            }
        }
    ]
}


