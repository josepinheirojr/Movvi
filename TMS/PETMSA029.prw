#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


/*/-----------------------------------------------------------
PE TMSA029()
Utilizado para tratar a seleção de multiplas tabelas de fretes.

@author Jose Luiz Pinheiro Junior         
@since 01/02/2022
@version 1.0
-----------------------------------------------------------/*/
User Function TMSA029()
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := aParam[1]
Local cIdPonto   := aParam[2]
Local cIdModel   := IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
//Local cClasse    := IIf( oObj<> NIL, oObj:ClassName(), '' )
//Local oModel     := FwModelActive()


Local aArea   	:= GetArea()
Local cFilDoc	:= ''
Local cDoc		:= ''   
Local cSerie	:= ''
Local nNiveis	:= 0
Local cCodOco   := SuperGetMV("ES_OCODESB", .F. ," ")
Local aCab	 	:= {}
Local aItens 	:= {}
Local cOpc		:= ""

Private lMSHelpAuto 	:= .F. // Apresenta erro em tela
Private lMSErroAuto 	:= .F. // Caso a variavel torne-se .T. apos MsExecAuto, apresenta erro em tela
Private lAutoErrNoFile	:= .T.

If cIdPonto == 'MODELCANCEL'
	Return xRet
EndIf

If cIdPonto ==  'MODELPOS' .And. cIdModel == 'TMSA029' 

	cOpc := U_TM029PAR()

	//-- posiciona da PA2 para pegar o documento e mudar status
	DbSelectArea(DDU->DDU_ALIAS)
	DbSetOrder(Val(DDU->DDU_INDEX))
	MsSeek(RTrim(DDU->DDU_CHAVE),.f.) // Usa RTrim Para Limpar os Espaços à Direita e Permitir Indexação Sem SoftSeek

	cFilDoc	:= PA2->PA2_FILDOC
	cDoc	:= PA2->PA2_DOC
	cSerie	:= PA2->PA2_SERIE

	//-- Rejeitar
	If cOpc == 'R' .And. DDU->DDU_STATUS == StrZero(1, Len(DDU->DDU_STATUS)) //-- Em Aberto 
		Begin Transaction
		RecLock("PA2",.F.)
		PA2->PA2_STATUS := StrZero(9, Len(PA2->PA2_STATUS)) //-- Reprovado
		PA2->(MsUnlock())

		aCab	:= {}
		aItens	:= {}
		cItem	:= StrZero(1,Len(DUA->DUA_SEQOCO))

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
			MsgAlert("Falha ao incluir ocorrencia para desbloqueio do documento ["+ cFilDoc + "-" + cDoc + "-" + cSerie + "].")
			xRet := .F.
		EndIf
		End Transaction

	//-- Liberar
	ElseIf cOpc == 'L'  .And. DDU->DDU_STATUS == StrZero(1, Len(DDU->DDU_STATUS)) //-- Em Aberto 

		//-- Necessito saber quantos niveis temos
		DDX->(DbSetOrder(1)) //-- DDX_FILIAL+DDX_ROTINA
		DDX->(DbSeek(xFilial('DDX') + DDU->DDU_ROTINA))
		nNiveis := DDX->DDX_NIVEIS

		//-- estou no ultimo nivel de aprovação
		If DDU->DDU_NIVBLQ == nNiveis
			Begin Transaction
			RecLock("PA2",.F.)
			PA2->PA2_STATUS := StrZero(3, Len(PA2->PA2_STATUS)) //-- Aprovado e libera o documento do bloqueio.
			PA2->(MsUnlock())

			//-- Atualiza o valor do desconto
			DT6->( DbSetOrder( 1 ) ) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
			DT6->(DbSeek( xFilial('DT6') + cFilDoc + cDoc + cSerie )) 
			RecLock("DT6",.F.)
			DT6->DT6_DECRES := PA2->PA2_DECRES
			DT6->(MsUnlock())

			aCab	:= {}
			aItens	:= {}
			cItem	:= StrZero(1,Len(DUA->DUA_SEQOCO))

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
				MsgAlert("Falha ao incluir ocorrencia para desbloqueio do documento ["+ cFilDoc + "-" + cDoc + "-" + cSerie + "].")
				xRet := .F.
			EndIf
			End Transaction
		Else
			RecLock("PA2",.F.)
			PA2->PA2_STATUS := StrZero(2, Len(PA2->PA2_STATUS)) //-- Muda para o proximo status de aprovação.
			PA2->(MsUnlock())
		EndIf

	EndIf

EndIf

RestArea(aARea)
Return xRet

