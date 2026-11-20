package br.edu.iff.telerin;

import java.io.PrintStream;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

public final class ColetorErros extends BaseErrorListener {

    private final String arquivo;
    private final String fase;
    private final PrintStream saida;
    private int total;

    public ColetorErros(String arquivo, String fase, PrintStream saida) {
        this.arquivo = arquivo;
        this.fase = fase;
        this.saida = saida;
    }

    @Override
    public void syntaxError(Recognizer<?, ?> recognizer, Object simboloOfensor,
            int linha, int coluna, String mensagem, RecognitionException e) {
        total++;
        saida.printf("%s:%d:%d: erro %s: %s%n", arquivo, linha, coluna + 1, fase, mensagem);
    }

    public int getTotal() {
        return total;
    }
}
