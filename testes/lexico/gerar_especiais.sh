#!/bin/sh
# Gera os testes com bytes invisíveis ou inválidos (seção 22.8).
cd "$(dirname "$0")" || exit 1

# né_lambë, né e lúmë em NFD
printf 'ne\314\201_lambe\314\210 x = ne\314\201;\nlu\314\201me\314\210 t = lu\314\201me\314\210(1, 2);\n' > validos/06_reservadas_nfd.tel

# BOM, CRLF e CR isolado
printf '\357\273\277hauda cava {}\r\nminya cava {}\rvola cava {}\n' > validos/07_bom_crlf_cr.tel

# U+00A0 fora de string
printf 'canat valor =\302\2401;\n' > invalidos/07_espaco_unicode.tel

# U+0000 em string
printf 'ela pet "a\000b";\n' > invalidos/08_string_com_nul.tel

# byte 0xFF
printf 'canat valor = 1; \377\n' > invalidos/09_utf8_malformado.tel
