import 'dart:async';
import 'dart:io';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/provider/clear_all/clear_all_data_provider.dart';
import 'package:flutterrestaurant/repository/clear_all_data_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/version_update_dialog.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/app_info_parameter_holder.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/app_info/app_info_provider.dart';
import 'package:flutterrestaurant/repository/app_info_repository.dart';
import 'package:flutterrestaurant/viewobject/ps_app_info.dart';
import 'package:provider/single_child_widget.dart';

class AppInfoView extends StatelessWidget {
  Future<dynamic> loadDeleteHistory(AppInfoProvider provider,
      ClearAllDataProvider clearAllDataProvider, BuildContext context) async {
    String realStartDate = '0';
    String realEndDate = '0';
    if (await Utils.checkInternetConnectivity()) {
      if (provider.psValueHolder == null ||
          provider.psValueHolder.startDate == null) {
        realStartDate =
            DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
      } else {
        realStartDate = provider.psValueHolder.endDate;
      }

      realEndDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
      final AppInfoParameterHolder appInfoParameterHolder =
          AppInfoParameterHolder(
        startDate: realStartDate,
        endDate: realEndDate,
      );

      final PsResource<PSAppInfo> _psAppInfo =
          await provider.loadDeleteHistory(appInfoParameterHolder.toMap());

      if (_psAppInfo.status == PsStatus.SUCCESS) {
        provider.replaceDate(realStartDate, realEndDate);
        print(Utils.getString(context, 'app_info__cancel_button_name'));
        print(Utils.getString(context, 'app_info__update_button_name'));

        checkVersionNumber(
            context, _psAppInfo.data, provider, clearAllDataProvider);
        realStartDate = realEndDate;
      } else if (_psAppInfo.status == PsStatus.ERROR) {
        Navigator.pushReplacementNamed(
          context,
          RoutePaths.home,
        );
      }
    } else {
      Navigator.pushReplacementNamed(
        context,
        RoutePaths.home,
      );
    }
  }

  final Widget _imageWidget = Container(
    width: 90,
    height: 90,
    child: Image.asset(
      'assets/images/fs_android_3x.png',
    ),
  );

  dynamic checkVersionNumber(
      BuildContext context,
      PSAppInfo psAppInfo,
      AppInfoProvider appInfoProvider,
      ClearAllDataProvider clearAllDataProvider) async {
    if (PsConfig.app_version != psAppInfo.psAppVersion.versionNo) {
      if (psAppInfo.psAppVersion.versionNeedClearData == PsConst.ONE) {
        await clearAllDataProvider.clearAllData();
        checkForceUpdate(context, psAppInfo, appInfoProvider);
      } else {
        checkForceUpdate(context, psAppInfo, appInfoProvider);
      }
    } else {
      appInfoProvider.replaceVersionForceUpdateData(false);

      Navigator.pushReplacementNamed(
        context,
        RoutePaths.home,
      );
    }
  }

  dynamic checkForceUpdate(BuildContext context, PSAppInfo psAppInfo,
      AppInfoProvider appInfoProvider) {
    if (psAppInfo.psAppVersion.versionForceUpdate == PsConst.ONE) {
      appInfoProvider.replaceAppInfoData(
          psAppInfo.psAppVersion.versionNo,
          true,
          psAppInfo.psAppVersion.versionTitle,
          psAppInfo.psAppVersion.versionMessage);

      Navigator.pushReplacementNamed(
        context,
        RoutePaths.force_update,
        arguments: psAppInfo.psAppVersion,
      );
    } else if (psAppInfo.psAppVersion.versionForceUpdate == PsConst.ZERO) {
      appInfoProvider.replaceVersionForceUpdateData(false);
      callVersionUpdateDialog(context, psAppInfo);
    } else {
      Navigator.pushReplacementNamed(
        context,
        RoutePaths.home,
      );
    }
  }

  dynamic callVersionUpdateDialog(BuildContext context, PSAppInfo psAppInfo) {
    showDialog<dynamic>(
        barrierDismissible: false,
        useRootNavigator: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () {
                return;
              },
              child: VersionUpdateDialog(
                title: psAppInfo.psAppVersion.versionTitle,
                description: psAppInfo.psAppVersion.versionMessage,
                leftButtonText:
                    Utils.getString(context, 'app_info__cancel_button_name'),
                rightButtonText:
                    Utils.getString(context, 'app_info__update_button_name'),
                onCancelTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    RoutePaths.home,
                  );
                },
                onUpdateTap: () async {
                  Navigator.pushReplacementNamed(
                    context,
                    RoutePaths.home,
                  );

                  if (Platform.isIOS) {
                    Utils.launchAppStoreURL(iOSAppId: PsConfig.iOSAppStoreId);
                  } else if (Platform.isAndroid) {
                    Utils.launchURL();
                  }
                },
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    AppInfoRepository repo1;
    AppInfoProvider provider;
    ClearAllDataRepository clearAllDataRepository;
    ClearAllDataProvider clearAllDataProvider;
    PsValueHolder valueHolder;

    PsColors.loadColor(context);
    valueHolder = Provider.of<PsValueHolder>(context);
    repo1 = Provider.of<AppInfoRepository>(context);
    clearAllDataRepository = Provider.of<ClearAllDataRepository>(context);
    // final dynamic data = EasyLocalizationProvider.of(context).data;
    return
        // EasyLocalizationProvider(
        //   data: data,
        //   child:
        MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ClearAllDataProvider>(
            lazy: false,
            create: (BuildContext context) {
              clearAllDataProvider = ClearAllDataProvider(
                  repo: clearAllDataRepository, psValueHolder: valueHolder);

              return clearAllDataProvider;
            }),
        ChangeNotifierProvider<AppInfoProvider>(
            lazy: false,
            create: (BuildContext context) {
              provider =
                  AppInfoProvider(repo: repo1, psValueHolder: valueHolder);
              loadDeleteHistory(provider, clearAllDataProvider, context);
              return provider;
            }),
      ],
      child: Consumer<AppInfoProvider>(
        builder: (BuildContext context, AppInfoProvider clearAllDataProvider,
            Widget child) {
          return Consumer<AppInfoProvider>(builder: (BuildContext context,
              AppInfoProvider clearAllDataProvider, Widget child) {
            return Container(
                height: 400,
                color: PsColors.mainColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _imageWidget,
                        const SizedBox(
                          height: PsDimens.space16,
                        ),
                        Text(
                          Utils.getString(context, 'app_name'),
                          style: Theme.of(context).textTheme.headline6.copyWith(
                              fontWeight: FontWeight.bold,
                              color: PsColors.white),
                        ),
                        const SizedBox(
                          height: PsDimens.space8,
                        ),
                        Text(
                          Utils.getString(context, 'app_info__splash_name'),
                          style: Theme.of(context).textTheme.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: PsColors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.all(PsDimens.space16),
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: PsButtonWidget(
                              provider: provider,
                              text: Utils.getString(
                                  context, 'app_info__submit_button_name'),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ));
          });
        },
      ),
      // ),
    );
  }
}

class PsButtonWidget extends StatefulWidget {
  const PsButtonWidget({
    @required this.provider,
    @required this.text,
  });
  final AppInfoProvider provider;
  final String text;

  @override
  _PsButtonWidgetState createState() => _PsButtonWidgetState();
}

class _PsButtonWidgetState extends State<PsButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(PsColors.loadingCircleColor),
        strokeWidth: 5.0);
  }
}
