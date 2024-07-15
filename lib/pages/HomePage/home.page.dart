import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:invo_5_widget/invo_5_widget.dart';
import 'package:invo_models/invo_models.dart';
import 'package:newcall_center/blocs/home.page.bloc.dart';

import 'package:resize/resize.dart';

import '../../models/branch.models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageBloc bloc;
  TabController? _tabController;
  final ScrollController _optionsController = ScrollController();
  // final _key = GlobalKey();

  late FocusNode focus;
  // late RecallPageBloc bloc;

  var tickets = <Map<String, dynamic>>[
    {
      "status": "Open".tr(),
      "color": const Color.fromRGBO(85, 110, 230, 1)
    },
    {
      "status": "Delivered".tr(),
      "color": const Color.fromRGBO(85, 110, 230, 1)
    },
    {
      "status": "Void".tr(),
      "color": const Color(0xffdc3545)
    },
    {
      "status": "Paid".tr(),
      "color": const Color.fromRGBO(116, 183, 46, 1)
    },
    {
      "status": "Merged".tr(),
      "color": const Color(0xffdc3545)
    },
    {
      "status": "Partially Paid".tr(),
      "color": const Color.fromRGBO(241, 180, 76, 1)
    },
    {
      "status": "Complimentary".tr(),
      "color": const Color(0xff17a2b8)
    },
  ];

  String vType = "grid";
  final StreamController<String> vTypeController = StreamController<String>.broadcast();

  double firstCol = 332;
  double keyBtnH = 100;

  bool isPickup = false;
  bool isDelivery = false;

  @override
  void initState() {
    super.initState();
    // bloc = widget.bloc;
    bloc = HomePageBloc();
    focus = FocusNode();
    firstCol = 400.w;
    keyBtnH = ((firstCol - 40.w) / 3);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
    _optionsController.dispose();
    bloc.dispose();
  }

