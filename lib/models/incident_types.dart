class IncidentTypeNode {
  final String name;
  final List<IncidentTypeNode> children;

  const IncidentTypeNode(this.name, [this.children = const []]);

  bool get isLeaf => children.isEmpty;

  String get fullPath => name;

  static const List<IncidentTypeNode> allTypes = [
    IncidentTypeNode('Fire', [
      IncidentTypeNode('Working Fire', [
        IncidentTypeNode('Residential'),
        IncidentTypeNode('Commercial'),
        IncidentTypeNode('Industrial'),
        IncidentTypeNode('Vacant'),
      ]),
      IncidentTypeNode('Automotive', [
        IncidentTypeNode('Private'),
        IncidentTypeNode('Commercial'),
        IncidentTypeNode('Rail'),
        IncidentTypeNode('Recreation'),
      ]),
      IncidentTypeNode('Brush/Field'),
      IncidentTypeNode('Smoke Showing'),
      IncidentTypeNode('Other'),
    ]),
    IncidentTypeNode('Traffic Accidents', [
      IncidentTypeNode('Motor Vehicle', [
        IncidentTypeNode('Major'),
        IncidentTypeNode('Minor'),
        IncidentTypeNode('Major w/ Road Closure'),
        IncidentTypeNode('Minor w/ Road Closure'),
        IncidentTypeNode('Fatal'),
      ]),
      IncidentTypeNode('Pedestrian Vehicle', [
        IncidentTypeNode('Major'),
        IncidentTypeNode('Minor'),
        IncidentTypeNode('Major w/ Road Closure'),
        IncidentTypeNode('Minor w/ Road Closure'),
        IncidentTypeNode('Fatal'),
      ]),
      IncidentTypeNode('Motorcycle', [
        IncidentTypeNode('Major'),
        IncidentTypeNode('Minor'),
        IncidentTypeNode('Major w/ Road Closure'),
        IncidentTypeNode('Minor w/ Road Closure'),
        IncidentTypeNode('Fatal'),
      ]),
      IncidentTypeNode('Multi Vehicle', [
        IncidentTypeNode('Major'),
        IncidentTypeNode('Minor'),
        IncidentTypeNode('Major w/ Road Closure'),
        IncidentTypeNode('Minor w/ Road Closure'),
        IncidentTypeNode('Fatal'),
      ]),
      IncidentTypeNode('Other'),
    ]),
    IncidentTypeNode('Medical', [
      IncidentTypeNode('Injury'),
      IncidentTypeNode('Resuscitation'),
      IncidentTypeNode('Assault'),
      IncidentTypeNode('Child Birth'),
      IncidentTypeNode('Mental Health', [
        IncidentTypeNode('Self Harm'),
        IncidentTypeNode('Suicide', [
          IncidentTypeNode('Attempt'),
          IncidentTypeNode('Threat'),
        ]),
      ]),
      IncidentTypeNode('Myocardial Infarction'),
      IncidentTypeNode('Transient Ischemic Attack'),
      IncidentTypeNode('Epilepsy'),
      IncidentTypeNode('Anaphylactic Shock'),
    ]),
    IncidentTypeNode('Rescue', [
      IncidentTypeNode('Technical'),
      IncidentTypeNode('Water'),
      IncidentTypeNode('Trench'),
    ]),
    IncidentTypeNode('HazMat', [
      IncidentTypeNode('Chemical'),
      IncidentTypeNode('Biological'),
      IncidentTypeNode('Radiological'),
      IncidentTypeNode('Nuclear'),
      IncidentTypeNode('Explosive'),
    ]),
    IncidentTypeNode('Disaster', [
      IncidentTypeNode('Natural'),
      IncidentTypeNode('Terrorism'),
      IncidentTypeNode('Accidental'),
      IncidentTypeNode('Collapse'),
    ]),
    IncidentTypeNode('Aviation'),
    IncidentTypeNode('Death', [
      IncidentTypeNode('Homicide'),
      IncidentTypeNode('Suicide'),
    ]),
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
    if (fullPath.startsWith('Traffic Accidents')) return 'ACCI';
    if (fullPath.startsWith('Medical')) return 'MEDI';
    if (fullPath.startsWith('Rescue')) return 'RESQ';
    if (fullPath.startsWith('HazMat')) return 'HZMT';
    if (fullPath.startsWith('Disaster')) return 'DIST';
    if (fullPath.startsWith('Aviation')) return 'ACC';
    if (fullPath.startsWith('Death')) return 'DEATH';
    return 'GEN';
  }
}
