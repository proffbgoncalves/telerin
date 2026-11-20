# Compilador Telerin

Trabalho Prático de Compiladores, Engenharia de Computação, IFF Campus Bom Jesus do Itabapoana.

Compilador da linguagem **Telerin 1.0**, uma linguagem imperativa, estruturada e tipada inspirada na língua élfica Telerin. Os programas `.tel` serão traduzidos para Arduino C++, com alvo no **Arduino Mega 2560**. A implementação usa Java e ANTLR 4.13.2.

## Estrutura

```text
src/main/antlr4/br/edu/iff/telerin/
    TelerinLexer.g4       gramática léxica
src/main/java/br/edu/iff/telerin/
    Main.java             driver: lê o arquivo em UTF-8 estrito e lista os tokens
    ColetorErros.java     imprime erros no formato arquivo:linha:coluna
src/main/resources/exemplo.tel   programa usado quando nenhum arquivo é informado
testes/lexico/            testes válidos e com erro léxico
```

## Analisador léxico

A gramática é um `lexer grammar` separado; a gramática sintática importa seus tokens com `options { tokenVocab = TelerinLexer; }`. Ela segue estas regras:

- **Palavras reservadas:** as 59 da seção 5, com os nomes de token da tabela. São declaradas antes de `ID`; no empate de tamanho vence a primeira regra, e o casamento mais longo vence sempre (`volaSensor` é `ID`).
- **Identificadores:** começam por letra Unicode ou `_` e continuam com letras, marcas combinantes, dígitos ou `_`.
- **NFC:** uma reservada digitada em NFD é reclassificada pela forma NFC, sem alterar o texto do token. `lume` não substitui `lúmë`, e `tharma_min` não substitui `þarma_min`.
- **Literais:**
  - inteiros decimais sem zero à esquerda, binários `0b` e hexadecimais `0x`;
  - `FLOAT_LITERAL` com ponto e/ou expoente;
  - strings sem quebra de linha, com os escapes `\n \r \t \" \\`.
- **Comentários e espaços:** `//`, `/* */` (sem aninhamento), espaço, tabulação, CR e LF são descartados. Um BOM inicial é aceito.
- **Posições:** linha e coluna começam em 1. CRLF, LF e CR isolado contam, cada um, como uma quebra de linha.
- **Erros léxicos:** viram tokens próprios (`ERRO_NUMERO`, `ERRO_STRING`, `ERRO_COMENTARIO`, `ERRO_CARACTERE`) e geram diagnóstico com a posição. O candidato numérico inválido é rejeitado inteiro: `0b102`, `007` e `2contador` dão um único erro.
- **UTF-8 malformado:** é erro de leitura, sem substituição silenciosa.

## Gerar e executar

Requisitos: JDK 20 ou superior e Maven.

```bash
mvn clean package
java -jar target/telerin.jar testes/lexico/validos/01_programa_ola.tel
```

O ANTLR gera as classes em `target/generated-sources/antlr4`. O jar executável, com o runtime do ANTLR incluído, fica em `target/telerin.jar`. Sem argumentos (por exemplo, com "Run" no NetBeans), o programa analisa `src/main/resources/exemplo.tel`.

A saída lista um token por linha (`linha:coluna TIPO 'texto'`). Os erros vão para a saída de erro como `arquivo:linha:coluna: erro léxico: descrição`.

| Código de saída | Significado |
|---|---|
| 0 | sem erros |
| 1 | erro de leitura ou léxico |
| 2 | uso incorreto |
