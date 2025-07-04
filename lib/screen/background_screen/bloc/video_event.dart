part of 'video_bloc.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object> get props => [];
}

class SwitchVideo extends VideoEvent {}
class IncrementCount extends VideoEvent {}



class UpdateTick extends VideoEvent {} // Renamed from UpdateSeconds for clarity
