import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';
import 'package:mess_meal/widgets/meal_tile.dart';
import 'package:provider/provider.dart';

class DefaultMealCard extends StatefulWidget {
  @override
  _DefaultMealCardState createState() => _DefaultMealCardState();
}

class _DefaultMealCardState extends State<DefaultMealCard> {
  bool breakfast, lunch, dinner;
  bool loading = true, updating = false, deleting = false;
  Meal defaultMeal;
  FirestoreDatabase db;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    db.getDefaultMeal().then((value) {
      defaultMeal = value;
      breakfast = defaultMeal.breakfast;
      lunch = defaultMeal.lunch;
      dinner = defaultMeal.dinner;
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: SpinKitCircle(
              color: primaryColorDark,
              size: 50.0,
            ),
          )
        : Column(
            children: [
              Card(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                color: Colors.white,
                elevation: kElevation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      MealTile(
                        title: 'Breakfast',
                        mealAmount: 0.5,
                        value: breakfast,
                        onChanged: (bool value) {
                          setState(() {
                            breakfast = value;
                          });
                        },
                      ),
                      Divider(
                        height: 1.0,
                        indent: 10.0,
                        endIndent: 10.0,
                      ),
                      MealTile(
                        title: 'Lunch',
                        mealAmount: 1.0,
                        value: lunch,
                        onChanged: (bool value) {
                          setState(() {
                            lunch = value;
                          });
                        },
                      ),
                      Divider(
                        height: 1.0,
                        indent: 10.0,
                        endIndent: 10.0,
                      ),
                      MealTile(
                        title: 'Dinner',
                        mealAmount: 1.0,
                        value: dinner,
                        onChanged: (bool value) {
                          setState(() {
                            dinner = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              updating
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SpinKitThreeBounce(
                        color: primaryColorDark,
                        size: 25.0,
                      ),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          accentColor,
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kBorderRadius),
                          ),
                        ),
                      ),
                      child: Text('Save'),
                      onPressed: () async {
                        Meal newMeal = Meal(
                          breakfast: breakfast,
                          lunch: lunch,
                          dinner: dinner,
                          date: DateTime.now(),
                        );
                        setState(() {
                          updating = true;
                        });
                        try {
                          await db.updateDefaultMeal(
                            defaultMeal,
                            newMeal,
                          );
                          defaultMeal = newMeal;
                          breakfast = defaultMeal.breakfast;
                          lunch = defaultMeal.lunch;
                          dinner = defaultMeal.dinner;
                        } catch (error) {
                          print(error);
                        } finally {
                          setState(() {
                            updating = false;
                          });
                        }
                      },
                    ),
              Divider(
                indent: 10.0,
                endIndent: 10.0,
              ),
              deleting
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SpinKitThreeBounce(
                        color: primaryColorDark,
                        size: 25.0,
                      ),
                    )
                  : BasicWhiteButton(
                      text: "Delete Account",
                      onPressed: () {
                        EasyDialog(
                          height: MediaQuery.of(context).size.height / 3,
                          descriptionPadding:
                              EdgeInsets.only(bottom: kBorderRadius),
                          title: Text("Delete Account"),
                          description: Text(
                              "Are you sure you want to delete your account? This will delete all your data from the Mess Meal app."),
                          contentList: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      primaryColorDark,
                                    ),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Colors.white,
                                    ),
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                      EdgeInsets.all(kBorderRadius),
                                    ),
                                  ),
                                  child: Text('Yes, delete'),
                                  onPressed: () async {
                                    setState(() {
                                      deleting = true;
                                    });
                                    Navigator.of(context).pop();
                                    bool deleted = await db.deleteAccount();
                                    Navigator.of(context).pop();

                                    String deleteMessage;
                                    if (deleted) {
                                      deleteMessage =
                                          "Account has been deleted successfully.";
                                    } else {
                                      deleteMessage =
                                          "Failed to delete account. Check if you're the current manager or try again later.";
                                    }
                                    EasyDialog(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3,
                                      description: Text(deleteMessage),
                                    ).show(context);
                                    setState(() {
                                      deleting = false;
                                    });

                                    if (deleted) {
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .signOut();
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: kBorderRadius,
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Colors.white,
                                    ),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                      primaryColorDark,
                                    ),
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                      EdgeInsets.all(kBorderRadius),
                                    ),
                                  ),
                                  child: Text('No, cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ).show(context);
                      },
                    ),
            ],
          );
  }
}
