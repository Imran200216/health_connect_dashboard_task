part of 'health_bloc.dart';

sealed class HealthState extends Equatable {
  const HealthState();
}

final class HealthInitial extends HealthState {
  @override
  List<Object> get props => [];
}

class HealthLoading extends HealthState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class HealthLoaded extends HealthState {
  final List<int> weeklySteps;
  final int heartRate;

  const HealthLoaded({
    required this.weeklySteps,
    required this.heartRate,
  });

  @override
  List<Object?> get props => [weeklySteps, heartRate];
}

class HealthError extends HealthState {
  final String message;

  const HealthError(this.message);

  @override
  List<Object?> get props => [message];
}