import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:duties_sharer_app/features/authentication/bloc/authentication/authentication_bloc.dart';
import 'package:duties_sharer_app/features/duties/bloc/duties_bloc.dart';
import 'package:duties_sharer_app/features/duties/view/screens/day_screen.dart';
import 'package:duties_sharer_app/features/groups/bloc/groups_bloc.dart';
import 'package:duties_sharer_app/utils/change_color_brightness.dart';
import 'package:duties_sharer_app/utils/elevated_bottom_sheet.dart';
import 'package:duties_sharer_app/utils/text_styles.dart';
import 'package:duties_sharer_app/utils/three_dimensional_box_decoration.dart';
import 'package:duties_sharer_app/widgets/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_repository/group_repository_library.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class DutiesScreen extends StatefulWidget {
  final int index;
  Group group;
  DutiesScreen({
    super.key,
    required this.index,
    required this.group,
  });

  @override
  State<DutiesScreen> createState() => _DutiesScreenState();
}

class _DutiesScreenState extends State<DutiesScreen> {
  final groupNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final customTextStyles = CustomTextStyles(context);
    final elevatedBottomSheet = ElevatedBottomSheet();
    groupNameController.text = widget.group.name;
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (groupsBlocContext, groupsBlocState) {
        if (groupsBlocState is GroupsSuccess) {
          return BlocBuilder<DutiesBloc, DutiesState>(
            builder: (dutiesBlocContext, dutiesBlocState) {
              if (dutiesBlocState is DutiesSuccess) {
                return Scaffold(
                  backgroundColor: Theme.of(groupsBlocContext).colorScheme.background,
                  extendBodyBehindAppBar: false,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    centerTitle: true,
                    title: Column(
                      children: [
                        Text(
                          groupsBlocState.groups[widget.index].name,
                          style: customTextStyles.title(fontSize: 18),
                        ),
                        Text(
                          'Group',
                          style: customTextStyles.subtitle(fontSize: 11),
                        ),
                      ],
                    ),
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.pop(groupsBlocContext);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Theme.of(groupsBlocContext).colorScheme.onBackground,
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            elevatedBottomSheet.showElevatedBottomSheet(
                                context: context,
                                body: GroupInfoContent(
                                  index: widget.index,
                                  groupsBlocState: groupsBlocState,
                                  groupsBlocContext: groupsBlocContext,
                                ));
                          },
                          child: Icon(
                            CupertinoIcons.circle_grid_3x3_fill,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      )
                    ],
                  ),
                  body: SingleChildScrollView(
                      child: SizedBox(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          CalendarPageView(
                            groupIndex: widget.index,
                            groupsBlocContext: groupsBlocContext,
                            groupId: groupsBlocState.groups[widget.index].id,
                            dutiesBlocState: dutiesBlocState,
                          ),
                          const SizedBox(height: 10),
                          RecentDuties(
                            dutiesBlocState: dutiesBlocState,
                            groupsBlocState: groupsBlocState,
                            index: widget.index,
                          )
                        ],
                      ),
                    ),
                  )),
                );
              } else {
                return Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  body: const LoadingIndicator(),
                );
              }
            },
          );
        } else {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: const LoadingIndicator(),
          );
        }
      },
    );
  }
}

class CalendarPageView extends StatelessWidget {
  final int groupIndex;
  final BuildContext groupsBlocContext;
  final String groupId;
  final DutiesState dutiesBlocState;
  const CalendarPageView(
      {super.key,
      required this.groupIndex,
      required this.groupsBlocContext,
      required this.groupId,
      required this.dutiesBlocState});

  @override
  Widget build(BuildContext context) {
    int difference;
    if (dutiesBlocState.duties.isEmpty) {
      difference = 0;
    } else {
      difference = (DateTime.now().year - dutiesBlocState.duties.last.doneAt.year) * 12 +
          DateTime.now().month -
          dutiesBlocState.duties.last.doneAt.month;
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: PageView.builder(
        reverse: true,
        itemCount: difference + 1,
        itemBuilder: (context, index) {
          DateTime currentDate = DateTime.now();
          DateTime indexDate = DateTime(currentDate.year, currentDate.month - index, currentDate.day);
          return CalendarGrid(
            groupIndex: groupIndex,
            groupsBlocContext: groupsBlocContext,
            currentDate: indexDate,
            groupId: groupId,
            dutiesBlocState: dutiesBlocState,
          );
        },
      ),
    );
  }
}

class CalendarGrid extends StatelessWidget {
  final int groupIndex;
  final BuildContext groupsBlocContext;
  final DateTime currentDate;
  final String groupId;
  final DutiesState dutiesBlocState;
  const CalendarGrid({
    super.key,
    required this.groupIndex,
    required this.currentDate,
    required this.groupsBlocContext,
    required this.groupId,
    required this.dutiesBlocState,
  });

