import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:focus_punch_in/core/utils/notification_utils.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../models/work_session.dart';
import '../viewmodels/time_sheet_vm.dart';

class TimeSheetScreen extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _TimeSheetScreen();
}

class _TimeSheetScreen extends State<TimeSheetScreen>{
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TimeSheetVM>();
    return Scaffold(
      appBar: AppBar(
          title: const Text('Check in/out'),
          actions: [
            IconButton(
                onPressed: ()=>{Navigator.pushNamed(context, '/setting')},
                icon: Icon(Icons.settings))
          ],
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
                  return Dismissible(
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
                      // color: Colors.grey[900],
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
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.getCheckIn,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.getCheckOut,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
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
              child: Text("Check in/out"),
            ),
          ),
        ],
      ),
    );
  }
}