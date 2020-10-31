import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrestaurant/repository/shop_info_repository.dart';
import 'package:flutterrestaurant/ui/common/base/ps_widget_with_appbar.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingPrivacyPolicyView extends StatefulWidget {
  const SettingPrivacyPolicyView({@required this.checkPolicyType});
  final int checkPolicyType;
  @override
  _SettingPrivacyPolicyViewState createState() {
    return _SettingPrivacyPolicyViewState();
  }
}

class _SettingPrivacyPolicyViewState extends State<SettingPrivacyPolicyView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  ShopInfoProvider _shopInfoProvider;

  AnimationController animationController;
  Animation<double> animation;

  @override
  void dispose() {
    animationController.dispose();
    animation = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _shopInfoProvider.nextShopInfoList();
      }
    });

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() => setState(() {}));

    animation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(animationController);
  }

  ShopInfoRepository repo1;
  PsValueHolder valueHolder;
  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<ShopInfoRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);
    return PsWidgetWithAppBar<ShopInfoProvider>(
        appBarTitle: widget.checkPolicyType == 1
            ? Utils.getString(context, 'privacy_policy__toolbar_name')
            : widget.checkPolicyType == 2
                ? Utils.getString(context, 'terms_and_condition__toolbar_name')
                : widget.checkPolicyType == 3
                    ? Utils.getString(context, 'refund_policy__toolbar_name')
                    : '',
        initProvider: () {
          return ShopInfoProvider(
              repo: repo1,
              psValueHolder: valueHolder,
              ownerCode: 'SettingPrivacyPolicyView');
        },
        onProviderReady: (ShopInfoProvider provider) {
          provider.loadShopInfo();
          _shopInfoProvider = provider;
        },
        builder:
            (BuildContext context, ShopInfoProvider provider, Widget child) {
          if (provider.shopInfo == null || provider.shopInfo.data == null) {
            return Container();
          } else {
            return Padding(
              padding: const EdgeInsets.all(PsDimens.space16),
              child: SingleChildScrollView(
                child: Text(
                  widget.checkPolicyType == 1
                      ? provider.shopInfo.data.privacyPolicy
                      : widget.checkPolicyType == 2
                          ? provider.shopInfo.data.terms
                          : widget.checkPolicyType == 3
                              ? provider.shopInfo.data.refundPolicy
                              : '',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            );
          }
        });
  }
}
