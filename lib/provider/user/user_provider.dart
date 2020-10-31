import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:apple_sign_in/scope.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/error_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/facebook_login_web_view.dart';
import 'package:flutterrestaurant/utils/ps_progress_dialog.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/api_status.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/apple_login_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/facebook_login_user_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/fb_login_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/google_login_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/user_login_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/user_register_parameter_holder.dart';
import 'package:flutterrestaurant/viewobject/shipping_area.dart';
import 'package:flutterrestaurant/viewobject/user.dart';
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/provider/common/ps_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class UserProvider extends PsProvider {
  UserProvider(
      {@required UserRepository repo,
      @required this.psValueHolder,
      int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    isDispose = false;
    print('User Provider: $hashCode');
    userListStream = StreamController<PsResource<User>>.broadcast();
    subscription = userListStream.stream.listen((PsResource<User> resource) {
      if (resource != null && resource.data != null) {
        _user = resource;
        holderUser = resource.data;
        originalUserLat = _user.data.userLat;
        originalUserLng = _user.data.userLng;
      }

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }

  UserRepository _repo;
  PsValueHolder psValueHolder;
  User holderUser;
  ShippingArea selectedArea;
  bool isCheckBoxSelect = false;
  String originalUserLat;
  String originalUserLng;

  PsResource<User> _user = PsResource<User>(PsStatus.NOACTION, '', null);
  PsResource<User> _holderUser = PsResource<User>(PsStatus.NOACTION, '', null);
  PsResource<User> get user => _user;

  PsResource<ApiStatus> _apiStatus =
      PsResource<ApiStatus>(PsStatus.NOACTION, '', null);
  PsResource<ApiStatus> get apiStatus => _apiStatus;

  StreamSubscription<PsResource<User>> subscription;
  StreamController<PsResource<User>> userListStream;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    subscription.cancel();
    isDispose = true;
    print('User Provider Dispose: $hashCode');
    super.dispose();
  }

  LatLng getUserLatLng() {
    if (user == null ||
        user.data == null ||
        (user.data.userLat == '0' && user.data.userLng == '0')) {
      return LatLng(double.parse(PsConfig.lat), double.parse(PsConfig.lng));
    }

    return LatLng(double.parse(user.data.userLat ?? PsConfig.lat),
        double.parse(user.data.userLng ?? PsConfig.lng));
  }

  void setUserLatLng(LatLng latlng) {
    user.data.userLat = latlng.latitude.toString();
    user.data.userLng = latlng.longitude.toString();
  }

  bool hasLatLng() {
    final LatLng _latlng = getUserLatLng();
    if (_latlng == null ||
        _latlng.latitude == 0.0 ||
        _latlng.longitude == 0.0) {
      return false;
    } else {
      if (_latlng.latitude.toString() == PsConfig.lat &&
          _latlng.longitude.toString() == PsConfig.lng) {
        return false;
      } else {
        return true;
      }
    }
  }

  Future<dynamic> postUserRegister(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _user = await _repo.postUserRegister(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _user;
  }

  Future<dynamic> postUserEmailVerify(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _user = await _repo.postUserEmailVerify(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _user;
  }

  Future<dynamic> postImageUpload(
    String userId,
    String platformName,
    File imageFile,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _user = await _repo.postImageUpload(userId, platformName, imageFile,
        isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _user;
  }

  Future<dynamic> postUserLogin(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _user = await _repo.postUserLogin(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _user;
  }

  Future<dynamic> postForgotPassword(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _apiStatus = await _repo.postForgotPassword(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _apiStatus;
  }

  Future<dynamic> postChangePassword(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _apiStatus = await _repo.postChangePassword(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _apiStatus;
  }

  Future<dynamic> postProfileUpdate(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _holderUser = await _repo.postProfileUpdate(
        jsonMap, isConnectedToInternet, PsStatus.SUCCESS);
    if (_holderUser.status == PsStatus.SUCCESS) {
      _user = _holderUser;
      return _holderUser;
    } else {
      return _holderUser;
    }
  }

  Future<dynamic> postPhoneLogin(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _user = await _repo.postPhoneLogin(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _user;
  }

  Future<dynamic> postFBLogin(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _user = await _repo.postFBLogin(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _user;
  }

  Future<dynamic> postGoogleLogin(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _user = await _repo.postGoogleLogin(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _user;
  }

  Future<dynamic> postAppleLogin(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _user = await _repo.postAppleLogin(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _user;
  }

  Future<dynamic> postResendCode(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _apiStatus = await _repo.postResendCode(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _apiStatus;
  }

  Future<dynamic> getUser(
    String loginUserId,
  ) async {
    isLoading = true;
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    await _repo.getUser(userListStream, loginUserId, isConnectedToInternet,
        PsStatus.PROGRESS_LOADING);
  }

  Future<dynamic> getUserFromDB(String loginUserId) async {
    isLoading = true;

    await _repo.getUserFromDB(
        loginUserId, userListStream, PsStatus.PROGRESS_LOADING);
  }

  ///
  /// Firebase Auth
  ///
  Future<FirebaseUser> getCurrentFirebaseUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser currentUser = await auth.currentUser();
    return currentUser;
  }

  Future<void> handleFirebaseAuthError(BuildContext context, String email,
      {bool ignoreEmail = false}) async {
    if (email.isEmpty) {
      return;
    }

    final List<String> providers =
        await _firebaseAuth.fetchSignInMethodsForEmail(email: email);

    final String provider = providers.single;
    print('provider : $provider');
    // Registered With Email
    if (provider.contains(PsConst.emailAuthProvider) && !ignoreEmail) {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return WarningDialog(
              message: '[ $email ]\n' +
                  Utils.getString(context,
                      Utils.getString(context, 'auth__email_provider')),
            );
          });
    }
    // Registered With Google
    else if (provider.contains(PsConst.googleAuthProvider)) {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return WarningDialog(
              message: '[ $email ]\n' +
                  Utils.getString(context,
                      Utils.getString(context, 'auth__google_provider')),
            );
          });
    }
    // Registered With Facebook
    else if (provider.contains(PsConst.facebookAuthProvider)) {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return WarningDialog(
              message: '[ $email ]\n' +
                  Utils.getString(context,
                      Utils.getString(context, 'auth__facebook_provider')),
            );
          });
    }
    // Registered With Apple
    else if (provider.contains(PsConst.appleAuthProvider)) {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return WarningDialog(
              message: '[ $email ]\n' +
                  Utils.getString(context,
                      Utils.getString(context, 'auth__apple_provider')),
            );
          });
    }
  }

  ///
  /// Apple Login Related
  ///
  Future<void> loginWithAppleId(
      BuildContext context, Function onAppleIdSignInSelected) async {
    ///
    /// Check User is Accept Terms and Conditions
    ///
    if (isCheckBoxSelect) {
      ///
      /// Check Connection
      ///
      if (await Utils.checkInternetConnectivity()) {
        ///
        /// Get Firebase User with Apple Id Login
        ///
        final FirebaseUser firebaseUser =
            await _getFirebaseUserWithAppleId(context);

        if (firebaseUser != null) {
          ///
          /// Got Firebase User
          ///
          Utils.psPrint('User id : ${firebaseUser.uid}');

          ///
          /// Show Progress Dialog
          ///
          PsProgressDialog.showDialog(context);

          ///
          /// Submit to backend
          ///
          final PsResource<User> resourceUser =
              await _submitLoginWithAppleId(firebaseUser);

          ///
          /// Close Progress Dialog
          ///
          PsProgressDialog.dismissDialog();

          if (resourceUser != null && resourceUser.data != null) {
            ///
            /// Success
            ///
            if (onAppleIdSignInSelected != null) {
              onAppleIdSignInSelected(resourceUser.data.userId);
            } else {
              Navigator.pop(context, resourceUser.data);
            }
          } else {
            ///
            /// Error from server
            ///
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                    message: resourceUser.message ?? '',
                  );
                });
          }
        }
      } else {
        ///
        /// No Internet Connection
        ///
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(context, 'error_dialog__no_internet'),
              );
            });
      }
    } else {
      ///
      /// Not yet agree on Privacy Policy
      ///
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return WarningDialog(
              message: Utils.getString(context, 'login__warning_agree_privacy'),
            );
          });
    }
  }

  Future<PsResource<User>> _submitLoginWithAppleId(FirebaseUser user) async {
    if (user != null) {
      String email = user.email;
      if (email == null || email == '') {
        if (user.providerData.isNotEmpty) {
          email = user.providerData[0].email;
        }
      }

      final AppleLoginParameterHolder appleLoginParameterHolder =
          AppleLoginParameterHolder(
              appleId: user.uid,
              userName: user.displayName,
              userEmail: email,
              profilePhotoUrl: user.photoUrl,
              deviceToken: psValueHolder.deviceToken,
              isDeliveryBoy: PsConst.ZERO);

      final PsResource<User> _apiStatus =
          await postAppleLogin(appleLoginParameterHolder.toMap());

      if (_apiStatus.data != null) {
        replaceVerifyUserData('', '', '', '');
        replaceLoginUserId(_apiStatus.data.userId);
      }
      return _apiStatus;
    } else {
      return null;
    }
  }

  Future<FirebaseUser> _getFirebaseUserWithAppleId(BuildContext context) async {
    final List<Scope> scopes = <Scope>[Scope.email, Scope.fullName];

    // 1. perform the sign-in request
    final AuthorizationResult result = await AppleSignIn.performRequests(
        <AppleIdRequest>[AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final AppleIdCredential appleIdCredential = result.credential;
        const OAuthProvider oAuthProvider =
            OAuthProvider(providerId: 'apple.com');
        final OAuthCredential credential = oAuthProvider.getCredential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        AuthResult authResult;
        try {
          authResult = await _firebaseAuth.signInWithCredential(credential);
        } on PlatformException catch (e) {
          print(e);

          handleFirebaseAuthError(context, appleIdCredential.email);
          // Fail to Login to Firebase, must return null;
          return null;
        }

        FirebaseUser firebaseUser = authResult.user;
        if (scopes.contains(Scope.fullName)) {
          final UserUpdateInfo updateUser = UserUpdateInfo();

          updateUser.displayName = null;

          if (appleIdCredential.fullName.givenName != null) {
            updateUser.displayName = '${appleIdCredential.fullName.givenName}';
          }

          if (appleIdCredential.fullName.familyName != null) {
            if (updateUser.displayName != null) {
              updateUser.displayName = '${updateUser.displayName} ';
            }

            updateUser.displayName +=
                '${appleIdCredential.fullName.familyName}';
          }

          if (updateUser.displayName != null &&
              updateUser.displayName != ' ' &&
              updateUser.displayName != '') {
            await firebaseUser.updateProfile(updateUser);
          }
        }
        firebaseUser = await _firebaseAuth.currentUser();
        return firebaseUser;
      case AuthorizationStatus.error:
        print(result.error.toString());
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
    }
    return null;
  }

  ///
  /// Google Login Related
  ///
  Future<void> loginWithGoogleId(
      BuildContext context, Function onGoogleIdSignInSelected) async {
    ///
    /// Check User is Accept Terms and Conditions
    ///
    if (isCheckBoxSelect) {
      ///
      /// Check Connection
      ///
      if (await Utils.checkInternetConnectivity()) {
        ///
        /// Get Firebase User with Google Id Login
        ///
        final FirebaseUser firebaseUser = await _getFirebaseUserWithGoogleId();

        if (firebaseUser != null) {
          ///
          /// Got Firebase User
          ///
          Utils.psPrint('User id : ${firebaseUser.uid}');

          ///
          /// Show Progress Dialog
          ///
          PsProgressDialog.showDialog(context);

          ///
          /// Submit to backend
          ///
          final PsResource<User> resourceUser =
              await _submitLoginWithGoogleId(firebaseUser);

          ///
          /// Close Progress Dialog
          ///
          PsProgressDialog.dismissDialog();

          if (resourceUser != null && resourceUser.data != null) {
            ///
            /// Success
            ///
            if (onGoogleIdSignInSelected != null) {
              onGoogleIdSignInSelected(resourceUser.data.userId);
            } else {
              Navigator.pop(context, resourceUser.data);
            }
          } else {
            ///
            /// Error from server
            ///
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                    message: resourceUser.message ?? '',
                  );
                });
          }
        }
      } else {
        ///
        /// No Internet Connection
        ///
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(context, 'error_dialog__no_internet'),
              );
            });
      }
    } else {
      ///
      /// Not yet agree on Privacy Policy
      ///
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return WarningDialog(
              message: Utils.getString(context, 'login__warning_agree_privacy'),
            );
          });
    }
  }

  Future<FirebaseUser> _getFirebaseUserWithGoogleId() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _firebaseAuth.signInWithCredential(credential)).user;
      print('signed in' + user.displayName);
      return user;
    } catch (Exception) {
      print('not select google account');
      return null;
    }
  }

  Future<PsResource<User>> _submitLoginWithGoogleId(FirebaseUser user) async {
    if (user != null) {
      String email = user.email;
      if (email == null || email == '') {
        if (user.providerData.isNotEmpty) {
          email = user.providerData[0].email;
        }
      }
      final GoogleLoginParameterHolder googleLoginParameterHolder =
          GoogleLoginParameterHolder(
              googleId: user.uid,
              userName: user.displayName,
              userEmail: email,
              profilePhotoUrl: user.photoUrl,
              deviceToken: psValueHolder.deviceToken,
              isDeliveryBoy: PsConst.ZERO);

      final PsResource<User> _apiStatus =
          await postGoogleLogin(googleLoginParameterHolder.toMap());

      if (_apiStatus.data != null) {
        replaceVerifyUserData('', '', '', '');
        replaceLoginUserId(_apiStatus.data.userId);
      }

      return _apiStatus;
    } else {
      return null;
    }
  }

  ///
  /// Facebook Login Related
  ///
  Future<void> loginWithFacebookId(
      BuildContext context, Function onFacebookIdSignInSelected) async {
    ///
    /// Check User is Accept Terms and Conditions
    ///
    if (isCheckBoxSelect) {
      ///
      /// Check Connection
      ///
      if (await Utils.checkInternetConnectivity()) {
        ///
        /// Get Firebase User with Facebook Id Login
        ///
        final FacebookLoginUserHolder facebookLoginUserHolder =
            await _getFirebaseUserWithFacebookId(context);

        if (facebookLoginUserHolder != null && facebookLoginUserHolder.firebaseUser != null) {
          ///
          /// Got Firebase User
          ///
          Utils.psPrint(
              'User id : ${facebookLoginUserHolder.firebaseUser.uid}');

          ///
          /// Show Progress Dialog
          ///
          PsProgressDialog.showDialog(context);

          ///
          /// Submit to backend
          ///
          final PsResource<User> resourceUser =
              await _submitLoginWithFacebookId(facebookLoginUserHolder);

          ///
          /// Close Progress Dialog
          ///
          PsProgressDialog.dismissDialog();

          if (resourceUser != null && resourceUser.data != null) {
            ///
            /// Success
            ///
            if (onFacebookIdSignInSelected != null) {
              onFacebookIdSignInSelected(resourceUser.data.userId);
            } else {
              Navigator.pop(context, resourceUser.data);
            }
          } else {
            ///
            /// Error from server
            ///
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                    message: resourceUser.message ?? '',
                  );
                });
          }
        }
      } else {
        ///
        /// No Internet Connection
        ///
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(context, 'error_dialog__no_internet'),
              );
            });
      }
    } else {
      ///
      /// Not yet agree on Privacy Policy
      ///
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return WarningDialog(
              message: Utils.getString(context, 'login__warning_agree_privacy'),
            );
          });
    }
  }

  Future<FacebookLoginUserHolder> _getFirebaseUserWithFacebookId(
      BuildContext context) async {
    // Get Keys
    const String yourClientId = PsConfig.fbKey;
    const String yourRedirectUrl =
        'https://www.facebook.com/connect/login_success.html';

    // Get Access Token
    final String result = await Navigator.push(
      context,
      MaterialPageRoute<String>(
          builder: (BuildContext context) => const FacebookLoginWebView(
                selectedUrl:
                    'https://www.facebook.com/dialog/oauth?client_id=$yourClientId&redirect_uri=$yourRedirectUrl&response_type=token&scope=email,public_profile,',
              ),
          maintainState: true),
    );

    // Get User Info Based on the Access Token
    final dynamic graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$result');
    final dynamic profile = json.decode(graphResponse.body);

    // Firebase Base Login
    if (result != null) {
      final AuthCredential credential =
          FacebookAuthProvider.getCredential(accessToken: result);

      try {
        final FirebaseUser user =
            (await _firebaseAuth.signInWithCredential(credential)).user;
        print('signed in' + user.displayName);

        return FacebookLoginUserHolder(user, profile);
        // return user;
      } on PlatformException catch (e) {
        print(e);

        handleFirebaseAuthError(context, profile['email']);

        return null;
      }
    } else {
      return null;
    }
  }

  Future<PsResource<User>> _submitLoginWithFacebookId(
      FacebookLoginUserHolder facebookLoginUserHolder) async {
    final FirebaseUser user = facebookLoginUserHolder.firebaseUser;
    final dynamic facebookUser = facebookLoginUserHolder.facebookUser;
    if (user != null) {
      String email = user.email;
      if (email == null || email == '') {
        if (user.providerData.isNotEmpty) {
          email = user.providerData[0].email;
        }
      }
      final FBLoginParameterHolder fbLoginParameterHolder =
          FBLoginParameterHolder(
        facebookId: user.uid,
        userName: user.displayName,
        userEmail: email,
        profilePhotoUrl: '',
        deviceToken: psValueHolder.deviceToken,
        profileImgId: facebookUser['id'],
        isDeliveryBoy: PsConst.ZERO,
      );

      final PsResource<User> _apiStatus =
          await postFBLogin(fbLoginParameterHolder.toMap());

      if (_apiStatus.data != null) {
        replaceVerifyUserData('', '', '', '');
        replaceLoginUserId(_apiStatus.data.userId);
      }

      return _apiStatus;
    } else {
      return null;
    }
  }

  ///
  /// Email Login Related
  ///
  Future<void> loginWithEmailId(BuildContext context, String email,
      String password, Function onProfileSelected) async {
    ///
    /// Check Connection
    ///
    if (await Utils.checkInternetConnectivity()) {
      ///
      /// Get Firebase User with Email Id Login
      ///

      await signInWithEmailAndPassword(context, email, email);

      ///
      /// Show Progress Dialog
      ///
      PsProgressDialog.showDialog(context);

      ///
      /// Submit to backend
      ///
      final PsResource<User> resourceUser =
          await _submitLoginWithEmailId(email, password);

      ///
      /// Close Progress Dialog
      ///
      PsProgressDialog.dismissDialog();

      if (resourceUser != null && resourceUser.data != null) {
        ///
        /// Success
        ///
        if (onProfileSelected != null) {
          onProfileSelected(resourceUser.data.userId);
        } else {
          Navigator.pop(context, resourceUser.data);
        }
      } else {
        ///
        /// Error from server
        ///
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: resourceUser.message ?? '',
              );
            });
      }
    } else {
      ///
      /// No Internet Connection
      ///
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__no_internet'),
            );
          });
    }
  }

  Future<FirebaseUser> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    AuthResult result;

    try {
      result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on PlatformException catch (e) {
      print(e);

      final FirebaseUser user = await createUserWithEmailAndPassword(
          context, email, password,
          ignoreHandleFirebaseAuthError: true);

      // Sign In as Dummy User
      if (user == null) {
        try {
          await _firebaseAuth.signInWithEmailAndPassword(
              email: PsConst.defaultEmail, password: PsConst.defaultPassword);
        } on PlatformException catch (e) {
          print(e);
          await createUserWithEmailAndPassword(
              context, PsConst.defaultEmail, PsConst.defaultPassword,
              ignoreHandleFirebaseAuthError: true);
        }
      }

      // Fail to Login to Firebase, must return null;
      return null;
    }

    final FirebaseUser user = result.user;

    print('signInEmail succeeded: $user');

    return user;
  }

  Future<PsResource<User>> _submitLoginWithEmailId(
      String email, String password) async {
    final UserLoginParameterHolder userLoginParameterHolder =
        UserLoginParameterHolder(
      userEmail: email,
      userPassword: password,
      deviceToken: psValueHolder.deviceToken,
    );

    final PsResource<User> _apiStatus =
        await postUserLogin(userLoginParameterHolder.toMap());

    if (_apiStatus.data != null) {
      replaceVerifyUserData('', '', '', '');
      replaceLoginUserId(_apiStatus.data.userId);
    }
    return _apiStatus;
  }

  ///
  /// Email Register Related
  ///
  Future<void> signUpWithEmailId(
      BuildContext context,
      Function onRegisterSelected,
      String name,
      String email,
      String password) async {
    ///
    /// Check User is Accept Terms and Conditions
    ///
    if (isCheckBoxSelect) {
      ///
      /// Check Connection
      ///
      if (await Utils.checkInternetConnectivity()) {
        ///
        /// Get Firebase User with Email Id Login
        ///
        final FirebaseUser firebaseUser = await createUserWithEmailAndPassword(context, email, email);

        if (firebaseUser != null) {

        ///
        /// Show Progress Dialog
        ///
        PsProgressDialog.showDialog(context);

        ///
        /// Submit to backend
        ///
        final PsResource<User> resourceUser =
            await _submitSignUpWithEmailId(name, email, password);

        ///
        /// Close Progress Dialog
        ///
        PsProgressDialog.dismissDialog();

        if (resourceUser != null && resourceUser.data != null) {
          ///
          /// Success
          ///
          if (onRegisterSelected != null) {
            await onRegisterSelected(resourceUser.data.userId);
          } else {
            final dynamic returnData = await Navigator.pushNamed(
                context, RoutePaths.user_verify_email_container,
                arguments: resourceUser.data.userId);

            if (returnData != null && returnData is User) {
              final User user = returnData;
              if (Provider != null && Provider.of != null) {
                psValueHolder =
                    Provider.of<PsValueHolder>(context, listen: false);
              }
              psValueHolder.loginUserId = user.userId;
              psValueHolder.userIdToVerify = '';
              psValueHolder.userNameToVerify = '';
              psValueHolder.userEmailToVerify = '';
              psValueHolder.userPasswordToVerify = '';
              print(user.userId);
              Navigator.of(context).pop();
            }
          }
        } else {
          ///
          /// Error from server
          ///
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: resourceUser.message ?? '',
                );
              });
          }
        }
        // else{
        //   ///
        //   /// Email Exist
        //   ///
        //   showDialog<dynamic>(
        //       context: context,
        //       builder: (BuildContext context) {
        //         return ErrorDialog(
        //           message: Utils.getString(context, 'register__email_exist')
        //         );
        //       });
        // }
      } else {
        ///
        /// No Internet Connection
        ///
        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: Utils.getString(context, 'error_dialog__no_internet'),
              );
            });
      }
    } else {
      ///
      /// Not yet agree on Privacy Policy
      ///
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return WarningDialog(
              message: Utils.getString(context, 'login__warning_agree_privacy'),
            );
          });
    }
  }

  // Future<FirebaseUser> createUserWithEmailAndPassword(
  //     BuildContext context, String email, String password,
  //     {bool ignoreHandleFirebaseAuthError = false}) async {
  //   AuthResult result;
  //   try {
  //     result = await _firebaseAuth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //   } on PlatformException catch (e) {
  //     print(e);

  //     final FirebaseUser user =
  //         await signInWithEmailAndPassword(context, email, email);
  //     if (user == null) {
  //       if (!ignoreHandleFirebaseAuthError) {
  //         handleFirebaseAuthError(context, email, ignoreEmail: true);
  //       }

  //       // Fail to Login to Firebase, must return null;
  //       return null;
  //     } else {
  //       return user;
  //     }
  //   }

  //   final FirebaseUser user = result.user;

  //   return user;
  // }

  Future<FirebaseUser> createUserWithEmailAndPassword(
      BuildContext context, String email, String password,
      {bool ignoreHandleFirebaseAuthError = false}) async {
    AuthResult result;
    try {
      result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on PlatformException catch (e) {
      print(e);

      final List<String> providers =
          await _firebaseAuth.fetchSignInMethodsForEmail(email: email);

      final String provider = providers.single;
      print('provider : $provider');
      // Registered With Email
      if (provider.contains(PsConst.emailAuthProvider)) {
        final FirebaseUser user =
            await signInWithEmailAndPassword(context, email, email);
        if (user == null) {
          if (!ignoreHandleFirebaseAuthError) {
            handleFirebaseAuthError(context, email, ignoreEmail: true);
          }

          // Fail to Login to Firebase, must return null;
          return null;
        } else {
          return user;
        }
      } else {
        if (!ignoreHandleFirebaseAuthError) {
          handleFirebaseAuthError(context, email, ignoreEmail: true);
        }
        return null;
      }
    }

    final FirebaseUser user = result.user;

    return user;
  }

  Future<PsResource<User>> _submitSignUpWithEmailId(
      String name, String email, String password) async {
    final UserRegisterParameterHolder userRegisterParameterHolder =
        UserRegisterParameterHolder(
      userId: '',
      userName: name,
      userEmail: email,
      userPassword: password,
      userPhone: '',
      isDeliveryBoy: PsConst.ZERO,
      deviceToken: psValueHolder.deviceToken,
    );

    final PsResource<User> _apiStatus =
        await postUserRegister(userRegisterParameterHolder.toMap());

    if (_apiStatus.data != null) {
      final User user = _apiStatus.data;

      await replaceVerifyUserData(_apiStatus.data.userId,
          _apiStatus.data.userName, _apiStatus.data.userEmail, password);

      psValueHolder.userIdToVerify = user.userId;
      psValueHolder.userNameToVerify = user.userName;
      psValueHolder.userEmailToVerify = user.userEmail;
      psValueHolder.userPasswordToVerify = user.userPassword;
    }
    return _apiStatus;
  }
}
