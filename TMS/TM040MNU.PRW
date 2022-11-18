#include "PROTHEUS.CH"  
#include "TBICONN.CH" 

/*/-----------------------------------------------------------
PE TM040MNU()

@author Jose Luiz Pinheiro Junior         
@since 18/02/2022
@version 1.0
-----------------------------------------------------------/*/
User Function TM040MNU()             

Aadd(aRotina,{"Envia Workflow p/ Aprovação","U_TM040M01(1)",0,99,0,NIL})

Return


/*/-----------------------------------------------------------
PE TM040M01()

@author Jose Luiz Pinheiro Junior         
@since 18/02/2022
@version 1.0
-----------------------------------------------------------/*/
User Function TM040M01(nOpcx,oProcess)
Local lRet   	:= .T.
Local cMail		:= ""
Local cHtml     := ""
Local cChave    := ""
Local cOpc     	:= ""
Local cObs     	:= ""
Local cWFID    	:= ""
Local aArea  	:= {}
Local cErro     := ""


Default nOpcx := 1

//-- Envia e-mail para aprovação ao solicitante
If nOPcx == 1

    //-- Nao permite o envio do email para aprovação de cotação com status bloqueada.
    If DT4->DT4_STATUS == StrZero( 2, Len( DT4->DT4_STATUS ) )
        MsgInfo("Cotação bloqueada. Não permitido o envio para aprovação.")
        Return
    EndIf

    DUE->( DbSetOrder( 1 ) )  // DUE_FILIAL+DUE_CODSOL
    DUE->( MsSeek(xFilial("DUE") + DT4->DT4_CODSOL) )  

    cMail := Alltrim(DUE->DUE_EMAIL) 
    If Empty(cMail)
        MsgInfo("E-mail do solicitante não preenchido para envio.")
        lRet := .F.
    Else
        lRet := MsgYesNo("Deseja enviar o e-mail da Cotação [" + DT4->DT4_FILORI + "-" + DT4->DT4_NUMCOT + "] para aprovação ao Solicitante [" + AllTrim(DUE->DUE_NOME) + "] ?" +CHR(10)+CHR(13)+ "e-mail: " + cMail,"Atenção")
    EndIf

    If ! U_MovIsMail(cMail,@cErro)
        MsgStop("E-mail invalido informado no cadastro do Solicitante [" + cErro + "]", "Atenção")
        cMail := ""
        lRet := .F.
    EndIf

    If lRet

        lRet := U_MOVMailCot(cMail,@cHtml, 2 /*nOpcx*/) //-- envia email para aprovação do solicitante
        If lRet
            cMotBlq := "Bloqueio workflow ao solicitante " + Alltrim(DUE->DUE_NOME)
            // Gera Bloqueio de usuario por rentabilidade
            Tmsa029Blq( 3  ,;				//-- 01 - nOpc
                        'TMSA040',;			//-- 02 - cRotina
                        'U2'  ,;			//-- 03 - cTipBlq
                        DT4->DT4_FILORI,;	//-- 04 - cFilOri
                        'DT4' ,;			//-- 05 - cTab
                        '1' ,;				//-- 06 - cInd
                        xFilial('DT4') + DT4->DT4_FILORI + DT4->DT4_NUMCOT,; //-- 07 - cChave
                        DT4->DT4_NUMCOT 	,;	//-- 08 - cCod
                        cMotBlq 		,;		//-- 09 - cDetalhe
                        )						//-- 10 - Opcao da Rotina

            RecLock('DT4',.F.)
            //-- Grava status como 2 - Bloqueado por aprovação de worflow
            DT4->DT4_STATUS := StrZero( 2, Len( DT4->DT4_STATUS ) )
            //DT4->DT4_XWFID  := cHtml
            MsUnLock()

            MsgInfo("E-mail para aprovação enviado com sucesso." + CHR(10)+CHR(13) + "Solicitante: " + Alltrim(DUE->DUE_NOME) + CHR(10)+CHR(13) + "E-mail: [" + cMail + "]", "Atenção")
        Else
            MsgStop("Falha ao enviar e-mail ao Solicitante. E-mail: [" + cMail + "]", "Atenção")
        EndIf
    EndIf

//-- Recebe o retorno do Webservice para aprovação da cotação.
ElseIf nOPcx == 2

    //-- Obrigatorio setar o usuario para que o desbloqueio funcione
    If Empty(__cUserId)
		__cUserId := '000000'
	EndIf

	ChkFile("DT4")
	ChkFile("DDU")
	
    aArea 	:= { DT4->(GetArea()) , DDU->(GetArea())  }

    cFilAnt		:= alltrim(oProcess:oHtml:RetByName("CFILANT"))
    cChave	    := alltrim(oProcess:oHtml:RetByName("CHAVE"))
    cOpc     	:= alltrim(oProcess:oHtml:RetByName("OPC"))
    cObs     	:= alltrim(oProcess:oHtml:RetByName("OBS"))
    cWFID     	:= alltrim(oProcess:oHtml:RetByName("WFID"))

	oProcess:Finish() // FINALIZA O PROCESSO

    DT4->(DbSetOrder(1)) //-- DT4_FILIAL+DT4_FILORI+DT4_NUMCOT
	If !DT4->(MsSeek( cChave ))
        Conout("==>> Cotacao nao encontrada: " + cChave)
        Return .T.
    EndIf

    If cOpc == 'S' //-- Cotação APROVADA
        //-- Chama Rotina De Liberação Automática
        If !U_TM029Lib( 'L', 'TMSA040','U2','DT4',xFilial('DT4') + DT4->DT4_FILORI + DT4->DT4_NUMCOT , cObs)
            Conout("==>> Liberacao automatica nao pode ser realizada: " + cChave)
            Return .T.
        EndIf
        
        RecLock('DT4',.F.)
        DT4->DT4_STATUS := StrZero( 3, Len( DT4->DT4_STATUS ) )
        DT4->DT4_XDTCON := Date()
        DT4->DT4_XHRCON := StrTran(Left(Time(),5),":","")
        MsUnLock()   

        Conout( Replicate("-",80) )
        Conout( '==>> Cotacao APROVADA por WF: ' + cChave )

    ElseIf cOpc == 'N'

        //-- Chama Rotina De Liberação Automática
        If !U_TM029Lib( 'R', 'TMSA040','U2','DT4',xFilial('DT4') + DT4->DT4_FILORI + DT4->DT4_NUMCOT , cObs )
            Conout("==>> Liberacao automatica nao pode ser realizada: " + cChave)
            Return .T.
        EndIf

        RecLock('DT4',.F.)
        DT4->DT4_STATUS := StrZero( 2, Len( DT4->DT4_STATUS ) )
        MsUnLock()   

        Conout( Replicate("-",80) )
        Conout( '==>> Cotacao REPROVADA por WF: ' + cChave )
    
    EndIf
    AEval(aArea,{|x,y| RestArea(x) })

EndIf    

Return

