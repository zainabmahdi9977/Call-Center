// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:invo_5_widget/invo_5_widget.dart';
import 'package:invo_models/invo_models.dart';

import 'package:newcall_center/blocs/orderPage/order.page.bloc.dart';
import 'package:newcall_center/blocs/orderPage/order.page.state.dart';

import 'package:newcall_center/pages/OrderPage/menuList.dart';
import 'package:newcall_center/utils/custom.scroll.behavior.dart';

import 'package:newcall_center/utils/hex.color.dart';
import 'package:resize/resize.dart';

class OrderPage extends StatefulWidget {
  final OrderPageBloc bloc;
  const OrderPage({super.key, required this.bloc});

  // This widget is the Recall page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  // final _orderPageBloc = OrderPageBloc();
  String _currentService = '';
  final ScrollController _optionsController = ScrollController();
  final ScrollController ticketPaginationController = ScrollController();
  final PageController productsPagesController = PageController();
  final PageController pageController = PageController();
  PageController ticketsPageController = PageController();

  final StreamController<int> pageIndexController = StreamController<int>.broadcast();

  ///final OrderPageBloc bloc = OrderPageBloc();
  final StreamController<bool> showGroupLeftArrow = StreamController<bool>.broadcast();
  final StreamController<bool> showGroupRightArrow = StreamController<bool>.broadcast();
  final StreamController<bool> extraModifierController = StreamController<bool>.broadcast();
  final StreamController<bool> holdItemController = StreamController<bool>.broadcast();

  final StreamController<String> extraModifierSearch = StreamController<String>.broadcast();

  final StreamController<bool> bottomOption = StreamController<bool>.broadcast();

  final GlobalKey<KeyPadState> _globalKeyPadKey = GlobalKey();

  late FocusNode focus;

  int typeOfOption = 0; // 0 = order option, 1 = item option, 2 = selected item optins, 3 = ticket header
  // List<Widget> optionsWidgets = [];
  late OrderPageBloc orderPageBloc;

  @override
  void initState() {
    super.initState();
    orderPageBloc = widget.bloc;
    _currentService = orderPageBloc.invoice.value.serviceId!;
    orderPageBloc.qty.stream.listen((double num) {
      if (_globalKeyPadKey.currentState != null) {
        if (num == 1) {
          _globalKeyPadKey.currentState!.controller.text = "";
        } else {
          _globalKeyPadKey.currentState!.controller.text = num.toString().replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
        }
      }
    });

    holdItemController.stream.listen((event) {
      if (!event) {
        for (var element in orderPageBloc.invoice.value.lines) {
          element.isSelected = false;
          // _currentService = orderPageBloc.invoice.value.serviceId!;
        }
      } else {
        orderPageBloc.onHoldFormShow();
      }
      orderPageBloc.ticketMultiItemSelection.sink(event);
    });

    focus = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    orderPageBloc.dispose();
    showGroupLeftArrow.close();
    showGroupRightArrow.close();
    _optionsController.dispose();
    pageController.dispose();
    productsPagesController.dispose();
    ticketPaginationController.dispose();
    ticketsPageController.dispose();
    pageIndexController.close();
    extraModifierController.close();
    holdItemController.close();
    bottomOption.close();
    // optionController.close();
  }

