# Agência de Heróis

Aplicativo Flutter do trabalho de Desenvolvimento Móvel. Usa a arquitetura do
`flutter_repository_example`: **UI → Repository → API/SQLite**. O estado das
telas fica em `StatefulWidget` e `setState()`. `Provider` fornece as
dependências; navegação usa `Navigator.push` e `MaterialPageRoute`.

## Executar

1. Instale Flutter e Node.js. Na raiz do projeto, rode `flutter pub get`.
2. Inicie a API local: `npx json-server server/db.json --port 3000`.
3. Inicie um Android Emulator e rode `flutter run`.

O emulador acessa a API em `http://10.0.2.2:3000`. Os dados originais estão em
`server/original/all.json`; `server/db.json` expõe `/heroes`.

## Funcionalidades

- **Agentes:** catálogo paginado, cache SQLite e detalhes completos.
- **Contrato Diário:** mesmo herói durante o dia, salvo em
  `SharedPreferences`; recrutamento sem duplicatas e limite de 15 agentes.
- **Meu Esquadrão:** lista, melhor atributo e dispensa com confirmação.
- **Missões:** exigem cinco agentes; sorteiam 3–5 rounds. Cada round sorteia
  atributo e inimigo fora do esquadrão. Cada agente participa uma vez.
  A comparação gera vitória, derrota ou empate. Vitória em mais da metade dos
  rounds concede `+1` aleatório a um agente vencedor, salvo no SQLite.

O cache permite consultar **heróis já carregados** sem a API. Imagens remotas
podem mostrar o ícone de substituição quando não estiverem em cache.

## Testar

Execute `flutter test` e `flutter analyze`.

Teste manual offline:

1. Com `json-server` ligado, abra Agentes, role páginas e veja detalhes.
2. Feche o aplicativo e pare o servidor.
3. Abra novamente e confira Agentes, detalhes, Contrato Diário, Esquadrão e
   Missões. Só páginas/heróis já carregados estarão disponíveis.

## Roteiro curto para apresentação

1. Mostre `ConfigureProviders`: cria API, mappers, DAOs e `HeroRepositoryImpl`.
2. Mostre `HeroRepository`: a UI conhece a interface, não o banco.
3. Mostre `HeroRepositoryImpl.getHeroes`: lê o cache, consulta a API quando
   necessário e guarda heróis no SQLite. `getDailyHero` usa
   `SharedPreferences` para data e ID.
4. Mostre `MissionPage`: sorteios e placar ficam no estado da tela; só o bônus
   é persistido com `updateHero`.
5. Demonstre catálogo online e reabra o app com servidor desligado para mostrar
   o cache. Explique que imagens remotas dependem do cache da biblioteca.
