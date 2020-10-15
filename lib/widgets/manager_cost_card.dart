import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

class ManagerCostCard extends StatefulWidget {
  @override
  _ManagerCostCardState createState() => _ManagerCostCardState();
}

class _ManagerCostCardState extends State<ManagerCostCard> {
  bool _costUpdating = false;
  int _addedCost = 0;
  final _formKey = GlobalKey<FormState>();
  FirestoreDatabase db;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Member>(
      stream: Provider.of<AuthProvider>(context, listen: false).user,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.isManager()) {
          return Card(
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
                    style: Theme.of(context).textTheme.headline6,
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
                                        _costUpdating = true;
                                      });
                                      await db
                                          .updateCurrentManagerCost(_addedCost);
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
          );
        } else {
          return Container();
        }
      },
    );
  }
}
