#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MOVR015
RelatÛrio de Impressao das Solicitacao de desconto
@type function
@version 12.1.33
@author Jose Luiz Pinheiro JUnior
@since 24/10/2022
@return variant, Nil
/*/
User Function MOVR015()

Local cPerg   := 'MOVR015'
Local cTitulo := 'RelatÛrio de InformaÁıes de SolicitaÁ„o de Desconto'
Local wnRel   := 'MOVR015'

AjustaSX1(cPerg)
Pergunte(cPerg,.F.)

oReport:= ReportDef({|| Pergunte(cPerg,.T.)},cTitulo,wnRel)
oReport:PrintDialog()

Return Nil

/*/{Protheus.doc} ReportDef
DefiniÁ„o do layout do RelatÛrio
@type function
@version 12.1.33
@author Daniel Leme
@since 18/10/2022
@return variant, Nil
/*/
Static Function ReportDef(cPerg,cTitulo,wnRel)

Local oReport    
oReport := TReport():New(wnRel,cTitulo,cPerg,{|oReport| ReportPrint(oReport)},cTitulo)

oSection1:= TRSection():New(oReport,"SolicitaÁ„o Descontos",{"PA2"}) 
oSection1:SetTotalInLine(.F.)

TRCell():New(oSection1,"PA2_ID"	     ,"PA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"PA2_DATSOL"  ,"PA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"PA2_HORSOL"  ,"PA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"PA2_STATUS"  ,"PA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"PA2_USRSOL"  ,"PA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"PA2_MOTIVO"  ,"PA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"X5_DESCRI"   ,"SX5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"PA2_OBS"     ,"PA2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_SEQ"     ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_NIVBLQ"  ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_USRBLQ"  ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_NOMBLQ"  ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_DATBLQ"  ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_HORBLQ"  ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_USRLIB"  ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_NOMLIB"  ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_DATLIB"  ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_HORLIB"  ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_MTVLIB"  ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DDU_HISREJ"  ,"DDU",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DT6_FILDOC"  ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DT6_DOC"     ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DT6_SERIE"   ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DT6_VALFRE"  ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DT6_VALIMP"  ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DT6_DECRES"  ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"PERC_DESC"   ,"   ",/*Titulo*/,PesqPictQt("E1_COMIS1") /*Picture*/,TamSX3('E1_COMIS1')[1] /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DT6_CDRORI"  ,"DUA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"REGORI"      ,"   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DT6_CDRDES"  ,"DUA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"REGDES"      ,"   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DT6_CLIDEV"  ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DT6_LOJDEV"  ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A1_NOME"     ,"SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A1_GRPVEN"   ,"SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"ACY_DESCRI"  ,"ACY",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)



/*/{Protheus.doc} ReportDef
Impress„o do RelatÛrio
@type function
@version 12.1.33
@author Daniel Leme
@since 18/10/2022
@return variant, Nil
/*/
Static Function ReportPrint(oReport)
Local oSection1	:= oReport:Section(1)
Local cAlias    := GetNextAlias()
Local cExpr	    := "%%"

//-- filtra o tipo da solicitaÁ„o
If MV_PAR03 == 1
  cExpr := "%AND PA2_STATUS = '1'%" //-- somente aprovado
EndIf


oSection1:BeginQuery()
BeginSql Alias cAlias  

SELECT 
//-- dados da solicitacao
	PA2_ID, PA2_DATSOL, PA2_HORSOL, PA2_STATUS,PA2_USRSOL, PA2_MOTIVO, X5_DESCRI, PA2_OBS, 

//-- dados de aprovacao ou bloqueio
	DDU_SEQ, DDU_NIVBLQ, DDU_USRBLQ, DDU_NOMBLQ, DDU_DATBLQ, DDU_HORBLQ,
	DDU_USRLIB, DDU_NOMLIB, DDU_DATLIB, DDU_HORLIB, DDU_MTVLIB, DDU_HISREJ,
      	                              	        	     	                                                            
