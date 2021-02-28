/* Criando uma para alteração 
Vamos alterar o endereço*/

Create or Alter Procedure stp_AtualizarEndereco
@idEndereco int,
@idCliente int,
@idLocalidade int,
@idTipoEndereco int,
@Logradouro varchar(50),
@Numero int,
@Complemento varchar(20) = '',
@Bairro varchar(20),
@CEP char(9),
@Exclusao datetime = null
As
Begin

	Update 
		tCADEndereco 
	Set 
		iIDCliente = @idCliente,
		iIDLocalidade = @idLocalidade,
		iIDTipoEndereco = @idTipoEndereco,
		cLogradouro = @Logradouro,
		nNumero = @Numero,
		cComplemento = @Complemento,
		cBairro = @Bairro,
		cCEP = @CEP,
		dCadastro = getdate(),
		dExclusao = @Exclusao
	Where
		iIDEndereco = @idEndereco

	Select 'O endereço' +cast(@idEndereco as varchar)+ ' foi atualizado com sucesso!'
End


Execute stp_AtualizarEndereco 130, 3, 3437, 1, 'Rua João Durval', 255, null, 'Pernambues', 41100290, null