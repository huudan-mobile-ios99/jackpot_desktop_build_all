import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:playtech_transmitter_app/service/config_custom.dart';
import 'package:playtech_transmitter_app/service/socket_service/socket_service.dart';

part 'video_event.dart';
part 'video_state.dart';

final _logger = Logger();

class VideoBloc extends Bloc<VideoEvent, ViddeoState> {
  final String videoBg; // Single video
  final BuildContext context; // For Phoenix.rebirth
  Timer? _timer;
  final int totalCountToRestart = ConfigCustom.totalCountToRestart;
  final int additionSeconds = ConfigCustom.additionSeconds;
  final SocketService _socketService;


  VideoBloc({
    required this.videoBg,
    required this.context,
    SocketService? socketService,
  })  : _socketService = socketService ?? SocketService(),
        super(ViddeoState(
          id: 1,
          currentVideo: videoBg,
          lastSwitchTime: DateTime.now(),
          count: 0,
          isRestart: false,
          runNumber: '1st',
        )) {
    on<IncrementCount>(_onIncrementCount);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Prevent multiple timers
    _timer = Timer.periodic(const Duration(seconds: ConfigCustom.durationSwitchVideoSecond), (_) {
      add(IncrementCount());
    });
  }

  Future<void> _onIncrementCount(IncrementCount event, Emitter<ViddeoState> emit) async {
    final now = DateTime.now();
    int newCount = state.count + 1;
    bool newIsRestart = false;

    if (newCount >= totalCountToRestart) {
      newCount = 0;
      newIsRestart = true;
      _logger.i('Triggering app restart after $totalCountToRestart counts with additional $additionSeconds seconds delay');
      try {
        _socketService.dispose();
        _logger.i('[${DateTime.now().toIso8601String()}] VideoBloc: SocketService disposed before app restart');
        await Future.delayed(Duration(seconds: additionSeconds));
        // Add delay before restart
        Phoenix.rebirth(context);
      } catch (e) {
        _logger.e('Restart failed: $e');
      }
    }

    emit(ViddeoState(
      currentVideo: videoBg,
      lastSwitchTime: now,
      count: newCount,
      isRestart: newIsRestart,
      id: 1,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _logger.i('VideoBloc closed, timer cancelled');
    return super.close();
  }
}
