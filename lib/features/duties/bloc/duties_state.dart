part of 'duties_bloc.dart';

sealed class DutiesState extends Equatable {
  final List<Duty> duties;

  const DutiesState({required this.duties});

  @override
  List<Object> get props => [duties];
}

final class DutiesInitial extends DutiesState {
  const DutiesInitial() : super(duties: const []);
}

final class DutiesProcess extends DutiesState {
  const DutiesProcess() : super(duties: const []);
}

final class DutiesSuccess extends DutiesState {
  const DutiesSuccess({
    required super.duties,
  });
}

final class DutiesFailure extends DutiesState {
  const DutiesFailure() : super(duties: const []);
}

//ADD NEW DUTY

final class DutyAddProcess extends DutiesState {
  const DutyAddProcess({
    required super.duties,
  });
}

final class DutyAddSuccess extends DutiesState {
  const DutyAddSuccess() : super(duties: const []);
}

final class DutyAddFailure extends DutiesState {
  final String errorMessage;
  const DutyAddFailure({required this.errorMessage}) : super(duties: const []);
}

//ACCEPT DUTY

final class DutyAcceptProcess extends DutiesState {
  const DutyAcceptProcess({
    required super.duties,
  });
}

final class DutyAcceptSuccess extends DutiesState {
  const DutyAcceptSuccess() : super(duties: const []);
}

final class DutyAcceptFailure extends DutiesState {
  final String errorMessage;
  const DutyAcceptFailure({required this.errorMessage}) : super(duties: const []);
}

//DELETE DUTY

final class DutyDeleteProcess extends DutiesState {
  const DutyDeleteProcess({
    required super.duties,
  });
}

final class DutyDeleteSuccess extends DutiesState {
  const DutyDeleteSuccess() : super(duties: const []);
}

final class DutyDeleteFailure extends DutiesState {
  final String errorMessage;
  const DutyDeleteFailure({required this.errorMessage}) : super(duties: const []);
}
