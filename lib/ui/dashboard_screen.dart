import 'package:banking/cubit/auth/cubit/auth_cubit.dart';
import 'package:banking/ui/application_layout.dart';
import 'package:banking/ui/helper/utils.dart';
import 'package:banking/ui/login_screen.dart';
import 'package:banking/ui/login_session_screen.dart';
import 'package:banking/ui/widget/filled_button.dart';
import 'package:banking/ui/widget/number_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  static const route = "DASHBOARD_SCREEN";
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final f = DateFormat('hh:mm:a');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSessionQrSaved) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.green, content: Text("QR saved")));
        }
        if(state is AuthUserLogedOut){
          Navigator.of(context).popUntil((route) => false);
          Navigator.of(context).pushNamed(LoginScreen.route);
        }
      },
      builder: (context, state) {
        return state is AuthUserLogedIn
            ? ApplicationLayout(
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Spacer(),
                    NumberGenerator(code: state.sessionId),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        onTap: (() {
                          Navigator.of(context)
                              .pushNamed(LoginSessionScreen.route);
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border:
                                  Border.all(width: 1, color: Colors.white)),
                          child: Text(
                            "Last login at Today, ${f.format((state.lastLoginTimeStamp as Timestamp).toDate())}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    space(),
                    FilledButton(
                      onPress: () {
                        showLoading(context);
                        context
                            .read<AuthCubit>()
                            .saveQrToSession(state.sessionDocumentId);
                      },
                      title: "SAVE",
                    ),
                    space()
                  ],
                ),
                            ))
            : const Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}
