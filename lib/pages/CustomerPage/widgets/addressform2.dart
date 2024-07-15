import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

import 'package:invo_5_widget/invo_5_widget.dart';
import 'package:newcall_center/blocs/orderPage/order.page.bloc.dart';

import 'package:resize/resize.dart';

class AddressForm2 extends StatefulWidget {
  final OrderPageBloc orderPageBloc;

  const AddressForm2(BuildContext context, bloc, {super.key, required this.orderPageBloc});

  @override
  State<AddressForm2> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm2> {
  Map<String, TextEditingController> textEditControllers = {};

  @override
  void initState() {
    super.initState();
  }

  List<Widget> addressFormat() {
    List<Widget> widgets = [];
    double i = 1;
    for (var element in widget.orderPageBloc.addressFormats) {
      TextEditingController textEditingController = TextEditingController();
      textEditControllers[element.key] = textEditingController;
      widgets.add(
        ExcludeFocus(
          child: Container(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              element.title.tr(),
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 16.sp, height: 1.5),
            ),
          ),
        ),
      );

      widgets.add(FocusTraversalOrder(
        order: NumericFocusOrder(i++),
        child: AutoCompleteField<String>(
          optionsBuilder: (textEditingValue) {
            List<String> list = widget.orderPageBloc.getAddressesList(element.key, widget.orderPageBloc.addressMap);
            return textEditingValue.text.isEmpty ? list : list.where((f) => f == textEditingValue.text);
          },
          initValue: widget.orderPageBloc.addressMap[element.key.toLowerCase()] ?? "",
          clearBtn: true,
          onClear: () {
            widget.orderPageBloc.setAddress(widget.orderPageBloc.addressMap, element.key.toLowerCase(), "");
            setState(() {});
          },
          onSelected: (String value) {
            widget.orderPageBloc.setAddress(widget.orderPageBloc.addressMap, element.key.toLowerCase(), value);
            setState(() {});
          },
          onTextChange: (String value) {
            widget.orderPageBloc.setAddress(widget.orderPageBloc.addressMap, element.key.toLowerCase(), value);
            //don't update view on text change (no setstate)
          },
          validator: (v) {
            String? value = widget.orderPageBloc.addressMap[element.key.toLowerCase()];
            if (element.isRequired) {
              if (value == null || value == "") return element.title.tr() + " Required".tr();
            } else {
              return null;
            }
            return null;
          },
          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.white,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  width: 350.w,
                  height: 165.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    // border: Border.all(
                    //   width: 2,
                    //   color: Color.fromRGBO(190, 190, 190, 1),
                    // ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return Container(
                        decoration: BoxDecoration(
                            // color: Colors.red,
                            border: Border(
                                bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: .5,
                        ))),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: Text(option, style: TextStyle(color: Colors.black, fontSize: 18.sp, overflow: TextOverflow.ellipsis))),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...addressFormat()
      ],
    );
  }
}
