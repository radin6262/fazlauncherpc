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
    with WidgetsBindingObserver {
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

  final GameService _gameService = GameService();

  int _selectedIndex = 0;
  String? _bgImage;

  final Map<String, bool> _installedMap = {};

  bool _isDownloading = false;
  String? _downloadingGameId;
  double _downloadProgress = 0.0;

  bool _musicEnabled = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadConfig();
    _loadMusicSetting();
    _checkAllInstallations();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

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

    // When coming back from SettingsScreen or restoring the
    // launcher window, re-read the saved music setting.
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

      // Synchronize actual playback with the saved setting.
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
    for (var game in games) {
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
  // Play / Download
  // ============================================================

  Future<void> _handlePlay(Game game) async {
    final isInstalled =
        _installedMap[game.id] ?? false;

    if (isInstalled) {
      try {
        await _gameService.launchGame(game);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Text('Error launching game: $e'),
            ),
          );
        }
      }
    } else {
      setState(() {
        _isDownloading = true;
        _downloadingGameId = game.id;
        _downloadProgress = 0.0;
      });

      try {
        await _gameService.downloadAndInstall(
          game,
              (progress) {
            if (mounted) {
              setState(() {
                _downloadProgress =
                    progress;
              });
            }
          },
        );

        if (mounted) {
          setState(() {
            _installedMap[game.id] =
            true;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Text('Download failed: $e'),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _downloadingGameId = null;
          });
        }
      }
    }
  }

  // ============================================================
  // Remove
  // ============================================================

  Future<void> _handleRemove(Game game) async {
    try {
      await _gameService.clearGame(game);

      if (!mounted) return;

      setState(() {
        _installedMap[game.id] =
        false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ============================================================
          // BACKGROUND
          // ============================================================

          Positioned.fill(
            child: AnimatedSwitcher(
              duration:
              const Duration(milliseconds: 500),
              child: Container(
                key: ValueKey(_bgImage),
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
                          .withOpacity(0.5),
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
                            icon: const Icon(
                              Icons.collections,
                              color:
                              Colors.white70,
                              size: 28,
                            ),
                            onPressed: () =>
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const GalleryScreen(),
                                  ),
                                ),
                          ),

                          const SizedBox(
                            width: 15,
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color:
                              Colors.white70,
                              size: 28,
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const SettingsScreen(),
                                ),
                              );

                              // Settings may have changed:
                              // background and music.
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
                            (context, index) {
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
        ],
      ),
    );
  }
}