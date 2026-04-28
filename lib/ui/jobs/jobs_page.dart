import 'package:flutter/material.dart';
import 'package:rimlink/ui/jobs/job_detail_page.dart';

class JobItem {
  final String id;
  final String title;
  final String company;
  final String location;
  final String timeAdded;
  final bool isPromoted;
  final bool isEasyApply;
  bool isSaved;

  JobItem({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.timeAdded,
    this.isPromoted = false,
    this.isEasyApply = false,
    this.isSaved = false,
  });
}

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  bool _showSavedOnly = false;

  final List<JobItem> _jobs = [
    JobItem(
      id: 'j1',
      title: 'Senior Flutter Engineer',
      company: 'Apposphere',
      location: 'San Francisco, CA (Remote)',
      timeAdded: '3 hours ago',
      isEasyApply: true,
    ),
    JobItem(
      id: 'j2',
      title: 'Mobile Tech Lead',
      company: 'FinTech Global',
      location: 'New York, NY (Hybrid)',
      timeAdded: '1 day ago',
      isPromoted: true,
    ),
    JobItem(
      id: 'j3',
      title: 'Android Developer',
      company: 'Streaming Co',
      location: 'Los Angeles, CA',
      timeAdded: '4 days ago',
    ),
    JobItem(
      id: 'j4',
      title: 'Full Stack Engineer, Mobile',
      company: 'Logistics Network',
      location: 'Austin, TX (Remote)',
      timeAdded: '1 week ago',
      isEasyApply: true,
      isSaved: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
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
                  const Text(
                    'Recommended for you',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Based on your profile and search history',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  
                  // Job list mapping
                  Builder(
                    builder: (context) {
                      final displayJobs = _showSavedOnly ? _jobs.where((j) => j.isSaved).toList() : _jobs;
                      
                      if (displayJobs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('No saved jobs found.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ),
                        );
                      }
                      
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayJobs.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final job = displayJobs[index];
                          return _buildJobCard(job);
                        },
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildJobCard(JobItem job) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobDetailPage(job: job)),
        );
        setState(() {}); // Reflect saved state changes from details page
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
              if (job.isPromoted) ...[
                const Text('Promoted', style: TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 2),
              ],
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
                  Text(job.timeAdded, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        // Save button
        IconButton(
          onPressed: () {
            setState(() {
              job.isSaved = !job.isSaved;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(job.isSaved ? 'Job saved to your list' : 'Job removed from saved list')),
              );
            });
          },
          icon: Icon(
            job.isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: job.isSaved ? Colors.black : Colors.grey,
          ),
        )
      ],
        ),
      ),
    );
  }
}
