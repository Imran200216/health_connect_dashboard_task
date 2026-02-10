import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect_dashboard/core/router/app_router.dart';
import 'package:health_connect_dashboard/features/home/presentation/bloc/health_bloc.dart';
import 'package:health_connect_dashboard/features/home/presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Health Bloc
        BlocProvider(
          create: (_) => HealthBloc()..add(FetchHealthData()),
          child: const HomeScreen(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Health Connect Dashboard',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        routerConfig: appRouter,
      ),
    );
  }
}
