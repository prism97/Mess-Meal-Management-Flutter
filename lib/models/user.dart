class User {
  final String uid;

  User({this.uid});
}

class UserData {
  final String uid;
  final Map<String, bool> defaultMeal;
  final int currentFortnightMealAmount;

  UserData({this.uid, this.defaultMeal, this.currentFortnightMealAmount});
}
