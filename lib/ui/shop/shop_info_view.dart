import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrestaurant/ui/common/ps_admob_banner_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/default_photo.dart';
import 'package:flutterrestaurant/viewobject/shop_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopInfoView extends StatefulWidget {
  const ShopInfoView({Key key, this.animationController, this.animation})
      : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  _ShopInfoViewState createState() => _ShopInfoViewState();
}

class _ShopInfoViewState extends State<ShopInfoView> {
  @override
  Widget build(BuildContext context) {
    widget.animationController.forward();
    return SliverToBoxAdapter(
      child: Consumer<ShopInfoProvider>(
        builder:
            (BuildContext context, ShopInfoProvider provider, Widget child) {
          return AnimatedBuilder(
              animation: widget.animationController,
              builder: (BuildContext context, Widget child) {
                return FadeTransition(
                    opacity: widget.animation,
                    child: Transform(
                        transform: Matrix4.translationValues(
                            0.0, 30 * (1.0 - widget.animation.value), 0.0),
                        child: provider.shopInfo != null &&
                                provider.shopInfo.data != null
                            ? _ShopInfoViewWidget(
                                widget: widget, provider: provider)
                            : Container()));
              });
        },
      ),
    );
  }
}

class _ShopInfoViewWidget extends StatefulWidget {
  const _ShopInfoViewWidget({
    Key key,
    @required this.widget,
    @required this.provider,
  }) : super(key: key);

  final ShopInfoView widget;
  final ShopInfoProvider provider;

  @override
  __ShopInfoViewWidgetState createState() => __ShopInfoViewWidgetState();
}

