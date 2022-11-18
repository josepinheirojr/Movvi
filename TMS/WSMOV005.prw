#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} INT008
Webservice Rest (GET/POST)
@author Jose Luiz Pinheiro Junior
@type Rest function
@since SET/2022
@version 1.0
/*/
WSRESTFUL WSMOV005 DESCRIPTION "Processo reversão de pagador frete - WSMOV005"

WSDATA FilDocto      AS String //-- Param: Usado em Get 
WSDATA NumDocto      AS String //-- Param: Usado em Get
WSDATA SerieDocto    AS String  //-- Param: Usado em Get
WSDATA CnpjDevedor   AS String  //-- Param: Usado em Get
WSDATA FilDeb        AS String  //-- Param: Usado em Get
WSDATA NumSol        AS String  //-- Param: Usado em Get


    WSMETHOD GET PESQSOL ;
    DESCRIPTION " Consulta status da solicitação de transferencia " ;
    WSSYNTAX "/PESQSOL/1.0";
    PATH "/PESQSOL/1.0"


    WSMETHOD POST INCSOL ;
    DESCRIPTION " Solicitação de transferencia de Devedor" ;
    WSSYNTAX "/INCSOL/1.0";
    PATH "/INCSOL/1.0"

END WSRESTFUL

//-- GET
WSMETHOD GET PESQSOL WSRECEIVE FilDocto,NumDocto,SerieDocto,CnpjDevedor,NumSol WSSERVICE WSMOV005

Local cFildoc    := "" 
Local cDoc	 	 := "" 
Local cSerie     := "" 
Local cCnpjDev   := "" 
Local cNumSol	 := ""

Local lCont 	 := .T.
Local cRetorno   := ""
Local cHist      := ""

Local oResult

If Type('cEmpAnt') == 'U'
	RpcSetType(3)
	//RpcSetEnv( "99"/*cEmpRun*/,"01"/*cFilRun*/,/*cUsrRun*/,/*cPasRun*/,"TMS",/*FunName*/,/*{Tables}*/)
	RpcSetEnv( "01"/*cEmpRun*/,"01"/*cFilRun*/,/*cUsrRun*/,/*cPasRun*/,"TMS",/*FunName*/,/*{Tables}*/)
	nModulo := 43
EndIf	

cFildoc  := Self:FilDocto
cDoc	 := Self:NumDocto
cSerie   := Self:SerieDocto
cCnpjDev := Self:CnpjDevedor
cNumSol  := Self:NumSol

//-- Default
If cFildoc == Nil
   cFildoc := ""
EndIf

If cDoc == Nil
   cDoc := ""
EndIf

If cSerie == Nil
   cSerie := ""
EndIf

If cCnpjDev == Nil
   cCnpjDev := ""
EndIf

If cNumSol == Nil
   cNumSol := ""
EndIf


//Conout("Chamada do metodo GET " + "cFildoc.: "  + cFildoc)
//Conout("Chamada do metodo GET " + "cDoc....: "  + cDoc)
//Conout("Chamada do metodo GET " + "cSerie..: "  + cSerie)
//Conout("Chamada do metodo GET " + "cCnpjDev: "  + cCnpjDev)

Self:SetContentType("application/json")

//-- pesquisa de o documento e fatura existe e ja deixa posicionada.
If lCont .And. !PesqDoc(cFilDoc,cDoc,cSerie)
	cRetorno := 'Documento nao encontrado: [' + cFilDoc + "-" + cDoc + "-" + cSerie + '].'
	lCont := .F.
EndIf

//-- Pesquisa o se o cliente devedor existe e já deixa posicionado.
If lCont .And. !PesqCli(cCnpjDev)
	cRetorno   := 'Cliente devedor nao encontrado para o Documento: [' + cCnpjDev + '].'
	lCont := .F.
EndIf

//-- coloca na filial de Origem do Documento.
cFilAnt := DT6->DT6_FILORI
If !Empty(cNumSol)
	cNumSol := StrTran(cNumSol,"-","")
EndIf

