import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF141F1B), // Dark card color
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => onTap(0),
                icon: Icon(
                  Icons.grid_view_rounded,
                  color: selectedIndex == 0
                      ? const Color(0xFF00E676)
                      : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () => onTap(1),
                icon: Icon(
                  Icons.menu_book_rounded,
                  color: selectedIndex == 1
                      ? const Color(0xFF00E676)
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 50), // Gap for FAB
              IconButton(
                onPressed: () => onTap(3),
                icon: Icon(
                  Icons
                      .bar_chart, // Changed from headphones to bar_chart for Stats w
                  color: selectedIndex == 3
                      ? const Color(0xFF00E676)
                      : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () => onTap(4),
                icon: Icon(
                  Icons.person,
                  color: selectedIndex == 4
                      ? const Color(0xFF00E676)
                      : Colors.grey,
                ),
              ),
            ],
          ),
          Positioned(
            top: -25,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: selectedIndex == 2
                      ? const Color(0xFF00E676)
                      : const Color(0xFF141F1B),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedIndex == 2
                        ? Colors.transparent
                        : const Color(0xFF00E676),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E676).withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: selectedIndex == 2 ? Colors.black : Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
