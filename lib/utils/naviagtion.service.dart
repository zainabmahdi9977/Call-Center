import 'package:flutter/material.dart';
import 'package:invo_models/invo_models.dart';
import 'package:newcall_center/blocs/customer.page.bloc.dart';
import 'package:newcall_center/pages/CustomerPage/customer.page.dart';
import 'package:newcall_center/pages/MainPage/main.page.dart';

import '../blocs/orderPage/order.page.bloc.dart';
import '../pages/OrderPage/order.page.dart';

class NavigationService {
  BuildContext context;
  NavigationService(this.context);
  Property<String> currentPage = Property("Home");
  List<String> pageStack = [
    "Home"
  ];
  _pushPage(dynamic page) async {
    return await Navigator.of(context).push(
      PageRouteBuilder(
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
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Future<Customer?> goToCustomerPage(CustomerPageBloc bloc) async {
    currentPage.sink("CustomerPage");
    pageStack.add(currentPage.value);
    return await _pushPage(CustomerPage(bloc: bloc));
  }

  Future goToOrderPage(OrderPageBloc bloc) async {
    currentPage.sink("OrderPage");
    pageStack.add(currentPage.value);

    return await _pushPage(OrderPage(bloc: bloc));
  }

  Future<bool> goBackToHomePage() async {
    // Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainPage()), // Replace with your HomePage widget
      (route) => false,
    );
    currentPage.sink("HomePage");
    pageStack = [
      "HomePage"
    ];
    return true;
  }

  void goBack(dynamic resault) {
    if (Navigator.of(context).canPop()) {
      pageStack.removeLast();
      if (pageStack.isEmpty) {
        currentPage.sink("HomePage");
        pageStack = [
          "HomePage"
        ];
      } else {
        currentPage.sink(pageStack.last);
      }
      Navigator.of(context).pop(resault);
    }
  }
}
