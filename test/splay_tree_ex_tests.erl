-module(splay_tree_ex_tests).

-include_lib("eunit/include/eunit.hrl").

entries() ->
    [{forth, 100},
     {erlang, 10},
     {java, 123},
     {lisp, 3},
     {ruby, 3},
     {python, 30},
     {lisp, 20},
     {java, 0}].

sorted_unique_entires() ->
    [{erlang,10},
     {forth,100},
     {java,0},
     {lisp,20},
     {python,30},
     {ruby,3}].

store_test() ->
    Tree0 = splay_tree_ex:new(),
    ?assertEqual(0, splay_tree_ex:size(Tree0)),

    Tree1 = splay_tree_ex:store(lisp, 3, Tree0),
    ?assertEqual(1, splay_tree_ex:size(Tree1)),

    ?assertMatch({ok, 3}, splay_tree_ex:lookup(lisp, Tree1)).

from_list_test() ->
    Input = entries(),
    Expected = sorted_unique_entires(),

    Tree = splay_tree_ex:from_list(Input),
    ?assertEqual(Expected, splay_tree_ex:to_list(Tree)).

find_test() ->
    ?assertMatch({error, _}, splay_tree_ex:find(erlang, splay_tree_ex:new())),

    Tree0 = splay_tree_ex:from_list(entries()),

    ?assertMatch({{ok, 10}, _}, splay_tree_ex:find(erlang, Tree0)),
    {{ok, _}, Tree1} = splay_tree_ex:find(erlang, Tree0),

    ?assertMatch({error, _}, splay_tree_ex:find(scala, Tree1)),
    {error, Tree2} = splay_tree_ex:find(scala, Tree1),

    ?assertMatch({{ok, 30}, _}, splay_tree_ex:find(python, Tree2)),
    {{ok, _}, Tree3} = splay_tree_ex:find(python, Tree2),
    io:format("~w\n", [Tree2]),
    io:format("~w", [Tree3]),

    ?assertEqual(sorted_unique_entires(), splay_tree_ex:to_list(Tree3)).

find_largest_test_() ->
    [
     {"最大の要素を検索する",
      fun () ->
              Tree = splay_tree_ex:from_list([{5,5}, {1,1}, {3,3}]),
              ?assertMatch({{ok,5,5}, _}, splay_tree_ex:find_largest(Tree))
      end},
     {"空の場合",
      fun () ->
              Empty = splay_tree_ex:new(),
              ?assertEqual({error, Empty}, splay_tree_ex:find_largest(Empty))
      end},
     {"find関数とは性能を除いて同じ挙動(木の形)となる",
      fun () ->
              T = splay_tree_ex:from_list([{N, N} || N <- lists:seq(5, 1, -1)]),
              ?assertEqual(element(2, splay_tree_ex:find(5, T)),
                           element(2, splay_tree_ex:find_largest(T)))
      end}
    ].

find_smallest_test_() ->
    [
     {"最小の要素を検索する",
      fun () ->
              Tree = splay_tree_ex:from_list([{5,5}, {1,1}, {3,3}]),
              ?assertMatch({{ok,1,1}, _}, splay_tree_ex:find_smallest(Tree))
      end},
     {"空の場合",
      fun () ->
              Empty = splay_tree_ex:new(),
              ?assertEqual({error, Empty}, splay_tree_ex:find_smallest(Empty))
      end},
     {"find関数とは性能を除いて同じ挙動(木の形)となる",
      fun () ->
              T = splay_tree_ex:from_list([{N, N} || N <- lists:seq(1, 5)]),
              ?assertEqual(element(2, splay_tree_ex:find(1, T)),
                           element(2, splay_tree_ex:find_smallest(T)))
      end}
    ].

take_largest_test_() ->
    [
     {"最大の要素から順に取り出す",
      fun () ->
              Tree0 = splay_tree_ex:from_list([{5,5}, {1,1}, {3,3}]),

              {{ok, Key1, Val1}, Tree1} = splay_tree_ex:take_largest(Tree0),
              ?assertEqual({5,5}, {Key1, Val1}),

              {{ok, Key2, Val2}, Tree2} = splay_tree_ex:take_largest(Tree1),
              ?assertEqual({3,3}, {Key2, Val2}),

              {{ok, Key3, Val3}, Tree3} = splay_tree_ex:take_largest(Tree2),
              ?assertEqual({1,1}, {Key3, Val3}),

              ?assertMatch({error, _}, splay_tree_ex:take_largest(Tree3))
      end}
    ].

