import 'package:energy_manager_app/features/monitoring/monitoring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MonitoringPage extends HookConsumerWidget {
  const MonitoringPage({
    required this.title,
    required this.metricType,
    super.key,
  });

  final String title;
  final MetricType metricType;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        usePageController(initialPage: MonitoringPageState.index);
    final screenControllerProvider =
        monitoringPageControllerProvider(metricType);
    final asyncState = ref.watch(screenControllerProvider);

    void next() {
      ref.read(screenControllerProvider.notifier).next();
      controller.jumpToPage(MonitoringPageState.index);
    }

    void prev() {
      ref.read(screenControllerProvider.notifier).prev();
      controller.jumpToPage(MonitoringPageState.index);
    }

    Future<void> pickDate() async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        ref.read(screenControllerProvider.notifier).setDate(pickedDate);
        controller.jumpToPage(MonitoringPageState.index);
      }
    }

    useEffect(
      () {
        void listener() {
          final index = controller.page! > MonitoringPageState.index
              ? controller.page!.floor()
              : controller.page!.ceil();
          if (index == MonitoringPageState.index) return;
          if (index == MonitoringPageState.index - 1) {
            prev();
          } else if (index == MonitoringPageState.index + 1) {
            next();
          }
        }

        controller.addListener(listener);
        return () => controller.removeListener(listener);
      },
      [controller],
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(title),
      ),
      body: asyncState.when(
        data: (state) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DateBarWidget(
              selectedDate: state.selectedDate,
              onPrevious: prev,
              onNext: next,
              pickDate: pickDate,
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: state.loadedDates.length,
                itemBuilder: (context, index) => MonitoringWidget(
                  date: state.loadedDates[index],
                  metricType: metricType,
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
