import 'package:flutter/material.dart';
import '../services/config_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

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
    "Set 3: FNAF SL": {
      "Ballora Animated": "assets/bg/ballora.gif",
      "Circus Baby Animated": "assets/bg/circusbaby.gif",
      "Funtime Foxy Animated": "assets/bg/funtimefoxy.gif",
      "Funtime Freddy Animated": "assets/bg/funtimefreddy.gif",
      "Circus Baby": "assets/bg/circusbaby.png",
    },
    "Set 3: FNAF 6": {
      "Rockstars": "assets/bg/fnaf6.png",
    },
    "Set 4: Default": {
      "Static Noise": "assets/bg/background.gif"
    }
  };

  String? _selectedSetName;
  String? _currentBg;

  @override
  void initState() {
    super.initState();
    _loadCurrentBg();
    _selectedSetName = backgroundSets.keys.first;
  }

  Future<void> _loadCurrentBg() async {
    final bg = await ConfigService.getBackgroundImage();
    setState(() {
      _currentBg = bg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Set Selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: backgroundSets.keys.map((setName) {
                final isSelected = _selectedSetName == setName;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: ChoiceChip(
                    label: Text(setName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSetName = setName;
                        });
                      }
                    },
                    selectedColor: Colors.redAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.grey[900],
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
              ),
              itemCount: backgroundSets[_selectedSetName]!.length,
              itemBuilder: (context, index) {
                final entry = backgroundSets[_selectedSetName]!.entries.elementAt(index);
                final name = entry.key;
                final path = entry.value;
                final isCurrent = _currentBg == path;

                return GestureDetector(
                  onTap: () async {
                    await ConfigService.setBackgroundImage(path);
                    setState(() {
                      _currentBg = path;
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Theme "$name" applied!'),
                          backgroundColor: Colors.redAccent,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: TextStyle(
                          color: isCurrent ? Colors.redAccent : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isCurrent ? Colors.redAccent : Colors.white10,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[900],
                                    child: const Icon(Icons.broken_image, color: Colors.white24),
                                  ),
                                ),
                                if (isCurrent)
                                  Container(
                                    color: Colors.redAccent.withOpacity(0.1),
                                    child: const Center(
                                      child: Icon(Icons.check_circle, color: Colors.redAccent, size: 40),
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
