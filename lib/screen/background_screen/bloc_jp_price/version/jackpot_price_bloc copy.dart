// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/jackpot_hive_service.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/jackpot_state_state.dart';
// import 'package:playtech_transmitter_app/service/config_custom.dart';
// import 'package:web_socket_channel/io.dart';
// import 'jackpot_price_event.dart';

// class JackpotPriceBloc extends Bloc<JackpotPriceEvent, JackpotPriceState> {
//   late IOWebSocketChannel channel;
//   final int secondToReconnect = ConfigCustom.secondToReConnect;
//   final List<String> _unknownLevels = [];
//   final Map<String, bool> _isFirstUpdate = {
//     for (var name in ConfigCustom.validJackpotNames) name: true,
//   };
//   Map<String, double> _currentBatchValues = {};
//   final Map<String, DateTime> _lastUpdateTime = {};
//   final JackpotHiveService hiveService = JackpotHiveService();
//   Timer? _batchTimeout;
//   static const int batchTimeoutSeconds = 5; // Timeout if Id:46 not received

//   JackpotPriceBloc() : super(JackpotPriceState.initial()) {
//     on<JackpotPriceResetEvent>(_onReset);
//     on<JackpotPriceConnectionEvent>(_onConnection);
//     _initializeHiveAndConnect();
//   }

//   Future<void> _initializeHiveAndConnect() async {
//     try {
//       await hiveService.initHive();
//       _connectToWebSocket();
//     } catch (e) {
//       debugPrint('JackpotPriceBloc: Failed to initialize Hive: $e');
//     }
//   }

//   void _connectToWebSocket() async {
//   // Add a fixed delay of 0.1 seconds before attempting connection
//   await Future.delayed(Duration(milliseconds: 500));

//   try {
//     debugPrint('JackpotPriceBloc: Connecting to WebSocket ${ConfigCustom.endpoint_web_socket_Sub1}');
//     channel = IOWebSocketChannel.connect(ConfigCustom.endpoint_web_socket_Sub1);
//     emit(state.copyWith(isConnected: true, error: null));
//     channel.stream.listen(
//       (message) async {
//         try {
//           debugPrint('JackpotPriceBloc: Received message at ${DateTime.now().toIso8601String()}: $message');
//           final data = jsonDecode(message);
//           final level = data['Id'].toString();
//           final value = double.tryParse(data['Value'].toString()) ?? 0.0;
//           final key = ConfigCustom.getJackpotNameByLevel(level);
//           if (key == null) {
//             if (!_unknownLevels.contains(level)) {
//               _unknownLevels.add(level);
//               // debugPrint('JackpotPriceBloc: Unknown level: $level, tracked: $_unknownLevels');
//               if (_unknownLevels.length > 5) {
//                 // debugPrint('JackpotPriceBloc: Excessive unknown levels: $_unknownLevels');
//               }
//             }
//             return;
//           }

//           // Update batch and state
//           _currentBatchValues[key] = value;
//           // debugPrint('JackpotPriceBloc: Added to batch: $key=$value, batch size: ${_currentBatchValues.length}');

//           final isFirst = _isFirstUpdate[key] ?? false;
//           final now = DateTime.now();

//           final jackpotValues = Map<String, double>.from(state.jackpotValues);
//           final previousJackpotValues = Map<String, double>.from(state.previousJackpotValues);

//           if (jackpotValues[key] != value) {
//             previousJackpotValues[key] = jackpotValues[key] ?? 0.0;
//             jackpotValues[key] = value;
//             _lastUpdateTime[key] = now;
//             if (isFirst) {
//               _isFirstUpdate[key] = false;
//             }
//             final validKeys = ConfigCustom.validJackpotNames.toSet();
//             jackpotValues.removeWhere((k, v) => !validKeys.contains(k));
//             previousJackpotValues.removeWhere((k, v) => !validKeys.contains(k));
//             emit(state.copyWith(
//               jackpotValues: jackpotValues,
//               previousJackpotValues: previousJackpotValues,
//               isConnected: true,
//               error: null,
//             ));
//           }

//           // Reset batch timeout
//           _batchTimeout?.cancel();
//           _batchTimeout = Timer(const Duration(seconds: batchTimeoutSeconds), () {
//             // debugPrint('JackpotPriceBloc: Batch timeout, saving partial batch: $_currentBatchValues');
//             _saveBatchToHive();
//           });

//           // Save batch to Hive only after Id:46
//           if (level == '46') { // Monthly is last in sequence
//             _batchTimeout?.cancel();
//             await _saveBatchToHive();
//           }
//         } catch (e) {
//           debugPrint('JackpotPriceBloc: Error parsing message: $e, message: $message');
//         }
//       },
//       onError: (error) {
//         debugPrint('JackpotPriceBloc: WebSocket error: $error');
//         emit(state.copyWith(isConnected: false, error: error.toString()));
//         _batchTimeout?.cancel();
//         Future.delayed(Duration(seconds: secondToReconnect), _connectToWebSocket);
//       },
//       onDone: () {
//         debugPrint('JackpotPriceBloc: WebSocket closed');
//         emit(state.copyWith(isConnected: false, error: null));
//         _batchTimeout?.cancel();
//         Future.delayed(Duration(seconds: secondToReconnect), _connectToWebSocket);
//       },
//     );
//   } catch (e) {
//     debugPrint('JackpotPriceBloc: Failed to connect to WebSocket: $e');
//     emit(state.copyWith(isConnected: false, error: e.toString()));
//     Future.delayed(Duration(seconds: secondToReconnect), _connectToWebSocket);
//   }
// }

//   Future<void> _saveBatchToHive() async {
//     if (_currentBatchValues.isNotEmpty) {
//       try {
//         await hiveService.appendJackpotHistory(Map.from(_currentBatchValues));
//         debugPrint('JackpotPriceBloc: Saved complete batch to Hive: $_currentBatchValues');
//         // Clear batch after saving
//         _currentBatchValues = {};
//       } catch (e) {
//         debugPrint('JackpotPriceBloc: Failed to save batch to Hive: $e');
//       }
//     } else {
//       debugPrint('JackpotPriceBloc: Skipped saving empty batch to Hive');
//     }
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
//     emit(state.copyWith(
//       jackpotValues: jackpotValues,
//       previousJackpotValues: previousJackpotValues,
//       isConnected: true,
//       error: null,
//     ));

//     // Update batch and save immediately for resets
//     _currentBatchValues[key] = resetValue;
//     await _saveBatchToHive();
//   }

//   Future<void> _onConnection(JackpotPriceConnectionEvent event, Emitter<JackpotPriceState> emit) async {
//     debugPrint('JackpotPriceBloc: Connection status changed: isConnected=${event.isConnected}, error=${event.error}');
//     emit(state.copyWith(
//       isConnected: event.isConnected,
//       error: event.error,
//     ));
//   }

//   @override
//   Future<void> close() {
//     debugPrint('JackpotPriceBloc: Closing WebSocket');
//     _batchTimeout?.cancel();
//     channel.sink.close(1000, 'Bloc closed');
//     return super.close();
//   }
// }
