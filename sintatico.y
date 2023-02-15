/*
+=============================================================
| UNIFAL = Universidade Federal de Alfenas .
| BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho.. : Funcao com retorno
| Disciplina : Teoria de Linguagens e Compiladores
| Professor. : Luiz Eduardo da Silva
| Aluno..... : Gabriel Piva Pereira
| Data...... : 15/02/2023
+============================================================= 
*/

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

#include "lexico.c"
#include "utils.c"
int contaVar;           // Número de variáveis declaradas GLOBAIS
int contaLoc;           // Número de variáveis declaradas LOCAIS
int contaPar;           // Auxiliar para contar parâmetros de cada função
int rotulo = 0;         // Marcar lugares no código
int tipo;               // Tipo das variáveis
char escopo = 'g';      // Escopo das variáveis
int posFunc;            // Posição da função
bool retornou = false;  // Verifica se a função retornou
%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_LEIA
%token T_ESCREVA
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_INTEIRO
%token T_LOGICO
%token T_MAIS
%token T_MENOS
%token T_VEZES
%token T_DIV
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_ATRIBUI
%token T_V
%token T_F
%token T_IDENTIF
%token T_NUMERO 

%token T_FUNC
%token T_FIMFUNC
%token T_RETORNE

%start programa
%expect 1

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%
programa 
    : cabecalho 
        { contaVar = 0; }
      variaveis 
        {
            //mostraTabela();
            empilha(contaVar, 'n'); 
            if (contaVar) 
                fprintf(yyout,"\tAMEM\t%d\n", contaVar); 
        }
      rotinas
      T_INICIO 
        {
            // mostraTabela();
        }
        lista_comandos T_FIM
        {
            int conta = desempilha('n');
            if (conta)
                fprintf(yyout, "\tDMEM\t%d\n", conta); 
            fprintf(yyout, "\tFIMP\n");
        }
    ;
cabecalho
    : T_PROGRAMA T_IDENTIF
        { fprintf(yyout, "\tINPP\n"); }
    ;
    
variaveis
    : /* vazio */
    | declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;

tipo
    : T_LOGICO
        { tipo = LOG; }
    | T_INTEIRO
        { tipo = INT; }
    ;

lista_variaveis 
    : lista_variaveis T_IDENTIF 
        { 
            strcpy(elemTab.id, atomo);
            elemTab.cat = 'v';
            elemTab.tip = tipo;
            elemTab.esc = escopo;
            if(elemTab.esc == 'l') {
                elemTab.end = contaLoc;
                contaLoc++;
            } else { 
                elemTab.end = contaVar;
                contaVar++;
            }
            insereSimbolo(elemTab);
        }
    | T_IDENTIF
        { 
            strcpy(elemTab.id, atomo);
            elemTab.cat = 'v';
            elemTab.tip = tipo;
            elemTab.esc = escopo;
            if(elemTab.esc == 'l') {
                elemTab.end = contaLoc;
                contaLoc++;
            } else { 
                elemTab.end = contaVar;
                contaVar++;
            }
            insereSimbolo(elemTab);
        }
    ;

rotinas
    : /* Não tem função*/
    | 
        { fprintf(yyout, "\tDSVS\tL%d\n", 0); }
        funcoes
        { fprintf(yyout, "L%d\tNADA\n", 0); }
    ;

funcoes
    : funcao
    | funcao funcoes
    ;

funcao
    : T_FUNC 
        {
            contaPar = 0;
            retornou = false;
        }
      tipo T_IDENTIF 
        {
            strcpy(elemTab.id, atomo);
            elemTab.tip = tipo;
            elemTab.cat = 'f';
            elemTab.esc = escopo;
            elemTab.rot = ++rotulo;

            elemTab.end = contaVar;
            contaVar++;

            insereSimbolo(elemTab);
            posFunc = buscaSimbolo(atomo);

            fprintf(yyout, "L%d\tENSP\n", rotulo); 

            contaLoc = 0;  
            escopo = 'l';
        }
      T_ABRE parametros T_FECHA 
        {
            int pos = buscaSimbolo(atomo);
            ajustarParametros(pos, contaPar);
        }
      variaveis 
        {
            if (contaLoc > 0) 
                fprintf(yyout,"\tAMEM\t%d\n", contaLoc); 
        } 
      T_INICIO lista_comandos T_FIMFUNC
        {
            escopo = 'g';
            contaPar = 0;

            // puts("\n\nFinalização da função: ");
            // puts("Antes de remover locais;\n");
            // mostraTabela();// Antes de remover as variáveis Loc e Par

            removerLocais(posFunc);

            // puts("Depois de remover locais;\n");
            // mostraTabela(); // Após remover as Loc e Par

            if(!retornou) yyerror("Função não possui retorno.");
        }
    ;

