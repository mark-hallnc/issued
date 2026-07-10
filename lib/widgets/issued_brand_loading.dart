import 'package:flutter/material.dart';

const issuedNameLogoAsset = 'assets/images/Issued_name_icon.png';

class IssuedBrandLoading extends StatelessWidget {
  const IssuedBrandLoading({super.key, this.message = 'Loading...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IssuedBrandLogo(width: 220),
            const SizedBox(height: 28),
            SizedBox(
              width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(minHeight: 4),
              ),
            ),
            if (message.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class IssuedBrandLogo extends StatelessWidget {
  const IssuedBrandLogo({super.key, this.width = 240});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      issuedNameLogoAsset,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          'Issued',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: const Color(0xFF1E3A5F),
            fontWeight: FontWeight.w800,
          ),
        );
      },
    );
  }
}
