// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:playtech_transmitter_app/odometer/odometer_child.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/hive_service/jackpot_hive_service.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/sign4u/jackpot_price_bloc_sign4u.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/sign4u/jackpot_state_sign4u_state.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/sub1/jackpot_price_sub_bloc.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/sub1/jackpot_state_sub_state.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/sub2/jackpot_state_sub2_state.dart';
// import 'package:playtech_transmitter_app/service/config_custom.dart';
// import 'package:playtech_transmitter_app/screen/setting/setting_service.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc/video_bloc.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/main/jackpot_price_bloc.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/sub2/jackpot_price_sub2_bloc.dart';
// import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/main/jackpot_state_state.dart';
// import 'package:playtech_transmitter_app/service/widget/circlar_progress.dart';

// class JackpotDisplayScreen extends StatefulWidget {
//   const JackpotDisplayScreen({Key? key}) : super(key: key);

//   @override
//   State<JackpotDisplayScreen> createState() => _JackpotDisplayScreenState();
// }

// class _JackpotDisplayScreenState extends State<JackpotDisplayScreen> {
//   final SettingsService _settingsService = SettingsService();
//   late Future<Map<String, double>> _hiveValuesFuture;
//   Map<String, double> _selectedValues = {
//     for (var name in ConfigCustom.validJackpotNames) name: 0.0,
//   };
//   Map<String, double> _selectedPreviousValues = {
//     for (var name in ConfigCustom.validJackpotNames) name: 0.0,
//   };
//   bool _isAnyConnected = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     // Fetch Hive data once on initialization
//     _hiveValuesFuture = JackpotHiveService().getJackpotHistory().then((state) => state.first);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (_) => JackpotPriceBloc()),
//         BlocProvider(create: (_) => JackpotPriceBlocSign4U()),
//         BlocProvider(create: (_) => JackpotPriceBlocSub()),
//         BlocProvider(create: (_) => JackpotPriceBlocSub2()),
//       ],
//       child: FutureBuilder<Map<String, double>>(
//         future: _hiveValuesFuture,
//         builder: (context, snapshot) {
//           Map<String, double> hiveValues = {};
//           if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//             hiveValues = snapshot.data!;
//             // debugPrint('Loaded Hive data: $hiveValues');
//           } else if (snapshot.hasError) {
//             debugPrint('Error loading Hive data: ${snapshot.error}');
//           }

//           return MultiBlocListener(
//             listeners: [
//               BlocListener<JackpotPriceBloc, JackpotPriceState>(
//                 listener: (context, state) {
//                   if (state.hasData) {
//                     setState(() {
//                       _selectedValues = Map.from(state.jackpotValues);
//                       _selectedPreviousValues = Map.from(state.previousJackpotValues);
//                       _isAnyConnected = state.isConnected;
//                       _error = state.error;
//                     });
//                     debugPrint('Using data from Main endpoint: ${_selectedValues}');
//                   }
//                   _updateConnectionStatus(context);
//                 },
//               ),
//               BlocListener<JackpotPriceBlocSub, JackpotPriceSubState>(
//                 listener: (context, state) {
//                   if (state.hasData && !context.read<JackpotPriceSubState>().state.hasData) {
//                     setState(() {
//                       _selectedValues = Map.from(state.jackpotValues);
//                       _selectedPreviousValues = Map.from(state.previousJackpotValues);
//                       _isAnyConnected = state.isConnected;
//                       _error = state.error;
//                     });
//                     debugPrint('Using data from Sub1 endpoint: ${_selectedValues}');
//                   }
//                   _updateConnectionStatus(context);
//                 },
//               ),
//               BlocListener<JackpotPriceBlocSub2, JackpotPriceSub2State>(
//                 listener: (context, state) {
//                   if (state.hasData &&
//                       !context.read<JackpotPriceBloc>().state.hasData &&
//                       !context.read<JackpotPriceBlocSub>().state.hasData) {
//                     setState(() {
//                       _selectedValues = Map.from(state.jackpotValues);
//                       _selectedPreviousValues = Map.from(state.previousJackpotValues);
//                       _isAnyConnected = state.isConnected;
//                       _error = state.error;
//                     });
//                     debugPrint('Using data from Sub2 endpoint: ${_selectedValues}');
//                   }
//                   _updateConnectionStatus(context);
//                 },
//               ),
//               BlocListener<JackpotPriceBlocSign4U, JackpotPriceSign4UState>(
//                 listener: (context, state) {
//                   if (state.hasData &&
//                       !context.read<JackpotPriceBloc>().state.hasData &&
//                       !context.read<JackpotPriceBlocSub>().state.hasData &&
//                       !context.read<JackpotPriceBlocSub2>().state.hasData) {
//                     setState(() {
//                       _selectedValues = Map.from(state.jackpotValues);
//                       _selectedPreviousValues = Map.from(state.previousJackpotValues);
//                       _isAnyConnected = state.isConnected;
//                       _error = state.error;
//                     });
//                     debugPrint('Using data from Sign4U endpoint: ${_selectedValues}');
//                   }
//                   _updateConnectionStatus(context);
//                 },
//               ),
//             ],
//             child: BlocBuilder<VideoBloc, ViddeoState>(
//               buildWhen: (previous, current) => previous.id != current.id,
//               builder: (context, videoState) {
//                 return Center(
//                   child: _isAnyConnected
//                       ? Tooltip(
//                           message: 'Data source: ${_getDataSource(context)}',
//                           child: SizedBox(
//                             width: ConfigCustom.fixWidth,
//                             height: ConfigCustom.fixHeight,
//                             child: screen1(context, hiveValues),
//                           ),
//                         )
//                       : _error != null
//                           ? Container()
//                           : circularProgessCustom(),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _updateConnectionStatus(BuildContext context) {
//     final isConnected = context.read<JackpotPriceBloc>().state.isConnected ||
//         context.read<JackpotPriceBlocSub>().state.isConnected ||
//         context.read<JackpotPriceBlocSub2>().state.isConnected ||
//         context.read<JackpotPriceBlocSign4U>().state.isConnected;
//     final error = context.read<JackpotPriceBloc>().state.error ??
//         context.read<JackpotPriceBlocSub>().state.error ??
//         context.read<JackpotPriceBlocSub2>().state.error ??
//         context.read<JackpotPriceBlocSign4U>().state.error;
//     setState(() {
//       _isAnyConnected = isConnected;
//       _error = error;
//     });
//   }

