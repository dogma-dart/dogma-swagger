// Copyright (c) 2015, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

library dogma_swagger.build;

//---------------------------------------------------------------------
// Standard libraries
//---------------------------------------------------------------------

import 'dart:async';

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'package:dogma_codegen/path.dart';
import 'package:dogma_codegen/template.dart' as template;
import 'package:dogma_codegen/src/build/build_system.dart';
import 'package:dogma_codegen/src/build/converters.dart';
import 'package:dogma_codegen/src/build/default_paths.dart';
import 'package:dogma_codegen/src/build/parse.dart';
import 'package:dogma_codegen/src/build/logging.dart';
import 'package:dogma_codegen/src/build/unmodifiable_model_views.dart';
import 'package:dogma_json_schema/src/build.dart';
import 'package:dogma_json_schema/src/json_schema.dart';
import 'package:logging/logging.dart';

import 'src/metadata.dart';

import 'package:dogma_codegen/src/metadata/route_metadata.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

/// The logger for the library.
final Logger _logger = new Logger('dogma_swagger.build');

/// Builds the model, unmodifiable view, and convert libraries for the project
/// from the Swagger definition specified at [swaggerRoot].
///
/// This build function should be used when the models were defined without
/// the aid of any codegen.
///
/// To use in a library a build.dart file should be created in the package
/// root. This was the convention of the Dart Editor for codegen. If the editor
/// being used does not follow this convention then the
/// [build_system](https://pub.dartlang.org/packages/build_system) library can
/// be used to emulate this functionality.
///
/// An example build.dart using all the defaults follows.
///
///     import 'dart:async';
///     import 'package:dogma_codegen/build.dart';
///
///     Future<Null> main(List<String> args) async {
///       await build(args, 'my_package_name', 'path/to/schema.json');
///     }
///
/// By convention the Dogma Codegen library uses the following directory
/// structure for libraries.
///
///     package_root
///       lib
///         src
///           models
///             foo.dart
///             bar.dart
///           convert
///             foo_convert.dart
///             bar_convert.dart
///           unmodifiable_model_view
///             unmodifiable_foo_view.dart
///             unmodifiable_bar_view.dart
///         models.dart
///         convert.dart
///         unmodifiable_model_view.dart
///
/// To get the best results from the codegen process the root [modelLibrary]
/// should just export all the libraries contained in [modelPath]. All the root
/// library locations, [modelLibrary], [unmodifiableLibrary], and
/// [convertLibrary], along with the output paths, [modelPath],
/// [unmodifiablePath], and [convertPath], can be explicitly set as well.
/// Deviating from the conventions should not break the codegen process, but
/// they should be followed for publicly available libraries to be consistent
/// with other clients using Dogma.
///
/// While [header] is optional it should be specified to provide any license
/// information for the generated libraries.
Future<Null> build(List<String> args,
                   String packageName,
                   String swaggerRoot,
                  {String modelLibrary: defaultModelLibrary,
                   String modelPath: defaultModelPath,
                   bool unmodifiable: true,
                   String unmodifiableLibrary: defaultUnmodifiableLibrary,
                   String unmodifiablePath: defaultUnmodifiablePath,
                   bool convert: true,
                   String convertLibrary: defaultConvertLibrary,
                   String convertPath: defaultConvertPath,
                   String header: ''}) async
{
  // Initialize logging
  initializeLogging(Level.ALL);

  // See if a build should happen
  if (!await shouldBuild(args, [swaggerRoot])) {
    return;
  }

  // Set the header
  template.header = header;

  // Parse the swagger file
  var api = await yamlFile(swaggerRoot, clone: true);
/*
  var routes = new List<RouteMetadata>();

  api['paths'].forEach((key, value) {
    routes.add(new RouteMetadata(key));
  });

  var buffer = new StringBuffer();
  generateRoutes(routes, buffer);
  generateTables(routes, buffer);
  print(buffer.toString());

  test(api['paths'], null, null);
*/
  // Get the JSON schema definitions
  var models = {};
  definitions(api, models);

  // Build the models library
  //
  // The call to modelsLibrary expects definitions in 'definitions' which is
  // already the case in the swagger file.
  var rootLibrary = await buildModels(
      models,
      packageName,
      join(modelLibrary),
      join(modelPath)
  );

  // Build the unmodifiable model view library
  if (unmodifiable) {
    _logger.info('Building unmodifiable model view library');

    await buildUnmodifiableViews(
        rootLibrary,
        join(unmodifiableLibrary),
        join(unmodifiablePath)
    );
  }

  // Build the convert library
  if (convert) {
    _logger.info('Building convert library');

    await buildConverters(
        rootLibrary,
        join(convertLibrary),
        join(convertPath)
    );
  }
}
