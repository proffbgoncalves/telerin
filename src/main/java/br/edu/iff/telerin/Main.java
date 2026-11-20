package br.edu.iff.telerin;

import java.io.FileDescriptor;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.Token;

public final class Main {

    private static final PrintStream OUT =
            new PrintStream(new FileOutputStream(FileDescriptor.out), true, StandardCharsets.UTF_8);
    private static final PrintStream ERR =
            new PrintStream(new FileOutputStream(FileDescriptor.err), true, StandardCharsets.UTF_8);

    private static final String EXEMPLO = "/exemplo.tel";

    private Main() {
    }

    public static void main(String[] args) {
        String caminho = null;
        for (String arg : args) {
            if (arg.equals("--tokens")) {
                continue;
            }
            if (arg.startsWith("--") || caminho != null) {
                uso();
            }
            caminho = arg;
        }

        String nome = caminho != null ? caminho : "exemplo.tel";
        String fonte;
        try {
            fonte = lerUtf8Estrito(caminho != null ? Files.readAllBytes(Path.of(caminho)) : lerExemplo());
        } catch (IOException e) {
            ERR.printf("%s: erro de leitura: %s%n", nome, e.getMessage());
            System.exit(1);
            return;
        }

        TelerinLexer lexer = new TelerinLexer(CharStreams.fromString(fonte, nome));
        ColetorErros errosLexicos = new ColetorErros(nome, "léxico", ERR);
        lexer.removeErrorListeners();
        lexer.addErrorListener(errosLexicos);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        tokens.fill();

        imprimirTokens(tokens);
        if (errosLexicos.getTotal() > 0) {
            ERR.printf("%d erro(s) léxico(s) em %s%n", errosLexicos.getTotal(), nome);
            System.exit(1);
        }
    }

    private static void uso() {
        ERR.println("uso: Main [--tokens] [arquivo.tel]");
        System.exit(2);
    }

    private static byte[] lerExemplo() throws IOException {
        try (InputStream stream = Main.class.getResourceAsStream(EXEMPLO)) {
            if (stream == null) {
                throw new IOException("recurso " + EXEMPLO + " não encontrado");
            }
            return stream.readAllBytes();
        }
    }

    // Byte UTF-8 malformado é erro de leitura, não vira U+FFFD.
    private static String lerUtf8Estrito(byte[] bytes) throws IOException {
        CharsetDecoder decoder = StandardCharsets.UTF_8.newDecoder()
                .onMalformedInput(CodingErrorAction.REPORT)
                .onUnmappableCharacter(CodingErrorAction.REPORT);
        try {
            CharBuffer texto = decoder.decode(ByteBuffer.wrap(bytes));
            return texto.toString();
        } catch (CharacterCodingException e) {
            throw new IOException("UTF-8 malformado " + localizarByteInvalido(bytes), e);
        }
    }

    private static String localizarByteInvalido(byte[] bytes) {
        CharsetDecoder decoder = StandardCharsets.UTF_8.newDecoder()
                .onMalformedInput(CodingErrorAction.REPORT)
                .onUnmappableCharacter(CodingErrorAction.REPORT);
        ByteBuffer entrada = ByteBuffer.wrap(bytes);
        CharBuffer saida = CharBuffer.allocate(bytes.length + 1);
        decoder.decode(entrada, saida, true);
        saida.flip();
        String lido = saida.toString();
        int linha = 1;
        int coluna = 1;
        for (int i = 0; i < lido.length(); ) {
            int cp = lido.codePointAt(i);
            i += Character.charCount(cp);
            if (cp == '\n' || (cp == '\r' && (i >= lido.length() || lido.charAt(i) != '\n'))) {
                linha++;
                coluna = 1;
            } else if (cp != '\r' && !(cp == 0xFEFF && i == 1)) {
                coluna++;
            }
        }
        return String.format("na linha %d, coluna %d (byte 0x%02X)",
                linha, coluna, bytes[entrada.position()] & 0xFF);
    }

    private static void imprimirTokens(CommonTokenStream tokens) {
        for (Token token : tokens.getTokens()) {
            String texto = token.getType() == Token.EOF ? "" : "'" + visivel(token.getText()) + "'";
            OUT.printf("%7s  %-20s %s%n",
                    token.getLine() + ":" + (token.getCharPositionInLine() + 1),
                    TelerinLexer.VOCABULARY.getSymbolicName(token.getType()),
                    texto);
        }
    }

    private static String visivel(String texto) {
        StringBuilder sb = new StringBuilder();
        texto.codePoints().forEach(cp -> {
            switch (cp) {
                case '\n' -> sb.append("\\n");
                case '\r' -> sb.append("\\r");
                case '\t' -> sb.append("\\t");
                default -> {
                    if (Character.isISOControl(cp) || cp == 0xFEFF || cp == 0x00A0) {
                        sb.append(String.format("\\u{%04X}", cp));
                    } else {
                        sb.appendCodePoint(cp);
                    }
                }
            }
        });
        return sb.toString();
    }
}
