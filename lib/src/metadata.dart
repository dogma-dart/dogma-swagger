// Copyright (c) 2015, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

library dogma_swagger.src.metadata;

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'package:dogma_codegen/metadata.dart';
import 'package:dogma_codegen/src/codegen/query_generator.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

/// Metadata for a RESTful API endpoint.
class RestEndpointMetadata {
  final String comments;

  /// The return type for a successful response.
  ///
  /// This is corresponds to a 200 being received.
  final TypeMetadata returnType;

  RestEndpointMetadata(this.returnType, {this.comments: ''});
}

class CommandMetadata {}

LibraryMetadata test(Map paths,
                     LibraryMetadata modelLibrary,
                     LibraryMetadata converterLibrary)
{
  var routes = new Map<String, RouteMetadata>();
  var mappers = new Map<String, MapperMetadata>();
  var queries = new List<QueryMetadata>();
  var commands = new List<CommandMetadata>();

  // Iterate over the paths looking for commands and queries
  paths.forEach((path, methods) {
    methods.forEach((method, values) {
      if (method == 'get') {
        print('FOUND A QUERY! $method');
        queries.add(_query(path, values, routes, mappers));
      } else {
        print('FOUND A COMMAND! $method');
        commands.add(_command(path, method, values, routes, mappers));
      }
    });
  });

  // Create the route library

  // Create the table library

  // Create the mapper libraries

  // Create the query libraries
  for (var query in queries) {
    var buffer = new StringBuffer();
    generateQuery(query, buffer);
    print(buffer.toString());
  }

  // Create the command libraries

  return null;
}

QueryMetadata _query(String path,
                     Map query,
                     Map<String, RouteMetadata> routes,
                     Map<String, MapperMetadata> mappers)
{
  print(path);
  var route = _route(path, query['parameters'], routes);

  // Look at the parameters


  // Look at the responses to see what mapper is needed
  var responses = query['responses'];

  responses.forEach((code, values) {
    var schema = values['schema'];

    if (schema != null) {

    }
  });

  return new QueryMetadata('Test', new TypeMetadata('Foo'), fields: []);
}

CommandMetadata _command(String path,
                         String method,
                         Map query,
                         Map<String, RouteMetadata> routes,
                         Map<String, MapperMetadata> mappers)
{
  print(path);
  var route = _route(path, query['parameters'], routes);

  return new CommandMetadata();
}

RouteMetadata _route(String path, List<Map> parameters, Map<String, RouteMetadata> routes) {
  // \TODO figure out what should be done here
  var route = new RouteMetadata(path);

  // See if the route is already present
  var savedRoute = routes[route.name];

  if (savedRoute != null) {
    print('ROUTE ALREADY PRESENT! $path');
    return savedRoute;
  }

  // Store off the route
  routes[route.name] = route;

  return route;
}

/// Gets the type of the schema if present.
///
/// Both the parameters to the API and the response can contain a schema that
/// will map to a model. If present then the information will be in the schema
/// value within the map.
///
/// If no type is referenced then this will return null.
TypeMetadata _typeMetadata(Map value) {
  // Get the schema value from the map
  var schema = value['schema'];

  if (schema == null) {
    return null;
  }


}
