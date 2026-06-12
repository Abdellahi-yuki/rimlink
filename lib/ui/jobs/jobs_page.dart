import 'package:flutter/material.dart';
import 'package:rimlink/l10n/app_localizations.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:rimlink/models/data_models.dart';
import 'package:rimlink/ui/jobs/job_detail_page.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _searchController = TextEditingController();
  bool _showSavedOnly = false;
  List<Job> _allJobs = [];
  List<String> _savedJobIds = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    try {
      final jobsData = await _supabaseService.getJobs();
      final savedIds = await _supabaseService.getSavedJobIds();
      
      if (mounted) {
        setState(() {
          _allJobs = jobsData.map((m) => Job.fromMap(m)).toList();
          _savedJobIds = savedIds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingJobs}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayJobs = () {
      var jobs = _showSavedOnly
          ? _allJobs.where((j) => _savedJobIds.contains(j.id)).toList()
          : _allJobs;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        jobs = jobs.where((j) =>
            j.title.toLowerCase().contains(q) ||
            j.company.toLowerCase().contains(q) ||
            j.location.toLowerCase().contains(q)).toList();
      }
      return jobs;
    }();

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: SizedBox(
          height: 36,
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.black54),
              hintText: AppLocalizations.of(context)!.searchJobs,
              hintStyle: TextStyle(fontSize: 14),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xFFEEF3F8),
            ),
          ),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPostJobDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadJobs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top action bar
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildPillButton(
                              Icons.bookmark, 
                              AppLocalizations.of(context)!.myJobs, 
                              isActive: _showSavedOnly,
                              onTap: () {
                                setState(() {
                                  _showSavedOnly = !_showSavedOnly;
                                });
                              }
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Recommended jobs heading
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _showSavedOnly ? AppLocalizations.of(context)!.mySavedJobs : AppLocalizations.of(context)!.recommendedForYou,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _showSavedOnly ? AppLocalizations.of(context)!.jobsYouSaved : AppLocalizations.of(context)!.basedOnProfile,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          
                          if (displayJobs.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text(
                                  _showSavedOnly ? AppLocalizations.of(context)!.noSavedJobs : AppLocalizations.of(context)!.noJobsAvailable,
                                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayJobs.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final job = displayJobs[index];
                                return _buildJobCard(job);
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPillButton(IconData icon, String label, {bool isActive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green[50] : Colors.white,
          border: Border.all(color: isActive ? Colors.green : Colors.grey[400]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.green[700] : Colors.grey[800]),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? Colors.green[700] : Colors.black)),
          ],
        ),
      ),
    );
  }

  void _showPostJobDialog() {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    final applyLinkController = TextEditingController();
    bool isPromoted = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.postAJob, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.jobTitle,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.companyName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.locationPlaceholder,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.jobDescription,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: applyLinkController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.applyLink,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isPromoted,
                      onChanged: (val) => setState(() => isPromoted = val ?? false),
                    ),
                    Text(AppLocalizations.of(context)!.promotedJob),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty && 
                    companyController.text.trim().isNotEmpty &&
                    locationController.text.trim().isNotEmpty &&
                    descriptionController.text.trim().isNotEmpty &&
                    applyLinkController.text.trim().isNotEmpty) {
                  final jobData = {
                    'title': titleController.text.trim(),
                    'company': companyController.text.trim(),
                    'location': locationController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'apply_link': applyLinkController.text.trim(),
                    'is_promoted': isPromoted,
                    'is_easy_apply': false, // Disabled as per requirements
                  };

                  try {
                    await _supabaseService.postJob(jobData);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.jobPosted)),
                      );
                      _loadJobs();
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${AppLocalizations.of(context)!.errorPostingJob}: $e')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: Text(AppLocalizations.of(context)!.postJob, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    final isSaved = _savedJobIds.contains(job.id);
    
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobDetailPage(job: job, isSavedInitial: isSaved)),
        );
        _loadJobs(); // Refresh state after return
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dummy company logo
        Container(
          width: 48,
          height: 48,
          color: Colors.accents[job.company.length % Colors.accents.length],
          child: Center(
            child: Text(
              job.company.substring(0, 1),
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Job Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0A66C2)),
              ),
              const SizedBox(height: 4),
              Text(job.company, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 2),
              Text(job.location, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (job.isEasyApply) ...[
                    const Icon(Icons.description, size: 14, color: Color(0xFF0A66C2)),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context)!.easyApply, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 8),
                  ],
                  Text(job.timeAgo, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        // Save button
        IconButton(
          onPressed: () async {
            await _supabaseService.toggleSaveJob(job.id, isSaved);
            _loadJobs();
          },
          icon: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: isSaved ? Colors.black : Colors.grey,
          ),
        )
      ],
        ),
      ),
    );
  }
}
