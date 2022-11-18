#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TM115MEM
Altera o menu para acrescentar a opção de Importar / Exportar

@author Jose Luiz Pinheiro Junior
@since 03/11/22
@version 1.0
/*/
//-------------------------------------------------------------------
User Function TM115MEM()             

	AAdd( aRotina, {'Importar Estrutura'  ,'U_MOVI015(1)', 0, 2, 0,Nil } ) 
	AAdd( aRotina, {'Exportar Estrutura'  ,'U_MOVI015(2)', 0, 2, 0,Nil } ) 

Return

