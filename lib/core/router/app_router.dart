import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/medicine/presentation/screens/add_medicine_screen.dart';
import '../../features/medicine/presentation/screens/add_new_screen.dart';
import '../../features/medicine/presentation/screens/medicine_detail_screen.dart';
import '../../features/medicine/presentation/screens/review_save_screen.dart';
import '../../features/today/presentation/screens/today_home_screen.dart';
import '../widgets/main_shell_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String today = '/';
  static const String history = '/history';
  static const String addNew = '/add';
  static const String addMedicineForm = '/add/form';
  static const String addMedicineReview = '/add/review';
  static const String medicineDetails = '/medicine/:id';

  static String medicineDetailsPath(String id) => '/medicine/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.today,
    debugLogDiagnostics: false,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                name: 'today',
                builder: (context, state) => const TodayHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                name: 'history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.addNew,
        name: 'addNew',
        builder: (context, state) => const AddNewScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMedicineForm,
        name: 'addMedicineForm',
        builder: (context, state) => const AddMedicineScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMedicineReview,
        name: 'addMedicineReview',
        builder: (context, state) => const ReviewSaveScreen(),
      ),
      GoRoute(
        path: AppRoutes.medicineDetails,
        name: 'medicineDetails',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MedicineDetailScreen(medicineId: id);
        },
      ),
    ],
  );
});
