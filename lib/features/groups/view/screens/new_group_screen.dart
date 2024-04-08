import 'package:duties_sharer_app/features/authentication/bloc/authentication/authentication_bloc.dart';
import 'package:duties_sharer_app/features/groups/bloc/groups_bloc.dart';
import 'package:duties_sharer_app/utils/text_styles.dart';
import 'package:duties_sharer_app/utils/three_dimensional_box_decoration.dart';
import 'package:duties_sharer_app/widgets/custom_button.dart';
import 'package:duties_sharer_app/widgets/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_repository/group_repository_library.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  late Group group;
  bool groupAddRequested = false;
  final groupNameController = TextEditingController();
  final activityNameController = TextEditingController();
  List<Color> colors = [
    const Color(0xFFD15555),
    const Color(0xFFBEAF27),
    const Color(0xFF40BE27),
    const Color(0xFF27BEBE),
    const Color(0xFF274FBE),
    const Color(0xFF6D27BE),
    const Color(0xFFA027BE),
    const Color(0xFFBE2772),
    const Color(0xFFD85600),
    const Color(0xFF797878),
  ];

  List<Activity> activities = [];
  Color selectedColor = const Color(0xFFD15555);

  late ScrollController activityScrollController;
  @override
  void initState() {
    group = Group.empty;
    super.initState();
    activityScrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final customTextStyles = CustomTextStyles(context);
    return BlocListener<GroupsBloc, GroupsState>(
      listener: (context, state) {
        if (state is GroupAddProcess) {
          Navigator.pop(context);
        }
        if (state is GroupAddSuccess) {
          Navigator.pop(context);
        }
      },
      child: Material(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                'New group',
                style: customTextStyles.title(),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                width: MediaQuery.of(context).size.width * 0.6,
                hintText: 'name',
                controller: groupNameController,
                obscureText: false,
                keyboardType: TextInputType.name,
              ),
              colors.isNotEmpty
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
                      decoration: threeDimensionalBoxDecoration(
                          context: context,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          borderColor: Theme.of(context).colorScheme.onBackground),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  maxLength: 25,
                                  controller: activityNameController,
                                  style: TextStyle(
                                    height: 1.8,
                                    fontFamily: 'EpilogueMedium',
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                    hintText: 'activity ${activities.length + 1}',
                                    hintStyle: customTextStyles.subtitle(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  if (activityNameController.text.isNotEmpty) {
                                    Activity newActivity = Activity(
                                      name: activityNameController.text,
                                      color: selectedColor.value,
                                    );
                                    setState(() {
                                      activities.add(newActivity);
                                      colors.remove(selectedColor);
                                      if (colors.isNotEmpty) {
                                        selectedColor = colors[0];
                                      }
                                      activityNameController.clear();

                                      int currentIndex = activities.indexOf(newActivity);
                                      if (currentIndex != -1 && currentIndex < activities.length - 1) {
                                        activities.removeAt(currentIndex);
                                        activities.add(newActivity);
                                      }
                                    });

                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      activityScrollController.animateTo(
                                        activityScrollController.position.maxScrollExtent,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    });
                                  }
                                },
                                child: Icon(
                                  CupertinoIcons.add,
                                  color: Theme.of(context).colorScheme.onBackground,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: colors.length,
                              itemBuilder: (BuildContext context, int index) {
                                return colors.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedColor = colors[index];
                                          });
                                        },
                                        child: Container(
                                          height: 20,
                                          width: 20,
                                          margin: EdgeInsets.only(right: index < colors.length - 1 ? 4 : 0),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(width: 3, color: Theme.of(context).colorScheme.onBackground),
                                            shape: BoxShape.circle,
                                            color: colors[index],
                                          ),
                                          child: selectedColor == colors[index]
                                              ? const Center(
                                                  child: Icon(
                                                    CupertinoIcons.circle_filled,
                                                    size: 6,
                                                  ),
                                                )
                                              : const Center(),
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              const SizedBox(height: 70),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      child: Center(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: ListView.builder(
                            controller: activityScrollController,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: activities.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: EdgeInsets.only(right: index < activities.length - 1 ? 8 : 4, bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: threeDimensionalBoxDecoration(
                                  context: context,
                                  backgroundColor: Color(activities[index].color),
                                  borderColor: Theme.of(context).colorScheme.onBackground,
                                ),
                                child: Center(
                                  child: Text(
                                    '#${activities[index].name.replaceAll(' ', '-')}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    CustomButton(
                      onTap: () {
                        if (groupNameController.text.isNotEmpty && activities.isNotEmpty) {
                          setState(() {
                            group = group.copyWith(name: groupNameController.text, activities: activities);
                            BlocProvider.of<GroupsBloc>(context).add(
                              AddGroup(
                                group: group,
                                initiatorId: context.read<AuthenticationBloc>().state.user!.uid,
                              ),
                            );
                          });
                        }
                      },
                      text: 'Add group',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
