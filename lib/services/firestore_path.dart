/*
This class defines all the possible read/write locations from the Firestore database.
In future, any new path can be added here.
This class work together with FirestoreService and FirestoreDatabase.
 */

class FirestorePath {
  static String counts() => 'system/counts';
  static String users() => 'users';
  static String user(String uid) => 'users/$uid';
  static String meal(String uid, String mealId) => 'users/$uid/meals/$mealId';
  static String meals(String uid) => 'users/$uid/meals';
}