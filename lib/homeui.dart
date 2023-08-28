// import 'dart:ui' show Color, FontWeight;

import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:mocheffendi.hilux_sensor/linechart.dart';
// import 'package:mocheffendi.hilux_sensor/temperaturepoints.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeUI extends StatefulWidget {
  final double temperature;
  final double humidity;
  const HomeUI({Key? key, required this.temperature, required this.humidity})
      : super(key: key);
  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  final limitCount = 100;
  final tempPoints = <FlSpot>[];
  final humiPoints = <FlSpot>[];

  double xValue = 0;
  double step = 5;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      while (tempPoints.length > limitCount) {
        tempPoints.removeAt(0);
        humiPoints.removeAt(0);
      }
      setState(() {
        tempPoints.add(FlSpot(xValue, widget.temperature));
        humiPoints.add(FlSpot(xValue, widget.humidity));
      });
      xValue += step;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  LineChartBarData tempLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      gradient: const LinearGradient(
        colors: [Colors.red, Colors.redAccent],
        // stops: [0.1, 1.0],
      ),
      barWidth: 2,
      isCurved: false,
    );
  }

  LineChartBarData humiLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: true,
      ),
      gradient: const LinearGradient(
        colors: [Colors.blue, Colors.blueGrey],
        // stops: [0.1, 1.0],
      ),
      barWidth: 2,
      isCurved: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // SizedBox(
              //   height: 100,
              //   width: double.infinity,
              //   child: SvgPicture.asset(
              //     "assets/roof.svg",
              //     fit: BoxFit.fill,
              //   ),
              // ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey)),
                width: double.infinity,
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SleekCircularSlider(
                        appearance: CircularSliderAppearance(
                            customWidths: CustomSliderWidths(
                                trackWidth: 2,
                                progressBarWidth: 10,
                                shadowWidth: 12),
                            customColors: CustomSliderColors(
                                trackColor: HexColor('#ef6c00'),
                                progressBarColor: HexColor('#ffb74d'),
                                shadowColor: HexColor('#ffb74d'),
                                shadowMaxOpacity: 0.5, //);
                                shadowStep: 12),
                            infoProperties: InfoProperties(
                                bottomLabelStyle: TextStyle(
                                    color: HexColor('#6DA100'),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600),
                                bottomLabelText: 'Temp.',
                                mainLabelStyle: TextStyle(
                                    color: HexColor('#54826D'),
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600),
                                modifier: (double value) {
                                  return '${widget.temperature} ˚C';
                                }),
                            startAngle: 90,
                            angleRange: 360,
                            size: 125.0,
                            animationEnabled: true),
                        min: 0,
                        max: 100,
                        initialValue: widget.temperature,
                      ),
                    ),
                    // const SizedBox(
                    //   height: 50,
                    // ),
                    SleekCircularSlider(
                      appearance: CircularSliderAppearance(
                          customWidths: CustomSliderWidths(
                              trackWidth: 2,
                              progressBarWidth: 10,
                              shadowWidth: 20),
                          customColors: CustomSliderColors(
                              trackColor: HexColor('#0277bd'),
                              progressBarColor: HexColor('#4FC3F7'),
                              shadowColor: HexColor('#B2EBF2'),
                              shadowMaxOpacity: 0.5, //);
                              shadowStep: 20),
                          infoProperties: InfoProperties(
                              bottomLabelStyle: TextStyle(
                                  color: HexColor('#6DA100'),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                              bottomLabelText: 'Humidity.',
                              mainLabelStyle: TextStyle(
                                  color: HexColor('#54826D'),
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600),
                              modifier: (double value) {
                                return '${widget.humidity} %';
                              }),
                          startAngle: 90,
                          angleRange: 360,
                          size: 125.0,
                          animationEnabled: true),
                      min: 0,
                      max: 100,
                      initialValue: widget.humidity,
                    ),
                    const SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
              tempPoints.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'x: ${xValue.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'temp: ${tempPoints.last.y.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'humi: ${humiPoints.last.y.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: LineChart(
                              LineChartData(
                                minY: 0,
                                maxY: 100,
                                minX: tempPoints.first.x,
                                maxX: humiPoints.last.x + 100,
                                lineTouchData:
                                    const LineTouchData(enabled: false),
                                clipData: const FlClipData.all(),
                                gridData: const FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                ),
                                borderData: FlBorderData(show: true),
                                lineBarsData: [
                                  tempLine(tempPoints),
                                  humiLine(humiPoints),
                                ],
                                titlesData: const FlTitlesData(
                                  show: true,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
