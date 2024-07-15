//import 'dart:js';
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:invo_models/invo_models.dart';
import 'package:newcall_center/blocs/bloc.base.dart';
import 'package:collection/collection.dart';
import 'package:newcall_center/blocs/orderPage/order.page.bloc.dart';
import 'package:newcall_center/pages/CustomerPage/widgets/addressform.dart';
import 'package:newcall_center/services/order.services.dart';
import 'package:newcall_center/utils/dialog.service.dart';
import 'package:newcall_center/utils/naviagtion.service.dart';
import '../../services/customer.services.dart';
import '../models/branch.models.dart';

import '../services/reposiory.services.dart';

class CustomerPageBloc implements BlocBase {
  Property<bool> notesUpdated = Property(false);
  Property<bool> addressesUpdated = Property(false);
  Property<bool> onCustomerChange = Property(false);
  Property<bool> onServiceChange = Property(false);
  Property<CustomerAddress?> selectedAddress = Property(null);
  Property<List<InvoiceMini>> orders = Property([]);
  Property<Invoice?> order = Property(null);
  bool selectMode = false;
  bool showPurchaseHistory = false;

  Property<List<InvoiceMini>> unpaidOrders = Property([]);
  Property<List<InvoiceMini>> paidOrders = Property([]);
  String serviceName;
  Property<List<Branch>> branches = Property([]);
  late Repository repository;

  CustomerAddress? tempAddress;

  Customer customer;

  Map<String, dynamic> addressMap = {}; //temp value to save address

  double get totalSale {
    double total = 0;
    for (var element in orders.value) {
      total += element.total;
    }
    return total;
  }

  int get totalOrder {
    return orders.value.length;
  }

  double get avgOrder {
    if (totalOrder == 0) return 0.0;
    return totalSale / totalOrder;
  }

  DeliveryAddresses get deliveryAddresses {
    if (repository.preferences != null && repository.preferences!.deliveryAddresses != null) {
      return repository.preferences!.deliveryAddresses!;
    }
    return DeliveryAddresses();
  }

  List<AddressFormat> addressFormats = [];
  //change to property
  late Property<Service> service;
  List<Service> services = [];

  //constructor
  CustomerPageBloc(this.customer, this.selectMode, this.showPurchaseHistory, Service service, this.serviceName)
      : service = Property(service),
        services = GetIt.instance.get<Repository>().services {
    repository = GetIt.instance.get<Repository>();
    addressFormats = repository.preferences!.settings.addressFormat;
    PickUpBranches();
    this.service = Property(service);
    services = GetIt.instance.get<Repository>().services;
  }

  get addressFormKey => null;

  static Future<CustomerPageBloc> fromPhone(String phone, Service service, String serviceName, {selectMode = false, bool showPurchaseHistory = false}) async {
    Customer customer = await CustomerService().getCustomerByNumber(phone);

    return CustomerPageBloc(customer, selectMode, showPurchaseHistory, service, serviceName);
  }

  factory CustomerPageBloc.fromCustomer(
    Customer customer,
    Service service, {
    selectMode = true,
    bool showPurchaseHistory = false,
    String serviceName = '',
  }) {
    return CustomerPageBloc(customer, selectMode, showPurchaseHistory, service, serviceName);
  }

  List<String> getAddressesList(String addressKey, Map address) {
    List<String> addresses = [];
    switch (addressKey.toLowerCase()) {
      case "governorate":
        for (var element in deliveryAddresses.list) {
          if (element.Governorate.isNotEmpty && !addresses.contains(element.Governorate)) addresses.add(element.Governorate);
        }
        break;
      case "city":
        // for (var element in deliveryAddresses.list) {

        List<Address> temp = deliveryAddresses.list;
        if (address['governorate'] != null && address['governorate'].isNotEmpty) {
          temp = deliveryAddresses.list.where((f) => f.Governorate == address['governorate']).toList();
        }
        for (var element in temp) {
          if (element.City.isNotEmpty && !addresses.contains(element.City)) addresses.add(element.City);
        }
        break;
      case "block":
        List<Address> temp = deliveryAddresses.list;
        if (address['city'] != null && address['city'].isNotEmpty) {
          temp = deliveryAddresses.list.where((f) => f.City == address['city']).toList();
        }
        for (var element in temp) {
          if (element.Block.isNotEmpty && !addresses.contains(element.Block)) addresses.add(element.Block);
        }
        break;
      case "road":
        List<Address> temp = deliveryAddresses.list;
        if (address['block'] != null && address['block'].isNotEmpty) {
          temp = deliveryAddresses.list.where((f) => f.Block == address['block']).toList();
        }
        for (var element in temp) {
          if (element.Road.isNotEmpty && !addresses.contains(element.Road)) addresses.add(element.Road);
        }
        break;
      default:
    }

    return addresses;
  }

