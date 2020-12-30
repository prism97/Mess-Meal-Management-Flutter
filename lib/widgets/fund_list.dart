import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/models/fund.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

class FundList extends StatefulWidget {
  @override
  _FundListState createState() => _FundListState();
}

class _FundListState extends State<FundList> {
  List<Fund> _funds;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Provider.of<FirestoreDatabase>(context, listen: false)
        .getFundList()
        .then((value) {
      _funds = value;
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text('Recently added funds'),
          ),
          Divider(),
          _loading
              ? Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SpinKitCircle(
                    color: primaryColorDark,
                    size: 50.0,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => Column(
                    children: [
                      ListTile(
                        title: Text(
                            'Added by ${_funds[index].convenerName} on ${_funds[index].date.toIso8601String().substring(0, 10)}'),
                        subtitle: Text(_funds[index].description),
                        isThreeLine: true,
                        trailing: Text(_funds[index].amount.toString()),
                      ),
                      Divider(),
                    ],
                  ),
                  itemCount: _funds.length,
                ),
        ],
      ),
    );
  }
}
