import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';

class JobNotifier extends StateNotifier<AsyncValue<List<JobItem>>> {
  final JobService _jobService;
  final Ref _ref;

  JobNotifier(this._jobService, this._ref) : super(const AsyncLoading());

  Future<void> loadInitial() async {
    state = const AsyncLoading();
    try {
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _jobService.getJobs(currentLanguage: currentLanguage);

      // Sort jobs by announcement date (newest first)
      final sortedJobs = _jobService.sortJobsByDate(response.data);

      state = AsyncData(sortedJobs);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _jobService.getJobs(currentLanguage: currentLanguage);

      // Sort jobs by announcement date (newest first)
      final sortedJobs = _jobService.sortJobsByDate(response.data);

      state = AsyncData(sortedJobs);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      await loadInitial();
      return;
    }

    state = const AsyncLoading();

    try {
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _jobService.getJobs(currentLanguage: currentLanguage);
      final searchResults = _jobService.searchJobsLocally(query, response.data, currentLanguage);

      // Sort search results by announcement date (newest first)
      final sortedResults = _jobService.sortJobsByDate(searchResults);

      state = AsyncData(sortedResults);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> filterByStatus(String status) async {
    try {
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _jobService.getJobs(currentLanguage: currentLanguage);
      final filteredJobs = _jobService.filterJobsByStatus(response.data, status);

      // Sort filtered jobs by announcement date (newest first)
      final sortedJobs = _jobService.sortJobsByDate(filteredJobs);

      state = AsyncData(sortedJobs);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> filterByType(String type) async {
    try {
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _jobService.getJobs(currentLanguage: currentLanguage);
      final filteredJobs = _jobService.filterJobsByType(response.data, type);

      // Sort filtered jobs by announcement date (newest first)
      final sortedJobs = _jobService.sortJobsByDate(filteredJobs);

      state = AsyncData(sortedJobs);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> filterActiveJobs() async {
    try {
      final currentLanguage = _ref.read(themeNotifierProvider).currentLanguage;
      final response = await _jobService.getJobs(currentLanguage: currentLanguage);
      final activeJobs = _jobService.filterActiveJobs(response.data);

      // Sort active jobs by announcement date (newest first)
      final sortedJobs = _jobService.sortJobsByDate(activeJobs);

      state = AsyncData(sortedJobs);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Main provider for job list
final jobNotifierProvider = StateNotifierProvider<JobNotifier, AsyncValue<List<JobItem>>>((ref) {
  final jobService = ref.read(jobServiceProvider);
  return JobNotifier(jobService, ref)..loadInitial();
});

// Provider for job detail by UUID
final jobDetailProvider = FutureProvider.family<JobItem, String>((ref, jobUuid) {
  final jobService = ref.read(jobServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  return jobService.getJobDetail(jobUuid, currentLanguage: currentLanguage);
});

// Provider for job detail by ID (fallback)
final jobDetailByIdProvider = FutureProvider.family<JobItem, int>((ref, jobId) {
  final jobService = ref.read(jobServiceProvider);
  final currentLanguage = ref.read(themeNotifierProvider).currentLanguage;
  return jobService.getJobDetailById(jobId, currentLanguage: currentLanguage);
});

// Provider for search query
final jobSearchProvider = StateProvider<String>((ref) => '');

// Provider for filter status
final jobFilterStatusProvider = StateProvider<String?>((ref) => null);

// Provider for filter type
final jobFilterTypeProvider = StateProvider<String?>((ref) => null);

// Provider for active jobs only filter
final jobActiveOnlyProvider = StateProvider<bool>((ref) => false);
