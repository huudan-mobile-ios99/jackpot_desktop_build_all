// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:playtech_transmitter_app/odometer/odometer_child.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/hive_service/jackpot_hive_service.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/hive_service/jackpot_hive_service_new.dart';
// import 'package:playtech_transmitter_app/service/config_custom.dart';
// import 'package:playtech_transmitter_app/screen/setting/setting_service.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc/video_bloc.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/main/jackpot_price_bloc.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/main/jackpot_state_state.dart';
// import 'package:logger/logger.dart';
// import 'package:playtech_transmitter_app/service/widget/circlar_progress.dart';

// class JackpotDisplayScreen extends StatefulWidget {
//   const JackpotDisplayScreen({super.key});

//   @override
//   State<JackpotDisplayScreen> createState() => _JackpotDisplayScreenState();
// }

// class _JackpotDisplayScreenState extends State<JackpotDisplayScreen> {
//   final SettingsService settingsService = SettingsService();
//   final Logger _logger = Logger();
//   late Future<Map<String, double>> _hiveValuesFuture;

//   @override
//   void initState() {
//     super.initState();
//     // Fetch Hive data once on initialization
//     _hiveValuesFuture = JackpotHiveService().getJackpotHistory().then((state) => state.first);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, double>>(
//       future: _hiveValuesFuture,
//       builder: (context, snapshot) {
//         Map<String, double> hiveValues = {};
//         if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//           hiveValues = snapshot.data!;
//         } else if (snapshot.hasError) {
//           _logger.e('Error loading Hive data: ${snapshot.error}');
//         }

//         return BlocBuilder<VideoBloc, ViddeoState>(
//           buildWhen: (previous, current) => previous.id != current.id,
//           builder: (context, state) {
//             return BlocBuilder<JackpotPriceBloc, JackpotPriceState>(
//               buildWhen: (previous, current) =>
//                   previous.isConnected != current.isConnected ||
//                   previous.error != current.error ||
//                   previous.jackpotValues != current.jackpotValues ||
//                   previous.previousJackpotValues != current.previousJackpotValues,
//               builder: (context, priceState) {
//                 debugPrint('Building JackpotDisplayScreen:${priceState.hasData}\n${priceState.jackpotValues}');
//                 return Center(
//                   child: priceState.isConnected
//                       ? Tooltip(
//                         message: '${priceState.hasData}',
//                         child: SizedBox(
//                             width: ConfigCustom.fixWidth,
//                             height: ConfigCustom.fixHeight,
//                             child: screen1(context, hiveValues),
//                           ),
//                       )
//                       :
//                       priceState.error != null ? Container() : circularProgessCustom()

//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//    Widget screen1(BuildContext context, Map<String, double> hiveValues) {
//     return Stack(
//       children: [
//          Positioned(
//           top: ConfigCustom.jp_vegas_screen_dY,
//           left: ConfigCustom.jp_vegas_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagVegas,
//             valueKey: ConfigCustom.tagVegas,
//             hiveValue: hiveValues[ConfigCustom.tagVegas] ?? 0.0,
//             isSmall: false,
//           ),
//         ),
//         Positioned(
//           top: ConfigCustom.jp_monthly_screen_dY,
//           right: ConfigCustom.jp_monthly_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagMonthly,
//             valueKey: ConfigCustom.tagMonthly,
//             hiveValue: hiveValues[ConfigCustom.tagMonthly] ?? 0.0,
//             isSmall: false,
//           ),
//         ),
//          Positioned(
//           top: ConfigCustom.jp_weekly_screen_dY,
//           right: ConfigCustom.jp_weekly_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagWeekly,
//             valueKey: ConfigCustom.tagWeekly,
//             hiveValue: hiveValues[ConfigCustom.tagWeekly] ?? 0.0,
//             isSmall: false,
//           ),
//         ),

// //2
//         Positioned(
//           top: ConfigCustom.jp_tripple_screen_dY,
//           left: ConfigCustom.jp_tripple_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagTriple,
//             valueKey: ConfigCustom.tagTriple,
//             hiveValue: hiveValues[ConfigCustom.tagTriple] ?? 0.0,
//             isSmall: false,
//           ),
//         ),
//         Positioned(
//           top: ConfigCustom.jp_dozen_screen_dY,
//           right: ConfigCustom.jp_dozen_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagDozen,
//             valueKey: ConfigCustom.tagDozen,
//             hiveValue: hiveValues[ConfigCustom.tagDozen] ?? 0.0,
//             isSmall: false,
//           ),
//         ),
//         Positioned(
//           top: ConfigCustom.jp_highlimit_screen_dY,
//           right: ConfigCustom.jp_highlimit_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagHighLimit,
//             valueKey: ConfigCustom.tagHighLimit,
//             hiveValue: hiveValues[ConfigCustom.tagHighLimit] ?? 0.0,
//             isSmall: false,
//           ),
//         ),


// //1
//         Positioned(
//           top: ConfigCustom.jp_dailygolden_screen_dY,
//           left: ConfigCustom.jp_dailygolden_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagDailyGolden,
//             valueKey: ConfigCustom.tagDailyGolden,
//             hiveValue: hiveValues[ConfigCustom.tagDailyGolden] ?? 0.0,
//             isSmall: false,
//           ),
//         ),
//         Positioned(
//           top: ConfigCustom.jp_daily_screen_dY,
//           right: ConfigCustom.jp_daily_screen_dX,
//           child: JackpotOdometer(
//             nameJP:ConfigCustom.tagDaily ,
//             valueKey: ConfigCustom.tagDaily,
//             hiveValue: hiveValues[ConfigCustom.tagDaily] ?? 0.0,
//             isSmall: false,
//           ),
//         ),
//         Positioned(
//           top: ConfigCustom.jp_frequent_screen_dY,
//           right: ConfigCustom.jp_frequent_screen_dX,
//           child:
//            JackpotOdometer(
//             nameJP: ConfigCustom.tagFrequent,
//             valueKey: ConfigCustom.tagFrequent,
//             hiveValue: hiveValues[ConfigCustom.tagFrequent] ?? 0.0,
//             isSmall: false,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class JackpotOdometer extends StatelessWidget {
//   final String nameJP;
//   final String valueKey;
//   final double hiveValue;
//   final bool isSmall;

//   const JackpotOdometer({
//     super.key,
//     required this.nameJP,
//     required this.valueKey,
//     required this.hiveValue,
//     required this.isSmall,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocSelector<JackpotPriceBloc, JackpotPriceState, ({double startValue, double endValue})>(
//       selector: (state) {
//         final blocStartValue = state.previousJackpotValues[valueKey] ?? 0.0;
//         final endValue = state.jackpotValues[valueKey] ?? 0.0;
//         return (startValue: blocStartValue, endValue: endValue);
//       },
//       builder: (context, values) {
//         return GameOdometerChildStyleOptimized(
//           startValue: values.startValue,
//           endValue: values.endValue,
//           nameJP: nameJP,
//           hiveValue: hiveValue,
//           isSmall: isSmall,

//         );
//       },
//     );
//   }
// }







