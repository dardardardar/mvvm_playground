import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit_data.dart';
import 'package:mvvm_playground/features/cubit/maps_cubit.dart';
import 'package:mvvm_playground/features/pages/main_menu_page.dart';
import 'package:mvvm_playground/features/response/trialConstant.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/helper/api.dart';
import 'package:mvvm_playground/widgets/buttons.dart';
import 'package:mvvm_playground/widgets/input.dart';
import 'package:mvvm_playground/widgets/snackbar.dart';
import 'package:mvvm_playground/widgets/typography.dart';

bool StatusCubit = false;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  String buttontext = 'Login';

  void sendAuth() async {
    setState(() {
      buttontext = 'Loading..';
    });
    context.read<AuthCubit>().sendAuth(
          _usernameController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              opacity: 0.5,
              image: AssetImage('assets/icons/images.jpeg'),
              fit: BoxFit.cover,
            )),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Form(
            key: _formKey,
            child: BlocConsumer<AuthCubit, authData>(
              listener: (context, state) {
                if (state.processAuth is LoadingState) {
                  setState(() {
                    buttontext = 'Loading..';
                    StatusCubit = true;
                  });
                  FocusScope.of(context).unfocus();
                } else if (state.processAuth is SuccessState) {
                  if (StatusCubit == true) {
                    showSnackbar(context,
                        message: 'Berhasil Login', status: Status.Success);
                    setState(() {
                      buttontext = 'Berhasil..';
                      StatusCubit = false;
                    });

                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                          builder: (context) => const MainMenuPage()),
                    );
                  }
                } else {
                  if (state.processAuth is GeneralErrorState) {
                    if (StatusCubit == true) {
                      showSnackbar(context,
                          message:
                              (state.processAuth as GeneralErrorState<dynamic>)
                                  .error,
                          status: Status.Error);
                    }
                  }
                  setState(() {
                    buttontext = 'Login';
                    StatusCubit = false;
                  });
                }
              },
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      displayText('Login', style: Styles.Display1Alt),
                      Visibility(
                        visible: (checkingTrial == 'Trial'),
                        child: Center(
                          child: Text(
                            'Aplikasi tidak dapat digunakan karena masa demo telah berakhir.',
                            style: subtitle.copyWith(
                                fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      InputFormField(
                        controller: _usernameController,
                        isDark: true,
                        label: 'Username',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      flatButton(
                          context: context,
                          title: buttontext,
                          backgroundColor: primaryColor,
                          onTap: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (buttontext == 'Login' &&
                                  (checkingTrial != 'Trial')) {
                                sendAuth();
                              }
                            }
                          },
                          icon: null)
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
