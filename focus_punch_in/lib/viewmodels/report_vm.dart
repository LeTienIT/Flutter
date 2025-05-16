
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:focus_punch_in/models/work_session.dart';

class Report_vm extends ChangeNotifier{
  int month;
  final int year;
  final List<WorkSession> sourceList;

  int totalWorkingDays = 0;
  int checkedInDays = 0;
  int missingCheckoutDays = 0;
  int absentDays = 0;
  int remainingWorkingDays = 0;
  double totalWorkPoints = 0;

  Report_vm(this.month, this.year, this.sourceList){
    _calculate();
  }

  void _calculate(){
    totalWorkingDays = 0;
    checkedInDays = 0;
    missingCheckoutDays = 0;
    absentDays = 0;
    remainingWorkingDays = 0;
    totalWorkPoints = 0;

    final today = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(this.year, this.month);

    final List<DateTime> workingDays = [];
    for(int i = 1; i <= daysInMonth; i++){
      final day = DateTime(year,month,i);
      if(day.weekday != DateTime.sunday){
        totalWorkingDays++;
        if (month == today.month && year == today.year && day.isAfter(today)) {
          remainingWorkingDays++;
          continue;
        }
        workingDays.add(DateTime(year, month, i));
      }
    }

    for(final workDay in workingDays){
      final match = sourceList.where((entry) => isSameDate(entry.day, workDay)).toList();
      final WorkSession? matchedSession = match.isNotEmpty ? match.first : null;

      if (matchedSession == null) {
        absentDays++;
      }else {
        bool checkedIn = matchedSession.getCheckIn != null && matchedSession.getCheckIn != '--|--';
        bool checkedOut = matchedSession.getCheckOut != null && matchedSession.getCheckOut != '--|--';

        if (checkedIn && !checkedOut) {
          checkedInDays++;
          missingCheckoutDays++;
          totalWorkPoints += 0.5;
        } else if (checkedIn && checkedOut) {
          checkedInDays++;
          totalWorkPoints += 1;
        } else if (!checkedIn && checkedOut) {
          totalWorkPoints += 0.5;
        }
      }
    }

    notifyListeners();
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isSameDayOrBefore(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day <= b.day;


  void updateMonth(int newMonth){
    this.month = newMonth;
    _calculate();
  }
}