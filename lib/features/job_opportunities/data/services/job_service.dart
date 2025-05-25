import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/ssl_config.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/api_exception.dart';
import '../models/job_model.dart';

/// Service for handling job opportunities-related API requests
class JobService {
  static const String baseUrl = 'http://172.16.15.229/api';
  final ApiClient _apiClient;

  JobService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(
          baseUrl: baseUrl,
          allowSelfSignedCertificates: SslConfig.shouldAllowSelfSignedCertificates(),
        );

  /// Map app language to API language code
  String getLanguageHeader(String appLanguage) {
    switch (appLanguage.toLowerCase()) {
      case 'english':
        return 'en';
      case 'persian':
        return 'dr';
      case 'uzbek':
        return 'uz';
      case 'pashto':
      default:
        return 'pa'; // Default to Pashto
    }
  }

  /// Get all job opportunities
  Future<JobResponse> getJobs({String? currentLanguage}) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint: 'vacancies',
        converter: (data) => data as Map<String, dynamic>,
        language: currentLanguage,
      );

      return JobResponse.fromJson(response);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  /// Get details of a specific job by UUID
  Future<JobItem> getJobDetail(String uuid, {String? currentLanguage}) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint: 'vacancies/$uuid',
        converter: (data) => data as Map<String, dynamic>,
        language: currentLanguage,
      );

      // Parse the single job response
      final jobData = response['data'] as Map<String, dynamic>;
      return JobItem.fromJson(jobData);
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  /// Get details of a specific job by ID (fallback method)
  Future<JobItem> getJobDetailById(int id, {String? currentLanguage}) async {
    try {
      // First try to get all jobs and find the specific one
      final response = await getJobs(currentLanguage: currentLanguage);

      // Try to find the job in the response
      final job = response.data.firstWhere(
        (job) => job.id == id,
        orElse: () => throw ApiException(
          message: 'Job not found with ID: $id',
          code: 'not_found',
          statusCode: 404,
        ),
      );

      return job;
    } catch (e) {
      throw ApiException.fromError(e);
    }
  }

  /// Search jobs by query (local search since API doesn't support search)
  List<JobItem> searchJobsLocally(String query, List<JobItem> jobs, String currentLanguage) {
    if (query.isEmpty) return jobs;

    final lowerQuery = query.toLowerCase();

    return jobs.where((job) {
      final title = job.getTitle(currentLanguage)?.toLowerCase() ?? '';
      final description = job.getDescription(currentLanguage)?.toLowerCase() ?? '';
      final type = job.type?.toLowerCase() ?? '';
      final status = job.status?.toLowerCase() ?? '';

      return title.contains(lowerQuery) ||
             description.contains(lowerQuery) ||
             type.contains(lowerQuery) ||
             status.contains(lowerQuery);
    }).toList();
  }

  /// Filter jobs by status
  List<JobItem> filterJobsByStatus(List<JobItem> jobs, String status) {
    return jobs.where((job) => job.status?.toLowerCase() == status.toLowerCase()).toList();
  }

  /// Filter jobs by type
  List<JobItem> filterJobsByType(List<JobItem> jobs, String type) {
    return jobs.where((job) => job.type?.toLowerCase() == type.toLowerCase()).toList();
  }

  /// Filter active jobs (not expired)
  List<JobItem> filterActiveJobs(List<JobItem> jobs) {
    return jobs.where((job) => job.isActive).toList();
  }

  /// Sort jobs by announcement date (newest first)
  List<JobItem> sortJobsByDate(List<JobItem> jobs, {bool ascending = false}) {
    final sortedJobs = List<JobItem>.from(jobs);
    sortedJobs.sort((a, b) {
      final dateA = DateTime.tryParse(a.announcementDate ?? '') ?? DateTime(1970);
      final dateB = DateTime.tryParse(b.announcementDate ?? '') ?? DateTime(1970);
      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    return sortedJobs;
  }
}

// Provider for JobService
final jobServiceProvider = Provider<JobService>((ref) {
  return JobService();
});
