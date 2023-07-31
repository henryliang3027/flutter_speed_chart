import 'package:flutter/material.dart';
import 'package:flutter_speed_chart/src/date_value_pair.dart';

class LineSeries {
  const LineSeries({
    required this.name,
    required this.dataList,
    required this.color,
    this.maxYAxisValue,
    this.minYAxisValue,
  });

  final String name;
  final List<DateValuePair> dataList;
  final Color color;
  final double? maxYAxisValue;
  final double? minYAxisValue;
}