//-- dados do documento
	DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_VALFRE, DT6_VALIMP, DT6_DECRES, (( DT6_DECRES / DT6_VALFRE ) * 100) AS PERC_DESC, 
	DT6_CDRORI, ORI.DUY_DESCRI REGORI, DT6_CDRDES, DES.DUY_DESCRI REGDES, DT6_CLIDEV, DT6_LOJDEV, 

//-- dados do devedor
	A1_NOME, A1_GRPVEN, ACY_DESCRI


  FROM %table:PA2% PA2
  JOIN %table:SX5% X5   ON X5_FILIAL = %xFilial:SX5% AND X5_TABELA = 'P2' AND X5_CHAVE = PA2_MOTIVO AND X5.%NotDel%
  LEFT JOIN %table:DDU% DDU ON DDU_FILIAL = %xFilial:DDU% AND DDU_ROTINA = 'MOVA010' AND DDU_ALIAS = 'PA2' AND DDU_CHAVE = (PA2_FILIAL + PA2_ID) AND DDU.%NotDel%
  JOIN %table:DT6% DT6  ON DT6_FILIAL = %xFilial:DT6% AND DT6_FILDOC = PA2_FILDOC AND DT6_DOC = PA2_DOC AND DT6_SERIE = PA2_SERIE AND DT6.%NotDel%
  JOIN %table:SA1% A1   ON A1_FILIAL = %xFilial:SA1% AND A1_COD = DT6_CLIDEV AND A1_LOJA = DT6_LOJDEV AND A1.%NotDel%
  LEFT JOIN %table:ACY% ACY ON ACY_FILIAL = %xFilial:ACY% AND ACY_GRPVEN = A1_GRPVEN AND ACY.%NotDel%
  JOIN %table:DUY% ORI  ON ORI.DUY_FILIAL = %xFilial:DUY% AND ORI.DUY_GRPVEN = DT6_CDRORI AND ORI.%NotDel%
  JOIN %table:DUY% DES  ON DES.DUY_FILIAL = %xFilial:DUY% AND DES.DUY_GRPVEN = DT6_CDRORI AND DES.%NotDel%
 WHERE PA2_FILIAL = %xFilial:PA2%
   AND PA2_DATSOL BETWEEN %Exp:DTOS(mv_par01)% AND %Exp:DTOS(mv_par02)%
   AND PA2.%NotDel%
   %exp:cExpr%

	ORDER BY PA2_FILIAL, PA2_ID, DDU_SEQ
	
EndSql		
oSection1:EndQuery() 	
                  
oSection1:Print() // processa as informacoes da tabela principal		

Return( NIL )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ AjustaSX1≥ Autor ≥ DLeme             ≥ Data ≥12/12/2013≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Verifica as perguntas inclu°ndo-as caso nÑo existam        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function AjustaSX1( cPerg )

Local aArea := GetArea()

U_DLM_PSx1( { cPerg, "01","Dt Solicitacao De ?","Dt Solicitacao De ?" ,"Dt Solicitacao De ?","mv_ch1","D",08	,0,0,"G","",""  ,""	,"","mv_par01" })
U_DLM_PSx1( { cPerg, "02","Dt Solicitacao AtÈ?","Dt Solicitacao AtÈ?" ,"Dt Solicitacao AtÈ?","mv_ch2","D",08	,0,0,"G","",""  ,""	,"","mv_par02" })
U_DLM_PSx1( { cPerg, "03","Status Solicitacao?" ,"Status Solicitacao?","Status Solicitacao?","mv_ch1","C",01  ,0,0,"C","",""  ,"" ,"","mv_par03","Aprovado","","","","Todos","","","","","","","","","","","","","","","","","","","","",""} )

//PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,;
//                            cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,;
//                           cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

RestArea(aArea)

Return Nil
