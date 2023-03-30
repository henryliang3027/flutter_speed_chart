import 'package:flutter/material.dart';
import 'package:flutter_speed_chart/src/date_value_pair.dart';

class LineSeries {
  const LineSeries({
    required this.name,
    required this.dataList,
    required this.color,
  });

  final String name;
  final List<DateValuePair> dataList;
  final Color color;
}
