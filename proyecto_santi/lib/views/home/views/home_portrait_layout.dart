import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/home/components/home_activity_cards.dart';
import 'package:proyecto_santi/views/home/components/calendar/syncfusion_calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:flutter/gestures.dart';

class HomePortraitLayout extends StatefulWidget {
  final List<Actividad> activities;

  const HomePortraitLayout({super.key, required this.activities});

  @override
  State<HomePortraitLayout> createState() => _HomePortraitLayoutState();
}

class _HomePortraitLayoutState extends State<HomePortraitLayout> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // Tab Bar personalizado
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color.fromRGBO(26, 35, 50, 0.6)
                : const Color.fromRGBO(227, 242, 253, 0.8),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              gradient: const LinearGradient(
                colors: [Color(0xFF1976d2), Color(0xFF42A5F5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976d2).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_note_rounded, size: 18),
                    const SizedBox(width: 6),
                    const Text('Actividades'),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.activities.length}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 18),
                    SizedBox(width: 6),
                    Text('Calendario'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Tab Bar View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Lista de Actividades
              _buildActivitiesTab(isDark),
              // Tab 2: Calendario
              _buildCalendarTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesTab(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color.fromRGBO(26, 35, 50, 0.4)
                : const Color.fromRGBO(227, 242, 253, 0.6),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.08),
                offset: Offset(0, 2),
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: widget.activities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 64,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay actividades',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: widget.activities.length,
                    itemBuilder: (context, index) {
                      final actividad = widget.activities[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SizedBox(
                          height: 145, // Altura fija para cada card
                          child: ActivityCardItem(
                            actividad: actividad,
                            isDarkTheme: isDark,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 12.0),
      child: ModernSyncfusionCalendar(
        activities: widget.activities,
        countryCode: 'ES',
      ),
    );
  }
}