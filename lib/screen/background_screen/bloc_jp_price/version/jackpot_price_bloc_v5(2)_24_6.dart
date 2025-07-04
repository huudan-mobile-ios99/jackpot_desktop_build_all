// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/hive_service/jackpot_hive_service.dart';
// import 'package:playtech_transmitter_app/service/config_custom.dart';
// import 'package:web_socket_channel/io.dart';
// import 'jackpot_price_event.dart';
// import 'jackpot_price_state.dart';

// class JackpotPriceBloc extends Bloc<JackpotPriceEvent, JackpotPriceState> {
//   final List<IOWebSocketChannel?> _channels = List.filled(ConfigCustom.webSocketEndpoints.length, null);
//   final List<bool> _channelConnected = List.filled(ConfigCustom.webSocketEndpoints.length, false);
//   int _activeEndpointIndex = 0;
//   final int secondToReconnect = ConfigCustom.secondToReConnect;
//   final List<String> _unknownLevels = [];
//   final Map<String, bool> _isFirstUpdate = {
//     for (var name in ConfigCustom.validJackpotNames) name: true,
//   };
//   final Map<String, double> _currentBatchValues = {};
//   Map<String, double> _lastSavedBatch = {};
//   final Map<String, DateTime> _lastUpdateTime = {};
//   final JackpotHiveService hiveService = JackpotHiveService();
//   Timer? _freshnessTimer;

//   JackpotPriceBloc() : super(JackpotPriceState.initial()) {
//     on<JackpotPriceUpdateEvent>(_onUpdate);
//     on<JackpotPriceResetEvent>(_onReset);
//     on<JackpotPriceConnectionEvent>(_onConnection);
//     _initializeHiveAndConnect();
//   }

//   Future<void> _initializeHiveAndConnect() async {
//     try {
//       await hiveService.initHive();
//       _connectToAllWebSockets();
//       _startFreshnessCheck();
//     } catch (e) {
//       debugPrint('JackpotPriceBloc: Failed to initialize Hive: $e');
//     }
//   }

//   void _connectToAllWebSockets() {
//     for (int i = 0; i < ConfigCustom.webSocketEndpoints.length; i++) {
//       _connectToWebSocket(i);
//     }
//   }



//   void _connectToWebSocket(int index) async {
//   if (isClosed) {
//     debugPrint('JackpotPriceBloc: Skipping connection for endpoint $index, bloc is closed');
//     return;
//   }
//   if (_channels[index] != null) {
//     try {
//       await _channels[index]?.sink.close(1000, 'Reconnecting');
//     } catch (e) {
//       debugPrint('JackpotPriceBloc: Error closing channel $index: $e');
//     }
//     _channels[index] = null;
//     _channelConnected[index] = false;
//   }
//   await Future.delayed(const Duration(milliseconds: 100));
//   try {
//     debugPrint('JackpotPriceBloc: Connecting to WebSocket ${ConfigCustom.webSocketEndpoints[index]}');
//     _channels[index] = IOWebSocketChannel.connect(ConfigCustom.webSocketEndpoints[index]);
//     _channelConnected[index] = true;
//     _updateConnectionState();
//     // Temporary map to collect jackpot values
//     Map<String, dynamic> tempJackpotBatch = {};
//     _channels[index]!.stream.listen(
//       (message) async {
//         try {
//           debugPrint('JackpotPriceBloc[$index]: $message');
//           final data = jsonDecode(message);
//           final level = data['Id'].toString();
//           final value = double.tryParse(data['Value'].toString()) ?? 0.0;
//           final key = ConfigCustom.getJackpotNameByLevel(level);
//           if (key == null) {
//             if (!_unknownLevels.contains(level)) {
//               _unknownLevels.add(level);
//               if (_unknownLevels.length > 5) {
//                 debugPrint('JackpotPriceBloc: Excessive unknown levels: $_unknownLevels');
//               }
//             }
//             return;
//           }
//           if (index == _activeEndpointIndex) {
//             if (value == 0.0) {
//               debugPrint('JackpotPriceBloc: [Endpoint $index] Ignored zero value for $key');
//               return;
//             }
//             final currentValue = state.jackpotValues[key] ?? 0.0;
//             if (value < currentValue) {
//               debugPrint('JackpotPriceBloc: [Endpoint $index] Ignored value $value for $key (less than current $currentValue)');
//               return;
//             }
//             // Add to temporary batch
//             tempJackpotBatch[key] = value;
//             debugPrint('JackpotPriceBloc: Added $key: $value to tempJackpotBatch');
//             debugPrint('JackpotPriceBloc: Current tempJackpotBatch: $tempJackpotBatch');
//             // Check if batch contains all 9 required jackpot names
//           if (tempJackpotBatch.keys.toSet().containsAll(ConfigCustom.selectedJackpotNames)) {
//             debugPrint('JackpotPriceBloc: FinishedTempJackpotBatch: $tempJackpotBatch');
//           }

