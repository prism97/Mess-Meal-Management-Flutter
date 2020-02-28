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

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      initialSelectedDay: DateTime.now(),
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
        titleTextStyle: Theme.of(context).textTheme.title,
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
        selectedColor: Theme.of(context).accentColor,
        todayColor: Theme.of(context).disabledColor,
        weekdayStyle: Theme.of(context).textTheme.body1,
        weekendStyle: Theme.of(context).textTheme.body2,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: Theme.of(context).textTheme.display1,
        weekendStyle: Theme.of(context).textTheme.display2,
      ),
      onDaySelected: (date, events) {
        showMealCard(date);
      },
    );
  }
}
