import 'package:bierdygame/app/modules/superAdmin/reportsAndAnalytics/widgets/finance_pie.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget buildPieChart({
  required double percent1,
  required double percent2,
   double? percent3,
   double? percent4,
   double? percent5,
  required String title,
  required String indicatorText1,
  required String indicatorText2,
  String? indicatorText3,
  String? indicatorText4,
  String? indicatorText5,
  Color? color1,
  Color? color2,
  Color? color3,
  Color? color4,
  Color? color5,
  int? playersPerClub,
  required List<PieChartSectionData> sections,

}) {

    return FinancePieChart(
      sections: sections,
      title:title,
      indicatorText1: indicatorText1,
      indicatorText2: indicatorText2,
      indicatorText3: indicatorText3,
      color: color1,
      indicatorText4:indicatorText4,
      indicatorText5: indicatorText5,
      color2: color2,
      color3:color3,
      color4: color4,
      color5: color5,
      playersPerClub: playersPerClub,
    );
  }
