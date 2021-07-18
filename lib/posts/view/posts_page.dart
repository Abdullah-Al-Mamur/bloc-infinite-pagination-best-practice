import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_freezed_pagination/posts/bloc/post_bloc.dart';
import 'package:flutter_bloc_freezed_pagination/posts/widgets/post_list.dart';
import 'package:http/http.dart' as http;

class PostsPage extends StatefulWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: BlocProvider<PostBloc>(
        create: (_) => PostBloc(httpClient: http.Client())..add(PostFetched()),
        child: const PostList(),
      ),
    );
  }
}
