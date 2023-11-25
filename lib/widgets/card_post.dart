import 'package:flutter/material.dart';
import 'package:prova/dados/post.dart';

class CardPost extends StatelessWidget {
  final Post post;
  final Function(Post) onDelete;
  final Function(Post) onUpdate;

  const CardPost({
    Key? key,
    required this.post,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(post.body),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onUpdate(post),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDelete(post),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
