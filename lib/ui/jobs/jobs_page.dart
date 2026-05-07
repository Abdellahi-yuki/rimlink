import 'package:flutter/material.dart';
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
  bool _showSavedOnly = false;
  List<Job> _allJobs = [];
  List<String> _savedJobIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
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
          SnackBar(content: Text('Error loading jobs: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayJobs = _showSavedOnly 
        ? _allJobs.where((j) => _savedJobIds.contains(j.id)).toList() 
        : _allJobs;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const SizedBox(
          height: 36,
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, size: 20, color: Colors.black54),
              hintText: 'Search jobs',
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
                              'My jobs', 
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
                            _showSavedOnly ? 'My saved jobs' : 'Recommended for you',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _showSavedOnly ? 'Jobs you have saved for later' : 'Based on your profile and search history',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          
                          if (displayJobs.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text(
                                  _showSavedOnly ? 'No saved jobs found.' : 'No jobs available at the moment.',
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
                    const Text('Easy Apply', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
