#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'atfa006.ch'

#DEFINE __nLinCabec		1

STATIC cTitulo   := "Inclusão de Solicitação Desconto"
STATIC aDadosPA2 := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} MOVA010
Inclusao de Solicitacao Desconto no Documento

@author Jose Luiz Pinheiro Junior
@since 19/10/22
@version 1.0
/*/
//-------------------------------------------------------------------
User Function MOVA010()
Local aArea 	:= GetArea()
Local oBrowse

Private cAlias 	:= "PA2" 
Private aRotina	:= MenuDef() 

dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(1))
(cAlias)->(dbGotop())

dbSelectArea('PA2')
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'PA2' )
oBrowse:SetDescription( cTitulo )

oBrowse:AddLegend( "PA2->PA2_STATUS == '1' ", "YELLOW" , "Pendente Aprovacao N1")
oBrowse:AddLegend( "PA2->PA2_STATUS == '2' ", "BLUE"   , "Pendente Aprovacao N2+" )
oBrowse:AddLegend( "PA2->PA2_STATUS == '3' ", "GREEN"  , "Aprovado"  )
oBrowse:AddLegend( "PA2->PA2_STATUS == '9' ", "RED"    , "Reprovado"  )
oBrowse:Activate()

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@author Jose Luiz Pinheiro Junior
@since 19/10/22
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRot    := {}

ADD OPTION aRot TITLE "Pesquisar"    ACTION 'PesqBrw' 		  	OPERATION 1 ACCESS 0	
ADD OPTION aRot TITLE 'Visualizar'   ACTION 'VIEWDEF.MOVA010' 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Incluir'      ACTION 'VIEWDEF.MOVA010' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3

Return aRot


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do Cadastro

@author Jose Luiz Pinheiro Junior
@since 19/10/22
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel 
Local oStruPA2 		:= FWFormStruct( 1, 'PA2', /*bAvalCampo*/, /*lViewUsado*/ )
Local bPosValid		:= { |oModel| PosVldMdl(oModel  ) }
//Local bCommit		:= { |oModel| CommitMdl( oModel ) }
	 
oModel:= MPFormModel():New( "MD_MOVA010",  /*bPreValidacao*/, bPosValid , /*bCommit*/, /*bCancel*/ )  
oModel:SetDescription(cTitulo)    
oModel:addFields('PA2MASTER', /*cOwner*/ ,oStruPA2)  

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'PA2MASTER' ):SetDescription( cTitulo )

oModel:SetPrimaryKey({'PA2_FILIAL', 'PA2_ID' })	

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados do Cadastro

@author Jose Luiz Pinheiro Junior
@since 19/10/22
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel := ModelDef() 
Local oStrPA2:= FWFormStruct(2, 'PA2')   
Local bBlock := {|| .T.}
Local oView 

oView := FWFormView():New()  
oView:SetModel(oModel)    
oView:AddField('VIEW_PA2' , oStrPA2, 'PA2MASTER' )  

oView:CreateHorizontalBox( 'CADPA2', 100 )

oView:SetOwnerView('VIEW_PA2','CADPA2')
oView:SetViewProperty('VIEW_PA2' , 'SETCOLUMNSEPARATOR', {10})
	
oView:SetCloseOnOk( bBlock )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MA010Vld
Validao de campos