If lCont
	If !Empty(cNumSol)
		DVX->(DbSetOrder(1)) //-- DVX_FILIAL+DVX_FILORI+DVX_NUMSOL
		DVX->(DBSeek(xFilial("DVX") + cNumSol))
		If DVX->(DVX_FILDOC+DVX_DOC+DVX_SERIE) <> DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)
			cRetorno := 'O documento [' + cFilDoc + "-" + cDoc + "-" + cSerie + '] nao pertence a solicitacao de transferencia: ['
			cRetorno += DVX->DVX_FILORI + '-' + DVX->DVX_NUMSOL + '].'
			lCont := .F.
		EndIf
	ElseIf !Empty(DT6->DT6_NUMSOL) 
		DVX->(DbSetOrder(1)) //-- DVX_FILIAL+DVX_FILORI+DVX_NUMSOL
		lCont := DVX->(DBSeek(xFilial("DVX") + DT6->(DT6_FILORI+DT6_NUMSOL)))
	Else
		DVX->(DbSetOrder(4)) //-- DVX_FILIAL+DVX_FILDOC+DVX_DOC+DVX_SERIE+DVX_FILORI	
		lCont := DVX->(DBSeek(xFilial("DVX")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE+DT6_FILORI)))
	EndIf

	If lCont
		If DVX->(DVX_CLIDEV + DVX_LOJDEV) == SA1->(A1_COD + A1_LOJA)
			cNumSol := DVX->DVX_FILORI + '-' + DVX->DVX_NUMSOL
			If DVX->DVX_SITSOL == "1" // solicitacao em aberto.
				cRetorno := 'O documento [' + cFilDoc + "-" + cDoc + "-" + cSerie + '] possui a solicitacao '
				cRetorno += '[' + DVX->DVX_FILORI + '-' + DVX->DVX_NUMSOL + '] de transferencia com status de ABERTO '
				cRetorno += 'em [' + DtoC(DVX->DVX_DATSOL) + ' - ' +  Transform(DVX->DVX_HORSOL, "@R 99:99") + '].'
			ElseIf DVX->DVX_SITSOL == "2" // Solicitacao aprovada
				cRetorno := 'O documento [' + cFilDoc + "-" + cDoc + "-" + cSerie + '] possui a solicitacao '
				cRetorno +=  '[' + DVX->DVX_FILORI + '-' + DVX->DVX_NUMSOL + '] de transferencia APROVADA em [' + DtoC(DVX->DVX_APVREJ) + '].'
				cHist    := StrTran(MsMM(DVX->DVX_CDHSOL,80),Chr(13),". ")
			Else // Solicitacao rejeitada
				cRetorno := 'O documento [' + cFilDoc + "-" + cDoc + "-" + cSerie + '] possui a solicitacao '
				cRetorno +=  '[' + DVX->DVX_FILORI + '-' + DVX->DVX_NUMSOL + '] de transferencia REJEITADA em [' + DtoC(DVX->DVX_APVREJ) + '].'
				cHist    := StrTran(MsMM(DVX->DVX_CDHREJ,80),Chr(13),". ")
			EndIf
		Else
			cRetorno := 'O documento [' + cFilDoc + "-" + cDoc + "-" + cSerie + '] nao possui a solicitacao de transferencia para o CNPJ: [' + cCnpjDev + '].'
			lCont := .F.
		EndIf
	Else
		cRetorno := 'Nao encontrado solicitacao de transferencia para o documento [' + cFilDoc + "-" + cDoc + "-" + cSerie + '].'
		lCont := .F.
	EndIf
Else
	cRetorno := 'Nao encontrado solicitacao de transferencia para o documento [' + cFilDoc + "-" + cDoc + "-" + cSerie + '].'
	lCont := .F.
Endif

