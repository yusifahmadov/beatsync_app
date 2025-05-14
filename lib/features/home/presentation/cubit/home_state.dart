import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String userName;
  final String currentDate;
  final Map<String, dynamic>? heartRateData;
  final Map<String, dynamic>? rmssdData;
  final Map<String, dynamic>? sdnnData;
  final Map<String, dynamic>? lfhfData;

  const HomeLoaded({
    required this.userName,
    required this.currentDate,
    this.heartRateData,
    this.rmssdData,
    this.sdnnData,
    this.lfhfData,
  });

  @override
  List<Object?> get props => [
        userName,
        currentDate,
        heartRateData,
        rmssdData,
        sdnnData,
        lfhfData,
      ];
}

class HomeError extends HomeState {
  final String errorMessage;

  const HomeError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