//   String _getDataSource(BuildContext context) {
//     if (context.read<JackpotPriceBloc>().state.hasData) return 'Main';
//     if (context.read<JackpotPriceBlocSub>().state.hasData) return 'Sub1';
//     if (context.read<JackpotPriceBlocSub2>().state.hasData) return 'Sub2';
//     if (context.read<JackpotPriceBlocSign4U>().state.hasData) return 'Sign4U';
//     return 'None';
//   }

//   Widget screen1(BuildContext context, Map<String, double> hiveValues) {
//     return Stack(
//       children: [
//         Positioned(
//           top: ConfigCustom.jp_vegas_screen_dY,
//           left: ConfigCustom.jp_vegas_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagVegas,
//             valueKey: ConfigCustom.tagVegas,
//             hiveValue: hiveValues[ConfigCustom.tagVegas] ?? 0.0,
//             isSmall: false,
//             selectedValues: _selectedValues,
//             selectedPreviousValues: _selectedPreviousValues,
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
//             selectedValues: _selectedValues,
//             selectedPreviousValues: _selectedPreviousValues,
//           ),
//         ),
//         Positioned(
//           top: ConfigCustom.jp_weekly_screen_dY,
//           right: ConfigCustom.jp_weekly_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagWeekly,
//             valueKey: ConfigCustom.tagWeekly,
//             hiveValue: hiveValues[ConfigCustom.tagWeekly] ?? 0.0,
//             isSmall: false,
//             selectedValues: _selectedValues,
//             selectedPreviousValues: _selectedPreviousValues,
//           ),
//         ),
//         Positioned(
//           top: ConfigCustom.jp_tripple_screen_dY,
//           left: ConfigCustom.jp_tripple_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagTriple,
//             valueKey: ConfigCustom.tagTriple,
//             hiveValue: hiveValues[ConfigCustom.tagTriple] ?? 0.0,
//             isSmall: false,
//             selectedValues: _selectedValues,
//             selectedPreviousValues: _selectedPreviousValues,
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
//             selectedValues: _selectedValues,
//             selectedPreviousValues: _selectedPreviousValues,
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
//             selectedValues: _selectedValues,
//             selectedPreviousValues: _selectedPreviousValues,
//           ),
//         ),
//         Positioned(
//           top: ConfigCustom.jp_dailygolden_screen_dY,
//           left: ConfigCustom.jp_dailygolden_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagDailyGolden,
//             valueKey: ConfigCustom.tagDailyGolden,
//             hiveValue: hiveValues[ConfigCustom.tagDailyGolden] ?? 0.0,
//             isSmall: false,
//             selectedValues: _selectedValues,
//             selectedPreviousValues: _selectedPreviousValues,
//           ),
//         ),
//         Positioned(
//           top: ConfigCustom.jp_daily_screen_dY,
//           right: ConfigCustom.jp_daily_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagDaily,
//             valueKey: ConfigCustom.tagDaily,
//             hiveValue: hiveValues[ConfigCustom.tagDaily] ?? 0.0,
//             isSmall: false,
//             selectedValues: _selectedValues,
//             selectedPreviousValues: _selectedPreviousValues,
//           ),
//         ),
//         Positioned(
//           top: ConfigCustom.jp_frequent_screen_dY,
//           right: ConfigCustom.jp_frequent_screen_dX,
//           child: JackpotOdometer(
//             nameJP: ConfigCustom.tagFrequent,
//             valueKey: ConfigCustom.tagFrequent,
//             hiveValue: hiveValues[ConfigCustom.tagFrequent] ?? 0.0,
//             isSmall: false,
//             selectedValues: _selectedValues,
//             selectedPreviousValues: _selectedPreviousValues,
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
//   final Map<String, double> selectedValues;
//   final Map<String, double> selectedPreviousValues;

//   const JackpotOdometer({
//     Key? key,
//     required this.nameJP,
//     required this.valueKey,
//     required this.hiveValue,
//     required this.isSmall,
//     required this.selectedValues,
//     required this.selectedPreviousValues,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final startValue = selectedPreviousValues[valueKey] ?? 0.0;
//     final endValue = selectedValues[valueKey] ?? 0.0;
//     return GameOdometerChildStyleOptimized(
//       startValue: startValue,
//       endValue: endValue,
//       nameJP: nameJP,
//       hiveValue: hiveValue,
//       isSmall: isSmall,
//     );
//   }
// }
