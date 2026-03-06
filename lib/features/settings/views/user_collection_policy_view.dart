import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/models/user_collection_field.dart';

class UserCollectionPolicyView extends StatefulWidget {
  const UserCollectionPolicyView({
    super.key,
    required this.initialSelectedFields,
  });

  final Set<UserCollectionField> initialSelectedFields;

  @override
  State<UserCollectionPolicyView> createState() =>
      _UserCollectionPolicyViewState();
}

class _UserCollectionPolicyViewState extends State<UserCollectionPolicyView> {
  late Set<UserCollectionField> _selectedFields;

  @override
  void initState() {
    super.initState();
    _selectedFields =
        Set<UserCollectionField>.from(widget.initialSelectedFields);
  }

  String _fieldLabel(AppLocalizations l10n, UserCollectionField field) {
    switch (field) {
      case UserCollectionField.userid:
        return l10n.settingsUserCollectionFieldUserid;
      case UserCollectionField.username:
        return l10n.settingsUserCollectionFieldUsername;
      case UserCollectionField.clientVersion:
        return l10n.settingsUserCollectionFieldClientVersion;
      case UserCollectionField.deviceBrand:
        return l10n.settingsUserCollectionFieldDeviceBrand;
      case UserCollectionField.deviceModel:
        return l10n.settingsUserCollectionFieldDeviceModel;
      case UserCollectionField.deptName:
        return l10n.settingsUserCollectionFieldDeptName;
      case UserCollectionField.schoolName:
        return l10n.settingsUserCollectionFieldSchoolName;
      case UserCollectionField.gender:
        return l10n.settingsUserCollectionFieldGender;
      case UserCollectionField.platform:
        return l10n.settingsUserCollectionFieldPlatform;
    }
  }

  void _toggleField(UserCollectionField field, bool selected) {
    setState(() {
      if (selected) {
        _selectedFields.add(field);
      } else {
        _selectedFields.remove(field);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedFields =
          Set<UserCollectionField>.from(UserCollectionField.values);
    });
  }

  void _clearAll() {
    setState(() {
      _selectedFields = <UserCollectionField>{};
    });
  }

  void _onBack() {
    Navigator.of(context).pop(Set<UserCollectionField>.from(_selectedFields));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBack,
          ),
          title: Text(l10n.settingsUserCollectionPolicyTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                OutlinedButton(
                  onPressed: _selectAll,
                  child: Text(l10n.settingsUserCollectionPolicySelectAll),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _clearAll,
                  child: Text(l10n.settingsUserCollectionPolicyClearAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...UserCollectionField.values.map((field) {
              final bool selected = _selectedFields.contains(field);
              return Card(
                child: CheckboxListTile(
                  value: selected,
                  title: Text(_fieldLabel(l10n, field)),
                  subtitle: Text(field.jsonKey),
                  onChanged: (value) => _toggleField(field, value ?? false),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
