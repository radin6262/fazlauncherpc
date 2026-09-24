import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/config_service.dart';
import '../services/music_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// ============================================================
// Launcher Music
// ============================================================



class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, Map<String, String>> backgroundSets = {
    "Set 1: FNAF 1": {
      "Animated": "assets/bg/fnaf1.gif",
      "Freddy(1)": "assets/bg/1.png",
      "Freddy Endo": "assets/bg/endo.png"
    },
    "Set 2: FNAF 2": {
      "Animated": "assets/bg/fnaf2.gif",
      "All Toys": "assets/bg/fnaf2toys.png",
      "All Toys With Wither Bonnie": "assets/bg/wb.png",
      "All Toys With Wither Chica": "assets/bg/wc.png"
    },
    "Set 3: FNAF 3": {
      "Animated": "assets/bg/fnaf3.gif",
      "SpringTrap": "assets/bg/sp1.png"
    },
    "Set 4: FNAF 4": {
      "Fazbear Entertainment": "assets/bg/FazBearEnterTainment.png",
      "Fazbear Shed": "assets/bg/fazbearshed.png",
      "FNAF 4 Background": "assets/bg/fnaf4bg2.png",
      "Nightmare Bonnie": "assets/bg/nightmarebonnie4.png",
      "Nightmare Chica": "assets/bg/nightmarechica4.png",
      "Nightmare Foxy": "assets/bg/nightmarefoxy4.png",
      "Nightmare Freddy": "assets/bg/nightmarefreddy4.png"
    },
    "Set 5: FNAF SL": {
      "Ballora Animated": "assets/bg/ballora.gif",
      "Circus Baby Animated": "assets/bg/circusbaby.gif",
      "Funtime Foxy Animated": "assets/bg/funtimefoxy.gif",
      "Funtime Freddy Animated": "assets/bg/funtimefreddy.gif",
      "Circus Baby": "assets/bg/circusbaby.png",
    },
    "Set 6: FNAF 6": {
      "Rockstars": "assets/bg/fnaf6.png",
    },
    "Set 7: Default": {
      "Static Noise": "assets/bg/background.gif"
    }
  };

  String? _selectedSetName;
  String? _currentBg;

  bool _musicEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _selectedSetName = backgroundSets.keys.first;

    _loadSettings();
  }

  // ============================================================
  // Load settings
  // ============================================================

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final bg =
      await ConfigService.getBackgroundImage();

      // EXACT SAME setting used by the launcher.
      final musicEnabled =
          prefs.getBool(
            'launcher_music_enabled',
          ) ??
              true;

      if (!mounted) return;

      setState(() {
        _currentBg = bg;
        _musicEnabled = musicEnabled;
        _loading = false;
      });

      // Start music according to saved setting.
      if (musicEnabled) {
        await MusicService.play();
      } else {
        await MusicService.stop();
      }
    } catch (e) {
      debugPrint(
        "Failed to load settings: $e",
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // Music toggle
  // ============================================================

  Future<void> _toggleMusic(bool value) async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      // Save the exact same setting key.
      await prefs.setBool(
        'launcher_music_enabled',
        value,
      );

      if (!mounted) return;

      setState(() {
        _musicEnabled = value;
      });

      if (value) {
        await MusicService.play();
      } else {
        await MusicService.stop();
      }
    } catch (e) {
      debugPrint(
        "Music toggle failed: $e",
      );
    }
  }

  // ============================================================
  // Background
  // ============================================================

  Future<void> _setBackground(
      String path,
      String name,
      ) async {
    try {
      await ConfigService.setBackgroundImage(path);

      if (!mounted) return;

      setState(() {
        _currentBg = path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Theme "$name" applied!',
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to apply theme: $e',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Do not stop the music here.
    //
    // The music belongs to the launcher and should continue
    // playing when the user leaves the settings screen.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSet =
        _selectedSetName ??
            backgroundSets.keys.first;

    final currentSet =
    backgroundSets[selectedSet]!;

    return Scaffold(
      backgroundColor: Colors.black,

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.redAccent,
        elevation: 0,

        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _musicEnabled
                      ? Icons.music_note
                      : Icons.music_off,
                  color: _musicEnabled
                      ? Colors.redAccent
                      : Colors.white38,
                  size: 21,
                ),

                const SizedBox(width: 6),

                const Text(
                  "MUSIC",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(width: 4),

                Switch(
                  value: _musicEnabled,
                  activeColor:
                  Colors.redAccent,
                  activeTrackColor:
                  Colors.redAccent.withValues(
                    alpha: 0.35,
                  ),
                  inactiveThumbColor:
                  Colors.grey,
                  inactiveTrackColor:
                  Colors.grey[900],
                  onChanged: _loading
                      ? null
                      : _toggleMusic,
                ),
              ],
            ),
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.redAccent,
        ),
      )
          : Column(
        children: [
          // ====================================================
          // SET SELECTOR
          // ====================================================
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection:
              Axis.horizontal,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              children:
              backgroundSets.keys.map(
                    (setName) {
                  final isSelected =
                      _selectedSetName ==
                          setName;

                  return Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 8.0,
                      vertical: 10,
                    ),
                    child: ChoiceChip(
                      label:
                      Text(setName),
                      selected:
                      isSelected,
                      onSelected:
                          (selected) {
                        if (selected) {
                          setState(() {
                            _selectedSetName =
                                setName;
                          });
                        }
                      },
                      selectedColor:
                      Colors.redAccent,
                      labelStyle:
                      TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white70,
                        fontWeight:
                        FontWeight.bold,
                      ),
                      backgroundColor:
                      Colors.grey[900],
                    ),
                  );
                },
              ).toList(),
            ),
          ),

          const Divider(
            color: Colors.white10,
            height: 1,
          ),

          // ====================================================
          // MUSIC STATUS
          // ====================================================
          Padding(
            padding:
            const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              4,
            ),
            child: Row(
              children: [
                Icon(
                  _musicEnabled
                      ? Icons.music_note
                      : Icons.music_off,
                  color: _musicEnabled
                      ? Colors.redAccent
                      : Colors.white38,
                  size: 19,
                ),

                const SizedBox(
                  width: 8,
                ),

                Text(
                  _musicEnabled
                      ? "Music enabled"
                      : "Music disabled",
                  style: TextStyle(
                    color: _musicEnabled
                        ? Colors.white70
                        : Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // BACKGROUND GRID
          // ====================================================
          Expanded(
            child: GridView.builder(
              padding:
              const EdgeInsets.all(20),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
              ),
              itemCount:
              currentSet.length,
              itemBuilder:
                  (context, index) {
                final entry = currentSet
                    .entries
                    .elementAt(index);

                final name = entry.key;
                final path = entry.value;

                final isCurrent =
                    _currentBg == path;

                return GestureDetector(
                  onTap: () =>
                      _setBackground(
                        path,
                        name,
                      ),
                  child: Column(
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: TextStyle(
                          color: isCurrent
                              ? Colors
                              .redAccent
                              : Colors
                              .white70,
                          fontSize: 12,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Expanded(
                        child:
                        AnimatedContainer(
                          duration:
                          const Duration(
                            milliseconds:
                            200,
                          ),
                          decoration:
                          BoxDecoration(
                            border:
                            Border.all(
                              color: isCurrent
                                  ? Colors
                                  .redAccent
                                  : Colors
                                  .white10,
                              width: isCurrent
                                  ? 2
                                  : 1,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              12,
                            ),
                          ),
                          child:
                          ClipRRect(
                            borderRadius:
                            BorderRadius
                                .circular(
                              10,
                            ),
                            child: Stack(
                              fit: StackFit
                                  .expand,
                              children: [
                                Image.asset(
                                  path,
                                  fit: BoxFit
                                      .cover,
                                  errorBuilder:
                                      (
                                      context,
                                      error,
                                      stackTrace,
                                      ) =>
                                      Container(
                                        color: Colors
                                            .grey[900],
                                        child:
                                        const Icon(
                                          Icons
                                              .broken_image,
                                          color: Colors
                                              .white24,
                                        ),
                                      ),
                                ),

                                if (isCurrent)
                                  Container(
                                    color: Colors
                                        .redAccent
                                        .withValues(
                                      alpha:
                                      0.1,
                                    ),
                                    child:
                                    const Center(
                                      child:
                                      Icon(
                                        Icons
                                            .check_circle,
                                        color: Colors
                                            .redAccent,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}