class Revision {
  final String id;
  final String entityType; // e.g. "Company", "Investor", etc.
  final String entityId; // The ID of the item being edited
  final Map<String, dynamic> proposedChanges;
  final Map<String, dynamic>? originalData;
  final String status;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? requestedBy;      // UUID of Founder requestor
  final String submitterType;    // 'admin' or 'member'
  final Map<String, dynamic>? fieldDecisions; // field decisions mapping
  final String? adminNote;        // feedback note from admin
  final Map<String, dynamic>? requestor;        // requestor info: { id, username, avatar_url }

  Revision({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.proposedChanges,
    this.originalData,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.requestedBy,
    this.submitterType = 'admin',
    this.fieldDecisions,
    this.adminNote,
    this.requestor,
  });

  factory Revision.fromJson(Map<String, dynamic> json) {
    // Safely parse proposed_changes with type conversion
    Map<String, dynamic> parseProposedChanges(dynamic rawChanges) {
      if (rawChanges == null) return {};
      if (rawChanges is! Map) return {};

      final Map<String, dynamic> changes = {};
      for (final entry in rawChanges.entries) {
        final key = entry.key;
        final value = entry.value;

        // Handle null values
        if (value == null) {
          changes[key] = null;
          continue;
        }

        // If it's already a basic type, keep it as-is
        if (value is String || value is bool || value is Map || value is List) {
          changes[key] = value;
          continue;
        }

        // Handle numeric values that might be sent as strings
        // (e.g., Decimal fields from PostgreSQL)
        if (value is num) {
          changes[key] = value;
        } else {
          // Try to convert string to number if it looks like one
          final strValue = value.toString();
          if (strValue.isNotEmpty) {
            // Try parsing as int first, then double
            final parsedInt = int.tryParse(strValue);
            if (parsedInt != null) {
              changes[key] = parsedInt;
            } else {
              final parsedDouble = double.tryParse(strValue);
              if (parsedDouble != null) {
                changes[key] = parsedDouble;
              } else {
                // Keep as string if it's not a number
                changes[key] = strValue;
              }
            }
          } else {
            changes[key] = null;
          }
        }
      }
      return changes;
    }

    return Revision(
      id: json['id'] ?? '',
      entityType: json['entity_type'] ?? '',
      entityId: json['entity_id'] ?? '',
      proposedChanges: parseProposedChanges(json['proposed_changes']),
      originalData: json['original_data'] != null ? parseProposedChanges(json['original_data']) : null,
      status: json['status'] ?? 'Pending',
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      requestedBy: json['requested_by'],
      submitterType: json['submitter_type'] ?? 'admin',
      fieldDecisions: json['field_decisions'] != null
          ? Map<String, dynamic>.from(json['field_decisions'] as Map)
          : null,
      adminNote: json['admin_note'],
      requestor: json['requestor'] != null
          ? Map<String, dynamic>.from(json['requestor'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'proposed_changes': proposedChanges,
      'original_data': originalData,
      'requested_by': requestedBy,
      'submitter_type': submitterType,
      'field_decisions': fieldDecisions,
      'admin_note': adminNote,
      'requestor': requestor,
    };
  }
}
