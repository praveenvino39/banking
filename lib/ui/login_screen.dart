import 'dart:math';

import 'package:banking/cubit/auth/cubit/auth_cubit.dart';
import 'package:banking/ui/application_layout.dart';
import 'package:banking/ui/dashboard_screen.dart';
import 'package:banking/ui/helper/utils.dart';
import 'package:banking/ui/widget/filled_button.dart';
import 'package:banking/ui/widget/filled_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class LoginScreen extends StatefulWidget {
  static const route = "LOGIN_SCREEN";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  loc.Location location = loc.Location();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String? verificationToken;

  @override
  void initState() {
    _auth.authStateChanges().listen((event) {
      if (event != null) {
        checkAndRequestPermission(
          onPermissionAvailable: () {
            context
                .read<AuthCubit>()
                .userLogedIn(event, Random().nextInt(99999));
          },
        );
      }
    });
    super.initState();
  }

  checkAndRequestPermission({required Function() onPermissionAvailable}) async {
    if (await Permission.location.status == PermissionStatus.granted &&
        await Permission.locationWhenInUse.status == PermissionStatus.granted) {
      onPermissionAvailable();
    } else {
      final locationResult = await Permission.location.request();
      final locationWhenUserResult =
          await Permission.locationWhenInUse.request();
      if (locationResult == PermissionStatus.permanentlyDenied &&
          locationWhenUserResult == PermissionStatus.permanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:  [
                const Text("Permission denied please enable it in settings"),
                ElevatedButton(onPressed: () {
                  openAppSettings();
                }, child: const Text("Open settings"))
              ],
            )));
        return;
      }
      checkAndRequestPermission(onPermissionAvailable: onPermissionAvailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ApplicationLayout(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthUserLogedIn) {
            Navigator.of(context).popUntil((route) => false);
            Navigator.of(context).pushNamed(DashboardScreen.route);
          }
          if (state is AuthOtpSent) {
            Navigator.of(context).pop();
            setState(() {
              verificationToken = state.verificationId;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    "OTP sent to +91 ${phoneNumberController.text}, Please enter it into OTP input box.")));
          }
          if (state is AuthOtpVerificationFailed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.red, content: Text(state.error)));
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Text(
                "Login",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            space(),
            FilledTextField(
              textController: phoneNumberController,
              label: "Phone number",
            ),
            space(),
            verificationToken != null
                ? FilledTextField(
                    textController: otpController,
                    label: "OTP",
                  )
                : const SizedBox(),
            space(),
            verificationToken == null
                ? FilledButton(
                    onPress: () async {
                      if (phoneNumberController.text.length == 10) {
                        showLoading(context);
                        context.read<AuthCubit>().sendOtp();
                        sentOneTimePassword();
                      }
                    },
                    title: "LOGIN")
                : FilledButton(
                    onPress: () async {
                      if (otpController.text.length == 6) {
                        showLoading(context);
                        context.read<AuthCubit>().verificationRequest();
                        verifyOneTimePassword();
                      }
                    },
                    title: "VERFIY OTP"),
            space(height: 10),
            FilledButton(
                onPress: () async {
                  showLoading(context);
                  _auth.signInWithProvider(GoogleAuthProvider());
                },
                title: "Continue with google"),
          ],
        ),
      ),
    ));
  }

  sentOneTimePassword() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: "+91 ${phoneNumberController.text}",
      verificationCompleted: (phoneAuthCredential) {},
      verificationFailed: (error) {
        context
            .read<AuthCubit>()
            .verificationFailed(error.message ?? "Something went wrong");
      },
      codeSent: (verificationId, forceResendingToken) {
        context.read<AuthCubit>().otpSent(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  verifyOneTimePassword() async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationToken ?? "", smsCode: otpController.text);
    await _auth.signInWithCredential(phoneAuthCredential);
  }
}
