import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_freezed_pagination/posts/bloc/post_bloc.dart';
import 'package:flutter_bloc_freezed_pagination/posts/widgets/post_list_item.dart';

import 'bottom_loader.dart';
class PostList extends StatefulWidget {
  const PostList({Key? key}) : super(key: key);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final ScrollController _scrollController = ScrollController();
  late PostBloc _postBloc;
  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    _postBloc = context.read<PostBloc>();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state){
        switch(state.status){
          case PostStatus.failure:
            return const Center(child: Text('failed to fetch data'),);
          case PostStatus.success:
            if(state.posts.isEmpty){
              return const Center(
                child: Text('post empty'),
              );
            }
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.posts.length
                    ? const BottomLoader()
                    : PostListItem(post: state.posts[index]);
              },
              itemCount: state.hasReachedMax
                  ? state.posts.length
                  : state.posts.length + 1,
              controller: _scrollController,
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _onScroll() {
    if (_isBottom) _postBloc.add(PostFetched());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isBottom {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      return true;
    }

    return false;
    // if (!_scrollController.hasClients) return false;
    // final maxScroll = _scrollController.position.maxScrollExtent;
    // final currentScroll = _scrollController.offset;
    // return currentScroll >= (maxScroll * 0.9);
  }
}