take_smallest_test_() ->
    [
     {"最小の要素から順に取り出す",
      fun () ->
              Tree0 = splay_tree_ex:from_list([{5,5}, {1,1}, {3,3}]),

              {{ok, Key1, Val1}, Tree1} = splay_tree_ex:take_smallest(Tree0),
              ?assertEqual({1,1}, {Key1, Val1}),

              {{ok, Key2, Val2}, Tree2} = splay_tree_ex:take_smallest(Tree1),
              ?assertEqual({3,3}, {Key2, Val2}),

              {{ok, Key3, Val3}, Tree3} = splay_tree_ex:take_smallest(Tree2),
              ?assertEqual({5,5}, {Key3, Val3}),

              ?assertMatch({error, _}, splay_tree_ex:take_smallest(Tree3))
      end}
    ].

lookup_test() ->
    Tree0 = splay_tree_ex:from_list(entries()),

    ?assertMatch({ok, 10}, splay_tree_ex:lookup(erlang, Tree0)),
    ?assertMatch(error,    splay_tree_ex:lookup(scala, Tree0)),
    ?assertMatch({ok, 30}, splay_tree_ex:lookup(python, Tree0)),

    ?assertEqual(sorted_unique_entires(), splay_tree_ex:to_list(Tree0)).

get_value_test() ->
    Tree0 = splay_tree_ex:from_list(entries()),

    ?assertMatch(10,   splay_tree_ex:get_value(erlang, Tree0, none)),
    ?assertMatch(none, splay_tree_ex:get_value(scala, Tree0, none)),
    ?assertMatch(30,   splay_tree_ex:get_value(python, Tree0, none)),

    ?assertEqual(sorted_unique_entires(), splay_tree_ex:to_list(Tree0)).

erase_test() ->
    Tree0 = splay_tree_ex:from_list(entries()),
    InitialSize = length(sorted_unique_entires()),
    ?assertEqual(InitialSize, splay_tree_ex:size(Tree0)),

    Tree1 = splay_tree_ex:erase(erlang, Tree0),
    ?assertEqual(InitialSize-1, splay_tree_ex:size(Tree1)),
    ?assertEqual(error, splay_tree_ex:lookup(erlang, Tree1)),

    Tree2 = splay_tree_ex:erase(scala, Tree1),
    ?assertEqual(InitialSize-1, splay_tree_ex:size(Tree2)),

    Tree3 = splay_tree_ex:erase(python, Tree2),
    ?assertEqual(InitialSize-2, splay_tree_ex:size(Tree3)),
    ?assertEqual(error, splay_tree_ex:lookup(python, Tree3)),

    Tree4 =
        lists:foldl(fun ({Key, _}, AccTree0) ->
                            AccTree1 = splay_tree_ex:erase(Key, AccTree0),
                            ?assertEqual(error, splay_tree_ex:lookup(Key, AccTree1)),
                            AccTree1
                    end,
                    Tree0,
                    sorted_unique_entires()),
    ?assertEqual(0, splay_tree_ex:size(Tree4)).

update4_test() ->
    Tree0 = splay_tree_ex:from_list(entries()),
    Tree1 =
        lists:foldl(fun ({Key, Value}, AccTree0) ->
                            UpdateFn = fun (V) -> {V, V} end,
                            AccTree1 = splay_tree_ex:update(Key, UpdateFn, undefined, AccTree0),
                            ?assertEqual({ok, {Value, Value}}, splay_tree_ex:lookup(Key, AccTree1)),
                            AccTree1
                    end,
                    Tree0,
                    sorted_unique_entires()),

    Expected = [{K,{V,V}} || {K,V} <- sorted_unique_entires()],
    ?assertEqual(Expected, splay_tree_ex:to_list(Tree1)),

    Tree2 = splay_tree_ex:update(scala, fun (V) -> V end, undefined, Tree1),
    ?assertEqual({ok, undefined}, splay_tree_ex:lookup(scala, Tree2)).

update3_test() ->
    Tree0 = splay_tree_ex:from_list(entries()),
    ?assertEqual(error, splay_tree_ex:update(scala, fun (_) -> 300 end, Tree0)),

    {ok, Tree1} = splay_tree_ex:update(lisp, fun (_) -> 300 end, Tree0),
    ?assertEqual({ok, 300}, splay_tree_ex:lookup(lisp, Tree1)).

filter_test() ->
    Tree0 = splay_tree_ex:from_list(entries()),

    OddTree = splay_tree_ex:filter(fun (_, V) -> V rem 2 =:= 1 end,
                                 Tree0),
    Expected = [{K,V} || {K,V} <- sorted_unique_entires(), V rem 2 =:= 1],

    ?assertEqual(Expected, splay_tree_ex:to_list(OddTree)).

foldl_test() ->
    TreeSum = splay_tree_ex:foldl(fun (_, V, Sum) -> V + Sum end,
                              0,
                               splay_tree_ex:from_list(entries())),

    ListSum = lists:foldl(fun ({_, V}, Sum) -> V + Sum end,
                          0,
                          sorted_unique_entires()),
    ?assertEqual(ListSum, TreeSum).

