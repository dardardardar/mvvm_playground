import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit.dart';
import 'package:mvvm_playground/features/cubit/auth_cubit_data.dart';
import 'package:mvvm_playground/features/pages/main_menu_page.dart';
import 'package:mvvm_playground/features/state/base_state.dart';
import 'package:mvvm_playground/widgets/navigation_bar.dart';
import 'package:mvvm_playground/widgets/snackbar.dart';

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
      appBar: appBar(title: 'Login', isCenter: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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

                showSnackbar(context, message: 'Berhasil Login');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainMenuPage()),
                );
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    style: TextStyle(
                      color: primaryColor, // Change this to your desired color
                    ),
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          sendAuth();
                        }
                      },
                      child: Text(
                        buttontext,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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
