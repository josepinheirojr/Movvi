#include "PROTHEUS.CH"  
#include "TBICONN.CH" 

/*/-----------------------------------------------------------
PE TM890MNU()

@author Jose Luiz Pinheiro Junior         
@since 29/09/2022
@version 1.0
-----------------------------------------------------------/*/
User Function TM890MNU()             

	AAdd( aRotina, {'Visualizar Docto'  ,'U_TM890B01', 0, 2,0,Nil } ) 

Return




User Function TM890B01()
Private aRotina := {}

aRotina := {{ '','',0,2},{ '','',0,2}}
TMSViewDoc(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)

Return
