# Implementação do catálogo aberto

- Removidas as seis faixas demonstrativas fictícias.
- O catálogo agora consulta gravações reais do Internet Archive.
- Cada item é verificado em `/metadata/{identifier}`.
- Só são aceitos CC0, Public Domain Mark, CC BY, CC BY-SA e CC BY-ND.
- Licenças NC e itens sem licença verificável são descartados.
- O arquivo MP3 é selecionado na lista de arquivos do item; o app não presume que o nome do MP3 seja igual ao identificador.
- Duração é lida dos metadados quando disponível.
- URL da licença e página original são preservadas nos dados da faixa.
- A splash screen permanece visível durante a inicialização e a primeira consulta ao catálogo.
