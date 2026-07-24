import 'package:go_router/go_router.dart';
import 'package:pinyinapp/core/di/dependencies.dart';
import 'package:pinyinapp/features/dictionary/presentation/pages/search_page.dart';
import 'package:pinyinapp/features/dictionary/presentation/pages/word_detail_page.dart';
import 'package:pinyinapp/features/favorites/presentation/pages/favorites_page.dart';
import 'package:pinyinapp/features/history/presentation/pages/history_page.dart';
import 'package:pinyinapp/features/settings/presentation/pages/settings_page.dart';
import 'package:pinyinapp/app/widgets/app_shell.dart';

abstract final class AppRouter {
  static GoRouter build(Dependencies dependencies) {
    return GoRouter(
      initialLocation: '/search',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  builder: (context, state) => const SearchPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/favorites',
                  builder: (context, state) => const FavoritesPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  builder: (context, state) => const HistoryPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => const SettingsPage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/word/:id',
          builder: (context, state) => WordDetailPage(
            wordId: state.pathParameters['id']!,
            heroNamespace: state.uri.queryParameters['from'] ?? 'search',
            dependencies: dependencies,
          ),
        ),
      ],
    );
  }
}
