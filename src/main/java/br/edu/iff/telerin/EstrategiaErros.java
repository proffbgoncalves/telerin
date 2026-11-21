package br.edu.iff.telerin;

import java.util.ArrayList;
import java.util.List;
import org.antlr.v4.runtime.DefaultErrorStrategy;
import org.antlr.v4.runtime.FailedPredicateException;
import org.antlr.v4.runtime.InputMismatchException;
import org.antlr.v4.runtime.NoViableAltException;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.Vocabulary;
import org.antlr.v4.runtime.atn.ATN;
import org.antlr.v4.runtime.misc.IntervalSet;

// Mensagens de erro sintático em português; a recuperação continua a padrão do ANTLR.
public final class EstrategiaErros extends DefaultErrorStrategy {

    private static final int MAX_ESPERADOS = 8;

    private static final IntervalSet RELACIONAIS = new IntervalSet(
            TelerinLexer.LT, TelerinLexer.LE, TelerinLexer.GT,
            TelerinLexer.GE, TelerinLexer.EQ, TelerinLexer.NE);

    @Override
    protected void reportNoViableAlternative(Parser parser, NoViableAltException e) {
        Token ofensor = e.getOffendingToken();
        String mensagem = ofensor.getType() == Token.EOF
                ? "o arquivo terminou antes do fim da construção"
                : descrever(ofensor) + " não era esperado aqui";
        parser.notifyErrorListeners(ofensor, mensagem, e);
    }

    @Override
    protected void reportInputMismatch(Parser parser, InputMismatchException e) {
        Token ofensor = e.getOffendingToken();
        IntervalSet esperados = e.getExpectedTokens();
        String mensagem = comparacaoEncadeada(ofensor, esperados)
                ? "comparações não podem ser encadeadas: " + descrever(ofensor)
                        + " aparece depois de outra comparação (use ye para combinar)"
                : "encontrado " + descrever(ofensor) + ", mas era esperado " + listar(parser, esperados);
        parser.notifyErrorListeners(ofensor, mensagem, e);
    }

    @Override
    protected void reportFailedPredicate(Parser parser, FailedPredicateException e) {
        parser.notifyErrorListeners(e.getOffendingToken(),
                "construção inválida na regra " + parser.getRuleNames()[parser.getContext().getRuleIndex()], e);
    }

    @Override
    protected void reportUnwantedToken(Parser parser) {
        if (inErrorRecoveryMode(parser)) {
            return;
        }
        beginErrorCondition(parser);
        Token atual = parser.getCurrentToken();
        String mensagem = descrever(atual) + " sobrando; era esperado "
                + listar(parser, getExpectedTokens(parser));
        parser.notifyErrorListeners(atual, mensagem, null);
    }

    @Override
    protected void reportMissingToken(Parser parser) {
        if (inErrorRecoveryMode(parser)) {
            return;
        }
        beginErrorCondition(parser);
        Token atual = parser.getCurrentToken();
        String mensagem = chamadaSemEla(parser, atual)
                ? "chamada usada como comando precisa de 'ela': escreva ela "
                        + parser.getInputStream().LT(-1).getText() + "(...);"
                : "falta " + listar(parser, getExpectedTokens(parser)) + " antes de " + descrever(atual);
        parser.notifyErrorListeners(atual, mensagem, null);
    }

    private static String descrever(Token token) {
        return switch (token.getType()) {
            case Token.EOF -> "fim do arquivo";
            case TelerinLexer.ID -> "identificador '" + token.getText() + "'";
            case TelerinLexer.INT_LITERAL, TelerinLexer.FLOAT_LITERAL -> "numeral '" + token.getText() + "'";
            case TelerinLexer.STRING_LITERAL -> "texto " + token.getText();
            default -> "'" + token.getText() + "'";
        };
    }

    // a < b < c: depois de uma comparação, o operador relacional deixa de ser esperado.
    private static boolean comparacaoEncadeada(Token ofensor, IntervalSet esperados) {
        return RELACIONAIS.contains(ofensor.getType())
                && esperados.contains(TelerinLexer.AND)
                && !esperados.contains(TelerinLexer.LT);
    }

    private static boolean chamadaSemEla(Parser parser, Token atual) {
        return atual.getType() == TelerinLexer.LPAREN
                && parser.getContext() instanceof TelerinParser.AtribuicaoContext
                && parser.getInputStream().LT(-1).getType() == TelerinLexer.ID;
    }

    private static String listar(Parser parser, IntervalSet esperados) {
        List<String> nomes = new ArrayList<>();
        IntervalSet restantes = new IntervalSet(esperados);
        restantes = resumir(parser, TelerinParser.RULE_expressao, "expressão", restantes, nomes);
        restantes = resumir(parser, TelerinParser.RULE_tipo, "tipo", restantes, nomes);
        for (int tipo : restantes.toList()) {
            nomes.add(nomeEsperado(tipo, parser.getVocabulary()));
        }
        if (nomes.isEmpty()) {
            return "outro símbolo";
        }
        if (nomes.size() == 1) {
            String unico = nomes.get(0);
            return switch (unico) {
                case "expressão" -> "uma expressão";
                case "tipo" -> "um tipo";
                default -> unico;
            };
        }
        if (nomes.size() > MAX_ESPERADOS) {
            return "um de " + String.join(", ", nomes.subList(0, MAX_ESPERADOS)) + ", entre outros";
        }
        return "um de " + String.join(", ", nomes);
    }

    // Se todo início possível da regra é esperado, a lista diz só "expressão" ou "tipo".
    private static IntervalSet resumir(Parser parser, int regra, String nome,
            IntervalSet esperados, List<String> nomes) {
        ATN atn = parser.getATN();
        IntervalSet inicio = atn.nextTokens(atn.ruleToStartState[regra]);
        if (inicio.isNil() || !inicio.subtract(esperados).isNil()) {
            return esperados;
        }
        nomes.add(nome);
        return esperados.subtract(inicio);
    }

    private static String nomeEsperado(int tipo, Vocabulary vocabulario) {
        switch (tipo) {
            case Token.EOF:
                return "fim do arquivo";
            case TelerinLexer.ID:
                return "identificador";
            case TelerinLexer.INT_LITERAL:
                return "numeral inteiro";
            case TelerinLexer.FLOAT_LITERAL:
                return "numeral real";
            case TelerinLexer.STRING_LITERAL:
                return "texto entre aspas";
            default:
                String literal = vocabulario.getLiteralName(tipo);
                return literal != null ? desescaparUnicode(literal) : vocabulario.getDisplayName(tipo);
        }
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
}
