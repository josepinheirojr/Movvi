#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


/*/-----------------------------------------------------------
PE TECA250()
Utilizado para tratar a seleção de multiplas tabelas de fretes.

@author Jose Luiz Pinheiro Junior         
@since 01/02/2022
@version 1.0
-----------------------------------------------------------/*/
User Function TECA250()
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := aParam[1]
Local cIdPonto   := aParam[2]
Local cIdModel   := IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
//Local cClasse    := IIf( oObj<> NIL, oObj:ClassName(), '' )

Local oModel     := FwModelActive()
Local cContrat   := ""
Local cCodNeg	 := ""
Local cItem      := ""
Local cServic    := ""
Local cChvTab	 := ""
Local nLoop		 := 0
Local nX         := 0
Local nY         := 0


If cIdPonto ==  'FORMLINEPRE'
	If cIdModel == 'MdGridIDDA' .And. aParam[5] == 'DELETE'
		cContrat := M->AAM_CONTRT
		cCodNeg	 := oModel:GetModel("MdGridIDDC"):GetValue("DDC_CODNEG")
		cItem    := oModel:GetModel("MdGridIDDA"):GetValue("DDA_ITEM")
		cServic  := oModel:GetModel("MdGridIDDA"):GetValue("DDA_SERVIC")
		cChvTab  := cContrat + cCodNeg + cItem + cServic //-- monta chave de pesquisa para guardar informações no vetor

		If (nLoop := Ascan( _aTabUSR, { |aItem| aItem[1] == cChvTab } )) > 0
			Adel(_aTabUSR,nLoop)	//Exclui linha em branco
			Asize(_aTabUSR,Len(_aTabUSR)-1)
		EndIf
	EndIf

ElseIf cIdPonto ==  'MODELCOMMITTTS' //-- Apos a gravação total do modelo e dentro da transação
	
	PA0->(DbSetOrder(1)) //-- PA0_FILIAL+PA0_NCONTR+PA0_CODNEG+PA0_ITEM+PA0_SERVIC+PA0_TABFRE+PA0_TIPTAB
	DDA->(DbSetOrder(1))   //-- DDA_FILIAL+DDA_NCONTR+DDA_CODNEG+DDA_ITEM

	If Empty(_aTabUSR)
		If PA0->(dbSeek(xFilial('PA0') + AAM->AAM_CONTRT ))
			While PA0->(!Eof()) .And. PA0->(PA0_FILIAL+PA0_NCONTR) == xFilial('PA0') + AAM->AAM_CONTRT
				RecLock('PA0', .F.)
				PA0->(dbDelete())
				PA0->(MsUnlock())
				PA0->(dbSkip())
			EndDo
		EndIf
	EndIf
	
	For nX := 1 To Len(_aTabUSR)
		//-- Localiza Serviço de Negociacao
		If DDA->(dbSeek(xFilial('DDA') + _aTabUSR[nX][1] ))
			For nY := 1 To Len(_aTabUSR[nX][2])
				cChvTab := _aTabUSR[nX][1] + _aTabUSR[nX][2][nY][2] + Left(_aTabUSR[nX][2][nY][3] , Len(DDA->DDA_TIPTAB))

				If _aTabUSR[nX][2][nY][1] 			//-- verificar se a tabela esta marcada como .T.
					If (_aTabUSR[nX][2][nY][2] == DDA->DDA_TABFRE .or. _aTabUSR[nX][2][nY][2] == DDA->DDA_TABALT)
						Loop
					Else
						If !PA0->(dbSeek(xFilial('PA0') + cChvTab ))
							RecLock('PA0', .T.)
							PA0->PA0_FILIAL := xFilial('PA0')
							PA0->PA0_NCONTR := AAM->AAM_CONTRT
							PA0->PA0_CODNEG := DDA->DDA_CODNEG
							PA0->PA0_ITEM   := DDA->DDA_ITEM
							PA0->PA0_SERVIC := DDA->DDA_SERVIC
							PA0->PA0_TABFRE := _aTabUSR[nX][2][nY][2]
							PA0->PA0_TIPTAB := Left(_aTabUSR[nX][2][nY][3] , Len(DDA->DDA_TIPTAB))
							PA0->(MsUnlock())
						EndIf
					EndIf
				Else
					If PA0->(dbSeek(xFilial('PA0') + cChvTab ))
						RecLock('PA0', .F.)
						PA0->(dbDelete())
						PA0->(MsUnlock())
					EndIf
				EndIf
			Next nY
		Else
			If PA0->(dbSeek(xFilial('PA0') + _aTabUSR[nX][1] ))
				While PA0->(!Eof()) .And. PA0->(PA0_FILIAL+PA0_NCONTR+PA0_CODNEG+PA0_ITEM+PA0_SERVIC) == xFilial('PA0') + _aTabUSR[nX][1]
					RecLock('PA0', .F.)
					PA0->(dbDelete())
					PA0->(MsUnlock())
					PA0->(dbSkip())
				EndDo
			EndIf
		EndIf
	Next nX 

	//-- Variavel utilizada para guardar as tabelas de Frete Adicionais.
	_aTabUSR := {}

