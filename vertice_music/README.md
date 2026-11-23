# VÉRTICE MUSIC

**Slogan:** *Sua música. Seu universo.*

Aplicativo Android completo de streaming musical desenvolvido em **Flutter & Dart**, com modo visitante (sem cadastro, login ou senha obrigatórios), interface escura com roxo neon (`#090711`, `#151226`, `#922CFF`, `#C987FF`, `#30264C`) e integração com fontes musicais abertas e licenciadas.

## Arquitetura e Módulos

- `lib/core/` — Controle central de estado (`VerticeAppController`) e inicialização condicional do Firebase.
- `lib/models/` — Modelos de domínio (`Track`, `UserPlaylist`, `GuestPreferences`, `RepeatModeType`).
- `lib/repositories/` — Repositórios de catálogo e persistência local (`SharedPreferences`).
- `lib/catalog/` — Camada extensível `MusicSourceProvider` (`OpenSeedProvider`, `ArchiveApiProvider`).
- `lib/player/` — Serviço de reprodução online (`AudioPlayerService`) com verificação de conectividade e tratamento de erros.
- `lib/screens/` — Splash Screen, Início, Explorar, Player Musical em tela cheia, Biblioteca e Perfil Visitante.
- `lib/widgets/` — Logotipo original, cards de faixa, mini-player e componentes reutilizáveis.
- `lib/theme/` — Paleta oficial e tema Material 3 do **VÉRTICE MUSIC**.

## Compilação via GitHub Actions

O workflow `.github/workflows/build-apk.yml` roda em `ubuntu-latest` e executa:
1. Checkout do repositório
2. Setup do JDK 17
3. Setup do Flutter SDK (`stable`)
4. `flutter pub get`
5. `flutter analyze`
6. `flutter test`
7. `flutter build apk --release`
8. Upload do artefato `app-release.apk` (`vertice-music-release-apk`)

## Documentação das Integrações Musicais

1. **OpenSeedProvider (`assets/data/open_catalog.json`)**: Catálogo curado com faixas abertas/licenciadas (`CC0`, `CC-BY 4.0`, `CC-BY-SA 4.0`) e streams de áudio ativos para testes imediatos e reprodução contínua.
2. **ArchiveApiProvider (`https://archive.org/advancedsearch.php`)**: Consulta pública ao acervo de áudio aberto do Internet Archive (`mediatype:(audio) AND format:(MP3)`), respeitando limites de requisição e mapeando cada faixa para o modelo `Track`.
3. **Expansão de novas fontes**: Implemente `MusicSourceProvider` e registre na lista de provedores em `CatalogRepository` sem alterar as telas.
