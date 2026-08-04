// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i6;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i3;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:omnilink_admin/core/events/event_bus.dart' as _i4;
import 'package:omnilink_admin/core/theme/theme_cubit.dart' as _i5;
import 'package:omnilink_admin/features/admin/data/admin_api.dart' as _i7;
import 'package:omnilink_admin/features/admin/data/repositories/admin_repository.dart'
    as _i8;
import 'package:omnilink_admin/features/admin/presentation/bloc/admin_bloc.dart'
    as _i11;
import 'package:omnilink_admin/features/auth/data/auth_api.dart' as _i9;
import 'package:omnilink_admin/features/auth/data/repositories/auth_repository.dart'
    as _i10;
import 'package:omnilink_admin/features/auth/presentation/bloc/auth_bloc.dart'
    as _i12;

import '../network/dio_client.dart'
    as _i13; // ignore_for_file: unnecessary_lambdas

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
    gh.singleton<_i4.GlobalEventBus>(_i4.GlobalEventBus());
    gh.factory<_i5.ThemeCubit>(
        () => _i5.ThemeCubit(gh<_i3.FlutterSecureStorage>()));
    gh.lazySingleton<_i6.Dio>(
        () => networkModule.dio(gh<_i3.FlutterSecureStorage>()));
    gh.factory<_i7.AdminApi>(() => _i7.AdminApi(gh<_i6.Dio>()));
    gh.factory<_i8.AdminRepository>(
        () => _i8.AdminRepository(adminApi: gh<_i7.AdminApi>()));
    gh.lazySingleton<_i9.AuthApi>(() => _i9.AuthApi(gh<_i6.Dio>()));
    gh.lazySingleton<_i10.AuthRepository>(() => _i10.AuthRepository(
          gh<_i9.AuthApi>(),
          gh<_i3.FlutterSecureStorage>(),
        ));
    gh.factory<_i11.AdminBloc>(
        () => _i11.AdminBloc(adminRepository: gh<_i8.AdminRepository>()));
    gh.factory<_i12.AuthBloc>(() => _i12.AuthBloc(gh<_i10.AuthRepository>()));
    return this;
  }
}

class _$NetworkModule extends _i13.NetworkModule {}
