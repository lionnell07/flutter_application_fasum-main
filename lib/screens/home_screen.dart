import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_post_screen.dart'; // Import file input Anda
import 'detail_screen.dart'; // Sesuaikan dengan nama file detail screen kamu

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: const Color(
          0xFFD1C4E9,
        ), // Warna ungu muda seperti gambar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              /* Fungsi Logout */
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil data urut berdasarkan waktu terbaru
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Terjadi kesalahan'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return PostCard(data: data);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const PostCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Konversi base64 kembali ke bytes
    final imageBytes = base64Decode(data['image']);

    // Gunakan createdAt atau nilai unik lain untuk Hero Tag
    final String heroTag = data['createdAt'] ?? DateTime.now().toString();

    return InkWell(
      onTap: () {
        // Navigasi ke DetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              imageBase64: data['image'] ?? '',
              description: data['description'] ?? '',
              createdAt: data['createdAt'] != null
                  ? DateTime.parse(data['createdAt'])
                  : DateTime.now(),
              fullName: data['fullName'] ?? 'Anonymous',
              latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
              longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
              category: data['category'] ?? 'Tidak diketahui',
              heroTag: heroTag,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container untuk membungkus gambar
            Container(
              width: double.infinity,
              height:
                  220, // Sedikit lebih tinggi agar gambar landscape terlihat bagus
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: Hero(
                tag: heroTag,
                child: Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: double.infinity,
                  // PERBAIKAN: Gunakan BoxFit.cover agar gambar memenuhi background sepenuhnya
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['createdAt']?.toString().split('T')[0] ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['fullName'] ?? 'Anonymous',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
