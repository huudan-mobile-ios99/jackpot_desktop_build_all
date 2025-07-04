class InformationBroadcast {
  final int logId;
  final List<Jackpot> jackpots;
  final DateTime timestamp;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  InformationBroadcast({
    required this.logId,
    required this.jackpots,
    required this.timestamp,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InformationBroadcast.fromJson(Map<String, dynamic> json) {
    return InformationBroadcast(
      logId: json['logId'] as int,
      jackpots: (json['jackpots'] as List<dynamic>)
          .map((j) => Jackpot.fromJson(j as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      id: json['_id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'InformationBroadcast(logId: $logId, jackpots: $jackpots, timestamp: $timestamp)';
  }
}

class Jackpot {
  final String jackpotId;
  final String? jackpotName;
  final double value;

  Jackpot({
    required this.jackpotId,
    this.jackpotName,
    required this.value,
  });

  factory Jackpot.fromJson(Map<String, dynamic> json) {
    return Jackpot(
      jackpotId: json['jackpotId'] as String,
      jackpotName: json['jackpotName'] as String?,
      value: (json['value'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Jackpot(jackpotId: $jackpotId, name: $jackpotName, value: $value)';
  }
}
