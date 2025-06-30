import 'package:flutter/cupertino.dart';
import 'package:focus_punch_in/services/SharedPrefService.dart';

import '../services/alarm_permission_helper.dart';

class AlarmPermissionHandler extends StatefulWidget {
  const AlarmPermissionHandler({super.key});

  @override
  State<AlarmPermissionHandler> createState() => _AlarmPermissionHandlerState();
}

class _AlarmPermissionHandlerState extends State<AlarmPermissionHandler> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final wasChecked = SharedPrefService.instance.getValue<bool>('alarm_permission') ?? false;

        if (!wasChecked) {
          await AlarmPermissionHelper.checkAndHandleAlarmPermission(context);
          SharedPrefService.instance.setValue<bool>('alarm_permission', true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
