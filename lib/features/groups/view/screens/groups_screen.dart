import 'package:animations/animations.dart';
import 'package:duties_sharer_app/features/authentication/bloc/sign_in/sign_in_bloc.dart';
import 'package:duties_sharer_app/features/duties/bloc/duties_bloc.dart';
import 'package:duties_sharer_app/features/duties/view/screens/duties_screen.dart';
import 'package:duties_sharer_app/features/groups/bloc/groups_bloc.dart';
import 'package:duties_sharer_app/features/groups/view/screens/join_group_screen.dart';
import 'package:duties_sharer_app/features/groups/view/screens/new_group_screen.dart';
import 'package:duties_sharer_app/features/user/bloc/user_bloc.dart';
import 'package:duties_sharer_app/utils/text_styles.dart';
import 'package:duties_sharer_app/utils/three_dimensional_box_decoration.dart';
import 'package:duties_sharer_app/widgets/loading_indicator.dart';
import 'package:duty_repository/duty_repository_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_repository/group_repository_library.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    final customTextStyles = CustomTextStyles(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocBuilder<UserBloc, UserState>(
        builder: (userBlocContext, userBlocState) {
          if (userBlocState is UserSuccess) {
            return BlocBuilder<GroupsBloc, GroupsState>(
              builder: (groupsBlocContext, groupsBlocState) {
                if (groupsBlocState is GroupsSuccess) {
                  //print(groupsBlocState);
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconActionButton(
                                icon: CupertinoIcons.zzz,
                                onTap: () {
                                  userBlocContext.read<SignInBloc>().add(const SignOutRequested());
                                },
                              ),
                              const SizedBox(width: 10),
                              Text(
                                userBlocState.user.name,
                                style: customTextStyles.title(),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your groups',
                                style: customTextStyles.title(),
                              ),
                              Row(
                                children: [
                                  OpenContainer(
                                    openBuilder: (context, _) => BlocProvider.value(
                                      value: BlocProvider.of<GroupsBloc>(groupsBlocContext),
                                      child: const NewGroupScreen(),
                                    ),
                                    closedBuilder: (context, openContainer) => IconActionButton(
                                      icon: CupertinoIcons.add,
                                      onTap: openContainer,
                                    ),
                                    transitionDuration: const Duration(milliseconds: 150),
                                    closedElevation: 0,
                                    closedColor: Colors.transparent,
                                  ),
                                  const SizedBox(width: 10),
                                  OpenContainer(
                                    openBuilder: (context, _) => BlocProvider.value(
                                      value: BlocProvider.of<GroupsBloc>(groupsBlocContext),
                                      child: const JoinGroupScreen(),
                                    ),
                                    closedBuilder: (context, openContainer) => IconActionButton(
                                      icon: CupertinoIcons.globe,
                                      onTap: openContainer,
                                    ),
                                    transitionDuration: const Duration(milliseconds: 150),
                                    closedElevation: 0,
                                    closedColor: Colors.transparent,
                                  )
                                ],
                              ),
                            ],
                          ),
                          groupsBlocState.groups.isEmpty
                              ? Text(
                                  'No groups',
                                  style: customTextStyles.subtitle(),
                                )
                              : UserGroupsList(
                                  groupsBlocState: groupsBlocState,
                                  groupsBlocContext: groupsBlocContext,
                                )
                        ],
                      ),
                    ),
                  );
                } else {
                  return const LoadingIndicator();
                }
              },
            );
          } else {
            return const LoadingIndicator();
          }
        },
      ),
    );
  }
}

class IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const IconActionButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.fromLTRB(0, 22, 5, 22),
        decoration: threeDimensionalBoxDecoration(
            context: context,
            backgroundColor: Theme.of(context).colorScheme.surface,
            borderColor: Theme.of(context).colorScheme.onBackground),
        child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.onBackground),
      ),
    );
  }
}

// ignore: must_be_immutable
class UserGroupsList extends StatefulWidget {
  final GroupsState groupsBlocState;
  final BuildContext groupsBlocContext;
  const UserGroupsList({
    super.key,
    required this.groupsBlocState,
    required this.groupsBlocContext,
  });

  @override
  State<UserGroupsList> createState() => _UserGroupsListState();
}

class _UserGroupsListState extends State<UserGroupsList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.groupsBlocState.groups.isNotEmpty
              ? (widget.groupsBlocState.groups.length <= 3 ? widget.groupsBlocState.groups.length : 3)
              : 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: widget.groupsBlocState.groups.length,
        itemBuilder: (BuildContext context, int index) {
          return GroupTile(
            groupsBlocState: widget.groupsBlocState,
            groupsBlocContext: widget.groupsBlocContext,
            group: widget.groupsBlocState.groups[index],
            index: index,
          );
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class GroupTile extends StatelessWidget {
  final GroupsState groupsBlocState;
  final BuildContext groupsBlocContext;
  final int index;
  final Group group;
  const GroupTile({
    super.key,
    required this.group,
    required this.groupsBlocContext,
    required this.index,
    required this.groupsBlocState,
  });

  @override
  Widget build(BuildContext context) {
    final customTextStyles = CustomTextStyles(context);
    return Animate(
      effects: const [FadeEffect(), ScaleEffect()],
      child: OpenContainer(
        openBuilder: (context, _) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: BlocProvider.of<GroupsBloc>(groupsBlocContext),
            ),
            BlocProvider(
              create: (context) =>
                  DutiesBloc(dutyRepository: FirebaseDutyRepository())..add(GetGroupDuties(groupId: group.id)),
            ),
          ],
          child: DutiesScreen(index: index, group: group),
        ),
        closedBuilder: (context, openContainer) => GestureDetector(
          onTap: openContainer,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: threeDimensionalBoxDecoration(
                context: context,
                backgroundColor: Theme.of(context).colorScheme.surface,
                borderColor: Theme.of(context).colorScheme.onBackground),
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: customTextStyles.title(
                          fontSize: groupsBlocState.groups.length == 1
                              ? 32
                              : groupsBlocState.groups.length == 2
                                  ? 22
                                  : 20,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -10,
                  right: -10,
                  child: Image.asset(
                    'assets/images/group.png',
                    height: groupsBlocState.groups.length == 1
                        ? 160
                        : groupsBlocState.groups.length == 2
                            ? 120
                            : 80,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
        transitionDuration: const Duration(milliseconds: 250),
        closedElevation: 0,
        closedColor: Colors.transparent,
      ),
    );
  }
}
