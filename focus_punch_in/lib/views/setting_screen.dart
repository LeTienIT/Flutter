

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_punch_in/viewmodels/theme_vm.dart';

class SettingScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cài đặt'),),
      body: SettingBody(),
    );
  }
}
class SettingBody extends StatelessWidget{

  bool light = ThemeVM().isDark;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
        )
      ],
    );
  }

}