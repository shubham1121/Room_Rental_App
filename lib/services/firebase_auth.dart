import 'package:firebase_auth/firebase_auth.dart';
import 'database_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String name = "";
  String contact = "";
  String profession = "";
  bool isHomeOwner = false;
  String email = "";
  bool wantRoommate = false;
  int countRoommatePost = 0;
  String belogsTo="";
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future loginUser(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return 'valid';
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  void setDataforUser(String name, String contact, String profession, bool isHomeOwner, String email, int countRoommatePost, String belogsTo) {
    this.name = name;
    this.contact = contact;
    this.profession = profession;
    this.isHomeOwner = isHomeOwner;
    this.email = email;
    this.countRoommatePost =  countRoommatePost;
    this.belogsTo = belogsTo;
    print('setted data for user');
  }

  Future signUpUser(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        print(user.uid + 'signUp user');
        await DatabaseService(user.uid)
            .updateUserData(name, contact, profession, isHomeOwner, email, countRoommatePost, belogsTo);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future logout() async {
    try {
      return await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }
}
