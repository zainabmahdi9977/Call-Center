// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:invo_5_widget/invo_5_widget.dart';
import 'package:invo_models/models/Employee.dart';

import 'package:newcall_center/blocs/main.bloc.dart';
import 'package:newcall_center/pages/HomePage/home.page.dart';
import 'package:newcall_center/services/reposiory.services.dart';
import 'package:newcall_center/utils/dialog.service.dart';
import 'package:newcall_center/utils/naviagtion.service.dart';
import 'package:resize/resize.dart';
import 'package:newcall_center/services/login.services.dart';
import 'package:newcall_center/translations/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newcall_center/services/connection.services.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;
  final ConnectivityService connectivityService = ConnectivityService();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    connectivityService.connectionStatus.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
      if (!_isConnected) {
        GetIt.instance.get<DialogService>().alertDialog("Connection failure".tr(), "No Internet Connection".tr());
      }
    });

    bloc = MainBloc();
    loading();
  }

  @override
  dispose() {
    connectivityService.dispose();
    super.dispose();
  }

  bool loadingComplete = false;
  loading() async {
    await bloc.loadData();
    setState(() {
      loadingComplete = true;
    });
  }

  double headerHeight = 70.h;

  Key navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (!GetIt.instance.isRegistered<NavigationService>()) {
      GetIt.instance.registerSingleton<NavigationService>(NavigationService(context));
    } else {
      GetIt.instance.get<NavigationService>().context = context;
    }

    DialogService.mainContext = context;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: !loadingComplete
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  key: GlobalKey(),
                  decoration: BoxDecoration(
                    gradient: WidgetUtilts.currentSkin.bgGradient,
                    // image: DecorationImage(
                    //     alignment: Alignment.topLeft,
                    //     // image: Svg("assets/images/dot.svg",
                    //     //     color: WidgetUtilts.currentSkin.skinPattern,
                    //     //     size: Size(15.w, 15.w),
                    //     //     scale: 1),
                    //     fit: BoxFit.none,
                    //     opacity: 0.03,
                    //     repeat: ImageRepeat.repeat),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: headerHeight,
                        color: Colors.blue[1200],
                        child: const TopBar(),
                      ),
                      // SingleChildScrollView(
                      //     physics: const NeverScrollableScrollPhysics(),
                      //     child: SizedBox(
                      //         width: 150.w,
                      //         height: MediaQuery.of(context).size.height,
                      //         child: SideMenu())),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            height: MediaQuery.of(context).size.height - headerHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadiusDirectional.only(
                                topStart: Radius.circular(40.r),
                                topEnd: Radius.circular(40.r),
                              ),
                            ),
                            child: Navigator(
                              key: navigatorKey,
                              initialRoute: "/",
                              onGenerateRoute: (RouteSettings settings) {
                                Widget page;
                                String pageName = settings.name.toString();
                                switch (pageName) {
                                  case "Home":
                                    page = const HomePage();
                                    break;
                                  default:
                                    pageName = "";
                                    page = const HomePage();
                                }

                                if (settings.name == "/") {
                                  return PageRouteBuilder(pageBuilder: (ctx, animation, secAndimation) => page);
                                }

                                return PageRouteBuilder(
                                  pageBuilder: (ctx, animation, secAndimation) => page,
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(1, 0);
                                    const end = Offset.zero;
                                    const curve = Curves.ease;

                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 400),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return FutureBuilder<Employee?>(
      future: LoginServices().getEmployee(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator while data is being fetched
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          // If data is available, display the user's name
          final employee = snapshot.data!;
          return Row(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(5)), border: Border.all(color: Colors.white), color: Colors.transparent),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      // Display the user's name dynamically here
                      child: Text(
                        employee.name, // Assuming 'name' is the attribute containing the user's name
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  onTap: () {
                    openDialog(context, isArabic);
                  },
                ),
              ),
            ],
          );
        } else {
          // If there's an error or no data available, display a default name or handle the error
          return const Text('User');
        }
      },
    );
  }
}

Future openDialog(context, isArabic) => showMenu(
      context: context,
      position: isArabic ? const RelativeRect.fromLTRB(10, 60, 280, 0) : const RelativeRect.fromLTRB(280, 60, 10, 0),
      items: [
        const PopupMenuItem(enabled: false, child: ShortCutPopup())
      ],
    );
List<String> ShortCut = [
  tr(LocaleKeys.ar_en),
  tr(LocaleKeys.LogOut),
  "PBX settings".tr(),
];
Color getTextColor(bool isHovered) {
  return isHovered ? Colors.white : Colors.black;
}

Color getContainerColor(bool isHovered) {
  return isHovered ? Colors.blue : Colors.black12;
}

class ShortCutPopup extends StatefulWidget {
  const ShortCutPopup({super.key});

  @override
  State<ShortCutPopup> createState() => _ShortCutPopupState();
}

class _ShortCutPopupState extends State<ShortCutPopup> {
  List<bool> isHovered = List.filled(ShortCut.length, false);
  void _updateColor(int index, bool hovered) {
    setState(() {
      isHovered[index] = hovered;
    });
  }

  Future<void> _handleAction(int index, BuildContext context) async {
    if (index == 0) {
      // Perform action for 'العربية' button
      if (context.locale.languageCode == 'ar') {
        await context.setLocale(const Locale('en'));
      } else {
        await context.setLocale(const Locale('ar'));
      }
    } else if (index == 1) {
      // Perform action for LocaleKeys.LogOut button
      logoutUser(context);
    } else if (index == 2) {
      // Perform action for LocaleKeys.LogOut button
      await DialogService().showSettingsDialog(context);
    }
  }

  void logoutUser(BuildContext context) async {
    try {
      // Clear the token from shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      GetIt.instance.unregister<NavigationService>();
      GetIt.instance.unregister<Repository>();

      // Navigate to the login page
      Navigator.pop(context);
      Navigator.of(context).popAndPushNamed("Login");
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      width: 142,
      child: Center(
        child: GridView.builder(
          itemCount: ShortCut.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 3.0),
          itemBuilder: (context, index) => MouseRegion(
            onHover: (event) => _updateColor(index, true),
            onExit: (event) => _updateColor(index, false),
            child: GestureDetector(
              onTap: () {
                _handleAction(index, context);
                if (index == 0) {
                  Navigator.popAndPushNamed(context, "Main");
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: getContainerColor(isHovered[index]),
                ),
                child: Center(
                  child: Text(
                    ShortCut[index].tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: getTextColor(isHovered[index]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
