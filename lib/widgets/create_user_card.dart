import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';

class CreateUserCard extends StatefulWidget {
  @override
  _CreateUserCardState createState() => _CreateUserCardState();
}

class _CreateUserCardState extends State<CreateUserCard> {
  final _formKey = GlobalKey<FormState>();

  // text field states
  int _sid;
  String _name;
  String _email;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: kElevation,
      margin: EdgeInsets.all(kBorderRadius),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          kBorderRadius,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          'Create New User',
          style: Theme.of(context).textTheme.body2,
        ),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(kBorderRadius),
            decoration: BoxDecoration(
              gradient: kBackgroundGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(kBorderRadius),
                bottomRight: Radius.circular(kBorderRadius),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'student ID',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        validator: (val) => val.length != 7
                            ? 'Student ID must have 7 digits'
                            : null,
                        onChanged: (val) {
                          setState(() => _sid = int.parse(val));
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'name',
                        ),
                        keyboardType: TextInputType.text,
                        validator: (val) =>
                            val.isEmpty ? 'Name field is empty' : null,
                        onChanged: (val) {
                          setState(() => _name = val);
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => !EmailValidator.validate(_email)
                            ? 'Enter a valid email address'
                            : null,
                        onChanged: (val) {
                          setState(() => _email = val);
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      BasicWhiteButton(
                        text: 'Create',
                        onPressed: () {
                          FocusScope.of(context).unfocus();

                          final formState = _formKey.currentState;
                          if (formState.validate()) {
                            formState.save();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
