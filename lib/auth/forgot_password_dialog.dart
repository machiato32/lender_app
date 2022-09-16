import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../essentials/widgets/gradient_button.dart';
import 'forgot_password_page.dart';

class ForgotPasswordDialog extends StatelessWidget {
  ForgotPasswordDialog();

  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formState,
      child: AlertDialog(
        title: Text(
          'forgot_password'.tr(),
          style: Theme.of(context).textTheme.headline6,
        ),
        content: TextFormField(
          controller: controller,
          validator: (value) {
            if (value.isEmpty) {
              return 'field_empty'.tr();
            }
            if (value.length < 3) {
              return 'minimal_length'.tr(args: ['3']);
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'username'.tr(),
            filled: true,
            prefixIcon: Icon(
              Icons.account_circle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-z0-9]')),
            LengthLimitingTextInputFormatter(15),
          ],
          onFieldSubmitted: (value) => _buttonPush(context),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientButton(
                onPressed: () {
                  _buttonPush(context);
                },
                child: Icon(Icons.send,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _buttonPush(BuildContext context) {
    if (formState.currentState.validate()) {
      String username = controller.text;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForgotPasswordPage(
            username: username,
          ),
        ),
      );
    }
  }
}
