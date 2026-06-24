import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/widgets/admin_header.dart';
import 'package:investrack_admin/widgets/custom_logo_widget.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/features/members/controllers/members_controller.dart';
import 'package:investrack_admin/features/investors/controllers/investors_controller.dart';
import 'package:investrack_admin/features/dashboard/controllers/dashboard_controller.dart';
import 'package:investrack_admin/features/dashboard/models/dashboard_model.dart';
import 'package:investrack_admin/features/dashboard/services/report_generator_service.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ScrollController _horizontalScrollCtrl = ScrollController();
  final ScrollController _verticalScrollCtrl = ScrollController();

  @override
  void dispose() {
    _horizontalScrollCtrl.dispose();
    _verticalScrollCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RevisionsController>().loadPendingRevisions();
      context.read<DashboardController>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AdminHeader(
            title: 'Welcome back, Admin',
            subtitle: 'Here is the state of the InvesTrack data lake today',
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<DashboardController>().loadAll();
                  },
                  icon: const Icon(LucideIcons.refreshCcw, size: 16),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<DashboardController>(
                  builder: (context, dashboardCtrl, _) {
                    return ElevatedButton(
                      onPressed: () {
                        ReportGeneratorService.generateAndShowReport(
                          dashboardCtrl.summary,
                          dashboardCtrl.sectors,
                          dashboardCtrl.recentCompanies,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                      child: const Text('Generate report'),
                    );
                  }
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              controller: _horizontalScrollCtrl,
              child: SingleChildScrollView(
                controller: _horizontalScrollCtrl,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1350,
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: _verticalScrollCtrl,
                    child: SingleChildScrollView(
                      controller: _verticalScrollCtrl,
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
            // Stats Row
            Consumer4<CompaniesController, MembersController, InvestorsController, DashboardController>(
              builder: (context, companiesCtrl, membersCtrl, investorsCtrl, dashboardCtrl, child) {
                final sum = dashboardCtrl.summary;
                if (dashboardCtrl.isLoadingSummary) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(width: 250, child: _buildStatCard(
                      'Companies',
                      (sum?.totalCompanies ?? companiesCtrl.companies.length).toString(),
                      '+${sum?.newCompaniesThisMonth ?? 0} this month',
                      true,
                      '${sum?.companiesAwaitingReview ?? 0} awaiting review',
                      LucideIcons.building2,
                    )),
                    SizedBox(width: 250, child: _buildStatCard(
                      'Founders & people',
                      (sum?.totalMembers ?? membersCtrl.members.length).toString(),
                      '+${sum?.newMembersThisMonth ?? 0} this month',
                      true,
                      'Total registered users',
                      LucideIcons.users,
                    )),
                    SizedBox(width: 250, child: _buildStatCard(
                      'Active investors',
                      (sum?.totalInvestors ?? investorsCtrl.investors.length).toString(),
                      '+0',
                      true,
                      'across multiple countries',
                      LucideIcons.wallet,
                    )),
                    SizedBox(width: 250, child: _buildStatCard(
                      'Funding tracked (YTD)',
                      '\$${((sum?.totalFundingYTD ?? 0) / 1000000).toStringAsFixed(1)}M',
                      '${(sum?.fundingChangePct ?? 0) >= 0 ? '+' : ''}${(sum?.fundingChangePct ?? 0).toStringAsFixed(1)}%',
                      (sum?.fundingChangePct ?? 0) >= 0,
                      'vs. same period last year',
                      LucideIcons.trendingUp,
                    )),
                    SizedBox(width: 250, child: _buildStatCard(
                      'Subscription Revenue',
                      '\$${sum?.monthlySubscriptionRevenue.toStringAsFixed(2) ?? '0.00'}',
                      'This month',
                      true,
                      'Monthly recurring',
                      LucideIcons.banknote,
                    )),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Charts Row
            Consumer<DashboardController>(
              builder: (context, dashboardCtrl, child) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 600,
                      child: _buildChartCardWithActions(
                        'Funding deployed in Laos',
                        '${dashboardCtrl.currentFundingPeriod} · USD millions',
                        _FundingAreaChart(history: dashboardCtrl.fundingHistory, isLoading: dashboardCtrl.isLoadingFunding),
                        Row(
                        mainAxisSize: MainAxisSize.min,
                        children: ['1D', '1W', '2W', '1M', '3M', '6M'].map((period) {
                          final isSelected = dashboardCtrl.currentFundingPeriod == period;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: ChoiceChip(
                              label: Text(period),
                              labelStyle: TextStyle(
                                fontSize: 10,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.background,
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) dashboardCtrl.loadFundingHistory(period);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: _buildChartCard(
                      'Sectors',
                      'Share of tracked companies',
                      _SectorBarChart(sectors: dashboardCtrl.sectors, isLoading: dashboardCtrl.isLoadingSectors),
                    ),
                  ),
                ],
              );
              }
            ),

            const SizedBox(height: 24),

            // Lists Row
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 600,
                  child: _buildListCard(
                    'Recently updated companies',
                    'Last edits across the dataset',
                    const _RecentCompaniesList(),
                    onViewAll: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            width: 600,
                            constraints: const BoxConstraints(maxHeight: 600),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Recently Updated Companies', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(LucideIcons.x, size: 20),
                                        onPressed: () => Navigator.pop(context),
                                        splashRadius: 24,
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, color: AppColors.border),
                                const Flexible(
                                  child: SingleChildScrollView(
                                    child: _RecentCompaniesList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 350,
                  child: Consumer<RevisionsController>(
                    builder: (context, revCtrl, child) {
                      return _buildListCard(
                        'Moderation queue',
                        '${revCtrl.pendingRevisions.length} items awaiting review',
                        _ModerationQueueList(controller: revCtrl),
                        onViewAll: () => context.push('/moderations'),
                      );
                    }
                  ),
                ),
              ],
            ),
              ],
            ), // End of Column
          ), // End of SingleChildScrollView(vertical)
        ), // End of Scrollbar(vertical)
      ), // End of SizedBox
    ), // End of SingleChildScrollView(horizontal)
  ), // End of Scrollbar(horizontal)
), // End of Expanded
],
),
    );
  }

  Widget _buildStatCard(String label, String value, String delta, bool positive, String hint, IconData icon) {
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Icon(icon, size: 16, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: positive ? AppColors.successBg : AppColors.errorBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      delta,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: positive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(hint, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
      );
  }

  Widget _buildChartCardWithActions(String title, String subtitle, Widget chart, Widget action) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                action,
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(height: 250, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, String subtitle, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            SizedBox(height: 250, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(String title, String subtitle, Widget list, {VoidCallback? onViewAll}) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                if (onViewAll != null)
                  TextButton.icon(
                    onPressed: onViewAll,
                    icon: const Text('View all', style: TextStyle(fontSize: 12)),
                    label: const Icon(LucideIcons.arrowRight, size: 14),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          list,
        ],
      ),
    );
  }
}

