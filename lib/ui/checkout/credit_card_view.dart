import 'dart:io';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/config/ps_config.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/provider/basket/basket_provider.dart';
import 'package:flutterrestaurant/provider/transaction/transaction_header_provider.dart';
import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutterrestaurant/ui/common/base/ps_widget_with_appbar_with_no_provider.dart';
import 'package:flutterrestaurant/ui/common/dialog/error_dialog.dart';
import 'package:flutterrestaurant/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrestaurant/ui/common/ps_button_widget.dart';
import 'package:flutterrestaurant/ui/common/ps_credit_card_form.dart';
import 'package:flutterrestaurant/utils/ps_progress_dialog.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutterrestaurant/viewobject/basket.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
import 'package:flutterrestaurant/viewobject/holder/intent_holder/checkout_status_intent_holder.dart';
import 'package:flutterrestaurant/viewobject/transaction_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:mercado_pago/mercado_pago.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show required;

class CreditCardView extends StatefulWidget {
  const CreditCardView(
      {Key key,
      @required this.basketList,
      @required this.couponDiscount,
      @required this.psValueHolder,
      @required this.transactionSubmitProvider,
      @required this.userLoginProvider,
      @required this.basketProvider,
      @required this.memoText,
      @required this.publishKey,
      @required this.mercadopagoKey,
      @required this.mercadopagoAccessToken})
      : super(key: key);

  final List<Basket> basketList;
  final String couponDiscount;
  final PsValueHolder psValueHolder;
  final TransactionHeaderProvider transactionSubmitProvider;
  final UserProvider userLoginProvider;
  final BasketProvider basketProvider;
  final String memoText;
  final String publishKey;
  final String mercadopagoKey;
  final String mercadopagoAccessToken;


  @override
  State<StatefulWidget> createState() {
    return CreditCardViewState();
  }
}

dynamic callTransactionSubmitApi(
    BuildContext context,
    BasketProvider basketProvider,
    UserProvider userLoginProvider,
    TransactionHeaderProvider transactionSubmitProvider,
    List<Basket> basketList,
    String token,
    String couponDiscount,
    String memoText) async {
  if (await Utils.checkInternetConnectivity()) {
    if (userLoginProvider.user != null && userLoginProvider.user.data != null) {
      final PsResource<TransactionHeader> _apiStatus =
          await transactionSubmitProvider.postTransactionSubmit(
              userLoginProvider.user.data,
              basketList,
              Platform.isIOS ? token : token,
              couponDiscount.toString(),
              basketProvider.checkoutCalculationHelper.tax.toString(),
              basketProvider.checkoutCalculationHelper.totalDiscount.toString(),
              basketProvider.checkoutCalculationHelper.subTotalPrice.toString(),
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              basketProvider.checkoutCalculationHelper.totalPrice.toString(),
              basketProvider.checkoutCalculationHelper.totalOriginalPrice
                  .toString(),
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ONE,
              PsConst.ZERO,
              PsConst.ZERO,
              PsConst.ZERO,
              '',
              basketProvider.checkoutCalculationHelper.shippingCost.toString(),
              userLoginProvider.user.data.area.areaName,
              memoText);
      print(_apiStatus.status);
      if (_apiStatus.data != null) {
        PsProgressDialog.dismissDialog();

        if (_apiStatus.status == PsStatus.SUCCESS) {
          await basketProvider.deleteWholeBasketList();

          print(_apiStatus.data);

          await Navigator.pushNamed(context, RoutePaths.checkoutSuccess,
              arguments: CheckoutStatusIntentHolder(
                transactionHeader: _apiStatus.data,
                userProvider: userLoginProvider,
              ));
          Navigator.pop(context, true);
        } else {
          print('hh');
          PsProgressDialog.dismissDialog();

          return showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: _apiStatus.message,
                );
              });
        }
      } else {
        PsProgressDialog.dismissDialog();

        return showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                message: _apiStatus.message+'s',
              );
            });
      }
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
}