  @override
  Widget build(BuildContext context) {
    final customTextStyles = CustomTextStyles(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          DateFormat('MMMM, yyyy').format(currentDate),
          style: customTextStyles.title(fontSize: 11),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: DateTime(currentDate.year, currentDate.month + 1, 0).day,
              itemBuilder: (context, index) {
                DateTime dayDate =
                    DateTime(currentDate.year, currentDate.month, currentDate.day - ((currentDate.day - 1) - index));
                int day = dayDate.day;
                bool isToday = DateTime.now().day == day &&
                    DateTime.now().month == currentDate.month &&
                    DateTime.now().year == currentDate.year;
                return CalendarDayTile(
                  index: groupIndex,
                  groupsBlocContext: groupsBlocContext,
                  groupId: groupId,
                  dayDate: dayDate,
                  isToday: isToday,
                  dutiesBlocState: dutiesBlocState,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CalendarDayTile extends StatelessWidget {
  final int index;
  final BuildContext groupsBlocContext;
  final String groupId;
  final DateTime dayDate;
  final bool isToday;
  final DutiesState dutiesBlocState;

  const CalendarDayTile({
    super.key,
    required this.index,
    required this.groupsBlocContext,
    required this.groupId,
    required this.dayDate,
    required this.isToday,
    required this.dutiesBlocState,
  });

  @override
  Widget build(BuildContext context) {
    final currentDayDuties = dutiesBlocState.duties
        .where((duty) =>
            duty.doneAt.day == dayDate.day && duty.doneAt.month == dayDate.month && duty.doneAt.year == dayDate.year)
        .toList();
    return Animate(
      effects: const [FadeEffect(), ScaleEffect()],
      child: OpenContainer(
          openBuilder: (context, _) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: BlocProvider.of<GroupsBloc>(groupsBlocContext),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<DutiesBloc>(groupsBlocContext),
                  ),
                ],
                child: DayScreen(groupId: groupId, index: index, dayDate: dayDate),
              ),
          closedBuilder: (context, openContainer) => Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.all(3),
                decoration: threeDimensionalBoxDecoration(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  borderColor:
                      isToday ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.onBackground,
                ),
                child: GestureDetector(
                  onTap: openContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayDate.day.toString(),
                        style: TextStyle(
                          color: isToday
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.onBackground,
                          fontSize: 14,
                          fontFamily: 'Transom',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: currentDayDuties.take(3).map((duty) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: duty.isApproved == true ? Color(duty.category.color) : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: duty.isApproved == true ? 0 : 2,
                                color: Color(duty.category.color),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              ),
          transitionDuration: const Duration(milliseconds: 250),
          closedElevation: 0,
          closedColor: Colors.transparent),
    );
  }
}

// ignore: must_be_immutable
class RecentDuties extends StatefulWidget {
  final DutiesState dutiesBlocState;
  final GroupsState groupsBlocState;
  final int index;
  String? selectedCategory;

  RecentDuties({super.key, required this.dutiesBlocState, required this.groupsBlocState, required this.index});

  @override
  State<RecentDuties> createState() => _RecentDutiesState();
}

class _RecentDutiesState extends State<RecentDuties> {
  @override
  Widget build(BuildContext context) {
    final recentlyCompletedDuties = widget.dutiesBlocState.duties.where((duty) => duty.isApproved == true).toList();
    final recentlyCompletedDutiesByCategory = widget.dutiesBlocState.duties
        .where((duty) => duty.isApproved == true && duty.category.name == widget.selectedCategory)
        .toList();
    final completedDutiesToDisplay =
        widget.selectedCategory == null ? recentlyCompletedDuties : recentlyCompletedDutiesByCategory;

    completedDutiesToDisplay.sort((a, b) => b.doneAt.compareTo(a.doneAt));
    final customTextStyles = CustomTextStyles(context);
    final changeColorBrightness = ChangeColorBrightness();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recently completed',
            style: customTextStyles.title(),
          ),
          recentlyCompletedDuties.isEmpty
              ? Container()
              : Container(
                  height: 30,
                  color: Colors.transparent,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.groupsBlocState.groups[widget.index].activities.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isCategorySelected =
                          widget.selectedCategory == widget.groupsBlocState.groups[widget.index].activities[index].name;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (widget.selectedCategory ==
                                widget.groupsBlocState.groups[widget.index].activities[index].name) {
                              widget.selectedCategory = null;
                            } else {
                              widget.selectedCategory =
                                  widget.groupsBlocState.groups[widget.index].activities[index].name;
                            }
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              right: index < widget.groupsBlocState.groups[widget.index].activities.length - 1 ? 8 : 4,
                              bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: threeDimensionalBoxDecoration(
                              context: context,
                              backgroundColor: isCategorySelected
                                  ? Color(widget.groupsBlocState.groups[widget.index].activities[index].color)
                                  : changeColorBrightness.lighten(
                                      Color(widget.groupsBlocState.groups[widget.index].activities[index].color), .3),
                              borderColor: isCategorySelected
                                  ? changeColorBrightness.lighten(
                                      Color(widget.groupsBlocState.groups[widget.index].activities[index].color), .3)
                                  : Color(widget.groupsBlocState.groups[widget.index].activities[index].color)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.groupsBlocState.groups[widget.index].activities[index].name,
                                style: customTextStyles.title(
                                    fontSize: 10,
                                    color: isCategorySelected
                                        ? changeColorBrightness.lighten(
                                            Color(widget.groupsBlocState.groups[widget.index].activities[index].color),
                                            .3)
                                        : Color(widget.groupsBlocState.groups[widget.index].activities[index].color)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 10),
          recentlyCompletedDuties.isEmpty
              ? Text(
                  'No recent duties',
                  style: customTextStyles.subtitle(),
                )
              : completedDutiesToDisplay.isEmpty
                  ? Text(
                      'No recent duties from this category',
                      style: customTextStyles.subtitle(),
                    )
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: completedDutiesToDisplay.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Animate(
                          effects: const [FadeEffect(), ScaleEffect()],
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: threeDimensionalBoxDecoration(
                                context: context,
                                backgroundColor: Color(completedDutiesToDisplay[index].category.color),
                                borderColor: changeColorBrightness.lighten(
                                    Color(completedDutiesToDisplay[index].category.color), .3)),
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    completedDutiesToDisplay[index].author.name,
                                    style:
                                        TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9)),
                                  ),
                                  Text(
                                    completedDutiesToDisplay[index].category.name,
                                    style:
                                        TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9)),
                                  ),
                                  Text(
                                    DateFormat('dd.MM.yyyy').format(completedDutiesToDisplay[index].doneAt).toString(),
                                    style:
                                        TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}

class GroupInfoContent extends StatefulWidget {
  final int index;
  final GroupsState groupsBlocState;
  final BuildContext groupsBlocContext;
  const GroupInfoContent(
      {super.key, required this.index, required this.groupsBlocState, required this.groupsBlocContext});

  @override
  State<GroupInfoContent> createState() => _GroupInfoContentState();
}

class _GroupInfoContentState extends State<GroupInfoContent> {
  @override
  Widget build(BuildContext context) {
    final customTextStyles = CustomTextStyles(context);
    final changeColorBrightness = ChangeColorBrightness();
    bool isGroupLeaveRequested = false;
    return SingleChildScrollView(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.zero,
                height: 5,
                width: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(60),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                widget.groupsBlocState.groups[widget.index].name,
                style: customTextStyles.title(fontSize: 24),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(3),
                decoration: threeDimensionalBoxDecoration(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.onBackground,
                  borderColor: changeColorBrightness.darken(Theme.of(context).colorScheme.onBackground, .1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.groupsBlocState.groups[widget.index].id,
                      style: customTextStyles.title(fontSize: 12, color: Theme.of(context).colorScheme.surface),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.groupsBlocState.groups[widget.index].id));
                      },
                      child: Icon(
                        Icons.copy,
                        color: Theme.of(context).colorScheme.surface,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(3),
                decoration: threeDimensionalBoxDecoration(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.onBackground,
                  borderColor: changeColorBrightness.darken(Theme.of(context).colorScheme.onBackground, .1),
                ),
                child: Column(
                  children: [
                    Text(
                      'Members:',
                      style: customTextStyles.title(fontSize: 14, color: Theme.of(context).colorScheme.background),
                    ),
                    const SizedBox(height: 5),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.groupsBlocState.groups[widget.index].members.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                          child: Text(
                            widget.groupsBlocState.groups[widget.index].members[index].name,
                            style:
                                customTextStyles.title(fontSize: 14, color: Theme.of(context).colorScheme.background),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: isGroupLeaveRequested == true
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Leave?',
                            style: customTextStyles.subtitle(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isGroupLeaveRequested = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.all(3),
                                  child: Text(
                                    'No',
                                    style: customTextStyles.subtitle(),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    try {
                                      widget.groupsBlocContext.read<GroupsBloc>().add(
                                            LeaveGroup(
                                                groupId: widget.groupsBlocState.groups[widget.index].id,
                                                leavingId: context.read<AuthenticationBloc>().state.user!.uid),
                                          );
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    } catch (e) {
                                      log(e.toString());
                                      rethrow;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  margin: const EdgeInsets.all(3),
                                  decoration: threeDimensionalBoxDecoration(
                                    context: context,
                                    backgroundColor: Theme.of(context).colorScheme.onBackground,
                                    borderColor:
                                        changeColorBrightness.darken(Theme.of(context).colorScheme.onBackground, .1),
                                  ),
                                  child: Text(
                                    'Yes',
                                    style: customTextStyles.subtitle(color: Theme.of(context).colorScheme.surface),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            setState(() {
                              isGroupLeaveRequested = true;
                            });
                          });
                        },
                        child: Icon(
                          Icons.exit_to_app_rounded,
                          color: Theme.of(context).colorScheme.onBackground,
                          size: 28,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
