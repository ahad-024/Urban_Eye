import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_colors.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: LucideIcons.home,
                  label: 'Home',
                  selected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),

              Expanded(
                child: _NavItem(
                  icon: LucideIcons.fileText,
                  label: 'Reports',
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),

              Expanded(
                child: _CaptureButton(
                  onTap: () => onTap(2),
                ),
              ),

              Expanded(
                child: _NavItem(
                  icon: LucideIcons.bell,
                  label: 'Alerts',
                  selected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ),

              Expanded(
                child: _NavItem(
                  icon: LucideIcons.user,
                  label: 'Profile',
                  selected: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? AppColors.purple
                  : AppColors.secondaryText,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppColors.purple
                    : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CaptureButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.camera,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}