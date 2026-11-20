#!/bin/sh
# Gera os testes com bytes invisíveis ou inválidos (seção 22.8).
cd "$(dirname "$0")" || exit 1

# Reservadas em NFD: "né" = n + e + U+0301; "lúmë" = l + u + U+0301 + m + e + U+0308.
printf '// Objetivo: reservadas digitadas em NFD (letra + acento combinante)\n// são reconhecidas depois da normalização NFC (seção 5.1).\n// Esperado: BOOL_TYPE, TRUE e TIME_TYPE, sem erro.\nne\314\201_lambe\314\210 x = ne\314\201;\nlu\314\201me\314\210 t = lu\314\201me\314\210(1, 2);\n' > validos/06_reservadas_nfd.tel

# BOM inicial, CRLF e CR isolado.
printf '\357\273\277// Objetivo: BOM inicial descartado; CRLF e CR isolado contam como uma\r\n// quebra de linha cada (seção 21). Esperado: hauda em 4:1, minya em 5:1 e\r\n// vola em 6:1, sem erro.\r\nhauda cava {}\rminya cava {}\nvola cava {}\n' > validos/07_bom_crlf_cr.tel

# Espaço Unicode U+00A0 (bytes C2 A0) fora de string.
printf '// Objetivo: separadores Unicode fora de strings e comentários são erro\n// léxico (seção 21). Esperado: erro "caractere inválido U+00A0".\ncanat valor =\302\2401;\n' > invalidos/07_espaco_unicode.tel

# U+0000 dentro de string.
printf '// Objetivo: U+0000 é proibido em strings (seção 5.2).\n// Esperado: erro "caractere U+0000 não é permitido em string".\nela pet "a\000b";\n' > invalidos/08_string_com_nul.tel

# Byte 0xFF isolado: UTF-8 malformado.
printf '// Objetivo: UTF-8 malformado é erro de leitura, sem substituição\n// silenciosa (seção 21). Esperado: "UTF-8 malformado na linha 3".\ncanat valor = 1; \377\n' > invalidos/09_utf8_malformado.tel
