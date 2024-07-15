// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:newcall_center/utils/dialog.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/login.page.bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _passwordVisible = false;
  String error = "";
  LoginPageBloc bloc = LoginPageBloc();
  String currentServer = 'Local';

  final Map<String, String> serverNames = {
    'https://productionback.invopos.co': 'Production',
    'https://testBack.invopos.co': 'Test',
    'https://devBack.invopos.co': 'Development',
    'http://10.2.2.60:3001': 'Local',
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
    //var _focusNode = FocusNode();
  }

  load() async {
    _loadCurrentServer();
    if (await bloc.isTokenValid()) {
      Navigator.of(context).popAndPushNamed("Main");
    }
  }

  Future<void> _loadCurrentServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('serverURL') ?? 'https://productionback.invopos.co';
    setState(() {
      currentServer = serverNames[url] ?? 'Production';
    });
  }

  Future<void> _changeServerDialog(BuildContext context) async {
    await DialogService().changeServerDialog(context);

    _loadCurrentServer();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Material(
              child: Container(
                padding: const EdgeInsets.all(25.0),
                color: Colors.grey[200],
                child: Center(
                    child: SingleChildScrollView(
                  child: Material(
                    elevation: 3,
                    child: SizedBox(
                        width: 300,
                        height: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Image.asset(
                                  "assets/Images/call_center_logo.png",
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 6),
                                child: Column(
                                  children: [
                                    Text("Login", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                                    Text("Sign In to your account", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 140,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 63,
                                          child: Form(
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            child: TextFormField(
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                              controller: emailController,
                                              onFieldSubmitted: (value) async {
                                                bloc.email = value;
                                              },
                                              onChanged: (value) {
                                                bloc.email = value;
                                              },
                                              decoration: const InputDecoration(
                                                  errorStyle: TextStyle(
                                                    fontSize: 12.0,
                                                  ),
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(9.0))),
                                                  contentPadding: EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                  ),
                                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 221, 219, 219))),
                                                  prefixIcon: Icon(Icons.person, size: 16),
                                                  labelText: 'Email',
                                                  labelStyle: TextStyle(color: Colors.grey)),

                                              validator: MultiValidator(
                                                [
                                                  RequiredValidator(errorText: '     Enter email address'),
                                                  EmailValidator(errorText: '     Please correct email filled'),
                                                ],
                                              ).call,
                                              // validator: (value) {
                                              //   if (value.isEmpty) {
                                              //     return "* Required";
                                              //   } else
                                              //     return null;
                                              // },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 63,
                                      child: Form(
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        child: Theme(
                                          data: themeData.copyWith(inputDecorationTheme: themeData.inputDecorationTheme.copyWith(
                                            prefixIconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                                              if (states.contains(MaterialState.focused)) {
                                                return Colors.blue;
                                              }
                                              if (states.contains(MaterialState.error)) {
                                                return Colors.red;
                                              }
                                              return Colors.grey;
                                            }),
                                          )),
                                          child: TextFormField(
                                            textInputAction: TextInputAction.none,
                                            obscureText: !_passwordVisible,
                                            onFieldSubmitted: (value) async {
                                              bloc.password = value;
                                              if (await bloc.login()) {
                                                Navigator.of(context).popAndPushNamed("Main");
                                              }
                                            },
                                            onChanged: (value) {
                                              bloc.password = value;
                                            },
                                            controller: passwordController,
                                            decoration: InputDecoration(
                                              errorStyle: const TextStyle(fontSize: 12.0),
                                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(9.0))),
                                              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 221, 219, 219))),
                                              prefixIcon: const Icon(
                                                Icons.lock,
                                                size: 16,
                                              ),
                                              suffixIcon: SizedBox(
                                                child: IconButton(
                                                  splashRadius: Checkbox.width,
                                                  icon: Icon(
                                                    size: 16,
                                                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                                    color: _passwordVisible ? Colors.blue : Colors.grey,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _passwordVisible = !_passwordVisible;
                                                    });
                                                  },
                                                ),
                                              ),

                                              labelText: 'Password',
                                              labelStyle: const TextStyle(color: Colors.grey),
                                              // errorText: loginfail ? 'Connecting Service failed' : null,
                                            ),
                                            validator: MultiValidator(
                                              [
                                                RequiredValidator(errorText: 'Please enter Password'),
                                                MinLengthValidator(6, errorText: 'Password must be atlist 6 digit'),
                                                // PatternValidator(r'(?=.*?[#!@$%^&*-])',
                                                // errorText:
                                                //     'Password must be atlist one special character')
                                              ],
                                            ).call,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StreamBuilder(
                                  stream: bloc.errorMsg.stream,
                                  builder: (context, snapshot) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(bloc.errorMsg.value,
                                          style: const TextStyle(
                                            color: Colors.red, // Set the text color to red
                                          )),
                                    );
                                  }),
                              ElevatedButton(
                                onPressed: () async {
                                  //  LoginPageBloc bloc = GetIt.instance.get<LoginPageBloc>();
                                  // await LoginServices().getToken().toString();
                                  // print('${(await LoginServices().getToken())}');
                                  // TaxService().loadTax();
                                  // AddressServices().getCompanyAddresses();
                                  // Price().getPriceLabelList(); //1done
                                  // TaxService().getSurchargeList(); //2done
                                  // OptionService().getOptions(); //3done
                                  // OptionService().getOptionGroupList(); //4done
                                  // await Repository().addServices();

                                  if (await bloc.login()) {
                                    bloc.errorMsg.value = '';
                                    Navigator.of(context).popAndPushNamed("Main");
                                    setState(() {});
                                  }

                                  // LoginPageBloc().login(
                                  //     emailController.text, passwordController.text);

                                  // print("$passwordController");
                                  // if (_formkey.currentState!.validate()) {
                                  //   print('form submiitted');
                                  // context.go('/Main');
                                  //

                                  // GoRouter.of(context).go('/HomePage');
                                  // GoRouter.of(context)
                                  //     .go(RouteConstants.mainRouteName.toString());
                                  // context.go(RouteConstants.mainRouteName.toString(),
                                  //     extra: '/MainPage');
                                  // }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[300],
                                ),
                                child: const SizedBox(
                                    width: 210,
                                    height: 39,
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'LOGIN',
                                        ))),
                              ),
                              // TextButton(
                              //   onPressed: () {
                              //     BranchService().getBranchList();
                              //   },
                              //   child: Text(
                              //     'Forgot password?',
                              //     style: TextStyle(color: Colors.blue[300]),
                              //   ),
                              // ),
                            ],
                          ),
                        )),
                  ),
                )),
              ),
            ),
            Positioned(
              top: 20.0,
              right: 20.0,
              child: ElevatedButton(
                onPressed: () async {
                  await _changeServerDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300],
                ),
                child: Text(
                  currentServer,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
