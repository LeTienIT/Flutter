import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_punch_in/core/tool.dart';
import 'package:focus_punch_in/core/utils/notification_utils.dart';
import 'package:focus_punch_in/services/SharedPrefService.dart';
import 'package:focus_punch_in/viewmodels/theme_vm.dart';
import 'package:focus_punch_in/widget/numberForm.dart';
import 'package:focus_punch_in/widget/sessionTitle.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget{
  const SettingScreen({super.key});
  @override
  State<StatefulWidget> createState() => _SettingScreen();

}
class _SettingScreen extends State<SettingScreen>{
  late TimeOfDay time_checkIn;
  late TimeOfDay time_checkOut;

  late TimeOfDay time_In;
  late TimeOfDay time_Out;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _minus;
  late final TextEditingController _dayOff;
  @override
  void initState() {
    super.initState();
    // print("Setting");

    int h_i = SharedPrefService.instance.getValue<int>('h_in') ?? 8;
    int m_i = SharedPrefService.instance.getValue<int>('m_in') ?? 25;
    int h_o = SharedPrefService.instance.getValue<int>('h_o') ?? 17;
    int m_o = SharedPrefService.instance.getValue<int>('m_o') ?? 35;

    int gioVao = SharedPrefService.instance.getValue<int>('gioVao') ?? 8;
    int phutVao = SharedPrefService.instance.getValue<int>('phutVao') ?? 30;
    int gioRa = SharedPrefService.instance.getValue<int>('gioRa') ?? 17;
    int phutRa = SharedPrefService.instance.getValue<int>('phutRa') ?? 30;

    // SharedPrefService.instance.printAllPrefs();
    // print("check: ${SharedPrefService.instance.getValue<int>('m_in')}");

    int soNgayDuocDenMuon = SharedPrefService.instance.getValue<int>('soNgayDenMuon') ?? 0;
    int soPhutDuocDenMuon = SharedPrefService.instance.getValue<int>('soPhutDenMuon') ?? 0;
    int soNgayPhepTrongThang = SharedPrefService.instance.getValue<int>('soNgayPhepThang') ?? 0;

    _amount = TextEditingController(text: soNgayDuocDenMuon.toString());
    _minus = TextEditingController(text: soPhutDuocDenMuon.toString());
    _dayOff = TextEditingController(text: soNgayPhepTrongThang.toString());

    time_checkIn = TimeOfDay(hour: h_i, minute: m_i);
    time_checkOut = TimeOfDay(hour: h_o, minute: m_o);

    time_In = TimeOfDay(hour: gioVao, minute: phutVao);
    time_Out = TimeOfDay(hour: gioRa, minute: phutRa);
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
                              SnackBar(content: Text('Đã lưu cài đặt của bạn'),backgroundColor: Colors.green,)
                            );
                          },
                          child: Text('Apply')
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          ExpansionTile(
            title: Text('Cài đặt bổ sung'),
            leading: Icon(Icons.more),
            children: [
              Padding(padding: EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Giờ Vào')),
                        Text(time_In.format(context)),
                        IconButton(
                            onPressed: () async {
                              var pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: time_In,
                                  initialEntryMode: TimePickerEntryMode.dial
                              );
                              if(pickedTime != null){
                                setState(() {
                                  time_In = pickedTime;
                                });
                              }
                            },
                            icon: Icon(Icons.access_alarms))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: Text('Giờ về')),
                        Text(time_Out.format(context)),
                        IconButton(
                            onPressed: () async {
                              var pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: time_Out,
                                  initialEntryMode: TimePickerEntryMode.dial
                              );
                              if(pickedTime != null){
                                setState(() {
                                  time_Out = pickedTime;
                                });
                              }
                            },
                            icon: Icon(Icons.access_alarms))
                      ],
                    ),

                    SessionTitle(title: 'Số ngày được phép đến muộn'),
                    NumberForm(amount: _amount, title: 'VD: 3', validator: Tool.amountValidator),

                    SessionTitle(title: 'Số phút được phép đi muộn'),
                    NumberForm(amount: _minus, title: 'VD: 15', validator: Tool.amountValidator),

                    SessionTitle(title: 'Số ngày nghỉ phép của 1 tháng'),
                    NumberForm(amount: _dayOff, title: 'VD: 1', validator: Tool.amountValidator),

                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: FilledButton(
                          onPressed: _isRegistering ? null : () async{
                            if(_isRegistering)return;
                            setState(() {
                              _isRegistering = true;
                            });

                            if(_formKey.currentState!.validate()){
                              int soNgayDenMuon = int.parse(_amount.text);
                              int soPhutDenMuon = int.parse(_minus.text);
                              int soNgayPhepThang = int.parse(_dayOff.text);

                              SharedPrefService.instance.setValue<int>('gioVao', time_In.hour);
                              SharedPrefService.instance.setValue<int>('phutVao', time_In.minute);
                              SharedPrefService.instance.setValue<int>('gioRa', time_Out.hour);
                              SharedPrefService.instance.setValue<int>('phutRa', time_Out.minute);

                              SharedPrefService.instance.setValue<int>('soNgayDenMuon', soNgayDenMuon);
                              SharedPrefService.instance.setValue<int>('soPhutDenMuon', soPhutDenMuon);
                              SharedPrefService.instance.setValue<int>('soNgayPhepThang', soNgayPhepThang);

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã lưu cài đặt')));
                            }

                            setState(() {
                              _isRegistering = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã lưu cài đặt của bạn'),backgroundColor: Colors.green,)
                            );
                          },
                          child: Text('Apply')
                      ),
                    )
                  ],
                ),
              ),
              )
            ],
          )
        ],
      ),
    );
  }
}
