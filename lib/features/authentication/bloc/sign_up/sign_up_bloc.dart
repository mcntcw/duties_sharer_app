import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository_library.dart';
part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository _userRepository;

  SignUpBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignUpInitial()) {
    on<SignUpRequested>((event, emit) async {
      emit(SignUpProcess());
      try {
        Profile profile = await _userRepository.signUp(event.user, event.password);
        await _userRepository.setUser(profile);
        emit(SignUpSuccess());
      } on FirebaseAuthException catch (e) {
        emit(SignUpFailure(message: e.code));
      } catch (e) {
        emit(const SignUpFailure());
        log(e.toString());
      }
    });
  }
}
