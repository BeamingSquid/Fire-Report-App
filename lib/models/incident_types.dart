class IncidentTypeNode {
  final String name;
  final List<IncidentTypeNode> children;

  const IncidentTypeNode(this.name, [this.children = const []]);

  bool get isLeaf => children.isEmpty;

  String get fullPath => name;

  static const List<IncidentTypeNode> allTypes = [
    IncidentTypeNode('Fire', [
      IncidentTypeNode('Working Fire', [
        IncidentTypeNode('Structure - House'),
        IncidentTypeNode('Structure - Commercial'),
        IncidentTypeNode('Structure - Industrial'),
        IncidentTypeNode('Structure - Vacant'),
      ]),
      IncidentTypeNode('Smoke Showing'),
      IncidentTypeNode('Brush Fire'),
    ]),
    IncidentTypeNode('Traffic Accident', [
      IncidentTypeNode('Motor Vehicle Accident', [
        IncidentTypeNode('Major'),
        IncidentTypeNode('Minor'),
        IncidentTypeNode('Major With Roadway Shutdown'),
        IncidentTypeNode('Minor With Roadway Shutdown'),
        IncidentTypeNode('Extrication'),
        IncidentTypeNode('Fatal'),
      ]),
      IncidentTypeNode('Pedestrian Vehicle Accident'),
      IncidentTypeNode('Multi Vehicle Accident', [
        IncidentTypeNode('Major'),
        IncidentTypeNode('Minor'),
        IncidentTypeNode('Major With Roadway Shutdown'),
        IncidentTypeNode('Minor With Roadway Shutdown'),
        IncidentTypeNode('Extrication'),
      ]),
    ]),
    IncidentTypeNode('Rescue - Technical'),
    IncidentTypeNode('HazMat'),
    IncidentTypeNode('Medical'),
    IncidentTypeNode('Natural Disaster'),
  ];

  static String? buildFullPath(IncidentTypeNode leaf) {
    return _findPath(leaf, allTypes);
  }

  static String? _findPath(IncidentTypeNode target, List<IncidentTypeNode> nodes, [String parent = '']) {
    for (final node in nodes) {
      final current = parent.isEmpty ? node.name : '$parent > ${node.name}';
      if (identical(node, target)) return current;
      if (node.children.isNotEmpty) {
        final result = _findPath(target, node.children, current);
        if (result != null) return result;
      }
    }
    return null;
  }

  static List<IncidentTypeNode> getAllLeaves() {
    final leaves = <IncidentTypeNode>[];
    void walk(List<IncidentTypeNode> nodes) {
      for (final n in nodes) {
        if (n.isLeaf) {
          leaves.add(n);
        } else {
          walk(n.children);
        }
      }
    }
    walk(allTypes);
    return leaves;
  }

  static Map<String, String> get leafPaths {
    final map = <String, String>{};
    void walk(List<IncidentTypeNode> nodes, [String parent = '']) {
      for (final n in nodes) {
        final current = parent.isEmpty ? n.name : '$parent > ${n.name}';
        if (n.isLeaf) {
          map[n.name] = current;
        } else {
          walk(n.children, current);
        }
      }
    }
    walk(allTypes);
    return map;
  }

  static String getPrefix(String fullPath) {
    if (fullPath.startsWith('Fire')) return 'FIRE';
    if (fullPath.startsWith('Traffic Accident')) return 'ACC';
    if (fullPath.startsWith('Rescue')) return 'RESQ';
    if (fullPath.startsWith('HazMat')) return 'HAZ';
    if (fullPath.startsWith('Medical')) return 'MED';
    if (fullPath.startsWith('Natural Disaster')) return 'DIS';
    return 'GEN';
  }
}
