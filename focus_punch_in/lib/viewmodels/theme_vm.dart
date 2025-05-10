import 'package:flutter/foundation.dart';
import '../services/SharedPrefService.dart';

class ThemeVM with ChangeNotifier{
  static final ThemeVM _instance = ThemeVM._();
  bool _isDark = false;

  ThemeVM._(){
    _isDark = SharedPrefService.instance.getValue<bool>('isDark') ?? false;
  }

  factory ThemeVM(){
    return _instance;
  }

  bool get isDark => _isDark;

  void toggleTheme(bool value){
    SharedPrefService.instance.setValue<bool>('isDark', value);
    _isDark = value;
    notifyListeners();
  }
}