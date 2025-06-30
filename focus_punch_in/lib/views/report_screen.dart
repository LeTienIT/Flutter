import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:focus_punch_in/viewmodels/time_sheet_vm.dart';
import 'package:focus_punch_in/widget/lineChart.dart';
import 'package:provider/provider.dart';
import '../viewmodels/report_vm.dart';
import '../widget/alarmPermissionHandler.dart';
import '../widget/pieChart.dart';

class ReportScreen extends StatelessWidget{
  const ReportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final timeSheet = context.watch<TimeSheetVM>();
    final sourceList = timeSheet.list;
    if (timeSheet.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ChangeNotifierProxyProvider<TimeSheetVM, Report_vm>(
      create: (_) => Report_vm(DateTime.now().month, DateTime.now().year, null),
      update: (_, timeSheetVM, previous) {
        previous!.updateSourceList(timeSheetVM);
        return previous!;
      },
      child: Stack(
        children: const [
          ReportContent(),
          AlarmPermissionHandler(), // xử lý permission sau build
        ],
      ),
    );

  }
}

class ReportContent extends StatelessWidget {
  const ReportContent({super.key});

  @override
  Widget build(BuildContext context) {
    final reportVM = context.watch<Report_vm>();

    if(!reportVM.isLoad){
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tổng quát'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Divider(height: 1,),
          if(reportVM.sourceList.isNotEmpty)...[
            dropList(context,reportVM),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: report_content(context, reportVM),
              ),
            ),

          ]
          else
            Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.green,
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                        'Hãy bắt đầu lưu lại các lần điểm danh của bạn, à đừng quên trong cài đặt, có 1 số thứ bạn nên cài đặt'!
                    )
                )
            ),
        ],
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
      bottomNavigationBar: Padding(padding: EdgeInsets.all(5),
        child: ElevatedButton(
          onPressed: ()=>{Navigator.pushNamed(context, '/checkIn')},
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Bo góc 8px
              side: BorderSide(color: Colors.grey), // Viền xám
            ),
            elevation: 2, // Độ đổ bóng
          ),
          child: Text("Điểm danh"),
        ),),
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
          buildReportCard('Số ngày làm của tháng', report.totalWorkingDays.toString(), Colors.blue),
          buildReportCard('Số ngày làm còn lại của tháng', report.remainingWorkingDays.toString(), Colors.purple),
          buildReportCard('Số ngày đã làm thực tế', report.totalWorkPoints.toStringAsFixed(1), Colors.teal),
          buildReportCard('Nghỉ làm', report.absentDays.toString(), Colors.red),
          buildReportCard('Không điểm danh VỀ', report.missingCheckoutDays.toString(), Colors.orange),
          buildReportCard('Tổng số ngày đi muộn', report.soNgayDiMuon.toString(), Colors.orange),
          buildReportCard('Số ngày đi muộn < ${report.soPhutDuocDiMuon}\'', report.soNgayDiMuonKhongQuaPhut .toString(), Colors.orange),
          buildReportCard('Số ngày đi muộn > ${report.soPhutDuocDiMuon}\'', report.soNgayDiMuonBiTru.toString(),Colors.orange),

          PieChartWidget(report.bieuDoTronNgayLam,tieuDeBD: 'Biểu đồ thời gian làm',showTitle: false,),
          SizedBox(height: 10),
          PieChartWidget(report.bieuDoTronDiMuon,tieuDeBD: 'Biểu đồ đi muộn',showTitle: false,),
          SizedBox(height: 10),
          LineChartWidget(report.bieuDoDuongCheckIn, data2: report.bieuDoDuongCheckOut, tieuDe: 'Biểu đồ thời gian điểm danh',)
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