//             // Update state
//             final isFirst = _isFirstUpdate[key] ?? false;
//             final now = DateTime.now();
//             _currentBatchValues[key] = value;
//             if (state.jackpotValues[key] != value) {
//               final jackpotValues = Map<String, double>.from(state.jackpotValues);
//               final previousJackpotValues = Map<String, double>.from(state.previousJackpotValues);
//               previousJackpotValues[key] = jackpotValues[key] ?? 0.0;
//               jackpotValues[key] = value;
//               _lastUpdateTime[key] = now;
//               if (isFirst) {
//                 _isFirstUpdate[key] = false;
//               }
//               final validKeys = ConfigCustom.validJackpotNames.toSet();
//               jackpotValues.removeWhere((k, v) => !validKeys.contains(k));
//               previousJackpotValues.removeWhere((k, v) => !validKeys.contains(k));
//               debugPrint('JackpotPriceBloc: Updated $key to $value');
//               emit(state.copyWith(
//                 jackpotValues: jackpotValues,
//                 previousJackpotValues: previousJackpotValues,
//                 isConnected: true,
//                 hasData: true,
//                 error: null,
//                 activeEndpoint: ConfigCustom.webSocketEndpoints[_activeEndpointIndex],
//                 sourceName: ConfigCustom.webSocketEndpoints[_activeEndpointIndex],
//               ));
//             }
//           }
//         } catch (e) {
//           debugPrint('JackpotPriceBloc: [Endpoint $index] Error parsing message: $e, message: $message');
//         }
//       },
//       onError: (error) {
//         debugPrint('JackpotPriceBloc: [Endpoint $index] WebSocket error: $error');
//         _channelConnected[index] = false;
//         _updateConnectionState();
//         _switchActiveEndpoint();
//         Timer(Duration(seconds: secondToReconnect), () => _connectToWebSocket(index));
//       },
//       onDone: () {
//         debugPrint('JackpotPriceBloc: [Endpoint $index] WebSocket closed');
//         _channelConnected[index] = false;
//         _updateConnectionState();
//         _switchActiveEndpoint();
//         Timer(Duration(seconds: secondToReconnect), () => _connectToWebSocket(index));
//       },
//     );
//   } catch (e) {
//     debugPrint('JackpotPriceBloc: Failed to connect to WebSocket $index: $e');
//     _channelConnected[index] = false;
//     _updateConnectionState();
//     _switchActiveEndpoint();
//     Timer(Duration(seconds: secondToReconnect), () => _connectToWebSocket(index));
//   }
// }

//   void _updateConnectionState() {
//     if (isClosed) return;
//     final isAnyConnected = _channelConnected.any((connected) => connected);
//     emit(state.copyWith(
//       isConnected: isAnyConnected,
//       error: isAnyConnected ? null : 'No active connections',
//       sourceName: ConfigCustom.webSocketEndpoints[_activeEndpointIndex],
//     ));
//   }

//   void _switchActiveEndpoint() {
//     if (isClosed) return;
//     final previousActiveIndex = _activeEndpointIndex;
//     for (int i = 0; i < _channelConnected.length; i++) {
//       if (_channelConnected[i]) {
//         _activeEndpointIndex = i;
//         break;
//       }
//     }
//     if (!_channelConnected.any((connected) => connected)) {
//       _activeEndpointIndex = 0;
//     }

//     if (previousActiveIndex != _activeEndpointIndex) {
//       debugPrint('JackpotPriceBloc: Switched active endpoint ${ConfigCustom.webSocketEndpoints[_activeEndpointIndex]}');
//       emit(state.copyWith(
//         activeEndpoint: ConfigCustom.webSocketEndpoints[_activeEndpointIndex],
//         isConnected: _channelConnected[_activeEndpointIndex],
//         hasData: state.hasData,
//         sourceName: ConfigCustom.webSocketEndpoints[_activeEndpointIndex],
//       ));
//     }
//   }

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
//     final level = event.level;
//     final key = ConfigCustom.getJackpotNameByLevel(level);
//     if (key == null) {
//       if (!_unknownLevels.contains(level)) {
//         _unknownLevels.add(level);
//         if (_unknownLevels.length > 5) {
//           debugPrint('JackpotPriceBloc: Excessive unknown levels: $_unknownLevels');
//         }
//       }
//       return;
//     }
//     debugPrint('JackpotPriceBloc: Update event for $key ignored, processing moved to WebSocket listener');
//   }

//   bool _isBatchEqual(Map<String, double> batch1, Map<String, double> batch2) {
//     if (batch1.length != batch2.length) return false;
//     for (var key in batch1.keys) {
//       if (batch2[key] != batch1[key]) return false;
//     }
//     return true;
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
//       isConnected: state.isConnected,
//       hasData: true,
//       error: null,
//       sourceName: state.sourceName,
//     ));

//     _currentBatchValues[key] = resetValue;
//   }

//   Future<void> _onConnection(JackpotPriceConnectionEvent event, Emitter<JackpotPriceState> emit) async {
//     debugPrint('JackpotPriceBloc: Connection status changed: isConnected=${event.isConnected}, error=${event.error}');
//     emit(state.copyWith(
//       isConnected: event.isConnected,
//       error: event.error,
//       sourceName: state.sourceName,
//     ));
//   }

//   @override
//   Future<void> close() async {
//     debugPrint('JackpotPriceBloc: Closing all WebSockets');
//     _freshnessTimer?.cancel();
//     for (int i = 0; i < _channels.length; i++) {
//       if (_channels[i] != null) {
//         await _channels[i]?.sink.close(1000, 'Bloc closed');
//         _channels[i] = null;
//       }
//     }
//     return super.close();
//   }
// }
