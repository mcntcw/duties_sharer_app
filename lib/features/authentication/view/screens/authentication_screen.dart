import 'package:duties_sharer_app/features/authentication/bloc/authentication/authentication_bloc.dart';
import 'package:duties_sharer_app/features/authentication/bloc/sign_in/sign_in_bloc.dart';
import 'package:duties_sharer_app/features/authentication/bloc/sign_up/sign_up_bloc.dart';
import 'package:duties_sharer_app/features/authentication/view/widgets/sign_up_panel.dart';
import 'package:duties_sharer_app/features/authentication/view/widgets/sign_in_panel.dart';
import 'package:duties_sharer_app/utils/three_dimensional_box_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.10),
              Image.asset(
                'assets/images/logo.png',
                height: 120,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.10),
              Center(
                child: TabBar(
                  tabAlignment: TabAlignment.center,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                    return states.contains(MaterialState.focused) ? null : Colors.transparent;
                  }),
                  indicator: threeDimensionalBoxDecoration(
                      context: context,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      borderColor: Theme.of(context).colorScheme.onBackground),
                  indicatorSize: TabBarIndicatorSize.label,
                  controller: tabController,
                  isScrollable: true,
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/user.png',
                        height: 12,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/key.png',
                        height: 14,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    BlocProvider(
                      create: (context) =>
                          SignInBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
                      child: const SignInPanel(),
                    ),
                    BlocProvider(
                      create: (context) =>
                          SignUpBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
                      child: const SignUpPanel(),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