CreditCard callCard(String cardNumber, String expiryDate, String cardHolderName,
    String cvvCode) {
  final List<String> monthAndYear = expiryDate.split('/');
  return CreditCard(
      number: cardNumber,
      expMonth: int.parse(monthAndYear[0]),
      expYear: int.parse(monthAndYear[1]),
      name: cardHolderName,
      cvc: cvvCode);
}

class CreditCardViewState extends State<CreditCardView> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  @override
  void initState() {
    /*StripePayment.setOptions(StripeOptions(
        publishableKey: widget.publishKey,
        merchantId: 'Test',
        androidPayMode: 'test'));*/
    super.initState();
  }

 // PsValueHolder

  MercadoPago get mercadoPago {
    List<String> keys = [
      //'TEST-98041829-8c47-4c6a-9c23-7b6e1855f31d',
      widget.psValueHolder.mercadopagoKey,
      //widget.mercadopagoKey,
      widget.psValueHolder.mercadopagoAccessToken
      //'TEST-3029117202042245-103104-2fd0688859e43720378e5ed1043114f4__LC_LB__-182447115',
    ];
    MercadoCredentials credentials = MercadoCredentials(
      publicKey: keys[0],
      accessToken: keys[1],
    );

    return MercadoPago(credentials);
  }

  Future<MercadoObject> responseMercadopago(
      dynamic response, {
        int customSuccessCode = 201,
      }) async {
    /// decode response
    var jsonBody = json.decode(response.body);

    MercadoObject responseObject = MercadoObject();
    responseObject.isSuccessful = true;
    responseObject.data = jsonBody;

    /// if error
    if (response.statusCode != customSuccessCode) {
      responseObject.isSuccessful = false;

      try {
        responseObject.errorCode = jsonBody["cause"][0]["code"];
      } //
      catch (_) {
        responseObject.errorCode = response.statusCode.toString();
      }
    }

    return responseObject;
  }

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    final url = 'https://api.mercadopago.com/v1/customers/search?email=$email&access_token='+widget.psValueHolder.mercadopagoAccessToken;

   // return await http.get(url);

    final response = await http.get(url);

    return {
      'status': response.statusCode,
      'response': json.decode(response.body),
    };
