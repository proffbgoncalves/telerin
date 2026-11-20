lexer grammar TelerinLexer;

// Espaços e comentários

WS              : [ \t\r\n]+ -> skip ;
LINE_COMMENT    : '//' ~[\r\n]* -> skip ;
BLOCK_COMMENT   : '/*' .*? '*/' -> skip ;

// Palavras reservadas (antes de ID)

HARDWARE            : 'hauda' ;
SETUP               : 'minya' ;
LOOP                : 'vola' ;
CONST               : 'glanna' ;
FUNCTION            : 'car' ;
RETURN              : 'auta' ;
IN                  : 'cava' ;
ACTION              : 'ela' ;
TO                  : 'han' ;

INT_TYPE            : 'canat' ;
BYTE_TYPE           : 'canat_min' ;
BOOL_TYPE           : 'né_lambë' ;
LEVEL_TYPE          : 'duimë_dammë' ;
TIME_TYPE           : 'lúmë' ;
TEXT_TYPE           : 'lambë' ;
OPTIONAL_BYTE_TYPE  : 'mapa_min' ;
VOID                : 'aba_car' ;
FLOAT               : 'duinë' ;

TRUE                : 'né' ;
FALSE               : 'aba_né' ;
HIGH                : 'duimë' ;
LOW                 : 'dammë' ;

IF                  : 'né_cava' ;
ELSE                : 'heco' ;
SWITCH              : 'car_heco' ;
CASE                : 'car_min' ;
WHILE               : 'vola_né' ;
REPEAT              : 'vola_canat' ;
DO                  : 'vola_car' ;
FOR                 : 'vola_delia' ;
BREAK               : 'lanca' ;
CONTINUE            : 'vola_minya' ;

AND                 : 'ye' ;
OR                  : 'heco_ye' ;
NOT                 : 'abá' ;

BIT_AND             : 'ye_min' ;
BIT_OR              : 'heco_min' ;
BIT_XOR             : 'heco_aba' ;
BIT_NOT             : 'abá_min' ;
SHIFT_LEFT          : 'þarma_min' ;
SHIFT_RIGHT         : 'forma_min' ;

DIGITAL_WRITE       : 'car_duimë' ;
ANALOG_WRITE        : 'car_duinë' ;
DIGITAL_READ        : 'mapa_duimë' ;
ANALOG_READ         : 'mapa_duinë' ;

SERIAL_PRINT        : 'pet' ;
SERIAL_PRINTLN      : 'pet_lanca' ;
SERIAL_WRITE        : 'pet_min' ;
SERIAL_BEGIN        : 'minya_lambë' ;
SERIAL_READ         : 'mapa' ;

DELAY               : 'lúmë_dammë' ;
MILLIS              : 'lúmë_min' ;

DIGITAL_PIN         : 'leper' ;
ANALOG_PIN          : 'leper_duinë' ;
INPUT               : 'leper_mapa' ;
INPUT_PULLUP        : 'leper_duimë' ;
OUTPUT              : 'leper_car' ;
ANALOG_INPUT        : 'duinë_mapa' ;
PWM_OUTPUT          : 'duinë_car' ;

// Literais

INT_LITERAL
    : '0'
    | [1-9] [0-9]*
    | '0b' [01]+
    | '0x' [0-9a-fA-F]+
    ;

FLOAT_LITERAL
    : PARTE_INTEIRA '.' [0-9]+ EXPOENTE?
    | PARTE_INTEIRA EXPOENTE
    ;

STRING_LITERAL  : '"' CARACTERE_STRING* '"' ;

fragment PARTE_INTEIRA      : '0' | [1-9] [0-9]* ;
fragment EXPOENTE           : [eE] [+-]? [0-9]+ ;
fragment CARACTERE_STRING   : ~["\\\r\n\u0000] | ESCAPE ;
fragment ESCAPE             : '\\' [nrt"\\] ;

// Operadores e delimitadores

PLUS        : '+' ;
MINUS       : '-' ;
STAR        : '*' ;
SLASH       : '/' ;
PERCENT     : '%' ;

LE          : '<=' ;
GE          : '>=' ;
EQ          : '==' ;
NE          : '!=' ;
LT          : '<' ;
GT          : '>' ;

ASSIGN      : '=' ;

LPAREN      : '(' ;
RPAREN      : ')' ;
LBRACE      : '{' ;
RBRACE      : '}' ;
LBRACKET    : '[' ;
RBRACKET    : ']' ;
SEMI        : ';' ;
COMMA       : ',' ;
COLON       : ':' ;

// Identificadores

ID          : [\p{L}_] [\p{L}\p{M}\p{Nd}_]* ;
