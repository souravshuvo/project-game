import 'package:flutter/material.dart';

import '../../tracing/data/progress_repository.dart';

class ParentCornerScreen extends StatefulWidget {
  const ParentCornerScreen({
    required this.progressRepository,
    required this.gameIds,
    super.key,
  });

  final ProgressRepository progressRepository;
  final List<String> gameIds;

  @override
  State<ParentCornerScreen> createState() => _ParentCornerScreenState();
}

class _ParentCornerScreenState extends State<ParentCornerScreen> {
  Future<void> _setSound(bool enabled) async {
    await widget.progressRepository.setSoundEnabled(enabled);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all progress?'),
        content: const Text(
          'This removes every local completion checkmark and restores sound. '
          'It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep progress'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }
    await widget.progressRepository.reset();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local progress was reset.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.gameIds
        .where(widget.progressRepository.isGameComplete)
        .length;
    final totalGames = widget.gameIds.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        title: const Text('Parent Corner'),
        backgroundColor: const Color(0xFFF8F5FF),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _ParentCard(
              icon: Icons.insights_rounded,
              color: const Color(0xFF7257E8),
              title: 'Local progress',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$completed of $totalGames game explored',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: totalGames == 0 ? 0 : completed / totalGames,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ParentCard(
              icon: Icons.tune_rounded,
              color: const Color(0xFFEF7B45),
              title: 'Settings',
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: widget.progressRepository.soundEnabled,
                onChanged: _setSound,
                secondary: const Icon(Icons.volume_up_rounded),
                title: const Text('Sound feedback'),
                subtitle: const Text('Uses local, offline-safe cues only.'),
              ),
            ),
            const SizedBox(height: 16),
            const _ParentCard(
              icon: Icons.privacy_tip_rounded,
              color: Color(0xFF2EAD7B),
              title: 'Privacy',
              child: Text(
                'KidsLand has no account, ads, Firebase, analytics SDK, '
                'location, camera, microphone, or child profile. Game '
                'progress stays in local Hive storage. Android cloud backup '
                'and device transfer are disabled for app data.',
              ),
            ),
            const SizedBox(height: 16),
            _ParentCard(
              icon: Icons.delete_outline_rounded,
              color: const Color(0xFFD55252),
              title: 'Local data',
              child: OutlinedButton.icon(
                onPressed: _resetProgress,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset all progress and settings'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB23B3B),
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentCard extends StatelessWidget {
  const _ParentCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final Color color;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(icon, color: color),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF392C68),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
