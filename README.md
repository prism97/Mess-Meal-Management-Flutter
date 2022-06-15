# Mess Meal

A Flutter application for automating meal management and budget calculation in a mess.

## Features

- Users can update and keep track of their daily meals.
- Manager can change meal amounts (breakfast, lunch, dinner) for any day.
- Manager and mess boys can view the list of users who opted to take any meal of a day.
- Manager can input his expenses and make other changes to the monthly budget.
- Conveners can add to or deduct from available mess funds.
- Conveners can end the work period of a manager and assign the role to another user.
  - This assignment occurs automatically. Users move ahead in a circular list, and the one at the front becomes the manager.
- Conveners can download the meal data and payable amount for every user during any manager's work period in pdf format.
- Conveners can merge the details of two or more consecutive managers and get the total calculation in a single pdf document.
- Conveners can send messages to all the users in the form of push notifications.

## Technologies Used

- Dart, Flutter Framework
- Firebase Firestore Database
- Firebase Authentication
- Firebase Cloud Messaging

