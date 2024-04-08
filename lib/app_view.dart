import 'package:duties_sharer_app/features/authentication/bloc/authentication/authentication_bloc.dart';
import 'package:duties_sharer_app/features/authentication/bloc/sign_in/sign_in_bloc.dart';
import 'package:duties_sharer_app/features/authentication/bloc/sign_up/sign_up_bloc.dart';
import 'package:duties_sharer_app/features/authentication/view/screens/authentication_screen.dart';
import 'package:duties_sharer_app/features/groups/bloc/groups_bloc.dart';
import 'package:duties_sharer_app/features/groups/view/screens/groups_screen.dart';
import 'package:duties_sharer_app/features/user/bloc/user_bloc.dart';
import 'package:duties_sharer_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_repository/group_repository_library.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return MaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'Sharies',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          background: Color(0xFF0A0A0A),
          primary: Color(0xFF443E3E),
          surface: Color.fromARGB(255, 12, 12, 12),
          secondary: Color.fromARGB(255, 236, 231, 154),
          onBackground: Color(0xFFECECEC),
          error: Color(0xFFAF3434),
        ),
        fontFamily: 'EpilogueBold',
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => SignInBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
                ),
                BlocProvider(
                  create: (context) => UserBloc(userRepository: context.read<AuthenticationBloc>().userRepository)
                    ..add(GetUser(id: context.read<AuthenticationBloc>().state.user!.uid)),
                ),
                BlocProvider(
                  create: (context) => GroupsBloc(groupRepository: FirebaseGroupRepository())
                    ..add(GetUserGroups(userId: context.read<AuthenticationBloc>().state.user!.uid)),
                ),
              ],
              child: const GroupsScreen(),
            );
          } else {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => SignInBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
                ),
                BlocProvider(
                  create: (context) => SignUpBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
                ),
              ],
              child: const AuthenticationScreen(),
            );
          }
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => MenuScreen()),
      // );
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: 120,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }
}
