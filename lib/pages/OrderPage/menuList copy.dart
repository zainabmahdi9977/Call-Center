// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:invo_5_widget/invo_5_widget.dart';
import 'package:invo_models/invo_models.dart';
import 'package:newcall_center/utils/custom.scroll.behavior.dart';
import 'package:newcall_center/utils/hex.color.dart';
import 'package:resize/resize.dart';

// ignore: must_be_immutable
class MenuList extends StatefulWidget {
  final Function(MenuSectionProduct)? callback;
  final List<MenuSectionProduct> products;
  final Future<String> Function(String) loadImage;
  const MenuList({
    super.key,
    this.callback,
    required this.products,
    required this.loadImage,
  });

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  double cellHeight = 0;
  double spacing = 7;
  final PageController pageController = PageController();

  final StreamController<int> pageIndexController = StreamController<int>.broadcast();

  List<MenuSectionProduct> list = [];

  @override
  void initState() {
    super.initState();
    list = [];
    // widget.orderPageBloc.products.stream.listen((event) {
    //   setState(() {});
    // });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    pageIndexController.close();
  }

  List<Widget> menuPages() {
    int pageCount = list.map((e) => e.page).reduce(max);
    List<MenuSectionProduct> tempList = [];
    List<Widget> tempWidgets = [];
    List<Widget> pages = [];
    MenuSectionProduct? temp;
    for (var i = 1; i <= pageCount; i++) {
      tempList = list.where((f) => f.page == i && f.product != null).toList();

      //fill empty cells
      for (var i = 0; i < 36; i++) {
        if (tempList.where((f) => f.index == i).isEmpty) {
          tempList.add(MenuSectionProduct(
            index: i,
          ));
        }
      }

      //sort cells
      tempList.sort((prev, next) {
        if (prev.index > next.index) {
          return 1;
        } else {
          return -1;
        }
      });

      try {
        for (var item in tempList.toList()) {
          // temp = list.firstWhere((f) => f.index == item.index,
          //     orElse: () => null);
          // if (temp != null && temp.menu_item == null) list.remove(temp);

          if (item.doubleHeight) {
            temp = tempList.firstWhereOrNull((f) => f.index == item.index + 6);
            if (temp == null || temp.product == null) tempList.remove(temp);
          }

          if (item.doubleWidth) {
            temp = tempList.firstWhereOrNull((f) => f.index == item.index + 1);
            if (temp == null || temp.product == null) tempList.remove(temp);
          }

          if (item.doubleHeight && item.doubleWidth) {
            temp = tempList.firstWhereOrNull((f) => f.index == item.index + 7);
            if (temp == null || temp.product == null) tempList.remove(temp);
          }
        }
        //print("list length : ${list.length}");
      } catch (e) {
        debugPrint("error :$e");
      }

      tempList.sort((prev, next) {
        if (prev.index > next.index) {
          return 1;
        } else {
          return -1;
        }
      });

      tempWidgets = [];
      for (var element in tempList.toList()) {
        if (element.doubleHeight && element.doubleWidth) {
          tempWidgets.add(doubleWidthDoubleHeightItem(element));
        } else if (element.doubleHeight) {
          tempWidgets.add(doubleHeightItem(element));
        } else if (element.doubleWidth) {
          tempWidgets.add(doubleWidthItem(element));
        } else {
          tempWidgets.add(normalItem(element));
        }
      }

      pages.add(StaggeredGrid.count(
        crossAxisCount: 6,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        children: tempWidgets,
      ));
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    // return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {});

    list = widget.products;
    if (list.isEmpty) {
      return Center(
        child: Text("This section has no products attached".tr()),
      );
    }

    double itemSpaceing = spacing * (6 - 1); // MainSpaceing  * (noOfRow - 1)
    // double pageVerticalMargin = 30.h;
    // double groupHeight = 219.h;
    cellHeight = ((MediaQuery.of(context).size.height - 132.h - 85.h - 30.h) - itemSpaceing) / 6;
    List<Widget> pages = menuPages();

    return Row(
      children: [
        Expanded(
          child: PageView(
            controller: pageController,
            scrollBehavior: MyCustomScrollBehavior(),
            onPageChanged: (index) {
              pageIndexController.add(index);
            },
            dragStartBehavior: DragStartBehavior.down,
            scrollDirection: Axis.vertical,
            children: pages,
          ),
        ),
        (pages.length > 1)
            ? SizedBox(
                width: 50.w,
                height: 100.h,
                child: StreamBuilder(
                  stream: pageIndexController.stream,
                  builder: (context, snapshot) {
                    int selectedIndex = 0;
                    if (snapshot.data != null) {
                      selectedIndex = int.parse(snapshot.data!.toString());
                    }

                    return ListView.builder(
                      itemCount: pages.length,
                      itemExtent: 20.h,
                      itemBuilder: (context, index) {
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 5.h),
                              height: 15.h,
                              width: 15.w,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == selectedIndex ? WidgetUtilts.currentSkin.primaryColor : WidgetUtilts.currentSkin.lightenPrimaryColor,
                                ),
                              ),
                            ),
                            onTap: () async {
                              if (pageController.page == index) return;
                              await pageController.animateToPage(index, duration: const Duration(milliseconds: 250), curve: Curves.easeIn);

                              pageIndexController.add(index);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            : const SizedBox()
      ],
    );
  }

  Widget normalItem(MenuSectionProduct item) {
    try {
      return StaggeredGridTile.extent(
          crossAxisCellCount: 1,
          mainAxisExtent: cellHeight,
          child: item.product != null
              ? Material(
                  child: InkWell(
                      onTap: () {
                        widget.callback!(item);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 2.w,
                              color: HexColor(item.product!.color),
                            ),
                            borderRadius: BorderRadius.circular(10.r)),
                        child: Center(
                          child: Text(
                            item.product!.getTranslatedName(WidgetUtilts.getCurrentLang),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w500, color: HexColor(item.product!.color), fontSize: 18.sp, height: 1),
                          ),
                        ),
                      )),
                )
              : Container());
    } catch (e) {
      return StaggeredGridTile.extent(crossAxisCellCount: 1, mainAxisExtent: cellHeight, child: Container());
    }
  }

