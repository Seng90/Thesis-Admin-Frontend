import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_model.dart';

class ReportGeneratorService {
  static Future<void> generateAndShowReport(
    DashboardSummary? summary,
    List<SectorStat> sectors,
    List<RecentCompany> recentCompanies,
  ) async {
    final pdf = pw.Document();
    
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final numberFormatter = NumberFormat.decimalPattern();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'InvesTrack',
                    style: pw.TextStyle(
                      color: PdfColors.blue900,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  pw.Text(
                    'Executive Summary Report',
                    style: pw.TextStyle(
                      color: PdfColors.grey700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generated on: ${DateFormat('MMMM dd, yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 20),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // 1. Key Metrics Section
            pw.Text(
              '1. Key Metrics',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
            ),
            pw.SizedBox(height: 10),
            if (summary != null)
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  _buildTableRow('Total Tracked Companies', numberFormatter.format(summary.totalCompanies)),
                  _buildTableRow('New Companies This Month', numberFormatter.format(summary.newCompaniesThisMonth)),
                  _buildTableRow('Total Registered Members', numberFormatter.format(summary.totalMembers)),
                  _buildTableRow('New Members This Month', numberFormatter.format(summary.newMembersThisMonth)),
                  _buildTableRow('Active Investors', numberFormatter.format(summary.totalInvestors)),
                  _buildTableRow('Total Funding (YTD)', currencyFormatter.format(summary.totalFundingYTD)),
                  _buildTableRow('Monthly Subscription Revenue', currencyFormatter.format(summary.monthlySubscriptionRevenue)),
                  _buildTableRow('Pending Revisions', numberFormatter.format(summary.revisionsAwaitingReview)),
                ],
              )
            else
              pw.Text('No summary data available.', style: const pw.TextStyle(color: PdfColors.grey)),
            
            pw.SizedBox(height: 30),

            // 2. Sector Distribution Section
            pw.Text(
              '2. Companies by Sector',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
            ),
            pw.SizedBox(height: 10),
            if (sectors.isNotEmpty)
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Industry', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Company Count', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...sectors.map((sector) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(sector.industry)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(numberFormatter.format(sector.count))),
                    ],
                  )),
                ],
              )
            else
              pw.Text('No sector data available.', style: const pw.TextStyle(color: PdfColors.grey)),
            
            pw.SizedBox(height: 30),

            // 3. Recent Companies Section
            pw.Text(
              '3. Recently Updated Companies',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
            ),
            pw.SizedBox(height: 10),
            if (recentCompanies.isNotEmpty)
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Company Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Industry', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Last Updated', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...recentCompanies.map((comp) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(comp.name)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(comp.industry)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(comp.updatedAt != null ? DateFormat('MMM dd, yyyy').format(comp.updatedAt!) : 'N/A')),
                    ],
                  )),
                ],
              )
            else
              pw.Text('No recent companies data available.', style: const pw.TextStyle(color: PdfColors.grey)),
          ];
        },
      ),
    );

    // Display the PDF using Printing package
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'InvesTrack_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }
}
