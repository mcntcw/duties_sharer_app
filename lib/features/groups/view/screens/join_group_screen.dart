import 'package:duties_sharer_app/features/authentication/bloc/authentication/authentication_bloc.dart';
import 'package:duties_sharer_app/features/groups/bloc/groups_bloc.dart';
import 'package:duties_sharer_app/utils/text_styles.dart';
import 'package:duties_sharer_app/utils/three_dimensional_box_decoration.dart';
import 'package:duties_sharer_app/widgets/custom_button.dart';
import 'package:duties_sharer_app/widgets/custom_text_field.dart';
import 'package:duties_sharer_app/widgets/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_repository/group_repository_library.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  late Group group;
  final groupIdController = TextEditingController();
  String joinGroupMessage = '';
  bool isGroupJoinRequested = false;
  bool isGroupJoinSuccedd = false;

  @override
  void initState() {
    group = Group.empty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customTextStyles = CustomTextStyles(context);
    return BlocListener<GroupsBloc, GroupsState>(
      listener: (context, state) {
        if (state is GroupJoinProcess) {
          setState(() {
            isGroupJoinRequested = true;
          });
        }
        if (state is GroupJoinSuccess) {
          setState(() {
            groupIdController.clear();
            isGroupJoinRequested = false;
            Navigator.pop(context);
          });
        }
        if (state is GroupJoinFailure) {
          setState(() {
            joinGroupMessage = state.errorMessage;
            groupIdController.clear();
            isGroupJoinRequested = false;
          });
        }
      },
      child: Material(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.symmetric(vertical: 22),
                  decoration: threeDimensionalBoxDecoration(
                      context: context,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      borderColor: Theme.of(context).colorScheme.onBackground),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    size: 16,
                  ),
                ),
              ),
              Text(
                'Join group',
                style: customTextStyles.title(),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                width: MediaQuery.of(context).size.width * 0.6,
                hintText: 'id',
                controller: groupIdController,
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
              Text(
                joinGroupMessage,
                style: customTextStyles.subtitle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 20),
              isGroupJoinRequested ? const LoadingIndicator() : Container(),
              const Spacer(),
              CustomButton(
                  onTap: () {
                    if (groupIdController.text.isNotEmpty) {
                      BlocProvider.of<GroupsBloc>(context).add(JoinGroup(
                          groupId: groupIdController.text,
                          joiningId: context.read<AuthenticationBloc>().state.user!.uid));
                    }
                  },
                  text: 'Join group'),
            ],
          ),
        ),
      ),
    );
  }
}
