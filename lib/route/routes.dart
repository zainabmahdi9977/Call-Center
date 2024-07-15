import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/HomePage/home.page.dart';
import '../pages/LoginPage/login.page.dart';

import '../route/route.constants.dart';

class AppRoutes {
  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        name: RouteConstants.loginRouteName,
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        name: RouteConstants.homeRouteName,
        path: '/HomePage',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),
      // GoRoute(
      // name: RouteConstants.orderRouteName,
      //   path: '/OrderPage',
      //   builder: (BuildContext context, GoRouterState state) {
      //     return  OrderPage(bloc: state.extra as Blocs,);
      //   },
      // ),
      // GoRoute(
      //  name: RouteConstants.customerRouteName,
      //   path: '/CustomerPage',
      //   builder: (BuildContext context, GoRouterState state) {
      //     return  CustomerPage(bloc: null,);
      //   },
      // ),
      // GoRoute(
      //   name: RouteConstants.mainRouteName,
      //   path: '/MainPage',
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const MainPage(
      //       page: HomePage(),
      //     );
      //   },
      // ),
      // GoRoute(
      //   name: RouteConstants.mainRouteName,
      //   path: '/MainPage/Customer',
      //   builder: (BuildContext context, GoRouterState state) {
      //     return MainPage(
      //       page: CustomerPage(
      //         bloc: CustomerPageBloc.fromPhoneAsync("33774772"),
      //       ),
      //     );
      //   },
      // ),
    ],
    // errorPageBuilder: (context, state) {
    //   return MaterialPage(child: ErrorPage());
    // },
  );
}
