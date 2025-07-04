// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/hive_service/jackpot_hive_service.dart';
// import 'package:playtech_transmitter_app/service/config_custom.dart';
// import 'package:socket_io_client/socket_io_client.dart' as socket_io;
// import 'jackpot_price_event.dart';
// import 'jackpot_price_state.dart';

// class JackpotPriceBloc extends Bloc<JackpotPriceEvent, JackpotPriceState> {
//   socket_io.Socket? _socket;
//   final List<bool> _channelConnected = List.filled(ConfigCustom.webSocketEndpoints.length, false);
//   int _activeEndpointIndex = 0;
//   final int secondToReconnect = ConfigCustom.secondToReConnect;
//   final List<String> _unknownLevels = [];
//   final Map<String, bool> _isFirstUpdate = {
//     for (var name in ConfigCustom.validJackpotNames) name: true,
//   };
//   final Map<String, DateTime> _lastUpdateTime = {};
//   final JackpotHiveService hiveService = JackpotHiveService();
//   Timer? _freshnessTimer;
//   Timer? _reconnectTimer;

//   JackpotPriceBloc() : super(JackpotPriceState.initial()) {
//     on<JackpotPriceUpdateEvent>(_onUpdate);
//     on<JackpotPriceResetEvent>(_onReset);
//     on<JackpotPriceConnectionEvent>(_onConnection);
//     on<JackpotPriceVideoSwitchEvent>(_onVideoSwitch);
//     _initializeHiveAndConnect();
//   }

//   Future<void> _initializeHiveAndConnect() async {
//     try {
//       await hiveService.initHive();
//       _connectToWebSocket();
//       _startFreshnessCheck();
//     } catch (e) {
//       debugPrint('JackpotPriceBloc: Failed to initialize Hive: $e');
//       emit(state.copyWith(error: 'Failed to initialize Hive: $e'));
//     }
//   }

//   void _connectToWebSocket() {
//     if (isClosed) return;
//     if (_socket != null) {
//       _socket!.dispose();
//       _socket = null;
//       _channelConnected[_activeEndpointIndex] = false;
//     }

//     Future.delayed(Duration(milliseconds: 100 + Random().nextInt(2000)), () {
//       try {
//         final endpoint = ConfigCustom.webSocketEndpoints[_activeEndpointIndex];
//         debugPrint('JackpotPriceBloc: Connecting to Socket.IO $endpoint');
//         _socket = socket_io.io(
//           endpoint,
//           <String, dynamic>{
//             'transports': ['websocket'],
//             'autoConnect': false,
//           },
//         );

//         _socket!.connect();

//         _socket!.onConnect((_) {
//           debugPrint('JackpotPriceBloc: Connected to $endpoint');
//           _channelConnected[_activeEndpointIndex] = true;
//           _updateConnectionState();
//           add(const JackpotPriceConnectionEvent(true));
//         });

//         _socket!.on('broadcast_latest', (data) {
//           _processBroadcastData(data);
//         });

//         _socket!.onError((error) {
//           debugPrint('JackpotPriceBloc: Socket.IO error: $error');
//           _channelConnected[_activeEndpointIndex] = false;
//           _updateConnectionState();
//           add(JackpotPriceConnectionEvent(false, error: 'Socket.IO error: $error'));
//           _switchActiveEndpoint();
//         });

//         _socket!.onDisconnect((_) {
//           debugPrint('JackpotPriceBloc: Socket.IO disconnected');
//           _channelConnected[_activeEndpointIndex] = false;
//           _updateConnectionState();
//           add(const JackpotPriceConnectionEvent(false, error: 'Socket.IO disconnected'));
//           _switchActiveEndpoint();
//         });
//       } catch (e) {
//         debugPrint('JackpotPriceBloc: Failed to connect to Socket.IO: $e');
//         _channelConnected[_activeEndpointIndex] = false;
//         _updateConnectionState();
//         add(JackpotPriceConnectionEvent(false, error: 'Failed to connect: $e'));
//         _switchActiveEndpoint();
//       }
//     });
//   }

//   void _processBroadcastData(dynamic data) {
//     try {
//       debugPrint('JackpotPriceBloc: Received broadcast_latest: $data');
//       final Map<String, dynamic> broadcast = data as Map<String, dynamic>;
//       if (broadcast['jackpots'] == null) {
//         debugPrint('JackpotPriceBloc: Invalid broadcast data, missing jackpots');
//         return;
//       }

