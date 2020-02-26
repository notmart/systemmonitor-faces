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

import org.kde.kirigami 2.8 as Kirigami

import org.kde.ksgrd2 0.1 as KSGRD
import org.kde.quickcharts 1.0 as Charts

import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: chart

    Layout.minimumWidth: plasmoid.formFactor != PlasmaCore.Types.Vertical ? Kirigami.Units.gridUnit * 4 : Kirigami.Units.gridUnit
    Layout.minimumHeight: plasmoid.formFactor == PlasmaCore.Types.Vertical ? width : Kirigami.Units.gridUnit


    Repeater {
        model: plasmoid.configuration.sensorIds.length

        ParticleSystem {
            id: particles
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height)
            height: width

            ImageParticle {
                groups: [plasmoid.configuration.sensorIds[index]]
                anchors.fill: parent
                source: "qrc:///particleresources/glowdot.png"
                colorVariation: 0.1
                color: plasmoid.configuration.sensorColors[index]
                RotationAnimator on rotation {
                    from: 0
                    to: 360
                    duration: 30000
                    running: true
                    loops: Animation.Infinite
                }
            }

            Emitter {
                id: emitter
                anchors.fill: parent
                group: plasmoid.configuration.sensorIds[index]
                emitRate: particleSensor.value ? Math.round(500 * (parseInt(particleSensor.value)/particleSensor.maximum)) : 0
                lifeSpan: 2000
                size: particles.width / 20
                sizeVariation: 3
                endSize: 0


                KSGRD.Sensor {
                    id: particleSensor
                    sensorId: plasmoid.configuration.sensorIds[index]
                }
                shape: EllipseShape {
                    fill: false
                    
                }
                velocity: TargetDirection {
                    targetX: emitter.width/2
                    targetY: emitter.height/2
                    proportionalMagnitude: true
                    magnitude: 0.5
                }
            }
        }
    }

    Kirigami.Heading {
        anchors.centerIn: parent
        visible: width <= chart.width
        level: 2
        text: sensor.formattedValue
    }
    KSGRD.Sensor {
        id: sensor
        sensorId: plasmoid.configuration.totalSensor
    }
}

