import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  final Reader _read;
  AuthService(this._read);

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  fb.User? get currentUser => _auth.currentUser;

  Future<fb.UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
    if (googleUser == null) {
      throw Exception('Sign-in aborted');
    }
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<fb.UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<fb.UserCredential> signUpWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}