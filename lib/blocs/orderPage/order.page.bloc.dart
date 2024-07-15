import 'dart:async';
import 'dart:core';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:invo_models/invo_models.dart';

import 'package:invo_models/models/PriceLabel.dart';
import 'package:newcall_center/blocs/bloc.base.dart';
import 'package:newcall_center/blocs/customer.page.bloc.dart';

import 'package:newcall_center/models/branch.models.dart';
import 'package:newcall_center/pages/CustomerPage/widgets/addressform.dart';

import 'package:newcall_center/services/branch.services.dart';
import 'package:newcall_center/services/login.services.dart';
import 'package:newcall_center/services/menu.services.dart';
import 'package:newcall_center/services/order.services.dart';
import 'package:newcall_center/utils/dialog.service.dart';
import 'package:newcall_center/utils/naviagtion.service.dart';
import '../../services/reposiory.services.dart';
import 'order.page.state.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

class OrderPageBloc implements BlocBase {
  final DialogService dialogService = DialogService();
  final _serviceChangeController = StreamController<String>.broadcast();
  Stream<String> get serviceChangeStream => _serviceChangeController.stream;
  BehaviorSubject<String> serviceNameSubject = BehaviorSubject<String>();
  List<Menu> menus = [];
  List<Option> options = [];
  List<Service> services = [];
  List<AddressFormat> addressFormats = [];
  InvoiceLine? selectedLine;

  Property<Invoice> invoice = Property<Invoice>(Invoice());
  Property<List<Invoice>> invoices = Property<List<Invoice>>([]);
  Property<int> selectedInvoiceIndex = Property<int>(0);

  Property<int> invoiceQty = Property<int>(0);

  Property<Menu?> selectedMenu = Property<Menu?>(null);
  Property<List<MenuSection>> sections = Property<List<MenuSection>>([]);
  Property<MenuSection?> selectedSection = Property<MenuSection?>(null);
  Property<List<MenuSectionProduct>> products = Property<List<MenuSectionProduct>>([]);
  Property<double> qty = Property<double>(1);

  Property<OrderPageOptionState> orderPageOption = Property(OrderPageOption());
  Map<String, dynamic> addressMap = {}; //temp value to save address
  bool deleteableItems = true;
  bool selectableItems = true;
  Property<CustomerAddress?> selectedAddress = Property(null);
  Property<OptionGroup?> optionGroup = Property(null);
  Property<int> optionGroupIndex = Property(0);
  Property<bool> optionFinish = Property(false); //finish button on modifier

  Property<ProductSelection?> productSelection = Property(null);
  Property<int> productSelectionIndex = Property(0);

  Property<bool> showAddNewInvoice = Property(false);

  Property<bool> ticketMultiItemSelection = Property(false);

  Property<List<DateTime>> holdUntil = Property([]);
  late Repository repository;
  late Property<Service> selectedService;
  late CustomerPageBloc blocc;
  CustomerAddress? tempAddress;
  int seatNumber = 0;
  bool get isHalfEnable {
    if (repository.preferences != null) {
      return !repository.preferences!.options.disableHalfItem;
    }

    return false;
  }

  bool get enableQuickPayment {
    // if (repository.terminal != null) {
    //   return repository.terminal!.settings.enableQuickPayment;
    // }
    return false;
  }

  bool get isDineIn {
    return false;
  }

  bool get onlyOneTicketPerTable {
    return true;
  }

  bool get isQuickService {
    // if (repository.terminal != null) {
    //   return repository.terminal!.settings.quickService;
    // }
    return false;
  }

  double get invoicesTotal {
    double total = 0;
    for (var element in invoices.value) {
      total += element.total;
    }
    return total;
  }

  get bloc => null;

  @override
  void dispose() {
    _serviceChangeController.close();
    serviceNameSubject.close();
    invoice.dispose();
    invoice.value.dispose();
    invoices.dispose();
    for (var element in invoices.value) {
      element.dispose();
    }
    selectedInvoiceIndex.dispose();
    selectedMenu.dispose();
    sections.dispose();
    selectedSection.dispose();
    products.dispose();
    orderPageOption.dispose();
    optionGroup.dispose();
    productSelection.dispose();
    optionGroupIndex.dispose();
    productSelectionIndex.dispose();
    showAddNewInvoice.dispose();
    invoiceQty.dispose();
    ticketMultiItemSelection.dispose();
    holdUntil.dispose();
  }

  late Employee loggedInEmployee;
  Branch branch;
  OrderPageBloc(Service service, this.branch) {
    repository = GetIt.instance.get<Repository>();
    load(service);
  }

