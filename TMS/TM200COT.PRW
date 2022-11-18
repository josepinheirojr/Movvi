#Include "Protheus.ch"

/*/-----------------------------------------------------------
PE TM200COT()
Utilizado para determinar se deve ou nao recalcular a cotação
com base em configuração especifica no contrato do cliente generico.

@author Jose Luiz Pinheiro Junior         
@since 16/11/2022
@version 1.0
-----------------------------------------------------------/*/
User Function TM200COT()             
Local lRet   	:= .T. // retorno .T. nao recalcula a cotação // .F. realiza o novo calculo da cotação.
Local lCont		:= .T. // continuao do processo por etapa
Local aAreas   	:= { DUO->(GetArea()) , DTC->(GetArea()) , DT4->(GetArea()) , GetArea()}

Local nQtdVol	:= ParamIXB[2] //aLote[ nCntFor, LTQTDVOL ]
Local nValor	:= ParamIXB[3] //aLote[ nCntFor, LTVALOR  ]
Local nPeso		:= ParamIXB[4] //aLote[ nCntFor, LTPESO   ]
Local nPesoM3	:= ParamIXB[5] //aLote[ nCntFor, LTPESOM3 ]
Local nSeguro	:= ParamIXB[6] //aLote[ nCntFor, LTBASSEG ]
Local nQtdUni	:= ParamIXB[7] //aLote[ nCntFor, LTQTDUNI ]
Local cMV_CliGen := SuperGetMV('MV_CLIGEN')

DUO->(DbSetOrder(1)) //-- DUO_FILIAL+DUO_CODCLI+DUO_LOJCLI
If	DUO->(!MsSeek(xFilial('DUO') + cMV_CliGen)) 
	lCont := .F.
EndIf

If lCont .And. DUO->DUO_RECFRE == StrZero(1, Len(DUO->DUO_RECFRE)) //-- recalcula cotacao
	//-- Indica se aplica tolerancia no calculo
	If DUO->DUO_XUTTOL == StrZero(1, Len(DUO->DUO_XUTTOL))
		If DUO->DUO_XPEMEN == 0 .And.  DUO->DUO_XPEMAI == 0
			lCont := .F.
		EndIf
	EndIf
EndIf

//-- Realiza nova comparação para determinar se possui diferença entre Nota (DTC) e Cotação
//-- se for tudo igual , nao continua.
If 	lCont 					   .And. ;
	DVF->DVF_QTDVOL == nQtdVol .And. ;
   	DVF->DVF_VALMER == nValor  .And. ;
   	DVF->DVF_PESO   == nPeso   .And. ;
   	DVF->DVF_PESOM3 == nPesoM3 .And. ;
   	DVF->DVF_BASSEG == nSeguro .And. ;
   	DVF->DVF_QTDUNI == nQtdUni

	lCont := .F.
EndIf

//-- Retorna NIL para nao afetar o calculo da cotação
If !lCont
	aEval(aAreas, {|xArea| RestArea( xArea ) } )
	Return Nil
EndIf


lRet := ReCalc(nQtdVol, DVF->DVF_QTDVOL)
If !lRet
	lRet := ReCalc(nValor, DVF->DVF_VALMER)
EndIf

If !lRet
	lRet := ReCalc(nPeso, DVF->DVF_PESO)
EndIf

If !lRet
	lRet := ReCalc(nPesoM3, DVF->DVF_PESOM3)
EndIf

If !lRet
	lRet := ReCalc(nSeguro, DVF->DVF_BASSEG)
EndIf

If !lRet
	lRet := ReCalc(nQtdUni, DVF->DVF_QTDUNI)
EndIf


//-- faço inversao do retorno para atender a logica do TM200COT
//-- lRet = .T. nao recalcula a cotação // .F. realiza o novo calculo da cotação.
lRet := !lRet
//-- Restaura areas	
aEval(aAreas, {|xArea| RestArea( xArea ) } )
Return lRet



/*/-----------------------------------------------------------
ReCalc()
Utilizado para realizar o calculo e verifica se esta dentro da
faixa de minima e maxima para recalculo da cotação.
-----------------------------------------------------------/*/
Static Function ReCalc(xValNFC, xValCOT)
Local lRet 		:= (xValNFC <> xValCOT) 
Local nResult	:= 0
Local nPerMen 	:= DUO->DUO_XPEMEN
Local nPerMai 	:= DUO->DUO_XPEMAI

If lRet
	If xValNFC > xValCOT
		//-- info da nota do cliente maior que cotacao
		nResult := 100-((xValCOT/xValNFC)*100) 
		lRet 	:= (nResult > nPerMai)
	Else
		//-- infor da nota do cliente menor que cotacao
		nResult := 100-((xValNFC/xValCOT)*100) 
		lRet 	:= (nResult > nPerMen)
	EndIf
EndIf
Return lRet
