import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/fund.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

class AddFundCard extends StatefulWidget {
  @override
  _AddFundCardState createState() => _AddFundCardState();
}

class _AddFundCardState extends State<AddFundCard> {
  final _formKey = GlobalKey<FormState>();
  int _amount;
  String _description;
  bool loading = false;
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
        if (snapshot.hasData && snapshot.data.isConvener) {
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
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType:
                          TextInputType.numberWithOptions(signed: true),
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'amount',
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: 'can be positive/negative',
                      ),
                      validator: (val) =>
                          int.tryParse(val) == null ? 'Invalid amount' : null,
                      onChanged: (val) {
                        setState(() {
                          _amount = int.parse(val);
                        });
                      },
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'description',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      validator: (val) =>
                          val.isEmpty ? 'Please add a description' : null,
                      onChanged: (val) {
                        setState(() {
                          _description = val;
                        });
                      },
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    loading
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
                              'Add new fund',
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
                                  loading = true;
                                });
                                await db.addFund(
                                  Fund(
                                    amount: _amount,
                                    description: _description,
                                    date: DateTime.now(),
                                    convenerId: snapshot.data.uid,
                                    convenerName: snapshot.data.name,
                                  ),
                                );
                                setState(() {
                                  loading = false;
                                  formState.reset();
                                });
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
