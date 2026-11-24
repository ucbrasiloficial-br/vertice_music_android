# VÉRTICE MUSIC

Aplicativo Android de streaming musical em Flutter, com identidade visual preta e violeta, modo visitante e catálogo online de gravações reais com licença aberta ou domínio público.

## Fonte musical

O catálogo usa o **Internet Archive**. O aplicativo consulta a busca avançada e depois os metadados individuais de cada item para localizar o arquivo MP3 real, obter a duração quando disponível e verificar a licença declarada.

Licenças aceitas pelo filtro automático:
- CC0 / Public Domain Dedication;
- Public Domain Mark;
- CC BY;
- CC BY-SA;
- CC BY-ND.

Licenças com cláusula **NC (NonCommercial)** e itens sem licença verificável são excluídos. O app guarda a URL da licença e a página de origem junto aos dados da faixa. As seis faixas fictícias e os endereços demonstrativos foram removidos.

## Abertura e carregamento

A splash screen é exibida antes do carregamento do catálogo e aguarda a inicialização real do aplicativo, com tempo mínimo para a animação da marca. O catálogo exige conexão com a internet; não há reprodução offline.

## Limitações importantes

- A disponibilidade depende da conexão e dos itens encontrados no Internet Archive.
- O filtro valida a licença declarada nos metadados, mas uma revisão individual ainda é necessária antes de distribuição comercial.
- O catálogo é dinâmico e a quantidade de faixas varia conforme a busca e os arquivos com licença compatível.
- Este ambiente não tem Flutter/Dart instalado; a compilação precisa ser validada pelo GitHub Actions.

## Compilar

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

O workflow `.github/workflows/build-apk.yml` executa análise, testes e geração do APK no GitHub Actions.
