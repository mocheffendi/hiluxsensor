import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SensorTempCircular extends StatefulWidget {
  final double temperature;

  const SensorTempCircular({super.key, required this.temperature});

  @override
  State<SensorTempCircular> createState() => _SensorTempCircularState();
}

class _SensorTempCircularState extends State<SensorTempCircular> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                                text: 'Temperature',
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
                                        '${widget.temperature} °C',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ))
                                ],
                                pointers: <GaugePointer>[
                                  RangePointer(
                                    value: widget.temperature,
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
                      ],
                    ),
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