ElseIf cIdPonto ==  'BUTTONBAR'
	//-- Variavel utilizada para guardar as tabelas de Frete Adicionais.
	Public _aTabUSR := {}
	VAR_IXB := .F.
	xRet := { {'Tabelas Adicionais', 'SALVAR', { || U_A250TAB() }, 'Inclui Tabelas Adicionais' } }
	
EndIf

Return xRet


/*/-----------------------------------------------------------
A250TAB()
Rotina para permitir a escolha de varias Tabelas de Frete a Receber

@author Jose Luiz Pinheiro Junior         
@since 01/02/2022
@version 1.0
-----------------------------------------------------------/*/

User Function A250TAB()
Local oModel     := FwModelActive()
Local cContrat   := ""
Local cCodNeg    := ""
Local cItem      := ""
Local cServic    := ""
Local cCatTab    := StrZero(1, Len(DTL->DTL_CATTAB)) //-- Frete a Receber
//Local nPosLine	 := 0
Local cChvTab	 := ""
Local nLoop		 := 0
Local nAchou     := 0
Local nx         := 0
Local nOperation := oModel:GetOperation()
Local aLayOut    := {}

cContrat := M->AAM_CONTRT
cCodNeg	 := oModel:GetModel("MdGridIDDC"):GetValue("DDC_CODNEG")
cItem    := oModel:GetModel("MdGridIDDA"):GetValue("DDA_ITEM")
cServic  := oModel:GetModel("MdGridIDDA"):GetValue("DDA_SERVIC")
//nPosLine := oModel:GetModel("MdGridIDDA"):GetLine()
cChvTab  := cContrat + cCodNeg + cItem + cServic //-- monta chave de pesquisa para guardar informações no vetor

If Empty(cServic)
	MsgInfo ("Necessário Informar Servico de Negociacao. Verifique!")
	Return(.F.)
EndIf

//-- Carrega Tabelas de Frete a Receber (Padrao)
aLayOut := TMSLayOutTab(cCatTab, .T.,,{"15"}) 
If Len(aLayOut)==0
	Return( .F. )
EndIf

//-- Caso seja alteração Verificar se possui tabelas adicionais e ja carrega no vetor
If Empty(_aTabUSR) .And. nOperation == MODEL_OPERATION_UPDATE
	If !VAR_IXB
		LoadTab()
		VAR_IXB := .T.
	EndIf
EndIf

