import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/work_session.dart';
import '../services/database.dart';

class TimeSheetVM extends ChangeNotifier{
  final _db = DatabaseHelper.instance;

  // STATE
  final List<WorkSession> _list = [];
  List<WorkSession> listView = [];
  bool get hasOpen => _list.isNotEmpty && _list.last.checkOut == null;

  bool get today {
    if (_list.isEmpty) return false;
    final lastDate = DateFormat('yyyy-MM-dd').format(_list.last.day);
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return lastDate == todayDate;
  }

  List<WorkSession> get list => listView;

  // LOAD
  Future<void> loadData() async{
    final data = await _db.fetchAll();
    // print("Số lượng $data.length");
    _list..clear()..addAll(data.reversed);
    listView..clear()..addAll(_list);
    notifyListeners();
  }

  void search(int? month){
    listView.clear();
    if(month==0){
      listView.addAll(_list);
      notifyListeners();
    }
    else{
      listView = _list.where((e)=>e.day.month==month).toList();
      notifyListeners();
    }
  }
  // ACTION
  Future<void> punchIn() async{
    if(hasOpen)return;
    DateTime d = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final w = WorkSession(day: d, checkIn: DateTime.now());
    w.id = await _db.insert(w);
    _list.add(w);
    listView.add(w);
    notifyListeners();
  }

  Future<void> punchOut() async{
    if(!hasOpen) return;
    final w = _list.last..checkOut = DateTime.now();
    await _db.update(w, w.id!);
    listView.last.checkOut = DateTime.now();
    notifyListeners();
  }

  Future<void> delete(int id) async{
    await _db.delete(id);
    listView.removeWhere((e) => e.id == id);
    _list.removeWhere((e) => e.id == id);
    // print("DELETE $id");
    notifyListeners();
  }
}