foldr_test() ->
    TreeSum = splay_tree_ex:foldr(fun (_, V, Sum) -> V + Sum end,
                              0,
                               splay_tree_ex:from_list(entries())),

    ListSum = lists:foldr(fun ({_, V}, Sum) -> V + Sum end,
                          0,
                          sorted_unique_entires()),
    ?assertEqual(ListSum, TreeSum).

foldl_while_test() ->
    TreeSum = splay_tree_ex:foldl_while(fun (_, V, Sum) -> {Sum < 5, V + Sum} end,
                                     0,
                                     splay_tree_ex:from_list(entries())),

    {_, ListSum} = lists:foldl(fun (_, {Prev, Sum}) when Prev > 5 -> {Prev, Sum};
                                   ({_, V}, {_Prev, Sum}) -> {Sum, V + Sum} end,
                               {0, 0},
                               sorted_unique_entires()),
    ?assertEqual(ListSum, TreeSum).

foldr_while_test() ->
    TreeSum = splay_tree_ex:foldr_while(fun (_, V, Sum) -> {Sum < 5, V + Sum} end,
                                     0,
                                     splay_tree_ex:from_list(entries())),

    {_, ListSum} = lists:foldr(fun (_, {Prev, Sum}) when Prev > 5 -> {Prev, Sum};
                                   ({_, V}, {_Prev, Sum}) -> {Sum, V + Sum} end,
                               {0, 0},
                               sorted_unique_entires()),
    ?assertEqual(ListSum, TreeSum).

map_test() ->
    Tree = splay_tree_ex:map(fun (K, V) -> {K, V} end,
                          splay_tree_ex:from_list(entries())),

    Expected = [{K, {K, V}} || {K,V} <- sorted_unique_entires()],

    ?assertEqual(Expected, splay_tree_ex:to_list(Tree)).

large_entries_test() ->
    Entries = dict:to_list(
                dict:from_list(
                  [{rand:uniform(), N} || N <- lists:seq(1, 10000)])),

    Tree = splay_tree_ex:from_list(Entries),

    lists:foreach(fun ({Key, Value}) ->
                          ?assertEqual({ok,Value}, splay_tree_ex:lookup(Key, Tree))
                  end,
                  Entries),

    EmptyTree = lists:foldl(fun ({Key, _}, AccTree) ->
                                    splay_tree_ex:erase(Key, AccTree)
                            end,
                            Tree,
                            Entries),
    ?assertEqual(0, splay_tree_ex:size(EmptyTree)).

equal_test() ->
    Tree = splay_tree_ex:from_list([{1.0, one}]),
    ?assertMatch({ok, one}, splay_tree_ex:lookup(1, Tree)).

split_test_() ->
    [
     {"指定したキーの位置で分割する",
      fun () ->
              List0 = [{1, a}, {2, b}, {3, c}, {4, d}, {5, e}],
              Tree0 = splay_tree_ex:from_list(List0),

              lists:foreach(
                fun (N) ->
                        {ListLeft, ListRight} = lists:split(N-1, List0),
                        {TreeLeft, TreeRight} = splay_tree_ex:split(N, Tree0),
                        ?assertEqual(ListLeft, splay_tree_ex:to_list(TreeLeft)),
                        ?assertEqual(ListRight, splay_tree_ex:to_list(TreeRight))
                end,
                lists:seq(1, length(List0)))
      end},
     {"空のツリーを分割した場合",
      fun () ->
              Empty = splay_tree_ex:new(),
              ?assertEqual({Empty, Empty}, splay_tree_ex:split(key, Empty))
      end},
     {"指定したキーが存在しない場合",
      fun () ->
              List0 = [{1, a}, {2, b}, {3, c}],
              Tree0 = splay_tree_ex:from_list(List0),

              {TreeLeft, TreeRight} = splay_tree_ex:split(2.5, Tree0),
              ?assertEqual([{1, a}, {2, b}], splay_tree_ex:to_list(TreeLeft)),
              ?assertEqual([{3, c}], splay_tree_ex:to_list(TreeRight))
      end}
    ].

find_lower_bound_test_() ->
    [
     {"空のツリーが対象の場合",
      fun () ->
              Empty = splay_tree_ex:new(),
              ?assertEqual({error, Empty}, splay_tree_ex:find_lower_bound(key, Empty))
      end},
     {"キーと等しいか、より大きな最初の要素を検索",
      fun () ->
              List = [{1, a}, {2, b}, {3, c}, {4, d}, {5, e}],
              Tree0 = splay_tree_ex:from_list(List),

              {{ok, 1, a}, Tree1} = splay_tree_ex:find_lower_bound(0, Tree0),
              {{ok, 2, b}, Tree2} = splay_tree_ex:find_lower_bound(2, Tree1),
              {{ok, 3, c}, Tree3} = splay_tree_ex:find_lower_bound(2.5, Tree2),
              {error,      Tree4} = splay_tree_ex:find_lower_bound(5.1, Tree3),
              {{ok, 5, e},_Tree5} = splay_tree_ex:find_lower_bound(4.9, Tree4)
      end}
    ].

