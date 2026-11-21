package br.edu.iff.telerin;

import java.io.PrintStream;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.TerminalNode;

// Árvore sintática indentada: regras pelo nome, folhas como TIPO 'texto'.
final class ArvoreSintatica {

    private static final String RECUO = "  ";

    private final Parser parser;
    private final PrintStream saida;

    ArvoreSintatica(Parser parser, PrintStream saida) {
        this.parser = parser;
        this.saida = saida;
    }

    void imprimir(ParseTree no) {
        imprimir(no, 0);
    }

    private void imprimir(ParseTree no, int nivel) {
        String recuo = RECUO.repeat(nivel);
        if (no instanceof ErrorNode erro) {
            saida.println(recuo + "<erro> '" + erro.getText() + "'");
        } else if (no instanceof TerminalNode folha) {
            saida.println(recuo + descreverFolha(folha.getSymbol()));
        } else if (no instanceof ParserRuleContext regra) {
            saida.println(recuo + parser.getRuleNames()[regra.getRuleIndex()]);
            for (int i = 0; i < regra.getChildCount(); i++) {
                imprimir(regra.getChild(i), nivel + 1);
            }
        }
    }

    private String descreverFolha(Token token) {
        String tipo = parser.getVocabulary().getSymbolicName(token.getType());
        return token.getType() == Token.EOF ? tipo : tipo + " '" + token.getText() + "'";
    }
}
