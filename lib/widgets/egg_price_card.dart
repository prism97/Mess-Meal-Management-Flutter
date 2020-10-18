import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

class EggPriceCard extends StatefulWidget {
  @override
  _EggPriceCardState createState() => _EggPriceCardState();
}

class _EggPriceCardState extends State<EggPriceCard> {
  bool _priceUpdating = false;
  double _newPrice = 0;
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
            color: accentColor,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Egg Unit Price',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      StreamBuilder<double>(
                        stream: db.eggUnitPriceStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data.toString(),
                              style: TextStyle(color: Colors.white),
                            );
                          }
                          return Container();
                        },
                      ),
                    ],
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
                              hintText: 'new price',
                            ),
                            validator: (val) => double.parse(val) > 0
                                ? null
                                : 'Price must be positive',
                            onChanged: (val) {
                              setState(() {
                                _newPrice = double.parse(val);
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: _priceUpdating
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
                                        _priceUpdating = true;
                                      });
                                      await db.updateEggUnitPrice(_newPrice);
                                      setState(() {
                                        _priceUpdating = false;
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
