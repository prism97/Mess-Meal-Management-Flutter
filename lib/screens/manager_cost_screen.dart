import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/manager_cost.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class ManagerCostScreen extends StatefulWidget {
  final String managerId;

  const ManagerCostScreen({@required this.managerId});
  @override
  _ManagerCostScreenState createState() => _ManagerCostScreenState();
}

class _ManagerCostScreenState extends State<ManagerCostScreen> {
  List<ManagerCost> costs;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    FirestoreDatabase db =
        Provider.of<FirestoreDatabase>(context, listen: false);
    db.getManagerCostList(widget.managerId).then((list) {
      costs = list;
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Costs'),
      body: loading
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SpinKitFadingCircle(
                color: primaryColorDark,
                size: 40.0,
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(10.0),
              physics: ScrollPhysics(),
              itemCount: costs.length,
              itemBuilder: (context, index) => Card(
                elevation: kElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kBorderRadius),
                ),
                child: ListTile(
                  title: Text(
                      costs[index].date.toIso8601String().substring(0, 10)),
                  subtitle: Text(costs[index].description),
                  trailing: Text(costs[index].amount.toString()),
                ),
              ),
            ),
    );
  }
}
