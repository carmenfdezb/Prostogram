import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0

import "../components"
import "../Helper.js" as Helper
import "../MediaStreamMode.js" as MediaStreamMode
import "../js/Settings.js" as Setting
import "../Storage.js" as Storage

Page {

    allowedOrientations:  Orientation.All

    property var user
    property var recentMediaData

    property bool relationStatusLoaded : false
    property var relationStatus;

    property bool privateProfile : false;
    property bool recentMediaLoaded: false;

    property bool errorAtUserMediaRequestOccurred : false

    property string rel_outgoing_status : "";
    property string rel_incoming_status : "";

    property bool isSelf: false;

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if(app.user.pk === user.pk)
            {
                isSelf = true;
                followingMenuItem.visible = true
                followersMenuItem.visible = true
                followMenuItem.visible = false
                unFollowMenuItem.visible = false

            }
            else
            {
                isSelf = false;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Setting.STYLE_COLOR_BACKGROUND
    }

    SilicaFlickable {
        id: allView
        anchors.fill: parent
        contentHeight: column.height + header.height + 10
        contentWidth: parent.width

        PageHeader {
            id: header
            title: user.username
            _titleItem.color: Setting.STYLE_COLOR_FONT
        }

        Column {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            id: column
            spacing: Theme.paddingSmall

            UserDetailBlock { }

            Label {
                id: incomingRelLabel
                text: getOutgoingText()
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Setting.STYLE_COLOR_FONT
                truncationMode: TruncationMode.Fade
                visible: text!==""
                font.pixelSize: Setting.profileFontSize();
                function getOutgoingText() {
                    if(!relationStatus)
                    {
                        return "";
                    }
                    if(relationStatus.following)
                        return qsTr("You follow %1").arg(user.username);
                    if(relationStatus.outgoing_request)
                        return qsTr("You requested to follow %1").arg(user.username);
                    return ""
                }
            }

            Label {
                text: getIncomingText()
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Setting.STYLE_COLOR_FONT
                truncationMode: TruncationMode.Fade
                visible: text!==""
                font.pixelSize: Setting.profileFontSize();

                function getIncomingText() {
                    if(!relationStatus)
                    {
                        return "";
                    }

                    if(relationStatus.followed_by)
                        return qsTr("%1 follows you").arg(user.username);
                    if(relationStatus.incoming_request)
                        return qsTr("%1 requested to follow you").arg(user.username);
                    if(relationStatus.blocking)
                        return qsTr("You blocked %1").arg(user.username)
                    return ""
                }
            }

            Label {
                text: user.full_name
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Setting.STYLE_COLOR_FONT
                truncationMode: TruncationMode.Fade
                font.bold: true
                font.pixelSize: Setting.profileFontSize();
                visible: user.full_name !== "" ? true : false

            }

            Label {
                text: user.biography !== undefined ? user.biography : ""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                font.pixelSize: Setting.profileFontSize();
                color: Setting.STYLE_COLOR_FONT
                visible: text!==""
                wrapMode: Text.Wrap

            }

            Label {
                text: user.external_url !== undefined ? '<a href="'+user.external_url+'">'+user.external_url+'</a>' : ""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium

                font.pixelSize: Setting.profileFontSize();
                color: Setting.STYLE_COLOR_FONT
                visible: text !== ""
                truncationMode: TruncationMode.Fade
            }


            Label {
                id: privatelabel
                text: qsTr("This profile is private.")
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                font.pixelSize: Setting.profileFontSize();
                color: Setting.STYLE_COLOR_FONT
                visible: false
            }


            BusyIndicator {
                running: visible
                visible: !recentMediaLoaded
                anchors.horizontalCenter: parent.horizontalCenter
            }


            Item {
                id: gridHeader

                height: Theme.itemSizeMedium
                width: parent.width
                visible: !privatelabel.visible


                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: parent.width/2

                    Rectangle {
                        anchors.fill:parent
                        color: Setting.STYLE_COLOR_BUTTON
                        opacity: 0.1
                    }

                    Label {
                        font.pixelSize: Setting.profileFontSize();
                        color: Setting.STYLE_COLOR_FONT

                        text: "#tags"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingMedium
                    }

                    MouseArea {
                        id: mouseAreaHeaderTag
                        anchors.fill: parent
                        onClicked: pageStack.push(Qt.resolvedUrl("MediaStreamPage.qml"),{mode : MediaStreamMode.TAG_MODE,
                                                      streamData: recentMediaData,tag: user.username, streamTitle: user.username})
                    }
                }

                Rectangle {
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: parent.width/2

                    Rectangle {
                        anchors.fill: parent
                        color: Setting.STYLE_COLOR_BUTTON
                        opacity : 0.1
                    }

                    Label {
                        font.pixelSize: Setting.profileFontSize();
                        color: Setting.STYLE_COLOR_FONT
                        text: user.username
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingMedium

                    }

                    MouseArea {
                        id: mouseAreaHeader
                        anchors.fill: parent
                        onClicked: pageStack.push(Qt.resolvedUrl("MediaStreamPage.qml"),{mode : MediaStreamMode.USER_MODE,
                                                      streamData: recentMediaData,tag: user.pk, streamTitle: user.username})
                    }
                }
            }


            GridView {
                width: parent.width
                height: cellHeight * (recentMediaModel.count/3)
                //contentHeight: allView.height
                cellWidth: width/3
                cellHeight: cellWidth

                clip: true

                anchors {
                    left: parent.left
                    right: parent.right
                }

                model: recentMediaModel

                delegate: Item {
                    property var item: model
                    width: parent.width/3
                    height: width

                    MainItemLoader {
                        id: mainLoader
                        anchors.fill: parent
                        width: parent.width
                        clip: true
                        preview: true
                        autoVideoPlay: false
                        isSquared: true
                    }

                    MouseArea {
                        id: mousearea
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../pages/SingleMediaPage.qml"),{singleItem: item});
                        }
                    }
                }

            }
        }


        PullDownMenu {
            MenuItem {
                id: logoutItem
                text: qsTr("Logout")
                visible: isSelf
                color: Setting.STYLE_COLOR_FONT
                onClicked: {
                    Storage.set("username", "");
                    Storage.set("password", "");
                    app.need_login = true;
                    instagram.logout();
                }
            }

            MenuItem {
                id: followersMenuItem
                visible: isSelf
                color: Setting.STYLE_COLOR_FONT
                text:  qsTr("Followers")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("UserListPage.qml"),{pageTitle:qsTr("Followers"), userId: user.pk});
                }
            }

            MenuItem {
                id: followingMenuItem
                visible: isSelf
                color: Setting.STYLE_COLOR_FONT
                text:  qsTr("Following")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("UserListPage.qml"),{pageTitle:qsTr("Following"), userId: user.pk});
                }
            }

            MenuItem {
                id: unFollowMenuItem
                color: Setting.STYLE_COLOR_FONT
                visible: !isSelf && !relationStatus.following
                text:  qsTr("Unfollow %1").arg(user.username)
                onClicked: {
                    instagram.unFollow(user.pk);
                }
            }

            MenuItem {
                id: followMenuItem
                color: Setting.STYLE_COLOR_FONT
                visible: !isSelf &&  relationStatus.following
                text: qsTr("Follow %1").arg(user.username)
                onClicked: {
                    instagram.follow(user.pk);
                }
            }
        }
    }

    ListModel {
        id: recentMediaModel
    }


    Component.onCompleted: {
        instagram.getUserFeed(user.pk)
        instagram.getInfoById(user.pk)

        refreshCallback = null
        if(app.user.pk === user.pk)
        {
            isSelf = true;
            relationStatus = JSON.parse('{"following": "", "status": "ok"}')
        }
        else
        {
            isSelf = false;
            instagram.getFriendship(user.pk);
        }
    }


    function reloadFinished(data) {
        if(data.meta.code === 200) {
            user = data.data;
        } else {
            privateProfile = true;
        }
    }

    Connections {
        target: instagram
        onUserFeedDataReady: {
            var data = JSON.parse(answer);
            if(data === undefined || data.items === undefined) {
                recentMediaLoaded=true;
                return;
            }
            recentMediaData = data
            for(var i=0; i<data.items.length; i++) {
                recentMediaModel.append(data.items[i]);
            }
            recentMediaLoaded=true;
        }
        onInfoByIdDataReady: {
            var out = JSON.parse(answer);
            user = out.user
        }
        onFollowDataReady: {
            relationStatusLoaded = false;
            instagram.getFriendship(user.pk);
        }
        onUnfollowDataReady: {
            relationStatusLoaded = false;
            instagram.getFriendship(user.pk);
        }
        onFriendshipDataReady: {
            relationStatus = JSON.parse(answer)
            //print(answer);
            if(!isSelf)
            {
                followMenuItem.visible = !relationStatus.following
                unFollowMenuItem.visible = relationStatus.following
            }
            else
            {
                followMenuItem.visible = false
                unFollowMenuItem.visible = false
            }

            if(relationStatus.is_private)
            {
                privatelabel.visible = true
            }

            //print(Theme.fontSizeExtraSmall+"-" +Theme.fontSizeTiny+"-" +Theme.fontSizeSmall+"-" +Theme.fontSizeMedium+"-" +Theme.fontSizeLarge
            //      +"-" +Theme.fontSizeHuge+"-" +Theme.fontSizeExtraLarge);

            relationStatusLoaded = true;
        }
    }
}
