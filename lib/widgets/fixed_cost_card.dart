import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

class FixedCostCard extends StatefulWidget {
  @override
  _FixedCostCardState createState() => _FixedCostCardState();
}

class _FixedCostCardState extends State<FixedCostCard> {
  bool _costUpdating = false;
  bool _loading = true;
  double _fixedCost, _newFixedCost;
  final _formKey = GlobalKey<FormState>();
  FirestoreDatabase db;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    db.getFixedCost().then((value) {
      _fixedCost = value;
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: SpinKitCircle(
              color: primaryColorDark,
              size: 40.0,
            ),
          )
        : Card(
            color: primaryColorLight,
            elevation: kElevation,
            margin: EdgeInsets.all(kBorderRadius),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                kBorderRadius,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    dense: true,
                    title: Text(
                      'Fixed Cost',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: Colors.white),
                    ),
                    trailing: Text(
                      _fixedCost.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Divider(
                    color: Colors.white,
                  ),
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
                              isDense: true,
                              hintText: 'new cost',
                            ),
                            validator: (val) => double.parse(val) > 0
                                ? null
                                : 'Cost must be positive',
                            onChanged: (val) {
                              setState(() {
                                _newFixedCost = double.parse(val);
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: _costUpdating
                              ? SpinKitFadingCircle(
                                  color: Colors.white,
                                  size: 40.0,
                                )
                              : RaisedButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(kBorderRadius),
                                  ),
                                  child: Text(
                                    'Update',
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
                                        _costUpdating = true;
                                      });
                                      await db.updateFixedCost(_newFixedCost);
                                      setState(() {
                                        _costUpdating = false;
                                        _fixedCost = _newFixedCost;
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
          );
  }
}
