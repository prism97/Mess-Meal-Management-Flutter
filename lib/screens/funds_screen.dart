import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/add_fund_card.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:mess_meal/widgets/fixed_cost_card.dart';
import 'package:mess_meal/widgets/fund_list.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';
import 'package:provider/provider.dart';

class FundsScreen extends StatelessWidget {
  static const String id = 'funds_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(
        currentRoute: id,
      ),
      appBar: CustomAppBar(
        title: 'Funds',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FixedCostCard(),
            StreamBuilder<int>(
              stream: Provider.of<FirestoreDatabase>(context, listen: false)
                  .totalFundStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    child: ListTile(
                      title: Text(
                        'Total Funds',
                      ),
                      trailing: Text(snapshot.data.toString()),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: SpinKitCircle(
                      color: primaryColorDark,
                      size: 50.0,
                    ),
                  );
                }
              },
            ),
            AddFundCard(),
            FundList(),
          ],
        ),
      ),
    );
  }
}
