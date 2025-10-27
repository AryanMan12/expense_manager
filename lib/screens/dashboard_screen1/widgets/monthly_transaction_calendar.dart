import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthlyTransactionCalendar extends StatefulWidget {
  final Map<DateTime, double> dailyTotals;
  const MonthlyTransactionCalendar({super.key, required this.dailyTotals});

  @override
  State<MonthlyTransactionCalendar> createState() =>
      MonthlyTransactionCalendarState();
}

class MonthlyTransactionCalendarState
    extends State<MonthlyTransactionCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  double _getAmountForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return widget.dailyTotals[key] ?? 0.0;
  }

  Color _getColor(double amount, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (amount == 0) return Colors.transparent;
    if (amount < 100) return colorScheme.primary.withOpacity(0.25);
    if (amount < 500) return colorScheme.primary.withOpacity(0.5);
    if (amount < 1000) return colorScheme.primary.withOpacity(0.7);
    return colorScheme.primary.withOpacity(0.9);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            final amount = _getAmountForDay(selectedDay);
            if (amount > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "₹${amount.toStringAsFixed(2)} spent on ${selectedDay.day}/${selectedDay.month}",
                  ),
                ),
              );
            }
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final amount = _getAmountForDay(day);
              final color = _getColor(amount, context);

              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: amount > 0
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: amount > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
          calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        ),
        const SizedBox(height: 8),
        // Month legend (color scale)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            _colorLegend("Low", colorScheme.primary.withOpacity(0.25)),
            _colorLegend("Medium", colorScheme.primary.withOpacity(0.5)),
            _colorLegend("High", colorScheme.primary.withOpacity(0.9)),
          ],
        ),
      ],
    );
  }

  Widget _colorLegend(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label),
    ],
  );
}
