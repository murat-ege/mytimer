import 'package:flutter/material.dart';
import 'package:mytimer/l10n/generated/app_localizations.dart';

class AddTimerTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddTimerTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox.expand(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00E676).withValues(alpha: 0.35),
              style: BorderStyle.solid,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00E676).withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF00E676),
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.addTimer ?? 'Zamanlayıcı Ekle',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
