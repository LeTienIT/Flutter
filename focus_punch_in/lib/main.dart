import 'package:flutter/material.dart';
import 'package:focus_punch_in/core/utils/notification_utils.dart';
import 'package:focus_punch_in/viewmodels/theme_vm.dart';
import 'package:focus_punch_in/viewmodels/time_sheet_vm.dart';
import 'package:focus_punch_in/views/check_io_screen.dart';
import 'package:focus_punch_in/views/list_view.dart';
import 'package:focus_punch_in/views/report_screen.dart';
import 'package:focus_punch_in/views/setting_screen.dart';
import 'package:provider/provider.dart';
import 'services/SharedPrefService.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefService.instance.init();
  await NotificationUtil().initNoti();
  await NotificationUtil().registerNotificationDefault();
  // await NotificationUtil().testScheduleNotificationSoon();
  runApp(
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
        expansionTileTheme: ExpansionTileThemeData(
          backgroundColor: Colors.grey[200],
          collapsedBackgroundColor: Colors.grey[100]
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
          expansionTileTheme: ExpansionTileThemeData(
              backgroundColor: Colors.grey[900],
              collapsedBackgroundColor: Colors.grey[850]
          )
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/list': (context) => TimeSheetScreen(),
        '/checkIn': (context) => CheckIOScreen(),
        '/setting': (context) => SettingScreen(),
        '/report' : (context) => ReportScreen()
      },
      home: ReportScreen(),
    );
  }
}

