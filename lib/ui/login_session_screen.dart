import 'dart:developer';

import 'package:banking/cubit/auth/cubit/auth_cubit.dart';
import 'package:banking/ui/application_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class LoginSessionScreen extends StatefulWidget {
  static const route = "LOGIN_SESSION_SCREEN";
  const LoginSessionScreen({super.key});

  @override
  State<LoginSessionScreen> createState() => _LoginSessionScreenState();
}

class _LoginSessionScreenState extends State<LoginSessionScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  final CollectionReference _firestoreRef =
      FirebaseFirestore.instance.collection("sessions");
  DateTime today = DateTime.parse(
      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} 00:00:00");
  DateTime yesterday = DateTime.parse(
      "${DateTime.now().subtract(const Duration(days: 1)).year}-${DateTime.now().subtract(const Duration(days: 1)).month.toString().padLeft(2, '0')}-${DateTime.now().subtract(const Duration(days: 1)).day.toString().padLeft(2, '0')} 00:00:00");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    log(today.toString());
  }

  @override
  Widget build(BuildContext context) {
    return ApplicationLayout(
        child: SizedBox(
      width: double.infinity,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {},
        builder: (context, state) {
          return state is AuthUserLogedIn
              ? Column(
                  children: [
                    TabBar(controller: tabController, tabs: const [
                      Tab(
                        child: Text("Today"),
                      ),
                      Tab(
                        child: Text("Yesterday"),
                      ),
                      Tab(
                        child: Text("Others"),
                      ),
                    ]),
                    Expanded(
                      child: TabBarView(controller: tabController, children: [
                        FutureBuilder<QuerySnapshot<Object?>>(
                          future: _firestoreRef
                              .where('user', isEqualTo: state.user.uid)
                              .where("timestamp", isGreaterThanOrEqualTo: today)
                              .orderBy("timestamp", descending: true)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) => SessionTile(
                                  ip: snapshot.data!.docs[index].get("ip"),
                                  location: snapshot.data!.docs[index]
                                      .get("location"),
                                  timestamp: snapshot.data!.docs[index]
                                      .get("timestamp"),
                                  qrImage: snapshot.data!.docs[index].get("qr"),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              log(snapshot.error.toString());
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                        FutureBuilder<QuerySnapshot<Object?>>(
                          future: _firestoreRef
                              .where('user', isEqualTo: state.user.uid)
                              .where("timestamp",
                                  isGreaterThanOrEqualTo: yesterday,
                                  isLessThan: today)
                              // .orderBy("timestamp", descending: false)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) => SessionTile(
                                  ip: snapshot.data!.docs[index].get("ip"),
                                  location: snapshot.data!.docs[index]
                                      .get("location"),
                                  timestamp: snapshot.data!.docs[index]
                                      .get("timestamp"),
                                  qrImage: snapshot.data!.docs[index].get("qr"),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              log(snapshot.error.toString());
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                        FutureBuilder<QuerySnapshot<Object?>>(
                          future: _firestoreRef
                              .where('user', isEqualTo: state.user.uid)
                              .where("timestamp", isLessThan: yesterday)
                              // .orderBy("timestamp", descending: false)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) => SessionTile(
                                  ip: snapshot.data!.docs[index].get("ip"),
                                  location: snapshot.data!.docs[index]
                                      .get("location"),
                                  timestamp: snapshot.data!.docs[index]
                                      .get("timestamp"),
                                  qrImage: snapshot.data!.docs[index].get("qr"),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              log(snapshot.error.toString());
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                        // ListView.builder(
                        //   itemCount: 50,
                        //   itemBuilder: (context, index) => const Text(""),
                        // ),
                        // ListView.builder(
                        //   itemCount: 50,
                        //   itemBuilder: (context, index) => const Text(""),
                        // ),
                      ]),
                    )
                  ],
                )
              : const CircularProgressIndicator();
        },
      ),
    ));
  }
}

class SessionTile extends StatelessWidget {
  final String ip;
  final String location;
  final Timestamp timestamp;
  final f = DateFormat('hh:mm:a');
  final dateF = DateFormat("dd MMM yyyy");
  final String? qrImage;
  SessionTile(
      {Key? key,
      required this.ip,
      required this.location,
      required this.timestamp,
      this.qrImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 100,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(
                  0xff121212,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "${f.format(timestamp.toDate())} - ${dateF.format(timestamp.toDate())}"),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(ip),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(location),
                ],
              ),
            ),
          ),
          qrImage != null
              ? Positioned(
                  bottom: 20,
                  right: 10,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      width: 70,
                      height: 70,
                      padding: const EdgeInsets.all(6),
                      child: Image.network(
                        qrImage!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      )),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
