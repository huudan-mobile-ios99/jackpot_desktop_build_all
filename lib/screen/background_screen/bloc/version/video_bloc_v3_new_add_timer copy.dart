// import 'dart:async';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:logger/logger.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:playtech_transmitter_app/service/config_custom.dart';

// part 'video_event.dart';
// part 'video_state.dart';

// final _logger = Logger();

// class VideoBloc extends Bloc<VideoEvent, ViddeoState> {
//   final String videoBg; // Single video
//   final BuildContext context; // For Phoenix.rebirth
//   Timer? _countTimer; // Timer for incrementing count
//   Timer? _tickTimer; // Timer for seconds and milliseconds
//   final int totalCountToRestart = ConfigCustom.totalCountToRestart;
//   final int additionSeconds = ConfigCustom.additionSeconds;

//   VideoBloc({
//     required this.videoBg,
//     required this.context,
//   }) : super(ViddeoState(
//           id: 1,
//           currentVideo: videoBg,
//           lastSwitchTime: DateTime.now(),
//           count: 0,
//           isRestart: false,
//           secondsInCurrentCount: 1,
//           millisecondsInCurrentCount: 0,
//         )) {
//     on<IncrementCount>(_onIncrementCount);
//     on<UpdateTick>(_onUpdateTick);
//     _startTimers();
//   }

//   void _startTimers() {
//     _countTimer?.cancel(); // Prevent multiple count timers
//     _tickTimer?.cancel(); // Prevent multiple tick timers

//     // Timer for incrementing count every 30 seconds
//     _countTimer = Timer.periodic(
//       const Duration(seconds: ConfigCustom.durationSwitchVideoSecond),
//       (_) => add(IncrementCount()),
//     );

//     // Timer for updating seconds and milliseconds every 100ms
//     _tickTimer = Timer.periodic(
//       const Duration(milliseconds: 100),
//       (_) => add(UpdateTick()),
//     );
//   }

//   Future<void> _onIncrementCount(IncrementCount event, Emitter<ViddeoState> emit) async {
//     final now = DateTime.now();
//     int newCount = state.count + 1;
//     bool newIsRestart = false;

//     if (newCount >= totalCountToRestart) {
//       newCount = 0;
//       newIsRestart = true;
//       _logger.i('Triggering app restart after $totalCountToRestart counts with additional $additionSeconds seconds delay');
//       try {
//         // Stop the count timer to prevent further increments
//         _countTimer?.cancel();
//         // Continue tick timer for milliseconds during additional seconds
//         for (int i = 1; i <= additionSeconds * 10; i++) { // 25s * 10 ticks per second
//           await Future.delayed(const Duration(milliseconds: 100));
//           int seconds = (i / 10).floor() + 1;
//           int milliseconds = (i % 10) * 100;
//           emit(ViddeoState(
//             currentVideo: state.currentVideo,
//             lastSwitchTime: state.lastSwitchTime,
//             count: state.count,
//             isRestart: true,
//             id: state.id,
//             secondsInCurrentCount: seconds,
//             millisecondsInCurrentCount: milliseconds,
//           ));
//         }
//         Phoenix.rebirth(context);
//       } catch (e) {
//         _logger.e('Restart failed: $e');
//       }
//     } else {
//       emit
//       (ViddeoState(
//         currentVideo: state.currentVideo,
//         lastSwitchTime: now,
//         count: newCount,
//         isRestart: newIsRestart,
//         id: 1,
//         secondsInCurrentCount: 1,
//         millisecondsInCurrentCount: 0,
//       ));
//     }
//   }

//   void _onUpdateTick(UpdateTick event, Emitter<ViddeoState> emit) {
//     if (state.isRestart) return; // Skip during restart delay
//     int newMilliseconds = state.millisecondsInCurrentCount + 100;
//     int newSeconds = state.secondsInCurrentCount;

//     if (newMilliseconds >= 1000) {
//       newMilliseconds = 0;
//       newSeconds += 1;
//     }
//     if (newSeconds > ConfigCustom.durationSwitchVideoSecond) {
//       newSeconds = ConfigCustom.durationSwitchVideoSecond; // Cap at 30
//       newMilliseconds = 0;
//     }

//     emit(ViddeoState(
//       currentVideo: state.currentVideo,
//       lastSwitchTime: state.lastSwitchTime,
//       count: state.count,
//       isRestart: state.isRestart,
//       id: state.id,
//       secondsInCurrentCount: newSeconds,
//       millisecondsInCurrentCount: newMilliseconds,
//     ));
//   }

//   @override
//   Future<void> close() {
//     _countTimer?.cancel();
//     _tickTimer?.cancel();
//     _logger.i('VideoBloc closed, timers cancelled');
//     return super.close();
//   }
// }
