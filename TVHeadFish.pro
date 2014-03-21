# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = TVHeadFish

CONFIG += sailfishapp

SOURCES += src/TVHeadFish.cpp

OTHER_FILES += qml/TVHeadFish.qml \
    qml/cover/CoverPage.qml \
    rpm/TVHeadFish.spec \
    rpm/TVHeadFish.yaml \
    TVHeadFish.desktop \
    qml/pages/helper/VideoPoster.qml \
    qml/pages/Player.qml \
    qml/pages/ConnectPage.qml \
    qml/pages/ChannelsPage.qml \
    qml/pages/ChannelSchedule.qml \
    qml/pages/RecordingsPage.qml \
    qml/pages/helper/TVHeadFish.py \
    qml/pages/ProgramPage.qml \
    qml/pages/UpcomingRecordings.qml

