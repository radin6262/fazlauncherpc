import 'package:flutter/material.dart';

import '../models/game.dart';
import '../services/game_service.dart';
import '../services/config_service.dart';
import '../services/music_service.dart';
import '../widgets/game_card.dart';
import 'settings_screen.dart';
import 'gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // ============================================================
  // Games
  // ============================================================

  final List<Game> games = [
    Game(
      id: "fnaf1",
      name: "Five Nights at Freddy's",
      windowsUrl:
      "https://github.com/radin6262/FazLauncherSite/raw/refs/heads/main/FiveNightsatFreddys.zip?download=true",
      image: "assets/images/fnaf1.png",
    ),
    Game(
      id: "fnaf2",
      name: "Five Nights at Freddy's 2",
      windowsUrl:
      "https://github.com/radin6262/FazLauncherSite/raw/refs/heads/main/FiveNightsatFreddys2.zip?download=true",
      image: "assets/images/fnaf2.png",
    ),
    Game(
      id: "fnaf3",
      name: "Five Nights at Freddy's 3",
      windowsUrl:
      "https://github.com/radin6262/FazLauncherSite/raw/refs/heads/main/FiveNightsatFreddys3.zip?download=true",
      image: "assets/images/fnaf3.png",
    ),
    Game(
      id: "fnaf4",
      name: "Five Nights at Freddy's 4",
      windowsUrl:
      "https://github.com/radin6262/FazLauncherSite/raw/refs/heads/main/FiveNightsatFreddys4.zip?download=true",
      image: "assets/images/fnaf4.png",
    ),
    Game(
      id: "fnaf5",
      name: "Five Nights at Freddy's: Sister Location",
      windowsUrl:
      "https://github.com/radin6262/FazLauncherSite/raw/refs/heads/main/SisterLocation.zip?download=true",
      image: "assets/images/slcard.png",
    ),
    Game(
      id: "fnaf6",
      name: "Five Nights at Freddy's 6",
      windowsUrl:
      "https://github.com/radin6262/FazLauncherSite/raw/refs/heads/main/pizzeria-simulator.zip?download=true",
      image: "assets/images/fnaf6card.png",
    ),
    Game(
      id: "fnafworld",
      name: "Five Nights at Freddy's World",
      windowsUrl:
      "https://github.com/radin6262/FazLauncherSite/raw/refs/heads/main/fnaf-world.zip?download=true",
      image: "assets/images/world.png",
    ),
  ];

  // ============================================================
  // Dedicated launch splash images
  //
  // These are completely separate from Game.image.
  //
  // Game.image:
  //     normal game card
  //
  // This map:
  //     4-second full-screen launch splash
  // ============================================================

  final Map<String, String> _launchSplashImages = {
    "fnaf1": "assets/splash/fnaf1.png",
    "fnaf2": "assets/splash/fnaf2.png",
    "fnaf3": "assets/splash/fnaf3.png",
    "fnaf4": "assets/splash/fnaf4.png",
    "fnaf5": "assets/splash/fnaf5.png",
    "fnaf6": "assets/splash/fnaf6.png",
    "fnafworld": "assets/splash/fnafworld.png",
  };

  // ============================================================
  // Services
  // ============================================================

  final GameService _gameService = GameService();

  // ============================================================
  // State
  // ============================================================

  int _selectedIndex = 0;

  String? _bgImage;

  final Map<String, bool> _installedMap = {};

  bool _isDownloading = false;
  String? _downloadingGameId;
  double _downloadProgress = 0.0;

  bool _musicEnabled = true;

  // ============================================================
  // Game launch splash
  // ============================================================

  late final AnimationController _launchSplashController;

  static const Duration _launchSplashDuration =
  Duration(seconds: 4);

  bool _showLaunchSplash = false;

  Game? _launchSplashGame;

  // ============================================================
  // Init
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _launchSplashController = AnimationController(
      vsync: this,
      duration: _launchSplashDuration,
    );

    _loadConfig();
    _loadMusicSetting();
    _checkAllInstallations();
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _launchSplashController.dispose();

    super.dispose();
  }

  // ============================================================
  // App lifecycle
  // ============================================================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _loadMusicSetting();
    }
  }

  // ============================================================
  // Configuration
  // ============================================================

  Future<void> _loadConfig() async {
    final bg =
    await ConfigService.getBackgroundImage();

    if (!mounted) return;

    setState(() {
      _bgImage =
          bg ?? 'assets/bg/background.gif';
    });
  }

  // ============================================================
  // Music
  // ============================================================

  Future<void> _loadMusicSetting() async {
    try {
      final enabled =
      await MusicService.getEnabled();

      if (!mounted) return;

      setState(() {
        _musicEnabled = enabled;
      });

      if (enabled) {
        await MusicService.play();
      } else {
        await MusicService.stop();
      }
    } catch (e) {
      debugPrint(
        'Failed to load music setting: $e',
      );
    }
  }

  // ============================================================
  // Installation checking
  // ============================================================

  Future<void> _checkAllInstallations() async {
    for (final game in games) {
      final installed =
      await _gameService.isGameInstalled(game);

      if (!mounted) return;

      setState(() {
        _installedMap[game.id] =
            installed;
      });
    }
  }

  // ============================================================
  // Launch splash
  //
  // ONLY the following is displayed:
  //
  //   - Full-screen game-specific splash image
  //   - Circular progress ring in bottom-left
  //
  // No text.
  // No countdown.
  // No linear progress bar.
  // No controls.
  // ============================================================

  Future<void> _showGameLaunchSplash(
      Game game,
      Future<void> Function() launchAction,
      ) async {
    if (!mounted) return;

    if (_showLaunchSplash) {
      return;
    }

    final splashImage =
    _launchSplashImages[game.id];

    if (splashImage == null ||
        splashImage.isEmpty) {
      debugPrint(
        'LAUNCHER SPLASH: no splash image configured '
            'for ${game.id}',
      );

      await launchAction();
      return;
    }

    debugPrint(
      'LAUNCHER SPLASH: ${game.id} -> $splashImage',
    );

    setState(() {
      _showLaunchSplash = true;
      _launchSplashGame = game;
    });

    try {
      await _launchSplashController.forward(
        from: 0.0,
      );
    } on TickerCanceled {
      return;
    }

    if (!mounted) return;

    setState(() {
      _showLaunchSplash = false;
      _launchSplashGame = null;
    });

    // Launch only after the full 4-second splash.
    await launchAction();
  }

  // ============================================================
  // Launch game
  // ============================================================

  Future<void> _launchInstalledGame(
      Game game,
      ) async {
    if (!mounted) return;

    try {
      await _gameService.launchGame(game);

      debugPrint(
        'LAUNCHER: launched ${game.name}',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text('Error launching game: $e'),
        ),
      );
    }
  }

  // ============================================================
  // Play / Download
  // ============================================================

  Future<void> _handlePlay(
      Game game,
      ) async {
    if (_isDownloading) return;

    if (_showLaunchSplash) return;

    final isInstalled =
        _installedMap[game.id] ?? false;

    // ==========================================================
    // Already installed
    // ==========================================================

    if (isInstalled) {
      await _showGameLaunchSplash(
        game,
            () => _launchInstalledGame(game),
      );

      return;
    }

    // ==========================================================
    // Download and install
    // ==========================================================

    if (!mounted) return;

    setState(() {
      _isDownloading = true;
      _downloadingGameId = game.id;
      _downloadProgress = 0.0;
    });

    try {
      await _gameService.downloadAndInstall(
        game,
            (progress) {
          if (!mounted) return;

          setState(() {
            _downloadProgress =
                progress.clamp(0.0, 1.0);
          });
        },
      );

      if (!mounted) return;

      setState(() {
        _installedMap[game.id] = true;
      });

      /*
       * Download + installation is now complete.
       *
       * Hide the download state first, then show the
       * dedicated 4-second launch splash.
       */
      setState(() {
        _isDownloading = false;
        _downloadingGameId = null;
        _downloadProgress = 0.0;
      });

      await _showGameLaunchSplash(
        game,
            () => _launchInstalledGame(game),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text('Download failed: $e'),
        ),
      );

      setState(() {
        _isDownloading = false;
        _downloadingGameId = null;
        _downloadProgress = 0.0;
      });
    }
  }

  // ============================================================
  // Remove
  // ============================================================

  Future<void> _handleRemove(
      Game game,
      ) async {
    if (_isDownloading) return;

    if (_showLaunchSplash) return;

    try {
      await _gameService.clearGame(game);

      if (!mounted) return;

      setState(() {
        _installedMap[game.id] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text('${game.name} files removed.'),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('Error removing game: $e'),
          ),
        );
      }
    }
  }

  // ============================================================
  // Full-screen launch splash
  // ============================================================

  Widget _buildLaunchSplash() {
    final game =
        _launchSplashGame;

    if (game == null) {
      return const SizedBox.shrink();
    }

    final splashImage =
    _launchSplashImages[game.id];

    if (splashImage == null ||
        splashImage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Material(
        color: Colors.black,
        child: AbsorbPointer(
          absorbing: true,
          child: AnimatedBuilder(
            animation:
            _launchSplashController,
            builder: (
                context,
                child,
                ) {
              final progress =
                  _launchSplashController
                      .value;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // ==================================================
                  // Dedicated splash image.
                  //
                  // NOT game.image.
                  // ==================================================

                  Image.asset(
                    splashImage,
                    fit: BoxFit.cover,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      debugPrint(
                        'LAUNCHER SPLASH IMAGE ERROR: '
                            '$splashImage',
                      );

                      return Container(
                        color: Colors.black,
                      );
                    },
                  ),

                  // ==================================================
                  // ONLY UI ELEMENT:
                  // circular progress ring
                  // bottom-left
                  // ==================================================

                  Positioned(
                    left: 24,
                    bottom: 24,
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child:
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        backgroundColor:
                        Colors.black
                            .withOpacity(
                          0.45,
                        ),
                        valueColor:
                        const AlwaysStoppedAnimation<
                            Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      body: Stack(
        children: [
          // ============================================================
          // BACKGROUND
          // ============================================================

          Positioned.fill(
            child: AnimatedSwitcher(
              duration:
              const Duration(
                milliseconds: 500,
              ),
              child: Container(
                key:
                ValueKey(_bgImage),
                decoration:
                BoxDecoration(
                  image:
                  DecorationImage(
                    image: AssetImage(
                      _bgImage ??
                          'assets/bg/background.gif',
                    ),
                    fit: BoxFit.cover,
                    colorFilter:
                    ColorFilter.mode(
                      Colors.black
                          .withOpacity(
                        0.5,
                      ),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ============================================================
          // CONTENT
          // ============================================================

          SafeArea(
            child: Column(
              children: [
                // ======================================================
                // HEADER
                // ======================================================

                Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/launcher-title.png',
                        height: 80,
                        fit: BoxFit.contain,
                      ),

                      Row(
                        children: [
                          IconButton(
                            icon:
                            const Icon(
                              Icons.collections,
                              color:
                              Colors.white70,
                              size: 28,
                            ),
                            onPressed:
                            _showLaunchSplash ||
                                _isDownloading
                                ? null
                                : () =>
                                Navigator
                                    .push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                    const GalleryScreen(),
                                  ),
                                ),
                          ),

                          const SizedBox(
                            width: 15,
                          ),

                          IconButton(
                            icon:
                            const Icon(
                              Icons.settings,
                              color:
                              Colors.white70,
                              size: 28,
                            ),
                            onPressed:
                            _showLaunchSplash ||
                                _isDownloading
                                ? null
                                : () async {
                              await Navigator
                                  .push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                  const SettingsScreen(),
                                ),
                              );

                              await _loadConfig();
                              await _loadMusicSetting();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ======================================================
                // CAROUSEL
                // ======================================================

                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 580,
                      child: ListView.builder(
                        scrollDirection:
                        Axis.horizontal,
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 100,
                        ),
                        itemCount:
                        games.length,
                        itemBuilder:
                            (
                            context,
                            index,
                            ) {
                          final game =
                          games[index];

                          return GameCard(
                            game: game,
                            isSelected:
                            _selectedIndex ==
                                index,
                            isInstalled:
                            _installedMap[
                            game.id] ??
                                false,
                            isDownloading:
                            _isDownloading &&
                                _downloadingGameId ==
                                    game.id,
                            downloadProgress:
                            _downloadProgress,
                            onTap: () {
                              if (_showLaunchSplash ||
                                  _isDownloading) {
                                return;
                              }

                              setState(() {
                                _selectedIndex =
                                    index;
                              });
                            },
                            onPlay: () =>
                                _handlePlay(
                                  game,
                                ),
                            onRemove: () =>
                                _handleRemove(
                                  game,
                                ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),

          // ============================================================
          // FULL-SCREEN GAME SPLASH
          //
          // LAST Stack child = above everything.
          //
          // Contains ONLY:
          //   - dedicated splash image
          //   - progress ring bottom-left
          // ============================================================

          if (_showLaunchSplash)
            _buildLaunchSplash(),
        ],
      ),
    );
  }
}