part of 'health_bloc.dart';

sealed class HealthEvent extends Equatable {
  const HealthEvent();
}

class FetchHealthData extends HealthEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
