import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:focus_punch_in/core/utils/notification_utils.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../models/work_session.dart';
import '../viewmodels/time_sheet_vm.dart';

class TimeSheetScreen extends StatefulWidget{
  const TimeSheetScreen({super.key});


  @override
  State<StatefulWidget> createState() => _TimeSheetScreen();
}

class _TimeSheetScreen extends State<TimeSheetScreen>{
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TimeSheetVM>();
    return Scaffold(
      appBar: AppBar(
          title: const Text('Danh sách chấm công'),
          centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(6),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownMenu<int>(
                    enableSearch: true,
                    requestFocusOnTap: true,
                    width: 180,
                    label: const Text('Chọn tháng'),
                    initialSelection: 0,
                    dropdownMenuEntries: const[
                      DropdownMenuEntry(value: 0, label: "Tất cả"),
                      DropdownMenuEntry(value: 1, label: "1"),
                      DropdownMenuEntry(value: 2, label: "2"),
                      DropdownMenuEntry(value: 3, label: "3"),
                      DropdownMenuEntry(value: 4, label: "4"),
                      DropdownMenuEntry(value: 5, label: "5"),
                      DropdownMenuEntry(value: 6, label: "6"),
                      DropdownMenuEntry(value: 7, label: "7"),
                      DropdownMenuEntry(value: 8, label: "8"),
                      DropdownMenuEntry(value: 9, label: "9"),
                      DropdownMenuEntry(value: 10, label: "10"),
                      DropdownMenuEntry(value: 11, label: "11"),
                      DropdownMenuEntry(value: 12, label: "12"),
                    ],
                    onSelected: (select) {
                      if(select!=null)
                        {
                          vm.search(select);
                        }

                    },
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(child: Text('Ngày', textAlign: TextAlign.center,)),
                  Expanded(child: Text('Check in',textAlign: TextAlign.center,)),
                  Expanded(child: Text('Check out',textAlign: TextAlign.center,))
                ],
              ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: vm.list.isEmpty
                ? const Center(child: Text("Không có bản ghi"))
                : ListView.builder(
                itemCount: vm.list.length,
                itemBuilder: (context, index) {
                  final item = vm.list[index];
                  final bool isSpecialItem = item.getCheckOut == '--|--';
                  final Color cardColor = isSpecialItem ? Theme.of(context).colorScheme.errorContainer:Theme.of(context).cardColor;
                  final Color textColor = isSpecialItem ? Theme.of(context).colorScheme.onErrorContainer:Theme.of(context).colorScheme.onSurface;
                  return InkWell(
                    onTap: (){
                      _showDialog(context, item, vm);
                    },
                    child: Dismissible(
                      key: Key(item.id!.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete),
                      ),
                      onDismissed: (direction) {
                        vm.delete(item.id!);
                      },
                      child: Card(
                        color: item.getCheckOut ==  '--|--' ?
                        Theme.of(context).colorScheme.secondary : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  item.getDay,
                                  style: TextStyle(fontSize: 16,
                                      color: item.getCheckOut ==  '--|--' ?
                                      Theme.of(context).colorScheme.errorContainer : null),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.getCheckIn,
                                  style: TextStyle(fontSize: 16,
                                      color: item.getCheckOut ==  '--|--' ?
                                      Theme.of(context).colorScheme.errorContainer : null),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.getCheckOut,
                                  style: TextStyle(fontSize: 16,
                                      color: item.getCheckOut ==  '--|--' ?
                                      Theme.of(context).colorScheme.errorContainer : null),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  );
                  // return
                },
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay parseTimeFromString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return TimeOfDay.now();

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  void _showDialog(BuildContext context, WorkSession w, TimeSheetVM vm){
    var timeCheckIn = parseTimeFromString(w.getCheckIn);
    var timeCheckOut = TimeOfDay.now();
    if(w.getCheckOut!='--|--')timeCheckOut = parseTimeFromString(w.getCheckOut);
    var wID = w.id;
    var day = w.day;
    showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(builder: (context, setState){
            return AlertDialog(
              title: Text('Ngày: ${w.getDay}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(child: Text('Giờ check-in')),
                      Text(timeCheckIn.format(context)),
                      IconButton(
                          onPressed: () async {
                            var pickedTime = await showTimePicker(
                                context: context,
                                initialTime: timeCheckIn,
                                initialEntryMode: TimePickerEntryMode.dial
                            );
                            if(pickedTime != null){
                              setState(() {
                                timeCheckIn = pickedTime;
                              });
                            }
                          },
                          icon: Icon(Icons.access_alarms))
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(child: Text('Giờ check-out')),
                      Text(w.getCheckOut=='--|--' ? w.getCheckOut : timeCheckOut.format(context)),
                      IconButton(
                          onPressed: () async {
                            if(w.getCheckOut != '--|--'){
                              var pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: timeCheckOut,
                                  initialEntryMode: TimePickerEntryMode.dial
                              );
                              if(pickedTime != null){
                                setState(() {
                                  timeCheckOut = pickedTime;
                                });
                              }
                            }
                          },
                          icon: Icon(Icons.access_alarms))
                    ],
                  ),
                  FilledButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Xác nhận'),
                            content: Text('Bạn có chắc chắn muốn cập nhật phiên làm việc này không?'),
                            actions: [
                              TextButton(
                                // Đóng dialog và trả về 1 giá trị. về nguyên tác vẫn là đóng hoặc chuyển trang thôi
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Đồng ý'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          w.checkIn = DateTime(day.year, day.month, day.day, timeCheckIn.hour, timeCheckIn.minute);
                          if(w.getCheckOut != '--|--') {
                            w.checkOut = DateTime(day.year, day.month, day.day, timeCheckOut.hour, timeCheckOut.minute);
                          }
                          await vm.update(w, wID!);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Cập nhật thành công')),
                          );
                        }
                      },
                    child: Text('Cập nhật'),
                  )
                ],
              ),
            );
          });
        }
    );
  }

}