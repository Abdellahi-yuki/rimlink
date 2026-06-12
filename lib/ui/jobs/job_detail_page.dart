import 'package:flutter/material.dart';
import 'package:rimlink/models/data_models.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailPage extends StatefulWidget {
  final Job job;
  final bool isSavedInitial;

  const JobDetailPage({super.key, required this.job, required this.isSavedInitial});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  final SupabaseService _supabaseService = SupabaseService();
  late bool _isSaved;

  String? get currentUserId => _supabaseService.currentUserId;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSavedInitial;
  }

  void _editJob() {
    final titleController = TextEditingController(text: widget.job.title);
    final companyController = TextEditingController(text: widget.job.company);
    final locationController = TextEditingController(text: widget.job.location);
    final descriptionController = TextEditingController(text: widget.job.description);
    final applyLinkController = TextEditingController(text: widget.job.applyLink);
    bool isPromoted = widget.job.isPromoted;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Job Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (e.g., Remote, New York, NY)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Job Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: applyLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Apply Link (URL)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isPromoted,
                      onChanged: (val) => setState(() => isPromoted = val ?? false),
                    ),
                    const Text('Promoted Job'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
                    'is_easy_apply': false,
                  };

                  try {
                    await _supabaseService.updateJob(widget.job.id, jobData);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Job updated successfully!')),
                      );
                      setState(() {}); // Refresh UI
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating job: $e')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _applyForJob() {
    if (widget.job.applyLink.isNotEmpty) {
      // Open the apply link in a browser
      // ignore: deprecated_member_use
      launch(widget.job.applyLink);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No application link provided.')),
      );
    }
  }

  Future<void> _toggleSave() async {
    final oldState = _isSaved;
    setState(() => _isSaved = !oldState);
    
    try {
      await _supabaseService.toggleSaveJob(widget.job.id, oldState);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isSaved ? 'Job saved!' : 'Job removed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaved = oldState);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Job Description', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, color: _isSaved ? Colors.black : Colors.grey),
            onPressed: _toggleSave,
          ),
          if (widget.job.posterId == currentUserId)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  _editJob();
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete job'),
                      content: const Text('Are you sure you want to delete this job?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _supabaseService.deleteJob(widget.job.id);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Job deleted successfully')),
                      );
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              color: Colors.accents[widget.job.company.length % Colors.accents.length],
              child: Center(
                child: Text(
                  widget.job.company.substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.job.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.job.company, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(widget.job.location, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyForJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text(
                      'Apply now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _toggleSave,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(_isSaved ? 'Saved' : 'Save', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('About the job', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              widget.job.description.isNotEmpty 
                  ? widget.job.description 
                  : 'Job description not provided.',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
