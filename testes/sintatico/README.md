# Testes sintáticos

Cada arquivo começa com um comentário que diz o objetivo do teste e o resultado esperado. Os arquivos com prefixo `e` reproduzem os programas e os casos citados no enunciado (seções 4, 6.1.4, 8, 9, 10, 18.2.3, 19.1, 19.2, 22.8, 25, 26.2 e 26.3); os numerados cobrem os critérios das issues #6 a #9.

Para rodar todos e conferir o resultado:

```bash
mvn clean package
sh testes/sintatico/rodar.sh
```

Para ver a árvore ou o erro de um arquivo:

```bash
java -jar target/telerin.jar testes/sintatico/validos/e09_secao25_programa_completo.tel
java -jar target/telerin.jar --lisp testes/sintatico/validos/01_estrutura_minima.tel
```

As imagens das árvores dos programas válidos (PNG e SVG) ficam em `arvores/`. Foram desenhadas com o `TreeViewer` do ANTLR 4.13.2, o mesmo visualizador do `TestRig -gui`; `precedencia_*.png` mostram, a partir da regra `expressao`, as três expressões da issue #7. As capturas do ANTLR Lab acompanham estas imagens na entrega.

## Válidos

Esperado: árvore sintática impressa, código de saída 0.

| Arquivo | Objetivo |
|---|---|
| `01_estrutura_minima.tel` | o menor programa completo (seção 4): hauda, minya e vola, cada um com cava e bloco vazio, seguidos do fim do arquivo. |
| `02_declaracoes_tipos.tel` | recursos dos cinco tipos (seção 19), constantes (seção 7), globais com e sem inicializador e locais com inicializador (seção 8), todos os tipos da seção 6, larguras e vetores. |
| `03_funcoes.tel` | funções com retorno, procedimentos aba_car (seções 17 e 18), listas de parâmetros vazias e com vários itens, parâmetro de capacidade (tipo de recurso), auta com e sem expressão e chamadas com ela. |
| `04_condicao_selecao.tel` | né_cava com e sem heco, aninhado (seção 11), forma de presença com han (seção 10.3) e car_heco com vários casos e heco por último (seção 12). |
| `05_repeticoes.tel` | as quatro repetições (seções 13 a 15): vola_né, vola_delia com as três partes e com as partes vazias, vola_car ... vola_né; e vola_canat, além de lanca e vola_minya (seção 16). |
| `06_vetores_expressoes.tel` | vetores (seção 20), precedência e associatividade (seção 9), unários encadeados, conversões (seção 22.3), operações sobre bits (seção 9.1), duração (seção 10.5) e leituras sem parênteses (seção 10.4). |
| `e01_secao4_minimo.tel` | exemplo mínimo completo da seção 4. |
| `e02_secao4_mensagem.tel` | exemplo com impressão de mensagem da seção 4. |
| `e03_secao4_2_paralelo.tel` | programa do paralelo com Arduino da seção 4.2. |
| `e04_secao6_1_4_media.tel` | exemplo comparado de duinë da seção 6.1.4. |
| `e05_secao8_instante_global.tel` | global lúmë<lúmë_min> sem inicializador, da seção 8. |
| `e06_secao18_2_3_somar_mostrar.tel` | exemplo completo de função e procedimento da seção 18.2.3. |
| `e07_secao19_1_led.tel` | paralelo com Arduino da seção 19.1. |
| `e08_secao19_2_pwm.tel` | exemplo integrado de leitura e PWM da seção 19.2. |
| `e09_secao25_programa_completo.tel` | programa completo comentado da seção 25.1. |
| `e10_trechos_das_secoes.tel` | trechos válidos das seções 6 a 20 e do §22.8 (canat casa, 0xE+1, abá né, condição omitida em vola_delia, lista vetorial como argumento e retorno), inseridos num programa completo. |

## Com erro só semântico

A sintaxe está correta; nomes, tipos, faixas, recursos e posições são verificados na análise semântica. A seção 26.3 exige que esses casos passem pelo lexer e pelo parser. Esperado: o parser aceita e imprime a árvore.

