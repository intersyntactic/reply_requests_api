import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

/// Every URI a source's directives name, in every branch, as written.
///
/// Read from the parse tree, which knows comments, strings and metadata, so
/// none of them can hide a directive or cut one short. The tree keeps every
/// branch of a conditional import (the element model keeps only the one it
/// picked), and `import 'stub.dart' if (dart.library.io) 'dart:io';` names
/// both.
Iterable<StringLiteral> directiveUris(String source) sync* {
  final unit = parseString(content: source, throwIfDiagnostics: false).unit;
  // Over every directive, unfiltered and exhaustive, so a new kind of
  // directive stops this compiling.
  for (final directive in unit.directives) {
    yield* switch (directive) {
      NamespaceDirective(:final uri, :final configurations) => [
        uri,
        for (final branch in configurations) branch.uri,
      ],
      PartDirective(:final uri) => [uri],
      LibraryDirective() || PartOfDirective() => const <StringLiteral>[],
    };
  }
}

/// The interfaces name only the types they take and give back: the web
/// request and outcome types, the reply's, and the trajectory's id.
bool _allowedPackage(String name) => const {
  'is_conversation_vocabulary',
  'is_effects',
  'is_shapes',
}.contains(name);

bool _allowed(String target) {
  final uri = Uri.parse(target);
  return switch (uri.scheme) {
    'dart' => target == 'dart:core',
    'package' => _allowedPackage(uri.pathSegments.first),
    '' => !uri.isAbsolute && !uri.pathSegments.contains('..'),
    _ => false,
  };
}

void main() {
  test('the interfaces import only the types they name', () {
    final violations = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      for (final literal in directiveUris(file.readAsStringSync())) {
        // Null when the URI is not one plain string, so cannot be checked.
        final target = literal.stringValue;
        if (target == null || !_allowed(target)) {
          violations.add('${file.path}: ${target ?? literal.toSource()}');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'writing a reply\'s requests is pure: it sends nothing',
    );
  });

  test('exports only its own files, never another package', () {
    final reExports = <String>[];
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final unit = parseString(
        content: file.readAsStringSync(),
        throwIfDiagnostics: false,
      ).unit;
      for (final directive in unit.directives.whereType<ExportDirective>()) {
        for (final literal in [
          directive.uri,
          for (final branch in directive.configurations) branch.uri,
        ]) {
          final target = literal.stringValue;
          if (target == null || Uri.parse(target).hasScheme) {
            reExports.add('${file.path}: ${target ?? literal.toSource()}');
          }
        }
      }
    }
    expect(
      reExports,
      isEmpty,
      reason: 'a dependent imports each vocabulary it uses directly',
    );
  });
}
