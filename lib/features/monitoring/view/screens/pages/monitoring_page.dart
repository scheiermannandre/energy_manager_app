import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MonitoringPage extends ConsumerWidget {
  const MonitoringPage({
    required this.title,
    required this.metricType,
    super.key,
  });

  final String title;
  final MetricType metricType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenControllerProvider =
        monitoringPageControllerProvider(metricType);
    final asyncState = ref.watch(screenControllerProvider);
    final screenController = ref.read(screenControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(title),
      ),
      body: asyncState.when(
        data: (state) => HookBuilder(
          builder: (context) {
            final controller =
                usePageController(initialPage: state.availableDates.length - 1);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DateBarWidget(
                  selectedDate: controller.hasClients
                      ? state.availableDates[controller.page!.round()]
                      : state.availableDates.last,
                  onPrevious: () => controller.previousPage(
                    duration: 300.milliseconds,
                    curve: Curves.easeInOut,
                  ),
                  onNext: () => controller.nextPage(
                    duration: 300.milliseconds,
                    curve: Curves.easeInOut,
                  ),
                  pickDate: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(MonitoringPageState.firstDateYear),
                      lastDate: DateTime.now().date,
                    );

                    if (pickedDate != null) {
                      final newIndex =
                          state.availableDates.indexOf(pickedDate.date);
                      if (newIndex != -1) {
                        controller.jumpToPage(newIndex);
                        screenController.preloadData(pickedDate);
                      }
                    }
                  },
                ),
                Expanded(
                  child: PageView.builder(
                    onPageChanged: (index) {
                      ref.read(screenControllerProvider.notifier).preloadData(
                            state.availableDates[index],
                          );
                    },
                    controller: controller,
                    itemCount: state.availableDates.length,
                    itemBuilder: (context, index) => MonitoringWidget(
                      date: state.availableDates[index],
                      metricType: metricType,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
