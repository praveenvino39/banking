import 'dart:io';

import 'package:banking/service/http.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final Location location = Location();

  AuthCubit() : super(AuthInitial());

  final CollectionReference _firestoreRef =
      FirebaseFirestore.instance.collection("sessions");
      

  userLogedIn(User user, int sessionId) async {
    final userLocation =await location.getLocation(); 
    final String ip = (await HttpService.getPublicIp()) ?? "";
    final String city = (await HttpService.getCityByLatLong( userLocation.latitude ?? 0, userLocation.longitude ?? 0)) ?? "";
    DocumentReference documentRef = await _firestoreRef.add({
      "user": user.uid,
      "ip": ip,
      "location": city.toUpperCase(),
      "session_code": sessionId.toString(),
      "timestamp": FieldValue.serverTimestamp(),
      "qr": null,
    });
    emit(
      AuthUserLogedIn(
        sessionId: sessionId,
        user: user,
        sessionDocumentId: documentRef.id,
        lastLoginTimeStamp:
            (await _firestoreRef.doc(documentRef.id).get()).get("timestamp"),
      ),
    );
  }

  sendOtp() {
    emit(AuthOtpRequested());
  }

  
  otpSent(String verificationId) {
    emit(AuthOtpSent(verificationId: verificationId));
  }

  verificationRequest() {
    emit(AuthOtpVerificationRequested());
  }

  otpRequested() {
    emit(AuthOtpRequested());
  }

  userLogedOut() {
    emit(AuthUserLogedOut());
  }

  verificationFailed(String error) {
    emit(AuthOtpVerificationFailed(error: error));
  }

  saveQrToSession(String docId) async {
    final AuthUserLogedIn currentState = state as AuthUserLogedIn;
    final qrValidationResult = QrValidator.validate(
      data: currentState.sessionId.toString(),
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    if (qrValidationResult.isValid) {
      final painter = QrPainter.withQr(
        qr: qrValidationResult.qrCode!,
        color: const Color(0xFF000000),
        gapless: true,
        embeddedImageStyle: null,
        embeddedImage: null,
      );
      painter.toImageData(250.0).asStream().listen((event) async {
        final data = event!.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final filename = "${tempDir.path}${currentState.sessionId}.jpg";
        final file = await File(filename).writeAsBytes(data);
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('sessions')
            .child('/${currentState.sessionId}.jpg');
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': file.path},
        );
        UploadTask uploadTask = ref.putFile(file, metadata);
        uploadTask.whenComplete(() async {
          await _firestoreRef
              .doc(docId)
              .update({"qr": await ref.getDownloadURL()});
          emit(AuthSessionQrSaved(
              lastLoginTimeStamp: currentState.lastLoginTimeStamp,
              sessionId: currentState.sessionId,
              user: currentState.user,
              sessionDocumentId: currentState.sessionDocumentId));
        });
      });
    }
  }
}

AuthCubit getAuthCubit(context) {
  return context.read<AuthCubit>();
}
