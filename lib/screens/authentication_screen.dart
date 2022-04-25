import 'package:flutter/material.dart';
import 'package:room_rental_app/services/firebase_auth.dart';
import 'package:room_rental_app/utils/constants.dart';
import 'package:room_rental_app/utils/device_size.dart';
import 'package:room_rental_app/utils/loading.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({Key? key}) : super(key: key);

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  TextEditingController userFullName = TextEditingController();
  TextEditingController userContactNumber = TextEditingController();
  TextEditingController userProfession = TextEditingController();
  TextEditingController userBelongsTo = TextEditingController();
  final AuthService _authService = AuthService();

  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  bool loginState = true;
  bool isLoading = false;
  bool isHomeOwner = false;

  @override
  void didChangeDependencies() {
    precacheImage(const AssetImage("images/real_estate.jpg"), context);
    precacheImage(const AssetImage("images/no_result_found.jpg"), context);
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    userEmail.dispose();
    userPassword.dispose();
    userFullName.dispose();
    userContactNumber.dispose();
    userProfession.dispose();
    super.dispose();
  }

  validateAndRegister(context) async {
    if (_signUpFormKey.currentState!.validate()) {
      _authService.setDataforUser(
          userFullName.text,
          userContactNumber.text,
          userProfession.text,
          isHomeOwner,
          userEmail.text,
          0,
          userBelongsTo.text);
      setState(() {
        isLoading = true;
      });
      dynamic result =
          await _authService.signUpUser(userEmail.text, userPassword.text);
      if (result == null) {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('We got an error'),
            ),
          );
        });
      }
    }
  }

  authenticateAndLogin(context) async {
    setState(() {
      isLoading = true;
    });
    dynamic result =
        await _authService.loginUser(userEmail.text, userPassword.text);
    if (result != 'valid') {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.toString()),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: isLoading
            ? Loading(false)
            : Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/real_estate.jpg',
                          // height: displayHeight(context)*0.4,
                          // width: displayWidth(context),
                          fit: BoxFit.contain,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    loginState = !loginState;
                                  });
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: displayWidth(context) * 0.065,
                                    fontWeight: FontWeight.w700,
                                    color: loginState
                                        ? Colors.indigo
                                        : darkGreyColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    loginState = !loginState;
                                  });
                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: displayWidth(context) * 0.065,
                                    fontWeight: FontWeight.w700,
                                    color: loginState
                                        ? darkGreyColor
                                        : Colors.indigo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: loginState
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 25),
                                      child: Form(
                                        key: _loginFormKey,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              style: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              autofocus: false,
                                              controller: userEmail,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                focusedBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                hintText: 'Enter Username',
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                labelText: 'Email',
                                                labelStyle: TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize:
                                                      formElementsSize(context),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              obscureText: true,
                                              style: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              autofocus: false,
                                              controller: userPassword,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                focusedBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                hintText: 'Enter Password',
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                labelText: 'Password',
                                                labelStyle: TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.050,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16.0),
                                              child: InkWell(
                                                onTap: () {
                                                  authenticateAndLogin(context);
                                                },
                                                child: Container(
                                                  height:
                                                      displayHeight(context) *
                                                          0.05,
                                                  width: displayWidth(context) *
                                                      0.2,
                                                  child: Center(
                                                    child: Text(
                                                      'Login',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: displayWidth(
                                                                context) *
                                                            0.050,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: darkBlueColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 25),
                                      child: Form(
                                        key: _signUpFormKey,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Full Name Can't be Empty";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              style: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              keyboardType: TextInputType.name,
                                              autofocus: false,
                                              controller: userFullName,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                focusedBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                hintText: 'Alex Carry',
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                labelText: 'Full Name',
                                                labelStyle: TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize:
                                                      formElementsSize(context),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Contact Number Can't be Empty";
                                                } else if (value.length != 10) {
                                                  return "Mobile Number Should be of 10 digits!";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              style: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              autofocus: false,
                                              controller: userContactNumber,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                focusedBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                hintText: '1234567890',
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                labelText: 'Mobile Number',
                                                labelStyle: TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize:
                                                      formElementsSize(context),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Profession Can't be Empty";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              style: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              keyboardType: TextInputType.text,
                                              autofocus: false,
                                              controller: userProfession,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                focusedBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                hintText: 'Engineer / Student',
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                labelText: 'Profession',
                                                labelStyle: TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize:
                                                      formElementsSize(context),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Username Can't be Empty";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              style: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              autofocus: false,
                                              controller: userEmail,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                focusedBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                hintText:
                                                    'carryalex123@gmail.com',
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                labelText: 'Email',
                                                labelStyle: TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize:
                                                      formElementsSize(context),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Password Can't be Empty";
                                                } else if (value.length < 6) {
                                                  return "Password should be of atleast 6 characters";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              obscureText: true,
                                              style: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              autofocus: false,
                                              controller: userPassword,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                focusedBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                hintText: 'Enter Password',
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                labelText: 'Password',
                                                labelStyle: TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize:
                                                      formElementsSize(context),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Password Can't be Empty";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              style: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              autofocus: false,
                                              controller: userBelongsTo,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                focusedBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.indigo),
                                                ),
                                                hintText: 'Madhya Pradesh',
                                                hintStyle: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                labelText: 'Belongs To',
                                                labelStyle: TextStyle(
                                                  color: Colors.indigo,
                                                  fontSize:
                                                      formElementsSize(context),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Are you a Home Owner?',
                                                  style: TextStyle(
                                                      fontSize:
                                                          formElementsSize(
                                                              context),
                                                      color: isHomeOwner
                                                          ? Colors.indigo
                                                          : Colors
                                                              .grey.shade600),
                                                ),
                                                Switch(
                                                  value: isHomeOwner,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    isHomeOwner = !isHomeOwner;
                                                  }),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16.0),
                                              child: InkWell(
                                                onTap: () {
                                                  validateAndRegister(context);
                                                },
                                                child: Container(
                                                  height:
                                                      displayHeight(context) *
                                                          0.05,
                                                  width: displayWidth(context) *
                                                      0.25,
                                                  child: Center(
                                                    child: Text(
                                                      'Register',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: displayWidth(
                                                                context) *
                                                            0.050,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: darkBlueColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
