import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget> children;
  final bool initiallyExpanded;
  final Function(bool)? onExpansionChanged;

  const CustomExpansionTile({super.key,  required this.title, this.leading, required this.children, required this.initiallyExpanded, this.onExpansionChanged});

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState(); 
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
              widget.onExpansionChanged?.call(_isExpanded);
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                widget.leading ?? SizedBox(),
                SizedBox(width: 8),
                Expanded(child: widget.title),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.children.length,
            itemBuilder: (context, index) => widget.children[index],
          ),
      ],
    );
  }
}