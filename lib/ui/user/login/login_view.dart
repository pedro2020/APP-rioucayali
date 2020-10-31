import 'dart:io';
import 'package:apple_sign_in/apple_sign_in_button.dart';
import 'package:flutter/services.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_button_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    Key key,
    this.animationController,
    this.animation,
    this.onProfileSelected,
    this.onForgotPasswordSelected,
    this.onSignInSelected,
    this.onPhoneSignInSelected,
    this.onFbSignInSelected,
    this.onGoogleSignInSelected,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;
  final Function onProfileSelected,
      onForgotPasswordSelected,
      onSignInSelected,
      onPhoneSignInSelected,
      onFbSignInSelected,
      onGoogleSignInSelected;
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  UserRepository repo1;
  PsValueHolder psValueHolder;

  @override
  Widget build(BuildContext context) {
    widget.animationController.forward();
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space28,
    );

    repo1 = Provider.of<UserRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    return SliverToBoxAdapter(
        child: ChangeNotifierProvider<UserProvider>(
      lazy: false,
      create: (BuildContext context) {
        final UserProvider provider =
            UserProvider(repo: repo1, psValueHolder: psValueHolder);
        print(provider.getCurrentFirebaseUser());
        // provider.postUserLogin(userLoginParameterHolder.toMap());
        return provider;
      },
      child: Consumer<UserProvider>(
          builder: (BuildContext context, UserProvider provider, Widget child) {
        return AnimatedBuilder(
          animation: widget.animationController,
          builder: (BuildContext context, Widget child) {
            return FadeTransition(
                opacity: widget.animation,
                child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 100 * (1.0 - widget.animation.value), 0.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          _HeaderIconAndTextWidget(),
                          _TextFieldAndSignInButtonWidget(
                            provider: provider,
                            text: Utils.getString(context, 'login__submit'),
                            onProfileSelected: widget.onProfileSelected,
                          ),
                          _spacingWidget,
                          _DividerORWidget(),
                          const SizedBox(
                            height: PsDimens.space12,
                          ),
                          _TermsAndConCheckbox(
                            provider: provider,
                            onCheckBoxClick: () {
                              setState(() {
                                updateCheckBox(context, provider);
                              });
                            },
                          ),
                          const SizedBox(
                            height: PsDimens.space8,
                          ),
                          if (PsConfig.showPhoneLogin)
                            _LoginWithPhoneWidget(
                              onPhoneSignInSelected:
                                  widget.onPhoneSignInSelected,
                              provider: provider,
                            ),
                          if (PsConfig.showFacebookLogin)
                            _LoginWithFbWidget(
                                userProvider: provider,
                                onFbSignInSelected: widget.onFbSignInSelected),
                          if (PsConfig.showGoogleLogin)
                            _LoginWithGoogleWidget(
                                userProvider: provider,
                                onGoogleSignInSelected:
                                    widget.onGoogleSignInSelected),
                          if (Utils.isAppleSignInAvailable == 1 &&
                              Platform.isIOS)
                            _LoginWithAppleIdWidget(
                                onAppleIdSignInSelected:
                                    widget.onGoogleSignInSelected),
                          _spacingWidget,
                          _spacingWidget,
                          _ForgotPasswordAndRegisterWidget(
                            provider: provider,
                            animationController: widget.animationController,
                            onForgotPasswordSelected:
                                widget.onForgotPasswordSelected,
                            onSignInSelected: widget.onSignInSelected,
                          ),
                          _spacingWidget,
                        ],
                      ),
                    )));
          },
        );
      }),
    ));
  }
}

class _TermsAndConCheckbox extends StatefulWidget {
  const _TermsAndConCheckbox(
      {@required this.provider, @required this.onCheckBoxClick});

  final UserProvider provider;
  final Function onCheckBoxClick;

  @override
  __TermsAndConCheckboxState createState() => __TermsAndConCheckboxState();
}

class __TermsAndConCheckboxState extends State<_TermsAndConCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox(
          width: PsDimens.space20,
        ),
        Checkbox(
          activeColor: PsColors.mainColor,
          value: widget.provider.isCheckBoxSelect,
          onChanged: (bool value) {
            widget.onCheckBoxClick();
          },
        ),
        Expanded(
          child: InkWell(
            child: Text(
              Utils.getString(context, 'login__agree_privacy'),
              style: Theme.of(context).textTheme.bodyText2,
            ),
            onTap: () {
              widget.onCheckBoxClick();
            },
          ),
        ),
      ],
    );
  }
}

