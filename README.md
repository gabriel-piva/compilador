# Compilador

Projeto final da disciplina de Teoria de Linguagens e Compiladores, da Universidade Federal de Alfenas (Unifal).

O compilador é desenvolvido para a linguagem Simples, uma linguagem semelhante a portugol com os termos em português. Exemplo:

``` cpp
programa fatorial
inteiro x

func inteiro fatorial (inteiro a)
inicio
    se a > 0
        entao retorne a * fatorial (a - 1)
        senao retorne 1
  fimse
fimfunc

inicio 
  leia x
  escreva fatorial (x)

fimprograma
```

O compilador utiliza Flex e Bison do Unix e usando os arquivos lexico.l e sintatico.y, transforma os códigos .simples em arquivos .mvs, com instruções. MVS vem de Máquina Virtual Simples.
O código simples mostrado seria traduzido para o seguinte .mvs:

```
	INPP
	AMEM	1
	DSVS	L0
L1	ENSP
	CRVL	-3
	CRCT	0
	CMMA
	DSVF	L2
	CRVL	-3
	AMEM	1
	CRVL	-3
	CRCT	1
	SUBT
	SVCP
	DSVS	L1
	MULT
	ARZL	-4
	RTSP	1
	DSVS	L3
L2	NADA
	CRCT	1
	ARZL	-4
	RTSP	1
L3	NADA
L0	NADA
	LEIA
	ARZG	0
	AMEM	1
	CRVG	0
	SVCP
	DSVS	L1
	ESCR
	DMEM	1
	FIMP
```

Usando o executável mvs do arquivo mvs.c, é realizada a leitura do arquivo .mvs e as intruções são executadas, mostrando as saídas no console.