import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isHandlingCode = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Item'),
        actions: [
          TextButton(
            onPressed: _showManualEntryDialog,
            child: const Text('Manual', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF17212F),
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Scan an item label or manufacturer barcode.',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _handleCapture,
              errorBuilder: (context, error) {
                return _ScannerError(message: error.errorCode.message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: _showManualEntryDialog,
              icon: const Icon(Icons.keyboard),
              label: const Text('Enter Code Manually'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_isHandlingCode) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue?.trim();
      if (code != null && code.isNotEmpty) {
        _handleCode(code);
        return;
      }
    }
  }

  Future<void> _handleCode(String code) async {
    if (_isHandlingCode) {
      return;
    }

    setState(() {
      _isHandlingCode = true;
    });
    await _controller.stop();

    if (!mounted) {
      return;
    }

    final store = AppStoreScope.of(context);
    final item = _findItem(store, code);

    if (item != null) {
      if (!mounted) {
        return;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => ItemDetailScreen(item: item),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    await _showItemNotFoundDialog(code);
  }

  Future<void> _showManualEntryDialog() async {
    if (_isHandlingCode) {
      return;
    }

    final code = await showDialog<String>(
      context: context,
      builder: (context) => const _ManualEntryDialog(),
    );

    if (code == null || code.trim().isEmpty) {
      return;
    }

    await _handleCode(code.trim());
  }

  Future<void> _showItemNotFoundDialog(String code) async {
    final action = await showDialog<_NotFoundAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ItemNotFoundDialog(code: code),
    );

    if (!mounted) {
      return;
    }

    switch (action) {
      case _NotFoundAction.addNew:
        final itemAdded = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (context) => AddItemScreen(initialBarcode: code),
          ),
        );

        if (!mounted) {
          return;
        }

        if (itemAdded == true) {
          final item = _findItem(AppStoreScope.of(context), code);
          if (item != null) {
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => ItemDetailScreen(item: item),
              ),
            );
            return;
          }
        }
        await _resumeScanning();
      case _NotFoundAction.scanAgain:
        await _resumeScanning();
      case _NotFoundAction.cancel || null:
        if (mounted) {
          Navigator.of(context).pop();
        }
    }
  }

  Future<void> _resumeScanning() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isHandlingCode = false;
    });
    await _controller.start();
  }

  Item? _findItem(AppStore store, String scannedCode) {
    final normalizedCode = _normalize(scannedCode);

    for (final item in store.items) {
      final values = [item.barcode, item.sku, item.id].whereType<String>();

      for (final value in values) {
        if (_normalize(value) == normalizedCode) {
          return item;
        }
      }
    }

    return null;
  }

  String _normalize(String value) => value.trim().toLowerCase();
}

class _ManualEntryDialog extends StatefulWidget {
  const _ManualEntryDialog();

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Code'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Barcode or QR value',
          border: OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Search')),
      ],
    );
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }
}

class _ItemNotFoundDialog extends StatelessWidget {
  const _ItemNotFoundDialog({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Item not found'),
      content: Text('No item matched "$code".'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_NotFoundAction.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_NotFoundAction.scanAgain),
          child: const Text('Scan Again'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_NotFoundAction.addNew),
          child: const Text('Add New Item'),
        ),
      ],
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Camera access is needed to scan item barcodes and QR labels.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _NotFoundAction { addNew, scanAgain, cancel }