void updateCheckBox(BuildContext context, UserProvider provider) {
  if (provider.isCheckBoxSelect) {
    provider.isCheckBoxSelect = false;
  } else {
    provider.isCheckBoxSelect = true;

    Navigator.pushNamed(context, RoutePaths.privacyPolicy, arguments: 2);
  }
}

class _HeaderIconAndTextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget _textWidget = Text(Utils.getString(context, 'app_name'),
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(color: PsColors.mainColor));

    final Widget _imageWidget = Container(
      width: 90,
      height: 90,
      child: Image.asset(
        'assets/images/fs_android_3x.png',
      ),
    );
    return Column(
      children: <Widget>[
        const SizedBox(
          height: PsDimens.space32,
        ),
        _imageWidget,
        const SizedBox(
          height: PsDimens.space8,
        ),
        _textWidget,
        const SizedBox(
          height: PsDimens.space52,
        ),
      ],
    );
  }
}

class _TextFieldAndSignInButtonWidget extends StatefulWidget {
  const _TextFieldAndSignInButtonWidget({
    @required this.provider,
    @required this.text,
    this.onProfileSelected,
  });

  final UserProvider provider;
  final String text;
  final Function onProfileSelected;

  @override
  __CardWidgetState createState() => __CardWidgetState();
}

class __CardWidgetState extends State<_TextFieldAndSignInButtonWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // final FirebaseAuth auth = FirebaseAuth.instance;
  // Future<FirebaseUser> handleSignInEmail(String email, String password) async {
  //   AuthResult result =
  //       await auth.signInWithEmailAndPassword(email: email, password: password);
  //   final FirebaseUser user = result.user;

  //   assert(user != null);
  //   assert(await user.getIdToken() != null);

  //   final FirebaseUser currentUser = await auth.currentUser();
  //   assert(user.uid == currentUser.uid);

  //   print('signInEmail succeeded: $user');

  //   return user;
  // }

  // Future<FirebaseUser> handleSignUp(email, password) async {
  //   AuthResult result = await auth.createUserWithEmailAndPassword(
  //       email: email, password: password);
  //   final FirebaseUser user = result.user;

  //   assert(user != null);
  //   assert(await user.getIdToken() != null);

  //   return user;
  // }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets _marginEdgeInsetsforCard = EdgeInsets.only(
        left: PsDimens.space16,
        right: PsDimens.space16,
        top: PsDimens.space4,
        bottom: PsDimens.space4);
    return Column(
      children: <Widget>[
        Card(
          elevation: 0.3,
          margin: const EdgeInsets.only(
              left: PsDimens.space32, right: PsDimens.space32),
          child: Column(
            children: <Widget>[
              Container(
                margin: _marginEdgeInsetsforCard,
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: Utils.getString(context, 'login__email'),
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: PsColors.textPrimaryLightColor),
                      icon: Icon(Icons.email,
                          color: Theme.of(context).iconTheme.color)),
                ),
              ),
              const Divider(
                height: PsDimens.space1,
              ),
              Container(
                margin: _marginEdgeInsetsforCard,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: Theme.of(context).textTheme.button.copyWith(),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: Utils.getString(context, 'login__password'),
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: PsColors.textPrimaryLightColor),
                      icon: Icon(Icons.lock,
                          color: Theme.of(context).iconTheme.color)),
                  // keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: PsDimens.space8,
        ),
        Container(
          margin: const EdgeInsets.only(
              left: PsDimens.space32, right: PsDimens.space32),
          child: PSButtonWidget(
            hasShadow: true,
            width: double.infinity,
            titleText: Utils.getString(context, 'login__sign_in'),
            onPressed: () async {
              if (emailController.text.isEmpty) {
                callWarningDialog(context,
                    Utils.getString(context, 'warning_dialog__input_email'));
              } else if (passwordController.text.isEmpty) {
                callWarningDialog(context,
                    Utils.getString(context, 'warning_dialog__input_password'));
              } else {
                await widget.provider.loginWithEmailId(
                    context,
                    emailController.text,
                    passwordController.text,
                    widget.onProfileSelected);
              }
            },
          ),
        )
      ],
    );
  }
}

