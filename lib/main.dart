import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:selecaosicoob/bin/model/sla_params.dart';
import 'package:selecaosicoob/bin/pages/home_page/home_page.dart';
import 'package:selecaosicoob/firebase_options.dart';

import 'bin/model/color_schema_app.dart';
import 'bin/model/project_info_model.dart';

final getIt = GetIt.instance;

void main() async {
  getIt.registerSingleton<ProjectInfo>(ProjectInfo(nome: 'Seleção SICOOB'));
  getIt.registerSingleton<CorPadraoTema>(CorPadraoTema());
  getIt.registerSingleton<SlaParams>(SlaParams());

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: getIt<ProjectInfo>().nome,
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      theme: FlexThemeData.light(
        //scheme: FlexScheme.green,
        colors: FlexSchemeColor(
          primary: getIt<CorPadraoTema>().primaria,
          secondary: getIt<CorPadraoTema>().secundaria,
          tertiary: getIt<CorPadraoTema>().terciaria,
          error: Colors.red,
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        //blendLevel: 9,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: false,
        swapLegacyOnMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        //scheme: FlexScheme.green,
        colors: FlexSchemeColor(
          primary: getIt<CorPadraoTema>().primaria,
          secondary: getIt<CorPadraoTema>().secundaria,
          tertiary: getIt<CorPadraoTema>().terciaria,
          error: Colors.red,
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        // blendLevel: 15,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: false,
        swapLegacyOnMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      home: const HomePage(),
    );
  }
}
