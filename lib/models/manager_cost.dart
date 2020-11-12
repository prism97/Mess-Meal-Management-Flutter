import 'package:flutter/material.dart';

class ManagerCost {
  int amount;
  String description;
  DateTime date;

  ManagerCost({
    @required this.amount,
    @required this.description,
    @required this.date,
  });

  factory ManagerCost.fromMap(Map<String, dynamic> data) {
    return ManagerCost(
      amount: data['amount'],
      description: data['description'],
      date: DateTime.parse(data['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': this.amount,
      'description': this.description,
      'date': this.date.toIso8601String(),
    };
  }
}
