import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { signup, login }

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  // ignore: prefer_final_fields
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  bool _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController? _animationController;
  Animation<Size>? _heightAnimation;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;
  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Error occured'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Okay'))
              ],
            ));
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false)
            .signin(_authData['email']!, _authData['password']!);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signup(_authData['email']!, _authData['password']!);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';

      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = "You have a weak password";
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = "Could not find user with that email";
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = "Invalid password";
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate you. Please try in sometime';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
      _animationController!.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _animationController!.reverse();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // _animationController!.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightAnimation = Tween<Size>(
      begin: const Size(double.infinity, 260),
      end: const Size(double.infinity, 320),
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _heightAnimation!.addListener(() {
      setState(() {});
    });
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeIn));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.5), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8.0,
      child: AnimatedBuilder(
        animation: _heightAnimation!,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email';
                    }
                  },
                  onSaved: (value) {
                    _authData['email'] = value as String;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value as String;
                  },
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.signup ? 120 : 0),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.signup,
                        decoration: const InputDecoration(
                            labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    child:
                        Text(_authMode == AuthMode.login ? 'Login' : 'Sign up'),
                    onPressed: submit,
                  ),
                TextButton(
                  child: Text(_authMode == AuthMode.login
                      ? 'Sign up  instead'
                      : 'login instead'),
                  onPressed: _switchAuthMode,
                )
              ],
            ),
          ),
        ),
        builder: (ctx, child) => Container(
          height: _heightAnimation!.value.height,
          constraints: BoxConstraints(
            minHeight: _heightAnimation!.value.height,
          ),
          width: deviceSize.width * 0.75,
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