  factory OrderPageBloc.newOrder(Service service, Branch branch) {
    OrderPageBloc page = OrderPageBloc(service, branch);
    page.newOrder(service);
    return page;
  }
  get addressFormKey => null;
  Future<void> showAddressFormDialog(BuildContext context, CustomerPageBloc bloc) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          child: AddressForm(bloc: bloc),
        );
      },
    );
  }

  addAddress() {
    tempAddress = null;
    selectedAddress.sink(null);
    addressMap = CustomerAddress().toMap();
    selectedAddress.sink(CustomerAddress());
  }

  factory OrderPageBloc.newOrderWithCustomer(Service service, Branch branch, Customer customer) {
    OrderPageBloc page = OrderPageBloc.newOrder(service, branch);
    CustomerAddress? address = customer.addresses.firstWhereOrNull((f) => f.isSelected);
    page.checkCustomerDiscount(customer);
    double deliveryCharge = page.checkDeliveryCharge(address, service);
    page.invoice.value.addCustomer(customer, customer.phone, address, deliveryCharge: deliveryCharge);
    return page;
  }

  void checkCustomerDiscount(Customer customer) {
    if (customer.discountAmount > 0) {
      invoice.value.addDiscount(Discount(id: "", name: "Customer Discount", amount: customer.discountAmount, percentage: true, permittedEmployees: []));
    }
  }

  double checkDeliveryCharge(CustomerAddress? address, Service service) {
    double deliveryCharge = 0;
    selectedService = Property(service);
    if (selectedService.value.type == "Delivery" && address != null && repository.preferences!.deliveryAddresses != null) {
      Map<String, dynamic> addressMap = address.toMap();
      String rateBy = repository.preferences!.deliveryAddresses!.type;
      CoveredAddress? coveredAddress = repository.preferences!.deliveryAddresses!.coveredAddresses.firstWhereOrNull((f) {
        return f.address == addressMap[rateBy.toLowerCase()];
      });
      if (coveredAddress != null) {
        deliveryCharge = coveredAddress.deliveryCharge;
      }
    }

    return deliveryCharge;
  }

  factory OrderPageBloc.editOrder(Invoice invoice) {
    Repository repository = GetIt.instance.get<Repository>();
    Service service = repository.services.firstWhere((f) => f.id == invoice.serviceId);
    Branch branch = repository.branches.firstWhere((f) => f.id == invoice.branchId);
    OrderPageBloc page = OrderPageBloc(service, branch);
    //TODO check employee
    page.invoice.sink(invoice);
    page.invoiceQty.sink(invoice.lines.length);
    page.newOrder(service);
    return page;
  }

  load(Service service) async {
    services = repository.services;

    Employee? employee = await LoginServices().getEmployee();
    if (employee != null) {
      loggedInEmployee = employee;
    }
    // Menu menus = await MenuService().loadMenu();
    repository.services.where((f) {
      switch (f.type) {
        case "DineIn":
          return true;
        case "Delivery":
          return true;
        case "PickUp":
          return true;
        case "CarHop":
          return true;
        default:
          return false;
      }
    }).toList();
    selectedService = Property(service);
    await loadMenus();
    // loadMenu();

    loadOptions();
  }

  loadOptions() async {
    options = repository.options;
  }

  Future<void> loadMenus() async {
    try {
      final menuService = MenuService();
      menus = await menuService.loadMenus(branch.id);
      menus.sort((a, b) {
        return a.index > b.index ? 1 : -1;
      });

      List<Menu> tempMenu = menus.where((element) => element.startAt != null).toList();
      if (tempMenu.length == 1) {
        selectedMenu.sink(tempMenu[0]);
      } else {
        for (var i = 0; i < tempMenu.length; i++) {
          if (tempMenu.length == i + 1) {
            //reach last one
            selectedMenu.sink(menus[i]);
            break;
          } else if (toCurrentDate(tempMenu[i].startAt!).compareTo(DateTime.now()) < 0 && toCurrentDate(tempMenu[i].endAt!, nextDay: true).compareTo(DateTime.now()) > 0) {
            selectedMenu.sink(menus[i]);
            break;
          }
        }
      }

      if (selectedMenu.value == null) {
        selectedMenu.sink(menus[0]);
      }
      loadMenuSections();
    } catch (e) {
      throw Exception(e);
    }
  }

  void loadMenuSections() async {
    selectedSection.set(null);
    if (selectedMenu.value != null) {
      //check if section already loaded
      if (selectedMenu.value!.sections.isEmpty) {
        List<MenuSection> loadedSections = await MenuService().getMenu(selectedMenu.value!.id);

        selectedMenu.value!.sections = loadedSections;
      }

      sections.sink(selectedMenu.value!.sections);
      if (sections.value.isNotEmpty) {
        sections.value.sort((a, b) => a.index.compareTo(b.index));
        selectSection(sections.value[0]);
      }
    }
  }

  selectSection(MenuSection section) {
    if (selectedSection.value != null && selectedSection.value!.id == section.id) return;

    selectedSection.sink(section);
    sections.sink(sections.value);

    loadProducts();
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

  newOrder(Service service) async {
    Employee? employee = await LoginServices().getEmployee();
    GetIt.instance.get<Repository>();
    if (employee != null) loggedInEmployee = employee;
    invoice.value.isInclusiveTax = false;
    GetIt.instance.get<Repository>().preferences!.isInclusiveTax;
    invoice.value.serviceId = service.id;

    invoice.value.service = service;
    invoice.value.terminalId = "";
    invoice.value.employeeId = loggedInEmployee.id;
    invoice.value.employee = loggedInEmployee;
    invoice.value.smallestCurrency = 0;
    GetIt.instance.get<Repository>().preferences!.smallestCurrency;
    invoice.value.roundingType = GetIt.instance.get<Repository>().preferences!.roundingType;
  }

  loadProducts() async {
    if (selectedSection.value != null) {
      final menuService = MenuService();

      List<Product> prod = await menuService.getMenuProducts(sectionId: selectedSection.value!.id, branchId: branch.id);

      for (var element in selectedSection.value!.products) {
        element.product = prod.firstWhereOrNull((f) => f.id == element.productId);
      }

      products.sink(selectedSection.value!.products);
    } else {
      products.sink([]);
    }
  }

  DateTime toCurrentDate(DateTime dateTime, {bool nextDay = false}) {
    int plusDays = 0;
    if (dateTime.hour == 0 && dateTime.minute == 0) {
      if (nextDay) {
        plusDays = 1;
      }
    }
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day + plusDays,
      dateTime.hour,
      dateTime.minute,
    );
  }

  changeMenu() async {
    Menu? menu = await DialogService().showMenuList(menus);
    if (menu != null) {
      selectedMenu.sink(menu);
      loadMenuSections();
    }
  }

  changeInvoice(int index) {
    invoice.sink(invoices.value[index]);
    invoiceQty.sink(invoice.value.lines.length);
  }

  updateInvoiceIndex(int index) {
    selectedInvoiceIndex.sink(index);
  }

  bool get lastInvoiceHasProducts {
    if (invoices.value.isNotEmpty) {
      return invoices.value.last.lines.isNotEmpty;
    }
    return false;
  }

  Future<bool> addNewInvoice() async {
    // if (!await Privilege().checkLogin(Security.newInvoice)) return false;
    if (invoices.value.last.lines.isEmpty) return false;

    Invoice clone = invoices.value[0];
    // ignore: no_leading_underscores_for_local_identifiers
    Invoice _invoice = Invoice();
    // _invoice.terminalId = GetIt.instance.get<Repository>().terminal!.id;
    _invoice.serviceId = clone.serviceId;
    _invoice.service = clone.service;
    _invoice.employeeId = loggedInEmployee.id;
    _invoice.employee = loggedInEmployee;
    if (clone.table != null) {
      _invoice.tableId = clone.tableId;
      _invoice.table = clone.table;
    }
    invoices.value.add(_invoice);
    invoice.sink(invoices.value.last);
    invoices.sink(invoices.value);
    selectedInvoiceIndex.sink(invoices.value.length - 1);
    showAddNewInvoice.sink(false);
    checkServiceSurcharge();
    return true;
  }

  addProduct(Product product, {double? price}) async {
    double price0 = 0;
    String priceType = "";

    if (!product.available) {
      await DialogService().alertDialog("", "Unavailable item");
      return;
    }

    if (product.priceModel != null) {
      priceType = product.priceModel!.model;
    }

    if (price == null) {
      if (product.selectedPricingType == "openPrice") {
        double? priceTemp = await DialogService().priceDialog("Enter Price");
        if (priceTemp == null) return;
        priceType = "openPrice";
        price0 = priceTemp;
      } else if (product.selectedPricingType == "buyDownPrice") {
        if (product.buyDownQty >= qty.value) {
          price0 = product.buyDownPrice;
          product.buyDownQty -= qty.value.toInt();
          priceType = "buyDownPrice";
        } else {
          price0 = product.price;
        }
      } else {
        ProductPrice? productPrice;
        PriceLabel? priceLabel = repository.priceLabels.firstWhereOrNull((f) => f.id == selectedService.value.priceLabelId);
        if (priceLabel != null) {
          productPrice = priceLabel.productsPrices.firstWhereOrNull((f) => f.productId == product.id);
        }

        if (productPrice == null) {
          price0 = product.price;
        } else {
          priceType = "servicePrice";
          price0 = productPrice.price;
        }
      }
    } else {
      price0 = price;
    }

    String employeeId = loggedInEmployee.id;

    Tax? tax;
    if (product.taxId != null) {
      tax = GetIt.instance<Repository>().taxes.firstWhereOrNull((f) => f.id == product.taxId);
    }

    // ignore: unused_local_variable
    bool newLine = false;
    if (product.type == "batch") {
      ProductBatch? productBatch = await DialogService().batchedItem(product.batches);
      if (productBatch == null) {
        return;
      }
      newLine = invoice.value.addProduct(qty.value == 0 ? 1 : qty.value, product, price0, seatNumber, employeeId, tax, batch: productBatch.batch, priceType: priceType);
    } else if (product.type == "serialized") {
      ProductSerial? productSerial = await DialogService().serializedItem(product.serials);
      if (productSerial == null) {
        return;
      }
      if (productSerial.status == "Available") {
        newLine = invoice.value.addProduct(qty.value == 0 ? 1 : qty.value, product, price0, seatNumber, employeeId, tax, serial: productSerial.serial, priceType: priceType);
      } else {
        return;
      }
    } else {
      double itemQty = qty.value;
      if (product.orderByWeight && product.selectedPricingType != "priceByQty" && product.selectedPricingType != "buyDownPrice") {
        double? weight = await DialogService().numberDialog("Enter Weight");
        if (weight == null) return;
        itemQty = weight;
      }
      newLine = invoice.value.addProduct(itemQty == 0 ? 1 : itemQty, product, price0, seatNumber, employeeId, tax, priceType: priceType);
    }

    InvoiceLine addedLine = invoice.value.lines.last;

    qty.sink(1);
    showAddNewInvoice.sink(lastInvoiceHasProducts);
    InvoiceLine lastLine = invoice.value.lines[invoice.value.lines.length - 1];

    if (product.type == "menuItem") {
      if (product.optionGroups.isNotEmpty) {
        product.optionGroups.sort((a, b) {
          return a.index > b.index ? 1 : -1;
        });

        OptionGroup optionGroupTemp = repository.optionGroups.firstWhere((f) => f.id == product.optionGroups[0].optionGroupId);

        currentOptionGroups = product.optionGroups;
        loadOptionGroup(optionGroupTemp, 0);
      }
    } else if (product.type == "menuSelection") {
      if (product.selection.isNotEmpty) {
        product.selection.sort((a, b) {
          return a.index > b.index ? 1 : -1;
        });

        currentSelections = product.selection;
        loadMenuSelection(currentSelections[0], 0);
      }
    } else if (product.type == "package") {
      Product? tempProduct;
      double subItemTotalPrice = 0;
      for (var element in product.package) {
        tempProduct = repository.products.firstWhereOrNull((f) => f.id == element.productId);
        if (tempProduct != null) {
          subItemTotalPrice += tempProduct.price * element.qty;
          lastLine.addSubItem(
            tempProduct,
            1,
            employeeId,
            invoice.value.isInclusiveTax,
            qty: element.qty,
          );
        }
      }

      switch (priceType) {
        case "fixedPrice":
          addedLine.adjPrice(product.price);
          invoice.value.calculateTotal();
          break;
        case "totalPrice":
          addedLine.adjPrice(subItemTotalPrice);
          invoice.value.calculateTotal();
          break;
        case "totalPriceWithDiscount":
          if ((subItemTotalPrice - product.priceModel!.discount) < 0) {
            addedLine.adjPrice(0);
          } else {
            addedLine.adjPrice(subItemTotalPrice - product.priceModel!.discount);
          }
          invoice.value.calculateTotal();
          break;
        default:
      }

      packageIndex = 0;
      checkPackageOptions();
    }

    for (var element in invoice.value.lines) {
      element.isSelected = false;
    }
    lastLine.isSelected = true;
    selectedLine = lastLine;

    List<Option> quickOptions = [];
    for (var element in product.quickOptions) {
      quickOptions.add(repository.options.firstWhere((f) => f.id == element.id));
    }

    if (quickOptions.isNotEmpty) {
      orderPageOption.sink(QuickModifierOption(options: quickOptions));
    } else {
      orderPageOption.sink(ItemOption(lastLine));
    }
    invoiceQty.sink(invoice.value.lines.length);
    checkPriceByQty();
  }

  bool addProductByBarcode(String barcode) {
    if (barcode == "") return false;
    Product? product = repository.products.firstWhereOrNull((f) => f.barcode == barcode || f.barcodes.where((f) => f.barcode == barcode).isNotEmpty);
    if (product == null) {
      return false;
    } else {
      addProduct(product);
      return true;
    }
  }

  DeliveryAddresses get deliveryAddresses {
    if (repository.preferences != null && repository.preferences!.deliveryAddresses != null) {
      return repository.preferences!.deliveryAddresses!;
    }
    return DeliveryAddresses();
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

  Future<String> loadProductImage(String productId) async {
    // RegExp base64 = RegExp(r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');
    //base64 validation is not working probaly

    Product? product = repository.products.firstWhereOrNull((f) => f.id == productId);
    if (product != null) {
      if (product.defaultImage != "") {
        // if (_base64.hasMatch(product?.defaultImage)) {
        return product.defaultImage;
        // }
      }

      return product.defaultImage;
      // }
    }

    return "";
  }

  selectLine(InvoiceLine line) {
    selectedLine = line;
    orderPageOption.sink(ItemOption(line));
  }

  deleteLine(InvoiceLine line) async {
    String employeeId = loggedInEmployee.id;
    if (line.id == "") {
      invoice.value.deleteLine(line);
      invoice.value.calculateTotal();
      invoice.value.lineUpdated.sink(1);

      if (line.priceOfferType == "buyDownPrice") {
        Product? product = repository.products.firstWhereOrNull((f) => f.id == line.productId);
        if (product != null) {
          product.buyDownQty += (line.qty).toInt();
        }
      }
    } else {
      // if (!await Privilege().checkLogin(Security.voidItem)) return;
      bool waste = await DialogService().confirmationDialog("Waste Product", "Waste?");
      String? voidReason;
      if (repository.preferences != null && repository.preferences!.options.voidedItemNeedExplanation) {
        voidReason = await DialogService().voidReasonDialog(reasons: repository.preferences!.voidReasons);
        if (voidReason != null) {
          line.voidQty(line.remainQty, employeeId, waste: waste, voidReason: voidReason);
          invoice.value.calculateTotal();
          invoice.value.lineUpdated.sink(1);
        } else {
          await GetIt.instance.get<DialogService>().alertDialog("Void Reason", "Void reason is required");
          return;
        }
      } else {
        line.voidQty(line.remainQty, employeeId, waste: waste, voidReason: voidReason);
        invoice.value.calculateTotal();
        invoice.value.lineUpdated.sink(1);
      }
    }

    showAddNewInvoice.sink(lastInvoiceHasProducts);
  }

  deleteOption(InvoiceLine line, InvoiceLineOption option) {
    if (line.id == "") {
      line.deleteOption(option);

      invoice.value.calculateTotal();
      invoice.value.lineUpdated.sink(1);
    }
  }

  deleteDiscount(InvoiceLine line) {
    if (line.id == "") {
      line.deleteDiscount();
      invoice.value.calculateTotal();
      invoice.value.lineUpdated.sink(1);
    }
  }

  increaseQty() {
    if (selectedLine == null) return;
    if (selectedLine!.priceOfferType == "buyDownPrice") {
      Product? product = repository.products.firstWhereOrNull((f) => f.id == selectedLine!.productId);
      if (product != null) {
        if (product.buyDownQty >= 1) {
          product.buyDownQty -= 1;
        } else {
          return;
        }
      } else {
        return;
      }
    }

    selectedLine!.increaseQty();
    invoice.value.calculateTotal();
    invoice.value.lineUpdated.sink(1);
    checkPriceByQty();
  }

  decreaseQty() {
    if (selectedLine == null) return;
    if (selectedLine!.priceOfferType == "buyDownPrice") {
      Product? product = repository.products.firstWhereOrNull((f) => f.id == selectedLine!.productId);
      if (product != null) {
        product.buyDownQty += 1;
      } else {
        return;
      }
    }

    selectedLine!.decreaseQty();
    invoice.value.calculateTotal();
    invoice.value.lineUpdated.sink(1);
    checkPriceByQty();
  }

  adjQty() async {
    String employeeId = loggedInEmployee.id;
    if (selectedLine == null) return;
    double? number = await DialogService().numberDialog("Enter Qty");

    double oldQty = selectedLine!.qty;

    if (number != null) {
      if (selectedLine!.priceOfferType == "buyDownPrice") {
        Product? product = repository.products.firstWhereOrNull((f) => f.id == selectedLine!.productId);
        if (product != null) {
          product.buyDownQty -= (oldQty - number).toInt();
        } else {
          return;
        }
      }

      selectedLine!.adjQty(number, employeeId);
      invoice.value.calculateTotal();
      invoice.value.lineUpdated.sink(1);
      checkPriceByQty();
    }
  }

  adjPrice() async {
    // if (!await Privilege().checkLogin(Security.adjPrice)) return;

    if (selectedLine == null) return;
    Product? product = repository.products.firstWhereOrNull((f) => f.id == selectedLine!.productId);
    if (product != null) {
      double? number = await DialogService().priceDialog("Enter Price");
      if (number != null) {
        if ((product.priceBoundriesFrom == 0 && product.priceBoundriesTo == 0) || number >= product.priceBoundriesFrom && number <= product.priceBoundriesTo) {
          selectedLine!.adjPrice(number);
          invoice.value.calculateTotal();
          invoice.value.lineUpdated.sink(1);
        } else {
          DialogService().alertDialog("Price Boundries", "Price Should be between ${product.priceBoundriesFrom} and ${product.priceBoundriesTo}");
        }
      }
    }
  }

  onHoldFormShow() {
    // holdUntil
    DateTime current = DateTime.now();
    DateTime until = current;
    List<DateTime> dates = [];
    int nearstMinute = 15 * (until.minute / 15).ceil();
    until = until.add(Duration(minutes: -until.minute)).add(Duration(minutes: nearstMinute));
    dates.add(until);
    for (int i = 0; i <= 14; i++) {
      until = until.add(const Duration(minutes: 15));
      dates.add(until);
    }
    holdUntil.sink(dates);
  }

  holdUntilFire() {
    if (selectedLine != null) {
      selectedLine!.holdUntilFire();
      invoice.value.lineUpdated.sink(1);
      orderPageOption.reSink();
    }
  }

  fireHoldItem() {
    if (selectedLine != null) {
      selectedLine!.fire();
      invoice.value.lineUpdated.sink(1);
      orderPageOption.reSink();
    }
  }

  hold(DateTime dateTime) {
    for (var element in invoice.value.lines.where((f) => f.isSelected)) {
      element.holdItemUntil(dateTime);
    }
    invoice.value.lineUpdated.sink(1);
    orderPageOption.sink(OrderPageOption());
  }

  holdWithPreperationTime(DateTime dateTime) {
    for (var element in invoice.value.lines.where((f) => f.isSelected)) {
      element.holdWithPreperationTime(dateTime);
    }
    invoice.value.lineUpdated.sink(1);
    orderPageOption.sink(OrderPageOption());
  }

  holdItemFor(int min) {
    for (var element in invoice.value.lines.where((f) => f.isSelected)) {
      element.holdItemFor(min);
    }
    invoice.value.lineUpdated.sink(1);
    orderPageOption.sink(OrderPageOption());
  }

  checkPriceByQty() {
    Product? product = repository.products.firstWhereOrNull((f) => f.id == selectedLine!.productId);
    if (product != null) {
      if (product.selectedPricingType == "priceByQty") {
        product.priceByQty.sort((a, b) => a.qty > b.qty ? 0 : 1);
        bool found = false;
        for (var element in product.priceByQty) {
          if (selectedLine!.qty >= element.qty) {
            found = true;
            selectedLine!.adjPrice(element.price);
            selectedLine!.priceOfferType = "priceByQty";
            invoice.value.calculateTotal();
            invoice.value.lineUpdated.sink(1);
            break;
          }
        }

        if (!found) {
          //return default price if no price is available
          selectedLine!.adjPrice(selectedLine!.defaultPrice);
          selectedLine!.priceOfferType = "";
          invoice.value.calculateTotal();
          invoice.value.lineUpdated.sink(1);
        }
      }
    }
  }

  reOrder() async {
    // if (!await Privilege().checkLogin(Security.reOrder)) return;

    if (selectedLine == null) return;
    InvoiceLine line = InvoiceLine.copy(selectedLine!);
    line.id = "";

    invoice.value.addInvoiceLine(line);
    qty.sink(1);

    for (var element in invoice.value.lines) {
      element.isSelected = false;
    }
    invoice.value.lines[invoice.value.lines.length - 1].isSelected = true;
    selectedLine = invoice.value.lines[invoice.value.lines.length - 1];
  }

  showItemDicount() async {
    if (selectedLine == null) return;
    Discount? discount = await DialogService().discountListDialog("Discount Item", repository.discounts);
    if (discount != null) {
      selectedLine!.addDiscount(discount);
      invoice.value.lineUpdated.sink(1);
      invoice.value.calculateTotal();
    }
  }

  shortNote() async {
    if (selectedLine == null) return;
    PricedNote? res = await DialogService().noteDialogWithPrice();
    if (res != null) {
      if (res.note.isEmpty) return;
      selectedLine!.addNote(res.note, res.price);

      invoice.value.lineUpdated.sink(1);
    }
  }

  double? getOptionAutoPrice(String optionId) {
    double? price;
    OptionPrice? optionPrice;
    PriceLabel? priceLabel = repository.priceLabels.firstWhereOrNull((f) => f.id == selectedService.value.priceLabelId);
    if (priceLabel != null) {
      optionPrice = priceLabel.optionsPrices.firstWhereOrNull((f) => f.optionId == optionId);
    }
    if (optionPrice != null) {
      price = optionPrice.price;
    }
    return price;
  }

  optionClicked(Option option) {
    if (selectedLine == null) return;
    if (selectedLine!.options.where((f) => f.optionId == option.id).isNotEmpty) {
      return;
    }

    selectedLine!.addOption(option, "", price: getOptionAutoPrice(option.id));

    invoice.value.calculateTotal();
    invoice.value.lineUpdated.sink(1);
    invoice.value.footerUpdate.sink(true);
  }

  _lockTicket() {
    if (deleteableItems == false && selectableItems == false) return;
    deleteableItems = false;
    selectableItems = false;
    ticketMultiItemSelection.reSink();
  }

  _unlockTicket() {
    if (deleteableItems == true && selectableItems == true) return;
    deleteableItems = true;
    selectableItems = true;
    ticketMultiItemSelection.reSink();
  }

  List<ProductOptionGroup> currentOptionGroups = [];
  int optionSelected = 0;
  loadOptionGroup(OptionGroup? group, int index) {
    optionGroupIndex.sink(index);
    optionSelected = 0;
    if (group != null) {
      for (var element in group.options.where((f) => f.option == null)) {
        element.option = repository.options.firstWhereOrNull((f) => f.id == element.optionId);
      }
    }

    if (group == null) {
      _unlockTicket();
    } else {
      _lockTicket();
    }

    optionGroup.sink(group);
  }

  popUpOptionClicked(OptionGroup group, Option option) {
    bool isForcedOption = optionSelected < group.minSelectable;
    // ignore: unused_local_variable
    InvoiceLineOption? invoiceLineOption;
    if (productSelection.value != null) {
      //if sub item
      if (selectedLine!.subItems.last.options.where((f) => f.optionId == option.id).isNotEmpty) return;
      invoiceLineOption = selectedLine!.subItems.last.addOption(option, group.id, price: getOptionAutoPrice(option.id), isForced: isForcedOption);
    } else if (currentPackageLine != null) {
      if (selectedLine!.subItems[packageIndex].options.where((f) => f.optionId == option.id).isNotEmpty) return;
      invoiceLineOption = selectedLine!.subItems[packageIndex].addOption(option, group.id, price: getOptionAutoPrice(option.id), isForced: isForcedOption);
    } else {
      //if not sub item
      if (selectedLine == null) return;
      if (selectedLine!.options.where((f) => f.optionId == option.id).isNotEmpty) return;
      invoiceLineOption = selectedLine!.addOption(option, group.id, price: getOptionAutoPrice(option.id), isForced: isForcedOption);
      // selectedLine!.subItems.last.options
    }

    invoice.value.calculateTotal();
    invoice.value.lineUpdated.sink(1);
    invoice.value.footerUpdate.sink(true);

    optionSelected++;
    optionFinish.sink(true);

    //check if not select all option inside the group
    if (optionSelected != group.options.length) {
      //check limitation
      if (optionSelected < group.maxSelectable) {
        return;
      }
    }

    if ((currentOptionGroups.length - 1) > optionGroupIndex.value) {
      //go to next group after reach end of selection
      finishOptionGroup();
    } else {
      //no more option group available
      optionGroup.sink(null);
      _unlockTicket();

      //if it is sub item then check the next selection
      if (productSelection.value != null) {
        checkNextSelection();
      }

      if (currentPackageLine != null) {
        packageIndex++;
        checkPackageOptions();
      }
    }
  }

  backOptionGroup() {
    if (optionGroup.value == null) return;

    if (optionSelected > 0) {
      optionSelected--;

      if (productSelection.value != null) {
        //if sub item
        selectedLine!.subItems.last.removeLastOption();
      } else if (currentPackageLine != null) {
        //package item
        selectedLine!.subItems[packageIndex].removeLastOption();
      } else {
        //if not sub item
        selectedLine!.removeLastOption();
      }
      invoice.value.lineUpdated.sink(1);
    }
    if (optionSelected == 0) {
      optionGroupIndex.value--;
      //Get Option Group
      OptionGroup optionGroupTemp = repository.optionGroups.firstWhere((f) => f.id == currentOptionGroups[optionGroupIndex.value].optionGroupId);

      //remove last option group selected Options
      if (productSelection.value != null) {
        //if sub item
        selectedLine!.subItems.last.removeOptionByOptionGroupId(optionGroupTemp.id);
      } else if (currentPackageLine != null) {
        //package item
        selectedLine!.subItems[packageIndex].removeOptionByOptionGroupId(optionGroupTemp.id);
      } else {
        //if not sub item
        selectedLine!.removeOptionByOptionGroupId(optionGroupTemp.id);
      }
      invoice.value.lineUpdated.sink(1);

      loadOptionGroup(optionGroupTemp, optionGroupIndex.value);
    }
  }

  cancelOptionGroup() {
    if (productSelection.value != null) {
      //if sub item
      if (subItemSelected > 0) {
        subItemSelected--;
        selectedLine!.deleteLastSubItem();
      }
    } else if (currentPackageLine != null) {
      return;
    } else {
      //if not sub item
      invoice.value.deleteLastLine();
    }

    invoice.value.lineUpdated.sink(1);
    optionGroup.sink(null);
    _unlockTicket();
  }

  finishOptionGroup() {
    if (optionGroup.value == null) return;
    if (optionGroup.value!.minSelectable > optionSelected) return;
    optionGroupIndex.value++;
    optionGroupIndex.sink(optionGroupIndex.value);

    if (optionGroupIndex.value >= currentOptionGroups.length) {
      loadOptionGroup(null, optionGroupIndex.value);
    } else {
      OptionGroup? optionGroupTemp = repository.optionGroups.firstWhereOrNull((f) => f.id == currentOptionGroups[optionGroupIndex.value].optionGroupId);
      loadOptionGroup(optionGroupTemp, optionGroupIndex.value);
    }
  }

  int packageIndex = 0;
  InvoiceLine? currentPackageLine;
  checkPackageOptions() {
    if (invoice.value.lines.last.subItems.length <= packageIndex) {
      currentPackageLine = null;
      return;
    }

    InvoiceLine line = invoice.value.lines.last.subItems[packageIndex];
    currentPackageLine = line;
    if (line.product.optionGroups.isNotEmpty) {
      line.product.optionGroups.sort((a, b) {
        return a.index > b.index ? 1 : -1;
      });

      OptionGroup optionGroupTemp = repository.optionGroups.firstWhere((f) => f.id == line.product.optionGroups[0].optionGroupId);

      currentOptionGroups = line.product.optionGroups;
      loadOptionGroup(optionGroupTemp, 0);
    } else {
      packageIndex++;
      checkPackageOptions();
    }
  }

  List<ProductSelection> currentSelections = [];
  int subItemSelected = 0;

  loadMenuSelection(ProductSelection? selection, int index) {
    productSelectionIndex.sink(index);
    subItemSelected = 0;
    if (selection != null) {
      for (var element in selection.items.where((f) => f.product == null)) {
        element.product = repository.products.firstWhere((f) => f.id == element.productId);
      }
    }
    productSelection.sink(selection);
  }

  addSubItem(Product product) {
    if (productSelection.value == null) return;
    String employeeId = loggedInEmployee.id;
    invoice.value.lines.last.addSubItem(
      product,
      productSelectionIndex.value,
      employeeId,
      invoice.value.isInclusiveTax,
      qty: 1,
    );
    invoice.value.lineUpdated.sink(invoice.value.lines.length - 1);
    subItemSelected++;
    if (product.type == "menuItem") {
      if (product.optionGroups.isNotEmpty) {
        product.optionGroups.sort((a, b) {
          return a.index > b.index ? 1 : -1;
        });

        OptionGroup optionGroupTemp = repository.optionGroups.firstWhere((f) => f.id == product.optionGroups[0].optionGroupId);

        currentOptionGroups = product.optionGroups;
        loadOptionGroup(optionGroupTemp, 0);
      } else {
        checkNextSelection();
      }
    } else {
      checkNextSelection();
    }
  }

  checkNextSelection() {
    if (subItemSelected >= productSelection.value!.noOfSelection) {
      finishMenuSelection();
    }
  }

  backMenuSelection() {
    if (productSelection.value == null) return;

    if (subItemSelected > 0) {
      subItemSelected--;
      invoice.value.lines.last.deleteLastSubItem();
    } else {
      productSelectionIndex.value--;
      invoice.value.lines.last.deleteSubItemWithLevel(productSelectionIndex.value);
      loadMenuSelection(currentSelections[productSelectionIndex.value], productSelectionIndex.value);
    }
    invoice.value.lineUpdated.sink(invoice.value.lines.length - 1);

    checkNextSelection();
  }

  cancelMenuSelection() {
    invoice.value.deleteLastLine();
    invoice.value.lineUpdated.sink(1);
    productSelection.sink(null);
  }

  finishMenuSelection() {
    if (productSelection.value == null) return;
    if (productSelection.value!.noOfSelection > subItemSelected) return;
    productSelectionIndex.value++;
    if (currentSelections.length > productSelectionIndex.value) {
      loadMenuSelection(currentSelections[productSelectionIndex.value], productSelectionIndex.value);
    } else {
      productSelection.sink(null);
    }
  }

  changeService(Service service) async {
    selectedService.sink(service);
    //invoice.value.changeService(service);

    if (service.chargeId != null) {
      checkServiceSurcharge();
    }

    _serviceChangeController.sink.add(service.id);
    return service.id;
  }

  checkServiceSurcharge() {
    Surcharge? surcharge = repository.surcharges.firstWhereOrNull((f) => f.id == selectedService.value.chargeId);

    if (surcharge != null) invoice.value.addSurcharge(surcharge);
  }

  showOrderOptions() {
    orderPageOption.sink(OrderPageOption());
  }

  showDiscountDialog() async {
    if (invoice.value.discountAmount > 0) {
      invoice.value.removeDiscount();
      orderPageOption.reSink();
      return;
    }

    Discount? discount = await DialogService().discountListDialog("Discount Order", repository.discounts);
    if (discount != null) {
      invoice.value.addDiscount(discount);
      orderPageOption.reSink();
    }
  }

  showSurchargeDialog() async {
    if (invoice.value.chargeAmount > 0) {
      invoice.value.removeSurcharge();
      orderPageOption.reSink();
      return;
    }

    Surcharge? surcharge = await DialogService().surchargeListDialog(repository.surcharges);
    if (surcharge != null) {
      invoice.value.addSurcharge(surcharge);
      orderPageOption.reSink();
    }
  }

  scheduleOrder() async {
    DateTime? scheduleAt = await DialogService().dateTimePicker("Schedule Order");
    if (scheduleAt != null) {
      invoice.value.scheduleTime = scheduleAt;
      invoice.value.headerUpdate.sink(true);
    }
  }

  voidTicket() async {
    // if (!await Privilege().checkLogin(Security.voidTicket)) return;

    if (invoice.value.id == "") return;

    bool res = await GetIt.instance.get<DialogService>().confirmationDialog("Void Ticket".tr(), "Are you sure you want to void ticket ?".tr());

    if (!res) return;

    bool waste = await GetIt.instance.get<DialogService>().confirmationDialog("Waste Product".tr(), "Waste?".tr());
    String? voidReason;
    String employeeId = loggedInEmployee.id;

    if (repository.preferences != null && repository.preferences!.options.voidedItemNeedExplanation) {
      voidReason = await GetIt.instance.get<DialogService>().voidReasonDialog(reasons: repository.preferences!.voidReasons);
      if (voidReason != null && voidReason != "") {
        for (var line in invoice.value.lines) {
          if (line.remainQty > 0) {
            line.voidQty(line.remainQty, employeeId, waste: waste, voidReason: voidReason);
          }
        }
      } else {
        await GetIt.instance.get<DialogService>().alertDialog("Void Reason", "Void reason is required");
        return;
      }
    } else {
      for (var line in invoice.value.lines) {
        if (line.remainQty > 0) {
          line.voidQty(line.remainQty, employeeId, waste: waste, voidReason: voidReason);
        }
      }
    }

// before calculate send the invoice to capture data
    // ignore: unused_local_variable
    String invoiceNumber = invoice.value.invoiceNumber ?? invoice.value.id;
    // ignore: unused_local_variable
    double total = invoice.value.total;

    invoice.value.chargeAmount = 0;
    invoice.value.discountAmount = 0;
    invoice.value.isDirty = true;
    invoice.value.calculateTotal();

    if (await saveOrder(exitPage: true)) {
      GetIt.instance.get<DialogService>().alertDialog("Void Ticket".tr(), "Void Successfully".tr());
    }
  }

  searchProducts(String branchId) async {
    ValueNotifier<List<ProductList>> productsNotifier = ValueNotifier<List<ProductList>>([]);
    int currentPage = 1;
    bool hasMorePages = true;

    // Load the first page with the search term
    List<ProductList> firstPageProducts = await MenuService().getProductsByBranchId(branchId, page: currentPage);
    productsNotifier.value = List.from(productsNotifier.value)..addAll(firstPageProducts);
    dialogService.searchword.addListener(() async {
      if (dialogService.searchword.value != "") {
        List<ProductList> firstPageProducts1 = await MenuService().getProductsByBranchId(branchId, searchTerm: dialogService.searchword.value);
        productsNotifier.value = List.from(productsNotifier.value)..addAll(firstPageProducts1);
      }
    });
    // Create a ScrollController to monitor the scroll position
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent - scrollController.position.pixels < 200) {
        // Load the next page when the user scrolls to the bottom
        if (hasMorePages) {
          currentPage++;
          List<ProductList> nextPageProducts = await MenuService().getProductsByBranchId(branchId, page: currentPage);
          if (nextPageProducts.isEmpty) {
            hasMorePages = false;
          } else {
            productsNotifier.value = List.from(productsNotifier.value)..addAll(nextPageProducts);
          }
        }
      }
    });

    // Open the dialog with the first page products
    List<ProductList> products = await dialogService.showProductList(
      productsNotifier,
      scrollController: scrollController,
      checkAvailabilty: (product) async {
        List<Branch>? allBranches = await BranchService().getBranchList();
        List<ProductBranchAvailability> branches = [];
        if (allBranches != null) {
          for (var branch in allBranches) {
            branches.add(ProductBranchAvailability(branch: branch.name, onHand: product.onHand));
          }
        }
        dialogService.productAvailabilty(product, branches);
      },
      onScroll: () {},
      searchController: StreamController<String>.broadcast(), // Pass the searchController
    );

    ProductList? selectedProduct = products.isNotEmpty ? products.first : null;
    if (selectedProduct != null) {
      Product? productSel = await MenuService().getProduct(selectedProduct.id);

      if (productSel != null) {
        addProduct(productSel);
      }
    }
  }

