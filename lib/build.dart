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

import 'package:dogma_codegen/src/build/build_system.dart';
import 'package:dogma_codegen/src/build/converters.dart';
import 'package:dogma_codegen/src/build/file.dart';
import 'package:dogma_codegen/src/build/models.dart';
import 'package:dogma_codegen/src/build/unmodifiable_model_views.dart';
import 'package:dogma_codegen/path.dart';
import 'package:dogma_json_schema/build.dart' show modelsLibrary;
import 'package:dogma_codegen/template.dart' as template;

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

Future<Null> build(List<String> args,
                   String packageName,
                   String rootSwagger,
                  {String modelLibrary: 'lib/models.dart',
                   String modelPath: 'lib/src/models',
                   bool unmodifiableViews: true,
                   String unmodifiableLibrary: 'lib/unmodifiable_model_views.dart',
                   String unmodifiablePath: 'lib/src/unmodifiable_model_views',
                   bool converters: true,
                   String converterLibrary: 'lib/convert.dart',
                   String converterPath: 'lib/src/convert',
                   String header: ''}) async
{
  // See if a build should happen
  if (!await shouldBuild(args, [rootSwagger])) {
    return;
  }

  // Set the header
  template.header = header;

  // Parse the swagger file
  var api = await yamlFile(rootSwagger, clone: true);

  // Build the models library
  //
  // The call to modelsLibrary expects definitions in 'definitions' which is
  // already the case in the swagger file.
  var rootLibrary = modelsLibrary(api, packageName, modelLibrary, modelPath);

  await buildModels(rootLibrary, join(modelPath));

  if (unmodifiableViews) {

  }

  if (converters) {
    var library = convertersLibrary(
        rootLibrary,
        join(converterLibrary),
        join(converterPath)
    );

    await buildConverters(library, join(converterLibrary), join(converterPath));
  }
}