  Widget doubleWidthItem(MenuSectionProduct item) {
    return StaggeredGridTile.extent(
      crossAxisCellCount: 2,
      mainAxisExtent: cellHeight,
      child: Material(
        child: InkWell(
          onLongPress: () {},
          onTap: () {
            widget.callback!(item);
          },
          child: Ink(
            decoration: BoxDecoration(
                border: Border.all(width: 2.w, color: HexColor(item.product!.color) //item.color ?? Colors.transparent,
                    ),
                color: HexColor(item.product!.color), //item.color ?? Colors.transparent,
                borderRadius: BorderRadius.circular(10.r)),
            child: FutureBuilder<String?>(
              future: widget.loadImage(item.productId),
              initialData: null,
              builder: (context, snapshot) {
                if (snapshot.data == "") {
                  //no image
                  return Center(
                    child: Text(
                      item.product!.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18.sp, height: 1.5.h),
                    ),
                  );
                }
                return Row(children: [
                  (snapshot.data == null)
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(7.r),
                                bottomLeft: Radius.circular(7.r),
                              ),
                              image: DecorationImage(
                                  alignment: Alignment.center,
                                  image: MemoryImage(base64Decode(item.product!.defaultImage)),
                                  fit: //check if image is png
                                      item.product!.defaultImage.startsWith("iVBORw0KGgo") ? BoxFit.contain : BoxFit.cover),
                            ),
                          ),
                        ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        child: Text(
                          item.product!.getTranslatedName(WidgetUtilts.getCurrentLang),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18.sp, height: 1),
                        ),
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget doubleHeightItem(MenuSectionProduct item) {
    return StaggeredGridTile.extent(
      crossAxisCellCount: 1,
      mainAxisExtent: ((cellHeight) * 2) + spacing,
      child: Material(
        child: InkWell(
          onTap: () {
            widget.callback!(item);
          },
          child: Ink(
              decoration: BoxDecoration(
                  border: Border.all(width: 2.w, color: HexColor(item.product!.color) // item.color ?? Colors.transparent,
                      ),
                  color: HexColor(item.product!.color), // item.color ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r)),
              child: FutureBuilder<String?>(
                  future: widget.loadImage(item.productId),
                  initialData: null,
                  builder: (context, snapshot) {
                    if (snapshot.data == "") {
                      //no image
                      return Center(
                        child: Text(
                          item.product!.getTranslatedName(WidgetUtilts.getCurrentLang),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18.sp, height: 1.5.h),
                        ),
                      );
                    }

                    return Column(children: [
                      Expanded(
                        child: (snapshot.data == null)
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(7.r),
                                    topRight: Radius.circular(7.r),
                                  ),
                                  image: DecorationImage(
                                      image: MemoryImage(base64Decode(snapshot.data!)),
                                      fit: //check if image is png
                                          item.product!.defaultImage.startsWith("iVBORw0KGgo") ? BoxFit.contain : BoxFit.cover),
                                ),
                              ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            child: Text(
                              item.product!.getTranslatedName(WidgetUtilts.getCurrentLang),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18.sp, height: 1),
                            ),
                          ),
                        ),
                      ),
                    ]);
                  })),
        ),
      ),
    );
  }

  Widget doubleWidthDoubleHeightItem(MenuSectionProduct item) {
    return StaggeredGridTile.extent(
      crossAxisCellCount: 2,
      mainAxisExtent: ((cellHeight) * 2) + spacing,
      child: Material(
        child: InkWell(
          onTap: () {
            widget.callback!(item);
          },
          child: FutureBuilder<String?>(
            future: widget.loadImage(item.productId),
            initialData: item.product?.defaultImage,
            builder: (context, snapshot) {
              if (snapshot.data == "" || snapshot.data == null) {
                return Ink(
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.w,
                        color: HexColor(item.product!.color), // item.color ?? Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(10.r)),
                  child: Center(
                    child: Text(
                      item.product!.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500, color: HexColor(item.product!.color), fontSize: 18.sp, height: 1.5.h),
                    ),
                  ),
                );
              }

              return Ink(
                // clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment.center,
                      image: MemoryImage(base64Decode(snapshot.data!)),
                      fit: //check if image is png
                          item.product!.defaultImage.startsWith("iVBORw0KGgo") ? BoxFit.contain : BoxFit.cover),
                  border: Border.all(width: 2.w, color: HexColor(item.product!.color) // item.color ?? Colors.transparent,
                      ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 90.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.5),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(7.r),
                          bottomRight: Radius.circular(7.r),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item.product!.getTranslatedName(WidgetUtilts.getCurrentLang),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18.sp, height: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
