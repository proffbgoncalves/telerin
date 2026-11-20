lexer grammar TelerinLexer;

@header {
import java.text.Normalizer;
import java.util.HashMap;
import java.util.Map;
}

@members {
    // CR isolado conta como quebra de linha e o BOM inicial não ocupa coluna.
    private static final class TelerinATNSimulator extends LexerATNSimulator {
        TelerinATNSimulator(Lexer recog, ATN atn, DFA[] dfa, PredictionContextCache cache) {
            super(recog, atn, dfa, cache);
        }

        @Override
        public void consume(CharStream input) {
            int atual = input.LA(1);
            if (atual == '\r' && input.LA(2) != '\n') {
                line++;
                charPositionInLine = 0;
                input.consume();
            } else if (atual == 0xFEFF && input.index() == 0) {
                input.consume();
            } else {
                super.consume(input);
            }
        }
    }

    private static Map<String, Integer> reservadas;

    private static synchronized Map<String, Integer> reservadas() {
        if (reservadas == null) {
            Map<String, Integer> mapa = new HashMap<>();
            for (int tipo = 1; tipo <= VOCABULARY.getMaxTokenType(); tipo++) {
                String literal = VOCABULARY.getLiteralName(tipo);
                if (literal == null || literal.length() < 3) continue;
                String texto = desescaparUnicode(literal.substring(1, literal.length() - 1));
                if (Character.isLetter(texto.codePointAt(0))) {
                    mapa.put(Normalizer.normalize(texto, Normalizer.Form.NFC), tipo);
                }
            }
            reservadas = mapa;
        }
        return reservadas;
    }

    // O vocabulário gerado guarda os acentos como escapes unicode.
    private static String desescaparUnicode(String s) {
        StringBuilder sb = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '\\' && i + 6 <= s.length() && s.charAt(i + 1) == 'u') {
                sb.append((char) Integer.parseInt(s.substring(i + 2, i + 6), 16));
                i += 5;
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }

    @Override
    public Token nextToken() {
        if (!(_interp instanceof TelerinATNSimulator)) {
            _interp = new TelerinATNSimulator(this, _ATN, _decisionToDFA, _sharedContextCache);
        }
        Token token = super.nextToken();
        switch (token.getType()) {
            case ID:
                reclassificarPorNFC(token);
                break;
            case ERRO_NUMERO:
                reportar(token, token.getCharPositionInLine(),
                        "numeral inválido '" + token.getText() + "'");
                break;
            case ERRO_STRING:
                diagnosticarString(token);
                break;
            case ERRO_COMENTARIO:
                reportar(token, token.getCharPositionInLine(),
                        "comentário de bloco não fechado (falta */)");
                break;
            case ERRO_CARACTERE:
                reportar(token, token.getCharPositionInLine(),
                        "caractere inválido " + descrever(token.getText().codePointAt(0)));
                break;
            default:
                break;
        }
        return token;
    }

    // Reservada escrita em NFD casa com ID; aqui recebe o tipo certo.
    private void reclassificarPorNFC(Token token) {
        String nfc = Normalizer.normalize(token.getText(), Normalizer.Form.NFC);
        Integer tipo = reservadas().get(nfc);
        if (tipo != null && token instanceof WritableToken) {
            ((WritableToken) token).setType(tipo);
        }
    }

    private void diagnosticarString(Token token) {
        int[] cps = token.getText().codePoints().toArray();
        int coluna = token.getCharPositionInLine();
        for (int i = 1; i < cps.length; i++) {
            int c = cps[i];
            if (c == 0) {
                reportar(token, coluna + i, "caractere U+0000 não é permitido em string");
                return;
            }
            if (c == '\\') {
                if (i + 1 >= cps.length) break;
                int esc = cps[i + 1];
                if ("nrt\"\\".indexOf(esc) < 0) {
                    reportar(token, coluna + i, "escape inválido '\\" + new String(Character.toChars(esc))
                            + "' em string (permitidos: \\n \\r \\t \\\" \\\\)");
                    return;
                }
                i++;
                continue;
            }
            if (c == '"' && i == cps.length - 1) return;
        }
        reportar(token, coluna, "string não fechada na mesma linha");
    }

    private static String descrever(int cp) {
        String hex = String.format("U+%04X", cp);
        return Character.isISOControl(cp) || Character.isWhitespace(cp) || Character.isSpaceChar(cp)
                ? hex
                : "'" + new String(Character.toChars(cp)) + "' (" + hex + ")";
    }

    private void reportar(Token token, int coluna, String mensagem) {
        getErrorListenerDispatch().syntaxError(this, token, token.getLine(), coluna, mensagem, null);
    }
}

// Espaços e comentários

BOM             : '\uFEFF' {_tokenStartCharIndex == 0}? -> skip ;
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

// Erros léxicos (por último, para que um token válido do mesmo tamanho vença)

// Numeral seguido de letras, dígitos ou pontos vira um único erro: 0b102, 007, 2contador.
ERRO_NUMERO
    : [1-9] CONTINUA_DECIMAL*
    | '0' ( [\p{Lu}\p{Lt}\p{Lm}\p{Lo}\p{M}\p{Nd}_.ac-wyz] | [eE] [+-] ) CONTINUA_DECIMAL*
    | '0' [\p{Ll}] CONTINUA_CANDIDATO*
    ;

fragment CONTINUA_CANDIDATO : [\p{L}\p{M}\p{Nd}_.] ;
fragment CONTINUA_DECIMAL   : CONTINUA_CANDIDATO | [eE] [+-] ;

ERRO_STRING
    : '"' ( CARACTERE_STRING | '\\' ~[\r\n] | '\u0000' )* ( '"' | '\\' )?
    ;

ERRO_COMENTARIO
    : '/*' ( ~'*' | '*'+ ~[*/] )* '*'*
    ;

ERRO_CARACTERE : . ;
