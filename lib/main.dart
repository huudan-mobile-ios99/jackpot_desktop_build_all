import 'dart:async';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:playtech_transmitter_app/service/hive_service/jackpot_hive_service.dart';
import 'package:playtech_transmitter_app/screen/background_screen/bloc_jp_price/main/jackpot_price_bloc.dart';

import 'package:playtech_transmitter_app/screen/background_screen/bloc_socket_time/jackpot_bloc_socket.dart';
import 'package:playtech_transmitter_app/screen/background_screen/jackpot_hit_page.dart';
import 'package:window_manager/window_manager.dart';
import 'package:playtech_transmitter_app/screen/background_screen/jackpot_video_bg_page.dart';
import 'package:playtech_transmitter_app/service/config_custom.dart';
import 'package:playtech_transmitter_app/screen/background_screen/bloc/video_bloc.dart';
import 'package:media_kit/media_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final hiveService = JackpotHiveService();
  await Hive.initFlutter();
  await hiveService.initHive();
  await windowManager.ensureInitialized();
  await windowManager.setFullScreen(false);

  await Window.initialize();
  await Window.setWindowBackgroundColorToClear();

  runApp(Phoenix(child: const MyApp()));

  doWhenWindowReady(() {
    appWindow
      ..size = const Size(ConfigCustom.fixWidth, ConfigCustom.fixHeight)
      ..alignment = Alignment.center
      ..startDragging()
      ..title = 'App Build All Version'
      ..show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.transparent),
      home: const MyAppBody(),
    );
  }
}

class MyAppBody extends StatefulWidget {
  const MyAppBody({super.key});
  @override
  MyAppBodyState createState() => MyAppBodyState();
}

class MyAppBodyState extends State<MyAppBody> with WindowListener {
  Timer? _restartTimer;
  // WindowEffect effect = WindowEffect.transparent;
  WindowEffect effect = WindowEffect.aero;


  @override
  void initState() {
    super.initState();
    Window.setEffect(
      effect: WindowEffect.selection,
      // effect: WindowEffect.transparent,
      color: Colors.transparent,
      dark: false,
    );
    _initWindowManager();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _restartTimer?.cancel();
    super.dispose();
  }

  Future<void> _initWindowManager() async {
    await windowManager.setPreventClose(true);
    await windowManager.setBackgroundColor(Colors.transparent);
    setState(() {});
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {

    }
  }

  void _restartApp() {
    final start = DateTime.now();
    Phoenix.rebirth(context);
    final end = DateTime.now();
    debugPrint('RESTART ACTION TAKE: ${end.difference(start).inMilliseconds}ms');
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => JackpotBloc2(), lazy: false),
        BlocProvider(create: (context) => JackpotPriceBloc(), lazy: false),
        BlocProvider(
          create: (context) => VideoBloc(
            videoBg: ConfigCustom.videoBackgroundScreenAll,
            context: context,
          ),
          lazy: false,
        ),
      ],
      child: BlocListener<VideoBloc, ViddeoState>(
        listener: (context, state) {
          // Cancel any pending timers or futures if applicable
          if (state.isRestart) {
                debugPrint( 'MyAppBody: Triggering app restart via BlocListener');
                context.read<JackpotPriceBloc>().close();
                _restartApp();
          }
        },
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          // backgroundColor: Colors.black,
          body: Stack(
            alignment: Alignment.center,
            children: [
              RepaintBoundary(child: JackpotBackgroundShowWindowFadeAnimateP()),
              RepaintBoundary(child: JackpotHitShowScreen()),
            ],
          ),
        ),
      ),
    );
  }
}
