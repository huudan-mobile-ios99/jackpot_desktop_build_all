import 'package:equatable/equatable.dart';

abstract class SocketEvent extends Equatable {
  const SocketEvent();

  @override
  List<Object?> get props => [];
}

class ConnectSocket extends SocketEvent {}

class SubscribeToJackpot extends SocketEvent {
  final String jackpotId;

  const SubscribeToJackpot(this.jackpotId);

  @override
  List<Object?> get props => [jackpotId];
}

class BroadcastReceived extends SocketEvent {
  final List<dynamic> data; // Changed to List<dynamic> to match JSON structure

  const BroadcastReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class SocketErrorOccurred extends SocketEvent {
  final String error;

  const SocketErrorOccurred(this.error);

  @override
  List<Object?> get props => [error];
}

class SocketDisconnected extends SocketEvent {}
