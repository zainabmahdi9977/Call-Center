import 'dart:async';
import 'dart:io';
import 'package:invo_5_widget/Widgets/Attentions/Attentions.dart';
import 'package:newcall_center/utils/dialog.service.dart';

import '../../models/branch.models.dart';
import 'package:container_tab_indicator/container_tab_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:invo_5_widget/invo_5_widget.dart';
import 'package:newcall_center/blocs/customer.page.bloc.dart';
import 'package:newcall_center/pages/CustomerPage/widgets/PurchaseHistory.dart';
import 'package:newcall_center/pages/CustomerPage/widgets/addressform.dart';
import 'package:newcall_center/pages/CustomerPage/widgets/changeservuce.dart';
import 'package:resize/resize.dart';

class CustomerPage extends StatefulWidget {
  final CustomerPageBloc bloc;
  const CustomerPage({super.key, required this.bloc});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String? photo;

  bool editMode = false;
  final _customerFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();

  late CustomerPageBloc bloc;
  int tabLength = 3;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;

    bloc.onCustomerChange.stream.listen((event) {
      setState(() {});
    });

    bloc.onServiceChange.stream.listen((event) {
      setState(() {});
    });

    if (widget.bloc.selectMode) {
      tabLength = 1;
      if (widget.bloc.showPurchaseHistory) {
        tabLength = 2;
      }
    }

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Ensure the correct index for "Purchase History"
      if (_tabController.index == 1 && (!widget.bloc.selectMode || widget.bloc.showPurchaseHistory)) {
        // Purchase History
        widget.bloc.loadPurchaseHistory(reload: true);
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    _tabController.dispose();
    // bloc.dispose();
  }

  pickPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        photo = result.files.single.path!;
      });
    } else {
      // User canceled the picker
    }
  }

  void enterEdit() async {
    await _controller.forward();
    // await _controller.reserve();
  }

  void exitEdit() async {
    await _controller.reverse();
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(-1, 5.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  ));

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Material(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            (tabLength > 1)
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 25.w),
                    margin: const EdgeInsets.only(bottom: 0),
                    child: TabBar(
                      dividerHeight: 0,
                      tabAlignment: TabAlignment.start,
                      controller: _tabController,
                      isScrollable: true,
                      // onTap: (value) {
                      //   if (value == 1) {
                      //     //Purchace History
                      //     print("Hi");
                      //     bloc.loadPurchaseHistory(reload: true);
                      //   }
                      // },
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        TabElement("General".tr(), 0),
                        if (!widget.bloc.selectMode || widget.bloc.showPurchaseHistory) TabElement("Purchase History".tr(), 0),
                      ],
                      unselectedLabelStyle: TextStyle(fontSize: 25.sp, color: Colors.black, fontFamily: 'Cairo'),
                      labelStyle: TextStyle(fontSize: 25.sp, fontFamily: 'Cairo', color: Colors.black, fontWeight: FontWeight.bold),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.white,
                      indicator: ContainerTabIndicator(
                        // widthFraction: 1.0,
                        height: 4.h,
                        color: WidgetUtilts.currentSkin.primaryColor,
                        padding: EdgeInsets.only(top: 25.h),
                      ),
                    ))
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 25.w),
                  ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Row(
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.topStart,
                        children: [
                          LayoutBuilder(builder: (context, constraints) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(color: const Color.fromRGBO(247, 247, 247, 1), borderRadius: const BorderRadiusDirectional.only(topEnd: Radius.circular(15)), border: Border.all(width: 1.w, color: const Color.fromRGBO(215, 215, 215, 1))),
                              width: 400.w,
                              height: constraints.maxHeight - (MediaQuery.of(context).viewInsets.bottom) + 80.h,
                              child: Form(
                                key: _customerFormKey,
                                child: ListView(
                                  children: [
                                    ExcludeFocus(
                                      child: Container(
                                        clipBehavior: Clip.antiAlias,
                                        margin: EdgeInsets.only(top: 30.h, bottom: 5.h),
                                        width: 140.w,
                                        height: 140.w,
                                        decoration: const BoxDecoration(color: Color.fromRGBO(146, 146, 146, 1), shape: BoxShape.circle),
                                        child: photo == null
                                            ? Icon(
                                                Icons.person,
                                                size: 120.sp,
                                                color: Colors.white,
                                              )
                                            : Image(
                                                width: 140,
                                                height: 140,
                                                image: FileImage(File(photo!)),
                                              ),
                                      ),
                                    ),
                                    ExcludeFocus(
                                      child: TextButton(
                                        onPressed: () {
                                          pickPhoto();
                                        },
                                        style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(WidgetUtilts.currentSkin.primaryColor)),
                                        child: Text(
                                          "Add Photo".tr(),
                                          style: TextStyle(fontSize: 20.sp),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ExcludeFocus(
                                          child: Container(
                                            padding: EdgeInsets.only(top: 8.h),
                                            child: Text(
                                              "Salute".tr(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(fontSize: 16.sp, height: 1.5),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 55.h,
                                          child: DropDownMenu<String>(
                                            hint: "Salute".tr(),
                                            selectedValue: bloc.customer.saluation,
                                            iconColor: const Color.fromRGBO(146, 146, 146, 1),
                                            color: const Color.fromRGBO(255, 255, 255, 1),
                                            borderColor: const Color.fromRGBO(215, 215, 215, 1),
                                            onChanged: (String? value) {
                                              if (value != null) bloc.customer.saluation = value;
                                            },
                                            [
                                              "",
                                              "Mr.".tr(),
                                              "Ms.".tr(),
                                              "Mrs.".tr(),
                                              "Dr.".tr()
                                            ].map<DropdownMenuItem<String>>((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 20.sp, color: const Color.fromRGBO(0, 0, 0, 1), height: 1.5),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top: 8.h),
                                          child: Text(
                                            "Name".tr(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 16.sp, height: 1.5),
                                          ),
                                        ),
                                        CustomTextField(
                                          hint: 'Name'.tr(),
                                          validator: (value) {
                                            if (bloc.customer.name.isEmpty || bloc.customer.name == " ") {
                                              return 'Please enter customer name'.tr();
                                            }
                                            if (RegExp(r'\d').hasMatch(bloc.customer.name)) {
                                              return 'name should not contain  numbers'.tr();
                                            }
                                            return null;
                                          },
                                          initValue: bloc.customer.name,
                                          callback: (String txt) {
                                            bloc.customer.name = txt;
                                          },
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top: 8.h),
                                          child: Text(
                                            "Phone No.".tr(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 16.sp, height: 1.5),
                                          ),
                                        ),
                                        CustomTextField(
                                          hint: 'Phone No.'.tr(),
                                          initValue: bloc.customer.phone,
                                          validator: (value) {
                                            return bloc.validatePhoneNumber();
                                          },
                                          callback: (String txt) {
                                            // if (txt == 0) {
                                            //   bloc.customer.phone = "";
                                            //   return;
                                            // }
                                            if (txt.length > 20) {
                                              bloc.customer.phone = txt.toString().substring(0, 20);
                                            } else {
                                              bloc.customer.phone = txt;
                                            }
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            "Mobile No.".tr(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 16.sp, height: 1.5),
                                          ),
                                        ),
                                        CustomDigitsField(
                                          hint: 'Mobile No.'.tr(),
                                          initValue: bloc.customer.mobile,
                                          callback: (double txt) {
                                            bloc.customer.mobile = txt.toInt().toString();
                                          },
                                          validator: (value) {
                                            return null;
                                            //  return bloc.validatemNumber();
                                          },
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top: 8.h),
                                          child: Text(
                                            "Email Address".tr(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 16.sp, height: 1.5),
                                          ),
                                        ),
                                        CustomTextField(
                                          hint: 'Email Address'.tr(),
                                          initValue: bloc.customer.email,
                                          callback: (String txt) {
                                            bloc.customer.email = txt.toString();
                                          },
                                          keyboardLocation: KeyboardLocation.topLeft,
                                          validator: (value) {
                                            return bloc.validateemail();
                                          },
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top: 8.h),
                                          child: Text(
                                            "Birthday".tr(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 16.sp, height: 1.5),
                                          ),
                                        ),
                                        CustomDateField(
                                            hint: 'Birthday'.tr(),
                                            initValue: bloc.customer.birthDay,
                                            callback: (value) {
                                              bloc.customer.birthDay = value;
                                            }),
                                        Container(
                                          padding: EdgeInsets.only(top: 8.h),
                                          child: Text(
                                            "CardNo MSR".tr(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(fontSize: 16.sp, height: 1.5),
                                          ),
                                        ),
                                        CustomTextField(
                                          hint: 'CardNo MSR'.tr(),
                                          initValue: bloc.customer.MSR,
                                          callback: (String txt) {
                                            bloc.customer.MSR = txt;
                                          },
                                          keyboardLocation: KeyboardLocation.topLeft,
                                          validator: (value) {
                                            return null;
                                            //   return bloc.validateCardNo();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          SlideTransition(
                            position: _offsetAnimation,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: LayoutBuilder(builder: (context, constraints) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  decoration: BoxDecoration(color: const Color.fromRGBO(247, 247, 247, 1), borderRadius: const BorderRadius.only(topRight: Radius.circular(15)), border: Border.all(width: 1.w, color: const Color.fromRGBO(215, 215, 215, 1))),
                                  width: 400.w,
                                  height: constraints.maxHeight - (MediaQuery.of(context).viewInsets.bottom) + 80.h,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 20.h, bottom: 10.h),
                                      child: Text(
                                        "Address Info".tr(),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: StreamBuilder(
                                          stream: bloc.selectedAddress.stream,
                                          builder: (context, snapshot) {
                                            if (bloc.selectedAddress.value == null) return const SizedBox();
                                            return Form(
                                                key: _addressFormKey,
                                                child: SingleChildScrollView(
                                                  child: FocusTraversalGroup(
                                                    policy: ReadingOrderTraversalPolicy(),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        ExcludeFocus(
                                                          child: Container(
                                                            padding: EdgeInsets.only(top: 8.h),
                                                            child: Text(
                                                              "Address Title".tr(),
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(fontSize: 16.sp, height: 1.5),
                                                            ),
                                                          ),
                                                        ),
                                                        FocusTraversalOrder(
                                                          order: const NumericFocusOrder(0),
                                                          child: AutoCompleteField<String>(
                                                            //key: GlobalKey(),
                                                            optionsBuilder: (textEditingValue) {
                                                              List<String> list = [
                                                                "Home",
                                                                "Office",
                                                                "Apartment"
                                                              ];
                                                              return textEditingValue.text.isEmpty ? list : list.where((f) => f == textEditingValue.text);
                                                            },
                                                            initValue: "Home",
                                                            clearBtn: true,
                                                            onClear: () {
                                                              bloc.selectedAddress.value!.title = "";
                                                            },
                                                            onSelected: (String value) {
                                                              bloc.selectedAddress.value!.title = value;
                                                            },
                                                            onTextChange: (String value) {
                                                              bloc.selectedAddress.value!.title = value;
                                                              //don't update view on text change (no setstate)
                                                            },
                                                            optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                                                              return Align(
                                                                alignment: Alignment.topLeft,
                                                                child: Container(
                                                                  color: Colors.white,
                                                                  child: Container(
                                                                    clipBehavior: Clip.antiAlias,
                                                                    width: 350.w,
                                                                    height: 150.h,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white.withOpacity(0.6),
                                                                      // border: Border.all(
                                                                      //   width: 2,
                                                                      //   color: Color.fromRGBO(190, 190, 190, 1),
                                                                      // ),
                                                                      borderRadius: BorderRadius.circular(10.r),
                                                                    ),
                                                                    child: ListView.builder(
                                                                      padding: EdgeInsets.all(10.w),
                                                                      itemCount: options.length,
                                                                      itemBuilder: (BuildContext context, int index) {
                                                                        final String option = options.elementAt(index);
                                                                        return GestureDetector(
                                                                          onTap: () {
                                                                            onSelected(option);
                                                                          },
                                                                          child: Text(
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
                                                        AddressForm(bloc: bloc),
                                                        ExcludeFocus(
                                                          child: Container(
                                                            padding: EdgeInsets.only(top: 8.h),
                                                            child: Text(
                                                              "Note".tr(),
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(fontSize: 16.sp, height: 1.5),
                                                            ),
                                                          ),
                                                        ),
                                                        CustomTextArea(
                                                          hint: 'Note'.tr(),
                                                          initValue: bloc.selectedAddress.value!.note,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                          }),
                                    ),
                                    KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
                                      if (isKeyboardVisible) {
                                        return Container();
                                      } else {
                                        return Container(
                                          height: 50.h,
                                          margin: EdgeInsets.only(bottom: 20.h),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: OptionButton(
                                                  "Cancel".tr(),
                                                  fontSize: 20.sp,
                                                  style: "info",
                                                  padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 10.w),
                                                  onTap: () => exitEdit(),
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
                                              Expanded(
                                                child: OptionButton(
                                                  "Save".tr(),
                                                  fontSize: 20.0.sp,
                                                  style: "info",
                                                  padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 10.w),
                                                  onTap: () {
                                                    if (_addressFormKey.currentState!.validate()) {
                                                      bloc.selectedAddress.value!.copyAddressFormat(bloc.addressMap);
                                                      bloc.saveAddress();
                                                      exitEdit();
                                                    }
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                    }),
                                  ]),
                                );
                              }),
                            ),
                          )
                        ],
                      ),
                      ExcludeFocus(
                        child: Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  //padding: EdgeInsets.symmetric(horizontal: 100.w, vertical:50.h),
                                  // height: 450.h,
                                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: bloc.serviceName == "PickUp"
                                            ? Expanded(
                                                child: Container(
                                                  height: 450.h,
                                                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        "Branches".tr(),
                                                        style: TextStyle(
                                                          fontSize: 24.sp,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h), // Adjust spacing as needed
                                                      Expanded(
                                                        child: GridView.builder(
                                                          shrinkWrap: true,
                                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 3, // Number of cards per row
                                                            crossAxisSpacing: 10.0.w, // Horizontal spacing between cards
                                                            mainAxisSpacing: 10.0.h, // Vertical spacing between rows
                                                            childAspectRatio: 3 / 1, // Aspect ratio of each card
                                                          ),
                                                          itemCount: bloc.branches.value.length,
                                                          itemBuilder: (context, index) {
                                                            Branch branch = bloc.branches.value[index];

                                                            return GestureDetector(
                                                              /*  onTap: () async {
                                                                await GetIt.instance.get<NavigationService>().goToOrderPage(OrderPageBloc(bloc.service.value, branch));
                                                              },*/
                                                              onTap: () {
                                                                if (_customerFormKey.currentState != null && _customerFormKey.currentState!.validate()) {
                                                                  bloc.saveCustomer(branch);
                                                                } else {}
                                                              },
                                                              child: MouseRegion(
                                                                cursor: SystemMouseCursors.click,
                                                                child: SizedBox(
                                                                  height: 5.0, // Set maximum height here
                                                                  child: Card(
                                                                    elevation: 4.0,
                                                                    margin: EdgeInsets.zero,
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(16.0),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Text(
                                                                              branch.name,
                                                                              style: TextStyle(
                                                                                fontSize: 20.sp,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(height: 5.h),
                                                                          Expanded(
                                                                            child: Text(
                                                                              branch.address,
                                                                              style: TextStyle(
                                                                                fontSize: 16.sp,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(height: 5.h),
                                                                          Expanded(
                                                                            child: Text(
                                                                              branch.phoneNumber,
                                                                              style: TextStyle(
                                                                                fontSize: 16.sp,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                margin: EdgeInsets.all(20.h),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: 220.w,
                                                      height: 40.h,
                                                      child: OptionButton(
                                                        "Add Address".tr(),
                                                        textAlign: TextAlign.left,
                                                        fontSize: 20.0.sp,
                                                        lineHeight: 1.5,
                                                        icon: Icons.add,
                                                        iconSize: 30.0.sp,
                                                        onTap: () {
                                                          enterEdit();
                                                          bloc.addAddress();
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 370.w,
                                                      height: 40.h,
                                                      child: OptionButton(
                                                        "Show Covered Addresses".tr(),
                                                        textAlign: TextAlign.left,
                                                        fontSize: 20.0.sp,
                                                        lineHeight: 1.5,
                                                        icon: Icons.info,
                                                        iconSize: 30.0.sp,
                                                        onTap: () {
                                                          DialogService().showCoveredAddresses(bloc.getCoveredAddress(), bloc.branches);
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                      ),
                                      if (bloc.serviceName != "PickUp")
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.all(20.h),
                                            child: StreamBuilder(
                                              stream: bloc.addressesUpdated.stream,
                                              builder: (context, snapshot) {
                                                return AddressesWidget(
                                                  bloc.customer.addresses,
                                                  (address) {
                                                    enterEdit();
                                                    bloc.editAddress(address);
                                                  },
                                                  (address) {
                                                    exitEdit();
                                                    bloc.deleteAddress(address);
                                                  },
                                                  onSelect: (address) {},
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                                  decoration: BoxDecoration(
                                    color: WidgetUtilts.currentSkin.bgColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(70.r),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ExcludeFocus(
                                        child: Container(
                                          width: 206.w,
                                          height: 40.h,
                                          margin: EdgeInsets.only(top: 30.h, bottom: 10.h),
                                          child: OptionButton(
                                            "Add Note".tr(),
                                            textAlign: TextAlign.left,
                                            fontSize: 20.0.sp,
                                            lineHeight: 1.5,
                                            icon: Icons.add,
                                            iconSize: 30.0.sp,
                                            style: "custom",
                                            customColors: [
                                              Colors.transparent,
                                              const LinearGradient(
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.transparent,
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              WidgetUtilts.currentSkin.primaryColor,
                                              Colors.transparent,
                                              Colors.transparent,
                                            ],
                                            onTap: () => bloc.addNote(),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(bottom: 20.h),
                                        height: (MediaQuery.of(context).size.height - 385.h) / 2,
                                        child: StreamBuilder(
                                          stream: bloc.notesUpdated.stream,
                                          builder: (context, snapshot) {
                                            return Attentions(
                                              key: GlobalKey(),
                                              notes: bloc.customer.notes,
                                              onDelete: (note) {
                                                bloc.deleteNote(note);
                                              },
                                              onEdit: (note) {
                                                bloc.editNote(note);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!widget.bloc.selectMode || widget.bloc.showPurchaseHistory)
                    PurchaseHistory(
                      bloc: bloc,
                    ),
                ],
              ),
            ),
            // Container(i want dilag fixed here color: Colors.black,height: 80.h,),
            Container(
              height: 80.h,
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              decoration: BoxDecoration(
                gradient: WidgetUtilts.currentSkin.actionBar,
              ),
              child: Row(
                children: [
                  bloc.serviceName == "PickUp"
                      ? const SizedBox()
                      : Row(
                          children: [
                            ActionButton(
                              "Done".tr(),
                              onTap: () {
                                if (_customerFormKey.currentState == null || !_customerFormKey.currentState!.validate()) {
                                  debugPrint("Please check your input");
                                  return;
                                } else if (bloc.customer.addresses.isEmpty == false) {
                                  bloc.saveCustomer(null);
                                } else if (_addressFormKey.currentState == null || bloc.customer.addresses.isEmpty == true) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Add or Choose Address").tr(),
                                      content: const Text("Please add or choose an address before proceeding.").tr(),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text("Okay".tr()),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                          ],
                        ),
                  ActionButton("Change Customer".tr(), onTap: () {
                    bloc.changeCustomer();
                  }),
                  SizedBox(
                    width: 20.w,
                  ),
                  StreamBuilder(
                    stream: bloc.service.stream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return ActionButton(bloc.service.value.name.tr(), onTap: () {
                        bloc.changeService(bloc.service.value);
                        openDialog(context, bloc);
                      });
                    },
                  ),
                  SizedBox(
                    width: 20.w,
                  ),
                  /*ActionButton("Call History".tr(), onTap: () {
                    // bloc.callHistory();
                  }),*/
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ActionButton(
                        "Back".tr(),
                        icon: InvoIcons.right_arrow_next,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ))
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}

Future openDialog(BuildContext context, CustomerPageBloc bloc) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: ChangeService(bloc: bloc),
      );
    },
  );
}