  double screenHeight = 0;
  String barcode = "";

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: RawKeyboardListener(
        focusNode: focus,
        autofocus: true,
        onKey: (event) {
          if (event.runtimeType.toString() == 'RawKeyDownEvent') {
            if (event.logicalKey.keyLabel == "F2") {
              // orderPageBloc.searchProducts();
            }
            if (event.logicalKey.keyLabel.startsWith("F")) {
              barcode = "";
            }

            if (event.logicalKey.keyLabel == "Enter") {
              if (barcode != "") {
                // bool res = orderPageBloc.addProductByBarcode(barcode);
                // if (!res) {
                //   GetIt.instance.get<DialogService>().alertDialog("Wrong Barcode", "Product Not Found");
                // }
              }
              barcode = "";
            } else {
              if (event.character != null) {
                if (event.character == "*") {
                  double? qty = double.tryParse(barcode);
                  if (qty != null) {
                    orderPageBloc.qty.sink(qty);
                  }
                  barcode = "";
                } else {
                  barcode += event.character!;
                }
              }
            }
          }
        },
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 400.w,
                        child: Column(
                          children: [
                            Container(
                              height: 50.h,
                              margin: EdgeInsets.only(bottom: 0.h),
                              child: Row(
                                children: [
                                  Text(
                                    "${"Branch".tr()}: ${orderPageBloc.branch.name}",
                                    style: TextStyle(fontFamily: 'Cairo', fontSize: 20.sp, height: 1.5),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: StreamBuilder<Object>(
                                        stream: orderPageBloc.selectedService.stream,
                                        builder: (context, snapshot) {
                                          return DropDownMenu<Service>(
                                            orderPageBloc.services.map<DropdownMenuItem<Service>>((Service value) {
                                              return DropdownMenuItem<Service>(
                                                value: value,
                                                child: Text(
                                                  value.name,
                                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 20.sp, height: 1.5),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (Service? value) async {
                                              if (value != null) {
                                                final serviceId = await orderPageBloc.changeService(value);
                                                setState(() {
                                                  _currentService = serviceId;
                                                });
                                              }
                                            },
                                            selectedValue: orderPageBloc.selectedService.value,
                                          );
                                        }),
                                  ),
                                  StreamBuilder(
                                    stream: orderPageBloc.invoice.value.headerUpdate.stream,
                                    initialData: false,
                                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                                      if (orderPageBloc.invoice.value.table == null) {
                                        return const SizedBox();
                                      }
                                      List<String> seats = [
                                        ""
                                      ];
                                      int maxSeat = orderPageBloc.invoice.value.guests > orderPageBloc.invoice.value.table!.maxSeat ? orderPageBloc.invoice.value.table!.maxSeat : orderPageBloc.invoice.value.guests;

                                      for (var i = 1; i <= maxSeat; i++) {
                                        seats.add(i.toString());
                                      }

                                      return Container(
                                        margin: EdgeInsetsDirectional.only(start: 7.w),
                                        width: 70.w,
                                        child: DropDownMenu<String>(
                                          icon: Icon(
                                            InvoIcons.chair,
                                            size: 18.sp,
                                            color: Colors.white,
                                          ),
                                          seats.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value.toString(),
                                                style: TextStyle(fontFamily: 'Cairo', fontSize: 20.sp, height: 1.5),
                                              ),
                                            );
                                          }).toList(),
                                          selectedValue: "",
                                          onChanged: (String? value) {
                                            if (value == null || value == "") {
                                              orderPageBloc.seatNumber = 0;
                                            } else {
                                              orderPageBloc.seatNumber = int.parse(value);
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            StreamBuilder<Object>(
                                stream: orderPageBloc.invoices.stream,
                                builder: (context, snapshot) {
                                  return Expanded(
                                    child: orderPageBloc.invoices.value.isNotEmpty
                                        ? Column(
                                            children: [
                                              Container(
                                                height: 40,
                                                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                                                child: StreamBuilder(
                                                    stream: orderPageBloc.selectedInvoiceIndex.stream,
                                                    initialData: 0,
                                                    builder: (context, snapshot) {
                                                      // orderPageBloc
                                                      //     .changeInvoice(orderPageBloc.selectedInvoiceIndex.value);
                                                      return ScrollConfiguration(
                                                        behavior: MyCustomScrollBehavior(),
                                                        child: ListView(controller: ticketPaginationController, scrollDirection: Axis.horizontal, children: [
                                                          ...Iterable<int>.generate(orderPageBloc.invoices.value.length).toList().map((index) {
                                                            return GestureDetector(
                                                              onTap: () {
                                                                if (orderPageBloc.ticketMultiItemSelection.value) {
                                                                  return;
                                                                }
                                                                ticketsPageController.jumpToPage(index);
                                                              },
                                                              child: Container(
                                                                width: 50,
                                                                margin: const EdgeInsets.only(right: 2.0),
                                                                decoration: BoxDecoration(
                                                                  color: orderPageBloc.selectedInvoiceIndex.value == index ? WidgetUtilts.currentSkin.ticketBg : WidgetUtilts.currentSkin.ticketButton,
                                                                  borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(12.r),
                                                                    topRight: Radius.circular(12.r),
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    (index + 1).toString(),
                                                                    style: TextStyle(fontSize: 18.sp, color: orderPageBloc.selectedInvoiceIndex.value == index ? Colors.black : Colors.white),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                          if (!orderPageBloc.onlyOneTicketPerTable)
                                                            StreamBuilder(
                                                                stream: orderPageBloc.showAddNewInvoice.stream,
                                                                builder: (context, snapshot) {
                                                                  if (orderPageBloc.showAddNewInvoice.value) {
                                                                    return GestureDetector(
                                                                      onTap: () async {
                                                                        if (orderPageBloc.ticketMultiItemSelection.value) {
                                                                          return;
                                                                        }
                                                                        // if (await orderPageBloc.addNewInvoice()) {
                                                                        //   ticketPaginationController.jumpTo(
                                                                        //       ticketPaginationController
                                                                        //           .position.maxScrollExtent);
                                                                        // }
                                                                      },
                                                                      child: Container(
                                                                        width: 50,
                                                                        margin: const EdgeInsets.only(right: 2.0),
                                                                        decoration: BoxDecoration(
                                                                          color: WidgetUtilts.currentSkin.ticketButton,
                                                                          borderRadius: BorderRadius.only(
                                                                            topLeft: Radius.circular(12.r),
                                                                            topRight: Radius.circular(12.r),
                                                                          ),
                                                                        ),
                                                                        child: const Center(
                                                                          child: Icon(Icons.add),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                  return const SizedBox();
                                                                })
                                                        ]),
                                                      );
                                                    }),
                                              ),
                                              Expanded(
                                                child: StreamBuilder(
                                                  stream: orderPageBloc.ticketMultiItemSelection.stream,
                                                  builder: (cxt, s) {
                                                    return StreamBuilder<Object>(
                                                        stream: orderPageBloc.invoices.stream,
                                                        builder: (context, snapshot) {
                                                          ticketsPageController = PageController(initialPage: orderPageBloc.selectedInvoiceIndex.value);
                                                          return PageView.builder(
                                                            key: GlobalKey(),
                                                            controller: ticketsPageController,
                                                            onPageChanged: (index) {
                                                              orderPageBloc.selectedInvoiceIndex.sink(index);
                                                            },
                                                            scrollBehavior: MyCustomScrollBehavior(),
                                                            itemCount: orderPageBloc.invoices.value.length,
                                                            itemBuilder: ((context, index) {
                                                              return Ticket(
                                                                380.w,
                                                                headerClick: () {
                                                                  orderPageBloc.showOrderOptions();
                                                                },
                                                                headerDoubleClick: () {
                                                                  orderPageBloc.showNote();
                                                                },
                                                                multiSelection: orderPageBloc.ticketMultiItemSelection.value,
                                                                invoice: orderPageBloc.invoices.value[index],
                                                                onSelect: (InvoiceLine line) {
                                                                  orderPageBloc.selectLine(line);
                                                                },
                                                                onDelete: (InvoiceLine line) {
                                                                  orderPageBloc.deleteLine(line);
                                                                },
                                                                onOptionDelete: (InvoiceLine line, InvoiceLineOption option) {
                                                                  orderPageBloc.deleteOption(line, option);
                                                                },
                                                                onDiscountDelete: (InvoiceLine line) {
                                                                  orderPageBloc.deleteDiscount(line);
                                                                },
                                                                expandedTicket: () {
                                                                  // orderPageBloc.expandedTicket();
                                                                },
                                                                selectableItems: orderPageBloc.selectableItems,
                                                                deleteableItems: orderPageBloc.deleteableItems,
                                                              );
                                                            }),
                                                          );
                                                        });
                                                  },
                                                ),
                                              ),
                                              StreamBuilder(
                                                stream: orderPageBloc.invoice.stream,
                                                builder: (context, snapshot) {
                                                  return StreamBuilder(
                                                    stream: orderPageBloc.invoice.value.footerUpdate.stream,
                                                    builder: (context, snapshot) {
                                                      if (orderPageBloc.invoices.value.length > 1) {
                                                        return Container(
                                                          height: 50.h,
                                                          decoration: BoxDecoration(
                                                            color: WidgetUtilts.currentSkin.ticketFooter,
                                                            borderRadius: BorderRadius.circular(12.r),
                                                          ),
                                                          child: Container(
                                                            decoration: DottedDecoration(
                                                              linePosition: LinePosition.top,
                                                              strokeWidth: 2,
                                                              color: Colors.white,
                                                            ),
                                                            alignment: Alignment.center,
                                                            padding: EdgeInsetsDirectional.only(start: 10.w, end: 10.w, top: 10.w),
                                                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                              Text(
                                                                "Tickets Total".tr(),
                                                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, height: 1),
                                                              ),
                                                              Text(
                                                                orderPageBloc.invoicesTotal.toCurrency(),
                                                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, height: 1),
                                                              ),
                                                            ]),
                                                          ),
                                                        );
                                                      } else {
                                                        return const SizedBox();
                                                      }
                                                    },
                                                  );
                                                },
                                              )
                                            ],
                                          )
                                        : StreamBuilder(
                                            stream: orderPageBloc.ticketMultiItemSelection.stream,
                                            builder: (ctx, snap) {
                                              return StreamBuilder(
                                                stream: orderPageBloc.invoice.stream,
                                                builder: (context, snapshot) {
                                                  return Ticket(
                                                    380.w,
                                                    multiSelection: orderPageBloc.ticketMultiItemSelection.value,
                                                    invoice: orderPageBloc.invoice.value,
                                                    headerClick: () {
                                                      orderPageBloc.showOrderOptions();
                                                    },
                                                    headerDoubleClick: () {
                                                      orderPageBloc.showNote();
                                                    },
                                                    onSelect: (InvoiceLine line) {
                                                      orderPageBloc.selectLine(line);
                                                    },
                                                    onDelete: (InvoiceLine line) {
                                                      orderPageBloc.deleteLine(line);
                                                    },
                                                    onOptionDelete: (InvoiceLine line, InvoiceLineOption option) {
                                                      orderPageBloc.deleteOption(line, option);
                                                    },
                                                    expandedTicket: () {
                                                      // orderPageBloc.expandedTicket();
                                                    },
                                                    selectableItems: orderPageBloc.selectableItems,
                                                    deleteableItems: orderPageBloc.deleteableItems,
                                                  );
                                                },
                                              );
                                            }),
                                  );
                                }),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  onEnter: (event) {
                                    checkGroupArrows();
                                  },
                                  onExit: (event) {
                                    showGroupLeftArrow.sink.add(false);
                                    showGroupRightArrow.sink.add(false);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 5.h),
                                    height: 132.h,
                                    child: Stack(
                                      children: [
                                        StreamBuilder(
                                            stream: orderPageBloc.sections.stream,
                                            builder: (context, snapshot) {
                                              return PageView.builder(
                                                controller: pageController,
                                                scrollBehavior: MyCustomScrollBehavior(),
                                                onPageChanged: (index) {
                                                  pageIndexController.add(index);
                                                  checkGroupArrows();
                                                },
                                                dragStartBehavior: DragStartBehavior.down,
                                                scrollDirection: Axis.horizontal,
                                                itemCount: (orderPageBloc.sections.value.length / 12).ceil(),
                                                itemBuilder: (context, index) {
                                                  List<Widget> groups = [];
                                                  List<MenuSection> sections = orderPageBloc.sections.value.where((f) => f.index >= (index * 12) && f.index <= ((index + 1) * 12)).take(12).toList();
                                                  sections.sort((a, b) => a.index.compareTo(b.index));
                                                  for (var section in sections) {
                                                    groups.add(GroupButton(
                                                      onTap: () {
                                                        orderPageBloc.selectSection(section);
                                                        // print(orderPageBloc
                                                        //     .sections.value
                                                        //     .indexOf(section));
                                                      },
                                                      isSelected: orderPageBloc.selectedSection.value!.id == section.id,
                                                      fontSize: 20.sp,
                                                      borderColor: HexColor(section.properties.color.borderColor),
                                                      bgColor: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                        HexColor(section.properties.color.colorStart),
                                                        HexColor(section.properties.color.colorEnd)
                                                      ]),
                                                      title: section.name,
                                                    ));
                                                  }
                                                  return GroupView(
                                                    // mainAxisSpacing: 5,
                                                    // crossAxisSpacing: 5,
                                                    // crossAxisCount: 6,
                                                    // childAspectRatio: 4.h,
                                                    children: groups,
                                                  );
                                                },
                                              );
                                            }),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: StreamBuilder<bool>(
                                            stream: showGroupLeftArrow.stream,
                                            initialData: false,
                                            builder: (context, snapshot) {
                                              return AnimatedContainer(
                                                duration: const Duration(milliseconds: 250),
                                                height: double.infinity,
                                                color: Color.fromRGBO(255, 255, 255, (snapshot.data!) ? 0.6 : 0),
                                                width: (snapshot.data!) ? 30 : 0,
                                                child: GestureDetector(
                                                  child: !(snapshot.data!)
                                                      ? const SizedBox()
                                                      : Container(
                                                          height: 15.h,
                                                          width: 15.w,
                                                          color: Colors.white.withOpacity(0.6),
                                                          child: Icon(InvoIcons.left_arrow_next, size: 22.sp),
                                                        ),
                                                  onTap: () async {
                                                    if (pageController.page == 0) {
                                                      return;
                                                    }

                                                    await pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
                                                    checkGroupArrows();
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: StreamBuilder<bool>(
                                            stream: showGroupRightArrow.stream,
                                            initialData: false,
                                            builder: (context, snapshot) {
                                              return AnimatedContainer(
                                                duration: const Duration(milliseconds: 250),
                                                height: double.infinity,
                                                color: Color.fromRGBO(255, 255, 255, (snapshot.data!) ? 0.6 : 0),
                                                width: (snapshot.data!) ? 30 : 0,
                                                child: GestureDetector(
                                                  child: (snapshot.data!)
                                                      ? Container(
                                                          height: 15.h,
                                                          width: 15.w,
                                                          color: Colors.white.withOpacity(0.6),
                                                          child: Icon(InvoIcons.right_arrow_next, size: 22.sp),
                                                        )
                                                      : const SizedBox(),
                                                  onTap: () async {
                                                    await pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
                                                    checkGroupArrows();
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 300.w,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                margin: EdgeInsets.symmetric(horizontal: 10.w),
                                                padding: EdgeInsets.all(10.w),
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.r), color: WidgetUtilts.currentSkin.bgColor),
                                                child: StreamBuilder<OrderPageOptionState>(
                                                    stream: orderPageBloc.orderPageOption.stream,
                                                    builder: (context, snapshot) {
                                                      if (snapshot.data is QuickModifierOption) {
                                                        return modifierOptions((snapshot.data as QuickModifierOption).options);
                                                      } else if (snapshot.data is ItemOption) {
                                                        ItemOption itemOption = snapshot.data as ItemOption;
                                                        return itemOptions(itemOption);
                                                      } else {
                                                        return orderOptions();
                                                      }
                                                      // return optionsWidgets[opt];
                                                    }),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 10.h, left: 10.w, right: 10.w),
                                              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.r), color: WidgetUtilts.currentSkin.bgColor),
                                              child: KeyPad(
                                                (txt) {
                                                  orderPageBloc.qty.set(double.parse(txt));
                                                  focus.requestFocus();
                                                },
                                                key: _globalKeyPadKey,
                                                keyHeight: (300.w - 60.w) / 3,
                                                light: false,
                                                isHalfEnable: orderPageBloc.isHalfEnable,
                                                keypadType: KeyPadType.number,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: StreamBuilder<List<MenuSectionProduct>>(
                                          stream: orderPageBloc.products.stream,
                                          initialData: orderPageBloc.products.value,
                                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                                            return MenuList(
                                              callback: (value) {
                                                orderPageBloc.addProduct(value.product!);
                                              },
                                              loadImage: (productId) async {
                                                return Future.value("");
                                              },
                                              products: orderPageBloc.products.stream,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            StreamBuilder<bool>(
                                stream: extraModifierController.stream,
                                initialData: false,
                                builder: (context, snapshot) {
                                  bottomOption.sink.add(snapshot.data != null ? snapshot.data! : false);
                                  return extraModifiers(snapshot.data != null && snapshot.data == true ? screenHeight : 0);
                                }),
                            StreamBuilder<ProductSelection?>(
                                stream: orderPageBloc.productSelection.stream,
                                initialData: null,
                                builder: (context, snapshot) {
                                  bottomOption.sink.add(snapshot.data != null ? true : false);
                                  return selection(orderPageBloc.productSelection.value, orderPageBloc.productSelection.value == null ? 0 : screenHeight);
                                }),
                            StreamBuilder<OptionGroup?>(
                                stream: orderPageBloc.optionGroup.stream,
                                initialData: null,
                                builder: (context, snapshot) {
                                  bottomOption.sink.add(snapshot.data != null ? true : false);
                                  return optionGroups(orderPageBloc.optionGroup.value, orderPageBloc.optionGroup.value == null ? 0 : screenHeight);
                                }),
                            StreamBuilder<bool?>(
                                stream: holdItemController.stream,
                                initialData: false,
                                builder: (context, snapshot) {
                                  bottomOption.sink.add(snapshot.data != null ? snapshot.data! : false);
                                  return holdItemWidget(snapshot.data != null && snapshot.data == true ? screenHeight : 0);
                                })
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              StreamBuilder<bool>(
                  stream: bottomOption.stream,
                  builder: (context, snapshot) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: snapshot.data != null && snapshot.data == true ? 0 : 80.h,
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      decoration: BoxDecoration(
                        gradient: WidgetUtilts.currentSkin.actionBar,
                      ),
                      child: Row(
                        children: [
                          ActionButton(
                            "Save & Send Order".tr(),
                            onTap: () {
                              orderPageBloc.saveOrder();
                            },
                          ),
                          StreamBuilder(
                            stream: orderPageBloc.invoice.stream,
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if (orderPageBloc.invoice.value.id == "" && orderPageBloc.isDineIn) {
                                return Container(
                                  margin: EdgeInsetsDirectional.only(start: 20.w),
                                  child: ActionButton(
                                    "Save with Auto Hold".tr(),
                                    onTap: () {
                                      orderPageBloc.saveWithAutoHold();
                                    },
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          ActionButton(
                            "Options".tr(),
                            onTap: () {
                              orderPageBloc.showOrderOptions();
                            },
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          StreamBuilder(
                              stream: orderPageBloc.selectedMenu.stream,
                              builder: (context, snapshot) {
                                if (orderPageBloc.selectedMenu.value == null) {
                                  return ActionButton(
                                    "Menu".tr(),
                                    onTap: () {
                                      orderPageBloc.changeMenu();
                                    },
                                  );
                                }

                                return ActionButton(
                                  orderPageBloc.selectedMenu.value!.name,
                                  onTap: () {
                                    orderPageBloc.changeMenu();
                                  },
                                );
                              }),
                          SizedBox(
                            width: 20.w,
                          ),
                          Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 20.w,
                              ),
                              ActionButton(
                                "Back".tr(),
                                icon: InvoIcons.right_arrow_next,
                                onTap: () {
                                  Navigator.pop(context);
                                  orderPageBloc.goBack();
                                },
                              ),

                              /*
                           ActionButton(
  "bbb".tr(),
 
  onTap: () { //print("object");
showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        child:StreamBuilder(
                                              stream: orderPageBloc.selectedAddress.stream,
                                              builder: (context, snapshot) {
                                                if (orderPageBloc.selectedAddress.value ==
                                                    null) return const SizedBox();
                                                return Form(
                                                    key: _addressFormKey,
                                                    child: SingleChildScrollView(
                                                      child: FocusTraversalGroup(
                                                        policy:
                                                            ReadingOrderTraversalPolicy(),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ExcludeFocus(
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 8.h),
                                                                child: Text(
                                                                  "Address Title"
                                                                      .tr(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16.sp,
                                                                      height:
                                                                          1.5),
                                                                ),
                                                              ),
                                                            ),
                                                   
                                                            FocusTraversalOrder(
                                                              order:
                                                                  NumericFocusOrder(
                                                                      0),
                                                              child:
                                                                  AutoCompleteField<
                                                                      String>(
                                                                //key: GlobalKey(),
                                                                optionsBuilder:
                                                                    (textEditingValue) {
                                                                  List<String>
                                                                      list = [
                                                                    "Home",
                                                                    "Office",
                                                                    "Apartment"
                                                                  ];
                                                                  return textEditingValue
                                                                          .text
                                                                          .isEmpty
                                                                      ? list
                                                                      : list.where((f) =>
                                                                          f ==
                                                                          textEditingValue
                                                                              .text);
                                                                },
                                                                initValue: "Home",
                                                                clearBtn: true,
                                                                onClear: () {
                                                                  orderPageBloc
                                                                      .selectedAddress
                                                                      .value!
                                                                      .title = "";
                                                                },
                                                                onSelected:
                                                                    (String
                                                                        value) {
                                                                  orderPageBloc
                                                                      .selectedAddress
                                                                      .value!
                                                                      .title = value;
                                                                },
                                                                onTextChange:
                                                                    (String
                                                                        value) {
                                                                  orderPageBloc
                                                                      .selectedAddress
                                                                      .value!
                                                                      .title = value;
                                                                  //don't update view on text change (no setstate)
                                                                },
                                                                optionsViewBuilder: (BuildContext
  context,
                                                                    AutocompleteOnSelected<
                                                                            String>
                                                                        onSelected,
                                                                    Iterable<
                                                                            String>
                                                                        options) {
                                                                  return Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child:
                                                                        Container(
                                                                      color: Colors
                                                                          .white,
                                                                      child:
                                                                          Container(
                                                                        clipBehavior:
                                                                            Clip.antiAlias,
                                                                        width:
                                                                            350.w,
                                                                        height:
                                                                            150.h,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: Colors
                                                                              .white
                                                                              .withOpacity(0.6),
                                                                          // border: Border.all(
                                                                          //   width: 2,
                                                                          //   color: Color.fromRGBO(190, 190, 190, 1),
                                                                          // ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.r),
                                                                        ),
                                                                        child: ListView
                                                                            .builder(
                                                                          padding:
                                                                              EdgeInsets.all(10.w),
                                                                          itemCount:
                                                                              options.length,
                                                                          itemBuilder:
                                                                              (BuildContext context,
                                                                                  int index) {
                                                                            final String
                                                                                option =
                                                                                options.elementAt(index);
                                                                            return GestureDetector(
                                                                              onTap:
                                                                                  () {
                                                                                onSelected(option);
                                                                                print("ggg");
                                                                              },
                                                                              child:
                                                                                  Text(
                                                                                option,
                                                                                style: TextStyle(color: Colors.black, fontSize: 18.sp, overflow: TextOverflow.ellipsis),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            AddressForm2(
                                                                bloc: orderPageBloc),
                                                            ExcludeFocus(
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 8.h),
                                                                child: Text(
                                                                  "Note".tr(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16.sp,
                                                                      height:
                                                                          1.5),
                                                                ),
                                                              ),
                                                            ),
                                                            CustomTextArea(
                                                              hint: 'Note'.tr(),
                                                              initValue: orderPageBloc
                                                                  .selectedAddress
                                                                  .value!
                                                                  .note,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ));
                                              }));});
  },
),*/
                            ],
                          ))
                        ],
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  checkGroupArrows() {
    double current = pageController.page!.toDouble();
    if (current > 0) {
      showGroupLeftArrow.sink.add(true);
    } else {
      showGroupLeftArrow.sink.add(false);
    }

    if (current < (orderPageBloc.sections.value.length / 12).floor()) {
      showGroupRightArrow.sink.add(true);
    } else {
      showGroupRightArrow.sink.add(false);
    }
  }

  Widget orderOptions() {
    return GridView.count(
      controller: _optionsController,
      crossAxisSpacing: 7,
      mainAxisSpacing: 7,
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: 300.w / 145.h,
      children: [
        if (!orderPageBloc.isDineIn && orderPageBloc.invoice.value.id == "")
          OptionButton(
            "Schedule Order".tr(),
            maxlines: 2,
            lineHeight: 1.2,
            fontSize: 20.sp,
            onTap: () {
              orderPageBloc.scheduleOrder();
            },
          ),
        OptionButton(
          "Add Note".tr(),
          maxlines: 2,
          lineHeight: 1.2,
          fontSize: 20.sp,
          onTap: (() => orderPageBloc.showNote()),
        ),
        /*OptionButton(
          "Adj Guests".tr(),
          maxlines: 2,
          lineHeight: 1.2,
          fontSize: 20.sp,
          onTap: (() => orderPageBloc.adjGuests()),
        ),*/
        OptionButton(
          "Discount Order".tr(),
          maxlines: 2,
          lineHeight: 1.2,
          fontSize: 20.sp,
          onTap: (() => orderPageBloc.showDiscountDialog()),
        ),
        OptionButton(
          "Surcharge".tr(),
          maxlines: 2,
          fontSize: 20.sp,
          onTap: (() => orderPageBloc.showSurchargeDialog()),
        ),
        if (orderPageBloc.invoice.value.id != "")
          OptionButton(
            "Void Ticket".tr(),
            maxlines: 2,
            lineHeight: 1.2,
            fontSize: 20.sp,
            onTap: () {
              orderPageBloc.voidTicket();
            },
          ),
        OptionButton(
          "Search Item".tr(),
          maxlines: 2,
          lineHeight: 1.2,
          fontSize: 20.sp,
          onTap: () async {
            orderPageBloc.searchProducts(orderPageBloc.branch.id);
          },
        ),
        _currentService == "cdb1e4d4-4fcf-4560-a33e-62cace1027cd"
            ? OptionButton(
                "Add/Change Address".tr(),
                fontSize: 20.sp,
                lineHeight: 1.2,
                maxlines: 2,
                onTap: (() => orderPageBloc.editAddress()),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget modifierOptions(List<Option> options) {
    List<Widget> widgets = [];
    for (var element in options) {
      widgets.add(OptionButton(
        element.getTranslatedName(WidgetUtilts.getCurrentLang),
        maxlines: 2,
        onTap: () {
          orderPageBloc.optionClicked(element);
        },
        fontSize: 20.sp,
      ));
    }
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            controller: _optionsController,
            crossAxisSpacing: 7,
            mainAxisSpacing: 7,
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 300.w / 145.h,
            children: widgets,
          ),
        ),
        SizedBox(
          height: 60.h,
          child: Row(
            children: [
              Expanded(
                child: OptionButton(
                  "Extra Modifiers".tr(),
                  fontSize: 20.sp,
                  maxlines: 2,
                  lineHeight: 1.2,
                  onTap: () {
                    extraModifierController.add(true);
                  },
                ),
              ),
              SizedBox(
                width: 7.w,
              ),
              Expanded(
                child: OptionButton(
                  "Short Note".tr(),
                  fontSize: 20.sp,
                  maxlines: 2,
                  lineHeight: 1.2,
                  // onTap: (() => orderPageBloc.shortNote()),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget itemOptions(ItemOption itemOption) {
    bool isNew = itemOption.line.id == "";
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            controller: _optionsController,
            crossAxisSpacing: 7,
            mainAxisSpacing: 7,
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 300.w / 145.h,
            children: [
              if (isNew)
                OptionButton(
                  "Increase Qty".tr(),
                  maxlines: 2,
                  lineHeight: 1.2,
                  onTap: () {
                    orderPageBloc.increaseQty();
                  },
                  fontSize: 20.sp,
                ),
              if (isNew)
                OptionButton(
                  "Decrease Qty".tr(),
                  maxlines: 2,
                  lineHeight: 1.2,
                  onTap: () {
                    orderPageBloc.decreaseQty();
                  },
                  fontSize: 20.sp,
                ),
              // OptionButton(
              //   "Adj Price".tr(),
              //   maxlines: 2,
              //   lineHeight: 1.2,
              //   fontSize: 20.sp,
              //   onTap: () {
              //     orderPageBloc.adjPrice();
              //   },
              // ),
              OptionButton(
                "Adj Qty".tr(),
                maxlines: 2,
                lineHeight: 1.2,
                fontSize: 20.sp,
                onTap: () {
                  orderPageBloc.adjQty();
                },
              ),
              OptionButton(
                "Discount Item".tr(),
                maxlines: 2,
                lineHeight: 1.2,
                fontSize: 20.sp,
                onTap: (() => orderPageBloc.showItemDicount()),
              ),
              OptionButton(
                "ReOrder".tr(),
                maxlines: 2,
                fontSize: 20.sp,
                onTap: () => orderPageBloc.reOrder(),
              ),
              if (isNew && orderPageBloc.isDineIn)
                OptionButton(
                  "Hold Item".tr(),
                  lineHeight: 1.2,
                  fontSize: 20.sp,
                  onTap: () {
                    holdItemController.add(true);
                  },
                ),
              if (orderPageBloc.isDineIn)
                (isNew && itemOption.line.holdTime == null)
                    ? OptionButton(
                        "Hold Until Fire".tr(),
                        maxlines: 2,
                        onTap: () {
                          orderPageBloc.holdUntilFire();
                        },
                        lineHeight: 1.2,
                        fontSize: 20.sp,
                      )
                    : (itemOption.line.holdTime != null && itemOption.line.holdTime!.year == 9999)
                        ? OptionButton(
                            "Fire".tr(),
                            maxlines: 2,
                            onTap: () {
                              orderPageBloc.fireHoldItem();
                            },
                            lineHeight: 1.2,
                            fontSize: 20.sp,
                          )
                        : const SizedBox(),
            ],
          ),
        ),
        SizedBox(
          height: 60.h,
          child: Row(
            children: [
              Expanded(
                child: OptionButton(
                  "Extra Modifiers".tr(),
                  maxlines: 2,
                  fontSize: 20.sp,
                  lineHeight: 1.2,
                  onTap: () {
                    extraModifierController.add(true);
                  },
                ),
              ),
              SizedBox(
                width: 7.w,
              ),
              Expanded(
                child: OptionButton(
                  "Short Note".tr(),
                  fontSize: 20.sp,
                  lineHeight: 1.2,
                  maxlines: 2,
                  onTap: (() => orderPageBloc.shortNote()),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // Widget ticketHeaderClickedOptions() {
  //   return GridView.count(
  //     controller: _optionsController,
  //     crossAxisSpacing: 7,
  //     mainAxisSpacing: 7,
  //     crossAxisCount: 2,
  //     shrinkWrap: true,
  //     childAspectRatio: 300.w / 145.h,
  //     children: [
  //       OptionButton(
  //         "Split Ticket".tr(),
  //         maxlines: 2,
  //         fontSize: 20.sp,
  //         onTap: () {
  //           Utilts.mainPageNavigationKey.currentState!.pushNamed("SpilitOrder");
  //         },
  //       ),
  //       OptionButton(
  //         "Merge Order".tr(),
  //         fontSize: 20.sp,
  //         onTap: () {
  //           Utilts.mainPageNavigationKey.currentState!.pushNamed("MergeOrder");
  //         },
  //       ),
  //       if (!orderPageBloc.isDineIn && orderPageBloc.invoice.value.id == "")
  //         OptionButton(
  //           "Schedule At".tr(),
  //           maxlines: 2,
  //           fontSize: 20.sp,
  //         ),
  //       OptionButton(
  //         "Add/Change Customer".tr(),
  //         fontSize: 20.sp,
  //         lineHeight: 1.0,
  //         maxlines: 2,
  //         onTap: (() => orderPageBloc.showCustomersList()),
  //       ),
  //       OptionButton(
  //         "Change Server".tr(),
  //         maxlines: 2,
  //         fontSize: 20.sp,
  //         onTap: () {
  //           orderPageBloc.changeEmployee();
  //         },
  //       ),
  //       OptionButton(
  //         "Add Note".tr(),
  //         maxlines: 2,
  //         fontSize: 20.sp,
  //         onTap: (() => orderPageBloc.showNote()),
  //       ),
  //       OptionButton(
  //         "Search Item".tr(),
  //         maxlines: 2,
  //         fontSize: 20.sp,
  //         onTap: () {
  //           orderPageBloc.searchProducts();
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget extraModifiers(double height) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: EdgeInsetsDirectional.only(start: 10.w),
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10.r))),
      child: Column(children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          margin: EdgeInsets.only(bottom: 15.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Extra Modifiers".tr(),
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 350.w,
                child: SizedBox(
                  child: CustomTextField(
                    hint: 'Search ...'.tr(),
                    callback: (txt) {
                      extraModifierSearch.sink.add(txt);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                child: StreamBuilder<Object>(
                    stream: extraModifierSearch.stream,
                    builder: (context, snapshot) {
                      List<Option> options = (snapshot.data == null || snapshot.data == "") ? orderPageBloc.options.where((element) => element.isVisible).toList() : orderPageBloc.options.where((f) => f.isVisible && f.name.contains(snapshot.data.toString())).toList();

                      return Wrap(
                        spacing: 15.w,
                        runSpacing: 15.h,
                        children: [
                          for (var element in options)
                            SizedBox(
                              width: 200.w,
                              height: 100.h,
                              child: ExtraModifierButton(
                                element.name,
                                onTap: () {
                                  orderPageBloc.optionClicked(element);
                                },
                                fontSize: 25.sp,
                              ),
                            )
                        ],
                      );
                    }),
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
                          extraModifierController.add(false);
                        },
                      ),
                      OptionButton(
                        "Finish".tr(),
                        lineHeight: 1.2,
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                        fontSize: 20.sp,
                        style: "primary",
                        onTap: () {
                          extraModifierController.add(false);
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
    );
  }

  Widget holdItemWidget(double height) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: EdgeInsetsDirectional.only(start: 10.w),
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10.r))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          margin: EdgeInsets.symmetric(vertical: 25.h),
          child: Text(
            "Hold Item".tr(),
            style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold),
          ),
        ),
        Divider(
          height: 1.h,
        ),
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            "Hold For".tr(),
            style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 150,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Wrap(
              spacing: 25.0, // gap between adjacent chips
              runSpacing: 15.0, // gap between lines
              children: [
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "5m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(5);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "10m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(10);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "15m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(15);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "20m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(20);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "25m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(25);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "30m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(30);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "40m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(40);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "45m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(45);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "60m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(60);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "1h 10m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(70);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "1h 15m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(75);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "1h 20m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(80);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "1h 30m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(90);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "1h 40m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(100);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "1h 45m",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(105);
                      holdItemController.add(false);
                    },
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: OptionButton(
                    "2h",
                    lineHeight: 1.2,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    fontSize: 20.sp,
                    style: "primary",
                    onTap: () {
                      orderPageBloc.holdItemFor(120);
                      holdItemController.add(false);
                    },
                  ),
                ),
              ]),
        ),
        Divider(
          height: 1.h,
        ),
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          margin: EdgeInsets.symmetric(vertical: 25.h),
          child: Text(
            "Hold Until".tr(),
            style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w),
          height: 150,
          child: StreamBuilder(
              stream: orderPageBloc.holdUntil.stream,
              builder: (context, snapshot) {
                List<Widget> widgets = [];
                for (var element in orderPageBloc.holdUntil.value) {
                  widgets.add(
                    SizedBox(
                      width: 140.w,
                      child: OptionButton(
                        DateFormat("HH:mm").format(element),
                        lineHeight: 1.2,
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                        fontSize: 20.sp,
                        style: "primary",
                        onTap: () {
                          orderPageBloc.hold(element);
                          holdItemController.add(false);
                        },
                      ),
                    ),
                  );
                }

                return Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 25.0, // gap between adjacent chips
                    runSpacing: 15.0, // gap between lines
                    children: widgets);
              }),
        ),
        Divider(
          height: 1.h,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          margin: EdgeInsets.only(top: 25.h),
          child: Text(
            "Hold With Preperation Time".tr(),
            style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          margin: EdgeInsets.only(bottom: 25.h),
          child: Text(
            "Hold Item Until specific time and consider the preperation time of the item".tr(),
            style: TextStyle(fontSize: 18.sp),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: StreamBuilder(
              stream: orderPageBloc.holdUntil.stream,
              builder: (context, snapshot) {
                List<Widget> widgets = [];
                for (var element in orderPageBloc.holdUntil.value) {
                  widgets.add(
                    SizedBox(
                      width: 140.w,
                      child: OptionButton(
                        DateFormat("HH:mm").format(element),
                        lineHeight: 1.2,
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                        fontSize: 20.sp,
                        style: "primary",
                        onTap: () {
                          orderPageBloc.holdWithPreperationTime(element);
                          holdItemController.add(false);
                        },
                      ),
                    ),
                  );
                }

                return Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 25.0, // gap between adjacent chips
                    runSpacing: 15.0, // gap between lines
                    children: widgets);
              },
            ),
          ),
        ),
        // Expanded(
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.stretch,
        //     children: [
        //       Expanded(
        //         child: Padding(
        //           padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w),
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [],
        //           ),
        //         ),
        //       ),
        //       // Padding(
        //       //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //       //   child: VerticalDivider(
        //       //     width: 1.h,
        //       //   ),
        //       // ),
        //       // Theme(
        //       //   data: Theme.of(context).copyWith(
        //       //       timePickerTheme: TimePickerThemeData(
        //       //     backgroundColor: Colors.white,
        //       //     // hourMinuteShape: const RoundedRectangleBorder(
        //       //     //   borderRadius: BorderRadius.all(Radius.circular(8)),
        //       //     //   side: BorderSide(color: Color.fromRGBO(26, 115, 231, 1), width: 4),
        //       //     // ),
        //       //     // dayPeriodBorderSide:
        //       //     //     const BorderSide(color: Color.fromRGBO(26, 115, 231, 1), width: 4),
        //       //     dayPeriodColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected)
        //       //         ?WidgetUtilts.currentSkin.lightenPrimaryColor
        //       //         : Colors.transparent),
        //       //     // shape: const RoundedRectangleBorder(
        //       //     //   borderRadius: BorderRadius.all(Radius.circular(8)),
        //       //     //   side: BorderSide(color: Color.fromRGBO(26, 115, 231, 1), width: 4),
        //       //     // ),
        //       //     dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
        //       //         states.contains(MaterialState.selected) ?WidgetUtilts.currentSkin.primaryColor : Colors.grey),
        //       //     // dayPeriodShape: const RoundedRectangleBorder(
        //       //     //   borderRadius: BorderRadius.all(Radius.circular(8)),
        //       //     //   side: BorderSide(color: Color.fromRGBO(26, 115, 231, 1), width: 4),
        //       //     // ),
        //       //     hourMinuteColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected)
        //       //         ?WidgetUtilts.currentSkin.lightenPrimaryColor
        //       //         : Color.fromRGBO(225, 222, 226, 1)),
        //       //     hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
        //       //         states.contains(MaterialState.selected) ?WidgetUtilts.currentSkin.primaryColor : Colors.black),
        //       //     dialBackgroundColor: Colors.white,
        //       //     hourMinuteTextStyle: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        //       //     dayPeriodTextStyle: TextStyle(
        //       //       fontSize: 20,
        //       //     ),
        //       //     // helpTextStyle:
        //       //     //     const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        //       //     // inputDecorationTheme: const InputDecorationTheme(
        //       //     //   border: InputBorder.none,
        //       //     //   contentPadding: EdgeInsets.all(0),
        //       //     //   fillColor: Colors.red,
        //       //     // ),

        //       //     // dialTextColor: MaterialStateColor.resolveWith((states) =>
        //       //     //     states.contains(MaterialState.selected)
        //       //     //         ? Color.fromRGBO(26, 115, 231, 1)
        //       //     //         : Colors.white),
        //       //     // entryModeIconColor: Color.fromRGBO(26, 115, 231, 1),
        //       //   )),
        //       //   child: TimePickerDialog(
        //       //     initialTime: TimeOfDay.now(),
        //       //     cancelText: "",
        //       //     initialEntryMode: TimePickerEntryMode.dialOnly,
        //       //   ),
        //       // ),
        //     ],
        //   ),
        // ),
        Container(
          height: 85.h,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          decoration: const BoxDecoration(color: Color.fromRGBO(238, 238, 238, 1), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
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
                  holdItemController.add(false);
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget optionGroups(OptionGroup? group, double height) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: EdgeInsetsDirectional.only(start: 10.w),
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10.r))),
      child: Column(children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          margin: EdgeInsets.only(bottom: 15.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                group == null ? "" : group.title,
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 15.w,
                  runSpacing: 15.h,
                  children: [
                    if (group != null)
                      for (var element in group.options.where((f) => f.option != null))
                        SizedBox(
                          width: 200.w,
                          height: 100.h,
                          child: ExtraModifierButton(
                            element.option!.getTranslatedName(WidgetUtilts.getCurrentLang),
                            onTap: () {
                              orderPageBloc.popUpOptionClicked(group, element.option!);
                            },
                            fontSize: 25.sp,
                          ),
                        )
                  ],
                ),
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
                      StreamBuilder(
                        stream: orderPageBloc.optionGroupIndex.stream,
                        initialData: 0,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (orderPageBloc.optionGroupIndex.value == 0) {
                            return OptionButton(
                              "Cancel".tr(),
                              lineHeight: 1.2,
                              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                              fontSize: 20.sp,
                              style: "primary",
                              onTap: () {
                                orderPageBloc.cancelOptionGroup();
                              },
                            );
                          } else {
                            return OptionButton(
                              "Back".tr(),
                              lineHeight: 1.2,
                              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                              fontSize: 20.sp,
                              style: "primary",
                              onTap: () {
                                Navigator.pop(context);
                                orderPageBloc.backOptionGroup();
                              },
                            );
                          }
                        },
                      ),
                      StreamBuilder(
                        stream: orderPageBloc.optionFinish.stream,
                        initialData: false,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          // if (group != null &&
                          //     orderPageBloc.optionSelected >=
                          //         group.minSelectable) {
                          //   return OptionButton(
                          //     "Finish".tr(),
                          //     lineHeight: 1.2,
                          //     padding: EdgeInsets.symmetric(
                          //         vertical: 10.h, horizontal: 20.w),
                          //     fontSize: 20.sp,
                          //     style: "primary",
                          //     onTap: () {
                          //       orderPageBloc.finishOptionGroup();
                          //     },
                          //   );
                          // }
                          return const SizedBox();
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
    );
  }

  Widget selection(ProductSelection? selection, double height) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: EdgeInsets.only(left: 10.w),
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10.r))),
      child: Column(children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          margin: EdgeInsets.only(bottom: 15.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Choose Item".tr(),
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 15.w,
                  runSpacing: 15.h,
                  children: [
                    if (selection != null)
                      for (var element in selection.items.where((f) => f.product != null))
                        SizedBox(
                          width: 200.w,
                          height: 100.h,
                          child: ExtraModifierButton(
                            element.product!.getTranslatedName(WidgetUtilts.getCurrentLang),
                            onTap: () {
                              orderPageBloc.addSubItem(element.product!);
                            },
                            fontSize: 25.sp,
                          ),
                        )
                  ],
                ),
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
                      StreamBuilder(
                        stream: orderPageBloc.productSelectionIndex.stream,
                        initialData: 0,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (orderPageBloc.productSelectionIndex.value == 0) {
                            return OptionButton(
                              "Cancel".tr(),
                              lineHeight: 1.2,
                              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                              fontSize: 20.sp,
                              style: "primary",
                              onTap: () {
                                orderPageBloc.cancelMenuSelection();
                              },
                            );
                          } else {
                            return OptionButton(
                              "Back".tr(),
                              lineHeight: 1.2,
                              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                              fontSize: 20.sp,
                              style: "primary",
                              onTap: () {
                                Navigator.pop(context);
                                orderPageBloc.backMenuSelection();
                              },
                            );
                          }
                        },
                      ),
                      OptionButton(
                        "Finish".tr(),
                        lineHeight: 1.2,
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                        fontSize: 20.sp,
                        style: "primary",
                        onTap: () {
                          orderPageBloc.finishMenuSelection();
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
    );
  }
}