oResult := JsonObject():New()
If lCont
	oResult["Status"] := "Success"
	oResult["Details"] := cRetorno 
	If !Empty(cNumSol)
		oResult["NumSol"] := cNumSol
	EndIf
	If !Empty(cHist)
		oResult["Comment"] := cHist
	EndIf
	oResult["InfoAdicionais"]  := {}

	aAdd(oResult["InfoAdicionais"],JsonObject():New())
	DVV->(DbSetOrder(1)) //-- DVV_FILIAL+DVV_FILDOC+DVV_DOC+DVV_SERIE+DVV_PREFIX+DVV_NUM+DVV_TIPO
	If DVV->(DBSeek(xFilial("DVX")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))
		aTail(oResult["InfoAdicionais"])["FaturaAnterior"] := DVV->DVV_PREFIX + '-' +DVV->DVV_NUM + '-' + DVV->DVV_TIPO
	EndIf
	
	If !Empty(DT6->(DT6_PREFIX+DT6_NUM+DT6_TIPO)) 
		aTail(oResult["InfoAdicionais"])["FaturaAtual"] := DT6->DT6_PREFIX + '-' + DT6->DT6_NUM + '-' + DT6->DT6_TIPO
		aTail(oResult["InfoAdicionais"])["DataEmissao"] := DtoC(SE1->E1_EMISSAO)
	EndIf

	aTail(oResult["InfoAdicionais"])["ValorFrete"] := CValToChar(DT6->DT6_VALFRE)
	aTail(oResult["InfoAdicionais"])["ValorImposto"] := CValToChar(DT6->DT6_VALIMP)
	aTail(oResult["InfoAdicionais"])["ValorTotal"] := CValToChar(DT6->DT6_VALTOT)
	
	aTail(oResult["InfoAdicionais"])["GrupoVendas"] := SA1->A1_GRPVEN + '-' +AllTrim(POSICIONE("ACY",1,xFilial("ACY")+SA1->A1_GRPVEN,"ACY_DESCRI"))

Else
	//-- Montagem de Retorno em JSON
	oResult["Status"] := "Error"
	oResult["Details"] := cRetorno 
	If !Empty(cHist)
		oResult["comment"] := cHist
	EndIf
EndIf

cJsRet:= FWJsonSerialize(oResult,.T.,.T.)
Self:SetResponse(cJsRet) 
FreeObj(oResult)
	
Return .T.

//-- POST
WSMETHOD POST INCSOL WSSERVICE WSMOV005

Local nI     := 0
Local aInfo  := {}
Local aEnvPAZ:= {}
Local aRetPAZ:= {}
Local cJSON  := ''
Local cJsRet := ''
Local lProc  := .F. //-- .T. - Processado com sucesso / .F. - Processado com erro
Local aErro  := {}
Local cNumSol := ''
Local oJSON,oResult 


If Type('cEmpAnt') == 'U'
	RpcSetType(3)
	//RpcSetEnv( "99"/*cEmpRun*/,"01"/*cFilRun*/,/*cUsrRun*/,/*cPasRun*/,"TMS",/*FunName*/,/*{Tables}*/)
	RpcSetEnv( "01"/*cEmpRun*/,"01"/*cFilRun*/,/*cUsrRun*/,/*cPasRun*/,"TMS",/*FunName*/,/*{Tables}*/)
	nModulo := 43
EndIf	

Conout("Chamada do metodo POST")

::SetContentType("application/json")

//-- Recebimento do JSON
cJSON := ::GetContent()
oJSON := JsonObject():new()
oJSON:fromJson(cJSON)
aInfo := oJSON:GetNames()

Varinfo("[WSMOV005] Json [POST] cJSON:" + TIME() , cJSON)

//-- Montagem de Retorno em JSON
oResult := JsonObject():New()

Conout("Gravacao do Json na PAZ")

aAdd(aEnvPAZ,{"PAZ_STATUS","1"}) //-- Em aberto
aAdd(aEnvPAZ,{"PAZ_TIPO"  ,"R"})
aAdd(aEnvPAZ,{"PAZ_ORIGEM","WSMOV005"})
aAdd(aEnvPAZ,{"PAZ_DESCRI","Reversao Pagador Frete"})
aAdd(aEnvPAZ,{"PAZ_MSG"   ,cJSON})
aAdd(aEnvPAZ,{"PAZ_RET"   ,cJsRet})

Varinfo("[WSMOV005] Json [aEnvPAZ] :" + TIME() , aEnvPAZ)

//oResult["Success"]    := "Solicitacao reversao de frete realizada com sucesso!"
//oResult["IdProtheus"] := "00010001002345"

