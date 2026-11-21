# Compilador Telerin

Trabalho Prático de Compiladores, Engenharia de Computação, IFF Campus Bom Jesus do Itabapoana.

Compilador da linguagem **Telerin 1.0**, uma linguagem imperativa, estruturada e tipada inspirada na língua élfica Telerin. Os programas `.tel` serão traduzidos para Arduino C++, com alvo no **Arduino Mega 2560**. A implementação usa Java e ANTLR 4.13.2.

## Estrutura

```text
src/main/antlr4/br/edu/iff/telerin/
    TelerinLexer.g4       gramática léxica
    TelerinParser.g4      gramática sintática
src/main/java/br/edu/iff/telerin/
    Main.java             driver: lê o arquivo em UTF-8 estrito, roda lexer e parser
    ColetorErros.java     imprime erros no formato arquivo:linha:coluna
    EstrategiaErros.java  mensagens de erro sintático em português
    ArvoreSintatica.java  imprime a árvore sintática indentada
src/main/resources/exemplo.tel   programa usado quando nenhum arquivo é informado
testes/lexico/            testes válidos e com erro léxico
testes/sintatico/         testes válidos, com erro só semântico e com erro sintático
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

## Analisador sintático

`TelerinParser.g4` é um `parser grammar` com `options { tokenVocab = TelerinLexer; }`. A regra inicial é `programa`:

```text
programa : blocoHauda declaracaoGlobal* funcao* blocoMinya blocoVola EOF ;
```

- **Ordem fixa:** `hauda`, declarações globais, funções, `minya` e `vola`. O `EOF` final faz com que qualquer conteúdo depois de `vola` seja erro.
- **Blocos:** todo bloco é `cava { ... }`, com declarações locais e comandos intercalados. Não existe comando vazio `;`.
- **`hauda`:** só declarações de recurso (`leper_car led = leper(13) : dammë;`). O pino é `leper(n)` ou `leper_duinë(n)`, com `n` numeral, e o `: valor` é opcional.
- **Declarações:** constantes `glanna tipo nome = expr;`. Globais podem omitir o inicializador e locais não.
- **Tipos:** `canat` e `canat_min` com largura opcional (`<8>`, `<16>`, `<32>`), os demais tipos da seção 6, `lúmë<lúmë_min>`, tipos de recurso (para parâmetros de capacidade) e vetores `[tipo; tamanho]`.
- **Funções:** `car tipo nome(parâmetros) cava { ... }`; procedimento usa `aba_car`.
- **Comandos:**
  - atribuição a nome ou a elemento de vetor (é comando, então `x = y = 1;` é erro);
  - ações com `ela` (`pet`, `pet_lanca`, `pet_min`, `lúmë_dammë`, `car_duimë ... han id`, `car_duinë ... han id`, chamada);
  - `minya_lambë taxa;`, `auta`, `lanca;` e `vola_minya;`.
- **Controle:**
  - `né_cava` com `heco` opcional e a forma de presença `né_cava mapa han valor`;
  - `car_heco` com pelo menos um `car_min` e `heco` por último;
  - `vola_né`;
  - `vola_delia (início; condição; atualização)`, com os dois `;` obrigatórios;
  - `vola_car ... vola_né expr;`;
  - `vola_canat`.

A gramática só verifica a forma. Tipo, escopo, faixa de valores e posição de `minya_lambë` ficam para a análise semântica, então um programa com esses erros passa pelo parser (ver `testes/sintatico/semanticos/`).

### Precedência das expressões

Cada nível de precedência é uma regra, e a regra de nível mais baixo chama a do nível seguinte. Por isso, quanto mais fundo na árvore, mais cedo o operador é aplicado.

| Nível | Regra | Operadores | Associatividade |
|---|---|---|---|
| 1 (menor) | `expressaoOu` | `heco_ye` | esquerda |
| 2 | `expressaoE` | `ye` | esquerda |
| 3 | `expressaoRelacional` | `<` `<=` `>` `>=` `==` `!=` | sem encadeamento |
| 4 | `expressaoAditiva` | `+` `-` | esquerda |
| 5 | `expressaoMultiplicativa` | `*` `/` `%` | esquerda |
| 6 | `expressaoUnaria` | `abá` `-` (não existe `+` unário) | direita |
| 7 (maior) | `expressaoPrimaria` | literais, nomes, `nome[i]`, chamadas, conversões, operações sobre bits, `lúmë(n, d)`, leituras, `[a, b]`, parênteses | - |

- **Binários:** associam à esquerda pela repetição `(op operando)*`.
- **Unários:** associam à direita porque a regra chama a si mesma (`- -x`, `abá abá ok`).
- **Relacional:** usa `?` em vez de `*`, então aceita no máximo uma comparação. `a < b < c` é erro sintático; para combinar comparações, usa-se `ye`.
- **Exemplo:** em `10 + 5 * 2`, o `*` fica num nó mais profundo que o `+` e é aplicado primeiro.

### Erros sintáticos

O formato é `arquivo:linha:coluna: erro sintático: descrição`. `EstrategiaErros` reescreve em português as mensagens padrão do ANTLR e nomeia os tokens pelo texto da linguagem (`'cava'`, `';'`), não pelo nome interno. Quando qualquer início de expressão ou de tipo seria aceito, a mensagem diz só "expressão" ou "tipo".

Há dicas para dois casos comuns, a comparação encadeada e a chamada sem `ela`. A análise para no primeiro erro sintático, porque os seguintes costumam ser efeito em cascata da recuperação.

## Gerar e executar

Requisitos: JDK 20 ou superior e Maven.

```bash
mvn clean package
java -jar target/telerin.jar testes/sintatico/validos/03_funcoes.tel            # árvore indentada
java -jar target/telerin.jar --lisp testes/sintatico/validos/03_funcoes.tel     # árvore em uma linha
java -jar target/telerin.jar --tokens testes/lexico/validos/01_programa_ola.tel # só os tokens
sh testes/sintatico/rodar.sh                                                     # todos os testes sintáticos
```

O ANTLR gera as classes em `target/generated-sources/antlr4`. O jar executável, com o runtime do ANTLR incluído, fica em `target/telerin.jar`. Sem argumentos (por exemplo, com "Run" no NetBeans), o programa analisa `src/main/resources/exemplo.tel`.

Sem opção, a saída é a árvore sintática concreta: um nó por linha, indentado, com as regras pelo nome e as folhas como `TIPO 'texto'`. `--lisp` imprime a mesma árvore no formato `toStringTree` do ANTLR, o mesmo do ANTLR Lab. `--tokens` lista um token por linha (`linha:coluna TIPO 'texto'`) e não executa o parser.

Se houver erro léxico, o parser não é executado. Os erros vão para a saída de erro como `arquivo:linha:coluna: erro léxico: descrição` ou `... erro sintático: descrição`.

| Código de saída | Significado |
|---|---|
| 0 | sem erros |
| 1 | erro de leitura, léxico ou sintático |
| 2 | uso incorreto |
