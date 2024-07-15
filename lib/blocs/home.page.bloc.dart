// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:invo_models/invo_models.dart';
import 'package:newcall_center/blocs/customer.page.bloc.dart';
import 'package:newcall_center/blocs/orderPage/order.page.bloc.dart';

import 'package:newcall_center/services/login.services.dart';
import 'package:newcall_center/services/reposiory.services.dart';
import 'package:newcall_center/utils/asteriskcallerid.dart';
import 'package:newcall_center/utils/dialog.service.dart';
import 'package:newcall_center/utils/naviagtion.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/branch.models.dart';
import '../services/order.services.dart';
import 'bloc.base.dart';

class HomePageBloc implements BlocBase {
  Property<List<Service>> services = Property([]);
  Employee allEmployee = Employee(id: "", name: "All Employees".tr(), email: "", passCode: "", MSR: "");
  Property<List<Employee>> employees = Property([]);
  Property<List<Branch>> branches = Property([]);
  Property<bool> updateFilter = Property(false);
  Property<Invoice?> invoice = Property(null);
  Property<List<InvoiceMini>> orders = Property([]);
  Property<String> phoneNumber = Property("");

  String invoiceStatus = "";
  late Repository repository;
  late Employee loggedInEmployee;
  String? selectedBranchId;
  String? selectedEmployeeId;
  String? selectedTicket = "Open".tr();
  String? customerContact;
  String? filter;
  late Timer timer;
  late NavigationService navigationService;
  HomePageBloc() {
    repository = GetIt.instance.get<Repository>();
    services.sink(repository.services);
    employees.sink(repository.employees);
    branches.sink(repository.branches);
    loadLoggedInEmployee();
    loadCallerID();
    navigationService = GetIt.instance.get<NavigationService>();

    navigationService.currentPage.stream.listen((event) {
      if (event == "HomePage") {
        loadOrdersInvoiceMini();
        updateOrders();
      } else {
        _stopUpdatingOrders();
      }
    });
  }