aRetPAZ := aClone(U_MVINCPAZ(aEnvPAZ))

Varinfo("[WSMOV005] Json [aRetPAZ] :" + TIME() , aRetPAZ)

lProc := aRetPAZ[1] .And. U_WSMOV005(aRetPAZ[2],aErro,@cNumSol)


//-- Processamento de WSMOV005
If lProc
   	oResult["Success"] := {}
   	aAdd(oResult["Success"],JsonObject():New())
	aTail(oResult["Success"])["IdProtheus"] := aRetPAZ[2]
	aTail(oResult["Success"])["NumSol"]     := cNumSol 
   	aTail(oResult["Success"])["Details"]    := "Solicitacao reversao de frete realizada com sucesso!"
	Conout("Solicitacao reversao de frete realizada com sucesso!" + " IdProtheus: " + aRetPAZ[2])
Else
	oResult["Errors"]    := {}
	For nI := 1 To Len(aErro)
		aAdd(oResult["Errors"],JsonObject():New())

		aTail(oResult["Errors"])["IdProtheus"] := aErro[nI,1]
		aTail(oResult["Errors"])["Error"]    := "Erro na Solicitacao da reversao de frete!"
		aTail(oResult["Errors"])["Details"]  := aErro[nI,2]
		Conout("Erro na Solicitação reversao de frete!" + " IdProtheus: " + aErro[nI,2])
	Next nI
EndIf

cJsRet:= FWJsonSerialize(oResult,.T.,.T.)
Self:SetResponse(cJsRet) 

//RESET ENVIRONMENT

Return .T.


/*/{Protheus.doc} WSMOV005
Inclusao da solicitacao de transferencia
@author Jose Luiz Pinheiro Junior
@type User function
@since Set/2022
@version 1.0
/*/
User Function WSMOV005(cID,aErro,cNumSol)

Local cQry     := ''
Local cFilDoc  := ''
Local cDoc     := ''
Local cSerie   := ''
Local cCnpjDev := ''
Local cCliDev  := ''
Local cLojDev  := ''
Local cHistDeb := ''
Local cStaLog  := ''
Local lCont    := .T.
Local nI	   := 0
Local cAlias   := GetNextAlias()

Default cID    := ''
Default aErro  := {}


//PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'


Conout("Iniciando o processamento da integração")

//-- Seleciona a Tabela PAZ para o INT008
cQry   += " SELECT R_E_C_N_O_ RECPAZ "
cQry   += "   FROM "+RetSqlName("PAZ")+" PAZ "
cQry   += "  WHERE PAZ.D_E_L_E_T_ = ' ' "
cQry   += "    AND PAZ_STATUS = '1' " //-- Somente em aberto
cQry   += "    AND PAZ_ORIGEM = 'WSMOV005' " 
If !Empty(cID)
	cQry   += "    AND PAZ_ID = '" + cID + "' " 
EndIf

cQry   := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlias)
TCSetField(cAlias,"RECPAZ" , "N" , 14 , 0 )

(cAlias)->(DbGoTop())		

