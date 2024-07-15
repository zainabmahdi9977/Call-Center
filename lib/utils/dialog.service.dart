import 'dart:async';
import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:invo_5_widget/invo_5_widget.dart';
import 'package:invo_models/invo_models.dart';

import 'package:newcall_center/models/branch.models.dart';

import 'package:newcall_center/services/reposiory.services.dart';
import 'package:newcall_center/utils/naviagtion.service.dart';
import 'package:resize/resize.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DialogService {
  final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _settingsFormKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 60.h * 10);
  GlobalKey<FormState> get settingsFormKey => _settingsFormKey;
  late ValueNotifier<String> searchword;
  GlobalKey<FormState> get addressFormKey => _addressFormKey;
  static BuildContext? mainContext;

  DialogService() {
    searchword = ValueNotifier<String>("");
  }

  bool isWindowsPlatform() {
    if (kIsWeb) {
      return false;
    } else {
      if (Platform.isWindows) {
        return true;
      }
    }
    return false;
  }

  void dispose() {
    _scrollController.dispose();
    searchword.dispose();
  }

  Future<bool> confirmationDialog2(String title, String msg) async {
    if (mainContext == null) return false;
    bool? x = await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 300.h,
                width: 350.w,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        msg,
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OptionButton(
                                  "No".tr(),
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  style: "danger",
                                  onTap: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                OptionButton(
                                  "Yes".tr(),
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  style: "primary",
                                  onTap: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });
    if (x == null) {
      return false;
    }
    return x;
  }

  Future<bool> confirmationDialog(String title, String msg) async {
    if (mainContext == null) return false;
    bool? x = await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 300.h,
                width: 350.w,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        msg,
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OptionButton(
                                  "Cancel".tr(),
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  style: "danger",
                                  onTap: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                OptionButton(
                                  "Yes".tr(),
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  style: "primary",
                                  onTap: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });
    if (x == null) {
      return false;
    }
    return x;
  }

  Future<bool?> alertDialog(String title, String msg) async {
    await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 300.h,
                width: 350.w,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        msg,
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            OptionButton(
                              "OK".tr(),
                              lineHeight: 1.2,
                              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                              fontSize: 20.sp,
                              style: "primary",
                              onTap: () async {
                                Navigator.of(context).pop(true);
                                final SharedPreferences prefs = await SharedPreferences.getInstance();
                                if (msg == 'Connection failure or server error'.tr() || title == "Connection failure".tr()) {
                                  await prefs.remove('token');
                                  GetIt.instance.unregister<NavigationService>();
                                  GetIt.instance.unregister<Repository>();

                                  // Navigate to the login page
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).popAndPushNamed("Login");
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });
    return true;
  }

  Future<Discount?> discountListDialog(String title, List<Discount> discounts) async {
    List<Widget> discountBtns = [];
    for (var element in discounts) {
      discountBtns.add(DiscountButton(
        element.name,
        percent: (element.percentage) ? "${element.amount}%" : element.amount.toCurrency(),
        fontSize: 25.sp,
        onTap: () {
          Navigator.of(mainContext!).pop(element);
        },
      ));
    }
    Discount? resault = await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 650.h,
                width: 800.w,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: GridView.count(
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          childAspectRatio: 350.w / 180.h,
                          children: [
                            ...discountBtns,
                            DiscountButton(
                              "Custom Discount".tr(),
                              singleText: true,
                              fontSize: 25.sp,
                              borderColor: WidgetUtilts.currentSkin.bgColor,
                              onTap: () async {
                                double? price = await priceDialog("Enter Discount Amount".tr());
                                if (price != null) {
                                  Navigator.of(mainContext!).pop(Discount(id: "", name: "", amount: price, percentage: false));
                                }
                              },
                            ),
                          ],
                        )),
                  ),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OptionButton(
                                  "Cancel".tr(),
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  style: "primary",
                                  onTap: () {
                                    Navigator.of(context).pop(null);
                                  },
                                ),
                              ],
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });

    return resault;
  }

  Future<Surcharge?> surchargeListDialog(List<Surcharge> surcharges) async {
    Surcharge? resault = await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 650.h,
                width: 800.w,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Surcharge".tr(),
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: GridView.builder(
                          itemCount: surcharges.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            crossAxisCount: 3,
                            childAspectRatio: 350.w / 180.h,
                          ),
                          itemBuilder: (ctx, index) {
                            return DiscountButton(
                              surcharges[index].name,
                              percent: (surcharges[index].percentage) ? "${surcharges[index].amount}%" : surcharges[index].amount.toCurrency(),
                              onTap: () {
                                Navigator.of(context).pop(surcharges[index]);
                              },
                              fontSize: 25.sp,
                            );
                          },
                          shrinkWrap: true,
                        )),
                  ),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OptionButton(
                                  "Cancel".tr(),
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  style: "primary",
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });
    return resault;
  }

  Future<List<ProductList>> showProductList1(List<ProductList> products, {bool multiSelection = false}) async {
    final StreamController<String> searchController = StreamController<String>.broadcast();

    String filterText = "";

    List<ProductList> filterdList = products.toList();
    List<DataRow> buildProductTable(List<ProductList> products) {
      List<DataRow> menulistTableRow = [];
      for (var i = 0; i < products.length; i++) {
        menulistTableRow.add(
          DataRow(
            selected: products[i].isSelected,
            onSelectChanged: (selected) {
              if (!multiSelection) {
                for (var element in products) {
                  element.isSelected = false;
                }
              }

              if (selected != null) {
                products[i].isSelected = selected;
              }
              searchController.add(filterText);
            },
            cells: <DataCell>[
              DataCell(Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    products[i].name.trim().toString(),
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 18.sp, color: Colors.black, height: 1),
                  ),
                  // Container(
                  //   padding: EdgeInsets.all(4.0),
                  //   margin: EdgeInsetsDirectional.only(start: 4.0),
                  //   decoration: BoxDecoration(
                  // color:WidgetUtilts.currentSkin.primaryColor,
                  // borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: Text(
                  // products[i].type.toString(),
                  // textAlign: TextAlign.center,
                  // style: TextStyle(fontSize: 12.sp, color: Colors.white, height: 1),
                  //   ),
                  // )
                ],
              )),
              DataCell(Text(
                products[i].available.toString(),
                style: TextStyle(fontSize: 18.sp, color: Colors.black),
              )),
              DataCell(Text(
                products[i].barcode.toString(),
                style: TextStyle(fontSize: 18.sp, color: Colors.black),
              )),
              DataCell(Row(
                children: [
                  Text(
                    products[i].price.toCurrency(),
                    style: TextStyle(fontSize: 18.sp, color: Colors.black),
                  )
                ],
              )),
              DataCell(Container(
                margin: const EdgeInsets.all(5),
                child: (products[i].available != "")
                    ? OptionButton(
                        "Check Availability".tr(),
                        onTap: () {},
                        lineHeight: 1.2,
                        fontSize: 15.sp,
                        style: "primary",
                      )
                    : const SizedBox(),
              )),
            ],
          ),
        );
      }
      return menulistTableRow;
    }

    List<DataRow> menulistTableRow = buildProductTable(filterdList);

    List<ProductList>? x = await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 847.h,
                width: 1064.w,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Product List".tr(),
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: CustomTextField(
                        hint: 'Search ...'.tr(),
                        focus: true,
                        callback: (value) {
                          filterText = value;
                          searchController.add(value);
                        }),
                  ),
                  Expanded(
                    child: StreamBuilder<String>(
                        stream: searchController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.data != null && snapshot.data != "") {
                            menulistTableRow = [];

                            filterdList = products
                                .where((element) =>
                                    (element.name.toLowerCase().contains(snapshot.data.toString().toLowerCase())) ||
                                    (element.barcode.toLowerCase().contains(snapshot.data.toString().toLowerCase())) ||
                                    // ignore: unrelated_type_equality_checks
                                    (element.price == num.tryParse(snapshot.data!)?.toDouble()))
                                .toList();
                            menulistTableRow = buildProductTable(filterdList);
                          } else {
                            menulistTableRow = buildProductTable(products);
                          }

                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            margin: EdgeInsets.symmetric(vertical: 20.h),
                            child: LayoutBuilder(builder: (context, constraints) {
                              double availableWidth = constraints.maxWidth - 49;
                              return DataTable2(
                                sortAscending: true,
                                showCheckboxColumn: false,
                                dataRowHeight: 60.h,
                                headingRowHeight: 40,
                                columnSpacing: 1,
                                columns: <DataColumn2>[
                                  DataColumn2(
                                    fixedWidth: availableWidth * 0.4,
                                    label: Text(
                                      "Product Name".tr(),
                                      style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                    ),
                                    onSort: (int columnIndex, bool ascending) {},
                                  ),
                                  DataColumn2(
                                    fixedWidth: availableWidth * 0.1,
                                    label: Text(
                                      "Available".tr(),
                                      style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                    ),
                                    onSort: (int columnIndex, bool ascending) {},
                                  ),
                                  DataColumn2(
                                    fixedWidth: availableWidth * 0.25,
                                    label: Text(
                                      "Barcode".tr(),
                                      style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                    ),
                                    onSort: (int columnIndex, bool ascending) {},
                                  ),
                                  DataColumn2(
                                    fixedWidth: availableWidth * 0.1,
                                    label: Text(
                                      "Price".tr(),
                                      style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                    ),
                                    onSort: (int columnIndex, bool ascending) {},
                                  ),
                                  DataColumn2(
                                    fixedWidth: availableWidth * 0.15,
                                    label: Text(
                                      "",
                                      style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                    ),
                                    onSort: (int columnIndex, bool ascending) {},
                                  ),
                                ],
                                rows: <DataRow>[
                                  ...menulistTableRow
                                ],
                              );
                            }),
                          );
                        }),
                  ),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OptionButton(
                                  "Cancel".tr(),
                                  onTap: () {
                                    List<ProductList> selected = [];
                                    Navigator.of(context).pop(selected);
                                  },
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  style: "primary".tr(),
                                ),
                                OptionButton(
                                  "Pick".tr(),
                                  onTap: () {
                                    List<ProductList> selected = products.where((f) => f.isSelected).toList();
                                    Navigator.of(context).pop(selected);
                                  },
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  style: "primary",
                                ),
                              ],
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });

    searchController.close();

    if (x == null) return [];
    return x;
  }

  Future<void> showCoveredAddresses(List<CoveredAddress> addresses, Property<List<Branch>> branches) async {
    await showGeneralDialog<void>(
      barrierColor: Colors.black.withOpacity(0.5),
      useRootNavigator: false,
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Dialog(
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            child: Container(
              height: 600.h,
              width: 850.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Text(
                      "Covered Addresses".tr(),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: LayoutBuilder(builder: (context, constraints) {
                        double availableWidth = constraints.maxWidth;
                        return Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: availableWidth * 0.25,
                                  child: Text(
                                    "Address".tr(),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      height: 3,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: availableWidth * 0.25,
                                  child: Text(
                                    "Min Order".tr(),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      height: 3,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: availableWidth * 0.25,
                                  child: Text(
                                    "Delivery Charge".tr(),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      height: 3,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: availableWidth * 0.25,
                                  child: Text(
                                    "Branch".tr(),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      height: 3,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: ListView.builder(
                                itemCount: addresses.length,
                                itemBuilder: (context, i) {
                                  String branchName = branches.value.firstWhere((element) => element.id == addresses[i].branchId).name;
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 20.h),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: 1.w, color: Colors.grey),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: availableWidth * 0.25,
                                          child: Text(
                                            addresses[i].address,
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: availableWidth * 0.25,
                                          child: Text(
                                            addresses[i].minimumOrder.toCurrency(),
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: availableWidth * 0.25,
                                          child: Text(
                                            addresses[i].deliveryCharge.toCurrency(),
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: availableWidth * 0.25,
                                          child: Text(
                                            branchName,
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: mainContext!,
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox();
      },
    );
  }

  Future<List<ProductList>> showProductList(
    ValueNotifier<List<ProductList>> productsNotifier, {
    bool multiSelection = false,
    Function(ProductList)? checkAvailabilty,
    Function(ProductList)? checkAvailability,
    // ignore: avoid_types_as_parameter_names, non_constant_identifier_names
    Page = 1,
    StreamController<String>? searchController,
    ScrollController? scrollController,
    required Null Function() onScroll,
    String filterText = "",
  }) async {
    final StreamController<String> searchController = StreamController<String>.broadcast();

    List<ProductList> filteredList = productsNotifier.value.toList();

    List<ProductList>? selectedProducts = await showGeneralDialog<List<ProductList>>(
      barrierColor: Colors.black.withOpacity(0.5),
      useRootNavigator: false,
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Dialog(
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            child: Container(
              height: 847.h,
              width: 1080.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Product List".tr(),
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: CustomTextField(
                      hint: 'Search ...'.tr(),
                      focus: true,
                      callback: (value) {
                        filterText = value;
                        searchController.add(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<List<ProductList>>(
                      valueListenable: productsNotifier,
                      builder: (context, products, _) {
                        filteredList = products.toList();
                        return StreamBuilder<String>(
                          stream: searchController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.data != null && snapshot.data != "") {
                              filteredList = products.where((element) => element.name.toLowerCase().contains(snapshot.data!.toString().toLowerCase()) || element.barcode.toLowerCase().contains(snapshot.data!.toString().toLowerCase()) || element.price == num.tryParse(snapshot.data!)?.toDouble()).toList();
                            } else {
                              filteredList = products;
                            }

                            filterText = filterText.trim();
                            searchword.value = filterText.trim();

                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              margin: EdgeInsets.symmetric(vertical: 20.h),
                              child: LayoutBuilder(builder: (context, constraints) {
                                double availableWidth = constraints.maxWidth - 49;
                                return Column(
                                  children: [
                                    SizedBox(
                                      height: 40,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: availableWidth * 0.3,
                                            child: Text(
                                              "Product Name".tr(),
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                height: 1.5.h,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: availableWidth * 0.15,
                                            child: Text(
                                              "Available".tr(),
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                height: 1.5.h,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: availableWidth * 0.25,
                                            child: Text(
                                              "Barcode".tr(),
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                height: 1.5.h,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: availableWidth * 0.15,
                                            child: Text(
                                              "Price".tr(),
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                height: 1.5.h,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: availableWidth * 0.17,
                                            child: Text(
                                              "",
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                height: 1.5.h,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      height: 1,
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height,
                                        child: SingleChildScrollView(
                                          controller: scrollController,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemExtent: 60.h,
                                            itemCount: filteredList.length,
                                            itemBuilder: (context, i) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(width: 1.w),
                                                  ),
                                                ),
                                                child: InkWell(
                                                  onTap: () async {
                                                    if (!multiSelection) {
                                                      for (var element in filteredList) {
                                                        element.isSelected = false;
                                                      }
                                                    }
                                                    filteredList[i].isSelected = !filteredList[i].isSelected;
                                                    productsNotifier.value = List.from(productsNotifier.value);
                                                  },
                                                  child: Container(
                                                    color: filteredList[i].isSelected ? const Color(0xffe0fbfc) : Colors.white,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: availableWidth * 0.3,
                                                          child: Text(
                                                            filteredList[i].name.trim().toString(),
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(
                                                              fontSize: 18.sp,
                                                              color: Colors.black,
                                                              height: 1,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: availableWidth * 0.15,
                                                            child: Text(
                                                              filteredList[i].available.toString().replaceAll(RegExp(r'([.])(?!.*\d)'), ''),
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                fontSize: 18.sp,
                                                                color: Colors.black,
                                                                height: 1,
                                                              ),
                                                            )),
                                                        SizedBox(
                                                          width: availableWidth * 0.25,
                                                          child: Text(
                                                            filteredList[i].barcode.toString(),
                                                            style: TextStyle(
                                                              fontSize: 18.sp,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: availableWidth * 0.15,
                                                          child: Text(
                                                            filteredList[i].price.toCurrency(),
                                                            style: TextStyle(
                                                              fontSize: 18.sp,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: availableWidth * 0.17,
                                                          margin: const EdgeInsets.all(5),
                                                          child: filteredList[i].available != ""
                                                              ? OptionButton(
                                                                  "Check Availability".tr(),
                                                                  onTap: () {
                                                                    if (checkAvailabilty != null) {
                                                                      checkAvailabilty(filteredList[i]);
                                                                    } else {
                                                                      return;
                                                                    }
                                                                  },
                                                                  lineHeight: 1.2,
                                                                  fontSize: 15.sp,
                                                                  style: "primary",
                                                                )
                                                              : const SizedBox(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(238, 238, 238, 1),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  OptionButton(
                                    "Cancel".tr(),
                                    onTap: () {
                                      List<ProductList> selected = [];
                                      Navigator.of(context).pop(selected);
                                    },
                                    lineHeight: 1.2,
                                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                    fontSize: 20.sp,
                                    style: "primary",
                                  ),
                                  OptionButton(
                                    "Pick".tr(),
                                    onTap: () {
                                      List<ProductList> selected = productsNotifier.value.where((f) => f.isSelected).toList();
                                      Navigator.of(context).pop(selected);
                                    },
                                    lineHeight: 1.2,
                                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                    fontSize: 20.sp,
                                    style: "primary",
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: mainContext!,
      pageBuilder: (context, animation1, animation2) {
        return const Text("");
      },
    );

    searchController.close();

    if (selectedProducts == null) return [];
    return selectedProducts;
  }

  void productAvailabilty(ProductList product, List<ProductBranchAvailability> branches) async {
    double totalOnHand = branches.map((e) => e.onHand).reduce((value, element) => value + element);
    await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 600.h,
                width: 600.w,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    margin: EdgeInsets.symmetric(vertical: 20.h),
                    child: LayoutBuilder(builder: (context, constraints) {
                      double availableWidth = constraints.maxWidth - 49;
                      return Column(
                        children: [
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: availableWidth * 0.8,
                                  child: Text(
                                    "Branch".tr(),
                                    style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: availableWidth * 0.2,
                                  child: Text(
                                    "Available".tr(),
                                    style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemExtent: 60.h,
                              itemCount: branches.length,
                              itemBuilder: (context, i) {
                                return Container(
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: availableWidth * 0.8,
                                        child: Text(
                                          branches[i].branch.toString(),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(fontSize: 18.sp, color: Colors.black, height: 1),
                                        ),
                                      ),
                                      SizedBox(
                                        width: availableWidth * 0.2,
                                        child: Text(
                                          branches[i].onHand.toString().replaceAll(RegExp(r'([.])(?!.*\d)'), ''),
                                          style: TextStyle(fontSize: 18.sp, color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(
                            height: 1,
                          ),
                          Container(
                            height: 40.h,
                            color: Colors.white,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: availableWidth * 0.8,
                                  child: Text(
                                    "Total".tr(),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(fontSize: 25.sp, color: Colors.black),
                                  ),
                                ),
                                SizedBox(
                                  width: availableWidth * 0.2,
                                  child: Text(
                                    totalOnHand.toString().replaceAll(RegExp(r'([.])(?!.*\d)'), ''),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(fontSize: 25.sp, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    }),
                  )),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OptionButton(
                                  "Close".tr(),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  style: "primary",
                                ),
                              ],
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });
  }

  Future<String?> noteDialog({String initValue = ""}) async {
    TextEditingController textEditingController = TextEditingController();
    textEditingController.text = initValue;
    FocusNode focus = FocusNode();

    String? result = await showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      useRootNavigator: false,
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: widget,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, a1, a2) {
        return Dialog(
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
          child: Container(
            height: (isWindowsPlatform()) ? 750.h : 500.h, // Increase height here
            width: 1200.w, // Increase width here
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add Note".tr(),
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        TextFormField(
                          autofocus: true,
                          controller: textEditingController,
                          style: TextStyle(fontSize: 18.sp),
                          maxLines: 3,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.all(10.w),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 2.w,
                                color: WidgetUtilts.currentSkin.primaryButtonBorder,
                              ),
                            ),
                            hintStyle: TextStyle(fontSize: 18.sp),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.w,
                                color: const Color.fromRGBO(215, 215, 215, 1),
                              ),
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                            hintText: "Enter text ...".tr(),
                          ),
                        ),
                        SizedBox(height: 15.h),
                        if (isWindowsPlatform())
                          Keyboard(
                            onChange: (txt) {
                              textEditingController.text += txt;
                              focus.requestFocus();
                            },
                            onDelete: () {
                              try {
                                textEditingController.text = textEditingController.text.substring(0, textEditingController.text.length - 1);
                                textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
                                focus.requestFocus();
                              } catch (e) {
                                //error
                              }
                            },
                            onMoveCursor: (val) {
                              if (val == "backCursor") {
                                TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length - 1));
                              } else {
                                TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length + 1));
                              }

                              focus.requestFocus();
                            },
                          ),
                        SizedBox(height: 15.h),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 85.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: const BoxDecoration(
                    //   color: Color.fromRGBO(238, 238, 238, 1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OptionButton(
                        "Cancel".tr(),
                        onTap: () {
                          Navigator.of(context).pop(null);
                        },
                        lineHeight: 1.2,
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                        fontSize: 20.sp,
                        style: "primary",
                      ),
                      OptionButton(
                        "Done".tr(),
                        onTap: () {
                          Navigator.of(context).pop(textEditingController.text);
                        },
                        lineHeight: 1.2,
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                        fontSize: 20.sp,
                        style: "primary",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      context: mainContext!,
    );
    return result;
  }

  Future<PricedNote?> noteDialogWithPrice({String initValue = ""}) async {
    String note = "";
    double price = 0;
    PricedNote? resault = await showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      useRootNavigator: false,
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Dialog(
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            child: Container(
              height: 390.h,
              width: 600.w,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
              child: Column(children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add Short Note".tr(),
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      CustomTextArea(
                        hint: "Enter text ...".tr(),
                        callback: ((p0) {
                          note = p0;
                        }),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        CustomDigitsField(
                            hint: "0.000",
                            callback: ((p0) {
                              price = p0;
                            }),
                            keypadType: KeyPadType.price),
                        SizedBox(
                          height: 15.h,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 85.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OptionButton(
                                "Cancel".tr(),
                                onTap: () {
                                  Navigator.of(context).pop(null);
                                },
                                lineHeight: 1.2,
                                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                fontSize: 20.sp,
                                style: "primary",
                              ),
                              OptionButton(
                                "Done".tr(),
                                onTap: () {
                                  Navigator.of(context).pop(PricedNote(note, price));
                                },
                                lineHeight: 1.2,
                                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                fontSize: 20.sp,
                                style: "primary",
                              ),
                            ],
                          ))
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: mainContext!,
      pageBuilder: (context, animation1, animation2) {
        return const Text("");
      },
    );

    return resault;
  }

  Future<double?> numberDialog(String title) async {
    late TextEditingController textEditingController = TextEditingController();
    late FocusNode focus = FocusNode();

    double? res = await showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Dialog(
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            child: LayoutBuilder(builder: (context, constraints) {
              double dialogWidth = constraints.minWidth;
              double keyWidth = ((dialogWidth - 40.w) / 3);
              double dialogHeight = 60 + //cancel enter button height
                  60.h + // textbox height
                  45.h + // margin between buttons
                  30 + // enter your password height
                  10 + //cancel enter margin top
                  10.h + // enter your password margin
                  20.h + //container vertical padding
                  30.h + //textbox padding
                  (keyWidth * 4); // for row of buttons
              return Container(
                width: dialogWidth,
                height: dialogHeight,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: WidgetUtilts.currentSkin.bgColor,
                ),
                child: Column(children: [
                  Container(
                    height: 30,
                    margin: EdgeInsets.only(bottom: 20.h, top: 10.h),
                    child: Text(
                      title,
                      style: TextStyle(color: Colors.white, fontSize: 25.sp, fontWeight: FontWeight.w700, height: 1.5.h),
                    ),
                  ),
                  KeyPad(
                    (txt) {
                      textEditingController.text = txt;
                      focus.requestFocus();
                    },
                    keyHeight: keyWidth,
                    light: false,
                    keypadType: KeyPadType.number,
                    enableKeyboardListner: true,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: KeyButton(
                            height: 60,
                            "Cancel".tr(),
                            onTap: () {
                              Navigator.of(context).pop(null);
                            },
                            fontSize: 30.sp,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: KeyButton(
                            height: 60,
                            "Done".tr(),
                            onTap: () {
                              double? x = double.tryParse(textEditingController.text);
                              Navigator.of(context).pop(x);
                            },
                            fontSize: 30.sp,
                          ),
                        )
                      ],
                    ),
                  )
                ]),
              );
            }),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: mainContext!,
      pageBuilder: (context, animation1, animation2) {
        return const Text("");
      },
    );
    return res;
  }

  Future<double?> priceDialog(String title) async {
    late TextEditingController textEditingController = TextEditingController();
    late FocusNode focus = FocusNode();

    double? res = await showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Dialog(
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            child: LayoutBuilder(builder: (context, constraints) {
              double dialogWidth = constraints.minWidth;
              double keyWidth = ((dialogWidth - 40.w) / 3);
              double dialogHeight = 60 + //cancel enter button height
                  60.h + // textbox height
                  45.h + // margin between buttons
                  30 + // enter your password height
                  10 + //cancel enter margin top
                  10.h + // enter your password margin
                  20.h + //container vertical padding
                  30.h + //textbox padding
                  (keyWidth * 4); // for row of buttons
              return Container(
                width: dialogWidth,
                height: dialogHeight,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: WidgetUtilts.currentSkin.bgColor,
                ),
                child: Column(children: [
                  Container(
                    height: 30,
                    margin: EdgeInsets.only(bottom: 20.h, top: 10.h),
                    child: Text(
                      title,
                      style: TextStyle(color: Colors.white, fontSize: 25.sp, fontWeight: FontWeight.w700, height: 1.5.h),
                    ),
                  ),
                  KeyPad(
                    (txt) {
                      textEditingController.text = txt;
                      focus.requestFocus();
                    },
                    keyHeight: keyWidth,
                    light: false,
                    keypadType: KeyPadType.price,
                    enableKeyboardListner: true,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: KeyButton(
                            height: 60,
                            "Cancel".tr(),
                            onTap: () {
                              Navigator.of(context).pop(null);
                            },
                            fontSize: 30.sp,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: KeyButton(
                            height: 60,
                            "Done".tr(),
                            onTap: () {
                              double? x = double.tryParse(textEditingController.text);
                              Navigator.of(context).pop(x);
                            },
                            fontSize: 30.sp,
                          ),
                        )
                      ],
                    ),
                  )
                ]),
              );
            }),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: mainContext!,
      pageBuilder: (context, animation1, animation2) {
        return const Text("");
      },
    );
    return res;
  }

  Future<String> phoneDialog(String title) async {
    late TextEditingController textEditingController = TextEditingController();
    late FocusNode focus = FocusNode();

    String? res = await showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Dialog(
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            child: LayoutBuilder(builder: (context, constraints) {
              double dialogWidth = constraints.minWidth;
              double keyWidth = ((dialogWidth - 40.w) / 3);
              double dialogHeight = 60 + //cancel enter button height
                  60.h + // textbox height
                  45.h + // margin between buttons
                  30 + // enter your password height
                  10 + //cancel enter margin top
                  10.h + // enter your password margin
                  20.h + //container vertical padding
                  30.h + //textbox padding
                  (keyWidth * 4); // for row of buttons
              return Container(
                width: dialogWidth,
                height: dialogHeight,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: WidgetUtilts.currentSkin.bgColor,
                ),
                child: Column(children: [
                  Container(
                    height: 30,
                    margin: EdgeInsets.only(bottom: 20.h, top: 10.h),
                    child: Text(
                      title,
                      style: TextStyle(color: Colors.white, fontSize: 25.sp, fontWeight: FontWeight.w700, height: 1.5.h),
                    ),
                  ),
                  KeyPad(
                    (txt) {
                      textEditingController.text = txt;
                      focus.requestFocus();
                    },
                    keyHeight: keyWidth,
                    light: false,
                    keypadType: KeyPadType.number,
                    enableKeyboardListner: true,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: KeyButton(
                            height: 60,
                            "Cancel".tr(),
                            onTap: () {
                              Navigator.of(context).pop("");
                            },
                            fontSize: 30.sp,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: KeyButton(
                            height: 60,
                            "Done".tr(),
                            onTap: () {
                              Navigator.of(context).pop(textEditingController.text);
                            },
                            fontSize: 30.sp,
                          ),
                        )
                      ],
                    ),
                  )
                ]),
              );
            }),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: mainContext!,
      pageBuilder: (context, animation1, animation2) {
        return const Text("");
      },
    );
    if (res == null) return "";
    return res;
  }

  Future<DateTime?> dateTimePicker(String title) async {
    DateTime selectedDateTime = DateTime.now();

    DateTime? res = await showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      useRootNavigator: false,
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Dialog(
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            child: Container(
              height: 310.h,
              width: 400.w,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
              child: Column(children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 11.h),
                  child: Row(children: [
                    Container(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Text(
                        "Date".tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 25.sp, height: 1.5),
                      ),
                    ),
                    Expanded(
                      child: CustomDateField(
                        hint: 'Date'.tr(),
                        initValue: selectedDateTime,
                        callback: (value) {
                          if (value != null) {
                            selectedDateTime = DateTime(value.year, value.month, value.day, selectedDateTime.hour, selectedDateTime.minute);
                          }
                        },
                      ),
                    ),
                  ]),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 11.h),
                  child: Row(children: [
                    Container(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Text(
                        "Time".tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 25.sp, height: 1.5),
                      ),
                    ),
                    Expanded(
                      child: CustomTimeField(
                        hint: 'Time'.tr(),
                        initValue: selectedDateTime,
                        callback: (value) {
                          if (value != null) {
                            selectedDateTime = DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, value.hour, value.minute);
                          }
                        },
                      ),
                    ),
                  ]),
                ),
                Container(
                  height: 85.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OptionButton(
                                "Cancel".tr(),
                                lineHeight: 1.2,
                                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                fontSize: 20.sp,
                                style: "danger",
                                onTap: () {
                                  Navigator.of(context).pop(null);
                                },
                              ),
                              OptionButton(
                                "Select".tr(),
                                lineHeight: 1.2,
                                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                fontSize: 20.sp,
                                style: "primary",
                                onTap: () {
                                  Navigator.of(context).pop(selectedDateTime);
                                },
                              )
                            ],
                          ))
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: mainContext!,
      pageBuilder: (context, animation1, animation2) {
        return const Text("");
      },
    );
    if (res == null) return null;
    return res;
  }

  Future<Menu?> showMenuList(List<Menu> menus) async {
    Menu? menu = await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 350.h,
                width: 350.w,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Text(
                      "Change Menu".tr(),
                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.w),
                      itemCount: menus.length,
                      itemBuilder: (ctx, index) {
                        return InkWell(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: WidgetUtilts.currentSkin.primaryColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    menus[index].name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "${menus[index].startAt == null ? "" : DateFormat('HH:mm').format(menus[index].startAt!)}-${menus[index].endAt == null ? "" : DateFormat('HH:mm').format(menus[index].endAt!)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(menus[index]);
                          },
                        );
                      },
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });
    return menu;
  }

  Future<ProductBatch?> batchedItem(List<ProductBatch> batches) async {
    final StreamController<String> searchController = StreamController<String>.broadcast();
    String filterText = "";

    ProductBatch? resault = await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 600.h,
                width: 800.w,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Choose a Batch".tr(),
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: CustomTextField(
                        hint: 'Search ...'.tr(),
                        focus: true,
                        callback: (value) {
                          filterText = value;
                          searchController.add(value);
                        }),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: StreamBuilder<Object>(
                          stream: searchController.stream,
                          builder: (context, snapshot) {
                            List<DataRow> customerTableRow = [];
                            List<ProductBatch> batchesList = [];
                            if (filterText == "") {
                              batchesList = batches;
                            } else {
                              batchesList = batches.where((f) => f.batch.toLowerCase().contains(filterText.toLowerCase())).toList();
                            }

                            for (var batch in batchesList) {
                              customerTableRow.add(
                                DataRow(
                                  onSelectChanged: (selected) {},
                                  cells: <DataCell>[
                                    DataCell(Text(
                                      batch.batch.toString(),
                                      style: TextStyle(fontSize: 18.sp, color: Colors.black, height: 1),
                                    )),
                                    DataCell(Text(
                                      batch.expireDate.toString(),
                                      style: TextStyle(fontSize: 18.sp, color: Colors.black),
                                    )),
                                    DataCell(SizedBox(
                                      height: 45.h,
                                      child: OptionButton(
                                        "Select".tr(),
                                        lineHeight: 1.2,
                                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                        fontSize: 20.sp,
                                        style: "primary",
                                        onTap: () {
                                          Navigator.of(context).pop(batch);
                                        },
                                      ),
                                    )),
                                  ],
                                ),
                              );
                            }

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 20.h),
                              child: LayoutBuilder(builder: (context, constraints) {
                                double availableWidth = constraints.maxWidth - 49;
                                return DataTable2(
                                  sortColumnIndex: 0,
                                  sortAscending: true,
                                  showCheckboxColumn: false,
                                  dataRowHeight: 60.h,
                                  headingRowHeight: 40,
                                  columnSpacing: 1,
                                  columns: <DataColumn2>[
                                    DataColumn2(
                                      fixedWidth: availableWidth * 0.45,
                                      label: Text(
                                        "Name".tr(),
                                        style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                      ),
                                      onSort: (int columnIndex, bool ascending) {},
                                    ),
                                    DataColumn2(
                                      fixedWidth: availableWidth * 0.4,
                                      label: Text(
                                        "Expiry Date".tr(),
                                        style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                      ),
                                      onSort: (int columnIndex, bool ascending) {},
                                    ),
                                    DataColumn2(
                                      fixedWidth: availableWidth * 0.15,
                                      label: Text(
                                        "",
                                        style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                      ),
                                      onSort: (int columnIndex, bool ascending) {},
                                    ),
                                  ],
                                  rows: <DataRow>[
                                    ...customerTableRow
                                  ],
                                );
                              }),
                            );
                          }),
                    ),
                  ),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OptionButton(
                                  "Cancel".tr(),
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  onTap: () {
                                    Navigator.of(context).pop(null);
                                  },
                                  style: "primary",
                                ),
                              ],
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });

    searchController.close();
    return resault;
  }

  Future<String?> showBranchSelectionDialog(List<Branch> branches) async {
    Branch? selectedBranch = await showDialog<Branch>(
      context: mainContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Branch'),
          content: SingleChildScrollView(
            child: ListBody(
              children: branches.map((branch) {
                return ListTile(
                  title: Text(branch.name), // Customize to display branch information
                  onTap: () {
                    Navigator.of(context).pop(branch);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
    //print(selectedBranch?.id);
    // Return the branch ID if a branch is selected, or null otherwise
    return selectedBranch?.id;
  }

  Future<ProductSerial?> serializedItem(List<ProductSerial> serials) async {
    final StreamController<String> searchController = StreamController<String>.broadcast();
    String filterText = "";

    ProductSerial? resault = await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 600.h,
                width: 800.w,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Choose a Serial".tr(),
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: CustomTextField(
                        hint: 'Search ...'.tr(),
                        focus: true,
                        callback: (value) {
                          filterText = value;
                          searchController.add(value);
                        }),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: StreamBuilder<Object>(
                          stream: searchController.stream,
                          builder: (context, snapshot) {
                            List<DataRow> customerTableRow = [];
                            List<ProductSerial> serialList = [];
                            if (filterText == "") {
                              serialList = serials;
                            } else {
                              serialList = serials.where((f) => f.serial.toLowerCase().contains(filterText.toLowerCase())).toList();
                            }

                            for (var serial in serialList) {
                              customerTableRow.add(
                                DataRow(
                                  onSelectChanged: (selected) {},
                                  cells: <DataCell>[
                                    DataCell(Text(
                                      serial.serial.toString(),
                                      style: TextStyle(fontSize: 18.sp, color: Colors.black, height: 1),
                                    )),
                                    DataCell(Text(
                                      serial.status.toString(),
                                      style: TextStyle(fontSize: 18.sp, color: Colors.black),
                                    )),
                                    DataCell(SizedBox(
                                      height: 45.h,
                                      child: serial.status == "Available"
                                          ? OptionButton(
                                              "Select".tr(),
                                              lineHeight: 1.2,
                                              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                              fontSize: 20.sp,
                                              style: "primary",
                                              onTap: () {
                                                Navigator.of(context).pop(serial);
                                              },
                                            )
                                          : const SizedBox(),
                                    )),
                                  ],
                                ),
                              );
                            }

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 20.h),
                              child: LayoutBuilder(builder: (context, constraints) {
                                double availableWidth = constraints.maxWidth - 49;
                                return DataTable2(
                                  sortColumnIndex: 0,
                                  sortAscending: true,
                                  showCheckboxColumn: false,
                                  dataRowHeight: 60.h,
                                  headingRowHeight: 40,
                                  columnSpacing: 1,
                                  columns: <DataColumn2>[
                                    DataColumn2(
                                      fixedWidth: availableWidth * 0.65,
                                      label: Text(
                                        "Name".tr(),
                                        style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                      ),
                                      onSort: (int columnIndex, bool ascending) {},
                                    ),
                                    DataColumn2(
                                      fixedWidth: availableWidth * 0.19,
                                      label: Text(
                                        "Status".tr(),
                                        style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                      ),
                                      onSort: (int columnIndex, bool ascending) {},
                                    ),
                                    DataColumn2(
                                      fixedWidth: availableWidth * 0.16,
                                      label: Text(
                                        "",
                                        style: TextStyle(fontSize: 18.sp, height: 1.5.h, fontWeight: FontWeight.bold),
                                      ),
                                      onSort: (int columnIndex, bool ascending) {},
                                    ),
                                  ],
                                  rows: <DataRow>[
                                    ...customerTableRow
                                  ],
                                );
                              }),
                            );
                          }),
                    ),
                  ),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OptionButton(
                                  "Cancel".tr(),
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  onTap: () {
                                    Navigator.of(context).pop(null);
                                  },
                                  style: "primary",
                                ),
                              ],
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });

    searchController.close();
    return resault;
  }

  Future<String?> voidReasonDialog(
      {List<String> reasons = const [
        "Customer Return",
        "Damaged"
      ]}) async {
    TextEditingController textEditingController = TextEditingController();

    FocusNode focus = FocusNode();

    List<Widget> reasonsBtns = [];
    for (var element in reasons) {
      reasonsBtns.add(
        InkWell(
          onTap: () {
            textEditingController.text = element;
          },
          child: Container(
            margin: EdgeInsets.all(5.h),
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            decoration: BoxDecoration(
              color: const Color(0xFF4F9AFF),
              borderRadius: BorderRadiusDirectional.only(topStart: Radius.circular(10.r), bottomEnd: Radius.circular(10.r)),
            ),
            child: Text(element, style: TextStyle(color: Colors.white, fontSize: 18.sp)),
          ),
        ),
      );
    }

    String? resault = await showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        useRootNavigator: false,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Dialog(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              child: Container(
                height: 770.h,
                width: 1200.w,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Void Reason".tr(),
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          Row(children: reasonsBtns),
                          const SizedBox(height: 10),
                          TextFormField(
                            focusNode: focus,
                            autofocus: true,
                            controller: textEditingController,
                            style: TextStyle(fontSize: 18.sp),
                            maxLines: 3,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: EdgeInsets.all(10.w),
                              focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(width: 2.w, color: WidgetUtilts.currentSkin.primaryButtonBorder)),
                              hintStyle: TextStyle(fontSize: 18.sp),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2.w, color: const Color.fromRGBO(215, 215, 215, 1)), borderRadius: const BorderRadius.all(Radius.circular(10))),
                            ),
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Keyboard(
                            onChange: (txt) {
                              textEditingController.text += txt;
                              focus.requestFocus();
                            },
                            onDelete: () {
                              try {
                                if (textEditingController.text.isNotEmpty) {
                                  textEditingController.text = textEditingController.text.substring(0, textEditingController.text.length - 1);
                                  textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
                                  focus.requestFocus();
                                }
                              } catch (e) {
                                //error
                              }
                            },
                            onMoveCursor: (val) {
                              if (val == "backCursor") {
                                TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length - 1));
                              } else {
                                TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length + 1));
                              }

                              focus.requestFocus();
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 85.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OptionButton(
                                  "Cancel".tr(),
                                  onTap: () {
                                    if (Navigator.of(context).canPop()) Navigator.of(context).pop(null);
                                  },
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  style: "primary",
                                ),
                                OptionButton(
                                  "Finish".tr(),
                                  onTap: () {
                                    if (Navigator.of(context).canPop()) Navigator.of(context).pop(textEditingController.text);
                                  },
                                  lineHeight: 1.2,
                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  fontSize: 20.sp,
                                  style: "primary",
                                ),
                              ],
                            ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: mainContext!,
        pageBuilder: (context, animation1, animation2) {
          return const Text("");
        });

    return resault;
  }

  Future<void> showSettingsDialog(BuildContext context) async {
    String ip = '';
    String port = '';
    String username = '';
    String password = '';
    String sid = '';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    ip = prefs.getString('ip') ?? '';
    port = prefs.getString('port') ?? '';
    username = prefs.getString('username') ?? '';
    password = prefs.getString('password') ?? '';
    sid = prefs.getString('sid') ?? '';

    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings').tr(),
          content: Form(
            key: _settingsFormKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    initialValue: ip,
                    decoration: const InputDecoration(labelText: 'IP'),
                    onSaved: (value) {
                      ip = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an IP'.tr();
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: port,
                    decoration: const InputDecoration(labelText: 'Port'),
                    onSaved: (value) {
                      port = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a port'.tr();
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: username,
                    decoration: const InputDecoration(labelText: 'Username'),
                    onSaved: (value) {
                      username = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username'.tr();
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    onSaved: (value) {
                      password = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password'.tr();
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  TextFormField(
                    initialValue: sid,
                    decoration: const InputDecoration(labelText: 'SID'),
                    onSaved: (value) {
                      sid = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a SID'.tr();
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (_settingsFormKey.currentState?.validate() ?? false) {
                  _settingsFormKey.currentState?.save();

                  await prefs.setString('ip', ip);
                  await prefs.setString('port', port);
                  await prefs.setString('username', username);
                  await prefs.setString('password', password);
                  await prefs.setString('sid', sid);

                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  hideLoading() {
    if (isLoading) Navigator.of(mainContext!).pop();
  }

  bool isLoading = false;
  showLoading() async {
    isLoading = true;
    await showDialog<void>(
        context: mainContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // return SimpleDialog(
          //   elevation: 0.0,
          //   backgroundColor: Colors.transparent, // can change this to your prefered color
          //   children: <Widget>[
          // Container(
          //   width: 200,
          //   height: 170,
          //   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //   const CircularProgressIndicator(),
          //   SizedBox(height: 20.h),
          //   Text("Loading", style: TextStyle(fontSize: 30.sp)),
          //     ],
          //   ),
          // )
          //   ],
          // );
          // if (!Utilts().checkConnection()) {
          //   Fluttertoast.showToast(msg: "No internet connection");
          // }
          return Material(
              color: Colors.transparent, // can change this to your prefered color
              child: Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: 15.h),
                      Text(
                        "Loading",
                        style: TextStyle(fontSize: 20.sp, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ));
        });
    // if (!Utilts().checkConnection()) {
    //   Fluttertoast.showToast(msg: "No internet connection");
    // }
    isLoading = false;
  }

  void updateProductList(List<Product> allProducts) {}

  Future<void> changeServerDialog(BuildContext context) async {
    isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await showDialog<void>(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Material(
            color: Colors.transparent, // can change this to your prefered color
            child: Center(
              child: Container(
                width: 400,
                height: 440,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.r))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Text(
                                "Change Server",
                                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  child: Container(
                                    width: 200,
                                    padding: const EdgeInsets.all(
                                      8,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: WidgetUtilts.currentSkin.primaryColor,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Production",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    prefs.setString("serverURL", "https://productionback.invopos.co");
                                  },
                                ),
                                InkWell(
                                  child: Container(
                                    width: 200,
                                    padding: const EdgeInsets.all(
                                      8,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: WidgetUtilts.currentSkin.primaryColor,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Test",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    prefs.setString("serverURL", "https://testBack.invopos.co");
                                  },
                                ),
                                InkWell(
                                  child: Container(
                                    width: 200,
                                    padding: const EdgeInsets.all(
                                      8,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: WidgetUtilts.currentSkin.primaryColor,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Development",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    prefs.setString("serverURL", "https://devBack.invopos.co");
                                  },
                                ),
                                InkWell(
                                  child: Container(
                                    width: 200,
                                    padding: const EdgeInsets.all(
                                      8,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: WidgetUtilts.currentSkin.primaryColor,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Local",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    prefs.setString("serverURL", "http://10.2.2.60:3001");
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 85.h,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  OptionButton(
                                    "Cancel".tr(),
                                    lineHeight: 1.2,
                                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                    fontSize: 20.sp,
                                    style: "danger",
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
    isLoading = false;
  }
}
