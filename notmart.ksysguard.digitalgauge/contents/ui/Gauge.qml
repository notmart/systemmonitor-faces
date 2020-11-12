/*
 *   Copyright 2019 Marco Martin <mart@kde.org>
 *   Copyright 2019 David Edmundson <davidedmundson@kde.org>
 *   Copyright 2019 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2 as Controls

import org.kde.kirigami 2.8 as Kirigami

import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.faces 1.0 as Faces

import org.kde.quickcharts 1.0 as Charts

import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: chart

    Layout.minimumWidth: root.formFactor != Faces.SensorFace.Vertical ? Kirigami.Units.gridUnit * 4 : Kirigami.Units.gridUnit
    Layout.minimumHeight: root.formFactor == Faces.SensorFace.Vertical ? width : Kirigami.Units.gridUnit


    PlasmaCore.Svg {
        id: gaugeSvg
        imagePath: Qt.resolvedUrl("gauge.svg")
        property real ratio
        onRepaintNeeded: {
            ratio = gaugeSvg.elementRect("background").width / gaugeSvg.elementRect("background").height
        }
    }

    PlasmaCore.SvgItem {
        id: face
        width: chart.width
        height: width / gaugeSvg.ratio

        anchors.centerIn: parent
        svg: gaugeSvg
        elementId: "background"
        readonly property real ratioX: face.width/gaugeSvg.elementRect("background").width
        readonly property real ratioY: face.height/gaugeSvg.elementRect("background").height

        function elementPos(element) {
            var rect = gaugeSvg.elementRect(element);
            return Qt.point(rect.x * ratioX, rect.y * ratioY);
        }

        function elementCenter(element) {
            var rect = gaugeSvg.elementRect(element);
            return Qt.point(rect.x * ratioX + (rect.width * ratioX)/2, rect.y * ratioY + (rect.height * ratioY)/2);
        }

        function elementSize(element) {
            var rect = gaugeSvg.elementRect(element);
            return Qt.size(rect.width * ratioX, rect.height * ratioY);
        }

        PlasmaCore.SvgItem {
            id: pointer
            svg: gaugeSvg
            elementId: "pointer"
            transformOrigin: Item.TopCenter
            x: face.elementCenter("rotatecenter").x - width/2
            y: face.elementCenter("rotatecenter").y - height/2
            width: face.elementSize("pointer").width
            height: face.elementSize("pointer").height
            //rotation: 45 + sensor.sensorRate * 270
            rotation: 45 + rot * 270
property real rot: 0
NumberAnimation{
    target: pointer
    property: rot
    from: 0
    to: 1
    duration: 1000
    loops: Animation.Infinite
    running: true
}
            /*Behavior on rotation {
                RotationAnimation {
                    id: rotationAnim
                    target: pointer
                    duration: Kirigami.Units.longDuration * 8
                    easing.type: Easing.OutElastic
                } 
            }*/
        }

        Controls.Label {
            color: "black"
            x: face.elementCenter("label0").x - width/2
            y: face.elementCenter("label0").y - height/2
            text: totalSensor.formattedValue
        }
    }

    Sensors.Sensor {
        id: totalSensor
        sensorId: root.controller.totalSensors[0]
    }
    Sensors.Sensor {
        id: sensor
        property real sensorRate: value/Math.max(value, maximum) || 0

        sensorId: root.controller.highPrioritySensorIds[0]
    }
}

