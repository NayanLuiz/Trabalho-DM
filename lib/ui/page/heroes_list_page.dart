import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero.dart' as domain;
import '../widgets/hero_card.dart';

class HeroesListPage extends StatefulWidget {
  const HeroesListPage({super.key});

  @override
  State<HeroesListPage> createState() => _HeroesListPageState();
}

class _HeroesListPageState extends State<HeroesListPage> {
  static const _pageSize = 10;

  late final PagingController<int, domain.Hero> _pagingController;

  @override
  void initState() {
    super.initState();
    final repository = context.read<HeroRepository>();
    _pagingController = PagingController<int, domain.Hero>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (page) => repository.getHeroes(page: page, limit: _pageSize),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agentes')),
      body: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, domain.Hero>(
              state: state,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<domain.Hero>(
                itemBuilder: (context, hero, index) => HeroCard(hero: hero),
                noItemsFoundIndicatorBuilder: (context) =>
                    const Center(child: Text('Nenhum agente encontrado.')),
              ),
            ),
      ),
    );
  }
}
