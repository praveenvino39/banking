part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthUserLogedIn extends AuthState {
  final int sessionId;
  final User user;
  final String sessionDocumentId;
  final dynamic lastLoginTimeStamp;
  AuthUserLogedIn({required this.sessionId,required this.user, required this.sessionDocumentId, required this.lastLoginTimeStamp});
}

class AuthUserLogedOut extends AuthState {}



class OtpRequested extends AuthState {}


class AuthOtpSent extends AuthState {
  final String verificationId;
  AuthOtpSent({required this.verificationId});
}

class AuthOtpRequested extends AuthState {}

class AuthOtpVerificationRequested extends AuthState {}

class AuthSessionQrSaved extends AuthUserLogedIn {
  AuthSessionQrSaved({required super.sessionId, required super.user, required super.sessionDocumentId, required super.lastLoginTimeStamp});
}


class AuthOtpVerificationFailed extends AuthState {
  final String error;
  AuthOtpVerificationFailed({required this.error});
}