While (cAlias)->(!Eof())

    PAZ->(dbGoTo((cAlias)->RECPAZ))
    
    cRetJSON:= AllTrim(PAZ->PAZ_MSG)

    oJSON   := JsonObject():New()
	cRet    := oJSON:fromJson(cRetJSON)

	cFilDoc	 := oJSON["FilDocto"]
	cDoc 	 := oJSON["NumDocto"]
	cSerie 	 := oJSON["SerieDocto"]
	cCnpjDev := oJSON["CnpjDevedor"]
	cFilDeb  := oJSON["FilDeb"]

	//-- Verifica se existe a Filial de debido no cadastro de empresas.
	If !Empty(cFilDeb)
		aRetSM0	:= FWLoadSM0()
		aSort(aRetSm0,,,{ |x,y| x[2] < y[2] } ) //-- Classifica por ordem de Filial.

		If aScan( aRetSM0, {|x| x[SM0_GRPEMP] + x[SM0_CODFIL] == cEmpAnt + cFilDeb } ) == 0 
			cErro   := 'Filial de debito [' + cFildeb + '] nao existente no cadastro de empresas.'
			Aadd(aErro,{ cID , cErro })
			cStaLog := '3'
			lCont := .F.
		EndIf
	EndIf

	//-- Pesquisa o se o cliente devedor existe e já deixa posicionado.
	If lCont .And.  !PesqCli(cCnpjDev)
		cErro   := 'Cliente devedor nao encontrado para o CNPJ: [' + cCnpjDev + ']'
		Aadd(aErro,{ cID , cErro })
		cStaLog := '3'
		lCont := .F.
	EndIf
	
	//-- pesquisa de o documento e fatura existe e ja deixa posicionada.
	If lCont .And. !PesqDoc(cFilDoc,cDoc,cSerie)
		cErro   := 'Documento nao encontrado: [' + cFilDoc + "-" + cDoc + "-" + cSerie + '].'
		Aadd(aErro,{ cID , cErro })
		cStaLog := '3'
		lCont := .F.
	EndIf

	//-- Deixa filial de Origem do Documento para fazer a solicitação.
	cFilAnt := DT6->DT6_FILORI
    If Empty(__cUserId)
		__cUserId := '000000'
	EndIf

	//-- Documento faturamento, nao pode ser solicitado transferencia.
	If lCont .And. !Empty(DT6->(DT6_PREFIX+DT6_NUM+DT6_TIPO)) 
		If SE1->E1_SALDO < SE1->E1_VALOR
			cErro  := 'O documento [' + cFilDoc + "-" + cDoc + "-" + cSerie + '] pertence a fatura [' + DT6_PREFIX + DT6_NUM +'] '
			cErro  += 'com baixa parcial. A tranferencia nao pode ser solicitada.'
			Aadd(aErro,{ cID , cErro })
			cStaLog := '3'
			lCont := .F.
		EndIf
	EndIf

	If lCont .And. ( DT6->(DT6_CLIDEV + DT6_LOJDEV) == SA1->(A1_COD + A1_LOJA) .And. ( If(Empty(cFilDeb), .T. , (DT6->DT6_FILDEB == cFilDeb)) )  )
		cErro   := 'Devedor do Documento [' + cFilDoc + "-" + cDoc + "-" + cSerie + '] e o mesmo da solicitacao. Altere o devedor ou a filial de debito.'
		Aadd(aErro,{ cID , cErro })
		cStaLog := '3'
		lCont := .F.
	EndIf

	/*
	If lCont .And. !Empty(cFilDeb) .And. ( DT6->DT6_FILDEB == cFilDeb  )
		cErro   := 'Filial de debito do Documento [' + cFilDoc + "-" + cDoc + "-" + cSerie + '] deve se diferente do título que esta sendo transferido.'
		Aadd(aErro,{ cID , cErro })
		cStaLog := '3'
		lCont := .F.
	EndIf
	*/

	DVX->(DbSetOrder(1)) //-- DVX_FILIAL+DVX_FILORI+DVX_NUMSOL
	If lCont .And. !Empty(DT6->DT6_NUMSOL) .And. DVX->(MsSeek(xFilial("DVX")+DT6->(DT6_FILORI+DT6_NUMSOL)))
		cErro   := 'Documento [' + cFilDoc + "-" + cDoc + "-" + cSerie + '] ja possui uma solicitacao de transferencia em andamento [' + DVX->DVX_FILORI + '-' + DVX->DVX_NUMSOL + '].'
		Aadd(aErro,{ cID , cErro })
		cStaLog := '3'
		lCont := .F.
	Endif

	If lCont
		cFilDeb := If(Empty(cFilDeb),DT6->DT6_FILDEB,cFilDeb)
		cCliDev := SA1->A1_COD
		cLojDev := SA1->A1_LOJA
		cHistDeb:= 'Transferencia solicitada por API Web.'

		//-- Gera solicitacao de transferencia e deixa posicionado o DVX.
		U_Tm890Grv(cFilDeb,cCliDev,cLojDev,cHistDeb)
		cNumSol := DVX->DVX_FILORI + '-' + DVX->DVX_NUMSOL
		cErro := ''
		cStaLog := '2'
	EndIf
		
    //-- Atualizo a chave em PAZ
    cRetorno := PAZ->PAZ_RET + CRLF
    cRetorno += REPLICATE("=", 20) + CRLF 
    cRetorno += " Processado no Protheus "+ DtoC(Date())+" - "+Time() + CRLF 
    cRetorno += REPLICATE("=", 20) + CRLF

	If Empty(aErro)
		cStaLog := '2'
	Else
		cStaLog := '3'
		For nI := 1 To Len(aErro)
			cRetorno += aErro[nI,2] + CRLF
		Next nI
	EndIf

	RecLock("PAZ",.F.)
	PAZ->PAZ_RET    := cRetorno 
	PAZ->PAZ_STATUS := cStaLog
	MsUnLock()
   
    (cAlias)->(DbSkip())
