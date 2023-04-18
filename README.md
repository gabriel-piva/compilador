# Compilador

Projeto final da disciplina Teoria de Linguagens e Compiladores, do curso de Ciência da Computação da Universidade Federal de Alfenas (UNIFAL).

O compilador é desenvolvido para a linguagem Simples, uma linguagem semelhante a portugol.

O compilador utiliza Flex e Bison do Unix e transforma os códigos _.simples_ em arquivos de instruções _.mvs_ (em que MVS vem de Máquina Virtual Simples).

### Utilização

Para gerar o executável **simples** no terminal Ubuntu:
```
flex -o lexico.c lexico.l
bison -v -d sintatico.y -o sintatico.c
gcc sintatico.c -o simples
```
Ou através do arquivo makefile, com o comando ```make```.

Com o executável **simples**, para compilar um programa _.simples_:
```
./simples <NOME>[.simples]
```
Ao compilar, também são realizadas várias verificações no arquivo, para garantir que não há nenhum erro no código. Caso exista algum erro, ele é alertado no terminal. 

O resultado é um arquivo _NOME.mvs_, que possui as instruções para serem interpretadas. 

A interpretação é realizada pelo executável **mvs**, resultado do arquivo _mvs.c_ presente no repositório. 
Para interpretar um arquivo _.mvs_:
```
./mvs <NOME>[.mvs]
```
Como resultado da execução, as instruções do programa original _.simples_ são interpretadas e executadas no terminal, recebendo entradas pelo próprio terminal e mostrando as saídas, por exemplo. 

### Exemplo

Será compilado e executado o seguinte programa em simples, que calcula o fatorial de um número recebido como entrada:

```cpp
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

Para compilar o programa, no terminal:
```
make 
./simples fatorial.simples
```

O resultado será o seguinte arquivo mvs:

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

Com o executável **mvs** na pasta, para interpretar as intruções:
```
./mvs fatorial.mvs
```
O resultado será a seguinte execução no terminal:
```
./mvs fatorial.mvs
? 5
Saida = 120

Fim do programa.
```

O terminal com a execução completa:
```
> gpiva@S1:/compilador$ make
	flex -o lexico.c lexico.l;\
	bison -v -d sintatico.y -o sintatico.c;\
	gcc sintatico.c -o simples;

> gpiva@S1:/compilador$ ./simples exemplos/fatorial.simples
	Programa OK!

> gpiva@S1:/compilador$ ./mvs exemplos/fatorial.mvs
	? 5
	Saida = 120

	Fim do programa.
```

#### Requisitos para utilização

- Terminal Ubuntu com Flex e Bison instalados.
```
flex -> sudo apt install flex
bison -> sudo apt install bison
```