dynamic callWarningDialog(BuildContext context, String text) {
  showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return WarningDialog(
          message: Utils.getString(context, text),
        );
      });
}

class _DividerORWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const Widget _dividerWidget = Expanded(
      child: Divider(
        height: PsDimens.space2,
      ),
    );

    const Widget _spacingWidget = SizedBox(
      width: PsDimens.space8,
    );

    final Widget _textWidget =
        Text('OR', style: Theme.of(context).textTheme.subtitle1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _dividerWidget,
        _spacingWidget,
        _textWidget,
        _spacingWidget,
        _dividerWidget,
      ],
    );
  }
}

class _LoginWithPhoneWidget extends StatefulWidget {
  const _LoginWithPhoneWidget(
      {@required this.onPhoneSignInSelected, @required this.provider});
  final Function onPhoneSignInSelected;
  final UserProvider provider;

  @override
  __LoginWithPhoneWidgetState createState() => __LoginWithPhoneWidgetState();
}

class __LoginWithPhoneWidgetState extends State<_LoginWithPhoneWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          left: PsDimens.space32, right: PsDimens.space32),
      child: PSButtonWithIconWidget(
        titleText: Utils.getString(context, 'login__phone_signin'),
        icon: Icons.phone,
        colorData: widget.provider.isCheckBoxSelect
            ? PsColors.mainColor
            : PsColors.mainColor,
        onPressed: () async {
          if (widget.provider.isCheckBoxSelect) {
            if (widget.onPhoneSignInSelected != null) {
              widget.onPhoneSignInSelected();
            } else {
              Navigator.pushReplacementNamed(
                context,
                RoutePaths.user_phone_signin_container,
              );
            }
          } else {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return WarningDialog(
                    message: Utils.getString(
                        context, 'login__warning_agree_privacy'),
                  );
                });
          }
        },
      ),
    );
  }
}

class _LoginWithFbWidget extends StatefulWidget {
  const _LoginWithFbWidget(
      {@required this.userProvider, @required this.onFbSignInSelected});
  final UserProvider userProvider;
  final Function onFbSignInSelected;

  @override
  __LoginWithFbWidgetState createState() => __LoginWithFbWidgetState();
}

class __LoginWithFbWidgetState extends State<_LoginWithFbWidget> {
//   loginWithFacebook() async{
// String result = await Navigator.push(
//   context,
//   MaterialPageRoute(
//       builder: (context) => CustomWebView(
//             selectedUrl:
//                 'https://www.facebook.com/dialog/oauth?client_id=$your_client_id&redirect_uri=$your_redirect_url&response_type=token&scope=email,public_profile,',
//           ),
//       maintainState: true),
// if (result != null) {
//   try {

//   } catch (e) {}
// }
// );}
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // String yourClientId = PsConfig.fbKey;
  // String yourRedirectUrl =
  //     'https://www.facebook.com/connect/login_success.html';
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          left: PsDimens.space32,
          top: PsDimens.space8,
          right: PsDimens.space32),
      child: PSButtonWithIconWidget(
          titleText: Utils.getString(context, 'login__fb_signin'),
          icon: FontAwesome.facebook_official,
          colorData: widget.userProvider.isCheckBoxSelect == false
              ? PsColors.facebookLoginButtonColor
              : PsColors.facebookLoginButtonColor,
          onPressed: () async {
            await widget.userProvider
                .loginWithFacebookId(context, widget.onFbSignInSelected);
          }),
    );
  }
}

class _LoginWithAppleIdWidget extends StatelessWidget {
  const _LoginWithAppleIdWidget({@required this.onAppleIdSignInSelected});

  final Function onAppleIdSignInSelected;

  @override
  Widget build(BuildContext context) {
    final UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Container(
        margin: const EdgeInsets.only(
            left: PsDimens.space32,
            top: PsDimens.space8,
            right: PsDimens.space32),
        child: AppleSignInButton(
          style: ButtonStyle.black, // style as needed
          type: ButtonType.signIn, // style as needed
          onPressed: () async {
            await _userProvider.loginWithAppleId(
                context, onAppleIdSignInSelected);
          },
        ));
  }
}

class _LoginWithGoogleWidget extends StatefulWidget {
  const _LoginWithGoogleWidget(
      {@required this.userProvider, @required this.onGoogleSignInSelected});
  final UserProvider userProvider;
  final Function onGoogleSignInSelected;

