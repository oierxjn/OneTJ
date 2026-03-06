import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeveloperDebugUploadCard extends StatefulWidget {
  const DeveloperDebugUploadCard({
    required this.l10n,
    required this.endpoint,
    required this.sending,
    required this.onSend,
    super.key,
  });

  final AppLocalizations l10n;
  final String endpoint;
  final bool sending;
  final Future<void> Function(String endpoint) onSend;

  @override
  State<DeveloperDebugUploadCard> createState() =>
      _DeveloperDebugUploadCardState();
}

class _DeveloperDebugUploadCardState extends State<DeveloperDebugUploadCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  late final TextEditingController _endpointController;
  late final FocusNode _endpointFocusNode;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _endpointController = TextEditingController(text: widget.endpoint);
    _endpointFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant DeveloperDebugUploadCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_endpointFocusNode.hasFocus) {
      return;
    }
    if (oldWidget.endpoint == widget.endpoint) {
      return;
    }
    _endpointController.text = widget.endpoint;
  }

  @override
  void dispose() {
    _expandController.dispose();
    _endpointController.dispose();
    _endpointFocusNode.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
    if (_expanded) {
      _expandController.forward();
      return;
    }
    _expandController.reverse();
  }

  Widget _buildEndpointField() {
    return TextField(
      controller: _endpointController,
      focusNode: _endpointFocusNode,
      keyboardType: TextInputType.url,
      autocorrect: false,
      enabled: !widget.sending,
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        labelText: widget.l10n.settingsDebugEndpointTitle,
        hintText: widget.l10n.settingsDebugEndpointHint,
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: widget.sending
            ? null
            : () async {
                await widget.onSend(_endpointController.text);
              },
        icon: widget.sending
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send_outlined),
        label: Text(widget.l10n.settingsDebugUploadTitle),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildEndpointField(),
          const SizedBox(height: 12),
          _buildSendButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.send_to_mobile_outlined),
            title: Text(widget.l10n.settingsDebugUploadTitle),
            subtitle: Text(
              widget.l10n.settingsDebugUploadSubtitle(widget.endpoint),
            ),
            trailing: AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              child: const Icon(Icons.expand_more),
            ),
            onTap: _toggleExpanded,
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: _buildExpandedContent(),
          ),
        ],
      ),
    );
  }
}
