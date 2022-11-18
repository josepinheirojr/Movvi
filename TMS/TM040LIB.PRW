#Include "Protheus.ch"

/*/-----------------------------------------------------------
PE TM040LIB()
Utilizado para gravar a data e hora da Aprovação da aprovação
da cotação após o desbloqueio

@author Jose Luiz Pinheiro Junior         
@since 18/02/2022
@version 1.0
-----------------------------------------------------------/*/
User Function TM040LIB()             
Local lRet   	:= .T.
Local lEnvMail	:= .F.
Local cErro     := ""


If DT4->DT4_STATUS == StrZero( 3, Len( DT4->DT4_STATUS ) )   //Aprovada
	RecLock('DT4',.F.)
	DT4->DT4_XDTCON := Date()
	DT4->DT4_XHRCON := StrTran(Left(Time(),5),":","")
	MsUnLock()

	cMail :=  Alltrim( Posicione("DUE",1,xFilial("DUE") + DT4->DT4_CODSOL ,"DUE_EMAIL") )  
	lEnvMail := MsgYesNo("Deseja enviar o e-mail da Cotação Aprovada ao Solicitante ?" +CHR(10)+CHR(13)+ "e-mail: " + cMail,"Atenção")

	If lEnvMail
		If ! U_MovIsMail(cMail,@cErro)
			MsgStop("E-mail invalido informado no cadastro do Solicitante [" + cErro + "]", "Atenção")
			cMail := ""
		EndIf
		U_MOVMailCot(cMail)
	EndIf
EndIf

Return lRet


