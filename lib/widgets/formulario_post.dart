import 'package:flutter/material.dart';
import 'package:prova/dados/post.dart';

class FormularioPost extends StatefulWidget {
  final Post? post;
  final Function(Post) onSubmit;

  FormularioPost({this.post, required this.onSubmit});

  @override
  _FormularioPostState createState() => _FormularioPostState();
}

class _FormularioPostState extends State<FormularioPost> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _bodyController.text = widget.post!.body;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final String title = _titleController.text;
    final String body = _bodyController.text;

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, preencha todos os campos.'),
        ),
      );
      return;
    }

    Post post;

    if (widget.post == null) {
      post = Post(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: 1,
        title: title,
        body: body,
      );
    } else {
      post = Post(
        id: widget.post!.id,
        userId: widget.post!.userId,
        title: title,
        body: body,
      );
    }

    widget.onSubmit(post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'Adicionar Poste' : 'Editar Poste'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Conteúdo',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _submitForm();
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