parametros
    : /* vazio */
    | parametro parametros
    ;

parametro
    : tipo T_IDENTIF
        {
            strcpy(elemTab.id, atomo);
            elemTab.tip = tipo;
            elemTab.cat = 'p';
            elemTab.esc = escopo;
            tabSimb[posFunc].par[contaPar] = tipo;
            contaPar++;
            insereSimbolo(elemTab);
        }
    ;

lista_comandos
    : /* vazio */
    | comando lista_comandos
    ;

comando 
    : entrada_saida
    | repeticao
    | selecao
    | atribuicao
    | retorno
    ;

retorno
    : T_RETORNE expressao
        {
            // mostraPilha();
            // ARZL (valor de retorno) (Ex -4)
            // DMEM (se tiver variavel local) numero de váriaveis locais
            // RTSP (n)

            int tip = desempilha('t');
            if (tabSimb[posFunc].tip != tip)
                yyerror("Incompatibilidade de tipo!");

            fprintf(yyout, "\tARZL\t%d\n", tabSimb[posFunc].end);

            if (contaLoc > 0)
                fprintf(yyout, "\tDMEM\t%d\n", contaLoc);

            fprintf(yyout,"\tRTSP\t%d\n", contaPar);

            retornou = true;
        }
    ;
    
entrada_saida
    : leitura
    | escrita
    ;

leitura
    : T_LEIA T_IDENTIF
        {
            int pos = buscaSimbolo(atomo);
            if (tabSimb[pos].esc == 'g')
                fprintf(yyout,"\tLEIA\n\tARZG\t%d\n", tabSimb[pos].end); 
            else
                fprintf(yyout,"\tLEIA\n\tARZL\t%d\n", tabSimb[pos].end);            
        }
    ;

escrita
    : T_ESCREVA expressao
        { 
            desempilha('t');
            fprintf(yyout, "\tESCR\n"); 
        }
    ;

repeticao
    : T_ENQTO 
        { 
            fprintf(yyout, "L%d\tNADA\n", ++rotulo);
            empilha(rotulo, 'r');
        }
      expressao T_FACA 
        { 
            int tip = desempilha('t');
            if(tip != LOG)
                yyerror("Incompatibilidade de tipo!");
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo, 'r');
        }
      lista_comandos 
      T_FIMENQTO
        { 
            int rot1 = desempilha('r');
            int rot2 = desempilha('r');
            fprintf(yyout, "\tDSVS\tL%d\n", rot2);
            fprintf(yyout, "L%d\tNADA\n", rot1); 
        }
    ;

selecao
    : T_SE expressao T_ENTAO 
        { 
            int tip = desempilha('t');
            //puts("Aqui2");
            if(tip != LOG)
                yyerror("Incompatibilidade de tipo!");
            fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo);
            empilha(rotulo, 'r');
        }
      lista_comandos T_SENAO 
        { 
            int rot = desempilha('r');
            fprintf(yyout, "\tDSVS\tL%d\n", ++rotulo);
            fprintf(yyout, "L%d\tNADA\n", rot);
            empilha(rotulo, 'r');
        }
      lista_comandos T_FIMSE
        { 
            int rot = desempilha('r');
            fprintf(yyout, "L%d\tNADA\n", rot); 
        }
    ;

atribuicao
    : T_IDENTIF
        {
            int pos = buscaSimbolo(atomo);
            empilha(pos, 'p');
        }
      T_ATRIBUI expressao
        { 
            int tip = desempilha('t');
            int pos = desempilha('p');
            if(tabSimb[pos].tip != tip)
                yyerror("Incompatibilidade de tipo");

            if(tabSimb[pos].esc == 'g') {
                fprintf(yyout,"\tARZG\t%d\n", tabSimb[pos].end); 
            } else { 
                fprintf(yyout,"\tARZL\t%d\n", tabSimb[pos].end);
            }
        }
    ;

