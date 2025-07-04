import 'package:equatable/equatable.dart';
import 'package:playtech_transmitter_app/service/config_custom.dart';

final class JackpotPriceState extends Equatable {
  final bool isConnected;
  final String? error;
  final bool hasData;
  final Map<String, double> jackpotValues;
  final Map<String, double> previousJackpotValues;
  final String activeEndpoint;
  final String sourceName;

  const JackpotPriceState({
    required this.isConnected,
    this.error,
    required this.hasData,
    required this.jackpotValues,
    required this.previousJackpotValues,
    required this.activeEndpoint,
    required this.sourceName,
  });

  factory JackpotPriceState.initial() => JackpotPriceState(
        isConnected: false,
        error: null,
        hasData: false,
        jackpotValues: {
          for (var name in ConfigCustom.validJackpotNames) name: 0.0,
        },
        previousJackpotValues: {
          for (var name in ConfigCustom.validJackpotNames) name: 0.0,
        },
        activeEndpoint: ConfigCustom.endpointSocketMain,
        sourceName: ConfigCustom.endpointSocketMain,
      );

  JackpotPriceState copyWith({
    bool? isConnected,
    String? error,
    bool? hasData,
    Map<String, double>? jackpotValues,
    Map<String, double>? previousJackpotValues,
    String? activeEndpoint,
    String? sourceName,
  }) {
    return JackpotPriceState(
      isConnected: isConnected ?? this.isConnected,
      error: error ?? this.error,
      hasData: hasData ?? this.hasData,
      jackpotValues: jackpotValues ?? this.jackpotValues,
      previousJackpotValues: previousJackpotValues ?? this.previousJackpotValues,
      activeEndpoint: activeEndpoint ?? this.activeEndpoint,
      sourceName: sourceName ?? this.sourceName,
    );
  }

  @override
  List<Object?> get props => [
        isConnected,
        hasData,
        error,
        jackpotValues,
        previousJackpotValues,
        activeEndpoint,
        sourceName,
      ];
}
