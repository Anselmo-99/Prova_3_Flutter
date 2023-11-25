import 'package:flutter/material.dart';
import 'package:prova/pagina_inicial.dart';

void main() {
  runApp(MaterialApp(
    home: PaginaInicial(),
  ));
}



/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

const String apiUrl = 'https://jsonplaceholder.typicode.com';

class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final Function(Post) onDelete;
  final Function(Post) onUpdate;

  const PostCard({
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
            SizedBox(height: 8),
            Text(post.body),
            SizedBox(height: 8),
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

class PostForm extends StatefulWidget {
  final Post? post;
  final Function(Post) onSubmit;

  PostForm({this.post, required this.onSubmit});

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
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
        title: Text(widget.post == null ? 'Adicionar Post' : 'Editar Post'),
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> _posts = [];
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final response = await http.get(Uri.parse('$apiUrl/posts'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        final List<Post> posts =
            jsonList.map((json) => Post.fromJson(json)).toList();

        setState(() {
          _posts = posts;
          _loading = false;
        });
      } else {
        throw Exception('Erro ao buscar os posts: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });

      print('Erro ao buscar os posts: $e');
    }
  }

  Future<void> _addPost(Post post) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/posts'),
        body: post.toJson(),
      );

      if (response.statusCode == 201) {
        final data = response.body;
        final Post newPost = Post.fromJson(json.decode(data));

        setState(() {
          _posts.add(newPost);
        });

        Navigator.of(context).pop();
      } else {
        throw Exception('Erro ao adicionar o post: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = true;
      });
      print('Erro ao adicionar o post: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updatePost(Post post) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/posts/${post.id}'),
        body: post.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.body;
        final Post updatedPost = Post.fromJson(json.decode(data));

        setState(() {
          _posts = _posts
              .map((p) => p.id == updatedPost.id ? updatedPost : p)
              .toList();
        });

        Navigator.of(context).pop();
      } else {
        throw Exception('Erro ao atualizar o post: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = true;
      });
      print('Erro ao atualizar o post: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deletePost(Post post) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/posts/${post.id}'));

      if (response.statusCode == 200) {
        setState(() {
          _posts.remove(post);
        });
      } else {
        throw Exception('Erro ao deletar o post: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = true;
      });
      print('Erro ao deletar o post: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _navigateToPostForm(Post? post) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostForm(
          post: post,
          onSubmit: post == null ? _addPost : _updatePost,
        ),
      ),
    );

    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prova'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _error
              ? Center(
                  child: const Text('Ocorreu um erro. Tente novamente.'),
                )
              : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return PostCard(
                      key: ValueKey(post.id),
                      post: post,
                      onDelete: _deletePost,
                      onUpdate: (updatedPost) =>
                          _navigateToPostForm(updatedPost),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToPostForm(null),
        tooltip: 'Adicionar Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}*/
