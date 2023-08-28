import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SensorHumiCircular extends StatefulWidget {
  final double humidity;

  const SensorHumiCircular({super.key, required this.humidity});

  @override
  State<SensorHumiCircular> createState() => _SensorHumiCircularState();
}

class _SensorHumiCircularState extends State<SensorHumiCircular> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          // width: 170,
          // height: 200,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const RadialGradient(
                  colors: [
                    Color.fromARGB(255, 88, 119, 122),
                    Color.fromARGB(255, 94, 53, 69),
                    Color.fromARGB(255, 217, 12, 97),
                  ],
                  center: Alignment(1, 1),
                  focal: Alignment(1, 0),
                  focalRadius: 1.0)),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        // ignore: sized_box_for_whitespace
                        Container(
                          width: 150,
                          height: 180,
                          child: SfRadialGauge(
                            title: GaugeTitle(
                                text: 'Humidity',
                                textStyle:
                                    Theme.of(context).textTheme.titleLarge),
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: 100,
                                showLabels: false,
                                showTicks: false,
                                startAngle: 90,
                                endAngle: 90,
                                axisLineStyle: AxisLineStyle(
                                  thickness: 1,
                                  color: Theme.of(context).cardColor,
                                  thicknessUnit: GaugeSizeUnit.factor,
                                ),
                                annotations: [
                                  GaugeAnnotation(
                                      positionFactor: 0.5,
                                      angle: 0,
                                      widget: Text(
                                        '${widget.humidity} °C',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ))
                                ],
                                pointers: <GaugePointer>[
                                  RangePointer(
                                    value: widget.humidity,
                                    width: 0.15,
                                    color: Color.fromARGB(255, 88, 119, 122),
                                    pointerOffset: 0.1,
                                    cornerStyle: CornerStyle.bothCurve,
                                    sizeUnit: GaugeSizeUnit.factor,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        // Positioned(
                        //   top: 5,
                        //   left: 5,
                        //   child: Container(
                        //       width: 50,
                        //       height: 50,
                        //       decoration: const BoxDecoration(
                        //           shape: BoxShape.circle, color: Colors.white),
                        //       child: null),
                        //   // const GreenDoneIcon()),
                        // ),
                        // Positioned(
                        //   top: 170,
                        //   left: 75,
                        //   child: Center(
                        //     child: Text(
                        //       widget.temperature.toString(),
                        //       style: GoogleFonts.lato(
                        //           color: Colors.white,
                        //           fontWeight: FontWeight.bold,
                        //           fontSize: 24),
                        //     ),
                        //     // Text(
                        //     //   widget.humidity.toString(),
                        //     //   style: GoogleFonts.lato(color: Colors.white),
                        //     // ),
                        //   ),
                        // ),
                      ],
                    ),

                    // const SizedBox(height: 40),
                    // Container(
                    //   decoration: BoxDecoration(
                    //       color: Colors.grey[200],
                    //       border: Border.all(color: Colors.grey)),
                    //   // width: double.infinity,
                    //   height: 200,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //     children: [
                    //       // Container(
                    //       //   width: 150,
                    //       //   height: 150,
                    //       //   decoration: BoxDecoration(
                    //       //     color: Colors.black87,
                    //       //     borderRadius: BorderRadius.circular(8.0),
                    //       //   ),
                    //       //   child: SleekCircularSlider(
                    //       //     appearance: CircularSliderAppearance(
                    //       //         customWidths: CustomSliderWidths(
                    //       //             trackWidth: 2,
                    //       //             progressBarWidth: 10,
                    //       //             shadowWidth: 12),
                    //       //         customColors: CustomSliderColors(
                    //       //             trackColor: HexColor('#ef6c00'),
                    //       //             progressBarColor: HexColor('#ffb74d'),
                    //       //             shadowColor: HexColor('#ffb74d'),
                    //       //             shadowMaxOpacity: 0.5, //);
                    //       //             shadowStep: 12),
                    //       //         infoProperties: InfoProperties(
                    //       //             bottomLabelStyle: TextStyle(
                    //       //                 color: HexColor('#6DA100'),
                    //       //                 fontSize: 10,
                    //       //                 fontWeight: FontWeight.w600),
                    //       //             bottomLabelText: 'Temp.',
                    //       //             mainLabelStyle: TextStyle(
                    //       //                 color: HexColor('#54826D'),
                    //       //                 fontSize: 20.0,
                    //       //                 fontWeight: FontWeight.w600),
                    //       //             modifier: (double value) {
                    //       //               return '${widget.temperature} ˚C';
                    //       //             }),
                    //       //         startAngle: 90,
                    //       //         angleRange: 360,
                    //       //         size: 125.0,
                    //       //         animationEnabled: true),
                    //       //     min: 0,
                    //       //     max: 100,
                    //       //     initialValue: widget.temperature,
                    //       //   ),
                    //       // ),
                    //       // const SizedBox(
                    //       //   height: 50,
                    //       // ),

                    //       const SizedBox(
                    //         height: 30,
                    //       )
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
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
