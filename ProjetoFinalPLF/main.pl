%Gerador de ordem de serviços

% Definindo que a base de dados é dinâmica
:- dynamic ordem_servico/5.
:- dynamic profissional/5.
:- dynamic atribuicao/2.

%Base de fatos

%Os fatos das Ordem de serviço serão cadastradas com a seguinte lógica:
%ordem_serviço(ID,descrição,situaçãoProjeto,dataInicio,dataFim)

ordem_servico(0,soldagem-mig,aberto,09-07-2024,null).
ordem_servico(1,soldagem-tig,emAndamento,04-06-2024,null).
ordem_servico(2,tornagem,concluido,22-04-2024,null).
ordem_servico(3,usinagem,aberto,10-07-2024,10-08-2024).

%Para os fatos dos profissionais haverá a seguinte ordem:
%profissional(ID,nome,funcao,competencias,disponibilidade).

profissional(0,ricardao,tecnico-eletromecanica,[tornagem,usinagem,soldagem-tig,soldagem-mig],sim).
profissional(1,lucao,tecnico-eletromecanica,[tornagem,usinagem,soldagem-tig],sim).
profissional(2,jorge,cientista-computacao,[programacao,integracao],nao).
profissional(3,alines,tecnico-eletromecanica,[administracao,usinagem,fundicao],sim).
profissional(4,tiaguinho,tecnico-automacao,[eletronica,automacao],sim).
profissional(5,gilmar,engenhero,[tornagem,usinagem,soldagem-mig,soldagem-tig,soldagem-submersa],sim).

%Base de fatos para atribuicao de profissionais em OS
%atribuicao(Id_OS,ID-func)

atribuicao(2,1). %essa base consiste na adição em tempo de execução para novos fatos!

%Regra para retornar o número máximo de funcionários.
ultimo_id_profissional(UltimoID) :-
    aggregate(max(ID), Nome^Funcao^Competencias^Disponibilidade^profissional(ID, Nome, Funcao,
    Competencias, Disponibilidade), UltimoID).

%Regra para verificar se funcionario tem disponibilidade

  verfica_disponibilidade(X):-
    profissional(_,X,_,_,Y),
    Y = sim -> true;
    false.

%Regra que verifica se uma competência está na lista de competências 

  tem_competencia([Competencia|_],Competencia).
  tem_competencia([_|T], Competencia) :-
    tem_competencia(T, Competencia).

%Regra que busca o primeiro profissional com a competência especificada e disponibilidade para serviços

  busca_funcionario(Nome,Competencia) :-
    profissional(_, Nome, _, Competencias, sim),
    tem_competencia(Competencias, Competencia), !.

%Lista as competências do profissional por ID

  retorna_competencias_ID(X):-
    profissional(ID,_,_,Competencias,_),
    tem_competencia(Competencias, Competencia), !.

%Faz a atribuição de de um profissional a uma OS
%atribuicao_profissional(OS).

  atribui(Id_OS,ID_Profissional):-
    assertz(atribuicao(Id_OS, ID_Profissional)).
  
  atribuicao_profissional(OS):-
    ordem_servico(OS,Competencia,aberto,_,_),
    busca_funcionario(Nome,Competencia),
    profissional(ID_Profissional,Nome,_,_,_),
    confirmacao(Nome,OS,ID_Profissional).

%Faz a confirmação da resposta informada via terminal
  
  confirmacao(Nome, OS, Func) :-
      write('Você tem certeza que deseja adicionar '), 
      write(Nome), writeln(' como novo profissional desta OS?'),
      writeln('Digite sim ou nao'),
      read_line_to_string(user_input, X),
      processar_resposta(X, Nome, OS, Func).
  
  processar_resposta("sim", Nome, OS, Func) :-
      atribui(OS, Func), write(Nome),
      writeln(' foi adicionado ao cargo com sucesso!'),
      altera_profissional_disponibilidade(Func).
      
  processar_resposta("nao", Nome, OS, _Func) :-
      writeln('Informe o ID do profissional que você deseja adicionar para o cargo.'),
      read_line_to_string(user_input, YStr),
      number_string(Y, YStr),
      profissional(Y,Nomel,_,_,_),
      atribui(OS, Y), write(Nomel),
      writeln(' foi adicionado ao cargo com sucesso!'),
      altera_profissional_disponibilidade(Y).
      
  processar_resposta(_, Nome, OS, Func) :-
      writeln('Entrada inválida. Digite sim ou nao.'),
      confirmacao(Nome, OS, Func).

%Apaga o profissional

  remover_profissional(ID) :-
    retract(profissional(ID,_,_,_,_)).

%Altera disponibilidade profissional

  altera_profissional_disponibilidade(ID):-
    profissional(ID,Nome,Funcao,Competencias,Disponibilidade),
    Disponibilidade == sim -> writeln(Disponibilidade),
    cadastraProfissional(ID,Nome,Funcao,Competencias,Disponibilidade),
    retract(profissional(ID,_,_,_,sim)).
    
  cadastraProfissional(ID,Nome,Funcao,Competencias,Disponibilidade):-
    assertz(profissional(ID,Nome,Funcao,Competencias,nao)).

%Demite funcionário, altera a disponiblidade

  demiteFuncionario(ID):-
    profissional(ID,Nome,Funcao,Competencias,Disponibilidade),
    Disponibilidade == nao ->
    assertz(profissional(ID,Nome,Funcao,Competencias,sim)),
    retract(profissional(ID,_,_,_,nao));
    writeln('Este profissional não esta empregado! ').

%Altera situação da OS

  alteraOsSituacaoAberto(ID):-
    ordem_servico(ID,Descricao,Situacao,DataIni,DataFim),
    Situacao = aberto -> 
    cadastraOS(ID,Descricao,emAndamento,DataIni,DataFim),
    retract(ordem_servico(ID,_,aberto,_,_)),
    writeln('Situação da OS alterada com sucesso!');
    Situacao = emAndamento -> 
    cadastraOS(ID,Descricao,concluido,DataIni,DataFim),
    retract(ordem_servico(ID,_,emAndamento,_,_)),
    writeln('Situação da OS alterada com sucesso!');

  cadastraOS(ID,Descricao,Situacao,DataIni,DataFim):-
    assertz(ordem_servico(ID,Descricao,Situacao,DataIni,DataFim)).
    
    

