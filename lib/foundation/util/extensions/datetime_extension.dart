import 'package:intl/intl.dart';

extension DatetimeExtension on DateTime {
  DateTime get date => DateTime(year, month, day);
  String get formattedDate => DateFormat.yMEd().format(this);
}
