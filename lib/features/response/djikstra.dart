import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';

class Graph {
  final Map<LatLng, List<Edge>> adjacencyList;

  Graph() : adjacencyList = {};

  void addEdge(LatLng start, LatLng end, double weight) {
    adjacencyList.putIfAbsent(start, () => []).add(Edge(end, weight));
    adjacencyList.putIfAbsent(end, () => []).add(Edge(start, weight));
  }
}

class Edge {
  final LatLng node;
  final double weight;

  Edge(this.node, this.weight);
}

class Node implements Comparable<Node> {
  final LatLng latLng;
  final double distance;

  Node(this.latLng, this.distance);

  @override
  int compareTo(Node other) => distance.compareTo(other.distance);
}

// Build graph from GeoJSON data
Graph buildGraphFromGeoJson(Map<String, dynamic> geoJson) {
  final graph = Graph();
  final features = geoJson['features'] as List;

  for (var feature in features) {
    final geometry = feature['geometry'];
    final coordinates = geometry['coordinates'] as List;

    // Flatten MultiLineString to LineString
    for (var line in coordinates) {
      for (var i = 0; i < line.length - 1; i++) {
        final start = line[i];
        final end = line[i + 1];
        final startLatLng = LatLng(start[1], start[0]);
        final endLatLng = LatLng(end[1], end[0]);
        final distance =
            Distance().as(LengthUnit.Meter, startLatLng, endLatLng);
        graph.addEdge(startLatLng, endLatLng, distance);
      }
    }
  }

  return graph;
}

double kmDistance(LatLng StartPosition, LatLng endPosition) {
  final km = Distance().as(LengthUnit.Meter, StartPosition, endPosition);
  return km;
}

Future<List<LatLng>> dijkstra(Map<String, dynamic> geoJson, Graph graph,
    LatLng startPosition, LatLng endPosition) async {
  final distances = <LatLng, double>{};
  final previous = <LatLng, LatLng?>{};
  final queue = PriorityQueue<Node>((a, b) => a.distance.compareTo(b.distance));

  for (var node in graph.adjacencyList.keys) {
    distances[node] = double.infinity;
    previous[node] = null;
  }

  final startNode = _findNearestNode(geoJson, startPosition);
  final endNode = _findNearestNode(geoJson, endPosition);

  distances[startNode] = 0;
  queue.add(Node(startNode, 0));

  while (queue.isNotEmpty) {
    final currentNode = queue.removeFirst();
    final currentDistance = currentNode.distance;
    if (currentNode.latLng == endNode) {
      return _reconstructPath(previous, endNode);
    }

    for (final edge in graph.adjacencyList[currentNode.latLng] ?? []) {
      final newDistance = currentDistance + edge.weight;
      if (newDistance < (distances[edge.node] ?? double.infinity)) {
        distances[edge.node] = newDistance;
        previous[edge.node] = currentNode.latLng;
        queue.add(Node(edge.node, newDistance));
      }
    }
  }

  return [];
}

LatLng _findNearestNode(Map<String, dynamic> geoJson, LatLng position) {
  final features = geoJson['features'] as List;
  double minDistance = double.infinity;
  LatLng? nearestNode;

  for (var feature in features) {
    final geometry = feature['geometry'];
    final coordinates = geometry['coordinates'] as List;

    if (geometry['type'] == 'MultiLineString') {
      for (var line in coordinates) {
        for (var i = 0; i < line.length; i++) {
          final lat = line[i][1];
          final lon = line[i][0];
          final nodeLatLng = LatLng(lat, lon);
          final distance =
              Distance().as(LengthUnit.Meter, position, nodeLatLng);
          if (distance < minDistance) {
            minDistance = distance;
            nearestNode = nodeLatLng;
          }
        }
      }
    }
  }

  return nearestNode!;
}

List<LatLng> _reconstructPath(Map<LatLng, LatLng?> previous, LatLng endNode) {
  final path = <LatLng>[];
  LatLng? currentNode = endNode;

  while (currentNode != null) {
    path.insert(0, currentNode);
    currentNode = previous[currentNode];
  }

  return path;
}

LatLng getCoordinatesFromIndex(Map<String, dynamic> geoJson, int index) {
  final features = geoJson['features'] as List;
  int indexOffset = 0;

  for (var feature in features) {
    final coordinates = feature['geometry']['coordinates'] as List;

    for (var line in coordinates) {
      if (index >= indexOffset && index < indexOffset + line.length) {
        final coord = line[index - indexOffset];
        return LatLng(coord[1], coord[0]);
      }
      int lineLength = line.length;
      indexOffset += lineLength;
    }
  }

  throw Exception('Index out of range');
}
