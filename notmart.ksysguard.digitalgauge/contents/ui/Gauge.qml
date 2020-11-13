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
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.8 as Kirigami

import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.ksysguard.faces 1.0 as Faces

import org.kde.quickcharts 1.0 as Charts
import org.kde.quickcharts.controls 1.0 as ChartControls

import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: chart

    Layout.minimumWidth: root.formFactor != backgrounds.Sensorbackground.Vertical ? Kirigami.Units.gridUnit * 4 : Kirigami.Units.gridUnit
    Layout.minimumHeight: root.formFactor == backgrounds.Sensorbackground.Vertical ? width : Kirigami.Units.gridUnit


    PlasmaCore.Svg {
        id: gaugeSvg
        imagePath: Qt.resolvedUrl("gauge.svg")
        property real ratio
        onRepaintNeeded: {
            ratio = gaugeSvg.elementRect("foreground").width / gaugeSvg.elementRect("foreground").height
        }
    }

    PlasmaCore.SvgItem {
        id: foreground
        readonly property real chartRatio: chart.width / chart.height
        width: chartRatio <= gaugeSvg.ratio ? chart.width : height * gaugeSvg.ratio
        height: chartRatio <= gaugeSvg.ratio ? width / gaugeSvg.ratio : chart.height

        anchors.centerIn: parent
        svg: gaugeSvg
        elementId: "foreground"
        readonly property real ratioX: foreground.width/gaugeSvg.elementRect("foreground").width
        readonly property real ratioY: foreground.height/gaugeSvg.elementRect("foreground").height

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
/*
        Repeater {
            id: handleRepeater
            model: root.controller.highPrioritySensorIds
            PlasmaCore.SvgItem {
                id: pointer
                svg: gaugeSvg
                elementId: "pointer"
                transformOrigin: Item.Top

                x: foreground.elementCenter("rotatecenter").x - width/2
                y: foreground.elementCenter("rotatecenter").y //- height/2
                width: foreground.elementSize("pointer").width
                height: foreground.elementSize("pointer").height
                // only 7.5 degrees increments
                rotation: index === 0
                    ? Math.round((75 + sensor.sensorRate * 210) / 7.5) * 7.5
                    : Math.round(( sensor.sensorRate * 210 + foreground.children[index-1].rotation) / 7.5) * 7.5
                Sensors.Sensor {
                    id: sensor
                    property real sensorRate: value/Math.max(value, maximum) || 0

                    sensorId: modelData
                }
            }
        }*/

        Controls.Label {
            color: "black"
            x: foreground.elementCenter("label0").x - width/2
            y: foreground.elementCenter("label0").y - height/2
            text: totalSensor.formattedValue
        }
    }

    ChartControls.PieChartControl {
        id: pie
        visible: false
        anchors.fill: foreground
        property alias sensors: sensorsModel.sensors
        property alias sensorsModel: sensorsModel

        Layout.minimumWidth: root.formFactor != Faces.SensorFace.Vertical ? Kirigami.Units.gridUnit * 4 : Kirigami.Units.gridUnit
        Layout.minimumHeight: root.formFactor == Faces.SensorFace.Vertical ? width : Kirigami.Units.gridUnit

        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        chart.smoothEnds: false
        chart.fromAngle: -110
        chart.toAngle: 110
        //chart.thickness: 80
        chart.filled: true

        range {
            from: root.controller.faceConfiguration.rangeFrom
            to: root.controller.faceConfiguration.rangeTo
            automatic: root.controller.faceConfiguration.rangeAuto
        }

        chart.backgroundColor: Qt.rgba(0.0, 0.0, 0.0, 0.3)

        text: root.controller.totalSensors.length == 1 ? sensor.formattedValue : ""

        valueSources: Charts.ModelSource {
            model: Sensors.SensorDataModel {
                id: sensorsModel
                sensors: root.controller.highPrioritySensorIds
            }
            roleName: "Value"
            indexColumns: true
        }
        chart.nameSource: Charts.ModelSource {
            roleName: "Name";
            model: valueSources[0].model;
            indexColumns: true
        }
        chart.shortNameSource: Charts.ModelSource {
            roleName: "ShortName";
            model: valueSources[0].model;
            indexColumns: true
        }
        chart.colorSource: root.colorSource
    }


    OpacityMask {
        cached: true
        anchors.fill: pie
        source: pie
        maskSource: foreground
    }

    Sensors.Sensor {
        id: totalSensor
        sensorId: root.controller.totalSensors[0]
    }
}

