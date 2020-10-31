import 'package:flutterrestaurant/provider/user/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterrestaurant/viewobject/transaction_header.dart';

class CheckoutStatusIntentHolder {
  const CheckoutStatusIntentHolder({
    @required this.transactionHeader,
    @required this.userProvider,
  });

  final TransactionHeader transactionHeader;
  final UserProvider userProvider;
}
