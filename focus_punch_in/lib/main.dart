import 'package:flutter/material.dart';
import 'package:focus_punch_in/core/utils/notification_utils.dart';
import 'package:focus_punch_in/viewmodels/theme_vm.dart';
import 'package:focus_punch_in/viewmodels/time_sheet_vm.dart';
import 'package:focus_punch_in/views/check_io_screen.dart';
import 'package:focus_punch_in/views/list_view.dart';
import 'package:focus_punch_in/views/setting_screen.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'services/SharedPrefService.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefService.instance.init();
  // print("Thời gian hiện tại trên máy ảo: ${DateTime.now()}");
  tz.initializeTimeZones();
  final location = tz.getLocation('Asia/Ho_Chi_Minh');
  tz.setLocalLocation(location);
  await NotificationUtil().initNoti();
  await NotificationUtil().registerNotificationDefault();



  runApp(
      // ChangeNotifierProvider(
      //   create: (_) => TimeSheetVM()..loadData(),
      //   child: const MyApp(),)
      // );
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TimeSheetVM()..loadData()),
            ChangeNotifierProvider.value(value: ThemeVM())
          ],
          child: const MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeVM>().isDark;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/list': (context) => TimeSheetScreen(),
        '/checkIn': (context) => CheckIOScreen(),
        '/setting': (context) => SettingScreen()
      },
      home: TimeSheetScreen(),
    );
  }
}