@author Jose Luiz Pinheiro Junior
@since 19/10/22
@version 1.0
/*/
//-------------------------------------------------------------------
User Function MO010Vld(cCampo)
Local lRet 		:= .T. 
Local oModel 	:= FwModelActive()
Local cFildoc	:= ""
Local cDoc		:= ""
Local cSerie 	:= ""
Local lCont		:= .F.
Local nDecres   := 0
Local nPerDesc  := SuperGetMV("ES_LIMDESC", .F.,0)
Local nResult	:= 0

Default cCampo  := Alltrim( Readvar() )

If ('PA2_FILDOC' $ cCampo .Or. 'PA2_DOC' $ cCampo .Or. 'PA2_SERIE' $ cCampo)
	cFildoc := oModel:GetModel('PA2MASTER'):GetValue('PA2_FILDOC')
	cDoc    := oModel:GetModel('PA2MASTER'):GetValue('PA2_DOC')
	cSerie  := oModel:GetModel('PA2MASTER'):GetValue('PA2_SERIE')

	lCont := (!Empty(cFildoc) .And. !Empty(cDoc) .And. !Empty(cSerie))

	If lCont
		lRet := PesqDoc(cFilDoc,cDoc,cSerie)
	EndIf
ElseIf 'PA2_MOTIVO' $ cCampo
	SX5->( DbSetOrder( 1 ) )
	If (lRet := SX5->(MsSeek( xFilial("SX5") + Padr('P2', Len(SX5->X5_TABELA)) + M->PA2_MOTIVO )))
		oModel:GetModel('PA2MASTER'):SetValue('PA2_DESMOT' , X5DESCRI())
	EndIf
ElseIf 'PA2_DECRES' $ cCampo
	cFildoc  := oModel:GetModel('PA2MASTER'):GetValue('PA2_FILDOC')
	cDoc     := oModel:GetModel('PA2MASTER'):GetValue('PA2_DOC')
	cSerie   := oModel:GetModel('PA2MASTER'):GetValue('PA2_SERIE')
	nDecres  := oModel:GetModel('PA2MASTER'):GetValue('PA2_DECRES')
	nResult  := (( nDecres / DT6->DT6_VALFAT ) * 100)

	If nPerDesc > 0 .And. nResult > nPerDesc
		MsgAlert("O valor do desconto informado é maior que o percentual permitido [" + AllTrim(cValToChar(nResult)) + "].")
		lRet := .F.
	EndIf

	If lRet .And. nDecres >= DT6->DT6_VALFAT
		lRet := .F.
	EndIf

EndIf

Return( lRet ) 


/*/{Protheus.doc} MO010Ini
Utilizado no X3_RELACAO dos campos virtuais
@author Jose Luiz Pinheirio Junior
@type User function
@since out/2022
@version 1.0
/*/
User Function MO010Ini(cCampo)
Local xRet 	:= "" 
Local nPos	:= 0

Default cCampo  := Alltrim( Readvar() )

If ( nPos := aScan(aDadosPA2,{|x| x[1] == PA2->PA2_ID  }) ) == 0
	PesqDoc(PA2->PA2_FILDOC,PA2->PA2_DOC,PA2->PA2_SERIE,1)
EndIf

If ( nPos := aScan(aDadosPA2,{|x| x[1] == PA2->PA2_ID .And. x[2] $ cCampo  }) ) > 0
	xRet := aDadosPA2[nPos][3]
EndIf

Return( xRet ) 



/*/{Protheus.doc} PesqDoc
Localiza o Documento posicionado
@author Jose Luiz Pinheirio Junior
@type Static function
@since Set/2022
@version 1.0
/*/
Static Function PesqDoc(cFilDoc,cDoc,cSerie,nOpc)
Local oModel 	 := FwModelActive()
Local cQry 		 := ""
Local lRet		 := .T.
Local cAlias 	 := GetNextAlias()

Default nOpc := 3 //-- Inclusao

cQry   := " SELECT DT6_CLIREM, DT6_LOJREM, REM.A1_NOME NOMREM, REM.A1_MUN MUNREM, REM.A1_EST ESTREM, "
cQry   += "        DES.A1_NOME NOMDES, DES.A1_MUN MUNDES, DES.A1_EST ESTDES, "
cQry   += "   	   DT6_CDRORI, DT6_CDRDES, DT6_PREFIX, DT6_NUM, DT6_VALFAT, DT6_DECRES, DT6.R_E_C_N_O_ RECNODT6, "
cQry   += "   	   (SELECT COUNT(1) FROM " + RetSqlName("PA2") + " PA2 "
cQry   += "   	     WHERE PA2_FILIAL = '" + xFilial("PA2") + "' "
cQry   += "   	       AND PA2_FILDOC = DT6_FILDOC "
cQry   += "   	       AND PA2_DOC = DT6_DOC "
cQry   += "   	   	   AND PA2_SERIE = DT6_SERIE "
cQry   += "   	       AND PA2.D_E_L_E_T_ = ' ' "
cQry   += "   	       AND PA2_STATUS IN ('1','2') ) PA2QTDE " //-- solicitacao com status em aprovacao N1 ou N2
cQry   += "   FROM " + RetSqlName("DT6") + " DT6 "
cQry   += "   JOIN " + RetSqlName("SA1") + " REM "
cQry   += "     ON REM.A1_FILIAL = '" + xFilial("SA1") + "' "
cQry   += "    AND REM.A1_COD = DT6_CLIREM "
cQry   += "    AND REM.A1_LOJA = DT6_LOJREM "
cQry   += "    AND REM.D_E_L_E_T_ = ' ' "
cQry   += "   JOIN " + RetSqlName("SA1") + " DES "
cQry   += "     ON DES.A1_FILIAL = '" + xFilial("SA1") + "' "
cQry   += "    AND DES.A1_COD = DT6_CLIREM "
cQry   += "    AND DES.A1_LOJA = DT6_LOJREM "
cQry   += "    AND DES.D_E_L_E_T_ = ' ' "
cQry   += "  WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
cQry   += "    AND DT6_FILDOC = '" + cFilDoc + "' "
cQry   += "    AND DT6_DOC = '" + cDoc + "' "
cQry   += "    AND DT6_SERIE = '" + cSerie + "' "
cQry   += "    AND DT6.D_E_L_E_T_ = ' ' "

cQry   := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlias)
TCSetField(cAlias,"DT6_VALFAT","N",TamSx3("DT6_VALFAT")[1],TamSx3("DT6_VALFAT")[2])
TCSetField(cAlias,"DT6_DECRES","N",TamSx3("DT6_DECRES")[1],TamSx3("DT6_DECRES")[2])
TCSetField(cAlias,"PA2QTDE" , "N" , 14 , 0 )
TCSetField(cAlias,"RECNODT6" , "N" , 14 , 0 )
(cAlias)->(DbGoTop())	

If (cAlias)->(Eof()) 
	lRet := .F.
Else
	DT6->(DbGoTo((cAlias)->RECNODT6))

	If nOpc <> 1 // Visualizar nao executa validação
		If !Empty(DT6->DT6_NUM)
			MsgAlert("Documento ["+ cFilDoc + "-" + cDoc + "-" + cSerie + "] pertence a fatura ["+ DT6->DT6_PREFIX + DT6->DT6_NUM +"].")
			lRet := .F.
		EndIf

		If lRet .And. DT6->DT6_BLQDOC == StrZero(1, Len(DT6->DT6_BLQDOC)) //-- Bloqueio: 1-Sim
			MsgAlert("Documento ["+ cFilDoc + "-" + cDoc + "-" + cSerie + "] com status de Bloqueado.")
			lRet := .F.
		EndIf

		If lRet .And. DT6->DT6_DECRES > 0
			MsgAlert("Documento ["+ cFilDoc + "-" + cDoc + "-" + cSerie + "] já possui valor de desconto aplicado [" + AllTrim(cValToChar(DT6->DT6_DECRES)) +"].")
			lRet := .F.
		EndIf

		If lRet .And. (cAlias)->PA2QTDE > 0
			MsgAlert("Documento ["+ cFilDoc + "-" + cDoc + "-" + cSerie + "] já possui solicitação de desconto em aberto.")
			lRet := .F.
		EndIf


		If lRet
			oModel:GetModel('PA2MASTER'):SetValue('PA2_CDRORI' , DT6->DT6_CDRORI)
			oModel:GetModel('PA2MASTER'):SetValue('PA2_CDRDES' , DT6->DT6_CDRDES)
			oModel:GetModel('PA2MASTER'):SetValue('PA2_CLIREM' , DT6->DT6_CLIREM)
			oModel:GetModel('PA2MASTER'):SetValue('PA2_LOJREM' , DT6->DT6_LOJREM)
			oModel:GetModel('PA2MASTER'):SetValue('PA2_NOMREM' , AllTrim((cAlias)->NOMREM))
			oModel:GetModel('PA2MASTER'):SetValue('PA2_MUNREM' , AllTrim((cAlias)->MUNREM))
			oModel:GetModel('PA2MASTER'):SetValue('PA2_ESTREM' , AllTrim((cAlias)->ESTREM))
			oModel:GetModel('PA2MASTER'):SetValue('PA2_CLIDES' , DT6->DT6_CLIDES)
			oModel:GetModel('PA2MASTER'):SetValue('PA2_LOJDES' , DT6->DT6_LOJDES)
			oModel:GetModel('PA2MASTER'):SetValue('PA2_NOMDES' , AllTrim((cAlias)->NOMDES))
			oModel:GetModel('PA2MASTER'):SetValue('PA2_MUNDES' , AllTrim((cAlias)->MUNDES))
			oModel:GetModel('PA2MASTER'):SetValue('PA2_ESTDES' , AllTrim((cAlias)->ESTDES))
			oModel:GetModel('PA2MASTER'):SetValue('PA2_VALFAT' , DT6->DT6_VALFAT)
			oModel:GetModel('PA2MASTER'):SetValue('PA2_DECRES' , 0 )

		Else
			oModel:GetModel('PA2MASTER'):SetValue('PA2_CDRORI' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_CDRDES' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_CLIREM' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_LOJREM' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_NOMREM' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_MUNREM' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_ESTREM' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_CLIDES' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_LOJDES' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_NOMDES' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_MUNDES' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_ESTDES' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_MOTIVO' , ' ')
			oModel:GetModel('PA2MASTER'):SetValue('PA2_VALFAT' , 0  )
			oModel:GetModel('PA2MASTER'):SetValue('PA2_DECRES' , 0  )
		EndIf
	Else
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_CDRORI' , DT6->DT6_CDRORI  } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_CDRDES' , DT6->DT6_CDRDES  } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_CLIREM' , DT6->DT6_CLIREM  } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_LOJREM' , DT6->DT6_LOJREM  } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_NOMREM' , AllTrim((cAlias)->NOMREM) } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_MUNREM' , AllTrim((cAlias)->MUNREM) } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_ESTREM' , AllTrim((cAlias)->ESTREM) } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_CLIDES' , DT6->DT6_CLIDES  } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_LOJDES' , DT6->DT6_LOJDES  } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_NOMDES' , AllTrim((cAlias)->NOMDES) } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_MUNDES' , AllTrim((cAlias)->MUNDES) } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_ESTDES' , AllTrim((cAlias)->ESTDES) } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_VALFAT' , DT6->DT6_VALFAT  } )
		aAdd(aDadosPA2, { PA2->PA2_ID, 'PA2_DECRES' , DT6->DT6_DECRES  } )
	EndIf


EndIf

(cAlias)->(DbCloseArea())
Return lRet


/*/{Protheus.doc} PosVldMdl
Realiza a Inclusao do bloqueio do documento.
@author Jose Luiz Pinheirio Junior
@type Static function
@since Set/2022
@version 1.0
/*/
Static Function PosVldMdl(oModel)
Local lRet		:=.T.
//Local nOpc    	:= oModel:GetOperation()
Local aArea   	:= GetArea()
Local cMotBlq   := ""

Local cItem		:= ''
Local cFilDoc	:= ''
Local cDoc		:= ''   
Local cSerie	:= ''
Local cID		:= ''
Local cCodOco   := SuperGetMV("ES_OCOBLQ", .F. ," ")
Local aCab	 	:= {}
Local aItens 	:= {}

Private lMSHelpAuto 	:= .F. // Apresenta erro em tela
Private lMSErroAuto 	:= .F. // Caso a variavel torne-se .T. apos MsExecAuto, apresenta erro em tela
Private lAutoErrNoFile	:= .T.

cMotBlq := "Bloqueio por solicitacao de desconto no documento."
// Gera Bloqueio de usuario por rentabilidade

If Empty(cCodOco)
	MsgAlert("Codigo de Ocorrencia de bloqueio nao configurada no parametro ES_OCOBLQ.")
	Return .F.
EndIf

Begin Transaction
//-- Gera bloqueio por Nives (DDU) (2 niveis)

cID := oModel:GetModel('PA2MASTER'):GetValue('PA2_ID')

lRet := Tmsa029Blq( 3  ,;					//-- 01 - nOpc
					'MOVA010',;				//-- 02 - cRotina
					'U5'  ,;				//-- 03 - cTipBlq
					DT6->DT6_FILORI,;		//-- 04 - cFilOri
					'PA2' ,;				//-- 05 - cTab
					'1' ,;					//-- 06 - cInd
					xFilial('PA2') + cID ,; //-- 07 - cChave
					cID ,;					//-- 08 - cCod
					cMotBlq	,;				//-- 09 - cDetalhe
					)						//-- 10 - Opcao da Rotina

If lRet
	aCab	:= {}
	aItens	:= {}
	cItem	:= StrZero(1,Len(DUA->DUA_SEQOCO))

	cFildoc  := oModel:GetModel('PA2MASTER'):GetValue('PA2_FILDOC')
	cDoc     := oModel:GetModel('PA2MASTER'):GetValue('PA2_DOC')
	cSerie   := oModel:GetModel('PA2MASTER'):GetValue('PA2_SERIE')

	//-- Itens da Ocorrencia
	AAdd(aItens, {	{"DUA_SEQOCO", cItem       , Nil},;
					{"DUA_CODOCO", cCodOco     , Nil},;
					{"DUA_FILDOC", cFilDoc     , Nil},;
					{"DUA_DOC"   , cDoc        , Nil},;
					{"DUA_SERIE" , cSerie      , Nil} } )

	lMsErroAuto := .F.
	//-- Inclusao da Ocorrencia
	MsExecAuto({|x,y,z| Tmsa360(x,y,z)} , aCab , aItens , {} ,3)
	If lMsErroAuto
		DisarmTransaction()
		lRet := .F.
	EndIf
Else
	DisarmTransaction()
	lRet := .F.
EndIf

End Transaction

RestArea(aARea)
Return lRet

