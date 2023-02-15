simples: lexico.l sintatico.y;
	flex -o lexico.c lexico.l;\
	bison -v -d sintatico.y -o sintatico.c;\
	gcc sintatico.c -o simples;
limpa:
	rm lexico.c sintatico.c sintatico.h sintatico.output simples
erro: ;
	echo "teste1";\
	./simples testesErro/teste1.simples;\
	echo "teste2";\
	./simples testesErro/teste2.simples;\
	echo "teste3";\
	./simples testesErro/teste3.simples;\
	echo "teste4";\
	./simples testesErro/teste4.simples;\
	echo "teste5";\
	./simples testesErro/teste5.simples;\
	echo "teste6";\
	./simples testesErro/teste6.simples;\
	echo "teste7";\
	./simples testesErro/teste7.simples;\
	echo "teste8";\
	./simples testesErro/teste8.simples;\
	echo "teste9";\
	./simples testesErro/teste9.simples;\
	echo "teste10";\
	./simples testesErro/teste10.simples;\
	echo "teste11";\
	./simples testesErro/teste11.simples;\
	echo "teste12";\
	./simples testesErro/teste12.simples;