//       final jackpots = (broadcast['jackpots'] as List<dynamic>).cast<Map<String, dynamic>>();
//       final jackpotValues = Map<String, double>.from(state.jackpotValues);
//       final previousJackpotValues = Map<String, double>.from(state.previousJackpotValues);
//       final now = DateTime.now();
//       final batchToSave = <String, double>{};

//       for (var jackpot in jackpots) {
//         final level = jackpot['jackpotId'].toString();
//         final value = double.tryParse(jackpot['value'].toString()) ?? 0.0;
//         final key = ConfigCustom.getJackpotNameByLevel(level);
//         if (key == null) {
//           if (!_unknownLevels.contains(level)) {
//             _unknownLevels.add(level);
//             if (_unknownLevels.length > 5) {
//               debugPrint('JackpotPriceBloc: Excessive unknown levels: $_unknownLevels');
//             }
//           }
//           continue;
//         }

//         if (value == 0.0) {
//           debugPrint('JackpotPriceBloc: Ignored zero value for $key');
//           continue;
//         }

//         final currentValue = state.jackpotValues[key] ?? 0.0;
//         if (value < currentValue) {
//           debugPrint('JackpotPriceBloc: Ignored value $value for $key (less than current $currentValue)');
//           continue;
//         }

//         previousJackpotValues[key] = jackpotValues[key] ?? 0.0;
//         jackpotValues[key] = value;
//         _lastUpdateTime[key] = now;
//         _isFirstUpdate[key] = false;
//         batchToSave[key] = value;
//       }

//       if (batchToSave.isNotEmpty) {
//         try {
//           hiveService.appendJackpotHistory(batchToSave);
//           debugPrint('JackpotPriceBloc: Saved to Hive: $batchToSave');
//         } catch (e) {
//           debugPrint('JackpotPriceBloc: Failed to save to Hive: $e');
//         }
//       }

//       final validKeys = ConfigCustom.validJackpotNames.toSet();
//       jackpotValues.removeWhere((k, v) => !validKeys.contains(k));
//       previousJackpotValues.removeWhere((k, v) => !validKeys.contains(k));
//       debugPrint('JackpotPriceBloc: Updated jackpotValues: $jackpotValues');

//       emit(state.copyWith(
//         jackpotValues: jackpotValues,
//         previousJackpotValues: previousJackpotValues,
//         isConnected: true,
//         hasData: true,
//         error: null,
//         activeEndpoint: ConfigCustom.webSocketEndpoints[_activeEndpointIndex],
//         sourceName: ConfigCustom.webSocketEndpoints[_activeEndpointIndex],
//       ));
//     } catch (e) {
//       debugPrint('JackpotPriceBloc: Error processing broadcast data: $e');
//       add(JackpotPriceConnectionEvent(false, error: 'Error processing data: $e'));
//     }
//   }

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
//       _activeEndpointIndex = (previousActiveIndex + 1) % ConfigCustom.webSocketEndpoints.length;
//     }

//     if (previousActiveIndex != _activeEndpointIndex) {
//       debugPrint('JackpotPriceBloc: Switched active endpoint ${ConfigCustom.webSocketEndpoints[_activeEndpointIndex]}');
//       emit(state.copyWith(
//         activeEndpoint: ConfigCustom.webSocketEndpoints[_activeEndpointIndex],
//         sourceName: ConfigCustom.webSocketEndpoints[_activeEndpointIndex],
//       ));
//       _reconnectTimer?.cancel();
//       _reconnectTimer = Timer(Duration(seconds: secondToReconnect), _connectToWebSocket);
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
//       sourceName: state.sourceName,
//     ));
//   }

//   Future<void> _onConnection(JackpotPriceConnectionEvent event, Emitter<JackpotPriceState> emit) async {
//     debugPrint('JackpotPriceBloc: Connection status changed: isConnected=${event.isConnected}, error=${event.error}');
//     emit(state.copyWith(
//       isConnected: event.isConnected,
//       error: event.error,
//       sourceName: state.sourceName,
//     ));
//   }

//   Future<void> _onVideoSwitch(JackpotPriceVideoSwitchEvent event, Emitter<JackpotPriceState> emit) async {
//     debugPrint('JackpotPriceBloc: Video switch event for videoId ${event.videoId}');
//     // Implement video switch logic if needed
//   }

//   @override
//   Future<void> close() async {
//     debugPrint('JackpotPriceBloc: Closing Socket.IO');
//     _freshnessTimer?.cancel();
//     _reconnectTimer?.cancel();
//     _socket?.dispose();
//     _socket = null;
//     return super.close();
//   }
// }
