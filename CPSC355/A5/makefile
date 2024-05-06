all:	a5amain.o a5a.o
	gcc -o a5a a5amain.o a5a.o


a5amain.o: a5amain.c
	gcc -c a5amain.c


a5a.o: a5a.asm
	m4 a5a.asm > a5a.s
	as a5a.s -o a5a.o
