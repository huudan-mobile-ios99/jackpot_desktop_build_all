part of 'video_bloc.dart';

class ViddeoState extends Equatable {
  final String currentVideo;
  final int id;
  final DateTime lastSwitchTime;
  final int count;
  final bool isRestart;
  final String  runNumber;


  const ViddeoState({
    required this.currentVideo,
    required this.id,
    required this.lastSwitchTime,
    this.count = 0,
    this.isRestart = false,
    this.runNumber= '1st run'
  });

  @override
  List<Object> get props => [currentVideo, id, lastSwitchTime, count, isRestart,runNumber];
}







// class ViddeoState extends Equatable {
//   final String currentVideo;
//   final int id;
//   final DateTime lastSwitchTime;
//   final int count;
//   final bool isRestart;
//   final int secondsInCurrentCount;
//   final int millisecondsInCurrentCount; // New field for milliseconds

//   const ViddeoState({
//     required this.currentVideo,
//     required this.id,
//     required this.lastSwitchTime,
//     this.count = 0,
//     this.isRestart = false,
//     this.secondsInCurrentCount = 1,
//     this.millisecondsInCurrentCount = 0,
//   });

//   @override
//   List<Object> get props => [
//         currentVideo,
//         id,
//         lastSwitchTime,
//         count,
//         isRestart,
//         secondsInCurrentCount,
//         millisecondsInCurrentCount,
//       ];
// }