  // ignore: non_constant_identifier_names
  PickUpBranches() {
    repository = GetIt.instance.get<Repository>();
    branches.sink(repository.branches);
  }

  setAddress(Map map, String key, String value) {
    if (map[key] == value) return;
    map[key] = value;
    try {
      switch (key) {
        case "governorate":
          Address? address = deliveryAddresses.list.firstWhereOrNull((f) => f.Governorate == value);
          if (address != null) {
            map["city"] = "";
            map["block"] = "";
            map["road"] = "";
          }
        case "city":
          Address? address = deliveryAddresses.list.firstWhereOrNull((f) => f.City == value);
          if (address != null) {
            map["governorate"] = address.Governorate;
            map["city"] = address.City;
            map["block"] = "";
            map["road"] = "";
          }

          break;
        case "block":
          Address? address = deliveryAddresses.list.firstWhereOrNull((f) => f.Block == value);
          if (address != null) {
            map["governorate"] = address.Governorate;
            map["city"] = address.City;
            map["block"] = address.Block;
            map["road"] = "";
          }
          break;
        case "road":
          Address? address = deliveryAddresses.list.firstWhereOrNull((f) => f.Road == value);
          if (address != null) {
            map["governorate"] = address.Governorate;
            map["city"] = address.City;
            map["block"] = address.Block;
            map["road"] = address.Road;
          }
          break;
        default:
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  changeCustomer() async {
    String phone = await GetIt.instance.get<DialogService>().phoneDialog("Enter Phone Number".tr());
    Customer customer = await CustomerService().getCustomerByNumber(phone);
    //Customer? customer = await GetIt.instance.get<ICustomerRepo>().getCustomerByPhone(phone);

    this.customer = customer;
    onCustomerChange.sink(true);
  }

  changeService(Service selectedService) {
    service.sink(selectedService);
    serviceName = selectedService.name;
    onServiceChange.sink(true);
  }

  addAddress() {
    tempAddress = null;
    selectedAddress.sink(null);
    addressMap = CustomerAddress().toMap();
    selectedAddress.sink(CustomerAddress());
  }

  editAddress(CustomerAddress address) {
    tempAddress = address;
    addressMap = address.toMap();
    selectedAddress.sink(null);
    selectedAddress.sink(CustomerAddress.clone(address));
  }

  deleteAddress(CustomerAddress address) {
    tempAddress = null;
    selectedAddress.sink(null);
    customer.addresses.remove(address);
    addressesUpdated.sink(true);
  }

  addNote() async {
    String? res = await GetIt.instance.get<DialogService>().noteDialog(initValue: "");
    if (res != null) {
      customer.notes.insert(0, res);
      notesUpdated.sink(true);
    }
  }

  editNote(String note) async {
    String? res = await GetIt.instance.get<DialogService>().noteDialog(initValue: note);
    if (res != null) {
      int index = customer.notes.indexOf(note);
      customer.notes.remove(note);
      customer.notes.insert(index, res);
      notesUpdated.sink(true);
    }
  }

  Future<void> showAddressFormDialog2(BuildContext context, CustomerPageBloc bloc) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          child: AddressForm(bloc: bloc),
        );
      },
    );
  }

  deleteNote(String note) async {
    customer.notes.remove(note);
    notesUpdated.sink(true);
  }

  saveAddress() {
    if (selectedAddress.value != null) {
      if (selectedAddress.value!.title == "") {
        selectedAddress.value!.title = "Home";
      }
      if (tempAddress == null) {
        customer.addresses.add(selectedAddress.value!);
      } else {
        tempAddress!.copyfrom(selectedAddress.value!);
      }
      tempAddress = null;
      addressesUpdated.sink(true);
    }
  }

  loadPurchaseHistory({bool reload = false}) async {
    // Directly sink the list of invoices
    if (orders.value.isEmpty || reload) {
      var invoices = await OrderService().getInvoicesByCustomerID(customer.id);
      orders.sink(invoices);
    }
  }

  String? validatePhoneNumber() {
    if (customer.phone.isEmpty) {
      return 'Please enter customer phone';
    }

    String? countryCode = repository.preferences?.settings.countryCode;
    int? phoneLength = repository.preferences?.settings.phoneLength;
    String? phoneRegExp = repository.preferences?.settings.phoneRegExp;
    phoneRegExp ??= "\\d";
    countryCode ??= "+973";
    phoneLength ??= 8;

    String phonePattern = "((\\+|00)$countryCode)?\\d{$phoneLength}";

    RegExp exp = RegExp(phonePattern);

    if (!exp.hasMatch(customer.phone)) {
      return 'Invalid phone number';
    }

    return null;
  }

  String? validateemail() {
    if (customer.email.isEmpty) {
      return null;
    }

    String emailRegExp = r'^[\w-]+(\.[\w-]+)*@([a-z0-9-]+\.)+[a-z]{2,}$';

    RegExp exp = RegExp(emailRegExp, caseSensitive: false);

    if (!exp.hasMatch(customer.email)) {
      return 'Invalid email address';
    }

    return null;
  }

  // String? validateCardNo() {
  // final cardNo = cardNoController.text.trim();