/*
 
 
 searchProducts1(String id) async {
  DialogService dialogService = DialogService();

  List<Product> productsByBranch = await MenuService().getMenuProductsByBranch(branch.id);
  
  // Convert List<Product> to ValueNotifier<List<Product>>
  ValueNotifier<List<Product>> productsNotifier = ValueNotifier<List<Product>>(productsByBranch);
 int currentPage = 1;
   bool hasMorePages = true;
    List<Product> firstPageProducts = await MenuService().getMenuProductsByBranch(branch.id, page: currentPage);
   productsNotifier.value = List.from(productsNotifier.value)..addAll(productsByBranch); 

  // // Create a ScrollController to monitor the scroll position
   ScrollController scrollController = ScrollController();
  scrollController.addListener(() async {
   
     if (scrollController.position.maxScrollExtent - scrollController.position.pixels < 200) {
      // Load the next page when the user scrolls to the bottom
      if (hasMorePages)  { print(productsNotifier.value.first.isSelected);
        currentPage++;
        List<Product> nextPageProducts = await MenuService().getMenuProductsByBranch(branch.address, page: currentPage);
         if (nextPageProducts.isEmpty) {
         hasMorePages = false;
        } else {
          productsNotifier.value = List.from(productsNotifier.value)..addAll(nextPageProducts);
       }
       }
   }
 });
  // show list of product by branch
  List<Product> products = await dialogService.showProductList(
    productsNotifier,
    scrollController: _scrollController,
    checkAvailabilty: (product) async {
      List<Branch>? allBranches = await BranchService().getBranchList();
      List<ProductBranchAvailability> branches = [];
      if (allBranches != null) {
        for (var branch in allBranches) {
          branches.add(ProductBranchAvailability(branch: branch.name, onHand: product.onHand));
        }
      }
      dialogService.productAvailabilty(product, branches);
    }, onScroll: () {  },
  );

  // get full product details
  if (products.isNotEmpty) {
    addProduct(products[0]);
  }
} */

  void addProducts(List<Product> products) {
    for (var product in products) {
      addProduct(product);
    }
  }

  showNote() async {
    String? res = await DialogService().noteDialog(initValue: invoice.value.note);
    if (res != null) {
      invoice.value.note = res;
      invoice.value.headerUpdate.sink(true);
    }
  }

  adjGuests() async {
    double guests = await DialogService().numberDialog("Guest Count") ?? 0;
    invoice.value.guests = guests.toInt();
  }

  // showCustomersList() async {
  //   CustomerPick? customerPick = await DialogService().showCustomerList();
  //   if (customerPick == null) return;
  //   if (customerPick.action == CustomerPickAction.add) {
  //     addCustomer();
  //   } else if (customerPick.action == CustomerPickAction.pick &&
  //       customerPick.customer != null) {
  //     selectCustomer(customerPick);
  //   } else if (customerPick.action == CustomerPickAction.edit &&
  //       customerPick.customer != null) {
  //     editCustomer(customerPick);
  //   }
  // }

  // addCustomer() async {
  //   // if (!await Privilege().checkLogin(Security.addCustomer)) return;
  //   DialogService dialogService = DialogService();
  //   String phone = await dialogService.phoneDialog("Enter Phone Number");
  //   if (phone.isEmpty) return;
  //   phone = Phone().getPhoneNumber(phone);
  //   String? msg = Validation().validatePhone(phone);
  //   if (msg != null) {
  //     dialogService.alertDialog("", "invalid phone number");
  //     return;
  //   }
  //   Customer? customer = await GetIt.instance
  //       .get<NavigationService>()
  //       .goToCustomerPage(
  //           await CustomerPageBloc.fromPhone(phone, selectMode: true));

  //   if (customer != null) {
  //     CustomerAddress? address =
  //         customer.addresses.firstWhereOrNull((f) => f.isSelected);
  //     double deliveryCharge = checkDeliveryCharge(address);
  //     invoice.value.addCustomer(customer, customer.phone, address,
  //         deliveryCharge: deliveryCharge);
  //     invoice.value.headerUpdate.sink(true);
  //   }
  // }

  // editCustomer(CustomerPick customerPick) async {
  //   // if (!await Privilege().checkLogin(Security.editCustomer)) return;

  //   Customer? customer =
  //       await GetIt.instance.get<NavigationService>().goToCustomerPage(
  //             await CustomerPageBloc.fromPhone(
  //               customerPick.customer!.phone,
  //               selectMode: true,
  //             ),
  //           );

  //   if (customer != null) {
  //     CustomerAddress? address =
  //         customer.addresses.firstWhereOrNull((f) => f.isSelected);
  //     double deliveryCharge = checkDeliveryCharge(address);
  //     invoice.value.addCustomer(customer, customer.phone, address,
  //         deliveryCharge: deliveryCharge);
  //     invoice.value.headerUpdate.sink(true);
  //   }
  // }

  editAddress() async {
    if (invoice.value.customer == null) return;
    // GetIt.instance
    //     .get<DialogService>()
    //     .showToastMessage("Please select your address");
    Customer? customer = await GetIt.instance.get<NavigationService>().goToCustomerPage(
          await CustomerPageBloc.fromPhone(
            invoice.value.customerContact,
            invoice.value.service!,
            invoice.value.service!.name,
            selectMode: true,
            showPurchaseHistory: false,
          ),
        );

    if (customer != null) {
      CustomerAddress? address = customer.addresses.firstWhereOrNull((f) => f.isSelected);
      double deliveryCharge = checkDeliveryCharge(address, invoice.value.service!);
      invoice.value.addCustomer(customer, customer.phone, address, deliveryCharge: deliveryCharge);
      invoice.value.headerUpdate.sink(true);
    }
  }

  // selectCustomer(CustomerPick customerPick) async {
  //   CustomerAddress? address =
  //       customerPick.customer!.addresses.firstWhereOrNull((f) => f.isSelected);
  //   double deliveryCharge = checkDeliveryCharge(address);
  //   invoice.value.addCustomer(
  //       customerPick.customer!, customerPick.customer!.phone, address,
  //       deliveryCharge: deliveryCharge);
  //   invoice.value.headerUpdate.sink(true);
  // }

  checkInvoicePayment(Invoice temp) {
    if (temp.paid()) {
      //if there is multiple invoice then remove the paid invoice
      if (invoices.value.isNotEmpty) {
        invoices.value.remove(invoices.value.firstWhereOrNull((f) => f.id == temp.id));
        //if there are no more invoices available
        if (invoices.value.isEmpty) {
          saveFinished();
        } else {
          //update the ui for the multi invoice
          invoices.sink(invoices.value);
          //update invoice to select first one
          invoice.sink(invoices.value[0]);
        }
      } else {
        //if there is single invoice
        saveFinished();
      }
    } else {
      //if the invoice is partialy paid , update the ui to show the invoice
      invoices.value.remove(invoices.value.firstWhereOrNull((f) => f.id == temp.id));
      invoices.value.add(temp);
      invoices.reSink();
      invoice.sink(temp);
    }
  }

  validate() async {
    if (selectedService.value.type == "Delivery") {
      if (invoice.value.customer == null) {
        //addCustomer();
        return false;
      } else if (invoice.value.customerAddress == null) {
        editAddress();
        return false;
      }
    }

    return true;
  }

  Future<bool> saveOrder({bool exitPage = true, bool printReceipt = false, bool printAllTicket = false}) async {
    DialogService().showLoading();
    try {
      //validate
      if (!(await validate())) {
        return false;
      }

      if (invoices.value.isEmpty) {
        //apply hold for
        for (var element in invoice.value.lines.where((f) => f.holdFor > 0)) {
          element.holdItemUntil(DateTime.now().add(Duration(minutes: element.holdFor)));
        }

        bool isNew = invoice.value.id == "";
        if (await saveInvoice(printReceipt: isNew || printReceipt)) {
          //TODO check if order print on sent
          DialogService().hideLoading();
          if (exitPage) saveFinished();
          return true;
        }
      }
      return false;
    } finally {
      // DialogService().hideLoading();
    }
  }

  saveWithAutoHold() {
    int maxPreprationTime = invoice.value.lines.where((f) => f.id == "").reduce((value, element) => value.product.serviceTime > element.product.serviceTime ? value : element).product.serviceTime;

    for (var element in invoice.value.lines.where((f) => f.id == "" && f.product.serviceTime > 0)) {
      if ((maxPreprationTime - element.product.serviceTime) > 0) {
        element.holdItemUntil(DateTime.now().add(Duration(minutes: maxPreprationTime - element.product.serviceTime)));
      }
    }

    saveOrder();
  }

  Future<bool> saveInvoice({bool printReceipt = false}) async {
    if (invoice.value.lines.isEmpty) {
      return false;
    }
    invoice.value.serviceId = selectedService.value.id; // Ensure serviceId is set
    Invoice? savedInvoice = await OrderService().saveInvoice(invoice.value, branch.id);
    if (savedInvoice != null) {
      invoice.sink(savedInvoice);
      return true;
    } else {
      //await GetIt.instance.get<NavigationService>().gotoHomePage();

      return true;
    }
  }

  printTicket() {
    saveOrder(exitPage: false, printReceipt: true);
  }

  printAllTicket() {
    saveOrder(exitPage: false, printReceipt: true);
  }

  saveFinished() async {
    _resetOrder();
    GetIt.instance.get<NavigationService>().goBackToHomePage();
  }

  _resetOrder() {
    Invoice temp = Invoice();
    temp.isInclusiveTax = GetIt.instance.get<Repository>().preferences!.isInclusiveTax;
    temp.serviceId = selectedService.value.id;
    temp.service = selectedService.value;
    temp.employeeId = loggedInEmployee.id;
    temp.employee = loggedInEmployee;
    temp.smallestCurrency = GetIt.instance.get<Repository>().preferences!.smallestCurrency;
    temp.roundingType = GetIt.instance.get<Repository>().preferences!.roundingType;

    // ignore: no_leading_underscores_for_local_identifiers
    List<Invoice> _invoices = [];
    _invoices.add(temp);
    invoice.sink(temp);

    if (invoice.value.service != null && invoice.value.service!.type == "DineIn") {
      invoices.sink(_invoices);
    } else {
      invoices.sink([]);
    }
  }

  goBack() {
    if (repository.terminal != null && repository.terminal!.settings.quickService) {
      saveFinished();
    } else {
      // GetIt.instance.get<NavigationService>().goBack(null);
    }
  }
}
