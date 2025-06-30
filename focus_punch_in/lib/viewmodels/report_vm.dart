
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:focus_punch_in/models/work_session.dart';
import 'package:focus_punch_in/viewmodels/time_sheet_vm.dart';

import '../services/SharedPrefService.dart';

class Report_vm extends ChangeNotifier{
  int month;
  bool isLoad = false;
  final int year;
  late TimeSheetVM? vm;
  late List<WorkSession> sourceList;
  ///tổng ngày công trong tháng
  int totalWorkingDays = 0;
  ///số ngày làm việc còn lại trong tháng
  int remainingWorkingDays = 0;
  ///số ngày nghỉ làm
  int absentDays = 0;
  ///số ngày không điểm danh khi về
  int missingCheckoutDays = 0;
  ///tổng số công hiện tại
  double totalWorkPoints = 0;
  ///số ngày đi muộn
  int soNgayDiMuon = 0;
  ///số ngày về sớm
  int soNgayVeSom = 0;
  ///số ngày đi muộn không quá số phút quy định
  int soNgayDiMuonKhongQuaPhut = 0;

  late int gioVao;
  late int phutVao;
  late int gioRa;
  late int phutRa;

  late int soNgayDuocDiMuon;
  late int soPhutDuocDiMuon;
  late int soPhepTrongThang;

  int get soNgayDiMuonHopLe => soNgayDiMuonKhongQuaPhut <= soNgayDuocDiMuon ? soNgayDiMuonKhongQuaPhut : soNgayDuocDiMuon;
  int get soNgayDiMuonBiTru => soNgayDiMuon - soNgayDiMuonHopLe >=0 ?(soNgayDiMuon - soNgayDiMuonHopLe) : 0;

  double encodeDateTimeToDouble(DateTime dt) => dt.hour + dt.minute / 60.0;

  Map<String, int> bieuDoTronNgayLam = {};
  Map<String, int> bieuDoTronDiMuon = {};
  List<FlSpot> bieuDoDuongCheckIn = [];
  List<FlSpot> bieuDoDuongCheckOut = [];

  Report_vm(this.month, this.year, this.vm){

    gioVao = SharedPrefService.instance.getValue<int>('gioVao') ?? 8;
    phutVao = SharedPrefService.instance.getValue<int>('phutVao') ?? 30;
    gioRa = SharedPrefService.instance.getValue<int>('gioRa') ?? 17;
    phutRa = SharedPrefService.instance.getValue<int>('phutRa') ?? 30;

    soNgayDuocDiMuon = SharedPrefService.instance.getValue<int>('soNgayDenMuon') ?? 3;
    soPhutDuocDiMuon = SharedPrefService.instance.getValue<int>('soPhutDenMuon') ?? 15;
    soPhepTrongThang = SharedPrefService.instance.getValue<int>('soNgayPhepThang') ?? 1;
    if(vm != null ){
      _calculate();
    }

  }

  void _calculate(){
    if(vm == null ){
      return;
    }
    sourceList = vm!.list;
    totalWorkingDays = 0;
    remainingWorkingDays = 0;
    missingCheckoutDays = 0;
    absentDays = 0;
    totalWorkPoints = 0;

    soNgayDiMuon = 0;
    soNgayVeSom = 0;
    soNgayDiMuonKhongQuaPhut = 0;
    bieuDoTronNgayLam.clear();bieuDoTronDiMuon.clear();bieuDoDuongCheckIn.clear();bieuDoDuongCheckOut.clear();

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
      }
      else {
        DateTime checkIn_D = matchedSession.checkIn;
        DateTime? checkOut_D = matchedSession.checkOut;

        double checkInValue = encodeDateTimeToDouble(matchedSession.checkIn);
        bieuDoDuongCheckIn.add(FlSpot(workDay.day.toDouble(), checkInValue));

        bool checkedIn = matchedSession.getCheckIn != null && matchedSession.getCheckIn != '--|--';
        bool checkedOut = matchedSession.getCheckOut != null && matchedSession.getCheckOut != '--|--';

        final gioVaoDung = DateTime(workDay.year, workDay.month, workDay.day, gioVao, phutVao);
        if (checkIn_D.isAfter(gioVaoDung)) {
          soNgayDiMuon++;
          final lateMinutes = checkIn_D.difference(gioVaoDung).inMinutes;
          if (lateMinutes <= soPhutDuocDiMuon) {
            soNgayDiMuonKhongQuaPhut++;
          }
        }
        if(checkOut_D!=null){
          double checkOutValue = encodeDateTimeToDouble(matchedSession.checkOut!);
          bieuDoDuongCheckOut.add(FlSpot(workDay.day.toDouble(), checkOutValue));
          final gioRaDung = DateTime(workDay.year, workDay.month, workDay.day, gioRa, phutRa);
          if (checkOut_D.isBefore(gioRaDung)) {
            soNgayVeSom++;
          }
        }

        if (checkedIn && !checkedOut) {
          missingCheckoutDays++;
          totalWorkPoints += 0.5;
        } else if (checkedIn && checkedOut) {
          totalWorkPoints += 1;
        } else if (!checkedIn && checkedOut) {
          totalWorkPoints += 0.5;
        }
      }
    }

    int soNgayLamThucTe = totalWorkingDays - absentDays - remainingWorkingDays;
    soNgayLamThucTe = soNgayLamThucTe.clamp(0, totalWorkingDays);

    bieuDoTronNgayLam['Số ngày làm thực tế'] = soNgayLamThucTe;
    bieuDoTronNgayLam['Số ngày nghỉ làm'] = absentDays;
    bieuDoTronNgayLam['Thời gian còn lại của tháng'] = remainingWorkingDays;

    bieuDoTronDiMuon['Đi muộn > $soPhutDuocDiMuon\''] = soNgayDiMuonBiTru;
    bieuDoTronDiMuon['Đi muộn < $soPhutDuocDiMuon\''] = soNgayDiMuonHopLe;

    isLoad = true;
    notifyListeners();
  }

  void updateSourceList(TimeSheetVM newList) {
    if (newList==null) return;
    vm = newList;
    _calculate();
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