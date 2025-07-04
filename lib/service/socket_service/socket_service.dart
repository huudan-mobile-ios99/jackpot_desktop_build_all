import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:playtech_transmitter_app/service/config_custom.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SocketService {

  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  socket_io.Socket? _socket;
  //broadcast stream for receiving updates
  final _broadcastStreamController = StreamController<Map<String, dynamic>>.broadcast();
  //hit stream for receiving specific hit events
  final _hitStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStreamController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get broadcastStream => _broadcastStreamController.stream;
  Stream<Map<String, dynamic>> get hitStream => _hitStreamController.stream;
  Stream<bool> get connectionStream => _connectionStreamController.stream;

  void initialize() {
     if (_socket != null) {
      debugPrint('[${DateTime.now().toIso8601String()}] SocketService: Socket already initialized');
      return;
    }


    try {
      debugPrint('[${DateTime.now().toIso8601String()}] SocketService: Initializing Socket.IO ');
      _socket = socket_io.io(
        ConfigCustom.endpointSocketMain,
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'reconnection': true,
          'reconnectionAttempts': 10,
          'reconnectionDelay': 15000,
          'reconnectionDelayMax': 30000,
        },
      );
      _socket!.connect();
      _socket!.onConnect((_) {
        debugPrint('[${DateTime.now().toIso8601String()}] SocketService: Connected ');
        _connectionStreamController.add(true);
      });
      _socket!.onReconnect((_) {
        debugPrint('[${DateTime.now().toIso8601String()}] SocketService: Reconnected ');
        _connectionStreamController.add(true);
      });
      _socket!.onReconnectAttempt((attempt) {
        debugPrint('[${DateTime.now().toIso8601String()}] SocketService: Reconnection attempt #$attempt');
      });

      _socket!.onReconnectError((error) {
        debugPrint('[${DateTime.now().toIso8601String()}] SocketService: Reconnection error: $error');
        _connectionStreamController.add(false);
      });

      _socket!.on('broadcast_latest', (data) {
        if (data is Map<String, dynamic>) {
          // debugPrint('SocketService: Received broadcast_latest: $data');
          _broadcastStreamController.add(data);
        } else {
          debugPrint('SocketService: Invalid broadcast_latest data type: ${data.runtimeType}');
        }
      });

       _socket!.on('hit_latest', (data) {
        try {
          Map<String, dynamic> rawHit;
          if (data is String) {
            rawHit = jsonDecode(data) as Map<String, dynamic>;
          } else if (data is Map) {
            rawHit = Map<String, dynamic>.from(data);
          } else {
            debugPrint('SocketService: Invalid hit_latest data format: ${data.runtimeType}');
            return;
          }
          if (!rawHit.containsKey('jackpotId') || !rawHit.containsKey('value')) {
            debugPrint('SocketService: Invalid hit_latest missing required fields: $rawHit');
            return;
          }
          final hit = {
            ...rawHit,
            'id': rawHit['jackpotId'].toString(), // Map jackpotId to id
            'amount': rawHit['value']?.toString() ?? '0', // Map value to amount
          };
          debugPrint('SocketService: Received hit_latest: $hit');
          _hitStreamController.add(hit);
        } catch (e) {
          debugPrint('SocketService: Error parsing hit_latest data: $e, Raw data: $data');
        }
      });

      _socket!.onError((error) {
        debugPrint('[${DateTime.now().toIso8601String()}] SocketService: Socket.IO error: $error');
        _connectionStreamController.add(false);
      });

      _socket!.onDisconnect((_) {
        debugPrint('[${DateTime.now().toIso8601String()}] SocketService: Socket.IO disconnected');
        _connectionStreamController.add(false);
      });

      _socket!.onConnectError((error) {
        debugPrint('[${DateTime.now().toIso8601String()}] SocketService: Connection error: $error');
        _connectionStreamController.add(false);
      });
    } catch (e) {
      debugPrint('SocketService: Failed to initialize Socket.IO: $e');
      _connectionStreamController.add(false);
    }
  }

  void dispose() {
    debugPrint('[${DateTime.now().toIso8601String()}] SocketService: Disposing Socket.IO');
    _socket?.dispose();
    _socket = null;
    // _broadcastStreamController.close();
    // _connectionStreamController.close();
  }
}


