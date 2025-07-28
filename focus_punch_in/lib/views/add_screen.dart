import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_punch_in/models/work_session.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../viewmodels/time_sheet_vm.dart';

class AddScreen extends StatefulWidget{
  const AddScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddScreen();
  }

}
class _AddScreen extends State<AddScreen>{
  DateTime? today;
  TimeOfDay? timeCheckIn, timeCheckOut;
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TimeSheetVM>();
    return Scaffold(
      appBar: AppBar(title: Text('Thêm dữ liệu'),),
      body: Container(
        padding: EdgeInsets.all(10),
        color: Theme.of(context).cardColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(today == null ? 'Hãy chọn 1 ngày?' : DateFormat('dd/MM/yyyy').format(today!)),
            ElevatedButton.icon(
                onPressed: ()async{
                  final rs = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now()
                  );
                  if(rs != null){
                    setState(() {
                      today = rs;
                    });
                  }
                },
                label: Text('Chọn ngày')
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(child: Text('Giờ check-in')),
                Text(timeCheckIn !=null ? timeCheckIn!.format(context) : '--|--'),
                IconButton(
                    onPressed: () async {
                      var pickedTime = await showTimePicker(
                          context: context,
                          initialTime: timeCheckIn!=null?timeCheckIn!:TimeOfDay.now(),
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
            SizedBox(height: 10,),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(child: Text('Giờ check-out')),
                Text(
                    timeCheckOut!=null ? timeCheckOut!.format(context) : '--|--'
                ),
                IconButton(
                    onPressed: () async {
                      var pickedTime = await showTimePicker(
                          context: context,
                          initialTime: timeCheckOut ?? TimeOfDay.now(),
                          initialEntryMode: TimePickerEntryMode.dial
                      );
                      if(pickedTime != null){
                        setState(() {
                          timeCheckOut = pickedTime;
                        });
                      }
                    },
                    icon: Icon(Icons.access_alarms))
              ],
            ),
            Divider(height: 2,),
            FilledButton.icon(
                onPressed: ()async{
                  if(today == null || timeCheckIn == null){
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ngày và giờ check-in là bắt buộc phải nhập'),
                          backgroundColor: Colors.redAccent,
                        )
                    );
                    return;
                  }
                  else{
                    if(vm.list.isNotEmpty){
                      bool exists = vm.list.any((session) =>
                      session.day.year == today!.year &&
                          session.day.month == today!.month &&
                          session.day.day == today!.day
                      );
                      if(exists){
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ngày hiện tại đã tồn tại trong danh sách, không thể thêm'),
                              backgroundColor: Colors.redAccent,
                            )
                        );
                      }
                      else{
                        final checkIn = DateTime(today!.year, today!.month, today!.day, timeCheckIn!.hour, timeCheckIn!.minute);
                        WorkSession w = WorkSession(day: today!, checkIn: checkIn);
                        if(timeCheckOut!=null){
                          final checkOut = DateTime(today!.year, today!.month, today!.day, timeCheckOut!.hour, timeCheckOut!.minute);
                          w.checkOut = checkOut;
                        }
                        await vm.insert(w);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Thêm dữ liệu thành công!'),
                              backgroundColor: Colors.green,
                            )
                        );
                      }
                    }
                  }
                },
                label: Icon(Icons.add)
            )
          ],
        ),
      ),
    );
  }

}