import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';



abstract class AuthRepository {
  Future<void> signUp(RegistrationData data);
  Future<UserRole> signIn(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  UserRole? getCurrentUserRole();
}

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthSignUpRequested extends AuthEvent {
  final RegistrationData data;
  AuthSignUpRequested(this.data);
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested(this.email, this.password);
}

class AuthSignOutRequested extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  AuthPasswordResetRequested(this.email);
}

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final UserRole? role;
  final String? message;

  AuthSuccess({this.role, this.message});

  @override
  List<Object?> get props => [role, message];
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {

    on<AuthSignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signUp(event.data);
        emit(AuthSuccess(role: event.data.role));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final role = await authRepository.signIn(event.email, event.password);
        emit(AuthSuccess(role: role));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signOut();
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthPasswordResetRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.resetPassword(event.email);
        emit(AuthSuccess(message: 'Ссылка для сброса отправлена на почту'));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}