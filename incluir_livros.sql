/* Criando agora uma stores de inclusão */

Use ebook
go

Create or Alter Procedure stp_IncluirLivro
@idLivro int,
@idDestaque int,
@Titulo Varchar(300),
@Subtitulo Varchar(50),
@Ano smallint,
@ISBN Char(13)
As
Begin
	Insert Into tCADLivro(iIDLivro, iIDDestaque, 
		cTitulo, cSubtitulo, nAno, cISBN)
	Values(@idLivro, @idDestaque, @Titulo, @Subtitulo, @Ano, @ISBN)  
End

Execute stp_IncluirLivro 25001, 01,'Teste Número 1', 'Tem que pegar', 2021, 1406199913047 


select * from tCADLivro where iIDLivro = 25001