import QtQuick 2.1
import QtGraphicalEffects 1.0
import Deepin.Widgets 1.0
/* import DBus.Com.Deepin.Daemon.Themes 1.0 */

Item {
    id: bubble
    y: - height
    width: content.width + 20 + 24 * 2
    height: content.height + 20
    layer.enabled: true

    property int leftPadding: (content.height - 48) / 2
    property int rightPadding: (content.height - 48) / 2
    property var notificationObj

    /* ThemeManager { id: dbus_theme_manager } */
    /* Theme {  */
    /*     id: dbus_theme  */
    /*     path: { */
    /*         var result = dbus_theme_manager.GetThemeByName(dbus_theme_manager.currentTheme)  */
    /*         return result[0] */
    /*     } */
    /* } */

    function isAnimating() {
        return out_animation.running
    }

    function mouseEnterAction() {
        out_timer.stop()
        close_button.visible = true
        action_area.visibleSwitch = true
    }

    function mouseExitAction() {
        close_button.visible = false
        action_area.visibleSwitch = false
        out_timer.restart()
    }

    PropertyAnimation {
        id: in_animation

        running: true
        target: bubble
        property: "y"
        to: 0
        duration: 300
        easing.type: Easing.OutCubic

        onStopped: out_timer.restart()
    }

    ParallelAnimation {
        id: out_animation

        PropertyAnimation {
            target: bubble
            property: "x"
            to: width
            duration: 500
            easing.type: Easing.OutCubic
        }

        PropertyAnimation {
            target: bubble
            property: "opacity"
            to: 0.2
            duration: 500
            easing.type: Easing.OutCubic
        }

        onStopped: _notify.expire()
    }

    Timer {
        id: out_timer

        interval: 3500
        onTriggered: {
            out_animation.start()
        }
    }
    
    function _processContentBody(body) {
        var result = body
        
        result = result.replace("\n", "<br>")
        
        return result
    }

    function updateContent(content) {
        if (x != 0 || opacity != 1) {
            x = 0
            opacity = 1
            y = -height
            in_animation.start()
        }
        out_timer.restart()

        notificationObj = JSON.parse(content)
        icon.icon = notificationObj.image_path || notificationObj.app_icon || "ooxx"
        summary.text = notificationObj.summary
        body.text = _processContentBody(notificationObj.body)
    }

    RectangularRing {
        id: ring
        visible: false
        outterWidth: innerWidth + 2
        outterHeight: innerHeight + 3
        outterRadius: content.radius + 2
        innerWidth: content.width
        innerHeight: content.height
        innerRadius: content.radius

        verticalCenterOffset: -2

        anchors.centerIn: parent
        anchors.verticalCenterOffset: 2
    }

    GaussianBlur {
        anchors.fill: ring
        source: ring
        radius: 8
        samples: 16
        transparentBorder: true
    }

    Rectangle {
        id: content
        radius: 4
        width: 300
        height: 70
        anchors.centerIn: parent

        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.8)}
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.95)}
        }

        Rectangle {
            id: bubble_border
            radius: 4
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.7)
            anchors.fill: parent

            Rectangle {
                id: bubble_inner_border
                radius: 4
                color: "transparent"
                border.color: Qt.rgba(1, 1, 1, 0.1)

                anchors.fill: parent
                anchors.topMargin: 1
                anchors.bottomMargin: 1
                anchors.leftMargin: 1
                anchors.rightMargin: 1
            }

            MouseArea {
                hoverEnabled: true
                anchors.fill: bubble_bg

                onEntered: bubble.mouseEnterAction()
                onExited: bubble.mouseExitAction()
                onClicked: {
                    var default_action_id
                    for (var i = 0; i < notificationObj.actions.length; i += 2) {
                        if (notificationObj.actions[i + 1] == "default") {
                            default_action_id = notificationObj.actions[i]
                        }
                    }
                    if (default_action_id) {_notify.sendActionInvokedSignal(notificationObj.id, default_action_id)}
                    _notify.dismiss()
                }
            }

            Item {
                id: bubble_bg
                anchors.fill: bubble_inner_border

                DIcon {
                    id: icon
                    width: 48
                    height: 48
                    theme: "Deepin"

                    anchors.left: parent.left
                    anchors.leftMargin: bubble.leftPadding
                    anchors.verticalCenter: parent.verticalCenter

                    property bool checkedFlag: false
                }

                Text {
                    id: summary
                    width: 200
                    elide: Text.ElideRight
                    font.pixelSize: 11
                    textFormat: Text.StyledText
                    color: Qt.rgba(1, 1, 1, 0.5)

                    anchors.left: icon.right
                    anchors.leftMargin: bubble.leftPadding
                    anchors.top: icon.top
                }

                Text {
                    id: body

                    color: "white"
                    wrapMode: Text.WrapAnywhere
                    linkColor: "#19A9F9"
                    textFormat: Text.StyledText
                    font.pixelSize: 11
                    maximumLineCount: 2

                    onLinkActivated: Qt.openUrlExternally(link)

                    anchors.left: summary.left
                    anchors.right: parent.right
                    anchors.rightMargin: bubble.rightPadding
                    anchors.top: summary.bottom
                    anchors.topMargin: 3
                }
            }

            LinearGradient {
                id: bubble_bg_mask
                visible: false
                anchors.fill: bubble_bg

                start: Qt.point(0, 0)
                end: Qt.point(width - action_area.width - action_area.anchors.rightMargin - close_button.width - close_button.anchors.rightMargin, 0)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 1)}
                    GradientStop { position: 0.8; color: Qt.rgba(0, 0, 0, 1)}
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0)}
                }
            }

            OpacityMask {
                id: opacity_mask
                visible: action_area.visible
                anchors.fill: bubble_bg
                source: ShaderEffectSource { sourceItem: bubble_bg; hideSource: opacity_mask.visible }
                maskSource: ShaderEffectSource { sourceItem: bubble_bg_mask; hideSource: opacity_mask.visible }
            }

            Item {
                id: action_area
                width: action_buttons.width
                height: action_buttons.height
                anchors.right: close_button.right
                anchors.rightMargin: bubble.rightPadding
                anchors.verticalCenter: bubble_bg.verticalCenter
                visible: visibleSwitch && action_area.actionsExceptDefault.length != 0

                property bool visibleSwitch: false

                property var actionsExceptDefault: {
                    var result = []
                    if (notificationObj) {
                        for (var i = 0; i < notificationObj.actions.length; i += 2) {
                            if (i + 1 < notificationObj.actions.length && notificationObj.actions[i + 1] != "default") {
                                result.push({"value": notificationObj.actions[i + 1], "key": notificationObj.actions[i]})
                            }
                        }
                    }
                    return result
                }

                Column {
                    id: action_buttons
                    spacing: 6
                    visible: parent.visible

                    ActionButton{
                        text: parent.visible ? action_area.actionsExceptDefault[0].value : ""

                        onEntered: bubble.mouseEnterAction()
                        onAction: {
                            _notify.sendActionInvokedSignal(notificationObj.id,
                                                            action_area.actionsExceptDefault[0].key)
                            _notify.dismiss()
                        }
                    }
                }
            }

            CloseButton {
                id: close_button
                anchors.top: bubble_bg.top
                anchors.right: bubble_bg.right
                anchors.topMargin: 5
                anchors.rightMargin: 6
                visible: false

                onEntered: bubble.mouseEnterAction()
                onClicked: _notify.dismiss()
            }
        }
    }
}
