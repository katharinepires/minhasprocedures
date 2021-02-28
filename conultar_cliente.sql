/* Criando uma procedure de consulta:
Dia 25/02
Katharine Pires */

Use eBook
go 

Create or Alter Procedure stp_ConsultarCliente
As
Begin

	Select 
		cNome As Nome, 
		dAniversario As Aniversario, 
		mCredito As Credito
	From tCADCliente 
	Where mCredito > 10
	Order by mCredito desc

End

Execute stp_ConsultarCliente

-- Progranação -> Procedimentos Armazenados -> stp -> Modificar:

Create or Alter Procedure stp_ConsultarCliente
	@mCredito smallmoney 
As
Begin

	Select 
		cNome As Nome, 
		dAniversario As Aniversario, 
		mCredito As Credito
	From tCADCliente 
	Where mCredito = @mCredito

End

Execute stp_ConsultarCliente 10 

/* Para poder selecionar um dos parâmetros, ou seja, 
se não for o crédito, pode consultar pelo nome */

Create or Alter Procedure stp_ConsultarCliente
	@cNome Varchar(50) = null,
	@mCredito smallmoney = null
As
Begin

	Select 
		cNome As Nome, 
		dAniversario As Aniversario, 
		mCredito As Credito
	From tCADCliente 
	Where ((mCredito = @mCredito) Or (@mCredito is null)) 
		And ((cNome Like '%' + @cNome + '%') Or (@cNome is null))
	Order by cNome

End

Exec stp_ConsultarCliente 'ted'