EndDo

(cAlias)->(DbCloseArea())

Return Empty(aErro)




/*/{Protheus.doc} PesqCli
Localiza o cliente e deixa posicionado
@author Jose Luiz Pinheirio Junior
@type Static function
@since Set/2022
@version 1.0
/*/
Static Function PesqCli(cCGC)
Local cQry := ""
Local lRet	:= .T.
Local cAlias := GetNextAlias()

//-- Fecha Arquivo Temporário
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQry   := " SELECT R_E_C_N_O_ RECNOSA1 "
cQry   += "   FROM " + RetSqlName("SA1") + " SA1 "
cQry   += "  WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
cQry   += "    AND A1_CGC LIKE '%" + cCGC + "%'
cQry   += "    AND D_E_L_E_T_ = ' ' "

cQry   := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlias)
TCSetField(cAlias,"RECNOSA1" , "N" , 14 , 0 )
(cAlias)->(DbGoTop())	

If (cAlias)->(Eof()) 
	lRet := .F.
Else
	SA1->(DbGoTo((cAlias)->RECNOSA1))
EndIf

(cAlias)->(DbCloseArea())
Return lRet



/*/{Protheus.doc} PesqDoc
Localiza o Documento e fatura deixa posicionado
@author Jose Luiz Pinheirio Junior
@type Static function
@since Set/2022
@version 1.0
/*/
Static Function PesqDoc(cFilDoc,cDoc,cSerie)
Local cQry := ""
Local lRet	:= .T.
Local cAlias := GetNextAlias()

//-- Fecha Arquivo Temporário
If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

cQry   := " SELECT DT6.R_E_C_N_O_ RECNODT6 , E1.R_E_C_N_O_ RECNOSE1 "
cQry   += "   FROM " + RetSqlName("DT6") + " DT6 "
cQry   += "   LEFT JOIN " + RetSqlName("SE1") + " E1 "
cQry   += "     ON E1_FILIAL = '" + xFilial("SE1") + "' "
cQry   += "    AND E1_PREFIXO = DT6_PREFIX "
cQry   += "    AND E1_NUM = DT6_NUM "
cQry   += "    AND E1_TIPO = DT6_TIPO "
cQry   += "    AND E1_CLIENTE = DT6_CLIDEV "
cQry   += "    AND E1_LOJA = DT6_LOJDEV "
cQry   += "    AND E1.D_E_L_E_T_ = ' ' "
cQry   += "  WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
cQry   += "   AND DT6_FILDOC = '" + cFilDoc + "' "
cQry   += "   AND DT6_DOC = '" + cDoc + "' "
cQry   += "   AND DT6_SERIE = '" + cSerie + "' "
cQry   += "   AND DT6.D_E_L_E_T_ = ' ' "
 
cQry   := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlias)
TCSetField(cAlias,"RECNODT6" , "N" , 14 , 0 )
TCSetField(cAlias,"RECNOSE1" , "N" , 14 , 0 )
(cAlias)->(DbGoTop())	

If (cAlias)->(Eof()) 
	lRet := .F.
Else
	DT6->(DbGoTo((cAlias)->RECNODT6))
	If (cAlias)->RECNOSE1 > 0
		SE1->(DbGoTo((cAlias)->RECNOSE1))
	EndIf
EndIf

(cAlias)->(DbCloseArea())
Return lRet

