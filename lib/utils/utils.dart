import 'dart:collection';
import 'dart:io';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/db/common/ps_shared_preferences.dart';
import 'package:flutterrestaurant/provider/common/notification_provider.dart';
import 'package:flutterrestaurant/ui/common/dialog/chat_noti_dialog.dart';
import 'package:flutterrestaurant/viewobject/common/ps_object.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/noti_register_holder.dart';
import 'package:flutterrestaurant/viewobject/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  Utils._();

  static String getString(BuildContext context, String key) {
    if (key != '') {
      return tr(key) ?? '';
    } else {
      return '';
    }
  }

  static DateTime previous;
  static void psPrint(String msg) {
    final DateTime now = DateTime.now();
    int min = 0;
    if (previous == null) {
      previous = now;
    } else {
      min = now.difference(previous).inMilliseconds;
      previous = now;
    }

    print('$now ($min)- $msg');
  }

  static String getPriceFormat(String price) {
    return PsConst.psFormat.format(double.parse(price));
  }

  static String getPriceTwoDecimal(String price) {
    return PsConst.priceTwoDecimalFormat.format(double.parse(price));
  }

  static bool isLightMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  static Brightness getBrightnessForAppBar(BuildContext context) {
    if (Platform.isAndroid) {
      return Brightness.dark;
    } else {
      return Theme.of(context).brightness;
    }
  }

  static dynamic getBannerAdUnitId() {
    if (Platform.isIOS) {
      return PsConfig.iosAdMobUnitIdApiKey;
    } else {
      return PsConfig.androidAdMobUnitIdApiKey;
    }
  }

  static dynamic getAdAppId() {
    if (Platform.isIOS) {
      return PsConfig.iosAdMobAdsIdKey;
    } else {
      return PsConfig.androidAdMobAdsIdKey;
    }
  }

  static String getDateFormat(String dateTime) {
    final DateTime date = DateTime.parse(dateTime);
    return DateFormat(PsConfig.dateFormat).format(date);
  }

  static Future<bool> checkInternetConnectivity() async {
    final ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else if (connectivityResult == ConnectivityResult.none) {
      print('No Connection');
      return false;
    } else {
      return false;
    }
  }

  static dynamic launchURL() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print(packageInfo.packageName);
    final String url =
        'https://play.google.com/store/apps/details?id=${packageInfo.packageName}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static dynamic launchAppStoreURL(
      {String iOSAppId, bool writeReview = false}) async {
    LaunchReview.launch(writeReview: writeReview, iOSAppId: iOSAppId);
  }

  static dynamic navigateOnUserVerificationView(
      dynamic provider, BuildContext context, Function onLoginSuccess) async {
    provider.psValueHolder = Provider.of<PsValueHolder>(context, listen: false);

    if (provider == null ||
        provider.psValueHolder.userIdToVerify == null ||
        provider.psValueHolder.userIdToVerify == '') {
      if (provider == null ||
          provider.psValueHolder == null ||
          provider.psValueHolder.loginUserId == null ||
          provider.psValueHolder.loginUserId == '') {
        final dynamic returnData = await Navigator.pushNamed(
          context,
          RoutePaths.login_container,
        );

        if (returnData != null && returnData is User) {
          final User user = returnData;
          provider.psValueHolder =
              Provider.of<PsValueHolder>(context, listen: false);
          provider.psValueHolder.loginUserId = user.userId;
        }
      } else {
        onLoginSuccess();
      }
    } else {
      Navigator.pushNamed(context, RoutePaths.user_verify_email_container,
          arguments: provider.psValueHolder.userIdToVerify);
    }
  }

  static String checkUserLoginId(PsValueHolder psValueHolder) {
    if (psValueHolder.loginUserId == null) {
      return 'nologinuser';
    } else {
      return psValueHolder.loginUserId;
    }
  }

  static Color hexToColor(String code) {
    if (code != null && code != '') {
      return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    } else {
      return PsColors.white;
    }
  }

  static String calculateShippingTax(String shippingCost, String shippingTax) {
    return Utils.getPriceFormat(
        (double.parse(shippingCost) * double.parse(shippingTax)).toString());
  }

  static Widget flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: toHeroContext.widget,
    );
  }

  static PsResource<List<T>> removeDuplicateObj<T>(
      PsResource<List<T>> resource) {
    final Map<String, String> _keyMap = HashMap<String, String>();
    final List<T> _tmpDataList = <T>[];

    if (resource != null && resource.data != null) {
      for (T obj in resource.data) {
        if (obj is PsObject) {
          final String _primaryKey = obj.getPrimaryKey();

          if (!_keyMap.containsKey(_primaryKey)) {
            _keyMap[_primaryKey] = _primaryKey;
            _tmpDataList.add(obj);
          }
        }
      }
    }

    resource.data = _tmpDataList;

    return resource;
  }

  static int isAppleSignInAvailable = 0;
  static Future<void> checkAppleSignInAvailable() async {
    final bool _isAvailable = await AppleSignIn.isAvailable();

    isAppleSignInAvailable = _isAvailable ? 1 : 2;
  }

  static Future<void> _onSelectNotification(
      BuildContext context, String payload) async {
    if (context != null) {
      showDialog<dynamic>(
          context: context,
          builder: (_) {
            return ChatNotiDialog(
                description: '$payload',
                leftButtonText: Utils.getString(context, 'chat_noti__cancel'),
                rightButtonText: Utils.getString(context, 'chat_noti__open'),
                onAgreeTap: () {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.notiList,
                  );
                });
          });
    }
  }

  static Future<void> _onOrderStatusChangeNotification(
      BuildContext context, String message, String orderId) async {
    if (context != null) {
      showDialog<dynamic>(
          context: context,
          builder: (_) {
            return ChatNotiDialog(
                description: '$message',
                leftButtonText: Utils.getString(context, 'chat_noti__cancel'),
                rightButtonText: Utils.getString(context, 'chat_noti__open'),
                onAgreeTap: () {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.transactionList,
                  );
                });
          });
    }
  }

  static void subscribeToTopic(bool isEnable) {
    if (isEnable) {
      final FirebaseMessaging _fcm = FirebaseMessaging();
      if (Platform.isIOS) {
        _fcm.requestNotificationPermissions(const IosNotificationSettings());
      }
      _fcm.subscribeToTopic('broadcast');
    }
  }

  static void fcmConfigure(BuildContext context, FirebaseMessaging _fcm) {
    // final FirebaseMessaging _fcm = FirebaseMessaging();
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(const IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');

        final String orderId = _getOrderHeaderId(message);

        if (orderId != null && orderId != '') {
          print(message['data']['trans_header_id']);
          final String notiMessage = _parseNotiMessage(message);
          _onOrderStatusChangeNotification(context, notiMessage, orderId);
        } else {
          final String notiMessage = _parseNotiMessage(message);

          _onSelectNotification(context, notiMessage);

          PsSharedPreferences.instance.replaceNotiMessage(
            notiMessage,
          );
        }
      },
      //onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');

        final String orderId = _getOrderHeaderId(message);

        if (orderId != null && orderId != '') {
          print(message['data']['trans_header_id']);
          final String notiMessage = _parseNotiMessage(message);
          _onOrderStatusChangeNotification(context, notiMessage, orderId);
        } else {
          final String notiMessage = _parseNotiMessage(message);

          _onSelectNotification(context, notiMessage);

          PsSharedPreferences.instance.replaceNotiMessage(
            notiMessage,
          );
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');

        final String orderId = _getOrderHeaderId(message);

        if (orderId != null && orderId != '') {
          print(message['data']['trans_header_id']);
          final String notiMessage = _parseNotiMessage(message);
          _onOrderStatusChangeNotification(context, notiMessage, orderId);
        } else {
          final String notiMessage = _parseNotiMessage(message);

          _onSelectNotification(context, notiMessage);

          PsSharedPreferences.instance.replaceNotiMessage(
            notiMessage,
          );
        }
      },
    );
  }

  static String _getOrderHeaderId(Map<String, dynamic> message) {
    String orderId = '';

    orderId = message['data']['trans_header_id'] ?? '';

    return orderId;
  }

  static String _parseNotiMessage(Map<String, dynamic> message) {
    final dynamic data = message['notification'] ?? message;
    String notiMessage = '';
    if (Platform.isAndroid) {
      notiMessage = message['data']['message'];
      notiMessage ??= '';
    } else if (Platform.isIOS) {
      notiMessage = data['body'];
      notiMessage ??= data['message'];
      notiMessage ??= '';
    }
    return notiMessage;
  }

  static Future<void> saveDeviceToken(
      FirebaseMessaging _fcm, NotificationProvider notificationProvider) async {
    // Get the token for this device
    final String fcmToken = await _fcm.getToken();
    await notificationProvider.replaceNotiToken(fcmToken);

    final NotiRegisterParameterHolder notiRegisterParameterHolder =
        NotiRegisterParameterHolder(
            platformName: PsConst.PLATFORM,
            deviceId: fcmToken,
            loginUserId:
                Utils.checkUserLoginId(notificationProvider.psValueHolder));
    print('Token Key $fcmToken');
    if (fcmToken != null) {
      await notificationProvider
          .rawRegisterNotiToken(notiRegisterParameterHolder.toMap());
    }
    return true;
  }
}
