import '../app_store.dart';
import '../labels/label_service.dart';
import '../models/models.dart';

enum ScanResultType {
  issuedItem,
  issuedLocation,
  issuedTarget,
  issuedCheckout,
  issuedReorder,
  plainCode,
  unknown,
}

class ScanParseResult {
  const ScanParseResult({
    required this.rawValue,
    required this.type,
    this.id,
    this.normalizedCode,
    this.error,
  });

  final String rawValue;
  final ScanResultType type;
  final String? id;
  final String? normalizedCode;
  final String? error;
}

enum ScanResolutionType {
  item,
  location,
  assignmentTarget,
  checkout,
  reorder,
  multipleItems,
  notFound,
  malformed,
}

class ResolvedScan {
  const ResolvedScan({
    required this.rawValue,
    required this.parseResult,
    required this.resolutionType,
    this.item,
    this.location,
    this.assignmentTarget,
    this.checkout,
    this.reorder,
    this.itemMatches = const [],
    this.message,
  });

  final String rawValue;
  final ScanParseResult parseResult;
  final ScanResolutionType resolutionType;
  final Item? item;
  final Location? location;
  final AssignmentTarget? assignmentTarget;
  final CheckoutRecord? checkout;
  final ReorderRequest? reorder;
  final List<Item> itemMatches;
  final String? message;
}

class ScanParser {
  const ScanParser();

  ScanParseResult parse(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return ScanParseResult(
        rawValue: rawValue,
        type: ScanResultType.unknown,
        error: 'Empty scan value.',
      );
    }

    final parts = trimmed.split(':').map((part) => part.trim()).toList();
    if (parts.first.toUpperCase() != 'ISSUED') {
      return ScanParseResult(
        rawValue: rawValue,
        type: ScanResultType.plainCode,
        normalizedCode: _normalizePlainCode(trimmed),
      );
    }

    if (parts.length != 3) {
      return ScanParseResult(
        rawValue: rawValue,
        type: ScanResultType.unknown,
        error: 'Malformed Issued payload.',
      );
    }

    final id = parts[2];
    if (id.isEmpty) {
      return ScanParseResult(
        rawValue: rawValue,
        type: ScanResultType.unknown,
        error: 'Issued payload is missing an id.',
      );
    }

    final type = switch (parts[1].toUpperCase()) {
      'ITEM' => ScanResultType.issuedItem,
      'LOCATION' => ScanResultType.issuedLocation,
      'TARGET' => ScanResultType.issuedTarget,
      'CHECKOUT' => ScanResultType.issuedCheckout,
      'REORDER' => ScanResultType.issuedReorder,
      _ => ScanResultType.unknown,
    };

    return ScanParseResult(
      rawValue: rawValue,
      type: type,
      id: type == ScanResultType.unknown ? null : id,
      normalizedCode: _normalizePlainCode(trimmed),
      error: type == ScanResultType.unknown ? 'Unknown Issued payload.' : null,
    );
  }

  String _normalizePlainCode(String value) {
    return value.trim().toLowerCase();
  }
}

class ScanResolver {
  const ScanResolver({this.parser = const ScanParser()});

  final ScanParser parser;

  ResolvedScan resolveScan(String rawValue, AppStore store) {
    final parseResult = parser.parse(rawValue);
    final id = parseResult.id;

    if (parseResult.type == ScanResultType.unknown) {
      return ResolvedScan(
        rawValue: rawValue,
        parseResult: parseResult,
        resolutionType: parseResult.error == null
            ? ScanResolutionType.notFound
            : ScanResolutionType.malformed,
        message: parseResult.error,
      );
    }

    switch (parseResult.type) {
      case ScanResultType.issuedItem:
        final item = id == null ? null : store.findItemById(id);
        return item == null
            ? _notFound(rawValue, parseResult)
            : ResolvedScan(
                rawValue: rawValue,
                parseResult: parseResult,
                resolutionType: ScanResolutionType.item,
                item: item,
              );
      case ScanResultType.issuedLocation:
        final location = id == null ? null : store.findLocationById(id);
        return location == null
            ? _notFound(rawValue, parseResult)
            : ResolvedScan(
                rawValue: rawValue,
                parseResult: parseResult,
                resolutionType: ScanResolutionType.location,
                location: location,
              );
      case ScanResultType.issuedTarget:
        final target = id == null ? null : store.findAssignmentTargetById(id);
        return target == null
            ? _notFound(rawValue, parseResult)
            : ResolvedScan(
                rawValue: rawValue,
                parseResult: parseResult,
                resolutionType: ScanResolutionType.assignmentTarget,
                assignmentTarget: target,
              );
      case ScanResultType.issuedCheckout:
        final checkout = id == null ? null : store.findCheckoutById(id);
        return checkout == null
            ? _notFound(rawValue, parseResult)
            : ResolvedScan(
                rawValue: rawValue,
                parseResult: parseResult,
                resolutionType: ScanResolutionType.checkout,
                checkout: checkout,
              );
      case ScanResultType.issuedReorder:
        final reorder = id == null ? null : store.findReorderById(id);
        return reorder == null
            ? _notFound(rawValue, parseResult)
            : ResolvedScan(
                rawValue: rawValue,
                parseResult: parseResult,
                resolutionType: ScanResolutionType.reorder,
                reorder: reorder,
              );
      case ScanResultType.plainCode:
        return _resolvePlainCode(rawValue, parseResult, store);
      case ScanResultType.unknown:
        return _notFound(rawValue, parseResult);
    }
  }

  ResolvedScan _resolvePlainCode(
    String rawValue,
    ScanParseResult parseResult,
    AppStore store,
  ) {
    final code = parseResult.normalizedCode ?? '';
    final legacyItem = _legacyItemMatch(code, store);
    if (legacyItem != null) {
      return ResolvedScan(
        rawValue: rawValue,
        parseResult: parseResult,
        resolutionType: ScanResolutionType.item,
        item: legacyItem,
      );
    }

    final matches = store.findItemsByBarcodeOrSku(code);
    final activeMatches = matches.where((item) => item.isActive).toList();
    if (activeMatches.length > 1) {
      return ResolvedScan(
        rawValue: rawValue,
        parseResult: parseResult,
        resolutionType: ScanResolutionType.multipleItems,
        itemMatches: activeMatches,
        message: 'Multiple active items match this code.',
      );
    }
    if (activeMatches.length == 1) {
      return ResolvedScan(
        rawValue: rawValue,
        parseResult: parseResult,
        resolutionType: ScanResolutionType.item,
        item: activeMatches.first,
      );
    }
    if (matches.length == 1) {
      return ResolvedScan(
        rawValue: rawValue,
        parseResult: parseResult,
        resolutionType: ScanResolutionType.item,
        item: matches.first,
        message: 'This item is archived.',
      );
    }
    return _notFound(rawValue, parseResult);
  }

  Item? _legacyItemMatch(String normalizedCode, AppStore store) {
    for (final item in store.items) {
      final values = [
        item.id,
        legacyItemQrValue(item),
        'issued:item:${item.id}',
      ];
      if (values.any((value) => value.trim().toLowerCase() == normalizedCode)) {
        return item;
      }
    }
    return null;
  }

  ResolvedScan _notFound(String rawValue, ScanParseResult parseResult) {
    return ResolvedScan(
      rawValue: rawValue,
      parseResult: parseResult,
      resolutionType: ScanResolutionType.notFound,
      message: 'No item, location, or target found for this code.',
    );
  }
}
