import 'package:duties_sharer_app/app_view.dart';
import 'package:duties_sharer_app/features/authentication/bloc/authentication/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository_library.dart';

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthenticationBloc>(
      create: (context) => AuthenticationBloc(
        userRepository: userRepository,
      ),
      child: const MyAppView(),
    );
  }
}
