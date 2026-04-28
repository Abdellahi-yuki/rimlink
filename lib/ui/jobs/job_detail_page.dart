import 'package:flutter/material.dart';
import 'package:rimlink/ui/jobs/jobs_page.dart';

class JobDetailPage extends StatefulWidget {
  final JobItem job;

  const JobDetailPage({super.key, required this.job});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
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
            icon: Icon(widget.job.isSaved ? Icons.bookmark : Icons.bookmark_border, color: widget.job.isSaved ? Colors.black : Colors.grey),
            onPressed: () {
              setState(() => widget.job.isSaved = !widget.job.isSaved);
            },
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
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.work, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                const Text('Full-time · Mid-Senior level', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.apartment, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                const Text('10,001+ employees · Software Development', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                const Text('See how you compare to other applicants. Try Premium', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting application form!')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      widget.job.isEasyApply ? 'Easy Apply' : 'Apply',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => widget.job.isSaved = !widget.job.isSaved);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('About the job', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              'We are looking for a highly skilled ${widget.job.title} to join our team at ${widget.job.company}. You will be responsible for building scalable application architectures and delivering visually excellent UI elements.\n\nRequirements:\n- 4+ years of professional engineering experience.\n- Familiarity with native deployment and state management solutions.\n- Passion for product-focused UI implementations.',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
