import 'package:collection_menu_1/database/data_io.dart';
import 'package:collection_menu_1/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'generated/codegen_loader.g.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_color_schemes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await DataIO.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            return ThemeProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return LocaleProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return HomeProvider();
          },
        ),
      ],
      child: EasyLocalization(
        supportedLocales: [
          Locale('en'),
          Locale('th'),
          Locale('my'),
          Locale('de'),
          Locale('zh'),
          Locale('ru'),
          Locale('he'),
          Locale('es'),
          Locale('ko'),
        ],
        path: 'assets/translations',
        fallbackLocale: Locale('en'),
        assetLoader: CodegenLoader(),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: LocaleProvider.navigatorKey,
          title: 'Food App',
          theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          initialRoute: AppRoutes.main,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
