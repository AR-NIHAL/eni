import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/dose_tracking/data/datasources/dose_local_datasource.dart';
import 'features/dose_tracking/data/models/dose_log_model.dart';
import 'features/medicine/data/datasources/medicine_local_datasource.dart';
import 'features/medicine/data/models/course_duration_model.dart';
import 'features/medicine/data/models/medicine_model.dart';
import 'features/medicine/data/models/medicine_schedule_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService.instance.init();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive TypeAdapters
  Hive.registerAdapter(MedicineModelAdapter());
  Hive.registerAdapter(MedicineScheduleModelAdapter());
  Hive.registerAdapter(CourseDurationModelAdapter());
  Hive.registerAdapter(DoseLogModelAdapter());

  // Open Hive boxes
  await Hive.openBox<MedicineModel>(MedicineLocalDataSourceImpl.boxName);
  await Hive.openBox<DoseLogModel>(DoseLocalDataSourceImpl.boxName);

  runApp(
    const ProviderScope(
      child: MedicoApp(),
    ),
  );
}

class MedicoApp extends ConsumerWidget {
  const MedicoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Medico',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
