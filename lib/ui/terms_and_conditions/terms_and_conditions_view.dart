import 'package:flutter/material.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrestaurant/repository/shop_info_repository.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:provider/provider.dart';

class TermsAndConditionsView extends StatefulWidget {
  const TermsAndConditionsView({Key key, @required this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  _TermsAndConditionsViewState createState() => _TermsAndConditionsViewState();
}

class _TermsAndConditionsViewState extends State<TermsAndConditionsView> {
  ShopInfoRepository repo1;
  PsValueHolder psValueHolder;
  ShopInfoProvider provider;
  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<ShopInfoRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: widget.animationController,
            curve: const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));
    widget.animationController.forward();
    return ChangeNotifierProvider<ShopInfoProvider>(
        lazy: false,
        create: (BuildContext context) {
          provider = ShopInfoProvider(
              repo: repo1, ownerCode: null, psValueHolder: psValueHolder);
          provider.loadShopInfo();
          return provider;
        },
        child: Consumer<ShopInfoProvider>(builder: (BuildContext context,
            ShopInfoProvider basketProvider, Widget child) {
          return AnimatedBuilder(
            animation: widget.animationController,
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                opacity: animation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - animation.value), 0.0),
                  child: Padding(
                    padding: const EdgeInsets.all(PsDimens.space16),
                    child: SingleChildScrollView(
                      child: Text(
                        provider.shopInfo != null &&
                                provider.shopInfo.data != null
                            ? provider.shopInfo.data.terms
                            : '',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }));
  }
}
