import 'dart:io';
import 'dart:ui';

import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hello_me/auth_repository.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AuthRepository.instance(),
        child: MaterialApp(
            initialRoute: 'main_screen',
            routes: {
              'main_screen': (context) => const RandomWords(),
              'login_screen': (context) => const LoginScreen(),
            },
            theme: ThemeData(
                colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: Colors.deepPurple,
                    accentColor: Colors.white)),
            title: 'Startup Name Generator',
            home: const RandomWords()));
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _savedLocal = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  var user;
  bool minimized = false;
  SnappingSheetController snappingSheetController = SnappingSheetController();

  void _pushSaved() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {
      if (user.isAuthenticated) {
        _savedLocal.addAll(user.savedSet);
      }
      final tiles = _savedLocal.map((pair) {
        return Dismissible(
            key: Key(pair.toString()),
            //ValueKey<int>(pair.hashCode),
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String name = pair.asPascalCase;
                    return AlertDialog(
                        title: const Text('Delete Suggestion'),
                        content: Text(
                            'Are you sure you want to delete $name from your saved suggestions?'),
                        actions: <Widget>[
                          ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Yes')),
                          ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('No'))
                        ]);
                  });
            },
            onDismissed: (DismissDirection direction) {
              setState(() {
                _savedLocal.remove(pair);
                user.removePair(pair);
              });
            },
            background: DefaultTextStyle(
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                child: Container(
                    color: Theme.of(context).colorScheme.primary,
                    child: Row(children: <Widget>[
                      Icon(Icons.delete,
                          color: Theme.of(context).colorScheme.secondary),
                      const Text('Delete Suggestion')
                    ]))),
            child:
                ListTile(title: Text(pair.asPascalCase, style: _biggerFont)));
      });
      final divided = tiles.isNotEmpty
          ? ListTile.divideTiles(context: context, tiles: tiles).toList()
          : <Widget>[];

      return Scaffold(
          appBar: AppBar(title: const Text('Saved Suggestions')),
          body: ListView(children: divided));
    }));
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, i) {
          if (i.isOdd) {
            return const Divider();
          }
          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final isSavedLocal = _savedLocal.contains(pair);
    final isSavedCloud = (user.isAuthenticated && user.savedSet.contains(pair));
    if (user.isAuthenticated && isSavedLocal && !isSavedCloud) {
      user.addPair(pair);
    }
    final isSavedAny = isSavedLocal || isSavedCloud;

    return ListTile(
        title: Text(pair.asPascalCase, style: _biggerFont),
        trailing: Icon(isSavedAny ? Icons.star : Icons.star_border,
            color: isSavedAny ? Theme.of(context).colorScheme.primary : null,
            semanticLabel: isSavedAny ? 'Remove from saved' : 'Save'),
        onTap: () {
          setState(() {
            if (isSavedAny) {
              _savedLocal.remove(pair);
              user.removePair(pair);
            } else {
              _savedLocal.add(pair);
              user.addPair(pair);
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AuthRepository>(context);

    return Scaffold(
        appBar: AppBar(title: const Text('Startup Name Generator'), actions: [
          IconButton(
              icon: const Icon(Icons.star),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions'),
          IconButton(
              icon: user.isAuthenticated
                  ? const Icon(Icons.exit_to_app)
                  : const Icon(Icons.login),
              onPressed: user.isAuthenticated
                  ? () async {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Successfully logged out')));
                      await user.signOut();
                      _savedLocal.clear();
                    }
                  : () {
                      Navigator.pushNamed(context, 'login_screen');
                    },
              tooltip: user.isAuthenticated ? 'Logout' : 'Login')
        ]),
        body: GestureDetector(
            onTap: () => {
                  setState(() {
                    if (minimized) {
                      ///If minimized make not minimized
                      snappingSheetController.snapToPosition(
                          const SnappingPosition.factor(
                              positionFactor: 0.200,
                              snappingCurve: Curves.easeInOut,
                              snappingDuration: Duration(milliseconds: 400)));
                    } else {
                      snappingSheetController.snapToPosition(
                          const SnappingPosition.factor(
                              positionFactor: 0.07,
                              snappingCurve: Curves.easeInOut,
                              snappingDuration: Duration(milliseconds: 400)));
                    }
                    minimized = !minimized;
                  })
                },
            child: SnappingSheet(
                controller: snappingSheetController,
                lockOverflowDrag: true,
                child: _buildSuggestions(),
                snappingPositions: const [
                  SnappingPosition.factor(
                      positionFactor: 0.200,
                      snappingCurve: Curves.easeIn,
                      snappingDuration: Duration(milliseconds: 350)),
                  SnappingPosition.factor(
                      positionFactor: 0.8,
                      snappingCurve: Curves.easeInBack,
                      snappingDuration: Duration(milliseconds: 1)),
                ],
                sheetBelow: !user.isAuthenticated
                    ? null
                    : SnappingSheetContent(
                        draggable: !minimized,
                        child: Container(
                            color: Theme.of(context).colorScheme.secondary,
                            child: ListView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  Column(children: [
                                    Row(children: <Widget>[
                                      Expanded(
                                          child: Container(
                                              height: 50,
                                              color: Colors.grey[400],
                                              child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Flexible(
                                                        flex: 3,
                                                        child: Center(
                                                            child: Text(
                                                                "Welcome back, " +
                                                                    user.email,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16.0)))),
                                                    IconButton(
                                                        icon: minimized
                                                            ? const Icon(Icons
                                                                .keyboard_arrow_up)
                                                            : const Icon(Icons
                                                                .keyboard_arrow_down),
                                                        onPressed: null)
                                                  ])))
                                    ]),
                                    Row(children: <Widget>[
                                      FutureBuilder(
                                          future: user.getAvatarURL(),
                                          builder: (context,
                                              AsyncSnapshot<String> snapshot) {
                                            return Padding(
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundImage:
                                                      snapshot.data != null
                                                          ? NetworkImage(
                                                              snapshot.data!)
                                                          : null,
                                                ));
                                          }),
                                      Column(children: <Widget>[
                                        Text(user.email, style: _biggerFont),
                                        MaterialButton(
                                            onPressed: () async {
                                              FilePickerResult? result =
                                                  await FilePicker.platform
                                                      .pickFiles(
                                                          allowedExtensions: [
                                                    'png',
                                                    'jpg',
                                                    'gif',
                                                    'bmp',
                                                    'jpeg',
                                                    'webp'
                                                  ],
                                                          type:
                                                              FileType.custom);
                                              if (result != null) {
                                                File file = File(
                                                    result.files.single.path!);
                                                user.uploadAvatar(file);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            'No image selected')));
                                              }
                                            },
                                            textColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            //padding
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.blue),
                                              padding: const EdgeInsets.all(5),

                                              ///The box size
                                              child: const Text('Change Avatar',
                                                  style:
                                                      TextStyle(fontSize: 17)),
                                            ))
                                      ])
                                    ]),
                                  ])
                                ])))))); //));
  }
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
