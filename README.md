# Compilador Telerin

Trabalho Prático de Compiladores, Engenharia de Computação, IFF Campus Bom Jesus do Itabapoana.

Compilador da linguagem Telerin 1.0 para Arduino Mega 2560, em Java com ANTLR 4.13.2.

## Estrutura

```text
src/main/antlr4/br/edu/iff/telerin/
    TelerinLexer.g4       gramática léxica
    TelerinParser.g4      gramática sintática
src/main/java/br/edu/iff/telerin/
    Main.java             roda o lexer e o parser
    ColetorErros.java     imprime os erros
    EstrategiaErros.java  mensagens de erro sintático em português
    ArvoreSintatica.java  imprime a árvore sintática
src/main/resources/exemplo.tel   exemplo usado sem argumentos
testes/lexico/            testes da análise léxica
testes/sintatico/         testes da análise sintática
```

## Compilar e executar

Requisitos: JDK 20+ e Maven.

```bash
mvn clean package
java -jar target/telerin.jar testes/sintatico/validos/03_funcoes.tel            # árvore indentada
java -jar target/telerin.jar --lisp testes/sintatico/validos/03_funcoes.tel     # árvore em uma linha
java -jar target/telerin.jar --tokens testes/lexico/validos/01_programa_ola.tel # só os tokens
sh testes/sintatico/rodar.sh                                                     # todos os testes sintáticos
```

Os erros saem como `arquivo:linha:coluna: erro léxico: descrição` ou `... erro sintático: descrição`. Se houver erro léxico, o parser não é executado.

| Código de saída | Significado |
|---|---|
| 0 | sem erros |
| 1 | erro de leitura, léxico ou sintático |
| 2 | uso incorreto |

## Precedência das expressões

| Nível | Regra | Operadores | Associatividade |
|---|---|---|---|
| 1 (menor) | `expressaoOu` | `heco_ye` | esquerda |
| 2 | `expressaoE` | `ye` | esquerda |
| 3 | `expressaoRelacional` | `<` `<=` `>` `>=` `==` `!=` | sem encadeamento |
| 4 | `expressaoAditiva` | `+` `-` | esquerda |
| 5 | `expressaoMultiplicativa` | `*` `/` `%` | esquerda |
| 6 | `expressaoUnaria` | `abá` `-` | direita |
| 7 (maior) | `expressaoPrimaria` | literais, nomes, chamadas, vetores, leituras, parênteses | - |

`a < b < c` é erro sintático. Erros de tipo, escopo e faixa de valores ficam para a análise semântica, então esses programas passam pelo parser (`testes/sintatico/semanticos/`).
