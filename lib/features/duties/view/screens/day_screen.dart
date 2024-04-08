import 'package:duties_sharer_app/features/authentication/bloc/authentication/authentication_bloc.dart';
import 'package:duties_sharer_app/features/duties/bloc/duties_bloc.dart';
import 'package:duties_sharer_app/features/groups/bloc/groups_bloc.dart';
import 'package:duties_sharer_app/utils/change_color_brightness.dart';
import 'package:duties_sharer_app/utils/text_styles.dart';
import 'package:duties_sharer_app/utils/three_dimensional_box_decoration.dart';
import 'package:duties_sharer_app/widgets/loading_indicator.dart';
import 'package:duty_repository/duty_repository_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_repository/group_repository_library.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class DayScreen extends StatefulWidget {
  final int index;
  final String groupId;
  final DateTime dayDate;
  String? activityController;
  String? pendingTaskPressed;
  DayScreen({
    super.key,
    required this.groupId,
    required this.dayDate,
    required this.index,
  });

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  late Duty duty;
  bool isProcessing = false;
  @override
  void initState() {
    duty = Duty.empty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customTextStyles = CustomTextStyles(context);
    final changeColorBrightness = ChangeColorBrightness();
    return BlocListener<DutiesBloc, DutiesState>(
      listener: (context, state) {
        if (state is DutyAddSuccess) {
          setState(() {
            widget.activityController = null;
            isProcessing = false;
          });
        }

        if (state is DutyAddProcess) {
          setState(() {
            widget.activityController = null;
            isProcessing = true;
          });
        }

        if (state is DutyAcceptSuccess) {
          setState(() {
            isProcessing = false;
          });
        }

        if (state is DutyAcceptProcess) {
          setState(() {
            isProcessing = true;
          });
        }

        if (state is DutyDeleteSuccess) {
          setState(() {
            isProcessing = false;
          });
        }

        if (state is DutyDeleteProcess) {
          setState(() {
            isProcessing = true;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: isProcessing
              ? const LoadingIndicator()
              : Column(
                  children: [
                    Text(
                      DateFormat('d MMMM, yyyy').format(widget.dayDate),
                      style: customTextStyles.title(fontSize: 18),
                    ),
                    Text(
                      'Day',
                      style: customTextStyles.subtitle(fontSize: 11),
                    ),
                  ],
                ),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    CupertinoIcons.person_3_fill,
                    color: Theme.of(context).colorScheme.onBackground,
                  )),
            )
          ],
        ),
        body: BlocBuilder<GroupsBloc, GroupsState>(
          builder: (groupsBlocContext, groupsBlocState) {
            return BlocBuilder<DutiesBloc, DutiesState>(
              builder: (dutiesBlocContext, dutiesBlocState) {
                final currentDayDuties = dutiesBlocState.duties
                    .where((duty) =>
                        duty.doneAt.day == widget.dayDate.day &&
                        duty.doneAt.month == widget.dayDate.month &&
                        duty.doneAt.year == widget.dayDate.year)
                    .toList();

                final currentDayPendingDuties = currentDayDuties.where((duty) => duty.isApproved == false).toList();
                final currentDayCompletedDuties = currentDayDuties.where((duty) => duty.isApproved == true).toList();
                return SafeArea(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'New task',
                            style: customTextStyles.title(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(groupsBlocContext).size.height * 0.1,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: groupsBlocState.groups[widget.index].activities.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Animate(
                              effects: const [FadeEffect(), ScaleEffect()],
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (widget.activityController ==
                                        groupsBlocState.groups[widget.index].activities[index].name) {
                                      widget.activityController = null;
                                    } else {
                                      widget.activityController =
                                          groupsBlocState.groups[widget.index].activities[index].name;
                                    }
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: index < groupsBlocState.groups[widget.index].activities.length - 1 ? 8 : 4,
                                      bottom: 4),
                                  width: MediaQuery.of(context).size.height * 0.1,
                                  height: MediaQuery.of(context).size.height * 0.1,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  decoration: threeDimensionalBoxDecoration(
                                    context: context,
                                    backgroundColor:
                                        Color(groupsBlocState.groups[widget.index].activities[index].color),
                                    borderColor: Theme.of(context).colorScheme.onBackground,
                                  ),
                                  child: Center(
                                    child: widget.activityController !=
                                            groupsBlocState.groups[widget.index].activities[index].name
                                        ? Text(
                                            groupsBlocState.groups[widget.index].activities[index].name,
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                duty = duty.copyWith(
                                                    category: Activity(
                                                        name: widget.activityController!,
                                                        color: groupsBlocState
                                                            .groups[widget.index].activities[index].color),
                                                    doneAt: DateTime(
                                                      widget.dayDate.year,
                                                      widget.dayDate.month,
                                                      widget.dayDate.day,
                                                      DateTime.now().hour,
                                                      DateTime.now().minute,
                                                      DateTime.now().second,
                                                    ));
                                              });
                                              dutiesBlocContext.read<DutiesBloc>().add(AddDuty(
                                                    duty: duty,
                                                    groupId: groupsBlocState.groups[widget.index].id,
                                                    authorId: context.read<AuthenticationBloc>().state.user!.uid,
                                                  ));
                                            },
                                            child: Icon(
                                              CupertinoIcons.plus_circle_fill,
                                              color: Theme.of(context).colorScheme.onBackground,
                                              size: 36,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pending tasks',
                            style: customTextStyles.title(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      currentDayPendingDuties.isEmpty
                          ? Text(
                              'No pending tasks',
                              style: customTextStyles.subtitle(),
                            )
                          : SizedBox(
                              height: MediaQuery.of(groupsBlocContext).size.height * 0.2,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: currentDayPendingDuties.length,
                                itemBuilder: (BuildContext context, int index) {
                                  bool isAbleToDelete =
                                      widget.pendingTaskPressed == currentDayPendingDuties[index].id &&
                                          currentDayPendingDuties[index].author.id ==
                                              context.read<AuthenticationBloc>().state.user!.uid;
                                  return Animate(
                                    effects: const [FadeEffect(), ScaleEffect()],
                                    child: GestureDetector(
                                      onLongPress: () {
                                        setState(() {
                                          widget.pendingTaskPressed = currentDayPendingDuties[index].id;
                                        });
                                      },
                                      onTap: () {
                                        if (widget.pendingTaskPressed == currentDayPendingDuties[index].id) {
                                          setState(() {
                                            widget.pendingTaskPressed = null;
                                          });
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: index < currentDayPendingDuties.length - 1 ? 8 : 4, bottom: 4),
                                        padding: const EdgeInsets.all(12),
                                        decoration: threeDimensionalBoxDecoration(
                                          context: context,
                                          backgroundColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                                          borderColor: Color(currentDayPendingDuties[index].category.color),
                                        ),
                                        child: Stack(alignment: Alignment.center, children: [
                                          Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  currentDayPendingDuties[index].author.name,
                                                  style: TextStyle(
                                                      color: isAbleToDelete
                                                          ? Colors.transparent
                                                          : Color(currentDayPendingDuties[index].category.color)),
                                                ),
                                                Text(
                                                  currentDayPendingDuties[index].category.name,
                                                  style: TextStyle(
                                                      color: isAbleToDelete
                                                          ? Colors.transparent
                                                          : Color(currentDayPendingDuties[index].category.color)),
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      "${currentDayPendingDuties[index].acceptances.length.toString()}/${(groupsBlocState.groups[widget.index].members.length - 1).toString()}",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: isAbleToDelete
                                                              ? Colors.transparent
                                                              : Color(currentDayPendingDuties[index].category.color)),
                                                    ),
                                                    currentDayPendingDuties[index].author.id ==
                                                                context.read<AuthenticationBloc>().state.user!.uid ||
                                                            currentDayPendingDuties[index].acceptances.any((profile) =>
                                                                profile.id ==
                                                                context.read<AuthenticationBloc>().state.user!.uid)
                                                        ? Container()
                                                        : GestureDetector(
                                                            onTap: () {
                                                              context.read<DutiesBloc>().add(AcceptDuty(
                                                                  duty: currentDayPendingDuties[index],
                                                                  groupId: widget.groupId,
                                                                  accepterId: context
                                                                      .read<AuthenticationBloc>()
                                                                      .state
                                                                      .user!
                                                                      .uid));
                                                            },
                                                            child: Icon(
                                                              CupertinoIcons.check_mark_circled_solid,
                                                              color:
                                                                  Color(currentDayPendingDuties[index].category.color),
                                                              size: 24,
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          isAbleToDelete
                                              ? GestureDetector(
                                                  onTap: () {
                                                    context
                                                        .read<DutiesBloc>()
                                                        .add(DeleteDuty(duty: currentDayPendingDuties[index]));
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/trash.png',
                                                    height: 26,
                                                    color: Color(currentDayPendingDuties[index].category.color),
                                                  ),
                                                )
                                              : Container(),
                                        ]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      const SizedBox(height: 20),
                      Text(
                        'Completed tasks',
                        style: customTextStyles.title(),
                      ),
                      const SizedBox(height: 10),
                      currentDayCompletedDuties.isEmpty
                          ? Text(
                              'No completed tasks',
                              style: customTextStyles.subtitle(),
                            )
                          : SizedBox(
                              height: MediaQuery.of(groupsBlocContext).size.height * 0.2,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: currentDayCompletedDuties.length,
                                itemBuilder: (BuildContext context, int index) {
                                  bool isAbleToDelete =
                                      widget.pendingTaskPressed == currentDayCompletedDuties[index].id &&
                                          currentDayCompletedDuties[index].author.id ==
                                              context.read<AuthenticationBloc>().state.user!.uid;
                                  return Animate(
                                    effects: const [FadeEffect(), ScaleEffect()],
                                    child: GestureDetector(
                                      onLongPress: () {
                                        setState(() {
                                          widget.pendingTaskPressed = currentDayCompletedDuties[index].id;
                                        });
                                      },
                                      onTap: () {
                                        if (widget.pendingTaskPressed == currentDayCompletedDuties[index].id) {
                                          setState(() {
                                            widget.pendingTaskPressed = null;
                                          });
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: index < currentDayCompletedDuties.length - 1 ? 8 : 4, bottom: 4),
                                        padding: const EdgeInsets.all(12),
                                        decoration: threeDimensionalBoxDecoration(
                                            context: context,
                                            backgroundColor: Color(currentDayCompletedDuties[index].category.color),
                                            borderColor: changeColorBrightness.lighten(
                                                Color(currentDayCompletedDuties[index].category.color), .4)),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    currentDayCompletedDuties[index].author.name,
                                                    style: TextStyle(
                                                        color: isAbleToDelete
                                                            ? Colors.transparent
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .onBackground
                                                                .withOpacity(0.8)),
                                                  ),
                                                  Text(
                                                    currentDayCompletedDuties[index].category.name,
                                                    style: TextStyle(
                                                        color: isAbleToDelete
                                                            ? Colors.transparent
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .onBackground
                                                                .withOpacity(0.8)),
                                                  ),
                                                  Icon(
                                                    CupertinoIcons.checkmark_alt,
                                                    color: isAbleToDelete
                                                        ? Colors.transparent
                                                        : Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            isAbleToDelete
                                                ? GestureDetector(
                                                    onTap: () {
                                                      context
                                                          .read<DutiesBloc>()
                                                          .add(DeleteDuty(duty: currentDayCompletedDuties[index]));
                                                    },
                                                    child: Image.asset(
                                                      'assets/images/trash.png',
                                                      height: 26,
                                                      color:
                                                          Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ));
              },
            );
          },
        ),
      ),
    );
  }
}
