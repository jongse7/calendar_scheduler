import 'package:calendar_scheduler/const/color.dart';
import 'package:flutter/material.dart';

class TodayBanner extends StatelessWidget {
  final DateTime selectedDay;
  final int scheduleCount;

  const TodayBanner({required this.selectedDay, required this.scheduleCount, super.key});

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );

    return Container(
      color: PRIMARY_COLOR,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${selectedDay.year}년 ${selectedDay.month}월' '${selectedDay.day}일',
            style: defaultTextStyle,),
            Text('$scheduleCount개',
            style: defaultTextStyle,),
          ],
        ),
      ),
    );
  }
}
