class Revision {
  final String id;
  final String entityType; // e.g. "Company", "Investor", etc.
  final String entityId; // The ID of the item being edited
  final Map<String, dynamic> proposedChanges;
  final String status;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Revision({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.proposedChanges,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Revision.fromJson(Map<String, dynamic> json) {
    return Revision(
      id: json['id'] ?? '',
      entityType: json['entity_type'] ?? '',
      entityId: json['entity_id'] ?? '',
      proposedChanges: json['proposed_changes'] ?? {},
      status: json['status'] ?? 'Pending',
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'proposed_changes': proposedChanges,
    };
  }
}
