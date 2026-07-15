// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i4;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i3;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:omnilink_frontend/core/network/sse_client.dart' as _i14;
import 'package:omnilink_frontend/features/auth/data/auth_api.dart' as _i7;
import 'package:omnilink_frontend/features/auth/data/repositories/auth_repository.dart'
    as _i8;
import 'package:omnilink_frontend/features/auth/presentation/bloc/auth_bloc.dart'
    as _i12;
import 'package:omnilink_frontend/features/device/data/devices_api.dart'
    as _i10;
import 'package:omnilink_frontend/features/device/data/repositories/device_repository.dart'
    as _i13;
import 'package:omnilink_frontend/features/device/presentation/bloc/device_bloc.dart'
    as _i15;
import 'package:omnilink_frontend/features/timeline/data/cards_api.dart' as _i9;
import 'package:omnilink_frontend/features/timeline/data/tags_api.dart' as _i5;
import 'package:omnilink_frontend/features/timeline/presentation/bloc/tags_bloc.dart'
    as _i6;
import 'package:omnilink_frontend/features/timeline/presentation/bloc/timeline_bloc.dart'
    as _i11;

import '../network/dio_client.dart'
    as _i16; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
extension GetItInjectableX on _i1.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i3.FlutterSecureStorage>(
        () => networkModule.secureStorage);
    gh.lazySingleton<_i4.Dio>(
        () => networkModule.dio(gh<_i3.FlutterSecureStorage>()));
    gh.lazySingleton<_i5.TagsApi>(() => _i5.TagsApi(gh<_i4.Dio>()));
    gh.lazySingleton<_i6.TagsBloc>(() => _i6.TagsBloc(gh<_i5.TagsApi>()));
    gh.lazySingleton<_i7.AuthApi>(() => _i7.AuthApi(gh<_i4.Dio>()));
    gh.lazySingleton<_i8.AuthRepository>(() => _i8.AuthRepository(
          gh<_i7.AuthApi>(),
          gh<_i3.FlutterSecureStorage>(),
        ));
    gh.lazySingleton<_i9.CardsApi>(() => _i9.CardsApi(gh<_i4.Dio>()));
    gh.lazySingleton<_i10.DevicesApi>(() => _i10.DevicesApi(gh<_i4.Dio>()));
    gh.lazySingleton<_i11.TimelineBloc>(
        () => _i11.TimelineBloc(gh<_i9.CardsApi>()));
    gh.factory<_i12.AuthBloc>(() => _i12.AuthBloc(gh<_i8.AuthRepository>()));
    gh.lazySingleton<_i13.DeviceRepository>(() => _i13.DeviceRepository(
          gh<_i10.DevicesApi>(),
          gh<_i3.FlutterSecureStorage>(),
        ));
    gh.lazySingleton<_i14.SseClient>(() => _i14.SseClient(
          gh<_i4.Dio>(),
          gh<_i13.DeviceRepository>(),
          gh<_i11.TimelineBloc>(),
        ));
    gh.lazySingleton<_i15.DeviceBloc>(
        () => _i15.DeviceBloc(gh<_i13.DeviceRepository>()));
    return this;
  }
}

class _$NetworkModule extends _i16.NetworkModule {}
