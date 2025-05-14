import 'package:flutter/material.dart';
import 'package:focus_punch_in/core/utils/notification_utils.dart';
import 'package:focus_punch_in/services/SharedPrefService.dart';
import 'package:focus_punch_in/viewmodels/theme_vm.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/time_sheet_vm.dart';

class CheckIOScreen extends StatelessWidget{
  const CheckIOScreen({super.key});

  @override
  Widget build(BuildContext context)  {
    final vm = context.watch<TimeSheetVM>();
    final dayCurrent = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
          title: Text('Chấm công'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!(vm.today && !vm.hasOpen))
              Container(
                padding: EdgeInsets.only(bottom: 26),
                child: RichText(text: TextSpan(
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.blue
                        ),
                        children: [
                          TextSpan(
                              text: 'Today:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                          ),
                          TextSpan(
                              text: ' $dayCurrent'
                          )
                        ]
                      )
                  )
              ),
            if (vm.today && !vm.hasOpen)
              Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade100,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bạn đã hoàn thành chấm công ngày hôm nay',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            if (!(vm.today && !vm.hasOpen))
              Row(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    onPressed: vm.today ? null : vm.punchIn,
                    label: const Text('Check in'),
                  ),
                  SizedBox(width: 20,),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    onPressed: vm.hasOpen ? vm.punchOut : null,
                    label: const Text('Check out'),
                  ),
                ],
              ),

            ElevatedButton(
              onPressed: ()=>{
                NotificationUtil().showNotification(title:'test',body:"Thông báo test")
              },
              child: Text("test")
            )
          ],
        )
      ),
    );
  }
}