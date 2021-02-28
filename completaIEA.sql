/* Vamos agora incluir, excluir ou alterar
Vamos fazer uma procedure que faz tudo isso.
E será com autores */

Create or Alter Procedure stp_CompletaIAE
@Acao int, -- variável que controla se será inclusão, exclusão ou alteração(0=excluir, 1=incluir, 2=alterar)
@idAutor int = null,
@Nome varchar(260) = null,
@Nascimento datetime = null,
@Exclusão datetime = null
As
Begin
	
	If (@Acao = 0)
	Begin
		Delete From 
			tCADAutor
		Where iIDAutor = @idAutor
	End

	Else If (@Acao = 1)
	Begin 
		Insert into tCADAutor(iIDAutor, cNome, dNascimento, dCadastro, dExclusao)
		Values(@idAutor, @Nome, @Nascimento, getdate(), @Exclusão)
	End

	Else If (@Acao = 2)
	Begin 
		Update 
			tCADAutor
		Set 
			cNome = @Nome,
			dNascimento = @Nascimento,
			dCadastro = getdate(),
			dExclusao = @Exclusão
		Where 
			iIDAutor = @idAutor
	End

	Else
		raiserror('Não foi possível completar a operação. Verifique as informções', 14,1);


End

Execute stp_CompletaIAE 2, 1, 'Andressa Urach', '1987-11-10', null
Execute stp_CompletaIAE 2, 2, 'Loretta Chase', '1949-02-06', null
Execute stp_CompletaIAE 2, 17370, null, null, '19'


Execute stp_CompletaIAE 1, 17371, 'Katharine Pires', '1999-14-06', null
Execute stp_CompletaIAE 1, 17372, 'Vera Carvalho', '1970-13-04', null
Execute stp_CompletaIAE 1, 17373, 'Claudemir Júnior', '2001-23-03', null

Execute stp_CompletaIAE 0, 17375