import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:english_words/english_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// ignore: constant_identifier_names
enum Status { UNINITIALIZED, AUTHENTICATED, AUTHENTICATING, UNAUTHENTICATED }

class AuthRepository with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth;
  User? _user;
  Status _status = Status.UNINITIALIZED;
  Set<WordPair> savedSet = {};

  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;

  User? get user => _user;

  bool get isAuthenticated => status == Status.AUTHENTICATED;

  String get email => _user!.email!;

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.AUTHENTICATING;
      notifyListeners();
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e);
      _status = Status.UNAUTHENTICATED;
      notifyListeners();
      return null;
    }
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.UNAUTHENTICATED;
    } else {
      _user = firebaseUser;
      _status = Status.AUTHENTICATED;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.AUTHENTICATING;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      savedSet = await downloadSaved();
      notifyListeners();
      return true;
    } catch (e) {
      _status = Status.UNAUTHENTICATED;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.UNAUTHENTICATED;
    savedSet = {};
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<String> getAvatarURL() async {
    try {
      return await _firebaseStorage
          .ref('Images')
          .child(user!.uid)
          .getDownloadURL();
    } catch (e) {
      return await _firebaseStorage
          .ref('Images')
          .child('Default')
          .getDownloadURL();
    }
  }

  Future<void> uploadAvatar(File img) async {
    await _firebaseStorage.ref("Images").child(user!.uid).putFile(img);
    notifyListeners();
  }

  Future<void> addPair(WordPair pair) async {
    if (isAuthenticated) {
      await _firestore
          .collection("Users")
          .doc(_user!.uid)
          .collection("Saved")
          .doc(pair.toString())
          .set({'first': pair.first, 'second': pair.second});
    }
    savedSet = await downloadSaved();
    notifyListeners();
  }

  Future<void> removePair(WordPair pair) async {
    if (isAuthenticated) {
      await _firestore
          .collection("Users")
          .doc(_user!.uid)
          .collection('Saved')
          .doc(pair.toString())
          .delete();
      savedSet = await downloadSaved();
      //notifyListeners();
    }
    notifyListeners();
  }

  Future<Set<WordPair>> downloadSaved() async {
    Set<WordPair> s = <WordPair>{};
    await _firestore
        .collection("Users")
        .doc(_user!.uid)
        .collection('Saved')
        .get()
        .then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        final entriesCloud = result.data().entries;
        String first = entriesCloud.first.value.toString();
        String second = entriesCloud.last.value.toString();
        s.add(WordPair(first, second));
      }
    });
    return Future<Set<WordPair>>.value(s);
  }
}
