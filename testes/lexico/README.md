# Testes léxicos

Os arquivos `validos/06`, `validos/07` e `invalidos/07` a `09` têm bytes invisíveis ou inválidos e são gerados por `gerar_especiais.sh`.

```bash
java -jar target/telerin.jar --tokens testes/lexico/validos/02_palavras_reservadas.tel
```

## Válidos

| Arquivo | Objetivo | Esperado | Observado |
|---|---|---|---|
| `01_programa_ola.tel` | Exemplo da seção 4 | 28 tokens + EOF, sem erro | 28 tokens + EOF, sem erro |
| `02_palavras_reservadas.tel` | As 59 palavras reservadas | 59 tokens próprios, nenhum `ID` | 59 tokens próprios, nenhum `ID` |
| `03_identificadores.tel` | Grafias parecidas com reservadas | `lume`, `tharma_min`, `volaSensor`, `casa` etc. viram `ID`; `þarma_min` é `SHIFT_LEFT`; `aba_né` é `FALSE`; `abá né` é `NOT TRUE` | igual ao esperado (9 `ID`) |
| `04_literais.tel` | Inteiros, reais e strings | `0xE+1` vira `INT_LITERAL PLUS INT_LITERAL`; `-128` vira `MINUS INT_LITERAL`; strings preservadas | igual ao esperado |
| `05_comentarios.tel` | Comentários, tabulação e marcadores dentro de string | comentários descartados; `/* ... */` dentro de string continua `STRING_LITERAL` | igual ao esperado |
| `06_reservadas_nfd.tel` | Reservadas em NFD | `BOOL_TYPE`, `TRUE`, `TIME_TYPE` | `BOOL_TYPE`, `TRUE`, `TIME_TYPE` |
| `07_bom_crlf_cr.tel` | BOM, CRLF e CR isolado | `hauda` 1:1, `minya` 2:1, `vola` 3:1 | `hauda` 1:1, `minya` 2:1, `vola` 3:1 |

## Com erro léxico

| Arquivo | Objetivo | Esperado | Observado |
|---|---|---|---|
| `01_binario_invalido.tel` | `0b102` | numeral inválido | `1:19: erro léxico: numeral inválido '0b102'` |
| `02_numeral_seguido_de_letras.tel` | `2contador` | numeral inválido | `1:11: erro léxico: numeral inválido '2contador'` |
| `03_string_nao_fechada.tel` | `"Ola;` | string não fechada | `1:9: erro léxico: string não fechada na mesma linha` |
| `04_escape_invalido.tel` | `"Ola\q"` | escape inválido | `1:13: erro léxico: escape inválido '\q' em string` |
| `05_comentario_nao_fechado.tel` | `/*` sem `*/` | comentário não fechado | `2:1: erro léxico: comentário de bloco não fechado (falta */)` |
| `06_caractere_invalido.tel` | `@` | caractere inválido | `1:19: erro léxico: caractere inválido '@' (U+0040)` |
| `07_espaco_unicode.tel` | U+00A0 fora de string | caractere inválido | `1:14: erro léxico: caractere inválido U+00A0` |
| `08_string_com_nul.tel` | U+0000 em string | U+0000 proibido | `1:11: erro léxico: caractere U+0000 não é permitido em string` |
| `09_utf8_malformado.tel` | byte `0xFF` | erro de leitura | `erro de leitura: UTF-8 malformado na linha 1, coluna 18 (byte 0xFF)` |