expressao 
    : expressao T_VEZES expressao
        {
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tMULT\n");
        }
    | expressao T_DIV expressao
        { 
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tDIVI\n");
        }
    | expressao T_MAIS expressao
        {
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tSOMA\n");
        }
    | expressao T_MENOS expressao
        {
            testaTipo(INT, INT, INT);
            fprintf(yyout, "\tSUBT\n");
        }
    | expressao T_MAIOR expressao
        { 
            testaTipo(INT, INT, LOG);
            fprintf(yyout, "\tCMMA\n");
        }
    | expressao T_MENOR expressao
        {
            testaTipo(INT, INT, LOG);
            fprintf(yyout, "\tCMME\n"); 
        }
    | expressao T_IGUAL expressao
        {
            testaTipo(INT, INT, LOG);
            fprintf(yyout, "\tCMIG\n"); 
        }
    | expressao T_E expressao
        {
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout, "\tCONJ\n"); 
        }
    | expressao T_OU expressao
        { 
            testaTipo(LOG, LOG, LOG);
            fprintf(yyout, "\tDISJ\n"); 
        }
    | termo
    ;

identificador 
    : T_IDENTIF
        {
            int pos = buscaSimbolo(atomo);
            empilha(pos, 'p');
        }
    ;

chamada
    : /* vazio */
        {
            // Aqui é uma variável global ou local normal
            int pos = desempilha('p');
            if(tabSimb[pos].cat == 'f') yyerror("Função precisa dos parêteses.");
            if(tabSimb[pos].esc == 'g') {
                fprintf(yyout, "\tCRVG\t%d\n", tabSimb[pos].end);
            } else {
                fprintf(yyout, "\tCRVL\t%d\n", tabSimb[pos].end);
            }
            empilha(tabSimb[pos].tip, 't');
        }
    | T_ABRE 
        {
            fprintf(yyout,"\tAMEM\t%d\n", 1);
            posFunc = buscaSimbolo(atomo);
            empilha(tabSimb[posFunc].npar, 'a');
            //nParametros = 0;
        }
      lista_argumentos 
        {
            // auxPar = 0;
        }
      T_FECHA
        {
            int nParametros = desempilha('a');
            if(nParametros != 0){
                if(nParametros > 0) yyerror("Número de parâmetros insuficiente na função.");
                if(nParametros < 0) yyerror("Parâmetro inesperado na função.");
            } 
            
            int pos = desempilha('p');
            fprintf(yyout, "\tSVCP\n");
            fprintf(yyout, "\tDSVS\tL%d\n", tabSimb[pos].rot);
            empilha(tabSimb[pos].tip, 't');
        }
    ;

lista_argumentos
    : /* vazio */
    | expressao 
        {
            // Depois de cada expressão sobra o tipo
            int tip = desempilha('t');

            int nParametros = desempilha('a');

            int auxPar = tabSimb[posFunc].npar - nParametros;

            nParametros--;
            empilha(nParametros, 'a');

            if(auxPar < tabSimb[posFunc].npar) {
                if(tabSimb[posFunc].par[auxPar] != tip) yyerror("Incompatibilidade de tipo nos parâmetros da função.");
            }

        }
      lista_argumentos
        {
            //int aux = tabSimb[posFunc].npar - 1;
            // for(int i = aux; i >= 0; i--) {
            //     printf("i = %d, valor = %d\n", i, tabSimb[posFunc].par[i]);
            //     // mostraPilha();
            //     int t = desempilha('t');
            //     if(tabSimb[posFunc].par[i] != t) {
            //         yyerror("Incompatibilidade de tipo nos parâmetros da função.");
            //     }
            // }
        }
    ;

termo 
    : identificador chamada
    | T_NUMERO
        { 
            fprintf(yyout, "\tCRCT\t%s\n", atomo);
            empilha(INT, 't');
        }
    | T_V
        { 
            fprintf(yyout, "\tCRCT\t1\n");
            empilha(LOG, 't');
        }
    | T_F
        { 
            fprintf(yyout, "\tCRCT\t0\n");
            empilha(LOG, 't');
        }
    | T_NAO termo
        {
            int t = desempilha('t');
            if(t != LOG) yyerror("Incompatibilidade de tipo!");
            fprintf(yyout, "\tNEGA\n");
            empilha(LOG, 't');
        }
    | T_ABRE expressao T_FECHA
    ;
%%

int main(int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if(argc < 2) {
        puts("\nCompilador Simples");
        puts("\n\tUso: ./simples <NOME>[.simples]\n\n");
        exit(10);
    }
    p = strstr(argv[0], ".simples");
    if(p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");
    yyin = fopen(nameIn, "rt");
    if(!yyin) {
        puts("\nPrograma fonte não encontrado!\n");
        exit(20);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    puts("Programa OK!");
}