  @override
  __LoginWithGoogleWidgetState createState() => __LoginWithGoogleWidgetState();
}

class __LoginWithGoogleWidgetState extends State<_LoginWithGoogleWidget> {
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // Future<FirebaseUser> _handleSignIn() async {
  //   try {
  //     final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final AuthCredential credential = GoogleAuthProvider.getCredential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final FirebaseUser user =
  //         (await _auth.signInWithCredential(credential)).user;
  //     print('signed in' + user.displayName);
  //     return user;
  //   } catch (Exception) {
  //     print('not select google account');
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          left: PsDimens.space32,
          top: PsDimens.space8,
          right: PsDimens.space32),
      child: PSButtonWithIconWidget(
        titleText: Utils.getString(context, 'login__google_signin'),
        icon: FontAwesome.google,
        colorData: widget.userProvider.isCheckBoxSelect
            ? PsColors.googleLoginButtonColor
            : PsColors.googleLoginButtonColor,
        onPressed: () async {
          await widget.userProvider
              .loginWithGoogleId(context, widget.onGoogleSignInSelected);
        },
      ),
    );
  }
}

class _ForgotPasswordAndRegisterWidget extends StatefulWidget {
  const _ForgotPasswordAndRegisterWidget(
      {Key key,
      this.provider,
      this.animationController,
      this.onForgotPasswordSelected,
      this.onSignInSelected})
      : super(key: key);

  final AnimationController animationController;
  final Function onForgotPasswordSelected;
  final Function onSignInSelected;
  final UserProvider provider;

  @override
  __ForgotPasswordAndRegisterWidgetState createState() =>
      __ForgotPasswordAndRegisterWidgetState();
}

