
import 'package:intl/intl.dart';

class WorkSession{
  int? id;
  DateTime day;
  final DateTime checkIn;
  DateTime? checkOut;
  bool isCompleted;

  WorkSession({this.id,required this.day, required this.checkIn, this.checkOut, this.isCompleted=false});

  Duration get duration => (checkOut ?? DateTime.now()).difference(checkIn);

  String get getDay => DateFormat("dd/MM/yyyy").format(day);
  String get getCheckIn => DateFormat("HH:mm").format(checkIn);
  String get getCheckOut => checkOut != null ? DateFormat("HH:mm").format(checkOut!) : '--|--';

  factory WorkSession.fromMap(Map<String, dynamic> m) => WorkSession(
    id : m['id'] as int ?,
    day: DateTime.parse(m['day']),
    checkIn: DateTime.parse(m['check_in']),
    checkOut: (m['check_out'] as String).isEmpty ? null : DateTime.parse(m['check_out']),
    isCompleted: m['isComplete'] as  bool
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'day': day.toIso8601String(),
    'check_in': checkIn.toIso8601String(),
    'check_out': checkOut?.toIso8601String() ?? '',
    'isCompleted': isCompleted
  };
}