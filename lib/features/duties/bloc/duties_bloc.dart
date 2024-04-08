import 'package:bloc/bloc.dart';
import 'package:duty_repository/duty_repository_library.dart';
import 'package:equatable/equatable.dart';

part 'duties_event.dart';
part 'duties_state.dart';

class DutiesBloc extends Bloc<DutiesEvent, DutiesState> {
  final DutyRepository _dutyRepository;
  DutiesBloc({required DutyRepository dutyRepository})
      : _dutyRepository = dutyRepository,
        super(const DutiesInitial()) {
    on<GetGroupDuties>((event, emit) async {
      emit(const DutiesProcess());
      try {
        final loadedDuties = await _dutyRepository.getGroupDuties(event.groupId);
        emit(DutiesSuccess(duties: loadedDuties));
      } catch (e) {
        emit(const DutiesFailure());
      }
    });
    on<AddDuty>((event, emit) async {
      emit(DutyAddProcess(duties: state.duties));
      try {
        final newDuty = await _dutyRepository.addDuty(event.duty, event.groupId, event.authorId);
        final newDuties = List.of(state.duties)..insert(0, newDuty);
        // final newDuties = List.of(state.duties)..add(newDuty);
        emit(const DutyAddSuccess());
        emit(DutiesSuccess(duties: newDuties));
      } catch (e) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith("Exception: ")) {
          errorMessage = errorMessage.substring("Exception: ".length);
        }
        final duties = state.duties;
        emit(DutyAddFailure(errorMessage: errorMessage));
        emit(DutiesSuccess(duties: duties));
      }
    });

    on<AcceptDuty>((event, emit) async {
      emit(DutyAcceptProcess(duties: state.duties));
      try {
        final acceptedDuty = await _dutyRepository.acceptDuty(event.duty, event.groupId, event.accepterId);
        final updatedDuties = state.duties.map((duty) {
          return duty.id == acceptedDuty.id ? acceptedDuty : duty;
        }).toList();
        emit(const DutyAcceptSuccess());
        emit(DutiesSuccess(duties: updatedDuties));
      } catch (e) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith("Exception: ")) {
          errorMessage = errorMessage.substring("Exception: ".length);
        }
        final duties = state.duties;
        emit(DutyAcceptFailure(errorMessage: errorMessage));
        emit(DutiesSuccess(duties: duties));
      }
    });

    on<DeleteDuty>((event, emit) async {
      emit(DutyDeleteProcess(duties: state.duties));
      try {
        await _dutyRepository.deleteDuty(event.duty);
        final updatedDuties = state.duties.where((duty) => duty.id != event.duty.id).toList();
        emit(const DutyDeleteSuccess());
        emit(DutiesSuccess(duties: updatedDuties));
      } catch (e) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith("Exception: ")) {
          errorMessage = errorMessage.substring("Exception: ".length);
        }
        final duties = state.duties;
        emit(DutyDeleteFailure(errorMessage: errorMessage));
        emit(DutiesSuccess(duties: duties));
      }
    });
  }
}
