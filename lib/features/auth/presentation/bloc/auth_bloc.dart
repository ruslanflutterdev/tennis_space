import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';


abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthSignUpRequested extends AuthEvent {
  final RegistrationData data;
  AuthSignUpRequested(this.data);
}

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final UserRole role;
  AuthSuccess(this.role);
}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthSignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signUp(event.data);
        emit(AuthSuccess(event.data.role));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}