/*
    if (customer.MSR.isEmpty) {
      return 'Card number is required';
    }

    final RegExp numericRegExp = RegExp(r'^[0-9]+$');

    if (!numericRegExp.hasMatch(customer.MSR)) {
      return 'Card number must be numeric';
    }

    if (customer.MSR.length != 16) {
      return 'Card number must be exactly 16 digits';
    }

    return null;*/
  // }

  // String? validatePhoneNumber() {
  //   if (customer.phone.isEmpty) {
  //     return 'Please enter customer phone';
  //   }

  //   String countryCode = repository.preferences!.settings.countryCode;
  //   List<String> prefix = repository.preferences!.settings.phonePrefix as List<String>;
  //   int phoneLength = repository.preferences!.settings.phoneLength;
  //   String phoneRegExp = repository.preferences!.settings.phoneRegExp;
  //   if (phoneRegExp == "") {
  //     phoneRegExp = "\\d";
  //   }

  //   String temp = "";
  //   for (var element in prefix) {
  //     temp += "$element\\d{${phoneLength - element.length}}|";
  //   }

  //   if (temp == "") {
  //     temp = "\\d{$phoneLength}";
  //   } else {
  //     temp = temp.substring(0, temp.length - 1);
  //   }

  //   print(r"((\+|00){0,1}" + countryCode + "){0,1}(" + temp + ")");
  //   print(customer.phone);
  //   RegExp exp = RegExp(phoneRegExp);
  //   Iterable<RegExpMatch> matchs = exp.allMatches(customer.phone);
  //   if (matchs.length != 1) {
  //     return 'invalid phone number';
  //   } else {
  //     RegExpMatch x = matchs.first;
  //     print(x.group(0));
  //     if (x.group(0) != customer.phone) {
  //       return 'invalid phone number';
  //     }
  //   }
  //   return null;
  // }

  selectInvoice(InvoiceMini invoice) async {
    if (order.value != null) {
      if (order.value!.id == invoice.id) {
        return;
      }
    }

    for (var element in orders.value) {
      element.isSelected = false;
    }
    invoice.isSelected = true;

    dynamic temp = orders.value;
    orders.sink([]);
    orders.sink(temp);

    Invoice? fullInvoice = await OrderService().getInvoice(invoice.id);
    if (order.value != null) {
      order.value!.dispose();
    }
    order.sink(fullInvoice);
  }

  reOrder() async {
    // if (!await Privilege().checkLogin(Security.reOrder)) return;

    if (order.value == null) return;
    Invoice invoice = Invoice.fromInvoice(order.value!);
    invoice.id = "";
    invoice.invoiceNumber = "";
    invoice.refrenceNumber = "";
    invoice.createdAt = DateTime.now();
    for (var line in invoice.lines) {
      line.id = "";
    }
    invoice.payments = [];
    invoice.branchId = order.value!.branchId;
    GetIt.instance.get<NavigationService>().goToOrderPage(OrderPageBloc.editOrder(invoice));
  }

  editOrder() {
    if (order.value != null) {
      GetIt.instance.get<NavigationService>().goToOrderPage(OrderPageBloc.editOrder(order.value!));
    }
  }

  voidTicket() async {
    // bool res = await InvoiceBloc().voidOrder(order.value);
    // if (res) {
    //   loadPurchaseHistory(reload: true);
    //   order.sink(null);
    // }
  }

  showDiscountOrder() async {
    // bool res = await InvoiceBloc().discountOrder(order.value);
    ///  order.sink(null);
  }

  showSurchargeOrder() async {
    // bool res = await InvoiceBloc().surchargeOrder(order.value);
    // order.sink(null);
  }

  void selectBranch(Branch branch) {
    OrderPageBloc orderPageBloc = OrderPageBloc.newOrder(service.value, branch);
    GetIt.instance.get<NavigationService>().goToOrderPage(orderPageBloc);
  }

  getCoveredAddress() {
    List<CoveredAddress> coveredAddresses = repository.preferences!.deliveryAddresses!.coveredAddresses;
    return coveredAddresses;
  }

  saveCustomer(Branch? branch) async {
    String? validate = validatePhoneNumber();

    if (validate != null) {
      bool res = await GetIt.instance.get<DialogService>().confirmationDialog("Phone Validation", "$validate do you want to procceed?");
      if (!res) return;
    }

    // GetIt.instance.get<DialogService>().showLoading();
    try {
      //  customer.id =
      await CustomerService().saveCustomer(customer).timeout(const Duration(seconds: 60));
      // GetIt.instance.get<DialogService>().alertDialog("Success",
      //   "Customer information has been save"); // await GetIt.instance.get<CustomerService>().saveCustomer(customer).timeout(Duration(seconds: TimeoutDuration.duration));

      //select first address if nothing is selected

      if (service.value.type == "Delivery") {
        if (customer.addresses.where((element) => element.isSelected).isEmpty) {
          if (customer.addresses.isNotEmpty) customer.addresses.first.isSelected = true;
        }

        CustomerAddress selectedAddress = customer.addresses.firstWhere((f) => f.isSelected);

        if (repository.preferences!.deliveryAddresses != null) {
          Map<String, dynamic> addressMap = selectedAddress.toMap();
          String rateBy = repository.preferences!.deliveryAddresses!.type;
          CoveredAddress? coveredAddress = repository.preferences!.deliveryAddresses!.coveredAddresses.firstWhereOrNull((f) {
            return f.address == addressMap[rateBy.toLowerCase()];
          });

          if (coveredAddress != null) {
            branch = repository.branches.firstWhere((f) => f.id == coveredAddress.branchId);
          }
        }

        if (branch == null) {
          String? selectedBranchId = await GetIt.instance.get<DialogService>().showBranchSelectionDialog(getBranches());

          if (selectedBranchId == null) {
            // User canceled branch selection, return without submitting
            return;
          }

          branch = repository.branches.firstWhere((f) => f.id == selectedBranchId);
        }
      }

      if (selectMode) {
        GetIt.instance.get<NavigationService>().goBack(customer);
      } else {
        await GetIt.instance.get<NavigationService>().goToOrderPage(OrderPageBloc.newOrderWithCustomer(service.value, branch!, customer));
      }

      //await GetIt.instance.get<NavigationService>().goToCustomerPage(CustomerPageBloc(customer, selectMode, showPurchaseHistory));
    } on TimeoutException {
      GetIt.instance.get<DialogService>().alertDialog("Connection failure", "No Internet Connection");
      // GetIt.instance.get<DialogService>().showToastMessage("No Internet Connection");
    } finally {
      // GetIt.instance.get<DialogService>().hideLoading();
    }
  }

  List<Branch> getBranches() {
    // Replace this with your logic to fetch the list of branches
    // from your data source
    return repository.branches;
  }

  cancel() async {
    // await GetIt.instance.get<NavigationService>().goBack(null);
  }

  @override
  void dispose() {
    notesUpdated.dispose();
    selectedAddress.dispose();
    addressesUpdated.dispose();
    onCustomerChange.dispose();
    onServiceChange.dispose();
    orders.dispose();
    order.dispose();

    unpaidOrders.dispose();
    paidOrders.dispose();
  }
}
