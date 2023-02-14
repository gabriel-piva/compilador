/*
+=============================================================
| UNIFAL = Universidade Federal de Alfenas .
| BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho.. : Funcao com retorno
| Disciplina : Teoria de Linguagens e Compiladores
| Professor. : Luiz Eduardo da Silva
| Aluno..... : Gabriel Piva Pereira
| Data...... : 09/02/2023
+============================================================= 
*/

// ----------------------------------------------------------------------

// Estrutura da Tabela de Simbolos

#include <ctype.h>
#define TAM_TAB 100
#define MAX_PAR 20

// Tipo da varíavel
enum {
    INT, 
    LOG
};

struct elemTabSimbolos {
    char id[100];      // Identificador
    int end;           // Endereço (global) ou deslocamento (local)
    int tip;           // Tipo da Variavel
    char cat;          // Categoria do simbolo (f = função, p = parametro, v = variável)
    char esc;          // Escopo da variável (g = global, l = local)
    int rot;           // Rotulo da função
    int npar;          // Número de parâmetros da função
    int par[MAX_PAR];  // Parâmetros da função (tipo)
} tabSimb[TAM_TAB], elemTab;

int posTab = 0;

// ----------------------------------------------------------------------

// Funções de Operação na Tabela de Símbolos

void maiuscula (char *s) {
    for (int i = 0; s[i]; i++)
        s[i] = toupper(s[i]); 
}

int buscaSimbolo(char *id) {
    int i;
    // maiuscula(id);        // Diferenciação entre variáveis maiúsculas e minúsculas
    for(i = posTab - 1; strcmp(tabSimb[i].id, id) && i >= 0; i--)
        ;
    if (i == -1) {
        char msg[200];
        sprintf(msg, "Identificador [%s] não encontrado!", id);
        yyerror(msg);       // Linha em que o erro foi encontrado e mensagem
    }
    return i;
}

void insereSimbolo(struct elemTabSimbolos elem) {
    int i;
    // maiuscula(elem.id);       // Diferenciação entre variáveis maiúsculas e minúsculas
    if(posTab == TAM_TAB) 
        yyerror("Tabela de Simbolos Cheia!");
    //for(i = posTab - 1; strcmp(tabSimb[i].id, elem.id) && i >= 0; i--)
    for(i = posTab - 1; (strcmp(tabSimb[i].id, elem.id) || tabSimb[i].esc != 'l') && i >= 0; i--)
        ;
    if (i != -1) {
        char msg[200];
        sprintf(msg, "Identificador [%s] duplicado!", elem.id);
        yyerror(msg);
    }
    tabSimb[posTab++] = elem;
}

void mostraTabela() {
    puts("----------------------");
    puts("| Tabela de Simbolos |");
    puts("----------------------");
    printf("%30s | %s | %s | %s | %s | %s  | %s | %s\n", "ID", "END", "TIP", "CAT", "ESC", "ROT", "NPAR", "PAR");
    for (int i = 0; i < 100; i++)
        printf("-");
    for (int i = 0; i < posTab; i++) {
        printf(
            "\n%30s | %3d | %s | %s | %3c |", 
            tabSimb[i].id, 
            tabSimb[i].end, 
            tabSimb[i].tip == INT ? "INT" : "LOG", 
            tabSimb[i].cat == 'v' ? "VAR" : tabSimb[i].cat == 'f' ? "FUN" : "PAR", 
            tabSimb[i].esc
        );
        if(tabSimb[i].cat == 'f') {
            printf(" L%2d  | %4d |", 
                tabSimb[i].rot, 
                tabSimb[i].npar
            );
            for(int j = 0; j < tabSimb[i].npar; j++) {
                printf(" [ %s ", tabSimb[i].par[j] == INT ? "INT" : "LOG");
                printf("]");
            }
        } else {
            printf("   -  |   -  |  - ");
        }
    }
    printf("\n");
}

// ----------------------------------------------------------------------

// Estrutura da Pilha Semântica
// Usada para endereços, viaráveis, rótulos

#define TAM_PIL 100
int topo = -1;

// Sugestão para a pilha
struct {
    int valor;
    char tipo; // r rotulo, n numero de variaveis, t tipo e p posicao
} pilha[TAM_PIL];

void empilha (int valor, char tipo) {
    if (topo == TAM_PIL)
        yyerror ("Pilha semântica cheia!");
    pilha[++topo].valor = valor;
    pilha[topo].tipo = tipo;
}

void mostraPilha(){
    int i = topo;
    printf("Pilha = [ ");
    while (i >=0) {
        printf("(%d, %c) ", pilha[i].valor, pilha[i].tipo);
        i--;
    }
    printf("]\n");
}

int desempilha(char tipo) {
    if (topo == -1) 
        yyerror("Pilha semântica vazia!");
    if (pilha[topo].tipo != tipo) {
        char msg[100];
        sprintf(msg, "Erro ao desempilhar: esperava [%c] e encontrou [%c]", tipo, pilha[topo].tipo);
        // mostraPilha();
        yyerror(msg);
    }
    return pilha[topo--].valor;
}

// ----------------------------------------------------------------------

// Teste de tipo de variável para operadores

void testaTipo(int tipo1, int tipo2, int ret) {
    int t1 = desempilha('t');
    int t2 = desempilha('t');
    if(t1 != tipo1 || t2 != tipo2)
        yyerror("Incompatibilidade de tipo!");
    empilha(ret, 't');
}

// ----------------------------------------------------------------------

// Função para ajustar endereço dos parâmetros

void ajustarParametros(int pos, int contaPar) {
    int inicio = -3;
    int posicaoFuncao = pos - contaPar;
    for (int i = pos; i >= posicaoFuncao; i--) {
        tabSimb[i].end = inicio; 
        inicio--;       
    } 
    tabSimb[posicaoFuncao].npar = contaPar;
}

// ----------------------------------------------------------------------

// Função para remover as variáveis locais da tabela de símbolos

void removerLocais(int pos) {
    while(tabSimb[pos+1].esc == 'l') {
        pos++;
        posTab--;
    }
}

// ----------------------------------------------------------------------