import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtech_transmitter_app/screen/socket_screen/model/infomation_broadcast_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'socket_event.dart';
import 'socket_state.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  socket_io.Socket? _socket;

  SocketBloc() : super(const SocketState()) {
    on<ConnectSocket>(_onConnectSocket);
    on<SubscribeToJackpot>(_onSubscribeToJackpot);
    on<BroadcastReceived>(_onBroadcastReceived);
    on<SocketErrorOccurred>(_onSocketErrorOccurred);
    on<SocketDisconnected>(_onSocketDisconnected);

    // Automatically connect on initialization
    add( ConnectSocket());
  }

  void _onConnectSocket(ConnectSocket event, Emitter<SocketState> emit) {
    if (_socket != null) return;

    _socket = socket_io.io(
      'http://localhost:8090', // Replace with your server URL if deployed
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket connected');
      add(const BroadcastReceived([{'status': 'connected'}]));
    });

    _socket!.on('broadcast_latest', (data) {
      add(BroadcastReceived([data])); // Wrap single object in list
    });

    _socket!.onError((error) {
      add(SocketErrorOccurred('Socket error: $error'));
    });

    _socket!.onDisconnect((_) {
      add( SocketDisconnected());
    });
  }

  void _onSubscribeToJackpot(SubscribeToJackpot event, Emitter<SocketState> emit) {
    if (state.isConnected && event.jackpotId.isNotEmpty) {
      _socket?.emit('subscribe_jackpot', event.jackpotId);
      print('Subscribed to jackpotId: ${event.jackpotId}');
    }
  }

  void _onBroadcastReceived(BroadcastReceived event, Emitter<SocketState> emit) {
    try {
      if (event.data.isNotEmpty && event.data[0].containsKey('status') && event.data[0]['status'] == 'connected') {
        emit(state.copyWith(isConnected: true, errorMessage: null));
      } else {
        final broadcasts = event.data
            .map((item) => InformationBroadcast.fromJson(item as Map<String, dynamic>))
            .toList();
        print('Received latest broadcasts: $broadcasts');
        emit(state.copyWith(latestBroadcasts: broadcasts, errorMessage: null));
      }
    } catch (e) {
      add(SocketErrorOccurred('Error parsing broadcast data: $e'));
    }
  }

  void _onSocketErrorOccurred(SocketErrorOccurred event, Emitter<SocketState> emit) {
    print(event.error);
    emit(state.copyWith(errorMessage: event.error, isConnected: false));
  }

  void _onSocketDisconnected(SocketDisconnected event, Emitter<SocketState> emit) {
    print('Socket disconnected');
    emit(state.copyWith(isConnected: false));
  }

  @override
  Future<void> close() {
    _socket?.disconnect();
    _socket = null;
    return super.close();
  }
}
