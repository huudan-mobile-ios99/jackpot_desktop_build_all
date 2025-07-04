import 'package:equatable/equatable.dart';
import 'package:playtech_transmitter_app/screen/socket_screen/model/infomation_broadcast_model.dart';

class SocketState extends Equatable {
  final bool isConnected;
  final List<InformationBroadcast> latestBroadcasts; // Changed to List
  final String? errorMessage;

  const SocketState({
    this.isConnected = false,
    this.latestBroadcasts = const [], // Initialize as empty list
    this.errorMessage,
  });

  SocketState copyWith({
    bool? isConnected,
    List<InformationBroadcast>? latestBroadcasts,
    String? errorMessage,
  }) {
    return SocketState(
      isConnected: isConnected ?? this.isConnected,
      latestBroadcasts: latestBroadcasts ?? this.latestBroadcasts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isConnected, latestBroadcasts, errorMessage];
}
