#Include "Protheus.ch"

/*/-----------------------------------------------------------
PE TM040APR()
Utilizado para gravar a data e hora da Confirmação da aprovação
da cotação.

@author Jose Luiz Pinheiro Junior         
@since 18/02/2022
@version 1.0
-----------------------------------------------------------/*/
User Function TM040APR(lGerHTML,cMail,cHtml)             
Local lRet   	:= .T.
Local lEnvMail	:= .F.
Local cErro     := ""

Private nOpcx  	:= ParamIXB[1]

Default lGerHTML 	:= .F. //-- Somente gera HTML
Default cMail		:= ""

If !lGerHTML
	If nOpcx == 6 .Or. IsInCallStack('TMSA040GRV') //-- se For Aprovacao OU ja possui todos os dados e nasce aprovado.
		cMail :=  Alltrim( Posicione("DUE",1,xFilial("DUE") + DT4->DT4_CODSOL ,"DUE_EMAIL") ) 
		If Empty(cMail)
			MsgInfo("E-mail do solicitante não preenchido para envio.")
		Else
			lEnvMail := MsgYesNo("Deseja enviar o e-mail da Cotação Aprovada ao Solicitante ?" +CHR(10)+CHR(13)+ "e-mail: " + cMail,"Atenção")
		EndIf

		If lEnvMail
			If ! U_MovIsMail(cMail,@cErro)
				MsgStop("E-mail invalido informado no cadastro do Solicitante [" + cErro + "]", "Atenção")
				cMail := ""
			EndIf
			U_MOVMailCot(cMail,@cHtml)

			RecLock('DT4',.F.)
			M->DT4_XDTCON := Date()
			M->DT4_XHRCON := StrTran(Left(Time(),5),":","")
			M->DT4_XWFID  := cHtml
			MsUnLock()
		EndIf	
	EndIf
Else
	U_MOVMailCot(cMail,@cHtml)
EndIf

Return lRet

