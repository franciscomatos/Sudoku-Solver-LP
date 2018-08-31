:- include('SUDOKU').

/*Predicados para a propagacao de mudancas*/

tira_num_aux(Num,Puz,Pos,N_Puz):-puzzle_ref(Puz,Pos,Cont),
								 member(Num,Cont), /*e necessario o numero Num estar na posicao Pos*/
								 subtract(Cont,[Num],N_Cont),
								 puzzle_muda_propaga(Puz,Pos,N_Cont,N_Puz),!.

tira_num_aux(_,Puz,_,Puz).


tira_num(Num,Puz,Posicoes,N_Puz):-percorre_muda_Puz(Puz,tira_num_aux(Num),Posicoes,N_Puz).


puzzle_muda_propaga(Puz,Pos,Cont,N_Puz):-length(Cont,1),
										 !,
										 posicoes_relacionadas(Pos,Posicoes),
										 nth1(1,Cont,X),
										 puzzle_muda(Puz,Pos,[X],N_Puz2),
										 tira_num(X,N_Puz2,Posicoes,N_Puz).

puzzle_muda_propaga(Puz,Pos,Cont,N_Puz):-puzzle_muda(Puz,Pos,Cont,N_Puz).

/*Predicados para a inicializacao de puzzles*/

possibilidades(Pos,Puz,Poss):-numeros(L),
							  posicoes_relacionadas(Pos,Posicoes),
							  conteudos_posicoes(Puz,Posicoes,Conteudos),
							  possibilidades_aux(L,Conteudos,Poss).

possibilidades_aux(Poss,[],Poss).

possibilidades_aux(L,[P|R],Poss):-length(P,1),
							 	  subtract(L,P,Poss2), /*vai retirando da lista de numeros possiveis os numeros nas posicoes relacionadas cujo conteudo e uma sequencia unitaria*/
							 	  possibilidades_aux(Poss2,R,Poss).

possibilidades_aux(L,[_|R],Poss):-possibilidades_aux(L,R,Poss).


inicializa_aux(Puz,Pos,N_Puz):-puzzle_ref(Puz,Pos,Cont),
						       length(Cont,X),
						       X==0, /*este predicado apenas deve ser usado em posicoes vazias*/
							   possibilidades(Pos,Puz,Poss),
							   puzzle_muda_propaga(Puz,Pos,Poss,N_Puz).
							   
inicializa_aux(N_Puz,_,N_Puz).


inicializa(Puz,N_Puz):-todas_posicoes(Todas_Posicoes),
					   percorre_muda_Puz(Puz,inicializa_aux,Todas_Posicoes,N_Puz).

/*Predicados para a inspecao de puzzles*/


so_aparece_uma_vez(Puz,Num,Posicoes,Pos_Num):-so_aparece_uma_vez(Puz,Num,Posicoes,[],Pos_Num). /*cria uma lista extra que vai guardar todas as posicoes em que Num ocorre*/

so_aparece_uma_vez_aux([Pos_Num|_],Pos_Num).

so_aparece_uma_vez(_,_,[],Pos_Aux,Pos_Num):-length(Pos_Aux,1),
											so_aparece_uma_vez_aux(Pos_Aux,Pos_Num).

so_aparece_uma_vez(_,_,[],Pos_Aux,_):- \+length(Pos_Aux,1), /*caso o Num ocorra em mais que uma posicao*/
									  false.

so_aparece_uma_vez(Puz,Num,[P|R],Pos_Aux,Pos_Num):-
												   puzzle_ref(Puz,P,Cont),
										   		   member(Num,Cont),
										   		   append([P],Pos_Aux,N_Pos_Aux),/*Adiciona P a lista de posicoes caso Num esteja apareca na posicao P*/
										   		   so_aparece_uma_vez(Puz,Num,R,N_Pos_Aux,Pos_Num).

so_aparece_uma_vez(Puz,Num,[P|R],Pos_Aux,Pos_Num):-puzzle_ref(Puz,P,Cont),
												   \+member(Num,Cont),
												   so_aparece_uma_vez(Puz,Num,R,Pos_Aux,Pos_Num).


inspecciona_num(Posicoes,Puz,Num,N_Puz):-so_aparece_uma_vez(Puz,Num,Posicoes,Pos_Num),
										 puzzle_ref(Puz,Pos_Num,Cont),
										 length(Cont,X),
										 X>1,
										 puzzle_muda_propaga(Puz,Pos_Num,[Num],N_Puz).

