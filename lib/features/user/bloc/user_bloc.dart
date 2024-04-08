import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository_library.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  UserBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(UserInitial()) {
    on<GetUser>((event, emit) async {
      emit(UserProcess(user: state.user));
      try {
        Profile user = await _userRepository.getUser(event.id);
        emit(UserSuccess(user: user));
      } catch (e) {
        emit(UserFailure(user: state.user, errorMessage: e.toString()));
      }
    });
    on<UpdateUser>((event, emit) async {
      try {
        Profile user = await _userRepository.updateUser(state.user, event.id);
        emit(UserSuccess(user: user));
      } catch (e) {
        emit(UserFailure(user: state.user, errorMessage: e.toString()));
      }
    });
  }
}
