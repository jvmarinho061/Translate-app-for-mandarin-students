import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinyinapp/app/router/app_router.dart';
import 'package:pinyinapp/app/theme/app_theme.dart';
import 'package:pinyinapp/core/di/dependencies.dart';
import 'package:pinyinapp/features/dictionary/presentation/cubit/search_cubit.dart';
import 'package:pinyinapp/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:pinyinapp/features/history/presentation/cubit/history_cubit.dart';
import 'package:pinyinapp/features/settings/domain/entities/app_theme_mode.dart';
import 'package:pinyinapp/features/settings/presentation/cubit/theme_cubit.dart';

class PinyinApp extends StatefulWidget {
  const PinyinApp({required this.dependencies, super.key});

  final Dependencies dependencies;

  @override
  State<PinyinApp> createState() => _PinyinAppState();
}

class _PinyinAppState extends State<PinyinApp> {
  late final GoRouter _router = AppRouter.build(widget.dependencies);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SearchCubit(widget.dependencies.dictionary),
        ),
        BlocProvider(
          create: (_) => FavoritesCubit(widget.dependencies.favorites),
        ),
        BlocProvider(
          create: (_) => HistoryCubit(widget.dependencies.history),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(widget.dependencies.settings),
        ),
      ],
      child: BlocBuilder<ThemeCubit, AppThemeMode>(
        builder: (context, mode) => MaterialApp.router(
          title: 'pinyinapp',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode.toFlutter(),
          routerConfig: _router,
        ),
      ),
    );
  }
}