inspecciona_num(_,Puz,_,Puz).


inspecciona_grupo(Puz,Gr,N_Puz):-inspecciona_grupo(Puz,Gr,Gr,N_Puz).

inspecciona_grupo(N_Puz,_,[],N_Puz).

inspecciona_grupo(Puz,Gr,[P|R],N_Puz):-puzzle_ref(Puz,P,Cont),
									   length(Cont,1),
									   inspecciona_grupo(Puz,Gr,R,N_Puz).

inspecciona_grupo(Puz,Gr,[P|R],N_Puz):-puzzle_ref(Puz,P,Cont),
									   length(Cont,X),
									   X>1,
									   inspecciona_grupo_aux(Puz,Gr,Cont,N_Puz2), /*este predicado apenas e usado em posicoes cujo conteudo e uma lista nao unitaria*/
									   inspecciona_grupo(N_Puz2,Gr,R,N_Puz).

inspecciona_grupo_aux(N_Puz,_,[],N_Puz).

inspecciona_grupo_aux(Puz,Gr,[P|R],N_Puz):-inspecciona_num(Gr,Puz,P,N_Puz2),
										   inspecciona_grupo_aux(N_Puz2,Gr,R,N_Puz).


inspecciona(Puz,N_Puz):-grupos(Gr),
						inspecciona(Puz,Gr,N_Puz).

inspecciona(N_Puz,[],N_Puz).

inspecciona(Puz,[P|R],N_Puz):-inspecciona_grupo(Puz,P,N_Puz2),
							  inspecciona(N_Puz2,R,N_Puz).


/*Predicados para a verificacao de solucoes*/

grupo_correcto(Puz,Nums,Gr):-conteudos_posicoes(Puz,Gr,Conteudos),
							 append(Conteudos,N_Conteudos),
							 grupo_correto_aux(Nums,N_Conteudos).

grupo_correto_aux(Nums,N_Conteudos):-length(Nums,X),
									 length(N_Conteudos,Y),
									 X=\=Y,
									 false.

grupo_correto_aux(Nums,N_Conteudos):-length(Nums,X),
									 length(N_Conteudos,Y),
									 X=:=Y,
									 grupo_correto_aux1(Nums,N_Conteudos).

grupo_correto_aux1(_,[]).

grupo_correto_aux1(Nums,[P|_]):- \+member(P,Nums),
								 false.

grupo_correto_aux1(Nums,[P|R]):-member(P,Nums),
								grupo_correto_aux1(Nums,R).


solucao(Puz):-grupos(Gr),
			  numeros(L),
			  solucao(Puz,Gr,L).

solucao(_,[],_).

solucao(Puz,[P|R],L):-grupo_correcto(Puz,L,P),
					  solucao(Puz,R,L).


resolve(Puz,Sol):-inicializa(Puz,N_Puz),
				  inspecciona(N_Puz,N_Puz1),
				  resolve_aux(N_Puz1,Sol),!.

resolve_aux(Puz,Sol):-solucao(Puz), /*a cada alteracao verifica se o puzzle ja esta solucionado*/
					  Puz=Sol,!.

resolve_aux(Puz,Sol):-todas_posicoes(Todas_Posicoes), 
				  	  escolhe_posicao(Puz,Sol,Todas_Posicoes,Pos), /*escolhe uma posicao nao unitaria*/
				  	  puzzle_ref(Puz,Pos,Cont),
				  	  propaga_alteracoes(Puz,Sol,Pos,Cont).

escolhe_posicao(Puz,Sol,[P|R],Pos):-puzzle_ref(Puz,P,Cont),
								    length(Cont,1),
								    escolhe_posicao(Puz,Sol,R,Pos).

escolhe_posicao(Puz,_,[P|_],Pos):-puzzle_ref(Puz,P,Cont), /*caso o primeiro numero do conteudo da posicao nao resultar passa-se ao proximo*/
								  length(Cont,Tamanho),
								  Tamanho\=1,
								  Pos=P,!.

propaga_alteracoes(Puz,Sol,Pos,[P|_]):-puzzle_muda_propaga(Puz,Pos,[P],N_Puz), 
								 	   resolve_aux(N_Puz,Sol).

propaga_alteracoes(Puz,Sol,Pos,[_|R]):-propaga_alteracoes(Puz,Sol,Pos,R),!.










