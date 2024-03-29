import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';

class CustomCalendar extends StatelessWidget {
  const CustomCalendar({
    @required this.calendarController,
    this.showMealCard,
  });

  final CalendarController calendarController;
  final Function showMealCard;

  DateTime _getToday() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      initialSelectedDay: _getToday(),
      startDay: DateTime.now().subtract(
        Duration(days: 30),
      ),
      endDay: DateTime.now().add(
        Duration(days: 30),
      ),
      calendarController: calendarController,
      availableCalendarFormats: {
        CalendarFormat.week: '',
      },
      initialCalendarFormat: CalendarFormat.week,
      startingDayOfWeek: StartingDayOfWeek.saturday,
      weekendDays: [DateTime.thursday, DateTime.friday],
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        headerPadding: EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          gradient: kBackgroundGradient,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(20.0),
            right: Radius.circular(20.0),
          ),
        ),
        titleTextStyle: Theme.of(context).textTheme.headline6,
        leftChevronIcon: Icon(
          FontAwesomeIcons.chevronCircleLeft,
          color: Colors.white,
        ),
        rightChevronIcon: Icon(
          FontAwesomeIcons.chevronCircleRight,
          color: Colors.white,
        ),
      ),
      calendarStyle: CalendarStyle(
        selectedColor: Theme.of(context).colorScheme.secondary,
        todayColor: Theme.of(context).disabledColor,
        weekdayStyle: Theme.of(context).textTheme.bodyText1,
        weekendStyle: Theme.of(context).textTheme.bodyText2,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: Theme.of(context).textTheme.subtitle1,
        weekendStyle: Theme.of(context).textTheme.subtitle2,
      ),
      onDaySelected: (date, events, _) {
        showMealCard(true, DateTime(date.year, date.month, date.day));
      },
      onUnavailableDaySelected: () {
        showMealCard(false);
      },
    );
  }
}
