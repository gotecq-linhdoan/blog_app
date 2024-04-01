import 'package:intl/intl.dart';

String formatDateBydMMMYYYY(DateTime datetime) {
  return DateFormat('d MMM, yyyy').format(datetime);
}
