import 'package:firebase_auth/firebase_auth.dart';

class FacebookLoginUserHolder {
  FacebookLoginUserHolder(this.firebaseUser, this.facebookUser);
  FirebaseUser firebaseUser;
  dynamic facebookUser;
}
