import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/meal_amount.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

class MealAmountDialog extends StatefulWidget {
  final DateTime date;
  final MealAmount mealAmount;

  const MealAmountDialog({@required this.date, @required this.mealAmount});

  @override
  _MealAmountDialogState createState() => _MealAmountDialogState();
}

class _MealAmountDialogState extends State<MealAmountDialog> {
  double breakfast, lunch, dinner;
  FirestoreDatabase db;

  @override
  void initState() {
    super.initState();
    breakfast = widget.mealAmount.breakfast;
    lunch = widget.mealAmount.lunch;
    dinner = widget.mealAmount.dinner;
    db = Provider.of<FirestoreDatabase>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          kBorderRadius,
        ),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Meal Amount',
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              Text(
                widget.date.toIso8601String().substring(0, 10),
                style: Theme.of(context).textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
              Divider(
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  child: Column(
                    children: [
                      MealAmountField(
                        title: 'Breakfast',
                        initialAmount: breakfast,
                        onChanged: (val) {
                          setState(() => breakfast = double.parse(val));
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      MealAmountField(
                        title: 'Lunch',
                        initialAmount: lunch,
                        onChanged: (val) {
                          setState(() => lunch = double.parse(val));
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      MealAmountField(
                        title: 'Dinner',
                        initialAmount: dinner,
                        onChanged: (val) {
                          setState(() => dinner = double.parse(val));
                        },
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      RaisedButton(
                        color: Theme.of(context).accentColor,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kBorderRadius),
                        ),
                        child: Text('Save'),
                        onPressed: () async {
                          await db.setMealAmount(
                            date: widget.date,
                            mealAmount: MealAmount(
                              breakfast: breakfast,
                              lunch: lunch,
                              dinner: dinner,
                            ),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MealAmountField extends StatelessWidget {
  final String title;
  final double initialAmount;
  final Function onChanged;

  const MealAmountField({
    this.title,
    this.initialAmount,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: accentColor,
      initialValue: initialAmount.toString(),
      decoration: InputDecoration(
        isDense: true,
        prefix: Text(
          '$title  ',
          style: TextStyle(color: accentColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}
