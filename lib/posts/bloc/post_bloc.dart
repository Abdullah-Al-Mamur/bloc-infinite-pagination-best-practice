import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_freezed_pagination/app/utils.dart';
import 'package:flutter_bloc_freezed_pagination/posts/model/post.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

part 'post_event.dart';
part 'post_state.dart';
const _postLimit = 20;
class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState());
  final http.Client httpClient;

  @override
  Stream<PostState> mapEventToState(
    PostEvent event,
  ) async* {
    if(event is PostFetched){
      yield await _mapPostFetchedToState(state);
    }
  }

  Future<PostState> _mapPostFetchedToState(PostState state) async{
    if(state.hasReachedMax){
      return state;
    }
    try{
      if(state.status == PostStatus.initial){
        final posts = await _fetchPosts();
        return state.copyWith(
            posts: posts,
            status: PostStatus.success,
            hasReachedMax: false
        );
      }
      final posts = await _fetchPosts(state.posts.length);
      return posts.isEmpty ?
      state.copyWith(hasReachedMax: true) :
      state.copyWith(
        hasReachedMax: false,
        posts: List.of(state.posts)..addAll(posts),
        status: PostStatus.success
      );
    } on Exception{
      return state.copyWith(status: PostStatus.failure);
    }
  }


  Future<List<Post>> _fetchPosts([int startIndex = 0]) async{
    final response = await httpClient.get(
      Uri.parse('${Constants.baseURl}/posts?_start=$startIndex&_limit=$_postLimit')
    );
    if (response.statusCode == 200) {
      return postFromJson(response.body);
    }
    throw Exception('error fetching posts');
  }


}
