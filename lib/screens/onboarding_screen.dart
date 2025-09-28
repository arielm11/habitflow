import 'package:flutter/material.dart';
import 'package:habitflow/screens/home_page.dart';
import 'package:habitflow/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controlador de StateView
  final PageController _controller = PageController();
  // Contator das paginas
  int _currentPage = 0;

  // Função para salvar que o onBoarding foi concluído
  Future<void> _completeOnBoarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnBoarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [
              // Páginas de onBoarding
              OnboardingPage(
                  icon: Icons.track_changes,
                  title: 'Bem-vindo ao HabitFlow!',
                  description:
                      'Crie, gerencie e acompanhe seus hábitos diários de forma simples e eficaz.'),
              OnboardingPage(
                icon: Icons.edit_note,
                title: "Personalize Seus Hábitos",
                description:
                    "Defina metas flexíveis: feito/não feito, metas numéricas ou por duração de tempo.",
              ),
              OnboardingPage(
                icon: Icons.show_chart,
                title: "Acompanhe o seu Progresso",
                description:
                    "Receba relatórios semanais e notificações para se manter sempre motivado e no caminho certo.",
              )
            ],
          ),
          // indicador de página e botão
          Container(
            alignment: const Alignment(0, 0.80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botão para Voltar
                Visibility(
                  visible: _currentPage > 0,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: TextButton(
                    onPressed: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      "Voltar",
                      style: TextStyle(
                        color: AppColors.graphite,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // indicador de páginas (bolinhas)
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const WormEffect(
                      spacing: 16,
                      dotColor: AppColors.seaGreen,
                      activeDotColor: AppColors.teal),
                ),
                // botão de avançar
                _currentPage == 2
                    ? ElevatedButton(
                        onPressed: _completeOnBoarding,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.softGold,
                            foregroundColor: AppColors.graphite),
                        child: const Text("Começar"),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Próximo"),
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: AppColors.teal),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.graphite,
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 24,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.graphite,
              fontSize: 18,
            ),
          )
        ],
      ),
    );
  }
}
