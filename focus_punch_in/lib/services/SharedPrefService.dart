import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService{

  static final SharedPrefService _instance = SharedPrefService._();
  late SharedPreferences _preferences;

  SharedPrefService._();

  static SharedPrefService get instance => _instance;

  Future<void> init() async{
    _preferences = await SharedPreferences.getInstance();
    // print('isDark $getValue<bool>("isDark")');
  }

  Future<void> printAllPrefs() async {
    final allKeys = _preferences.getKeys();

    for (var key in allKeys) {
      final value = _preferences.get(key);
      print('$key: $value');
    }
  }

  bool checkKey(String key){
    return _preferences.containsKey(key);
  }

  T? getValue<T>(String key){
    if(T == String) return _preferences.getString(key) as T?;
    if(T == bool) return _preferences.getBool(key) as T?;
    throw Exception("Không tìm thấy kiểu tướng ứng GET (String / bool)");
  }

  void setValue<T>(String key, T value) async{
    if(value is String) {
      _preferences.setString(key, value as String);
      // print("set $key - $value");
    }
    else if(value is bool) {
      _preferences.setBool(key, value as bool);
      // print("set $key - $value");
    }
    else{
      throw Exception("Không tìm thấy kiểu tướng ứng SET (String / bool)");
    }
  }

  Future<bool> removeKey(String key){
    return _preferences.remove(key);
  }

  Future<bool> clearSharePre(){
    return _preferences.clear();
  }
 }