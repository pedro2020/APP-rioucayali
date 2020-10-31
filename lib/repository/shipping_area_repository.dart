import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/api/ps_api_service.dart';
import 'package:flutterrestaurant/db/shipping_area_dao.dart';
import 'package:flutterrestaurant/viewobject/shipping_area.dart';
import 'package:sembast/sembast.dart';

import 'Common/ps_repository.dart';

class ShippingAreaRepository extends PsRepository {
  ShippingAreaRepository(
      {@required PsApiService psApiService,
      @required ShippingAreaDao shippingAreaDao}) {
    _psApiService = psApiService;
    _shippingAreaDao = shippingAreaDao;
  }

  String primaryKey = 'id';
  PsApiService _psApiService;
  ShippingAreaDao _shippingAreaDao;

  Future<dynamic> insert(ShippingArea shippingArea) async {
    return _shippingAreaDao.insert(primaryKey, shippingArea);
  }

  Future<dynamic> update(ShippingArea shippingArea) async {
    return _shippingAreaDao.update(shippingArea);
  }

  Future<dynamic> delete(ShippingArea shippingArea) async {
    return _shippingAreaDao.delete(shippingArea);
  }

  Future<dynamic> getShippingById(
      bool isConnectedToInternet, String shippingId, PsStatus status,
      {bool isLoadFromServer = true}) async {
    // final Finder finder = Finder();

    if (isConnectedToInternet) {
      final PsResource<ShippingArea> _resource =
          await _psApiService.getShippingAreaById(shippingId);

      if (_resource.status == PsStatus.SUCCESS) {
        await _shippingAreaDao.insert(primaryKey, _resource.data);
      }
    }

    return await _shippingAreaDao.getOne(
        finder: Finder(filter: Filter.equals(primaryKey, shippingId)));
  }

  Future<dynamic> getAllShippingAreaList(
      StreamController<PsResource<List<ShippingArea>>> shippingAreaListStream,
      bool isConnectedToInternet,
      int limit,
      int offset,
      PsStatus status,
      {bool isNeedDelete = true,
      bool isLoadFromServer = true}) async {
    // final Finder finder = Finder();
    shippingAreaListStream.sink
        .add(await _shippingAreaDao.getAll(status: status));

    if (isConnectedToInternet) {
      final PsResource<List<ShippingArea>> _resource =
          await _psApiService.getShippingArea();

      if (_resource.status == PsStatus.SUCCESS) {
        if (isNeedDelete) {
          await _shippingAreaDao.deleteAll();
        }
        await _shippingAreaDao.insertAll(primaryKey, _resource.data);
        shippingAreaListStream.sink.add(await _shippingAreaDao.getAll());
      } else {
        shippingAreaListStream.sink.add(await _shippingAreaDao.getAll());
      }
    }
  }

  Future<dynamic> getNextPageShippingAreaList(
      StreamController<PsResource<List<ShippingArea>>> shippingAreaListStream,
      bool isConnectedToInternet,
      int limit,
      int offset,
      PsStatus status,
      {bool isNeedDelete = true,
      bool isLoadFromServer = true}) async {
    final Finder finder = Finder();
    shippingAreaListStream.sink
        .add(await _shippingAreaDao.getAll(finder: finder, status: status));

    if (isConnectedToInternet) {
      final PsResource<List<ShippingArea>> _resource =
          await _psApiService.getShippingArea();

      if (_resource.status == PsStatus.SUCCESS) {
        await _shippingAreaDao.insertAll(primaryKey, _resource.data);
      }
      shippingAreaListStream.sink.add(await _shippingAreaDao.getAll());
    }
  }
}
