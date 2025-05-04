// lib/utils/date_extensions.dart
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toShortDateString() {
    return DateFormat('MM/dd/yyyy').format(this);
  }
}