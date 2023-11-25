import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:prova/dados/post.dart';
import 'package:prova/widgets/card_post.dart';
import 'package:prova/widgets/formulario_post.dart';

const String apiUrl = 'https://jsonplaceholder.typicode.com';

class PaginaInicial extends StatefulWidget {
  @override
  _PaginaInicialState createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
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
        builder: (context) => FormularioPost(
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
        backgroundColor: Color.fromRGBO(0, 255, 34, 1),
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
                    return CardPost(
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
        backgroundColor: Color.fromRGBO(0, 255, 0, 1),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PaginaInicial(),
  ));
}
