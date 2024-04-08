// ignore_for_file: unused_import

import 'package:duties_sharer_app/features/authentication/bloc/sign_in/sign_in_bloc.dart';
import 'package:duties_sharer_app/widgets/custom_button.dart';
import 'package:duties_sharer_app/widgets/custom_text_field.dart';
import 'package:duties_sharer_app/utils/text_styles.dart';
import 'package:duties_sharer_app/utils/three_dimensional_box_decoration.dart';
import 'package:duties_sharer_app/widgets/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SignInPanel extends StatefulWidget {
  const SignInPanel({super.key});

  @override
  State<SignInPanel> createState() => _SignInPanelState();
}

class _SignInPanelState extends State<SignInPanel> {
  final _formKey = GlobalKey<FormState>();
  bool signInRequested = false;
  String? _errorMessage;
  String? _signInMessage;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  IconData iconPassword = CupertinoIcons.eye_solid;
  @override
  Widget build(BuildContext context) {
    final customTextStyles = CustomTextStyles(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign in',
                      style: customTextStyles.title(),
                    ),
                    Text(
                      'to your account',
                      style: customTextStyles.subtitle(),
                    ),
                  ],
                ),
              ),
              signInRequested == true ? const LoadingIndicator() : Container(),
            ],
          ),
          const SizedBox(height: 15),
          BlocListener<SignInBloc, SignInState>(
            listener: (context, state) {
              if (state is SignInProcess) {
                setState(() {
                  signInRequested = true;
                });
              } else if (state is SignInFailure) {
                setState(() {
                  if (state.message == "INVALID_LOGIN_CREDENTIALS" || state.message == "invalid-credential") {
                    _signInMessage = "Incorrect email or password";
                  }
                  if (state.message == "too-many-requests") {
                    _signInMessage = "Too many requests, try again later";
                  }

                  signInRequested = false;
                });
              }
            },
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    hintText: 'email',
                    controller: emailController,
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    errorMessage: _errorMessage,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please fill in this field';
                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(val)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    hintText: 'password',
                    controller: passwordController,
                    obscureText: obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    errorMessage: _errorMessage,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                          if (obscurePassword) {
                            iconPassword = CupertinoIcons.eye_solid;
                          } else {
                            iconPassword = CupertinoIcons.eye_slash;
                          }
                        });
                      },
                      icon: Icon(
                        iconPassword,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please fill in this field';
                      } else if (!RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$')
                          .hasMatch(val)) {
                        return 'Please enter a valid password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'Sign in',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<SignInBloc>().add(
                              SignInRequested(emailController.text, passwordController.text),
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          signInRequested == false && _signInMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _signInMessage.toString(),
                      style: customTextStyles.subtitle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                )
              : const Text('', style: TextStyle(fontSize: 16, color: Colors.transparent)),
        ],
      ),
    );
  }
}
