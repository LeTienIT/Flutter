import 'package:flutter/material.dart';
import 'package:focus_punch_in/core/utils/notification_utils.dart';
import 'package:focus_punch_in/services/SharedPrefService.dart';
import 'package:focus_punch_in/viewmodels/theme_vm.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
          title: Text('Điểm danh'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!(vm.today && !vm.hasOpen))
              Container(
                padding: EdgeInsets.only(bottom: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                        text: TextSpan(
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
                  ],
                )
              ),
            if (vm.today && !vm.hasOpen)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.all(20),
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

                  Positioned.fill(
                    top: 0,
                    child: Lottie.asset(
                      'assets/lottie/Animation-fireworks.json',
                      width: 250,
                      height: 250,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                ],
              ),
            if (!(vm.today && !vm.hasOpen))
              Row(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    onPressed: vm.today ? null : (){
                      vm.punchIn();
                      _showDialog(context, 'Thông báo', 'Bạn đã chấm công, rất tốt, nhớ chấm thêm 1 lần lúc về nhé');
                    },
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

            // ElevatedButton(
            //   onPressed: ()=>{
            //     NotificationUtil().showNotification(title:'test',body:"Thông báo test")
            //   },
            //   child: Text("test")
            // )
          ],
        )
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                ElevatedButton.icon(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    label: Text('Ok')
                )
              ],
            ),
          );
        }
    );
  }
}