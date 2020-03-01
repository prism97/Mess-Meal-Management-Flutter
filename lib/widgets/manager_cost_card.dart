import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/services/database.dart';

class ManagerCostCard extends StatefulWidget {
  @override
  _ManagerCostCardState createState() => _ManagerCostCardState();
}

class _ManagerCostCardState extends State<ManagerCostCard> {
  bool _manager = false;
  bool _costUpdating = false;
  int _cost = 0;
  int _addedCost = 0;
  final _formKey = GlobalKey<FormState>();

  Future<void> checkManager() async {
    if (DatabaseService.manager) {
      _manager = true;
      final result = await DatabaseService.getManagerData();
      _cost = int.parse(result['cost']);
    }
  }

  @override
  void initState() {
    super.initState();
    checkManager().whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return _manager
        ? Card(
            color: primaryColorLight,
            elevation: kElevation,
            margin: EdgeInsets.all(kBorderRadius),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                kBorderRadius,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Cost',
                    style: Theme.of(context).textTheme.title,
                  ),
                  Divider(
                    color: Colors.white,
                  ),
                  ListTile(
                    title: Text(
                      'Cost until now',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      _cost.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Divider(),
                  Form(
                    key: _formKey,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'new cost',
                            ),
                            validator: (val) => int.parse(val) > 0
                                ? null
                                : 'Cost must be positive',
                            onChanged: (val) {
                              setState(() {
                                _addedCost = int.parse(val);
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(kBorderRadius),
                            ),
                            child: _costUpdating
                                ? SpinKitFadingCircle(
                                    color: primaryColorDark,
                                    size: 40.0,
                                  )
                                : Text(
                                    'Add',
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        .copyWith(color: accentColor),
                                  ),
                            onPressed: () async {
                              final formState = _formKey.currentState;
                              formState.save();
                              if (formState.validate()) {
                                setState(() {
                                  _cost += _addedCost;
                                  _costUpdating = true;
                                });
                                await DatabaseService.updateManagerCost(_cost);
                                setState(() {
                                  _costUpdating = false;
                                  formState.reset();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
