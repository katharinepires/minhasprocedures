/* Vamos agora stored procedure de exclus�o.
Excluir alguns pedidos */

Create or Alter Procedure stp_ExcluirPedido
@idPedido int
As
Begin

	Delete From 
		tMOVPedido
	Where iIDPedido = @idPedido

	Select 'O pedido ' + cast(@idPedido as varchar) + ' foi exclu�do com sucesso!'


End

Execute stp_ExcluirPedido 6