class _FundingAreaChart extends StatefulWidget {
  final List<FundingHistoryItem> history;
  final bool isLoading;
  const _FundingAreaChart({required this.history, this.isLoading = false});

  @override
  State<_FundingAreaChart> createState() => _FundingAreaChartState();
}

class _FundingAreaChartState extends State<_FundingAreaChart> {
  double? _minX;
  double? _maxX;
  double? _minY;
  double? _maxY;

  double _lastScale = 1.0;
  Offset _lastFocalPoint = Offset.zero;

  @override
  void didUpdateWidget(covariant _FundingAreaChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.history != oldWidget.history) {
      _resetView();
    }
  }

  void _resetView() {
    setState(() {
      _minX = null;
      _maxX = null;
      _minY = null;
      _maxY = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return const Center(child: CircularProgressIndicator());

    // Provide a dummy history if empty so the chart still renders an empty grid
    final history = widget.history.isEmpty 
        ? List.generate(5, (index) => FundingHistoryItem(
            date: DateTime.now().subtract(Duration(days: 4 - index)).toString().split(' ')[0], 
            totalAmount: 0))
        : widget.history;
    final maxAmount = history.map((e) => e.totalAmount).reduce((a, b) => a > b ? a : b);
    
    final defaultMinX = 0.0;
    final defaultMaxX = history.length > 1 ? (history.length - 1).toDouble() : 1.0;
    final defaultMinY = 0.0;
    final defaultMaxY = maxAmount > 0 ? maxAmount * 1.2 : 5.0;

    final currentMinX = _minX ?? defaultMinX;
    final currentMaxX = _maxX ?? defaultMaxX;
    final currentMinY = _minY ?? defaultMinY;
    final currentMaxY = _maxY ?? defaultMaxY;

    return Stack(
      children: [
        GestureDetector(
          onScaleStart: (details) {
            _lastScale = 1.0;
            _lastFocalPoint = details.localFocalPoint;
          },
          onScaleUpdate: (details) {
            setState(() {
              // Handle Panning
              final dx = details.localFocalPoint.dx - _lastFocalPoint.dx;
              final dy = details.localFocalPoint.dy - _lastFocalPoint.dy;
              
              final xRange = currentMaxX - currentMinX;
              final yRange = currentMaxY - currentMinY;
              
              // Pan sensitivity
              final xDelta = -(dx / context.size!.width) * xRange;
              final yDelta = (dy / context.size!.height) * yRange;
              
              double newMinX = currentMinX + xDelta;
              double newMaxX = currentMaxX + xDelta;
              double newMinY = currentMinY + yDelta;
              double newMaxY = currentMaxY + yDelta;

              // Handle Zooming
              if (details.scale != 1.0) {
                final scaleChange = details.scale / _lastScale;
                final zoomFactor = 1 / scaleChange;
                
                final xCenter = (newMinX + newMaxX) / 2;
                final yCenter = (newMinY + newMaxY) / 2;
                
                newMinX = xCenter - (xRange * zoomFactor / 2);
                newMaxX = xCenter + (xRange * zoomFactor / 2);
                newMinY = yCenter - (yRange * zoomFactor / 2);
                newMaxY = yCenter + (yRange * zoomFactor / 2);
              }

              // Clamp to prevent zooming out too far or panning completely out of bounds
              if (newMaxX - newMinX < 0.5) {
                // Prevent zooming in too much on X
                final center = (newMinX + newMaxX) / 2;
                newMinX = center - 0.25;
                newMaxX = center + 0.25;
              }
              
              if (newMaxY - newMinY < (defaultMaxY * 0.05)) {
                // Prevent zooming in too much on Y
                final center = (newMinY + newMaxY) / 2;
                newMinY = center - (defaultMaxY * 0.025);
                newMaxY = center + (defaultMaxY * 0.025);
              }

              _minX = newMinX;
              _maxX = newMaxX;
              _minY = newMinY;
              _maxY = newMaxY;

              _lastScale = details.scale;
              _lastFocalPoint = details.localFocalPoint;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 24.0, bottom: 8.0),
            child: LineChart(
              LineChartData(
                clipData: const FlClipData.all(),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        if (spot.x.toInt() < 0 || spot.x.toInt() >= history.length) return null;
                        final date = history[spot.x.toInt()].date;
                        return LineTooltipItem(
                          '\$${(spot.y / 1000000).toStringAsFixed(2)}M\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          children: [
                            TextSpan(
                              text: date,
                              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.normal),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: defaultMaxY > 0 ? defaultMaxY / 5 : 1,
                  verticalInterval: defaultMaxX > 0 ? defaultMaxX / 5 : 1,
                  getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.border, strokeWidth: 1, dashArray: [4, 4]),
                  getDrawingVerticalLine: (value) => const FlLine(color: AppColors.border, strokeWidth: 1, dashArray: [4, 4]),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (currentMaxX - currentMinX) / 5 > 0 ? (currentMaxX - currentMinX) / 5 : 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.round();
                        if (index >= 0 && index < history.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(history[index].date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (currentMaxY - currentMinY) / 5 > 0 ? (currentMaxY - currentMinY) / 5 : 1,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value < 0) return const Text('');
                        if (value == 0) return const Text('\$0', style: TextStyle(color: AppColors.textSecondary, fontSize: 10));
                        return Text('\$${(value / 1000000).toStringAsFixed(1)}M', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true, 
                  border: const Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                    left: BorderSide(color: AppColors.border, width: 1),
                  )
                ),
                minX: currentMinX,
                maxX: currentMaxX,
                minY: currentMinY,
                maxY: currentMaxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalAmount)).toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: history.length == 1 || (currentMaxX - currentMinX) < 10,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.35),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_minX != null || _maxY != null)
          Positioned(
            top: 0,
            right: 16,
            child: IconButton(
              icon: const Icon(LucideIcons.refreshCcw, size: 16, color: AppColors.textSecondary),
              tooltip: 'Reset View',
              onPressed: _resetView,
              splashRadius: 20,
            ),
          ),
      ],
    );
  }
}

class _SectorBarChart extends StatefulWidget {
  final List<SectorStat> sectors;
  final bool isLoading;
  const _SectorBarChart({required this.sectors, this.isLoading = false});

  @override
  State<_SectorBarChart> createState() => _SectorBarChartState();
}

class _SectorBarChartState extends State<_SectorBarChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return const Center(child: CircularProgressIndicator());
    if (widget.sectors.isEmpty) return const Center(child: Text('No sector data'));

    final total = widget.sectors.fold<int>(0, (sum, item) => sum + item.count);
    if (total == 0) return const Center(child: Text('No companies tracked'));

    final colors = [
      AppColors.primary,
      const Color(0xFF14B8A6), // teal
      const Color(0xFFF59E0B), // amber
      const Color(0xFF8B5CF6), // purple
      const Color(0xFFEC4899), // pink
      const Color(0xFF06B6D4), // cyan
      const Color(0xFFF97316), // orange
      const Color(0xFF10B981), // emerald
      const Color(0xFF6366F1), // indigo
      AppColors.textSecondary,
    ];

    // Sort sectors by count descending
    final sorted = List<SectorStat>.from(widget.sectors)
      ..sort((a, b) => b.count.compareTo(a.count));

    List<SectorStat> displaySectors = sorted;
    if (sorted.length > 6) {
      final top6 = sorted.take(6).toList();
      final otherCount = sorted.skip(6).fold<int>(0, (sum, item) => sum + item.count);
      if (otherCount > 0) {
        displaySectors = [...top6, SectorStat(industry: 'Other', count: otherCount)];
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: displaySectors.asMap().entries.map((entry) {
                  final i = entry.key;
                  final sector = entry.value;
                  final isTouched = i == touchedIndex;
                  final pct = (sector.count / total * 100);

                  return PieChartSectionData(
                    color: colors[i % colors.length],
                    value: sector.count.toDouble(),
                    title: pct >= 3 ? '${pct.toStringAsFixed(0)}%' : '',
                    radius: isTouched ? 50.0 : 40.0,
                    titleStyle: TextStyle(
                      fontSize: isTouched ? 14.0 : 10.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: displaySectors.asMap().entries.map((entry) {
                final i = entry.key;
                final sector = entry.value;
                final color = colors[i % colors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sector.industry,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: i == touchedIndex ? FontWeight.bold : FontWeight.w500,
                            color: i == touchedIndex ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCompaniesList extends StatelessWidget {
  const _RecentCompaniesList();

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        if (controller.isLoadingRecent) return const Center(child: CircularProgressIndicator());
        if (controller.recentCompanies.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No recent updates')));

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.recentCompanies.length,
          separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
          itemBuilder: (context, index) {
            final item = controller.recentCompanies[index];
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  CustomLogoWidget(
                    imageUrl: item.logoUrl,
                    fallbackName: item.name,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('${item.industry} · Updated recently', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
class _ModerationQueueList extends StatelessWidget {
  final RevisionsController controller;
  const _ModerationQueueList({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) return const Center(child: CircularProgressIndicator());
    if (controller.pendingRevisions.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No pending revisions')));

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.pendingRevisions.length,
          separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
          itemBuilder: (context, index) {
            final rev = controller.pendingRevisions[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(rev.entityType, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textSecondary)),
                          ),
                          const SizedBox(width: 8),
                          const Text('PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: AppColors.success, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => controller.approveRevision(rev.id),
                            tooltip: 'Approve',
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.error, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => controller.rejectRevision(rev.id),
                            tooltip: 'Reject',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Update to ${rev.entityId}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('By ${rev.createdBy ?? "Unknown"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            );
          },
        ),
        const Divider(height: 1, color: AppColors.border),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Open queue'),
            ),
          ),
        ),
      ],
    );
  }
}
