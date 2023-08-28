import 'package:flutter/material.dart';
import 'package:mocheffendi.hilux_sensor/widget/sensor_temp_circular.dart';
import 'package:mocheffendi.hilux_sensor/widget/sensor_humi_circular.dart';

class SensorView extends StatefulWidget {
  final double temperature;
  final double humidity;
  const SensorView({
    Key? key,
    required this.temperature,
    required this.humidity,
  }) : super(key: key);

  @override
  State<SensorView> createState() => _SensorViewState();
}

class _SensorViewState extends State<SensorView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Column(
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     SensorCard(
          //       humidity: _humidity,
          //       temperature: _temp,
          //     ),
          //     const SensorCard(
          //       humidity: 80,
          //       temperature: 36.5,
          //     ),
          //   ],
          // ),
          const SizedBox(
            height: 0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SensorTempCircular(temperature: widget.temperature),
              SensorHumiCircular(humidity: widget.humidity),
            ],
          )
        ],
      ),
    );
  }
}
