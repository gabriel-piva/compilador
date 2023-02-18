simples: lexico.l sintatico.y;
	flex -o lexico.c lexico.l;\
	bison -v -d sintatico.y -o sintatico.c;\
	gcc sintatico.c -o simples;
limpa:
	rm lexico.c sintatico.c sintatico.h sintatico.output simples
teste: 
	echo "\n\nTestes:";\
	echo "\nTeste1";\
	./simples testes/t1;\
	echo "\nTeste2";\
	./simples testes/t2;\
	echo "\nTeste3";\
	./simples testes/t3;\
	echo "\nTeste4";\
	./simples testes/t4;\
	echo "\nTeste5";\
	./simples testes/t5;\
	echo "\nTeste6";\
	./simples testes/t6;\
	echo "\nTeste7";\
	./simples testes/t7;\
	echo "\nTeste8";\
	./simples testes/t8;\
	echo "\nTeste9";\
	./simples testes/t9;\
	echo "\nTeste10";\
	./simples testes/t10;\
	echo "\nTeste11";\
	./simples testes/t11;\
	echo "\nTeste12";\
	./simples testes/t12;\
	echo "\nFim dos Testes\n\n";