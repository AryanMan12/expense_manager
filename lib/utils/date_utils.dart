import 'package:intl/intl.dart';

const dbDateTimeFormat = "dd-MM-yyyy hh:mm:ss";
const uiDateTimeFormat = "dd MMM yyyy hh:mm a";
const formattedDate = "dd MMM yyyy";
const formattedDateWithWeek = "EEE, dd MMM";
const formattedTime = "hh:mm a";

String monthShort(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

String getCurrentDBDateTime() {
  return DateFormat(dbDateTimeFormat).format(DateTime.now());
}

String getCurrentUIDateTime() {
  return DateFormat(uiDateTimeFormat).format(DateTime.now());
}

String getFormattedDate(String dateFromDB) {
  return DateFormat(
    formattedDate,
  ).format(DateFormat(dbDateTimeFormat).parse(dateFromDB));
}

String getFormattedDateWithWeek(String dateFromDB) {
  return DateFormat(
    formattedDateWithWeek,
  ).format(DateFormat(dbDateTimeFormat).parse(dateFromDB));
}

String getFormattedTime(String dateFromDB) {
  return DateFormat(
    formattedTime,
  ).format(DateFormat(dbDateTimeFormat).parse(dateFromDB));
}
