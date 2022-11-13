import 'package:flutter/material.dart';
import 'auth_repository.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool disableButton = false;
  late String email;
  late String password;
  late String confirmation;

  @override
  Widget build(BuildContext context) {
    AuthRepository.instance();
    final user = Provider.of<AuthRepository>(context);
    return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(children: <Widget>[
              const Center(
                  child: Text(
                      'Welcome to Startup Names Generator, please log in below',
                      style: TextStyle(fontSize: 15))),
              const Padding(padding: EdgeInsets.all(10)),
              Center(
                  child: TextField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (value) {
                        email = value;
                      },
                      keyboardType: TextInputType.emailAddress)),
              const Padding(padding: EdgeInsets.all(10)),
              Center(
                  child: TextField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      onChanged: (value) {
                        password = value;
                      },
                      obscureText: true)),
              const Padding(padding: EdgeInsets.all(15)),
              Center(
                  child: disableButton
                      ? const CircularProgressIndicator()
                      : Column(children: <Widget>[
                          Container(
                            height: 40,
                            width: 320,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(50)),
                            child: TextButton(
                                onPressed: () async {
                                  setState(() {
                                    disableButton = true;
                                  });
                                  final succeeded =
                                      await user.signIn(email, password);
                                  if (succeeded) {
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'There was an error logging into the app')));
                                  }
                                  setState(() {
                                    disableButton = false;
                                  });
                                },
                                child: Text('Log in',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 16))),
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          Container(
                            height: 40,
                            width: 320,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(50)),
                            child: TextButton(
                                child: Text('New user? Click to sign up',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 16)),
                                onPressed: () async {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return AnimatedPadding(
                                          padding:
                                              MediaQuery.of(context).viewInsets,
                                          duration:
                                              const Duration(milliseconds: 100),
                                          curve: Curves.decelerate,
                                          child: Container(
                                              height: 200,
                                              color: Colors.white,
                                              child: Center(
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                    const Text(
                                                        'Please confirm your password below:'),
                                                    const SizedBox(height: 20),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 0,
                                                                horizontal: 40),
                                                        child: Center(
                                                            child: TextField(
                                                                obscureText:
                                                                    true,
                                                                decoration:
                                                                    const InputDecoration(
                                                                        labelText:
                                                                            'Password'),
                                                                onChanged:
                                                                    (value) {
                                                                  confirmation =
                                                                      value;
                                                                }))),
                                                    const SizedBox(height: 20),
                                                    Container(
                                                        height: 40,
                                                        width: 320,
                                                        decoration: BoxDecoration(
                                                            color: Colors.blue,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50)),
                                                        child: TextButton(
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                disableButton =
                                                                    true;
                                                              });
                                                              if (confirmation ==
                                                                  password) {
                                                                if (await user.signUp(
                                                                        email,
                                                                        password) !=
                                                                    null) {
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                } else {
                                                                  Navigator.pop(
                                                                      context);
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(const SnackBar(
                                                                          content:
                                                                              Text('There was an error signing you up to the app')));
                                                                }
                                                              } else {
                                                                Navigator.pop(
                                                                    context);
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(const SnackBar(
                                                                        content:
                                                                            Text('Passwords do not match')));
                                                              }
                                                              setState(() {
                                                                disableButton =
                                                                    false;
                                                              });
                                                            },
                                                            child: Text(
                                                                'Confirm',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .secondary,
                                                                    fontSize:
                                                                        16))))
                                                  ]))));
                                    },
                                  );
                                }),
                          ),
                        ]))
            ])));
  }
}
