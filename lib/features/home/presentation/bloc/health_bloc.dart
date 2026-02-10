import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'health_event.dart';

part 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  HealthBloc() : super(HealthInitial()) {
    on<FetchHealthData>(_fetchHealthData);
  }

  Future<void> _fetchHealthData(
    FetchHealthData event,
    Emitter<HealthState> emit,
  ) async {
    emit(HealthLoading());

    try {
      final health = Health();
      await health.configure();

      final types = [HealthDataType.STEPS, HealthDataType.HEART_RATE];

      final permissions = List.filled(types.length, HealthDataAccess.READ);

      final granted = await health.requestAuthorization(
        permissions: permissions,
        types,
      );

      if (granted != true) {
        emit(const HealthError("Permission denied"));
        return;
      }

      // Weekly steps
      List<int> weeklySteps = [];

      for (int i = 6; i >= 0; i--) {
        DateTime day = DateTime.now().subtract(Duration(days: i));
        DateTime start = DateTime(day.year, day.month, day.day, 0, 0, 0);
        DateTime end = DateTime(day.year, day.month, day.day, 23, 59, 59);

        int? steps = await health.getTotalStepsInInterval(start, end);
        weeklySteps.add(steps ?? 0);
      }

      // Latest heart rate (last 1 hour)
      int heartRate = 0;

      final hrData = await health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now(),
      );

      if (hrData.isNotEmpty) {
        heartRate = (hrData.last.value as num).round();
      }

      emit(HealthLoaded(weeklySteps: weeklySteps, heartRate: heartRate));
    } catch (e) {
      emit(HealthError(e.toString()));
    }
  }
}