class __ShopInfoViewWidgetState extends State<_ShopInfoViewWidget> {
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet && PsConfig.showAdMob) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isConnectedToInternet && PsConfig.showAdMob) {
      print('loading ads....');
      checkConnection();
    }
    return Column(
      children: <Widget>[
        const PsAdMobBannerWidget(),
        _HeaderImageWidget(
          photo: widget.provider.shopInfo.data.defaultPhoto ?? '',
        ),
        Container(
          color: PsColors.coreBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ImageAndTextWidget(
                data: widget.provider.shopInfo.data ?? '',
              ),
              _DescriptionWidget(
                data: widget.provider.shopInfo.data,
              ),
              const SizedBox(
                height: PsDimens.space32,
              ),
              Container(
                  color: PsColors.backgroundColor,
                  padding: const EdgeInsets.only(
                      left: PsDimens.space16, right: PsDimens.space16),
                  child: Text(Utils.getString(context, 'shop_info__contact'),
                      style: Theme.of(context).textTheme.subtitle1)),
              _PhoneAndContactWidget(
                phone: widget.provider.shopInfo.data,
              ),
              _LinkAndTitle(
                  icon: FontAwesome.wordpress,
                  title:
                      Utils.getString(context, 'shop_info__visit_our_website'),
                  link: widget.provider.shopInfo.data.aboutWebsite),
              _LinkAndTitle(
                  icon: FontAwesome.facebook,
                  title: Utils.getString(context, 'shop_info__facebook'),
                  link: widget.provider.shopInfo.data.facebook),
              _LinkAndTitle(
                  icon: FontAwesome.google_plus_circle,
                  title: Utils.getString(context, 'shop_info__google_plus'),
                  link: widget.provider.shopInfo.data.googlePlus),
              _LinkAndTitle(
                  icon: FontAwesome.twitter_square,
                  title: Utils.getString(context, 'shop_info__twitter'),
                  link: widget.provider.shopInfo.data.twitter),
              _LinkAndTitle(
                  icon: FontAwesome.instagram,
                  title: Utils.getString(context, 'shop_info__instagram'),
                  link: widget.provider.shopInfo.data.instagram),
              _LinkAndTitle(
                  icon: FontAwesome.youtube,
                  title: Utils.getString(context, 'shop_info__youtube'),
                  link: widget.provider.shopInfo.data.youtube),
              _LinkAndTitle(
                  icon: FontAwesome.pinterest,
                  title: Utils.getString(context, 'shop_info__pinterest'),
                  link: widget.provider.shopInfo.data.pinterest),
              _SourceAddressWidget(
                data: widget.provider.shopInfo.data,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _LinkAndTitle extends StatelessWidget {
  const _LinkAndTitle({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.link,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String link;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: PsColors.backgroundColor,
        margin: const EdgeInsets.only(top: PsDimens.space8),
        padding: const EdgeInsets.all(PsDimens.space16),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Container(
                      width: PsDimens.space20,
                      height: PsDimens.space20,
                      child: Icon(
                        icon,
                      )),
                  const SizedBox(
                    width: PsDimens.space12,
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: PsDimens.space8,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: PsDimens.space32,
                  ),
                  InkWell(
                    child: Text(
                        link == ''
                            ? Utils.getString(context, 'shop_info__dash')
                            : link,
                        style: Theme.of(context).textTheme.bodyText2),
                    onTap: () async {
                      if (await canLaunch(link)) {
                        await launch(link);
                      } else {
                        throw 'Could not launch $link';
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class _HeaderImageWidget extends StatelessWidget {
  const _HeaderImageWidget({
    Key key,
    @required this.photo,
  }) : super(key: key);

  final DefaultPhoto photo;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PsNetworkImage(
          photoKey: '',
          defaultPhoto: photo ?? '',
          width: double.infinity,
          height: 300,
          boxfit: BoxFit.cover,
          onTap: () {},
        ),
      ],
    );
  }
}

class ImageAndTextWidget extends StatelessWidget {
  const ImageAndTextWidget({
    Key key,
    @required this.data,
  }) : super(key: key);

  final ShopInfo data;
  @override
  Widget build(BuildContext context) {
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space4,
    );

    final Widget _imageWidget = PsNetworkImage(
      photoKey: '',
      defaultPhoto: data.defaultPhoto,
      width: 50,
      height: 50,
      boxfit: BoxFit.cover,
      onTap: () {},
    );

    return Container(
        margin: const EdgeInsets.only(
            left: PsDimens.space16,
            right: PsDimens.space16,
            top: PsDimens.space16),
        child: Row(
          children: <Widget>[
            _imageWidget,
            const SizedBox(
              width: PsDimens.space12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.name,
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: PsColors.mainColor,
                        ),
                  ),
                  _spacingWidget,
                  InkWell(
                    child: Text(
                      data.aboutPhone1,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(),
                    ),
                    onTap: () async {
                      if (await canLaunch('tel://${data.aboutPhone1}')) {
                        await launch('tel://${data.aboutPhone1}');
                      } else {
                        throw 'Could not Call Phone Number 1';
                      }
                    },
                  ),
                  _spacingWidget,
                  Row(
                    children: <Widget>[
                      Container(
                          child: Icon(
                        Icons.email,
                      )),
                      const SizedBox(
                        width: PsDimens.space8,
                      ),
                      InkWell(
                        child: Text(data.codEmail,
                            style: Theme.of(context).textTheme.bodyText2),
                        onTap: () async {
                          if (await canLaunch(
                              'mailto:teamps.is.cool@gmail.com')) {
                            await launch('mailto:teamps.is.cool@gmail.com');
                          } else {
                            throw 'Could not launch teamps.is.cool@gmail.com';
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class _PhoneAndContactWidget extends StatelessWidget {
  const _PhoneAndContactWidget({
    Key key,
    @required this.phone,
  }) : super(key: key);

  final ShopInfo phone;
  @override
  Widget build(BuildContext context) {
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space16,
    );
    return Container(
        color: PsColors.backgroundColor,
        margin: const EdgeInsets.only(top: PsDimens.space16),
        padding: const EdgeInsets.only(
            left: PsDimens.space16, right: PsDimens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _spacingWidget,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: PsDimens.space20,
                    height: PsDimens.space20,
                    child: Icon(
                      Icons.phone_in_talk,
                    )),
                const SizedBox(
                  width: PsDimens.space12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Utils.getString(context, 'shop_info__phone'),
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    _spacingWidget,
                    InkWell(
                      child: Text(
                        phone.aboutPhone1,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(),
                      ),
                      onTap: () async {
                        if (await canLaunch('tel://${phone.aboutPhone1}')) {
                          await launch('tel://${phone.aboutPhone1}');
                        } else {
                          throw 'Could not Call Phone Number 1';
                        }
                      },
                    ),
                    _spacingWidget,
                    InkWell(
                      child: Text(
                        phone.aboutPhone2,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(),
                      ),
                      onTap: () async {
                        if (await canLaunch('tel://${phone.aboutPhone2}')) {
                          await launch('tel://${phone.aboutPhone2}');
                        } else {
                          throw 'Could not Call Phone Number 2';
                        }
                      },
                    ),
                    _spacingWidget,
                    InkWell(
                      child: Text(
                        phone.aboutPhone3,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(),
                      ),
                      onTap: () async {
                        if (await canLaunch('tel://${phone.aboutPhone3}')) {
                          await launch('tel://${phone.aboutPhone3}');
                        } else {
                          throw 'Could not Call Phone Number 3';
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            _spacingWidget,
          ],
        ));
  }
}

class _SourceAddressWidget extends StatelessWidget {
  const _SourceAddressWidget({
    Key key,
    @required this.data,
  }) : super(key: key);

  final ShopInfo data;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: PsColors.backgroundColor,
      margin: const EdgeInsets.only(top: PsDimens.space8),
      padding: const EdgeInsets.all(PsDimens.space16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(Utils.getString(context, 'shop_info__source_address'),
                  style: Theme.of(context).textTheme.subtitle1),
            ],
          ),
          const SizedBox(
            height: PsDimens.space8,
          ),
          Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
              ),
              _AddressWidget(icon: Icons.location_on, title: data.address1),
              _AddressWidget(icon: Icons.location_on, title: data.address2),
              _AddressWidget(icon: Icons.location_on, title: data.address3),
              const SizedBox(
                height: PsDimens.space12,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _AddressWidget extends StatelessWidget {
  const _AddressWidget({
    Key key,
    @required this.icon,
    @required this.title,
  }) : super(key: key);

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: PsDimens.space16,
        ),
        if (title != '')
          Row(
            children: <Widget>[
              Container(
                  width: PsDimens.space20,
                  height: PsDimens.space20,
                  child: Icon(
                    icon,
                  )),
              const SizedBox(
                width: PsDimens.space8,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          )
        else
          Row(
            children: <Widget>[
              Container(
                  width: PsDimens.space20,
                  height: PsDimens.space20,
                  child: Icon(
                    icon,
                  )),
              const SizedBox(
                width: PsDimens.space8,
              ),
              Text(
                '-',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          )
      ],
    );
  }
}

class _DescriptionWidget extends StatelessWidget {
  const _DescriptionWidget({Key key, this.data}) : super(key: key);

  final ShopInfo data;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(
          left: PsDimens.space16,
          right: PsDimens.space16,
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: PsDimens.space16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                data.description,
                style:
                    Theme.of(context).textTheme.bodyText2.copyWith(height: 1.3),
              ),
            )
          ],
        ));
  }
}
