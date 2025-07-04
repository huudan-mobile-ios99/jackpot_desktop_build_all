class ConfigCustom {

  static const String endpointSocketMain = 'ws://192.168.101.58:8103';
  // static const String endpointSocketMain = 'ws://localhost:8090';
  // static const String endpoint_web_socket_Main = 'ws://localhost:8090';
  // static const String endpoint_web_socket_Sub1 = 'ws://localhost:8081';
  // static const String endpoint_web_socket_Sub2 = 'ws://localhost:8082';
  // static const String endpoint_web_socket_Sign4U = 'ws://localhost:8083';
  // static const String endpoint_web_socket_Main = 'ws://192.168.101.58:8071';
  // static const String endpoint_web_socket_Sub1 = 'ws://192.168.101.58:8074';
  // static const String endpoint_web_socket_Sub2 = 'ws://192.168.101.58:8081';
  // static const String endpoint_web_socket_Sign4U = 'ws://192.168.100.165:8080';
  // static const List<String> webSocketEndpoints = [
  //     endpoint_web_socket_Main,
  //     // endpoint_web_socket_Sub1,
  //     // endpoint_web_socket_Sub2,
  //     // endpoint_web_socket_Sign4U
  // ];
  // static const String endpoint_jphit_main = 'http://localhost:8000'; //endpointWebSocket= "ws://localhost:8080"
  // static const String endpoint_jphit_main = 'http://192.168.101.58:8097'; //endpointWebSocket= "ws://localhost:8080"
  // static const String endpoint_jphit_sub1 = 'http://192.168.101.58:8070'; //endpointWebSocket= "ws://localhost:8080"
  // static const String endpoint_jphit_sub2 = 'http://192.168.101.58:8073'; //endpointWebSocket= "ws://localhost:8080"


  static const double fixWidth= 800;
  static const double fixHeight= 800;

  static const int durationSwitchVideoSecond = 30; //swich video 1 and video background 2 after every 2min
  // static const int durationFinishCircleSpinNumber = 30; //swich video 1 and video background 2 after every 2min
  static const  double durationFinishCircleSpinNumberDouble = 30.0; // 29.5 seconds
  // static const int durationToGetDataFromWebSocketPerTime = 30; //swich video 1 and video background 2 after every 2min
  static const int dataFreshnessInterval = 30; //to check hasData or noData after 30s
  static const int durationGetDataToBloc = 1;
  static const int durationGetDataToBlocFirstMS = 100;
  static const int switchBetweeScreenDuration = 0;
  static const int switchBetweeScreenDurationForHitScreen = 0;
  static const int durationTimerVideoHitShow_Jackpot = 30; //show video hit for 30
  static const int durationTimerVideoHitShow_Hotseat = 20; //show video hit for 30
  static const int secondToReConnect = 30;


  static const int totalCountToRestart = 25; //1 count will be 30s | 240s will be 2h
  static const int additionSeconds = 0 ; //1 count will be 30s | 240s will be 2h
  static const int maxTimeToStartAnDecimalAnimationMs = 5000;




  // Reset values
  static const double resetFrequentJP = 300.0;
  static const double resetDailyJP = 5000.0;
  static const double resetDailyGoldenJP = 10000.0;
  static const double resetDozenJP = 20000.0;
  static const double resetWeeklyJP = 50000.0;
  static const double resetHighLimitJP = 10000.0;
  static const double resetTripleJP = 30000.0;
  static const double resetMonthlyJP = 105000.0;
  static const double resetVegasJP = 100000.0;
  // Levels
  static const int levelFrequent = 0;
  static const int levelDaily = 1;
  static const int levelDailyGolden = 34;
  static const int levelDozen = 2;
  static const int levelWeekly = 3;
  static const int levelHighLimit = 45;
  static const int levelTriple = 35;
  static const int levelMonthly = 46;
  static const int levelVegas = 4;
  static const int level7771st = 80;
  static const int level7771stAlt = 81;
  static const int level10001st = 88;
  static const int level10001stAlt = 89;
  static const int levelPpochiMonFri = 97;
  static const int levelPpochiMonFriAlt = 98;
  static const int levelRlPpochi = 109;
  static const int levelNew20Ppochi = 119;
  // Jackpot names
  static const String tagFrequent = 'Frequent';
  static const String tagDaily = 'Daily';
  static const String tagDailyGolden = 'DailyGolden';
  static const String tagDozen = 'Dozen';
  static const String tagWeekly = 'Weekly';
  static const String tagHighLimit = 'HighLimit';
  static const String tagTriple = 'Triple';
  static const String tagMonthly = 'Monthly';
  static const String tagVegas = 'Vegas';
  static const String tag7771st = '7771st';
  static const String tag10001st = '10001st';
  static const String tagPpochiMonFri = 'PpochiMonFri';
  static const String tagRlPpochi = 'RlPpochi';
  static const String tagNew20Ppochi = 'New20Ppochi';



  static const  String  videoBackgroundScreen1 = 'asset/video/video_background.mp4';
  static const  String  videoBackgroundScreen2 = 'asset/video/video_background2.mp4';
  static const  String  videoBackgroundScreenAll = 'asset/video/background/background.mp4';


  static const int duration_fade_animate_screen_switch_ms = 250;
  static const int duration_fade_animate_hit_jp_ms = 250;
  static const int duration_show_video_background_second = 30;
  static const int duration_show_video_background_jackpot_second = 30;
  static const int duration_show_video_background_hotseat_second = 30;

  static const String font_family = 'sf-pro-display';
  static const double text_hit_price_offset_dx = 0.0;
  static const double text_hit_price_offset_dy = 3.0;
  static const double text_hit_price_blur_radius = 4.0;

  static const double text_hit_price_size = 125.0;
  static const double text_hit_price_dX = 100.0;
  static const double text_hit_price_dY = 100.0;
  static const double text_hit_number_offset_dx = 0.0;
  static const double text_hit_number_offset_dy = 2.0;
  static const double text_hit_number_blur_radius = 4.0;
  static const double text_hit_number_size = 55.0;
  static const double text_hit_number_dX = 68.0;
  static const double text_hit_number_dY = 30.0;
  static const double text_odo_size = 65.5;
  static const double text_odo_size_small = 105.5;
  static const double text_odo_offset_dx = 0.0;
  static const double text_odo_blur_radius = 3.5;
  static const double text_odo_letter_width = 34.5;
  static const double text_odo_letter_width_small = 34.5;
  static const double text_odo_letter_vertical_offset = 60.0;
  static const double text_odo_letter_vertical_offset_small = 34.0;
  static const double odo_width = 768.0;
  static const double odo_height = 75.5;
  static const double odo_height_small = 75.5;
  static const double odo_position_top = 7.5;

  static const double jp_frequent_screen_dX = 0;
  static const double jp_frequent_screen_dY = 500;
  static const double jp_daily_screen_dX = 0;
  static const double jp_daily_screen_dY = 400;
  static const double jp_dailygolden_screen_dX = 0;
  static const double jp_dailygolden_screen_dY = 200;
  static const double jp_dozen_screen_dX = 0;
  static const double jp_dozen_screen_dY = 300;
  static const double jp_highlimit_screen_dX = 0;
  static const double jp_highlimit_screen_dY = 200;
  static const double jp_tripple_screen_dX = 0;
  static const double jp_tripple_screen_dY = 100;
  static const double jp_weekly_screen_dX = 0;
  static const double jp_weekly_screen_dY = 100;
  static const double jp_monthly_screen_dX = 0;
  static const double jp_monthly_screen_dY = 0;
  static const double jp_vegas_screen_dX = 0;
  static const double jp_vegas_screen_dY = 0;

  //JACKPOT PATH
  static const int jp_id_frequent = 0;
  static const int jp_id_daily = 1;
  static const int jp_id_dailygolden = 34;
  static const int jp_id_dozen = 2;
  static const int jp_id_highlimit = 45;
  static const int jp_id_weekly = 3;
  static const int jp_id_monthly = 46;
  static const int jp_id_vegas = 4;
  static const int jp_id_tripple = 35;
  static const int hotseat_id_777_1st = 80;
  static const int hotseat_id_777_2nd = 81;
  static const int hotseat_id_1000_1st = 88;
  static const int hotseat_id_1000_2nd = 89;
  static const int hotseat_id_ppochi_Mon_Fri = 97;
  static const int hotseat_id_ppochi_Sat_Sun = 98;
  static const int hotseat_id_RL_ppochi = 109;
  static const int hotseat_id_New_20_ppochi = 119;


  static const String jp_id_hit_all = 'asset/video/hit/hit.mp4';
  static const String jp_id_frequent_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_daily_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_dailygolden_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_dozen_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_weekly_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_highlimit_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_monthly_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_vegas_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_tripple_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_777_1st_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_777_2nd_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_1000_1st_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_1000_2nd_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_ppochi_Mon_Fri_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_ppochi_Sat_Sun_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_RL_ppochi_video_path = 'asset/video/hit/hit.mp4';
  static const String jp_id_New_20_ppochi_video_path = 'asset/video/hit/hit.mp4';


  // Helper methods
  static String? getJackpotNameByLevel(String level) {
    switch (level) {
      case '$levelFrequent': return tagFrequent;
      case '$levelDaily':  return tagDaily;
      case '$levelDailyGolden': return tagDailyGolden;
      case '$levelDozen': return tagDozen;
      case '$levelWeekly':
        return tagWeekly;
      case '$levelHighLimit':
        return tagHighLimit;
      case '$levelTriple':
        return tagTriple;
      case '$levelMonthly':
        return tagMonthly;
      case '$levelVegas':
        return tagVegas;
      case '$level7771st':
      case '$level7771stAlt':
        return tag7771st;
      case '$level10001st':
      case '$level10001stAlt':
        return tag10001st;
      case '$levelPpochiMonFri':
      case '$levelPpochiMonFriAlt':
        return tagPpochiMonFri;
      case '$levelRlPpochi':
        return tagRlPpochi;
      case '$levelNew20Ppochi':
        return tagNew20Ppochi;
      default:
        return null;
    }
  }


static const List<String> selectedJackpotNames = [
    'Frequent',
    'Daily',
    'Dozen',
    'Weekly',
    'Vegas',
    'DailyGolden',
    'Triple',
    'HighLimit',
    'Monthly',
  ];




  static double? getResetValueByLevel(String level) {
    switch (level) {
      case '$levelFrequent':
        return resetFrequentJP;
      case '$levelDaily':
        return resetDailyJP;
      case '$levelDailyGolden':
        return resetDailyGoldenJP;
      case '$levelDozen':
        return resetDozenJP;
      case '$levelWeekly':
        return resetWeeklyJP;
      case '$levelHighLimit':
        return resetHighLimitJP;
      case '$levelTriple':
        return resetTripleJP;
      case '$levelMonthly':
        return resetMonthlyJP;
      case '$levelVegas':
        return resetVegasJP;
      case '$level7771st':
      default:
        return null;
    }
  }



  static List<String> get validJackpotNames => [
        tagFrequent,
        tagDaily,
        tagDailyGolden,
        tagDozen,
        tagWeekly,
        tagHighLimit,
        tagTriple,
        tagMonthly,
        tagVegas,
        tag7771st,
        tag10001st,
        tagPpochiMonFri,
        tagRlPpochi,
        tagNew20Ppochi,
  ];

  static const List<int> excludedJackpotIds = [
    80,  // hotseat_id_777_1st
    81,  // hotseat_id_777_2nd
    88,  // hotseat_id_1000_1st
    89,  // hotseat_id_1000_2nd
    97,  // hotseat_id_ppochi_Mon_Fri
    98,  // hotseat_id_ppochi_Sat_Sun
    109, // hotseat_id_RL_ppochi
    119, // hotseat_id_New_20_ppochi
  ];

  static const Map<int, String> defaultJackpotValues = {
    80: '777',
    81: '777',
    88: '1000',
    89: '1000',
    97: '300',
    98: '300',
    109: '300',
    119: '500',
  };




}

