import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/constant/route_paths.dart';
import 'package:flutterrestaurant/ui/common/ps_expansion_tile.dart';
import 'package:flutterrestaurant/utils/utils.dart';
import 'package:flutter/material.dart';

class TermsAndPolicyTileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget _expansionTileTitleWidget = Text(
        Utils.getString(context, 'terms_and_policy_tile__terms_and_policy'),
        style: Theme.of(context).textTheme.subtitle1);

    return Container(
      margin: const EdgeInsets.only(
          left: PsDimens.space12,
          right: PsDimens.space12,
          bottom: PsDimens.space12),
      decoration: BoxDecoration(
        color: PsColors.backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(PsDimens.space8)),
      ),
      child: PsExpansionTile(
        initiallyExpanded: true,
        title: _expansionTileTitleWidget,
        children: <Widget>[
          Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, RoutePaths.privacyPolicy,
                      arguments: 2);
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: PsDimens.space16,
                      left: PsDimens.space16,
                      right: PsDimens.space16,
                      bottom: PsDimens.space16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        Utils.getString(context,
                            'terms_and_policy_tile__terms_and_condition'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(color: PsColors.mainColor),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, RoutePaths.privacyPolicy,
                                arguments: 2);
                          },
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: PsDimens.space16,
                          )),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, RoutePaths.privacyPolicy,
                      arguments: 3);
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: PsDimens.space16,
                      left: PsDimens.space16,
                      right: PsDimens.space16,
                      bottom: PsDimens.space16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        Utils.getString(
                            context, 'terms_and_policy_tile__refund_policy'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(color: PsColors.mainColor),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, RoutePaths.privacyPolicy,
                                arguments: 3);
                          },
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: PsDimens.space16,
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
