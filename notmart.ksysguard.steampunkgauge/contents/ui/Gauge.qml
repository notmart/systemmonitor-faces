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
import QtQuick.Particles 2.0
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


    ParticleSystem {
        id: particles
        x: face.x + (face.width/5 * 4)
        y: face.y + (face.height/5 * 4)
        width: 1
        height: Kirigami.Units.gridUnit
        rotation: 135

        ImageParticle {
            groups: "steam"
            anchors.fill: parent
            source: "qrc:///particleresources/glowdot.png"
            colorVariation: 0.1
            color: "white"
        }

        Emitter {
            id: emitter
            anchors.fill: parent
            group: "steam"
            emitRate: steamTimer.running && !steamOffTimer.running ? Math.round(face.width * sensor.sensorRate) : 0
            // Only if there is a background is allowed to exit from boundaries
            lifeSpan: Math.min(chart.width, chart.height) * 6
            size: 1
            sizeVariation: 5
            endSize: Kirigami.Units.gridUnit * 2

            shape: LineShape {
               
            }
            velocity: TargetDirection {
                targetX: emitter.width/2
                targetY: 0
                proportionalMagnitude: true
                magnitude: 3
                targetVariation: 2.5
            }
        }
        Timer {
            id: steamTimer
            repeat: true
            running: root.controller.faceConfiguration.showSteam && sensor.sensorRate > 0.8
            interval: 8000
            onTriggered: steamOffTimer.restart()
        }
        Timer {
            id: steamOffTimer
            interval: 2000
        }
    }

    PlasmaCore.Svg {
        id: gaugeSvg
        imagePath: Qt.resolvedUrl("gauge.svg")
    }

    PlasmaCore.SvgItem {
        id: face
        width: Math.min(chart.width, chart.height)
        height: width
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
            svg: gaugeSvg
            elementId: "pointer-shadow"
            transformOrigin: Item.Center
            x: face.elementCenter("rotatecenter").x - width/2
            y: face.elementCenter("rotatecenter").y - height/2 + 3
            width: face.elementSize("pointer-shadow").width
            height: face.elementSize("pointer-shadow").height
            rotation: pointer.rotation
        }

        PlasmaCore.SvgItem {
            id: pointer
            svg: gaugeSvg
            elementId: "pointer"
            transformOrigin: Item.Center
            x: face.elementCenter("rotatecenter").x - width/2
            y: face.elementCenter("rotatecenter").y - height/2
            width: face.elementSize("pointer").width
            height: face.elementSize("pointer").height
            rotation: 45 + sensor.sensorRate * 270

            Behavior on rotation {
                RotationAnimation {
                    id: rotationAnim
                    target: pointer
                    duration: Kirigami.Units.longDuration * 8
                    easing.type: Easing.OutElastic
                } 
            }
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

