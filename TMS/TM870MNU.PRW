#include "PROTHEUS.CH"  
#include "TBICONN.CH" 

/*/-----------------------------------------------------------
PE TM870MNU()

@author Jose Luiz Pinheiro Junior         
@since 29/09/2022
@version 1.0
-----------------------------------------------------------/*/
User Function TM870MNU()             

	AAdd( aRotina, {'Visualizar Docto'  ,'U_TM870B01', 0, 2,0,Nil } ) 

Return




User Function TM870B01()
Local aArea := DT6->(GetArea())

Private aRotina := {}

DT6->(dbSetOrder(1))
If	DT6->(MsSeek(xFilial('DT6')+DVX->(DVX_FILDOC+DVX_DOC+DVX_SERIE)))
    //-- Alterada a aRotina permitindo a visualizacao do documento
    aRotina := {{ '','',0,2},{ '','',0,2}}
    TMSViewDoc(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)
EndIf

RestArea(aArea)
Return
