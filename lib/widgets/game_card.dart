import 'package:flutter/material.dart';
import '../models/game.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final VoidCallback onRemove;
  final bool isInstalled;
  final bool isDownloading;
  final double downloadProgress;

  const GameCard({
    super.key,
    required this.game,
    required this.isSelected,
    required this.onTap,
    required this.onPlay,
    required this.onRemove,
    required this.isInstalled,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    const double baseWidth = 240;
    const double baseHeight = 320;
    
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isSelected ? baseWidth * 1.2 : baseWidth,
          height: isSelected ? baseHeight * 1.2 : baseHeight,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 4,
                    )
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // Background Image
                Image.asset(
                  game.image,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.gamepad, color: Colors.white54, size: 50),
                  ),
                ),

                // Dark Overlay for non-selected
                if (!isSelected)
                  Container(
                    color: Colors.black.withOpacity(0.6),
                  ),

                // Selection Glow/Overlay
                if (isSelected)
                  Container(
                    color: Colors.white.withOpacity(0.1),
                  ),

                // Buttons (Only for selected card)
                if (isSelected) ...[
                  // Play / Download Button (Top Left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: isDownloading ? null : onPlay,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB71C1C).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isDownloading
                              ? Icons.sync
                              : (isInstalled ? Icons.play_arrow : Icons.download),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Remove Button (Top Right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[900]!.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],

                // Download Progress Overlay
                if (isDownloading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            value: downloadProgress,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${(downloadProgress * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
