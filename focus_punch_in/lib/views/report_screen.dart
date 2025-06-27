
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:focus_punch_in/viewmodels/time_sheet_vm.dart';
import 'package:provider/provider.dart';

import '../viewmodels/report_vm.dart';

class ReportScreen extends StatelessWidget{

  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timeSheet = Provider.of<TimeSheetVM>(context);
    final sourceList = timeSheet.list;

    if (timeSheet.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (timeSheet.list.isEmpty) {
      return Center(child: Text('Không có dữ liệu để phân tích'));
    }

    return ChangeNotifierProvider(
      create: (_) => Report_vm(
        DateTime.now().month,
        DateTime.now().year,
        sourceList,
      ),
      child: ReportContent(),
    );
  }


}

class ReportContent  extends StatelessWidget {
  const ReportContent({super.key});

  @override
  Widget build(BuildContext context) {
    final reportVM = context.watch<Report_vm>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Báo cáo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Divider(height: 1,),
            dropList(context,reportVM),
            report_content(context, reportVM),
            Center(
              child: ElevatedButton(
                onPressed: ()=>{Navigator.pushNamed(context, '/checkIn')},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Bo góc 8px
                    side: BorderSide(color: Colors.grey), // Viền xám
                  ),
                  elevation: 2, // Độ đổ bóng
                ),
                child: Text("Chấm công"),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.clear,
        children: [
          SpeedDialChild(
              child: Icon(Icons.settings),
              label: 'Cài đặt',
              onTap: (){
                Navigator.pushNamed(context, '/setting');
              }
          ),
          SpeedDialChild(
              child: Icon(Icons.list),
              label: 'Danh sách',
              onTap: (){
                Navigator.pushNamed(context, '/list');
              }
          ),
        ],
      ),
    );
  }

  Widget dropList(BuildContext context, Report_vm report){
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownMenu<int>(
                initialSelection: DateTime.now().month,
                label: Text('Chọn tháng'),
                dropdownMenuEntries: const[
                  DropdownMenuEntry(value: 1, label: 'Tháng 1'),
                  DropdownMenuEntry(value: 2, label: 'Tháng 2'),
                  DropdownMenuEntry(value: 3, label: 'Tháng 3'),
                  DropdownMenuEntry(value: 4, label: 'Tháng 4'),
                  DropdownMenuEntry(value: 5, label: 'Tháng 5'),
                  DropdownMenuEntry(value: 6, label: 'Tháng 6'),
                  DropdownMenuEntry(value: 7, label: 'Tháng 7'),
                  DropdownMenuEntry(value: 8, label: 'Tháng 8'),
                  DropdownMenuEntry(value: 9, label: 'Tháng 9'),
                  DropdownMenuEntry(value: 10, label: 'Tháng 10'),
                  DropdownMenuEntry(value: 11, label: 'Tháng 11'),
                  DropdownMenuEntry(value: 12, label: 'Tháng 12'),
                ],
                onSelected: (value){
                  if(value != null) {
                    report.updateMonth(value);
                  }
                },
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget report_content(BuildContext context, Report_vm report){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          buildReportCard('Tổng số ngày công trong tháng', report.totalWorkingDays.toString(), Colors.blue),
          buildReportCard('Số ngày làm việc còn lại', report.remainingWorkingDays.toString(), Colors.purple),
          buildReportCard('Số ngày nghỉ làm', report.absentDays.toString(), Colors.red),
          buildReportCard('Số ngày không check-out', report.missingCheckoutDays.toString(), Colors.orange),
          buildReportCard('Số công hiện tại', report.totalWorkPoints.toStringAsFixed(1), Colors.teal),
        ],
      ),
    );
  }
  Widget buildReportCard(String label, String value, Color color){
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),),
        ),
        title: Text(label),
      ),
    );
  }
}