class __ForgotPasswordAndRegisterWidgetState
    extends State<_ForgotPasswordAndRegisterWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: PsDimens.space40),
      margin: const EdgeInsets.all(PsDimens.space12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: GestureDetector(
              child: Text(
                Utils.getString(context, 'login__forgot_password'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.button.copyWith(
                      color: PsColors.mainColor,
                    ),
              ),
              onTap: () {
                if (widget.onForgotPasswordSelected != null) {
                  widget.onForgotPasswordSelected();
                } else {
                  Navigator.pushReplacementNamed(
                    context,
                    RoutePaths.user_forgot_password_container,
                  );
                }
              },
            ),
          ),
          Flexible(
            child: GestureDetector(
              child: Text(
                Utils.getString(context, 'login__sign_up'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.button.copyWith(
                      color: PsColors.mainColor,
                    ),
              ),
              onTap: () async {
                if (widget.onSignInSelected != null) {
                  widget.onSignInSelected();
                } else {
                  final dynamic returnData =
                      await Navigator.pushReplacementNamed(
                    context,
                    RoutePaths.user_register_container,
                  );
                  if (returnData != null && returnData is User) {
                    final User user = returnData;
                    widget.provider.psValueHolder =
                        Provider.of<PsValueHolder>(context, listen: false);
                    widget.provider.psValueHolder.loginUserId = user.userId;
                    widget.provider.psValueHolder.userIdToVerify = '';
                    widget.provider.psValueHolder.userNameToVerify = '';
                    widget.provider.psValueHolder.userEmailToVerify = '';
                    widget.provider.psValueHolder.userPasswordToVerify = '';
                    Navigator.pop(context, user);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Email
// --------
// if (await Utils.checkInternetConnectivity()) {
//   await handleSignUp(emailController.text, emailController.text)
//       .then((FirebaseUser user) {
//     print(user);
//   }).catchError((e) {
//     print(e);

//     return auth
//         .fetchSignInMethodsForEmail(email: emailController.text)
//         .then((providers) {
//       print(providers);

//       widget.provider.handleFirebaseAuthError(
//           context, emailController.text);
//     });

//     //   // Existing email/password or Google user signed in.
//     //   // Link Facebook OAuth credential to existing account.
//     //   return user.linkWithCredential(pendingCred);
//     // });

//     // return;
//   });

//   final UserLoginParameterHolder userLoginParameterHolder =
//       UserLoginParameterHolder(
//     userEmail: emailController.text,
//     userPassword: passwordController.text,
//     deviceToken: widget.provider.psValueHolder.deviceToken,
//   );

//   PsProgressDialog.showDialog(context);
//   final PsResource<User> _apiStatus = await widget.provider
//       .postUserLogin(userLoginParameterHolder.toMap());

//   if (_apiStatus.data != null) {
//     PsProgressDialog.dismissDialog();

//     widget.provider.replaceVerifyUserData('', '', '', '');
//     widget.provider.replaceLoginUserId(_apiStatus.data.userId);

//     if (widget.onProfileSelected != null) {
//       await widget.provider
//           .replaceVerifyUserData('', '', '', '');
//       await widget.provider
//           .replaceLoginUserId(_apiStatus.data.userId);
//       await widget.onProfileSelected(_apiStatus.data.userId);
//     } else {
//       Navigator.pop(context, _apiStatus.data);
//     }
//   } else {
//     PsProgressDialog.dismissDialog();
//     showDialog<dynamic>(
//         context: context,
//         builder: (BuildContext context) {
//           return ErrorDialog(
//             message: _apiStatus.message,
//           );
//         });
//   }
// } else {
//   showDialog<dynamic>(
//       context: context,
//       builder: (BuildContext context) {
//         return ErrorDialog(
//           message: Utils.getString(
//               context, 'error_dialog__no_internet'),
//         );
//       });
// }

// Google
// -------
// if (widget.userProvider.isCheckBoxSelect) {
//   await _handleSignIn().then((FirebaseUser user) async {
//     if (user != null) {
//       if (await Utils.checkInternetConnectivity()) {
//         final GoogleLoginParameterHolder googleLoginParameterHolder =
//             GoogleLoginParameterHolder(
//                 googleId: user.uid,
//                 userName: user.displayName,
//                 userEmail: user.email,
//                 profilePhotoUrl: user.photoUrl,
//                 isDeliveryBoy: PsConst.ZERO,
//                 deviceToken:
//                     widget.userProvider.psValueHolder.deviceToken);
//         PsProgressDialog.showDialog(context);
//         final PsResource<User> _apiStatus = await widget.userProvider
//             .postGoogleLogin(googleLoginParameterHolder.toMap());

//         if (_apiStatus.data != null) {
//           widget.userProvider.replaceVerifyUserData('', '', '', '');
//           widget.userProvider
//               .replaceLoginUserId(_apiStatus.data.userId);
//           PsProgressDialog.dismissDialog();

//           if (widget.onGoogleSignInSelected != null) {
//             widget.onGoogleSignInSelected(_apiStatus.data.userId);
//           } else {
//             Navigator.pop(context, _apiStatus.data);
//           }
//         } else {
//           PsProgressDialog.dismissDialog();

//           showDialog<dynamic>(
//               context: context,
//               builder: (BuildContext context) {
//                 return ErrorDialog(
//                   message: _apiStatus.message ?? '',
//                 );
//               });
//         }
//       } else {
//         showDialog<dynamic>(
//             context: context,
//             builder: (BuildContext context) {
//               return ErrorDialog(
//                 message: Utils.getString(
//                     context, 'error_dialog__no_internet'),
//               );
//             });
//       }
//     }
//   });
// } else {
//   showDialog<dynamic>(
//       context: context,
//       builder: (BuildContext context) {
//         return WarningDialog(
//           message: Utils.getString(
//               context, 'login__warning_agree_privacy'),
//         );
//       });
// }

// Facebook
// ---------
//             if (widget.userProvider.isCheckBoxSelect) {
//               // final FacebookLogin fbLogin = FacebookLogin();
// // final FacebookLogin faceBookLogin = FacebookLogin();

//               final String result = await Navigator.push(
//                 context,
//                 MaterialPageRoute<String>(
//                     builder: (BuildContext context) => CustomWebView(
//                           selectedUrl:
//                               'https://www.facebook.com/dialog/oauth?client_id=$yourClientId&redirect_uri=$yourRedirectUrl&response_type=token&scope=email,public_profile,',
//                         ),
//                     maintainState: true),
//               );

//               if (result != null) {
//                 final AuthCredential facebookAuthCred =
//                     FacebookAuthProvider.getCredential(accessToken: result);
//                 AuthResult user;
//                 try {
//                   user = await _auth.signInWithCredential(facebookAuthCred);
//                 } on PlatformException catch (e) {
//                   print(e);

//                   return _auth
//                       .fetchSignInMethodsForEmail(
//                           email: 'teamps.dev.1@gmail.com')
//                       .then((providers) {
//                     print(providers);
//                     final FirebaseAuth _auth = FirebaseAuth.instance;
//                   });

//                   // if (e.code !=
//                   //     'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL') throw e;
//                   // // Now we caught the error we're talking about, we get the email by calling graph API manually
//                   // final httpClient = new HttpClient();
//                   // final graphRequest = await httpClient.getUrl(Uri.parse(
//                   //     'https://graph.facebook.com/v2.12/me?fields=email&access_token=${result}'));
//                   // final graphResponse = await graphRequest.close();
//                   // final graphResponseJSON = json.decode(
//                   //     (await graphResponse.transform(utf8.decoder).single));
//                   // final email = graphResponseJSON["email"];
//                   // // Now we have both credential and email that is required for linking
//                   // final signInMethods = await FirebaseAuth.instance
//                   //     .fetchSignInMethodsForEmail(email: email);
//                   // // Assume that signInMethods[0] is 'google.com'
//                   // try {
//                   //   final GoogleSignIn _googleSignIn = GoogleSignIn();
//                   //   final GoogleSignInAccount googleUser =
//                   //       await _googleSignIn.signIn();
//                   //   final GoogleSignInAuthentication googleAuth =
//                   //       await googleUser.authentication;

//                   //   final AuthCredential credential =
//                   //       GoogleAuthProvider.getCredential(
//                   //     accessToken: googleAuth.accessToken,
//                   //     idToken: googleAuth.idToken,
//                   //   );

//                   //   final FirebaseUser fbuser =
//                   //       (await _auth.signInWithCredential(credential)).user;
//                   //   print('signed in' + fbuser.displayName);
//                   //   if (fbuser.email == email) {
//                   //     // Now we can link the accounts together
//                   //     await fbuser.linkWithCredential(facebookAuthCred);
//                   //   }

//                   //return fbuser;
//                   // } catch (Exception) {
//                   //   print('not select google account');
//                   //   //return null;
//                   // }
//                   // ... do the Google sign-in logic here and get the Firebase AuthResult

//                 }
//                 // final FacebookAccessToken myToken = result.accessToken;
//                 // FacebookAuthProvider.getCredential(accessToken: myToken.token);
//                 // print(myToken.token);
//                 print(user);

//                 // final String token = myToken.token;
//                 final dynamic graphResponse = await http.get(
//                     'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$result');
//                 final dynamic profile = json.decode(graphResponse.body);

//                 if (await Utils.checkInternetConnectivity()) {
//                   final FBLoginParameterHolder fbLoginParameterHolder =
//                       FBLoginParameterHolder(
//                           facebookId: profile['id'],
//                           userName: profile['name'],
//                           userEmail: profile['email'],
//                           profilePhotoUrl: '',
//                           isDeliveryBoy: PsConst.ZERO,
//                           deviceToken:
//                               widget.userProvider.psValueHolder.deviceToken);

//                   PsProgressDialog.showDialog(context);
//                   final PsResource<User> _apiStatus = await widget.userProvider
//                       .postFBLogin(fbLoginParameterHolder.toMap());

//                   if (_apiStatus.data != null) {
//                     widget.userProvider.replaceVerifyUserData('', '', '', '');
//                     widget.userProvider
//                         .replaceLoginUserId(_apiStatus.data.userId);

//                     PsProgressDialog.dismissDialog();
//                     if (widget.onFbSignInSelected != null) {
//                       widget.onFbSignInSelected(_apiStatus.data.userId);
//                     } else {
//                       Navigator.pop(context, _apiStatus.data);
//                     }
//                   } else {
//                     PsProgressDialog.dismissDialog();
//                     showDialog<dynamic>(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return ErrorDialog(message: _apiStatus.message ?? '');
//                         });
//                   }
//                 } else {
//                   showDialog<dynamic>(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return ErrorDialog(
//                           message: Utils.getString(
//                               context, 'error_dialog__no_internet'),
//                         );
//                       });
//                 }
//               }
//             } else {
//               showDialog<dynamic>(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return WarningDialog(
//                       message: Utils.getString(
//                           context, 'login__warning_agree_privacy'),
//                     );
//                   });
//             }