find_upper_bound_test_() ->
    [
     {"空のツリーが対象の場合",
      fun () ->
              Empty = splay_tree_ex:new(),
              ?assertEqual({error, Empty}, splay_tree_ex:find_upper_bound(key, Empty))
      end},
     {"キーより大きな最初の要素を検索",
      fun () ->
              List = [{1, a}, {2, b}, {3, c}, {4, d}, {5, e}],
              Tree0 = splay_tree_ex:from_list(List),

              {{ok, 1, a}, Tree1} = splay_tree_ex:find_upper_bound(0, Tree0),
              {{ok, 3, c}, Tree2} = splay_tree_ex:find_upper_bound(2, Tree1),
              {{ok, 3, c}, Tree3} = splay_tree_ex:find_upper_bound(2.5, Tree2),
              {error,      Tree4} = splay_tree_ex:find_upper_bound(5.1, Tree3),
              {error,      Tree5} = splay_tree_ex:find_upper_bound(5,   Tree4),
              {{ok, 5, e},_Tree6} = splay_tree_ex:find_upper_bound(4.9, Tree5)
      end}
    ].

index_test() ->
    ShuffledList = [I || {_,I} <- lists:sort([{rand:uniform(),K} || K <- lists:seq(1,100)])],
    Entries = [{I/2.0, I} || I <- ShuffledList],
    Tree0 = splay_tree_ex:from_list(Entries),

    {{ok, 30},  Tree1} = splay_tree_ex:index(15.0,   Tree0),
    {{ok, 49},  Tree2} = splay_tree_ex:index(24.5, Tree1),
    {error,     Tree3} = splay_tree_ex:index(51.0,   Tree2),

    {{ok,15.5, 31},  Tree4} = splay_tree_ex:at(31,  Tree3),
    {{ok,50.0, 100}, Tree5} = splay_tree_ex:at(100, Tree4),
    {error,         _Tree6} = splay_tree_ex:at(101, Tree5).

update_size_test() ->
    List = [{1, a}, {2, b}, {3, c}, {4, d}, {5, e}],
    Tree0 = splay_tree_ex:from_list(List),
    5 = splay_tree_ex:size(Tree0),
    {5, Tree1} = splay_tree_ex:update_size(Tree0),
    {5, Tree1} = splay_tree_ex:update_size(Tree1).

foldl_cache_test() ->
    Fn = fun(_, V, Acc) -> [V | Acc] end,

    {0, _} = splay_tree_ex:foldl_cache(Fn, 0, splay_tree_ex:new()),

    Tree0 = splay_tree_ex:from_list(entries()),
    Expected = lists:foldl(fun({_, V}, Acc) -> [V | Acc] end, [], sorted_unique_entires() ),

    {Expected,  Tree1} = splay_tree_ex:foldl_cache(Fn, [], Tree0),
    {Expected,  Tree1} = splay_tree_ex:foldl_cache(Fn, [], Tree1),
    {_, Tree2} = splay_tree_ex:find(rand:uniform(100), Tree1),
    {Expected,  _} = splay_tree_ex:foldl_cache(Fn, [], Tree2).

foldr_cache_test() ->
    Fn = fun(_, V, Acc) -> [V | Acc] end,

    {0, _} = splay_tree_ex:foldr_cache(Fn, 0, splay_tree_ex:new()),

    Tree0 = splay_tree_ex:from_list(entries()),
    Expected = lists:foldr(fun({_, V}, Acc) -> [V | Acc] end, [], sorted_unique_entires() ),

    {Expected,  Tree1} = splay_tree_ex:foldr_cache(Fn, [], Tree0),
    {Expected,  Tree1} = splay_tree_ex:foldr_cache(Fn, [], Tree1),
    {_, Tree2} = splay_tree_ex:find(rand:uniform(100), Tree1),
    {Expected,  _} = splay_tree_ex:foldr_cache(Fn, [], Tree2).

reset_cache_test() ->
    Tree0 = splay_tree_ex:from_list([{a,1},{b,3},{c,5},{d,6}]),
    SumFn = fun(_, V, Acc) -> V + Acc end,
    MulFn = fun(_, V, Acc) -> V * Acc end,
    {15, Tree1} = splay_tree_ex:foldl_cache(SumFn, 0, Tree0),
    {15, Tree1} = splay_tree_ex:foldl_cache(SumFn, 0, Tree1),
    Tree2 = splay_tree_ex:reset_cache(Tree1),
    {90, _} = splay_tree_ex:foldr_cache(MulFn, 1, Tree2).
