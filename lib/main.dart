import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'package:newcall_center/pages/LoginPage/login.page.dart';
import 'package:newcall_center/pages/MainPage/main.page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:newcall_center/pages/login_provider.dart';

import 'package:newcall_center/utils/dialog.service.dart';
import 'package:provider/provider.dart';
// import 'package:invo/helpers/skins.dart';
// import 'package:invo/helpers/utlits.dart';
// import 'package:window_manager/window_manager.dart';
import 'package:resize/resize.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:windows_single_instance/windows_single_instance.dart';

// import 'view/Pages/Main/MainPage.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

String getType() {
  String type = "web";
  if (Platform.isAndroid) {
    type = "Android";
  } else if (Platform.isIOS) {
    type = "IOS";
  } else if (Platform.isLinux) {
    type = "Linux";
  } else if (Platform.isMacOS) {
    type = "MacOS";
  } else if (Platform.isWindows) {
    type = "Windows";
  }
  return type;
}

Future<void> main(List<String> args) async {
  HttpOverrides.global = MyHttpOverrides();
  GetIt.instance.registerLazySingleton<DialogService>(() => DialogService());

  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar')
      ],
      path: 'assets/i18n', // <-- change the path of the translation files
      startLocale: const Locale('en'),
      fallbackLocale: const Locale('en'),

      child: ChangeNotifierProvider(
        create: (_) => LoginProvider(),
        child: const App(),
      ),
    ),
  );

  // EasyLocalization(
  //     supportedLocales: const [Locale('en', ''), Locale('ar', '')],
  //     path: 'assets/i18n', // <-- change the path of the translation files
  //     startLocale: const Locale('en', ''),
  //     fallbackLocale: const Locale('en', ''),
  //     child: App(),
  //   ),
}

class App extends StatefulWidget {
  // final StreamController<Skin> themeController = StreamController<Skin>();

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }

  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //final localizationContext = context;
    return Resize(
        size: const Size(1920, 1080),
        builder: () {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // routeInformationParser: AppRoutes().router.routeInformationParser,
            // routerDelegate: AppRoutes().router.routerDelegate,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: 'Invo App',
            // builder: (context, child) {
            //   return const LoginPage();
            //   //  return AppRoutes().router.builder(context, child);
            // },
            initialRoute: "Login",
            routes: {
              'Login': (context) {
                return const LoginPage();
              },
              'Main': (context) {
                return const MainPage();
              }
            },
            theme: ThemeData(
              fontFamily: 'Cairo',
            ),
          );
        });
  }
}
