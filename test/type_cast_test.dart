import 'package:flutter_test/flutter_test.dart';
import 'package:investrack_admin/features/revisions/models/revision_model.dart';

void main() {
  test('Revision.fromJson cast test', () {
    final Map<String, dynamic> json = {
      'id': '94aa69a7-2d02-4ba8-a4c2-f79c5826223b',
      'entity_type': 'company',
      'entity_id': '45569d0e-85ec-4915-946a-03ba8d4912b5',
      'proposed_changes': {
        'logo_url': 'http://localhost:8000/uploads/1783359286169-934333612.png'
      },
      'status': 'Pending',
      'submitter_type': 'member',
      'requestor': {
        'id': '48f5c685-1090-4e1e-8977-71b89f0790a6',
        'username': 'founder_user',
        'avatar_url': null
      }
    };

    final revision = Revision.fromJson(json);
    expect(revision.id, '94aa69a7-2d02-4ba8-a4c2-f79c5826223b');
    expect(revision.requestor?['username'], 'founder_user');
  });
}
