import 'package:flutter/material.dart';

// ===== Import das páginas =====
// (Usei alias em Treinos para evitar conflito caso exista outro arquivo com o mesmo nome)
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_view.dart';
import 'pages/treinos_view.dart' as treinos;
import 'pages/consultoria_view.dart';
import 'pages/perfil_view.dart';
import 'theme/app_theme.dart'; 

void main() {
  // Garante que bindings do Flutter estão prontos (útil se futuramente inicializar plugins)
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

/// App raiz com tema (Material 3), rotas e shell principal.
class App extends StatelessWidget {
  const App({super.key});

  // Cor semente (laranja do projeto) — gera a paleta automática do Material 3
  static const Color seed = Color(0xFFFF6A00);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consultoria',
      debugShowCheckedModeBanner: false,

      // Tema claro/escuro usando a mesma seed.
      // Se quiser honrar a preferência do sistema troque para ThemeMode.system.
            themeMode: ThemeMode.dark,      // ou ThemeMode.system
            theme: AppTheme.light(),        // 👈 tema claro da sua marca
            darkTheme: AppTheme.dark(),     // 👈 tema escuro da sua marca

      // ===== Rotas nomeadas =====
      // Navegação típica:
      //  - Após login: Navigator.pushReplacementNamed(context, '/home');
      //  - Ir para cadastro: Navigator.pushNamed(context, '/register');
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const Shell(),
      },
    );
  }
}

/// Shell principal com BottomNavigationBar.
/// Cada página gerencia seu próprio Scaffold/AppBar/FAB,
/// evitando "Scaffold dentro de Scaffold".
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  // Páginas exibidas pelas abas. Mantemos `const` em cada item (quando possível)
  // e tipamos a lista para evitar o erro de "const list com não-const".
  final List<Widget> pages = <Widget>[
    const HomeView(),
    const treinos.TreinosView(),
    const ConsultoriaView(),
    const PerfilView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Troca suave entre as páginas
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        // ValueKey força rebuild correto ao trocar o índice
        child: KeyedSubtree(key: ValueKey(index), child: pages[index]),
      ),

      // Barra de navegação inferior (Material 3)
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Treinos',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent_outlined),
            selectedIcon: Icon(Icons.support_agent),
            label: 'Consultoria',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
