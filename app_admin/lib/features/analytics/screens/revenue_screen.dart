import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_provider.dart';
import '../../../core/widgets/admin_scaffold.dart';

class RevenueScreen extends StatelessWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final fmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 12,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Báo cáo Doanh thu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownAccent,
                      ),
                    ),
                    Text(
                      'Tổng quan doanh thu theo thời gian (UC-37)',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...[
                      ('today', 'Hôm nay'),
                      ('7d', '7 ngày'),
                      ('30d', '30 ngày'),
                    ].map((p) => _PresetButton(
                          label: p.$2,
                          onTap: () => provider.setPreset(p.$1),
                        )),
                    // Custom date range
                    OutlinedButton.icon(
                      icon: const Icon(Icons.date_range_rounded, size: 16),
                      label: Text(
                        '${provider.from.day}/${provider.from.month} → ${provider.to.day}/${provider.to.month}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderLight),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                          initialDateRange: DateTimeRange(
                              start: provider.from, end: provider.to),
                        );
                        if (range != null) {
                          provider.setDateRange(range.start, range.end);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (provider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else ...[
              // KPI Cards — responsive
              LayoutBuilder(builder: (ctx, bc) {
                final isMobile = bc.maxWidth < 600;
                final cardW = isMobile
                    ? bc.maxWidth
                    : (bc.maxWidth - 32) / 3;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(width: cardW, child: StatCard(
                      title: 'Tổng doanh thu',
                      value: fmt.format(provider.totalRevenue),
                      icon: Icons.payments_rounded,
                      color: AppColors.goldPrimary,
                    )),
                    SizedBox(width: cardW, child: StatCard(
                      title: 'Đơn hàng',
                      value: provider.totalOrders.toString(),
                      subtitle: '${provider.deliveredOrders} hoàn thành',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.success,
                    )),
                    SizedBox(width: cardW, child: StatCard(
                      title: 'Giá trị trung bình',
                      value: fmt.format(provider.avgOrderValue),
                      icon: Icons.trending_up_rounded,
                      color: AppColors.brownAccent,
                    )),
                  ],
                );
              }),
              const SizedBox(height: 20),

              // Chart
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Doanh thu theo ngày',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.brownAccent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: provider.dailyRevenue.isEmpty
                            ? const Center(
                                child: Text(
                                  'Không có dữ liệu trong khoảng thời gian này',
                                  style: TextStyle(color: AppColors.textHint),
                                ),
                              )
                            : _RevenueLineChart(data: provider.dailyRevenue),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Line Chart ───────────────────────────────────────────────────────────────

class _RevenueLineChart extends StatelessWidget {
  final List<DailyRevenue> data;
  const _RevenueLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.revenue / 1000); // k₫
    }).toList();

    final maxY = data.isEmpty
        ? 100.0
        : (data.map((d) => d.revenue).reduce((a, b) => a > b ? a : b) / 1000 * 1.2);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? (maxY / 5).clamp(1, double.infinity) : 1,
          getDrawingHorizontalLine: (v) => const FlLine(
            color: AppColors.borderLight,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (v, meta) => Text(
                '${v.toInt()}k',
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: data.length > 10 ? 2 : 1,
              getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[idx].label,
                    style: const TextStyle(
                        color: AppColors.textHint, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble().clamp(0, double.infinity),
        minY: 0,
        maxY: maxY.clamp(10, double.infinity),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.brownAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (s, p, bar, i) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.goldPrimary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.goldPrimary.withValues(alpha: 0.2),
                  AppColors.goldPrimary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                '${(s.y).toStringAsFixed(0)}k₫',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      ),
    );
  }
}

