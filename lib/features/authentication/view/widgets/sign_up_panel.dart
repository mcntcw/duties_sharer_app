import 'package:duties_sharer_app/features/authentication/bloc/sign_up/sign_up_bloc.dart';
import 'package:duties_sharer_app/widgets/custom_button.dart';
import 'package:duties_sharer_app/widgets/custom_text_field.dart';
import 'package:duties_sharer_app/utils/text_styles.dart';
import 'package:duties_sharer_app/widgets/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository_library.dart';

class SignUpPanel extends StatefulWidget {
  const SignUpPanel({super.key});

  @override
  State<SignUpPanel> createState() => _SignUpPanelState();
}

class _SignUpPanelState extends State<SignUpPanel> {
  final _formKey = GlobalKey<FormState>();
  bool signUpRequested = false;
  String? _errorMessage;
  String? _signUpMessage;
  final nameController = TextEditingController();
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
                      'Create',
                      style: customTextStyles.title(),
                    ),
                    Text(
                      'an account',
                      style: customTextStyles.subtitle(),
                    ),
                  ],
                ),
              ),
              signUpRequested == true ? const LoadingIndicator() : Container(),
            ],
          ),
          const SizedBox(height: 15),
          BlocListener<SignUpBloc, SignUpState>(
            listener: (context, state) {
              if (state is SignUpProcess) {
                setState(() {
                  signUpRequested = true;
                });
              } else if (state is SignUpFailure) {
                setState(() {
                  if (state.message == "email-already-in-use") {
                    _signUpMessage = "This email is already in use, try another one";
                  } else if (state.message == "invalid-email") {
                    _signUpMessage = "Bad email format";
                  }
                  signUpRequested = false;
                });
              }
            },
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    hintText: 'name',
                    controller: nameController,
                    obscureText: false,
                    keyboardType: TextInputType.name,
                    errorMessage: _errorMessage,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please fill in this field';
                      } else if (val.length > 20) {
                        return 'Name too long';
                      } else if (!RegExp(r'^[a-zA-Z0-9._]*$').hasMatch(val)) {
                        return 'Please use only letters, numbers, dots and underscores';
                      }
                      return null;
                    },
                  ),
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
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please fill in this field';
                      } else if (!RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$')
                          .hasMatch(val)) {
                        return 'Password must be a minimum of 8 characters, and include at least one uppercase letter, one lowercase letter, one digit, and one special character';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'Sign up',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        Profile profile = Profile.empty;
                        profile =
                            profile.copyWith(email: emailController.text, name: nameController.text.toLowerCase());

                        setState(() {
                          context.read<SignUpBloc>().add(SignUpRequested(profile, passwordController.text));
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          signUpRequested == false && _signUpMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _signUpMessage.toString(),
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
