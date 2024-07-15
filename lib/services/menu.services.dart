// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:invo_models/models/Menu.dart';

import 'package:http/http.dart' as http;
import 'package:invo_models/models/MenuSection.dart';

import 'package:invo_models/models/Product.dart';
import 'package:invo_models/models/custom/productList.dart';

import 'login.services.dart';
import 'varHttp.dart';

class MenuService {
  Future<List<Menu>> loadMenus(branchId) async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    try {
      final response = await http.get(
        Uri.parse('${myHTTP}menu/getMenuList/$branchId'),
        headers: {
          "Api-Auth": token.toString()
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);

        if (map['success']) {
          List<Menu> menus = [];
          for (var element in map['data']) {
            menus.add(Menu.fromJson(element));
          }
          return menus;
        } else {
          debugPrint(map['msg']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<MenuSection>> getMenu(String menuId) async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(
      Uri.parse('${myHTTP}menu/getMenu/$menuId'),
      headers: {
        "Api-Auth": token.toString()
      },
      // body: jsonEncode({'menus': menus})
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<MenuSection> menus = [];
        if (map['data']['sections'] != null) {
          for (var element in map['data']['sections']) {
            menus.add(MenuSection.fromJson(element));
          }
        }
        return menus;
      }
    }
    return [];
  }

  Future<List<Product>> getMenuProducts({required String branchId, required String sectionId}) async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    List<Product> menuProducts = [];
    final response = await http.post(Uri.parse('${myHTTP}menu/getMenuProducts'), headers: {
      "Api-Auth": token.toString()
    }, body: {
      "branchId": branchId,
      "sectionId": sectionId
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        for (var element in map['data']) {
          menuProducts.add(Product.fromJson(element));
        }
      }
    }

    return menuProducts;
  }

  Future<List<Product>> menuProductList() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    List<Product> menuProductList = [];
    final response = await http.post(Uri.parse('${myHTTP}menu/getMenuProducts'), headers: {
      "Api-Auth": token.toString()
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        for (var element in map['data']) {
          menuProductList.add(Product.fromJson(element));
        }
      }
    }

    return menuProductList;
  }

  Future<Product?> getProduct(String id) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;
    final response = await http.get(Uri.parse('${myHTTP}menu/getProduct/$id'), headers: {
      "Api-Auth": token.toString()
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        dynamic productData = map['data'];
        if (productData != null) {
          return Product.fromJson(productData);
        }
      }
    }
    return null;
  }

  Future<List<MenuSection>?> getMenuSections() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.post(Uri.parse('${myHTTP}menu/getMenuSectionList'),
        headers: {
          "Api-Auth": token.toString()
        },
        body: jsonEncode({}));
    if (response.statusCode == 200) {
      Map<String, MenuSection> map = jsonDecode(response.body);
      if (map['success'] != null) {
        List<MenuSection> menus = [];

        // for (var element in map['data']) {
        //   menus.add(MenuSection.fromJson(element));
        // }

        return menus;
      }
      throw Exception('Failed to load getMenuSections');
    }
    return null;
  }

  ///////////ShopController

  Future<List<Product>?> getProductTags() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.post(Uri.parse('${myHTTP}menu/getProductTags'), headers: {
      "Api-Auth": token.toString()
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<Product> productTags = [];
        for (var element in map['data']) {
          productTags.add(Product.fromJson(element));
        }
        return productTags;
      }
    } else {
      throw Exception('Failed to load getProductTags');
    }
    return null;
  }

  Future<List<Product>?> getCatgorieProductsTags() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.post(Uri.parse('${myHTTP}menu/getCatgorieProductsTags'), headers: {
      "Api-Auth": token.toString()
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<Product> catgorieProductsTags = [];
        for (var element in map['data']) {
          catgorieProductsTags.add(Product.fromJson(element));
        }
        return catgorieProductsTags;
      }
    } else {
      throw Exception('Failed to load getCatgorieProductsTags');
    }
    return null;
  }

  Future<List<Product>?> getCompanyCategories() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.get(Uri.parse('${myHTTP}menu/getCompanyCategories'), headers: {
      "Api-Auth": token.toString()
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<Product> companyCategories = [];
        for (var element in map['data']) {
          companyCategories.add(Product.fromJson(element));
        }
        return companyCategories;
      }
    } else {
      throw Exception('Failed to load getCompanyCategories');
    }
    return null;
  }

  Future<List<Product>?> getCategoriesProducts() async {
    String token = (await LoginServices().getToken())!;
    String myHTTP = await getServerURL();
    final response = await http.post(Uri.parse('${myHTTP}menu/getCategoriesProducts'), headers: {
      "Api-Auth": token.toString()
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        List<Product> categoriesProducts = [];
        for (var element in map['data']) {
          categoriesProducts.add(Product.fromJson(element));
        }
        return categoriesProducts;
      }
    } else {
      throw Exception('Failed to load getCategoriesProducts');
    }
    return null;
  }

  Future<List<ProductList>> getProductsByBranchId(String branchId, {String searchTerm = '', int page = 1, int limit = 100}) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;
    List<ProductList> products = [];

    final response = await http.post(
      Uri.parse('${myHTTP}menu/getProductsByBranchId'),
      headers: {
        "Api-Auth": token.toString()
      },
      body: {
        "branchId": branchId,
        "searchTerm": searchTerm,
        "page": page.toString(),
        "limit": limit.toString(),
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      if (map['success']) {
        for (var element in map['data']['records']) {
          products.add(ProductList.fromMap(element));
        }
      }
    }

    return products;
  }

  Future<List<Product>> getMenuProductsByBranch(String branchId, {String searchTerm = '', int page = 1, int limit = 100}) async {
    String myHTTP = await getServerURL();
    String token = (await LoginServices().getToken())!;
    List<Product> menuProducts = [];
    final response = await http.post(
      Uri.parse('${myHTTP}menu/getProductsByBranchid'),
      headers: {
        "Api-Auth": token.toString()
      },
      body: {
        "branchId": branchId,
        "searchTerm": searchTerm,
        "page": page.toString(),
        "limit": limit.toString(),
      },
    );

    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        if (map['success']) {
          var data = map['data']['records'];
          for (var element in data) {
            menuProducts.add(Product.fromJson(element));
          }
        }
      }
      return menuProducts;
    } catch (e) {
      throw Exception(e);
    }
  }

  getBranchAvailabilty(String id) {}
}
