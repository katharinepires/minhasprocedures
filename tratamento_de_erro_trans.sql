/* Criando uma Stored Procedure com
tratamento de erros e transações.
Irei usar a tabela tRELAutorLivro 
pois tem os id de livro e do autor */

use eBook
go

Create or Alter Procedure stp_CadastrarAutor
@idAutor int,
@Nome varchar(260),
@Nascimento datetime,
@Exclusao datetime = null,
@Livro int = null,
@Participa int = 0
As
Begin

	Begin Try

		Begin tran
			Insert into tCADAutor(iIDAutor, cNome, dNascimento, dCadastro, dCadastro)
			Values(@idAutor, @Nome, @Nascimento, getdate(), @Exclusao)

			Declare @idAutorNovo As int = @@IDENTITY

			If (@Livro is not null)
			Begin
				Insert into tRELAutorLivro(iIDAutorLivro, iIDAutor, iIDLivro, iIDParticipacao)
				Values(@idAutorNovo, @idAutor, @Livro, @Participa)
			End

		Commit

	End Try

	Begin Catch

		Rollback
		Select ERROR_MESSAGE() As Retorno 

	End Catch
End