| Arquivo | Objetivo |
|---|---|
| `01_erros_semanticos.tel` | erros que só a análise semântica detecta (tipo, escopo, faixa, nome reservado, vetor vazio, posição de minya_lambë e uso de lanca fora de laço). A sintaxe está correta. |
| `e01_nome_nao_declarado.tel` | contador = 1; sem declaração (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e02_nome_duplicado.tel` | mesmo nome declarado duas vezes (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e03_reatribui_constante.tel` | constante reatribuída (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e04_logico_em_inteiro.tel` | canat_min valor = né; (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e05_condicao_inteira.tel` | né_cava 1 cava {} (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e06_largura_7.tel` | canat_min<7> valor = 1; (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e07_256_em_canat_min.tel` | canat_min valor = 256; (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e08_lanca_fora_de_laco.tel` | lanca; direto em vola (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e09_vola_minya_fora_de_laco.tel` | vola_minya; direto em vola (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e10_vetor_com_menos_elementos.tel` | [canat_min; 3] valores = [1, 2]; (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e11_argumento_faltando.tel` | somar(1) com somar de dois parâmetros (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e12_retorno_logico.tel` | função canat_min que retorna né (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e13_logico_em_saida_digital.tel` | ela car_duimë né han led; (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e14_escrita_em_entrada.tel` | ela car_duimë duimë han botao; com botao de entrada (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e15_real_em_inteiro.tel` | canat_min valor = 1.5; (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e16_resto_de_real.tel` | duinë valor = 5.0 % 2.0; (seção 26.3). O erro é semântico; a sintaxe está correta. |
| `e17_nome_com_dois_sublinhados.tel` | nome iniciado por __ (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e18_variavel_aba_car.tel` | aba_car como tipo de variável (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e19_lista_vazia.tel` | [] como lista vetorial (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e20_declaracao_antes_de_minya_lambe.tel` | declaração local antes de minya_lambë (seções 10.2 e 22.8). O erro é semântico; a sintaxe está correta. |
| `e21_opcional_global.tel` | mapa_min global (seções 22.4 e 22.8). O erro é semântico; a sintaxe está correta. |
| `e22_lanca_em_funcao_sem_laco.tel` | lanca dentro de função sem laço local (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e23_duracao_nao_inteira.tel` | lúmë(1, 3) (seções 22.4 e 22.8). O erro é semântico; a sintaxe está correta. |
| `e24_conversao_fora_de_faixa.tel` | canat_min(256.0) (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e25_pwm_em_pino_sem_pwm.tel` | PWM no pino 22 (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e26_conflito_de_pino.tel` | leper(54) e leper_duinë(0) no mesmo pino físico (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e27_saida_sem_valor_inicial.tel` | saída digital sem valor inicial (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e28_pino_serial.tel` | pino 1 usado com serial ativa (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e29_recursao_indireta.tel` | recursão indireta entre duas funções (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e30_sombreamento.tel` | declaração local repete nome visível (seção 22.2). O erro é semântico; a sintaxe está correta. |
| `e31_casos_duplicados.tel` | car_min duplicado após avaliação constante (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e32_deslocamento_invalido.tel` | þarma_min<8>(128, 1) e forma_min<8>(1, 8) (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e33_instante_lido_antes_de_iniciar.tel` | instante global lido antes de inicializado (seção 22.8). O erro é semântico; a sintaxe está correta. |
| `e34_procedimento_como_valor.tel` | procedimento usado como valor (seção 18.2.6). O erro é semântico; a sintaxe está correta. |

## Com erro sintático

Esperado: mensagem `arquivo:linha:coluna: erro sintático: descrição` e código de saída 1. A análise para no primeiro erro.

| Arquivo | Objetivo | Observado |
|---|---|---|
| `01_minya_sem_cava.tel` | todo bloco começa com cava (seção 4.1). | `4:7: erro sintático: falta 'cava' antes de '{'` |
| `02_cava_antes_de_minya.tel` | cava vem depois de minya, não antes. | `4:1: erro sintático: 'cava' sobrando; era esperado um de tipo, 'minya', 'glanna', 'car'` |
| `03_sem_minya.tel` | o programa exige minya (seção 4). | `4:1: erro sintático: encontrado 'vola', mas era esperado um de tipo, 'minya', 'glanna', 'car'` |
| `04_blocos_fora_de_ordem.tel` | vola não pode vir antes de minya. | `4:1: erro sintático: encontrado 'vola', mas era esperado um de tipo, 'minya', 'glanna', 'car'` |
| `05_conteudo_apos_vola.tel` | nada pode vir depois de vola, só o fim do arquivo (seção 22). | `6:1: erro sintático: encontrado 'canat', mas era esperado fim do arquivo` |
| `06_local_sem_inicializador.tel` | variável local exige inicializador (seção 8). | `6:20: erro sintático: encontrado ';', mas era esperado um de '<', identificador` |
| `07_comparacao_encadeada.tel` | comparações não encadeiam (seção 9). | `6:24: erro sintático: comparações não podem ser encadeadas: '<' aparece depois de outra comparação (use ye para combinar)` |
| `08_leitura_com_parenteses.tel` | mapa_duimë recebe um identificador, sem parênteses (seção 10.4). | `6:28: erro sintático: '(' sobrando; era esperado identificador` |
| `09_indice_sobre_chamada.tel` | o índice só se aplica a um nome (seção 20). | `6:22: erro sintático: falta ';' antes de '['` |
| `10_operando_faltando.tel` | o operador + precisa de operando à direita. | `6:19: erro sintático: encontrado ';', mas era esperado uma expressão` |
| `11_mais_unario.tel` | não existe + unário (seção 9). | `6:15: erro sintático: '+' sobrando; era esperado uma expressão` |
| `12_ela_com_atribuicao.tel` | ela anuncia uma ação, não uma atribuição (seção 10). | `6:19: erro sintático: encontrado '=', mas era esperado '('` |
| `13_ela_com_parenteses.tel` | ela não aceita chamada entre parênteses. | `6:9: erro sintático: '(' não era esperado aqui` |
| `14_chamada_sem_ela.tel` | chamada como comando exige ela (seção 10). | `6:12: erro sintático: chamada usada como comando precisa de 'ela': escreva ela mostrar(...);` |
| `15_escrita_sem_han.tel` | a escrita em pino termina em han destino (seção 10). | `6:25: erro sintático: encontrado numeral '128', mas era esperado um de 'han', 'ye', 'heco_ye', '+', '-', '*', '/', '%', entre outros` |
| `16_han_antes_da_acao.tel` | han vem depois do valor, não logo após ela. | `6:9: erro sintático: 'han' não era esperado aqui` |
| `17_lanca_com_parenteses.tel` | lanca não tem parênteses (seção 16). | `6:10: erro sintático: encontrado '(', mas era esperado ';'` |
| `18_atribuicao_encadeada.tel` | atribuição é comando, não expressão (seção 9). | `6:11: erro sintático: encontrado '=', mas era esperado um de 'ye', 'heco_ye', '+', '-', '*', '/', '%', '<=', entre outros` |
| `19_comando_vazio.tel` | não existe comando vazio ";". | `6:5: erro sintático: ';' sobrando; era esperado um de tipo, 'glanna', 'auta', 'ela', 'né_cava', 'car_heco', 'vola_né', 'vola_canat', entre outros` |
| `20_para_com_um_ponto_e_virgula.tel` | vola_delia exige os dois ";" (seção 14). | `6:21: erro sintático: falta ';' antes de ')'` |
| `21_faca_sem_ponto_e_virgula.tel` | vola_car ... vola_né termina com ";" (seção 15). | `7:1: erro sintático: falta ';' antes de '}'` |
| `22_condicao_sem_cava.tel` | o corpo do né_cava é um bloco cava { } (seção 11). | `6:16: erro sintático: encontrado 'ela', mas era esperado um de 'cava', 'han'` |
| `23_selecao_sem_caso.tel` | car_heco exige pelo menos um car_min (seção 12). | `7:9: erro sintático: encontrado 'heco', mas era esperado 'car_min'` |
| `24_funcao_sem_cava.tel` | o corpo da função é um bloco cava { } (seção 17). | `4:17: erro sintático: falta 'cava' antes de '{'` |
| `25_caso_sem_cava.tel` | o corpo de car_min é um bloco cava { } (seção 12). | `7:19: erro sintático: falta 'cava' antes de '{'` |
| `26_laco_sem_cava.tel` | o corpo de vola_né é um bloco cava { } (seção 13). | `6:16: erro sintático: falta 'cava' antes de '{'` |
| `27_pino_com_expressao.tel` | o número do pino é um numeral, não uma expressão (seção 19). | `4:30: erro sintático: encontrado '+', mas era esperado ')'` |
| `28_duracao_com_expressao.tel` | lúmë(n, d) só aceita numerais (seção 10.5). | `6:25: erro sintático: encontrado identificador 'x', mas era esperado numeral inteiro` |
| `29_destino_han_nao_identificador.tel` | o destino de han é só identificador (seção 10). | `6:33: erro sintático: falta ';' antes de '['` |
| `30_hauda_com_variavel.tel` | hauda contém somente declarações de recurso (seção 19). | `4:5: erro sintático: encontrado 'canat', mas era esperado um de 'leper_mapa', 'leper_duimë', 'leper_car', 'duinë_mapa', 'duinë_car', '}'` |
| `e01_sem_hauda.tel` | arquivo sem hauda (seções 4 e 26.2). | `3:1: erro sintático: encontrado 'minya', mas era esperado 'hauda'` |
| `e02_sem_minya.tel` | arquivo sem minya; o trecho é o arquivo inteiro (seção 26.2). | `3:15: erro sintático: encontrado 'vola', mas era esperado um de tipo, 'minya', 'glanna', 'car'` |
| `e03_sem_vola.tel` | arquivo sem vola (seção 26.2). | `5:1: erro sintático: encontrado fim do arquivo, mas era esperado 'vola'` |
| `e04_blocos_fora_de_ordem.tel` | minya antes de hauda (seção 26.2). | `3:1: erro sintático: encontrado 'minya', mas era esperado 'hauda'` |
| `e05_token_apos_vola.tel` | tokens após o fechamento de vola (seção 26.2). | `6:1: erro sintático: encontrado 'ela', mas era esperado fim do arquivo` |
| `e06_segunda_sequencia.tel` | segunda sequência de blocos no mesmo arquivo (seção 22.8). | `6:1: erro sintático: encontrado 'hauda', mas era esperado fim do arquivo` |
| `e07_minya_sem_cava.tel` | minya {} sem o marcador cava (seções 4.1 e 26.2). | `4:7: erro sintático: falta 'cava' antes de '{'` |
| `e08_cava_antes_de_minya.tel` | cava minya {}: marcador na posição errada (seção 26.2). | `4:1: erro sintático: 'cava' sobrando; era esperado um de tipo, 'minya', 'glanna', 'car'` |
| `e09_minya_casa.tel` | minya casa {}: casa é identificador, não marcador (seções 22.8 e 26.2). | `4:7: erro sintático: encontrado identificador 'casa', mas era esperado 'cava'` |
| `e10_funcao_sem_cava.tel` | função sem cava (seção 26.2). | `4:17: erro sintático: falta 'cava' antes de '{'` |
| `e11_caso_sem_cava.tel` | caso de car_heco sem cava (seção 26.2). | `8:33: erro sintático: falta 'cava' antes de '{'` |
| `e12_laco_sem_cava.tel` | laço sem cava (seção 26.2). | `8:18: erro sintático: falta 'cava' antes de '{'` |
| `e13_cava_antes_da_condicao.tel` | cava né_cava contador > 0 {} (seção 4.1). | `9:5: erro sintático: 'cava' sobrando; era esperado um de tipo, 'glanna', 'auta', 'ela', 'né_cava', 'car_heco', 'vola_né', 'vola_canat', entre outros` |
| `e14_falta_ponto_e_virgula.tel` | canat_min contador = 1 sem ";" (seção 26.2). | `9:1: erro sintático: falta ';' antes de '}'` |
| `e15_condicao_sem_bloco.tel` | né_cava né ela pet_lanca 1; (seção 26.2). | `8:16: erro sintático: encontrado 'ela', mas era esperado um de 'cava', 'han'` |
| `e16_para_sem_segundo_separador.tel` | vola_delia (; né) cava {} (seção 26.2). | `8:21: erro sintático: falta ';' antes de ')'` |
| `e17_faca_sem_ponto_e_virgula.tel` | vola_car cava {} vola_né aba_né sem ";" (seção 26.2). | `9:1: erro sintático: falta ';' antes de '}'` |
| `e18_lanca_com_parenteses.tel` | lanca( ); (seção 26.2). | `8:10: erro sintático: encontrado '(', mas era esperado ';'` |
| `e19_operando_faltando.tel` | canat_min valor = 1 + ; (seção 26.2). | `8:27: erro sintático: encontrado ';', mas era esperado uma expressão` |
| `e20_local_sem_inicializador.tel` | canat_min valor; como local (seção 26.2). | `8:20: erro sintático: encontrado ';', mas era esperado um de '<', identificador` |
| `e21_ela_valor_igual.tel` | ela valor = 1; (seção 26.2). | `8:15: erro sintático: encontrado '=', mas era esperado '('` |
| `e22_parentese_aberto.tel` | canat_min valor = (1 + 2; (seção 26.2). | `8:29: erro sintático: falta ')' antes de ';'` |
| `e23_pwm_na_ordem_errada.tel` | ela car_duinë motor 128; (seções 10.4 e 26.2). | `10:25: erro sintático: encontrado numeral '128', mas era esperado um de 'han', 'ye', 'heco_ye', '+', '-', '*', '/', '%', entre outros` |
| `e24_han_antes_da_operacao.tel` | ela han led car_duimë duimë; (seções 10.4 e 26.2). | `10:9: erro sintático: 'han' não era esperado aqui` |
| `e25_escrita_sem_han.tel` | escrita digital sem han (seção 22.8). | `10:25: erro sintático: falta 'han' antes de identificador 'led'` |
| `e26_destino_expressao.tel` | destino de han que é expressão (seção 22.8). | `10:33: erro sintático: encontrado '+', mas era esperado um de 'han', 'ye', 'heco_ye', '+', '-', '*', '/', '%', entre outros` |
| `e27_ela_resultado_igual.tel` | ela resultado = 3; (seção 10.1.2). | `8:19: erro sintático: encontrado '=', mas era esperado '('` |
| `e28_ela_condicao.tel` | ela né_cava né cava {} (seção 10.1.2). | `8:9: erro sintático: 'né_cava' não era esperado aqui` |
| `e29_ela_entre_parenteses.tel` | ela (mostrar(3)); (seção 10.1.2). | `8:9: erro sintático: '(' não era esperado aqui` |
| `e30_chamada_sem_ela.tel` | mostrar(5); sem ela como comando (seção 18.2.6). | `8:12: erro sintático: chamada usada como comando precisa de 'ela': escreva ela mostrar(...);` |
| `e31_comparacao_encadeada.tel` | contador < limite < 10 (seção 9). | `8:36: erro sintático: comparações não podem ser encadeadas: '<' aparece depois de outra comparação (use ye para combinar)` |
| `e32_atribuicao_encadeada.tel` | x = y = 1; (seção 9). | `8:11: erro sintático: encontrado '=', mas era esperado um de 'ye', 'heco_ye', '+', '-', '*', '/', '%', '<=', entre outros` |
| `e33_atribuicao_na_condicao.tel` | né_cava (x = 1) cava {} (seção 9). | `8:16: erro sintático: encontrado '=', mas era esperado um de 'ye', 'heco_ye', '+', '-', '*', '/', '%', '<=', entre outros` |
| `e34_mais_unario.tel` | não há + unário (seção 9). | `8:15: erro sintático: '+' sobrando; era esperado uma expressão` |
| `e35_leitura_com_parenteses.tel` | mapa_duimë(botao) (seções 10.4 e 22.8). | `10:31: erro sintático: '(' sobrando; era esperado identificador` |
| `e36_leitura_de_construtor.tel` | mapa_duinë leper_duinë(0) (seção 10.4). | `8:34: erro sintático: encontrado 'leper_duinë', mas era esperado identificador` |
| `e37_leitura_de_pino_numerico.tel` | pino numérico no lugar do identificador (seção 22.8). | `8:32: erro sintático: encontrado numeral '2', mas era esperado identificador` |
| `e38_indice_sobre_chamada.tel` | obter()[0] (seções 20 e 22.8). | `8:26: erro sintático: falta ';' antes de '['` |
| `e39_comando_vazio.tel` | não há comando vazio ";" (seção 22). | `8:5: erro sintático: ';' sobrando; era esperado um de tipo, 'glanna', 'auta', 'ela', 'né_cava', 'car_heco', 'vola_né', 'vola_canat', entre outros` |