  updateOrders() {
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      loadOrdersInvoiceMini();
    });
  }

  _stopUpdatingOrders() {
    if (timer.isActive) {
      timer.cancel();
    }
  }

  loadLoggedInEmployee() async {
    Employee? employee = await LoginServices().getEmployee();
    if (employee != null) {
      loggedInEmployee = employee;
    }
  }

  @override
  void dispose() {
    services.dispose();
    employees.dispose();
    branches.dispose();
    orders.dispose();
    updateFilter.dispose();
    invoice.dispose();
    phoneNumber.dispose();
    timer.cancel();
    _debounce?.cancel();
  }

  String telephone = "";
  void updateTelephone(String txt) {
    telephone = txt;
  }

  String? callerIDIP = "";
  late AsteriskCallerID callerID;
  loadCallerID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? callerIDIP = prefs.getString("ip");
    int callerIDPort = int.parse(prefs.getString("port").toString());
    String? callerIDUsername = prefs.getString("username");
    String? callerIDPassword = prefs.getString("password");
    String? callerIDSID = prefs.getString("sid");

    callerID = AsteriskCallerID(
      ip: callerIDIP!,
      port: callerIDPort,
      userName: callerIDUsername!,
      password: callerIDPassword!,
      extensionNumber: callerIDSID!,
      onCallRecieved: onCallRecieved,
    );
    callerID.connect();
  }

  onCallRecieved(String number) async {
    int? res = int.tryParse(number);
    if (res != null) {
      phoneNumber.sink(res.toString());
    }
  }

  void loadCustomer(BuildContext context, Service service) async {
    try {
      // Check if the telephone number is valid (8 digits)
      if (telephone.length != 8) {
        throw const FormatException('Invalid phone number');
      }

      CustomerPageBloc customerBloc = await CustomerPageBloc.fromPhone(
        telephone,
        service,
        service.name,
      );
      GetIt.instance.get<NavigationService>().goToCustomerPage(customerBloc);
    } catch (e) {
      if (e is FormatException) {
        _showAlertDialog(context, 'Invalid phone number'.tr(), 'Enter a valid 8-digit phone number.'.tr());
      } else {
        _showAlertDialog(context, 'Error'.tr(), 'An error occurred.'.tr());
      }
    }
  }

  void _showAlertDialog(BuildContext context, String title, String content) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title).tr(),
          content: Text(content).tr(),
          actions: <Widget>[
            TextButton(
              child: const Text('Confirm').tr(),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  go() {
    loadOrdersInvoiceMini();
  }

  selectInvoice(InvoiceMini _invoice) async {
    if (invoice.value != null) {
      if (invoice.value!.id == _invoice.id) {
        return;
      }
    }
    for (var element in orders.value) {
      element.isSelected = false;
    }
    _invoice.isSelected = true;

    dynamic temp = orders.value;
    orders.sink([]);
    orders.sink(temp);

    Invoice? fullInvoice = await OrderService().getInvoice(_invoice.id);
    if (invoice.value != null) {
      invoice.value!.dispose();
    }
    invoiceStatus = _invoice.status;
    invoice.sink(fullInvoice);
  }

  void editInvoice() {
    if (invoice.value != null) {
      GetIt.instance.get<NavigationService>().goToOrderPage(OrderPageBloc.editOrder(invoice.value!));
    }
  }

  voidInvoice() async {
    if (invoice.value == null) return;
    if (invoice.value!.id == "") return;

    bool res = await DialogService().confirmationDialog("Void Ticket".tr(), "Are you sure you want to void ticket ?".tr());
    if (!res) return;
    bool waste = await GetIt.instance.get<DialogService>().confirmationDialog2("Waste Product".tr(), "Waste?".tr());
    String? voidReason;
    String employeeId = loggedInEmployee.id;

    if (repository.preferences != null && repository.preferences!.options.voidedItemNeedExplanation) {
      voidReason = await GetIt.instance.get<DialogService>().voidReasonDialog(reasons: repository.preferences!.voidReasons);
      if (voidReason != null && voidReason != "") {
        for (var line in invoice.value!.lines) {
          if (line.remainQty > 0) {
            line.voidQty(line.remainQty, employeeId, waste: waste, voidReason: voidReason);
          }
        }
      } else {
        await GetIt.instance.get<DialogService>().alertDialog("Void Reason".tr(), "Void reason is required".tr());
        return;
      }
    } else {
      for (var line in invoice.value!.lines) {
        if (line.remainQty > 0) {
          line.voidQty(line.remainQty, employeeId, waste: waste, voidReason: voidReason);
        }
      }
    }

    // before calculate send the invoice to capture data
    // ignore: unused_local_variable
    String invoiceNumber = invoice.value!.invoiceNumber ?? invoice.value!.id;
    // ignore: unused_local_variable
    double total = invoice.value!.total;

    invoice.value!.chargeAmount = 0;
    invoice.value!.discountAmount = 0;
    invoice.value!.isDirty = true;
    invoice.value!.calculateTotal();
    Invoice? savedInvoice = await OrderService().saveInvoice(invoice.value!, invoice.value!.branchId);
    if (savedInvoice != null) {
      loadOrdersInvoiceMini();
      invoiceStatus = "Void";
      invoice.sink(savedInvoice);
    }
  }

  reset() {
    selectedEmployeeId = null;
    selectedBranchId = null;
    selectedTicket = "Open".tr();
    customerContact = null;
    filter = null;
    updateFilter.sink(true);
  }

  Timer? _debounce;
  searchWithDebounce() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      loadOrdersInvoiceMini();
    });
  }

  loadOrdersInvoiceMini() async {
    List<InvoiceMini> loadedOrders = await OrderService().getOrders(
      selectedEmployeeId,
      selectedBranchId,
      filter,
      selectedTicket,
      customerContact,
    );

    if (invoice.value != null) {
      InvoiceMini? invoiceMini = loadedOrders.firstWhereOrNull((element) => element.id == invoice.value!.id);
      if (invoiceMini != null) {
        invoiceMini.isSelected = true;
      }
    }

    orders.sink(loadedOrders);
  }

  (
    bool,
    bool
  ) isPickupIsDelivery10(bool isPickup, bool isDelivery) {
    return (
      true,
      false
    );
  }

  (
    bool,
    bool
  ) isPickupIsDelivery01() {
    return (
      false,
      true
    );
  }

  isPickupIsDelivery1(bool isPickup, bool isDelivery) {
    isPickup = true;
    isDelivery = false;
    return (
      42,
      "foobar"
    );
  }

  void showKeyPad() {
    invoice.sink(null);
  }
}

//  Future<HomePageBloc> loadSuggestion(String GroupId, String phoneNumber,
//     {selectMode = false, bool showPurchaseHistory = false}) async {
//   try {
//     List<dynamic>? suggestedList = await CustomerService().getSuggestion(GroupId, phoneNumber);
//     return CustomerPageBloc(suggestedList, selectMode, showPurchaseHistory);
//   } catch (e) {
//     // Handle the exception or propagate it further
//     throw Exception('Failed to load suggestion: $e');
//   }
// }