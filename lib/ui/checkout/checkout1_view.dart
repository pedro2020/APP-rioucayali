import 'package:flutter/material.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/repository/user_repository.dart';
import 'package:flutterrestaurant/ui/common/dialog/error_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/success_dialog.dart';
import 'package:flutterrestaurant/ui/common/ps_dropdown_base_with_controller_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_textfield_widget.dart';
import 'package:flutterrestaurant/ui/map/current_location_view.dart';
import 'package:flutterrestaurant/utils/ps_progress_dialog.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/profile_update_view_holder.dart';
import 'package:flutterrestaurant/viewobject/shipping_area.dart';
import 'package:flutterrestaurant/viewobject/user.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class Checkout1View extends StatefulWidget {
  const Checkout1View(this.updateCheckout1ViewState);
  final Function updateCheckout1ViewState;

  @override
  _Checkout1ViewState createState() {
    final _Checkout1ViewState _state = _Checkout1ViewState();
    updateCheckout1ViewState(_state);
    return _state;
  }
}

class _Checkout1ViewState extends State<Checkout1View> {
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPhoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController shippingAreaController = TextEditingController();

  bool isSwitchOn = false;
  UserRepository userRepository;
  UserProvider userProvider;
  PsValueHolder valueHolder;

  bool bindDataFirstTime = true;
  LatLng latlng;

  @override
  Widget build(BuildContext context) {
    userRepository = Provider.of<UserRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    return Consumer<UserProvider>(builder:
        (BuildContext context, UserProvider userProvider, Widget child) {
      if (userProvider.user != null && userProvider.user.data != null) {
        if (bindDataFirstTime) {
          /// Shipping Data
          userEmailController.text = userProvider.user.data.userEmail;
          userPhoneController.text = userProvider.user.data.userPhone;
          addressController.text = userProvider.user.data.address;
          shippingAreaController.text = userProvider.user.data.area.areaName +
              ' (' +
              userProvider.user.data.area.currencySymbol +
              userProvider.user.data.area.price +
              ')';
          userProvider.selectedArea = userProvider.user.data.area;
          latlng = userProvider.getUserLatLng();
          bindDataFirstTime = false;
        }
        return SingleChildScrollView(
          child: Container(
            color: PsColors.backgroundColor,
            padding: const EdgeInsets.only(
                left: PsDimens.space16, right: PsDimens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: PsDimens.space16,
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: PsDimens.space12,
                      right: PsDimens.space12,
                      top: PsDimens.space16),
                  child: Text(
                    Utils.getString(context, 'checkout1__contact_info'),
                    style: Theme.of(context).textTheme.subtitle2.copyWith(),
                  ),
                ),
                const SizedBox(
                  height: PsDimens.space16,
                ),
                PsTextFieldWidget(
                    titleText: Utils.getString(context, 'edit_profile__email'),
                    textAboutMe: false,
                    hintText: Utils.getString(context, 'edit_profile__email'),
                    textEditingController: userEmailController,
                    isMandatory: true),
                PsTextFieldWidget(
                    titleText: Utils.getString(context, 'edit_profile__phone'),
                    textAboutMe: false,
                    keyboardType: TextInputType.number,
                    hintText: Utils.getString(context, 'edit_profile__phone'),
                    textEditingController: userPhoneController,
                    isMandatory: true),
                CurrentLocationWidget(
                  androidFusedLocation: true,
                  textEditingController: addressController,
                  // userLatLng: latlng,
                ),
                Container(
                    width: double.infinity,
                    height: PsDimens.space120,
                    margin: const EdgeInsets.fromLTRB(
                        PsDimens.space8, 0, PsDimens.space8, PsDimens.space16),
                    decoration: BoxDecoration(
                      color: PsColors.backgroundColor,
                      borderRadius: BorderRadius.circular(PsDimens.space4),
                      border: Border.all(color: PsColors.mainDividerColor),
                    ),
                    child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        controller: addressController,
                        style: Theme.of(context).textTheme.bodyText2,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                            left: PsDimens.space12,
                            bottom: PsDimens.space8,
                            top: PsDimens.space10,
                          ),
                          border: InputBorder.none,
                          hintText:
                              Utils.getString(context, 'edit_profile__address'),
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: PsColors.textPrimaryLightColor),
                        ))),
                // PsTextFieldWidget(
                //     textAboutMe: true,
                //     height: PsDimens.space120,
                //     keyboardType: TextInputType.multiline,
                //     hintText: Utils.getString(context, 'edit_profile__address'),
                //     textEditingController: addressController),
                PsDropdownBaseWithControllerWidget(
                    title: Utils.getString(context, 'checkout1__area'),
                    textEditingController: shippingAreaController,
                    isMandatory: true,
                    onTap: () async {
                      final dynamic result = await Navigator.pushNamed(
                          context, RoutePaths.areaList);

                      if (result != null && result is ShippingArea) {
                        setState(() {
                          shippingAreaController.text = result.areaName +
                              ' (' +
                              result.currencySymbol +
                              ' ' +
                              result.price +
                              ')';
                          userProvider.selectedArea = result;
                        });
                      }
                    }),
                const SizedBox(height: PsDimens.space16),
              ],
            ),
          ),
        );
      } else {
        return Container();
      }
    });
  }

  dynamic checkIsDataChange(UserProvider userProvider) async {
    if (userProvider.user.data.userEmail == userEmailController.text &&
        userProvider.user.data.userPhone == userPhoneController.text &&
        userProvider.user.data.address == addressController.text &&
        userProvider.user.data.area.areaName == shippingAreaController.text &&
        userProvider.user.data.userLat == userProvider.originalUserLat &&
        userProvider.user.data.userLng == userProvider.originalUserLng) {
      return true;
    } else {
      return false;
    }
  }

  dynamic callUpdateUserProfile(UserProvider userProvider) async {
    bool isSuccess = false;

    if (await Utils.checkInternetConnectivity()) {
      final ProfileUpdateParameterHolder profileUpdateParameterHolder =
          ProfileUpdateParameterHolder(
        userId: userProvider.psValueHolder.loginUserId,
        userName: userProvider.user.data.userName,
        userEmail: userEmailController.text,
        userPhone: userPhoneController.text,
        userAddress: addressController.text,
        userAboutMe: userProvider.user.data.userAboutMe,
        userAreaId: userProvider.selectedArea.id,
        userLat: userProvider.user.data.userLat,
        userLng: userProvider.user.data.userLng,
      );
      PsProgressDialog.showDialog(context);
      final PsResource<User> _apiStatus = await userProvider
          .postProfileUpdate(profileUpdateParameterHolder.toMap());
      if (_apiStatus.data != null) {
        PsProgressDialog.dismissDialog();
        isSuccess = true;

        showDialog<dynamic>(
            context: context,
            builder: (BuildContext contet) {
              return SuccessDialog(
                message: Utils.getString(context, 'edit_profile__success'),
              );
            });
      } else {
        PsProgressDialog.dismissDialog();

        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: _apiStatus.message,
              );
            });
      }
    } else {
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__no_internet'),
            );
          });
    }

    return isSuccess;
  }
}
