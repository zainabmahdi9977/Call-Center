// ignore_for_file: file_names

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

import 'package:invo_5_widget/invo_5_widget.dart';
import 'package:invo_models/invo_models.dart';

import 'package:newcall_center/blocs/customer.page.bloc.dart';

import 'package:resize/resize.dart';

class PurchaseHistory extends StatefulWidget {
  final CustomerPageBloc bloc;

  const PurchaseHistory({super.key, required this.bloc});

  @override
  State<PurchaseHistory> createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  String vType = "grid";
  final StreamController<String> vTypeController = StreamController<String>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
              width: 380.w,
              child: StreamBuilder(
                  stream: widget.bloc.order.stream,
                  builder: (context, snapshot) {
                    if (widget.bloc.order.value == null) {
                      return Container(
                        color: Colors.transparent,
                      );
                    }
                    return Ticket(
                      380.w,
                      key: GlobalKey(),
                      invoice: widget.bloc.order.value!,
                      selectableItems: false,
                    );
                  })),
          Container(
              width: 220.w,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.r), color: WidgetUtilts.currentSkin.bgColor),
              child: SingleChildScrollView(
                child: StreamBuilder(
                    stream: widget.bloc.order.stream, // widget.bloc.order.stream,
                    builder: (context, snapshot) {
                      if (widget.bloc.order.value != null) {
                        Invoice order = widget.bloc.order.value!;
                        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          SizedBox(
                            height: 60.h,
                            child: OptionButton(
                              "ReOrder".tr(),
                              fontSize: 22.sp,
                              margin: EdgeInsets.only(bottom: 10.h),
                              onTap: () {
                                widget.bloc.reOrder();
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          if (order.isEditVisible)
                            Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              height: 60.h,
                              child: OptionButton(
                                "Edit Order".tr(),
                                fontSize: 22.sp,
                                margin: EdgeInsets.only(bottom: 10.h),
                                onTap: () {
                                  widget.bloc.editOrder();
                                },
                              ),
                            ),

                          // SizedBox(
                          //   height: 60.h,
                          //   child: OptionButton(
                          //     fontSize: 22.sp,
                          //     "Send Email".tr(),
                          //     margin: EdgeInsets.only(bottom: 10.h),
                          //   ),
                          // ),
                        ]);
                      }
                      return const SizedBox();
                    }),
              )),
          Expanded(
              child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order List".tr(),
                          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, height: 1),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.all(0),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                          ),
                          child: StreamBuilder(
                              stream: vTypeController.stream,
                              builder: (context, snapshot) {
                                return Ink(
                                    height: 45.h,
                                    width: 45.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: WidgetUtilts.currentSkin.lightButton,
                                    ),
                                    child: Icon(
                                      vType == "list" ? Icons.grid_view : Icons.list,
                                      size: 25.sp,
                                      color: WidgetUtilts.currentSkin.lightButtonText,
                                    ));
                              }),
                          onPressed: () async {
                            if (vType == "list") {
                              vType = "grid";
                              vTypeController.sink.add("grid");
                            } else {
                              vType = "list";
                              vTypeController.sink.add("list");
                            }
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: widget.bloc.orders.stream,
                        initialData: widget.bloc.orders.value,
                        builder: (context, snapshot) {
                          if (snapshot.data!.isEmpty) {
                            return const Center(
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: AspectRatio(
                                  aspectRatio: 1.0, // This makes the widget maintain a square aspect ratio
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }

                          final invoices = List<InvoiceMini>.from(widget.bloc.orders.value);
                          invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                          return StreamBuilder(
                            stream: vTypeController.stream,
                            initialData: const [],
                            builder: (context, snapshot) {
                              if (vType == "grid") {
                                return GridViewOrders(
                                  orders: invoices,
                                  onTab: (order) {
                                    widget.bloc.selectInvoice(order);
                                  },
                                );
                              } else {
                                return ListViewOrders(
                                  orders: invoices,
                                  onTab: (order) {
                                    widget.bloc.selectInvoice(order);
                                  },
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                  ],
                )),
                Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10)), color: const Color.fromRGBO(247, 247, 247, 1), border: Border.all(width: 1.w, color: const Color.fromRGBO(215, 215, 215, 1))),
                  child: StreamBuilder(
                      stream: widget.bloc.orders.stream, //widget.bloc.orders.stream,
                      builder: (context, snapshot) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${"Total Sale".tr()}:",
                                  style: const TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  widget.bloc.totalSale.toCurrency(),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "${"Total Order".tr()}:",
                                  style: const TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  widget.bloc.totalOrder.toString(),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "${"Avg Order".tr()}:",
                                  style: const TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  widget.bloc.avgOrder.toCurrency(),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ],
                        );
                      }),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