//    print(response);
    //return responseMercadopago(response, customSuccessCode:201);
  }

  Future<MercadoObject> newCard2({
    @required String code,
    @required String year,
    @required int month,
    @required String card,
    @required String documentType,
    @required String documentNumber,
    @required String fullName
  }) async {
    final url = 'https://api.mercadopago.com/v1/cards?public_key='+widget.psValueHolder.mercadopagoKey;

    var first_six = card.trim().substring(0,5);
    var last_four = card.trim().substring(12,15);

    print(card.replaceAll(' ', ''));

    print(first_six+'/'+last_four);

    var body = {
      'security_code': code,
      'expiration_year': year,
      'expiration_month': month,
      'card_number': card,
      'first_six_digits':first_six,
      'last_four_digits':last_four,
      'cardholder': {
        'identification': {
          'number': documentNumber,
          'type': documentType,
        },
        'name': fullName
      }
    };

    //return await _post(url, body);
    final response = await http.post(url, body:json.encode(body) );

    /*return {
      'status': response.statusCode,
      'response': json.decode(response.body),
    };*/
//    print(response);
    return responseMercadopago(response, customSuccessCode:201);
  }


  void setError(dynamic error) {
    showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, error.toString()),
          );
        });
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

  @override
  Widget build(BuildContext context) {
    dynamic mercadopagoNow(String token) async {
      widget.basketProvider.checkoutCalculationHelper.calculate(
          basketList: widget.basketList,
          couponDiscountString: widget.couponDiscount,
          psValueHolder: widget.psValueHolder,
          shippingPriceStringFormatting:
              widget.userLoginProvider.user.data.area.price);

      PsProgressDialog.showDialog(context);
      callTransactionSubmitApi(
          context,
          widget.basketProvider,
          widget.userLoginProvider,
          widget.transactionSubmitProvider,
          widget.basketList,
          // progressDialog,
          token,
          widget.couponDiscount,
          widget.memoText);
    }

    return PsWidgetWithAppBarWithNoProvider(
      appBarTitle: 'Credit Card',
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              children: <Widget>[
                CreditCardWidget(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                  height: 175,
                  width: MediaQuery.of(context).size.width,
                  animationDuration: PsConfig.animation_duration,
                ),
                PsCreditCardForm(
                  onCreditCardModelChange: onCreditCardModelChange,
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: PsDimens.space12, right: PsDimens.space12),
                  child: PSButtonWidget(
                    hasShadow: true,
                    width: double.infinity,
                    titleText: Utils.getString(context, 'credit_card__pay'),
                    onPressed: () async {
                      if (cardNumber.isEmpty) {
                        callWarningDialog(
                            context,
                            Utils.getString(
                                context, 'warning_dialog__input_number'));
                      } else if (expiryDate.isEmpty) {
                        callWarningDialog(
                            context,
                            Utils.getString(
                                context, 'warning_dialog__input_date'));
                      } else if (cardHolderName.isEmpty) {
                        callWarningDialog(
                            context,
                            Utils.getString(
                                context, 'warning_dialog__input_holder_name'));
                      } else if (cvvCode.isEmpty) {
                        callWarningDialog(
                            context,
                            Utils.getString(
                                context, 'warning_dialog__input_cvv'));
                      } else {
                        /*StripePayment.createTokenWithCard(
                          callCard(
                              cardNumber, expiryDate, cardHolderName, cvvCode),
                        ).then((Token token) async {
                          await stripeNow(token.tokenId);
                        }).catchError(setError);*/

                        //agregar MP
                        print('Crear nuevo usuario');
                        MercadoObject responseUser = await mercadoPago.newUser(
                          email: widget.userLoginProvider.holderUser.userEmail,
                          firstname: widget.userLoginProvider.holderUser.userName,
                          lastName: widget.userLoginProvider.holderUser.userName,

                        );

                        //print(responseUser);

                        if(responseUser.isSuccessful==true){


                              final List<String> monthAndYear = expiryDate.split('/');
                              MercadoObject responseCard = await mercadoPago.newCard(
                                code: cvvCode,
                                year: monthAndYear[1],
                                month: int.parse(monthAndYear[0]),
                                card: cardNumber,
                                documentType:'DNI',
                                documentNumber:'1222',
                                fullName: cardHolderName,
                              );

                              if(responseCard.isSuccessful==true){
                                  //ASociarla a un cliente
                                  print('asociar tarjeta a usuario');
                                  var customerId = responseUser.data['id'];
                                  String cardId = responseCard.data['id'];
                                  String userIdN =responseUser.data['id'];
                                  MercadoObject responseCardWithUser = await mercadoPago.associateCardWithUser(
                                    user: userIdN,
                                    card: cardId,
                                  );
                                  print(responseCardWithUser);

                                  if(responseCardWithUser.isSuccessful==false){

                                    print('Obtener tarjeta por el usuario');
                                    String userId = customerId;
                                    MercadoObject responseCardWithUser = await mercadoPago.cardsFromUser(
                                      user: userId,
                                    );
                                    print(responseCardWithUser);
                                  }

                                  print('Crear un token');
                                  String cardId2 = responseCardWithUser.data['id'];
                                  String cardCVV = cvvCode;
                                  MercadoObject responseToken = await mercadoPago.tokenWithCard(
                                    card: cardId2,
                                    code: cardCVV,
                                  );
                                  print(responseToken);

                                  print('Crear un pago');

                                  String cardToken = responseToken.data['id'];
                                  String userId2 = customerId;
                                  MercadoObject response = await mercadoPago.createPayment(
                                    total: double.parse(widget.basketProvider.checkoutCalculationHelper.totalPrice.toString()),
                                    cardToken: cardToken,
                                    description: 'Pago',
                                    paymentMethod: responseCardWithUser.data['payment_method']['id'],
                                    userId: userId2,
                                    email: widget.userLoginProvider.holderUser.userEmail,
                                  );
                                  print(response);
                                  if(response.isSuccessful==true && response.data['status']=='approved'){

                                    await mercadopagoNow(cardToken);
                                  }


                              }else{
                                print(responseCard);
                              }

                        }else{

                           print('Obtener usuario por correo');
                           var rs = await getUserByEmail(widget.userLoginProvider.holderUser.userEmail);
                           var customerId = rs['response']['results'][0]['id']; //CustomerId

                           print('Nueva Tarjeta');
                           final List<String> monthAndYear = expiryDate.split('/');
                           MercadoObject responseCard = await mercadoPago.newCard(
                             code: cvvCode,
                             year: '20'+monthAndYear[1],
                             month: int.parse(monthAndYear[0]),
                             card: cardNumber.replaceAll(' ', ''),
                             documentType: 'DNI',
                             documentNumber:'16615879',
                             fullName: cardHolderName,
                           );

                           //print(int.parse(monthAndYear[0]));
                           if(responseCard.isSuccessful==true){
                             //ASociarla a un cliente
                             print('asociar tarjeta a usuario');
                             String cardId = responseCard.data['id'];
                             String userId =customerId;
                             MercadoObject responseCardWithUser = await mercadoPago.associateCardWithUser(
                               user: userId,
                               card: cardId,
                             );
                             print(responseCardWithUser);

                             if(responseCardWithUser.isSuccessful==false){

                               print('Obtener tarjeta por el usuario');
                               String userId = customerId;
                               MercadoObject responseCardWithUser = await mercadoPago.cardsFromUser(
                                 user: userId,
                               );
                               print(responseCardWithUser);
                             }

                             print('Crear un token');
                             String cardId2 = responseCardWithUser.data['id'];
                             String cardCVV = cvvCode;
                             MercadoObject responseToken = await mercadoPago.tokenWithCard(
                               card: cardId2,
                               code: cardCVV,
                             );
                             print(responseToken);

                             print('Crear un pago');
                             //var f = new NumberFormat("###.0#", "en_US");
                             //basketProvider.checkoutCalculationHelper.totalPrice.toString()
                             String cardToken = responseToken.data['id'];
                             String userId2 = customerId;
                             MercadoObject response = await mercadoPago.createPayment(
                               total: double.parse(widget.basketProvider.checkoutCalculationHelper.totalPrice.toString()),
                               cardToken: cardToken,
                               description: 'Pago',
                               paymentMethod: responseCardWithUser.data['payment_method']['id'],
                               userId: userId2,
                               email: widget.userLoginProvider.holderUser.userEmail,
                             );

                             //print(f.format(widget.basketProvider.checkoutCalculationHelper.totalPrice));
                             print(response);

                                if(response.isSuccessful==true && response.data['status']=='approved'){

                                  await mercadopagoNow(cardToken);
                                }



                           }else{
                             print('ERROR AL CREAR UNA TARJETA');
                           }



                        }





                        /*test('associate card with user', () async {
                          String cardId = 'ee6bbbee69f60990d0f68ffe108ef1ad';
                          String userId = '555305508-i67KHqcUTewosJ';
                          MercadoObject response = await mercadoPago.associateCardWithUser(
                            user: userId,
                            card: cardId,
                          );
                          print(response);
                        });

                        test('get cards for user', () async {
                          String userId = '555305508-i67KHqcUTewosJ';
                          MercadoObject response = await mercadoPago.cardsFromUser(
                            user: userId,
                          );
                          print(response);
                        });*/

                        /*test('create card token for payment', () async {
                          String cardId = '1587964933876';
                          String cardCVV = '333';
                          MercadoObject response = await mercadoPago.tokenWithCard(
                            card: cardId,
                            code: cardCVV,
                          );
                          print(response);
                        });*/

                        /*test('simple payment', () async {
                          String cardToken = 'ebcc4d445e845f052f702ed7015c4d57';
                          String userId = '555305508-i67KHqcUTewosJ';
                          MercadoObject response = await mercadoPago.createPayment(
                            total: 10.0,
                            cardToken: cardToken,
                            description: 'test payment',
                            paymentMethod: 'visa',
                            userId: userId,
                            email: 'brian1@mail.com',
                          );
                          print(response);
                        });*/

                      }
                    },
                  ),
                ),
                const SizedBox(height: PsDimens.space40)
              ],
            )),
          ),
        ],
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
