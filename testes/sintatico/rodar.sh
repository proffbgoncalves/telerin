#!/bin/sh
# Roda todos os testes sintáticos e confere o resultado esperado:
#   validos/ e semanticos/  -> código de saída 0 (árvore impressa);
#   invalidos/              -> código de saída 1 com "erro sintático".
# Requer o jar gerado por "mvn clean package".
# Uso: sh testes/sintatico/rodar.sh
cd "$(dirname "$0")/../.." || exit 1
JAR=target/telerin.jar
[ -f "$JAR" ] || { echo "gere o jar antes: mvn clean package"; exit 2; }

falhas=0
total=0

for arquivo in testes/sintatico/validos/*.tel testes/sintatico/semanticos/*.tel; do
    total=$((total + 1))
    if ! java -jar "$JAR" "$arquivo" > /dev/null 2> /dev/null; then
        echo "FALHOU (deveria aceitar): $arquivo"
        falhas=$((falhas + 1))
    fi
done

for arquivo in testes/sintatico/invalidos/*.tel; do
    total=$((total + 1))
    erro=$(java -jar "$JAR" "$arquivo" 2>&1 > /dev/null)
    codigo=$?
    if [ "$codigo" -ne 1 ] || ! echo "$erro" | grep -q "erro sintático"; then
        echo "FALHOU (deveria rejeitar): $arquivo"
        falhas=$((falhas + 1))
    fi
done

echo "$((total - falhas)) de $total testes passaram"
[ "$falhas" -eq 0 ]
