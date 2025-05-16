

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_punch_in/core/utils/notification_utils.dart';
import 'package:focus_punch_in/services/SharedPrefService.dart';
import 'package:focus_punch_in/viewmodels/theme_vm.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _SettingScreen();

}
class _SettingScreen extends State<SettingScreen>{
  late TimeOfDay time_checkIn;
  late TimeOfDay time_checkOut;

  @override
  void initState() {
    super.initState();

    int h_i = SharedPrefService.instance.getValue<int>('h_in') ?? 8;
    int m_i = SharedPrefService.instance.getValue<int>('m_in') ?? 25;
    int h_o = SharedPrefService.instance.getValue<int>('h_o') ?? 17;
    int m_o = SharedPrefService.instance.getValue<int>('m_o') ?? 35;

    time_checkIn = TimeOfDay(hour: h_i, minute: m_i);
    time_checkOut = TimeOfDay(hour: h_o, minute: m_o);
  }
  // bool light = ThemeVM().isDark;
  bool _isRegistering = false;
  @override
  Widget build(BuildContext context) {
    bool light = context.watch<ThemeVM>().isDark;
    return Scaffold(
      appBar: AppBar(title: Text('Cài đặt'),),
      body: ListView(
        children: [
          ExpansionTile(
            leading: Icon(Icons.palette),
            title: Text('Giao diện'),
            children: [
              Padding(
                padding: EdgeInsets.only(left: 28),
                child: SwitchListTile(
                  title: Text(
                    'Chế độ nền tối',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  value: light,
                  onChanged: (bool value){
                    // print('Value setting: $value');
                    ThemeVM().toggleTheme(value);
                  },
                  activeColor: Colors.red,
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Đặt giờ nhắc nhở'),
            leading: Icon(Icons.access_alarm),
            children: [
              Padding(
                padding: EdgeInsets.only(left: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Giờ check-in')),
                        Text(time_checkIn.format(context)),
                        IconButton(
                            onPressed: () async {
                              var pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: time_checkIn,
                                  initialEntryMode: TimePickerEntryMode.dial
                              );
                              if(pickedTime != null){
                                setState(() {
                                  time_checkIn = pickedTime;
                                });
                              }
                            },
                            icon: Icon(Icons.access_alarms))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: Text('Giờ check-out')),
                        Text(time_checkOut.format(context)),
                        IconButton(
                            onPressed: () async {
                              var pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: time_checkOut,
                                  initialEntryMode: TimePickerEntryMode.dial
                              );
                              if(pickedTime != null){
                                setState(() {
                                  time_checkOut = pickedTime;
                                });
                              }
                            },
                            icon: Icon(Icons.access_alarms))
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: FilledButton(
                          onPressed: _isRegistering ? null : () async{
                            if(_isRegistering)return;
                            setState(() {
                              _isRegistering = true;
                            });
                            await NotificationUtil().registerNotificationCustomize(
                                h_in: time_checkIn.hour, m_in: time_checkIn.minute, h_o: time_checkOut.hour, m_o: time_checkOut.minute
                            );
                            setState(() {
                              _isRegistering = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Success'))
                            );
                          },
                          child: Text('Apply')
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