// This function is trggered somehow after build() called
  @override
  Widget build(BuildContext context) {
    bloc.telephone = '';
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: firstCol,
                    child: StreamBuilder(
                      stream: bloc.invoice.stream,
                      initialData: null,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // if (bloc.orderState.value is OrderIsLoaded) {
                        // OrderIsLoaded state = snapshot.data;
                        if (bloc.invoice.value != null) {
                          String branchName = bloc.branches.value.firstWhere((element) => element.id == bloc.invoice.value!.branchId).name;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: WidgetUtilts.currentSkin.ticketBg,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0), // Adjust the radius as needed
                                  ),
                                ),
                                //color: WidgetUtilts.currentSkin.ticketBg,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      const Text('Branch: ', style: TextStyle(fontSize: 18, height: 1.5)),
                                      Text(
                                        branchName,
                                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, height: 1.5.h),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Expanded(
                                child: Ticket(
                                  firstCol,
                                  key: GlobalKey(),
                                  invoice: bloc.invoice.value!, //bloc.invoice.value.branchId
                                  // invoice: state.invoice,
                                  expandedTicket: () {
                                    // bloc.expandedTicket();
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 70.h,
                                child: Padding(
                                  padding: const EdgeInsets.all(10), // Add horizontal padding
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OptionButton(
                                          "New".tr(),
                                          fontSize: 18.sp,
                                          margin: EdgeInsets.only(top: 10.h, right: 5),
                                          onTap: () {
                                            bloc.showKeyPad();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      if (bloc.invoiceStatus == "Open")
                                        Expanded(
                                          child: OptionButton(
                                            "Edit".tr(),
                                            fontSize: 18.sp,
                                            margin: EdgeInsets.only(top: 10.h, right: 5),
                                            onTap: () {
                                              bloc.editInvoice();
                                              bloc.showKeyPad();
                                            },
                                          ),
                                        ),
                                      const SizedBox(width: 5),
                                      if (bloc.invoiceStatus == "Open")
                                        Expanded(
                                          child: OptionButton(
                                            "Void".tr(),
                                            fontSize: 18.sp,
                                            margin: EdgeInsets.only(top: 10.h),
                                            onTap: () {
                                              bloc.voidInvoice();
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return Container(
                          // margin: EdgeInsets.symmetric(horizontal: 5.w),
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.r), color: WidgetUtilts.currentSkin.bgColor),
                          child: Stack(
                            fit: StackFit.expand,
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RepaintBoundary(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    StreamBuilder<String>(
                                      stream: bloc.phoneNumber.stream,
                                      initialData: bloc.phoneNumber.value,
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          //  return CircularProgressIndicator();
                                        }
                                        final initValue = snapshot.data ?? "";
                                        if (initValue.isEmpty) {
                                          bloc.reset();
                                          bloc.go();
                                        } else {
                                          bloc.updateTelephone(initValue);
                                          bloc.customerContact = initValue;
                                          bloc.loadOrdersInvoiceMini();
                                        }

                                        return KeyPad(
                                          (txt) {
                                            bloc.updateTelephone(txt);
                                            focus.requestFocus();

                                            if (txt.isEmpty) {
                                              bloc.reset();
                                            } else {
                                              bloc.updateTelephone(txt);
                                              focus.requestFocus();
                                              bloc.customerContact = txt;
                                            }

                                            bloc.searchWithDebounce();
                                          },
                                          initValue: initValue,
                                          keyHeight: keyBtnH,
                                          keypadType: KeyPadType.number,
                                          light: false,
                                        );
                                      },
                                    )

                                    //           },
                                    //           // disabled:
                                    //           //     bloc.telephone.value.isEmpty
                                    //           //         ? true
                                    //           //         : false,
                                    //         ),
                                    //       );
                                    //     }),
                                  ],
                                ),
                              ),
                              RepaintBoundary(
                                child: Align(
                                  //Delivery or pickup
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    height: 330.h,
                                    child: StreamBuilder(
                                        stream: bloc.services.stream,
                                        initialData: bloc.services.value,
                                        builder: (context, snapshot) {
                                          return GridView.builder(
                                            itemCount: bloc.services.value.length,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 5,
                                              crossAxisSpacing: 5,
                                              childAspectRatio: 2.3,
                                            ),
                                            itemBuilder: (context, index) => SizedBox(
                                              height: 70.h,
                                              child: OptionButton(
                                                bloc.services.value[index].name,
                                                fontSize: 22.sp,
                                                margin: EdgeInsets.only(bottom: 10.h),
                                                onTap: () {
                                                  bloc.loadCustomer(context, bloc.services.value[index]);
                                                },
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(builder: (context, constraints) {
                        //final maxWidth = constraints.maxWidth;
                        //final maxHeight = constraints.maxHeight;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 7.0),
                              child: SizedBox(
                                height: 50.h,
                                child: StreamBuilder(
                                    stream: bloc.updateFilter.stream,
                                    builder: (context, snapshot) {
                                      return Row(
                                        // scrollDirection: Axis.horizontal,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: SizedBox(
                                              width: 280.w,
                                              child: DropDownMenu<Employee>(
                                                [
                                                  bloc.allEmployee,
                                                  ...bloc.employees.value,
                                                ].map<DropdownMenuItem<Employee>>((Employee value) {
                                                  return DropdownMenuItem<Employee>(
                                                    value: value,
                                                    child: Text(
                                                      value.name,
                                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 20.sp, color: const Color.fromRGBO(0, 0, 0, 1), height: 1.5),
                                                    ),
                                                  );
                                                }).toList(),
                                                selectedValue: bloc.allEmployee,
                                                iconColor: const Color.fromRGBO(146, 146, 146, 1),
                                                color: const Color.fromRGBO(255, 255, 255, 1),
                                                borderColor: const Color.fromRGBO(215, 215, 215, 1),
                                                hint: 'Select Servers',
                                                onChanged: (employee) {
                                                  if (employee != null) {
                                                    bloc.selectedEmployeeId = employee.id;
                                                    bloc.loadOrdersInvoiceMini();
                                                  } else {
                                                    bloc.selectedEmployeeId = null;
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: SizedBox(
                                              width: 280.w,
                                              child: DropDownMenu<String?>(
                                                [
                                                  DropdownMenuItem<String?>(
                                                    value: null,
                                                    child: Text(
                                                      "All Branches".tr(),
                                                      style: TextStyle(fontFamily: 'Cairo', fontSize: 20.sp, color: const Color.fromRGBO(0, 0, 0, 1), height: 1.5),
                                                    ),
                                                  ),
                                                  ...bloc.branches.value.map<DropdownMenuItem<String?>>((Branch value) {
                                                    return DropdownMenuItem<String?>(
                                                      value: value.id,
                                                      child: Text(
                                                        value.name,
                                                        style: TextStyle(fontFamily: 'Cairo', fontSize: 20.sp, color: const Color.fromRGBO(0, 0, 0, 1), height: 1.5),
                                                      ),
                                                    );
                                                  })
                                                ],
                                                selectedValue: bloc.selectedBranchId,
                                                iconColor: const Color.fromRGBO(146, 146, 146, 1),
                                                color: const Color.fromRGBO(255, 255, 255, 1),
                                                borderColor: const Color.fromRGBO(215, 215, 215, 1),
                                                hint: 'Select Branches',
                                                onChanged: (branchId) {
                                                  bloc.selectedBranchId = branchId;

                                                  bloc.loadOrdersInvoiceMini();
                                                },
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: SizedBox(
                                              width: 280.w,
                                              child: DropDownMenu<String?>([
                                                DropdownMenuItem<String?>(
                                                  value: null,
                                                  child: Text(
                                                    "All Tickets",
                                                    style: TextStyle(fontFamily: 'Cairo', fontSize: 20.sp, color: const Color.fromRGBO(0, 0, 0, 1), height: 1.5),
                                                  ).tr(),
                                                ),
                                                ...tickets.map<DropdownMenuItem<String?>>((ticket) {
                                                  return DropdownMenuItem<String?>(
                                                    value: ticket["status"],
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          height: 30,
                                                          width: 30,
                                                          color: ticket["color"],
                                                        ),
                                                        const SizedBox(width: 10), // Add spacing between color box and text
                                                        Expanded(
                                                          child: Text(
                                                            ticket["status"],
                                                            style: TextStyle(
                                                              fontFamily: 'Cairo',
                                                              fontSize: 20.sp,
                                                              color: const Color.fromRGBO(0, 0, 0, 1),
                                                              height: 1.5,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ], selectedValue: bloc.selectedTicket ?? "Open".tr(), iconColor: const Color.fromRGBO(146, 146, 146, 1), color: const Color.fromRGBO(255, 255, 255, 1), borderColor: const Color.fromRGBO(215, 215, 215, 1), hint: 'New/Sent', onChanged: (ticket) {
                                                bloc.selectedTicket = ticket;
                                                bloc.loadOrdersInvoiceMini();
                                              }),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: SizedBox(
                                                width: 380.w,
                                                height: 70.h,
                                                child: CustomTextField(
                                                    hint: "Filter tickets".tr(),
                                                    callback: (valure) {
                                                      bloc.filter = valure;
                                                    })),
                                          ),
                                        ],
                                      );
                                    }),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 60.h,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                                        child: ExtraModifierButton(
                                          "GO".tr(),
                                          fontSize: 23.sp,
                                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                                          onTap: () {
                                            bloc.go();
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                                        child: ExtraModifierButton(
                                          "Reset".tr(),
                                          fontSize: 23.sp,
                                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                                          onTap: () {
                                            bloc.reset();
                                            bloc.go();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(top: 15.h),
                              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.r)),
                              child: StreamBuilder(
                                  stream: bloc.orders.stream,
                                  initialData: bloc.orders.value,
                                  builder: (context, snapshot) {
                                    return GridViewOrders(
                                        crossAxisCount: 4,
                                        orders: bloc.orders.value,
                                        showServiceName: true,
                                        showBranchName: true,
                                        showSyncToBranch: true,
                                        onTab: (order) {
                                          bloc.selectInvoice(order);
                                        });
                                  })))
                    ],
                  ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

/*bool _isVoidOrComplimentary() {
  if (bloc.invoice.value != null) {
    final invoiceStatus = bloc.invoice.value!.calculateInvoiceStatus;
    return invoiceStatus == "Void" || invoiceStatus == "Complimentary";
  }  print(bloc.invoice.value!.calculateInvoiceStatus);
  return false;

}*/
}
