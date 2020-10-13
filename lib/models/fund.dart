import 'package:flutter/cupertino.dart';

class Fund {
  int amount; // can be positive or negative
  String convenerId;
  String convenerName;
  String description;
  DateTime date;

  Fund({
    @required this.amount,
    @required this.convenerId,
    @required this.convenerName,
    @required this.description,
    @required this.date,
  });

  factory Fund.fromMap(Map<String, dynamic> data) {
    return Fund(
      amount: data['amount'],
      convenerId: data['convenerId'],
      convenerName: data['convenerName'],
      description: data['description'],
      date: DateTime.parse(data['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': this.amount,
      'convenerId': this.convenerId,
      'convenerName': this.convenerName,
      'description': this.description,
      'date': this.date.toIso8601String(),
    };
  }
}
