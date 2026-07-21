// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i5;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i3;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i4;
import 'package:omnilink_frontend/core/network/sse_client.dart' as _i15;
import 'package:omnilink_frontend/features/auth/data/auth_api.dart' as _i8;
import 'package:omnilink_frontend/features/auth/data/repositories/auth_repository.dart'
    as _i9;
import 'package:omnilink_frontend/features/auth/presentation/bloc/auth_bloc.dart'
    as _i13;
import 'package:omnilink_frontend/features/device/data/devices_api.dart'
    as _i11;
import 'package:omnilink_frontend/features/device/data/repositories/device_repository.dart'
    as _i14;
import 'package:omnilink_frontend/features/device/presentation/bloc/device_bloc.dart'
    as _i16;
import 'package:omnilink_frontend/features/timeline/data/cards_api.dart'
    as _i10;
import 'package:omnilink_frontend/features/timeline/data/tags_api.dart' as _i6;
import 'package:omnilink_frontend/features/timeline/presentation/bloc/tags_bloc.dart'
    as _i7;
import 'package:omnilink_frontend/features/timeline/presentation/bloc/timeline_bloc.dart'
    as _i12;

import '../network/dio_client.dart'
    as _i17; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
extension GetItInjectableX on _i1.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i3.FlutterSecureStorage>(
        () => networkModule.secureStorage);
    await gh.singletonAsync<_i4.Isar>(
      () => networkModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i5.Dio>(
        () => networkModule.dio(gh<_i3.FlutterSecureStorage>()));
    gh.lazySingleton<_i6.TagsApi>(() => _i6.TagsApi(gh<_i5.Dio>()));
    gh.lazySingleton<_i7.TagsBloc>(() => _i7.TagsBloc(gh<_i6.TagsApi>()));
    gh.lazySingleton<_i8.AuthApi>(() => _i8.AuthApi(gh<_i5.Dio>()));
    gh.lazySingleton<_i9.AuthRepository>(() => _i9.AuthRepository(
          gh<_i8.AuthApi>(),
          gh<_i3.FlutterSecureStorage>(),
        ));
    gh.lazySingleton<_i10.CardsApi>(() => _i10.CardsApi(gh<_i5.Dio>()));
    gh.lazySingleton<_i11.DevicesApi>(() => _i11.DevicesApi(gh<_i5.Dio>()));
    gh.lazySingleton<_i12.TimelineBloc>(() => _i12.TimelineBloc(
          gh<_i10.CardsApi>(),
          gh<_i4.Isar>(),
        ));
    gh.factory<_i13.AuthBloc>(() => _i13.AuthBloc(gh<_i9.AuthRepository>()));
    gh.lazySingleton<_i14.DeviceRepository>(() => _i14.DeviceRepository(
          gh<_i11.DevicesApi>(),
          gh<_i3.FlutterSecureStorage>(),
        ));
    gh.lazySingleton<_i15.SseClient>(() => _i15.SseClient(
          gh<_i5.Dio>(),
          gh<_i14.DeviceRepository>(),
          gh<_i12.TimelineBloc>(),
        ));
    gh.lazySingleton<_i16.DeviceBloc>(
        () => _i16.DeviceBloc(gh<_i14.DeviceRepository>()));
    return this;
  }
}

class _$NetworkModule extends _i17.NetworkModule {}
