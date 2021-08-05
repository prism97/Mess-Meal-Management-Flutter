import 'package:easy_dialog/easy_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ForgotPasswordButton extends StatefulWidget {
  @override
  _ForgotPasswordButtonState createState() => _ForgotPasswordButtonState();
}

class _ForgotPasswordButtonState extends State<ForgotPasswordButton> {
  String _email;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        EasyDialog(
          height: MediaQuery.of(context).size.height / 2,
          title: Text('Forgot Password?'),
          description: Text(
              'Enter the email address you used when you joined and we’ll send you instructions to reset your password.'),
          contentList: [
            _emailField(),
            _sendButton(context),
          ],
        ).show(context);
      },
      child: Text(
        'Forgot password?',
        style: TextStyle(
          color: Theme.of(context).disabledColor,
          decoration: TextDecoration.underline,
          decorationColor: Theme.of(context).disabledColor,
        ),
      ),
    );
  }

  Widget _emailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        cursorColor: primaryColorLight,
        style: TextStyle(
          color: accentColor,
        ),
        decoration: InputDecoration(
          focusedBorder:
              Theme.of(context).inputDecorationTheme.focusedBorder.copyWith(
                    borderSide: BorderSide(
                      color: primaryColorLight,
                    ),
                  ),
          prefixIcon: Icon(
            FontAwesomeIcons.solidEnvelope,
            color: accentColor,
          ),
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
    );
  }

  ElevatedButton _sendButton(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          primaryColorLight,
        ),
        foregroundColor: MaterialStateProperty.all<Color>(
          Colors.white,
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
      ),
      onPressed: () async {
        await Provider.of<AuthProvider>(context, listen: false)
            .sendPasswordResetEmail(_email);
        Navigator.of(context).pop();
        EasyDialog(
          height: MediaQuery.of(context).size.height / 2,
          title: Text('Success'),
          description: Text(
              'An e-mail has been sent to your e-mail address. Follow the directions in the e-mail to reset your password & then login with your new password.'),
        ).show(context);
      },
      child: Text('Send Reset Instructions'),
    );
  }
}