If !Empty(_aTabUSR)
	If (nLoop := Ascan( _aTabUSR, { |aItem| aItem[1] == cChvTab } )) > 0
		For nX := 1 To Len(_aTabUSR[nLoop,2])
			If (nAchou := Ascan( aLayOut, { |x| x[2]+x[3] = _aTabUSR[nLoop,2][nX,2] + _aTabUSR[nLoop,2][nX,3]}) ) > 0
				aLayOut[nAchou,1] := _aTabUSR[nLoop,2][nX,1] // coloca como verdadeiro para trazer marcado na tela.
			EndIf
		Next nX
		//-- reclassifica o vetor para trazer os itens marcados primeiro.
		aLayOut := aSort(aLayOut,,,{|x,y| If(x[1],'0','1')+x[2]+x[3] < If(y[1],'0','1')+y[2]+y[3] })
	EndIf
EndIf

If TMSABrowse( aLayOut, "Tabela de Frete [Item: " + cItem +" / Srv: " + cServic + "]",/*bAcao*/,/*lIniAcao*/,.T./*lNaoItem*/,.F./*lOpcao*/, { "Tabela de Frete", "Tipo", "Descricao" } /*aCabec*/) //Permiti selecionar varias tabelas
	If (nLoop := Ascan( _aTabUSR, { |aItem| aItem[1] == cChvTab } )) > 0
		_aTabUSR[nLoop,2] := aLayOut 
	Else
		AADD( _aTabUSR , { cChvTab , aLayOut } )
	EndIf
EndIf

Return


/*/-----------------------------------------------------------
LoadTab()
Funcao utilizada para carregar as Tabelas de Frete Adicionais do Contrato do Cliente

@author Jose Luiz Pinheiro Junior         
@since 01/02/2022
@version 1.0
-----------------------------------------------------------/*/
Static Function LoadTab()
Local cQuery 	:= ""
Local cAlias 	:= GetNextAlias()
Local aArea		:= GetArea()
Local cQuebra   := ""
Local aLayOut	:= ""
Local aTipos    := {}
Local nLinha    := 0

cQuery := ""
cQuery += "SELECT (PA0_NCONTR+PA0_CODNEG+PA0_ITEM+PA0_SERVIC) CHAVE , PA0_TABFRE , PA0_TIPTAB, DTL_DESCRI "
cQuery += "  FROM " + RetSqlName("PA0") + " PA0 "
cQuery += "  JOIN " + RetSqlName("DTL") + " DTL "
cQuery += "    ON DTL_FILIAL = '" + xFilial('DTL') + "' "
cQuery += "   AND DTL_TABFRE = PA0_TABFRE "
cQuery += "   AND DTL_TIPTAB = PA0_TIPTAB "
cQuery += "   AND DTL.DTL_CATTAB = '1' " //-- frete a receber
cQuery += "   AND DTL.D_E_L_E_T_ = ' ' "
cQuery += " WHERE PA0_FILIAL = '" + xFilial('PA0') + "' "
cQuery += "   AND PA0_NCONTR = '" + AAM->AAM_CONTRT + "' "
cQuery += "   AND PA0.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY CHAVE "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias)

aTipos := FwGetSX5("M5")
While (cAlias)->(!Eof())
	aLayOut:= {}

	nLinha := Ascan(aTipos,{|x| AllTrim(x[3]) == AllTrim((cAlias)->PA0_TIPTAB)})
	Aadd( aLayOut, { .T. ,;
	                (cAlias)->PA0_TABFRE, (cAlias)->PA0_TIPTAB + " - " + Iif(nLinha > 0,Left(aTipos[nLinha,4],15),Space(15)),;
					(cAlias)->DTL_DESCRI ;
					} )

	If cQuebra <> (cAlias)->CHAVE
		cQuebra := (cAlias)->CHAVE
		AADD( _aTabUSR , { (cAlias)->CHAVE , aLayOut } )
	Else
		nLinha := Ascan(_aTabUSR , {|x| x[1] == (cAlias)->CHAVE } )
		AADD(_aTabUSR[nLinha,2] ,  aLayOut[1]  )
	EndIf

	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

RestArea(aArea)
Return
