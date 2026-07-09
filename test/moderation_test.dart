import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/revisions/views/moderations_view.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/features/revisions/models/revision_model.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/features/members/controllers/members_controller.dart';
import 'package:investrack_admin/features/founders/controllers/founders_controller.dart';
import 'package:investrack_admin/features/funding_rounds/controllers/investments_controller.dart';
import 'package:investrack_admin/features/packages/controllers/packages_controller.dart';
import 'package:investrack_admin/features/fundraising_posts/controllers/fundraising_posts_controller.dart';

class MockRevisionsController extends ChangeNotifier implements RevisionsController {
  @override
  List<Revision> pendingRevisions = [];
  @override
  bool isLoading = false;
  @override
  String? errorMessage;

  @override
  Future<void> loadPendingRevisions() async {
    // No-op or simulated load
  }

  @override
  Future<bool> createRevision({
    required String entityType,
    required String? entityId,
    required Map<String, dynamic> proposedChanges,
  }) async => true;

  @override
  Future<bool> approveRevision(String id) async => true;

  @override
  Future<bool> rejectRevision(String id) async => true;

  @override
  Future<bool> partialApproveRevision(
    String id,
    Map<String, dynamic> fieldDecisions,
    String? adminNote,
  ) async => true;
}

void main() {
  testWidgets('ModerationsView render freeze test', (WidgetTester tester) async {
    final mockController = MockRevisionsController();
    mockController.pendingRevisions = [
      Revision(
        id: '94aa69a7-2d02-4ba8-a4c2-f79c5826223b',
        entityType: 'company',
        entityId: '45569d0e-85ec-4915-946a-03ba8d4912b5',
        proposedChanges: {
          'logo_url': 'http://localhost:8000/uploads/1783359286169-934333612.png'
        },
        status: 'Pending',
        submitterType: 'member',
        createdAt: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<RevisionsController>.value(value: mockController),
          // Add dummy providers for others to avoid ProviderNotFoundException
          ChangeNotifierProvider<CompaniesController>(create: (_) => CompaniesController()),
          ChangeNotifierProvider<MembersController>(create: (_) => MembersController()),
          ChangeNotifierProvider<FoundersController>(create: (_) => FoundersController()),
          ChangeNotifierProvider<InvestmentsController>(create: (_) => InvestmentsController()),
          ChangeNotifierProvider<PackagesController>(create: (_) => PackagesController()),
          ChangeNotifierProvider<FundraisingPostsController>(create: (_) => FundraisingPostsController()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ModerationsView(),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Moderation Queue'), findsOneWidget);
  });
}
