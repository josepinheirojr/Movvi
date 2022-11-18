#Include "Protheus.ch"

/*/-----------------------------------------------------------
PE TM040GRV()
Utilizado para gravar a tabela de frete Auxiliar escolhida na 
cotação. Baseado na tabela PA0.

@author Jose Luiz Pinheiro Junior         
@since 18/02/2022
@version 1.0
-----------------------------------------------------------/*/
User Function TM040GRV()             
//Local nOpcx  := ParamIXB[1]
Local cSeek  := ""

//-- Atualiza a Tabele de Frete Auxiliar escolhida na cotação baseado na PA0.
If Type('__aTbCotAux') <> 'U' .And. Len(__aTbCotAux) > 0
	RecLock('DT4',.F.)
	DT4->DT4_SERVIC  := __aTbCotAux[1] //-- serviço
	DT4->DT4_TABFRE  := __aTbCotAux[2] //-- Tabela de Frete
	DT4->DT4_TIPTAB  := __aTbCotAux[3] //-- Tipo da Tabela
	MsUnLock()

	DT8->(DbSetOrder(1)) //-- DT8_FILIAL+DT8_FILORI+DT8_NUMCOT+DT8_CODPRO+DT8_CODPAS
	DT8->(MsSeek( cSeek := xFilial('DT8') + DT4->DT4_FILORI + DT4->DT4_NUMCOT ))
	bWhile := {|| DT8->(!Eof()) .And. DT8->DT8_FILIAL + DT8->DT8_FILORI + DT8->DT8_NUMCOT == cSeek }
	While Eval(bWhile)
		If	( DT8->DT8_CODPAS != 'TF' )
			RecLock('DT8',.F.)
			DT8->DT8_TABFRE := DT4->DT4_TABFRE
			DT8->DT8_TIPTAB := DT4->DT4_TIPTAB
			DT8->DT8_SEQTAB := DT4->DT4_SEQTAB
			MsUnLock()
		EndIf
		DT8->(DbSkip())
	EndDo
    __aTbCotAux := {}
EndIf


If Type('__lBloqueiaCot') <> 'U' .And. __lBloqueiaCot
	__lBloqueiaCot := .F.

	RecLock('DT4',.F.)
	//-- Grava status como 2 - Bloqueado por rentabilidade
	DT4->DT4_STATUS := StrZero( 2, Len( DT4->DT4_STATUS ) )
	MsUnLock()

	cMotBlq := "Bloqueio por rentabilidade inferior a configurada no contrato do cliente generico."
	// Gera Bloqueio de usuario por rentabilidade
	Tmsa029Blq( 3  ,;				//-- 01 - nOpc
				'TMSA040',;			//-- 02 - cRotina
				'U1'  ,;			//-- 03 - cTipBlq
				DT4->DT4_FILORI,;	//-- 04 - cFilOri
				'DT4' ,;			//-- 05 - cTab
				'1' ,;				//-- 06 - cInd
				xFilial('DT4') + DT4->DT4_FILORI + DT4->DT4_NUMCOT,; //-- 07 - cChave
				DT4->DT4_NUMCOT 	,;	//-- 08 - cCod
				cMotBlq 		,;		//-- 09 - cDetalhe
				)						//-- 10 - Opcao da Rotina
	
EndIf

Return 

