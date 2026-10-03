import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_repository_example/core/di/configure_providers.dart';
import 'package:flutter_repository_example/data/database/dao/hero_dao.dart';
import 'package:flutter_repository_example/data/database/dao/squad_dao.dart';
import 'package:flutter_repository_example/data/database/database_mapper.dart';
import 'package:flutter_repository_example/data/network/client/api_client.dart';
import 'package:flutter_repository_example/data/network/network_mapper.dart';
import 'package:flutter_repository_example/data/repository/hero_repository.dart';
import 'package:flutter_repository_example/data/repository/hero_repository_impl.dart';

void main() {
  testWidgets('injeta a mesma implementação para interface e classe concreta', (
    tester,
  ) async {
    final dependencies = await ConfigureProviders.createDependencyTree();
    expect(dependencies.providers, hasLength(7));

    await tester.pumpWidget(
      MultiProvider(
        providers: dependencies.providers,
        child: Builder(
          builder: (context) {
            final repository = context.read<HeroRepository>();
            final concrete = context.read<HeroRepositoryImpl>();

            expect(identical(repository, concrete), isTrue);
            expect(
              identical(concrete.apiClient, context.read<ApiClient>()),
              isTrue,
            );
            expect(
              identical(concrete.networkMapper, context.read<NetworkMapper>()),
              isTrue,
            );
            expect(
              identical(
                concrete.databaseMapper,
                context.read<DatabaseMapper>(),
              ),
              isTrue,
            );
            expect(
              identical(concrete.heroDao, context.read<HeroDao>()),
              isTrue,
            );
            expect(
              identical(concrete.squadDao, context.read<SquadDao>()),
              isTrue,
            );

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}
