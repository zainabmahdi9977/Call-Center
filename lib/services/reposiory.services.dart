// ignore_for_file: non_constant_identifier_names
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:invo_5_widget/invo_5_widget.dart';
import 'package:invo_models/invo_models.dart';
import 'package:invo_models/models/PriceLabel.dart';
import 'package:newcall_center/services/discount.services.dart';
import 'package:newcall_center/services/menu.services.dart';

import 'package:newcall_center/services/services.dart';
import 'package:newcall_center/utils/dialog.service.dart';

import '../models/branch.models.dart';
import 'branch.services.dart';
import 'employee.services.dart';
import 'login.services.dart';

import 'option.services.dart';

import 'price.services.dart';
import 'privielg.services.dart';
import 'company.dart';

import 'tex.services.dart';

class Repository {
  late String token;

  List<Service> services = [];
  List<Address> companyAddressess = [];
  List<PriceLabel> priceLabels = [];
  List<Surcharge> surcharges = [];
  List<Option> options = [];
  List<OptionGroup> optionGroups = [];

  List<Employee> employees = [];
  List<Branch> branches = [];
  List<Tax> taxes = [];
  List<Product> products2 = [];
  List<Product> products = [];
  List<EmployeePrivilege> privileges = [];
  List<CoveredAddress> Addresses = [];
  // @override
  // List<Menu> menus = [];

  // @override
  // List<MenuSection> menuSections = [];

  List<Discount> discounts = [];

  Terminal? terminal;

  Preferences? preferences;

  Repository() {
    loadToken();
  }

  loadToken() async {
    token = (await LoginServices().getToken()) ?? '';
  }

  Future<void> load() async {
    try {
      preferences = await company().getCompanyPreferences();
      priceLabels = await Price().getPriceLabelList();
      preferences!.deliveryAddresses = (await company().getCoveredAddresses());
      surcharges = (await TaxService().getSurchargeList())!;
      options = (await OptionService().getOptions())!;
      optionGroups = (await OptionService().getOptionGroupList())!;
      services = await ServicesApi().getServices();
      employees = (await EmployeeService().getEmployeeList())!;
      branches = (await BranchService().getBranchList())!;
      taxes = (await TaxService().loadTax())!;
      // discounts =
      //products2 = (await MenuService().getProductsByBranchId(""));
      privileges = (await PrivielgService().getEmployeePrivielges())!;
      discounts = (await DiscountService().loadDiscount());
      if (preferences != null) {
        WidgetUtilts.currencySymbol = preferences!.settings.currencySymbol;
        WidgetUtilts.afterDecimal = preferences!.settings.afterDecimal;
      }
      products = (await MenuService().menuProductList());
    } catch (e) {
      //show error msg to the user
      GetIt.instance.get<DialogService>().alertDialog("Error".tr(), "Connection failure or server error".tr());
      return;
    }
  }
}
