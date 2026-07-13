import 'package:flutter/material.dart';
import '../models/incident_types.dart';

class IncidentTypePicker extends StatelessWidget {
  final String? selectedPath;
  final ValueChanged<String> onSelected;

  const IncidentTypePicker({
    super.key,
    this.selectedPath,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selectedPath != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Chip(
              label: Text(selectedPath!, style: const TextStyle(fontSize: 13)),
              onDeleted: () => onSelected(''),
            ),
          ),
        const Text('Incident Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 4),
        _IncidentTypeTree(
          nodes: IncidentTypeNode.allTypes,
          selectedPath: selectedPath,
          onSelected: onSelected,
          depth: 0,
        ),
      ],
    );
  }
}

class _IncidentTypeTree extends StatefulWidget {
  final List<IncidentTypeNode> nodes;
  final String? selectedPath;
  final ValueChanged<String> onSelected;
  final int depth;

  const _IncidentTypeTree({
    required this.nodes,
    this.selectedPath,
    required this.onSelected,
    required this.depth,
  });

  @override
  State<_IncidentTypeTree> createState() => _IncidentTypeTreeState();
}

class _IncidentTypeTreeState extends State<_IncidentTypeTree> {
  final Set<String> _expanded = {};

  String _buildFullPath(IncidentTypeNode node, [String parent = '']) {
    return parent.isEmpty ? node.name : '$parent > ${node.name}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final node in widget.nodes)
          _buildNode(context, node, ''),
      ],
    );
  }

  Widget _buildNode(BuildContext context, IncidentTypeNode node, String parentPath) {
    final fullPath = _buildFullPath(node, parentPath);
    final isExpanded = _expanded.contains(fullPath);
    final isSelected = widget.selectedPath == fullPath;
    final isLeaf = node.isLeaf;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (isLeaf) {
              widget.onSelected(fullPath);
            } else {
              setState(() {
                if (isExpanded) {
                  _expanded.remove(fullPath);
                } else {
                  _expanded.add(fullPath);
                }
              });
            }
          },
          child: Padding(
            padding: EdgeInsets.only(left: widget.depth * 16.0, top: 2, bottom: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLeaf ? Icons.label_outline : (isExpanded ? Icons.expand_more : Icons.chevron_right),
                  size: 18,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                const SizedBox(width: 4),
                Text(
                  node.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLeaf && isExpanded)
          _IncidentTypeTree(
            nodes: node.children,
            selectedPath: widget.selectedPath,
            onSelected: widget.onSelected,
            depth: widget.depth + 1,
          ),
      ],
    );
  }
}
