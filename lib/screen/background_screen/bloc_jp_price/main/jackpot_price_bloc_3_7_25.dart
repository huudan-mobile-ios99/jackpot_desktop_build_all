// // import 'dart:async';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:playtech_transmitter_app/service/hive_service/jackpot_hive_service.dart';
// import 'package:playtech_transmitter_app/service/config_custom.dart';
// import 'package:playtech_transmitter_app/service/socket_service/socket_service.dart';
// import 'package:socket_io_client/socket_io_client.dart' as socket_io;
// import 'jackpot_price_event.dart';
// import 'jackpot_price_state.dart';


// class JackpotPriceBloc extends Bloc<JackpotPriceEvent, JackpotPriceState> {
//   final SocketService _socketService;
//   final List<String> _unknownLevels = [];
//   final Map<String, bool> _isFirstUpdate = {
//     for (var name in ConfigCustom.validJackpotNames) name: true,
//   };
//   final Map<String, DateTime> _lastUpdateTime = {};
//   final JackpotHiveService hiveService = JackpotHiveService();
//   Timer? _freshnessTimer;
//   StreamSubscription<Map<String, dynamic>>? _broadcastSubscription;
//   StreamSubscription<bool>? _connectionSubscription;

//   JackpotPriceBloc({SocketService? socketService})
//       : _socketService = socketService ?? SocketService(),
//         super(JackpotPriceState.initial()) {
//     on<JackpotPriceUpdateEvent>(_onUpdate);
//     on<JackpotPriceResetEvent>(_onReset);
//     on<JackpotPriceConnectionEvent>(_onConnection);
//     on<JackpotPriceVideoSwitchEvent>(_onVideoSwitch);
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     try {
//       await hiveService.initHive();
//       debugPrint('JackpotPriceBloc: Hive initialized successfully');
//       _socketService.initialize();
//       _startFreshnessCheck();
//       _listenToSocketEvents();
//     } catch (e) {
//       debugPrint('JackpotPriceBloc: Failed to initialize Hive: $e');
//       emit(state.copyWith(error: 'Failed to initialize Hive: $e'));
//     }
//   }

//   void _listenToSocketEvents() {
//     _broadcastSubscription?.cancel();
//     _connectionSubscription?.cancel();

//     _broadcastSubscription = _socketService.broadcastStream.listen((data) {
//       _processBroadcastData(data);
//     }, onError: (error) {
//       debugPrint('JackpotPriceBloc: Broadcast stream error: $error');
//       add(JackpotPriceConnectionEvent(false, error: 'Broadcast stream error: $error'));
//     });

//     _connectionSubscription = _socketService.connectionStream.listen((isConnected) {
//       add(JackpotPriceConnectionEvent(isConnected, error: isConnected ? null : 'No active connection'));
//     }, onError: (error) {
//       debugPrint('JackpotPriceBloc: Connection stream error: $error');
//       add(JackpotPriceConnectionEvent(false, error: 'Connection stream error: $error'));
//     });
//   }

//   void _processBroadcastData(Map<String, dynamic> broadcast) {
//   try {
//     if (broadcast['jackpots'] == null) {
//       debugPrint('JackpotPriceBloc: Invalid broadcast data, missing jackpots');
//       return;
//     }

//     final jackpots = (broadcast['jackpots'] as List<dynamic>).cast<Map<String, dynamic>>();
//     final jackpotValues = Map<String, double>.from(state.jackpotValues);
//     final previousJackpotValues = Map<String, double>.from(state.previousJackpotValues);
//     final now = DateTime.now();
//     final batchToSave = <String, double>{};

//     for (var jackpot in jackpots) {
//       final level = jackpot['jackpotId'].toString();
//       final value = double.tryParse(jackpot['value'].toString()) ?? 0.0;
//       final key = ConfigCustom.getJackpotNameByLevel(level);
//       if (key == null) {
//         if (!_unknownLevels.contains(level)) {
//           _unknownLevels.add(level);
//           debugPrint('JackpotPriceBloc: Unknown level: $level');
//         }
//         continue;
//       }

//       if (value == 0.0) {
//         debugPrint('JackpotPriceBloc: Ignored zero value for $key');
//         continue;
//       }

//       final currentValue = state.jackpotValues[key] ?? 0.0;
//       if (value == currentValue) {
//         debugPrint('JackpotPriceBloc: Skipped update for $key (value $value equals current $currentValue)');
//         continue;
//       }

//       if (value < currentValue) {
//         debugPrint('JackpotPriceBloc: Ignored value $value for $key (less than current $currentValue)');
//         // continue;
//       }

//       previousJackpotValues[key] = currentValue;
//       jackpotValues[key] = value;
//       _lastUpdateTime[key] = now;
//       _isFirstUpdate[key] = false;
//       batchToSave[key] = value;
//       debugPrint('JackpotPriceBloc: Updated $key: previous=$currentValue, current=$value');
//     }

//     if (batchToSave.isNotEmpty) {
//       try {
//         hiveService.appendJackpotHistory(batchToSave, );
//         debugPrint('JackpotPriceBloc: Saved to Hive: $batchToSave, Previous: $previousJackpotValues');
//       } catch (e) {
//         debugPrint('JackpotPriceBloc: Failed to save to Hive: $e');
//       }
//     }

//     final validKeys = ConfigCustom.validJackpotNames.toSet();
//     jackpotValues.removeWhere((k, v) => !validKeys.contains(k));
//     previousJackpotValues.removeWhere((k, v) => !validKeys.contains(k));
//     debugPrint('JackpotPriceBloc: Updated jackpotValues: $jackpotValues');
//     debugPrint('JackpotPriceBloc: Previous jackpotValues: $previousJackpotValues');

//     emit(state.copyWith(
//       jackpotValues: jackpotValues,
//       previousJackpotValues: previousJackpotValues,
//       isConnected: true,
//       hasData: true,
//       error: null,
//       activeEndpoint: ConfigCustom.endpointSocketMain,
//       sourceName: ConfigCustom.endpointSocketMain,
//     ));
//   } catch (e) {
//     debugPrint('JackpotPriceBloc: Error processing broadcast data: $e');
//     add(JackpotPriceConnectionEvent(false, error: 'Error processing data: $e'));
//   }
// }

//   void _startFreshnessCheck() {
//     _freshnessTimer?.cancel();
//     _freshnessTimer = Timer.periodic(const Duration(seconds: ConfigCustom.dataFreshnessInterval), (_) {
//       if (isClosed) return;
//       final now = DateTime.now();
//       final isFresh = _lastUpdateTime.values.any((time) =>
//           now.difference(time).inSeconds <= ConfigCustom.dataFreshnessInterval);
//       if (state.hasData != isFresh) {
//         emit(state.copyWith(hasData: isFresh));
//       }
//     });
//   }

//   Future<void> _onUpdate(JackpotPriceUpdateEvent event, Emitter<JackpotPriceState> emit) async {
//     debugPrint('JackpotPriceBloc: Update event for level ${event.level} ignored, processing in Socket.IO listener');
//   }

//   Future<void> _onReset(JackpotPriceResetEvent event, Emitter<JackpotPriceState> emit) async {
//     final key = ConfigCustom.getJackpotNameByLevel(event.level);
//     if (key == null) {
//       debugPrint('JackpotPriceBloc: Unknown level for reset: ${event.level}');
//       return;
//     }

//     final resetValue = ConfigCustom.getResetValueByLevel(event.level);
//     if (resetValue == null) {
//       debugPrint('JackpotPriceBloc: No reset value found for $key');
//       return;
//     }

//     final jackpotValues = Map<String, double>.from(state.jackpotValues);
//     final previousJackpotValues = Map<String, double>.from(state.previousJackpotValues);

//     previousJackpotValues[key] = jackpotValues[key] ?? 0.0;
//     jackpotValues[key] = resetValue;
//     _lastUpdateTime[key] = DateTime.now();
//     _isFirstUpdate[key] = false;
//     debugPrint('JackpotPriceBloc: Reset $key to $resetValue');

//     final batchToSave = Map<String, double>.from(jackpotValues)
//       ..[key] = resetValue;
//     try {
//       await hiveService.appendJackpotHistory(batchToSave);
//       debugPrint('JackpotPriceBloc: Saved reset batch to Hive: $batchToSave');
//     } catch (e) {
//       debugPrint('JackpotPriceBloc: Failed to save reset batch to Hive: $e');
//     }

//     emit(state.copyWith(
//       jackpotValues: jackpotValues,
//       previousJackpotValues: previousJackpotValues,
//       isConnected: state.isConnected,
//       hasData: true,
//       error: null,
//       sourceName: ConfigCustom.endpointSocketMain,
//     ));
//   }

//   Future<void> _onConnection(JackpotPriceConnectionEvent event, Emitter<JackpotPriceState> emit) async {
//     debugPrint('JackpotPriceBloc: Connection status changed: isConnected=${event.isConnected}, error=${event.error}');
//     emit(state.copyWith(
//       isConnected: event.isConnected,
//       error: event.error,
//       sourceName: ConfigCustom.endpointSocketMain,
//     ));
//   }

//   Future<void> _onVideoSwitch(JackpotPriceVideoSwitchEvent event, Emitter<JackpotPriceState> emit) async {
//     debugPrint('JackpotPriceBloc: Video switch event for videoId ${event.videoId}');
//     // Implement video switch logic if needed
//   }

//   @override
//   Future<void> close() async {
//     debugPrint('JackpotPriceBloc: Closing');
//     _freshnessTimer?.cancel();
//     _broadcastSubscription?.cancel();
//     _connectionSubscription?.cancel();
//     _socketService.dispose();
//     return super.close();
//   }
// }
