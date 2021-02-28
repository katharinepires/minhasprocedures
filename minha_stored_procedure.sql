use eBook
go

Create Type dtTMPVenda 
As Table 
(
   iIDCliente int,               -- Identificação do Cliente.
   iIDLoja int ,                 -- Identificação da Loja.
   iIDEndereco int null ,        -- Identificação do Endereço de Entrega
   iIDLivro int ,                -- Identificação do Livro
   mDesconto smallmoney null ,   -- Desconto aplicado ao Livro
   nQuantidade int               -- Quantidade vendida do Livro.
)

go

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: Store Procedure
Objeto     : stp_IncluirVenda
Objetivo   : Incluir um pedido de venda, atualizar estoque e 
             realizar solicitação de compra.
Projeto    : Treinamento          
Empresa Responsável: ForceDB Treinamentos
Criado em  : 09/08/2019
Execução   : A procedure deve se executada na area de CATCH         
Palavras-chave: Erro, tratamento, catch, avisos
----------------------------------------------------------------------------------------------        
Observações :        

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Wolney M. Maia               09/08/2019 Criação da Procedure 
*/

Create or Alter Procedure stp_IncluirVenda
@tTMPVenda dtTMPVenda readonly 
As
Begin
   
   /*
   Área de Declaração 
   */   
   Declare @nRetorno int = 0

   Declare @tSolicitaCompra Table 
   (iIDLivro int, 
    iIDLoja int, 
    nQuantidade int, 
    nQuantidadeMinima int, 
    mValor smallmoney 
   )

   Declare @nFatorQuantidade int = 12
   
   Declare @iIDPedido int = next value for seqIDPedido; -- Recupera o próximo número de pedido.
   Declare @nNumeroPedido int = next value for seqNumeroPedido
   
   Begin Transaction
   Begin Try 

      With cteEndereco as (
         Select iIDEndereco, iIDCliente 
           From tCADEndereco 
           Join tTIPEndereco 
             on tCADEndereco.iIDTipoEndereco = tTIPEndereco.iIDTipoEndereco
          Where tTIPEndereco.cDescricao = 'Principal'
      )
      Insert Into dbo.tMOVPedido           
             (iIDPedido ,iIDCliente,iIDLoja,iIDEndereco,
              iIDStatus,
              dCancelado,nNumero,mDesconto
             )
      Select Top 1 @iIDPedido, Venda.iidCliente,iidLoja, isnull(Venda.iIDEndereco,tTMPEnderecoPrincipal.iIDEndereco),
             1,null,@nNumeroPedido,sum(Venda.mDesconto) over() 
        From @tTMPVenda as Venda 
       Cross apply (Select iIDEndereco 
                      From cteEndereco 
                     Where iIDCliente = Venda.iIDCliente) tTMPEnderecoPrincipal
      
      Insert into dbo.tMOVPedidoItem 
             (iIDPedido,IDLivro,iIDLoja,
              nQuantidade,mValorUnitario,mDesconto
             )

       Select @iIDPedido,Venda.iIDLivro,Venda.iIDLoja,
              Venda.nQuantidade,Estoque.mValor ,Venda.mDesconto
         From @tTMPVenda as Venda 
         Join tRElEstoque as Estoque
           on Venda.iIDLoja = Estoque.iIDLoja
          and Venda.iIDLivro = Estoque.iIDLivro
         
      Update tRelEstoque  
         Set nQuantidade -= Venda.nQuantidade ,
             dUltimoConsumo = getdate()
      Output inserted.iIDLivro,
             inserted.iIDLoja,
             inserted.nQuantidade ,
             inserted.nQuantidadeMinima,
             inserted.mValor
        Into @tSolicitaCompra
        From tRelEstoque  
        Join @tTMPVenda as Venda 
          On tRelEstoque.iIDLoja = Venda.iIDLoja
         And tRELEstoque.iIDLivro = Venda.iIDLivro;

         With cteSolicitacao as 
         (
            Select Venda.iIDLivro , 
                   Estoque.nQuantidade*@nFatorQuantidade as nQuantidade ,
                   Estoque.mValor ,
                   Livro.nPeso
            From tRELEstoque as Estoque 
            Join @tTMPVenda as Venda
              on Estoque.iIDLivro = Venda.iIDLivro 
             and Estoque.iIDLoja = Venda.iIDLoja
            Join tCADLivro as Livro
              on Venda.iIDLivro = Livro.iIDLivro
           where Estoque.nQuantidade <= nQuantidadeMinima

         )
         Insert into tMOVSolicitacaoCompra
         (iIDLivro, nQuantidade, mValorEstimado,mPesoEstimado)
         Select iIDLivro,nQuantidade,mValor*nQuantidade ,nPeso * nQuantidade 
           From cteSolicitacao

      Commit 

   End Try 
   Begin Catch
      Execute @nRetorno = stp_ManipulaErro
      Rollback 
   End Catch 

   Return @nRetorno 

End 


-- Fim da Procedure 

use eBook
go


-- Definição da variável table que representa a venda realizada

Create Table tMOVVenda 
(
   iIDCliente int,               -- Identificação do Cliente.
   iIDLoja int ,                 -- Identificação da Loja.
   iIDEndereco int null ,        -- Identificação do Endereço de Entrega
   iIDLivro int ,                -- Identificação do Livro
   mDesconto smallmoney null,    -- Desconto aplicado ao Livro
   nQuantidade int               -- Quantidade vendida do Livro.
)


-- Inserção dos dados exemplos


Insert into tMOVVenda (iIDCliente, iIDLoja, iIDEndereco, mDesconto,iIDLivro, nQuantidade)
Values (8824,23,110649,10.00,160,1),
       (8824,23,110649,5.00,170,1),
       (8824,23,110649,2.00,114,1)


go

Select * from tRELEstoque where iidlivro in (160,170,114) and iidloja =23
go

Declare @tTMPVenda dtTMPVenda
insert into @tTMPVenda select * from tMOVVenda

Declare @nRet int = 0
Execute @nRet = stp_IncluirVenda @tTMPVenda = @tTMPVenda 
if @nRet >0
   raiserror('Erro na execução. Código do erro %d',16,1,@nRet) 

go

Select * from tRELEstoque where iidlivro in (160,170,114) and iidloja =23

Select top 1 * from tMOVPedido order by iidpedido desc 

select top 3 * from tMOVPedidoItem order by iidPedido desc 

Select * from tMOVSolicitacaoCompra



-- como fazer o backup:

Backup DataBase eBook
to disk = 'e:\backup\eBook.bkp
with stats = 1, init