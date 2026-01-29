import 'package:chat_app/core/model/user_model.dart';
import 'package:chat_app/screen/chat/chat_screen.dart';
import 'package:chat_app/shared/auth_service.dart';
import 'package:chat_app/shared/custom_button.dart';
import 'package:chat_app/shared/custom_text_form_field.dart';
import 'package:chat_app/shared/secure_storage_service.dart';
import 'package:chat_app/shared/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _phoneNumber = '';
  String _countryCode = '+20';

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  IconData suffixIcon = Icons.visibility_off_outlined;
  IconData suffixRegisterConfirmIcon = Icons.visibility_off_outlined;
  IconData suffixRegisterIcon = Icons.visibility_off_outlined;
  bool isPassword = true;
  bool isRegisterConfirmPassword = true;
  bool isRegisterPassword = true;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final savedEmail = await SecureStorageService.getDecryptedPassword(
        'saved_email',
      );
      final savedPassword = await SecureStorageService.getDecryptedPassword(
        'saved_password',
      );

      if (savedEmail != null && savedPassword != null) {
        setState(() {
          _loginEmailController.text = savedEmail;
          _loginPasswordController.text = savedPassword;
          isChecked = true;
        });
      }
    } catch (e) {
      print('Error loading saved credentials: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeProvider.backgroundColor,
            title: Text(
              _isLogin ? 'Login' : 'Create Account',
              style: TextStyle(color: themeProvider.textColor),
            ),
            actions: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: themeProvider.textColor,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  );
                },
              ),
            ],
          ),
          body: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Container(
                height: MediaQuery.of(context).size.height,
                color: themeProvider.backgroundColor,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      if (_isLogin)
                        _buildLoginForm(authService, themeProvider)
                      else
                        _buildRegisterForm(authService, themeProvider),

                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? 'Don\'t have an account?'
                                : 'Already have an account',
                            style: TextStyle(
                              fontSize: 16,
                              color: themeProvider.textColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin ? 'Create Account' : 'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: themeProvider.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(AuthService authService, ThemeProvider themeProvider) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          CustomTextFormField(
            controller: _loginEmailController,
            labelText: 'Email',
            prefixIcon: Icon(Icons.email, color: themeProvider.primaryColor),
            fillColor: themeProvider.cardColor,
            labelColor: themeProvider.textColor,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Email is invalid';
              }
              return null;
            },
            type: TextInputType.emailAddress,
          ),
          SizedBox(height: 15),
          CustomTextFormField(
            controller: _loginPasswordController,
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock, color: themeProvider.primaryColor),
            fillColor: themeProvider.cardColor,
            labelColor: themeProvider.textColor,
            obscureText: isPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  isPassword = !isPassword;
                  suffixIcon = isPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined;
                });
              },
              icon: Icon(suffixIcon, color: themeProvider.secondaryTextColor),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'The password must be at least 6 characters long.';
              }
              return null;
            },
            type: TextInputType.visiblePassword,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
              ),
              Text(
                'Remember me',
                style: TextStyle(color: themeProvider.textColor),
              ),
            ],
          ),

          SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                    onPressed: () async {
                      if (_loginFormKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          UserModel? user = await authService
                              .signInWithEmailAndPassword(
                                email: _loginEmailController.text,
                                password: _loginPasswordController.text,
                              );
                          setState(() {
                            _isLoading = false;
                          });

                          if (user != null) {
                            if (isChecked) {
                              await SecureStorageService.storeEncryptedPassword(
                                'saved_email',
                                _loginEmailController.text,
                              );
                              await SecureStorageService.storeEncryptedPassword(
                                'saved_password',
                                _loginPasswordController.text,
                              );
                            } else {
                              await SecureStorageService.storage.delete(
                                key: 'saved_email',
                              );
                              await SecureStorageService.storage.delete(
                                key: 'saved_password',
                              );
                            }

                            Fluttertoast.showToast(
                              msg: 'Login successful.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              ChatScreen.routeName,
                              (route) => false,
                              arguments: _loginEmailController.text,
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: 'login failed',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                            );
                          }
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                          });
                          Fluttertoast.showToast(
                            msg: 'Error: $e',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                          );
                        }
                      }
                      print('Password Hashed is ${_passwordController.text}');
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(
    AuthService authService,
    ThemeProvider themeProvider,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 15),
          CustomTextFormField(
            controller: _nameController,
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person, color: themeProvider.primaryColor),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
            fillColor: themeProvider.cardColor,
            labelColor: themeProvider.textColor,
            type: TextInputType.name,
          ),
          SizedBox(height: 15),
          CustomTextFormField(
            controller: _emailController,
            labelText: 'Email',
            prefixIcon: Icon(Icons.email, color: themeProvider.primaryColor),
            fillColor: themeProvider.cardColor,
            labelColor: themeProvider.textColor,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Email is invalid';
              }
              return null;
            },
            type: TextInputType.emailAddress,
          ),
          SizedBox(height: 15),
          IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Phone number',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: themeProvider.textColor),
              filled: true,
              fillColor: themeProvider.cardColor,
            ),
            initialCountryCode: 'EG',
            onChanged: (phone) {
              _countryCode = phone.countryCode;
              _phoneNumber = phone.number;
            },
            validator: (phone) {
              if (phone == null || phone.number.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 15),
          CustomTextFormField(
            controller: _passwordController,
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock, color: themeProvider.primaryColor),
            fillColor: themeProvider.cardColor,
            labelColor: themeProvider.textColor,
            obscureText: isRegisterPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  isRegisterPassword = !isRegisterPassword;
                  suffixRegisterIcon = isRegisterPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined;
                });
              },
              icon: Icon(
                suffixRegisterIcon,
                color: themeProvider.secondaryTextColor,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'The password must be at least 6 characters long.';
              }
              return null;
            },
            type: TextInputType.visiblePassword,
          ),
          SizedBox(height: 15),
          CustomTextFormField(
            controller: _confirmPasswordController,
            labelText: 'Confirm password',
            prefixIcon: Icon(Icons.lock, color: themeProvider.primaryColor),
            fillColor: themeProvider.cardColor,
            labelColor: themeProvider.textColor,
            obscureText: isRegisterConfirmPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  isRegisterConfirmPassword = !isRegisterConfirmPassword;
                  suffixRegisterConfirmIcon = isRegisterConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined;
                });
              },
              icon: Icon(
                suffixRegisterConfirmIcon,
                color: themeProvider.secondaryTextColor,
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            type: TextInputType.visiblePassword,
          ),
          SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          String fullPhone = _countryCode + _phoneNumber;

                          UserModel? user = await authService
                              .registerWithEmailAndPassword(
                                name: _nameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                phone: fullPhone,
                              );

                          setState(() {
                            _isLoading = false;
                          });

                          if (user != null) {
                            Fluttertoast.showToast(
                              msg: 'The account has been created successfully',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              ChatScreen.routeName,
                              (route) => false,
                              arguments: _emailController.text,
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Account creation failed',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                            );
                          }
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                          });
                          Fluttertoast.showToast(
                            msg: 'Error: $e',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                          );
                        }
                      }
                      print('Password Hashed is ${_passwordController.text}');
                    },
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              color: themeProvider.textColor,
                            ),
                          ),
                  ),
                ),
        ],
      ),
    );
  }
}
