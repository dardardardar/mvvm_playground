import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit_data.dart';
import 'package:mvvm_playground/features/pages/main_menu_page.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/widgets/buttons.dart';
import 'package:mvvm_playground/widgets/input.dart';
import 'package:mvvm_playground/widgets/snackbar.dart';
import 'package:mvvm_playground/widgets/typography.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  String buttontext = 'Login';

  void sendAuth() {
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
                if (state.sendAuth is LoadingState) {
                  setState(() {
                    buttontext = 'Loading..';
                  });
                  FocusScope.of(context).unfocus();
                } else if (state.sendAuth is SuccessState) {
                  setState(() {
                    buttontext = 'Berhasil..';
                  });
                  showSnackbar(context,
                      message: 'Berhasil Login', status: Status.Success);

                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (context) => const MainMenuPage()),
                  );
                  setState(() {
                    buttontext = 'Login';
                  });
                } else {
                  setState(() {
                    buttontext = 'Login';
                  });
                  if (state.sendAuth is GeneralErrorState) {
                    showSnackbar(context,
                        message: 'Username Salah', status: Status.Error);
                  }
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
                      SizedBox(height: 32),
                      flatButton(
                          context: context,
                          title: 'Login',
                          backgroundColor: primaryColor,
                          onTap: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              sendAuth();
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
