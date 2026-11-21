parser grammar TelerinParser;

options { tokenVocab = TelerinLexer; }

// Programa

programa
    : blocoHauda declaracaoGlobal* blocoMinya blocoVola EOF
    ;

blocoHauda
    : HARDWARE IN LBRACE declaracaoRecurso* RBRACE
    ;

blocoMinya
    : SETUP bloco
    ;

blocoVola
    : LOOP bloco
    ;

// Declarações

// O valor após ':' é opcional aqui; a semântica decide quando ele é exigido.
declaracaoRecurso
    : tipoRecurso ID ASSIGN pino (COLON expressao)? SEMI
    ;

pino
    : DIGITAL_PIN LPAREN INT_LITERAL RPAREN
    | ANALOG_PIN LPAREN INT_LITERAL RPAREN
    ;

declaracaoGlobal
    : declaracaoConstante
    | tipo ID (ASSIGN expressao)? SEMI
    ;

declaracaoLocal
    : declaracaoConstante
    | tipo ID ASSIGN expressao SEMI
    ;

declaracaoConstante
    : CONST tipo ID ASSIGN expressao SEMI
    ;

// Tipos

tipo
    : tipoSimples
    | tipoVetor
    ;

tipoVetor
    : LBRACKET tipoSimples SEMI INT_LITERAL RBRACKET
    ;

tipoSimples
    : tipoNumerico
    | BOOL_TYPE
    | LEVEL_TYPE
    | TIME_TYPE (LT MILLIS GT)?
    | TEXT_TYPE
    | OPTIONAL_BYTE_TYPE
    | VOID
    | tipoRecurso
    ;

tipoNumerico
    : INT_TYPE largura?
    | BYTE_TYPE largura?
    | FLOAT
    ;

largura
    : LT INT_LITERAL GT
    ;

tipoRecurso
    : OUTPUT
    | INPUT
    | INPUT_PULLUP
    | ANALOG_INPUT
    | PWM_OUTPUT
    ;

// Blocos

bloco
    : IN LBRACE itemBloco* RBRACE
    ;

itemBloco
    : declaracaoLocal
    ;

// Expressões, da menor para a maior precedência

expressao
    : expressaoOu
    ;

expressaoOu
    : expressaoE (OR expressaoE)*
    ;

expressaoE
    : expressaoRelacional (AND expressaoRelacional)*
    ;

// '?' em vez de '*': comparações não encadeiam (a < b < c é erro).
expressaoRelacional
    : expressaoAditiva (operadorRelacional expressaoAditiva)?
    ;

operadorRelacional
    : LT | LE | GT | GE | EQ | NE
    ;

expressaoAditiva
    : expressaoMultiplicativa ((PLUS | MINUS) expressaoMultiplicativa)*
    ;

expressaoMultiplicativa
    : expressaoUnaria ((STAR | SLASH | PERCENT) expressaoUnaria)*
    ;

expressaoUnaria
    : (NOT | MINUS) expressaoUnaria
    | expressaoPrimaria
    ;

expressaoPrimaria
    : literal
    | acessoVetor
    | chamada
    | ID
    | conversao
    | operacaoBits
    | duracao
    | leitura
    | listaVetor
    | LPAREN expressao RPAREN
    ;

literal
    : INT_LITERAL
    | FLOAT_LITERAL
    | STRING_LITERAL
    | TRUE
    | FALSE
    | HIGH
    | LOW
    ;

acessoVetor
    : ID LBRACKET expressao RBRACKET
    ;

chamada
    : ID LPAREN listaArgumentos? RPAREN
    ;

listaArgumentos
    : expressao (COMMA expressao)*
    ;

conversao
    : tipoNumerico LPAREN expressao RPAREN
    ;

operacaoBits
    : (BIT_AND | BIT_OR | BIT_XOR | SHIFT_LEFT | SHIFT_RIGHT)
          largura LPAREN expressao COMMA expressao RPAREN
    | BIT_NOT largura LPAREN expressao RPAREN
    ;

duracao
    : TIME_TYPE LPAREN INT_LITERAL COMMA INT_LITERAL RPAREN
    ;

leitura
    : DIGITAL_READ ID
    | ANALOG_READ ID
    | SERIAL_READ
    | MILLIS
    ;

listaVetor
    : LBRACKET listaArgumentos? RBRACKET
    ;
