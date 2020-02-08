class User {
  final String uid;
  final String email;

  User({this.uid, this.email});
}

class UserData {
  final String uid;
  final Map<String, bool> defaultMeal;
  final int currentFortnightMealAmount;

  UserData({this.uid, this.defaultMeal, this.currentFortnightMealAmount});
}
