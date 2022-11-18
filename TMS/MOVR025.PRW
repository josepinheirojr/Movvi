#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MOVR025
Relatório Clientes com Contrato a Vencer - REQ14
@type function
@version 12.1.33
@author Daniel Leme
@since 18/10/2022
@return variant, Nil
/*/
User Function MOVR025()

Local cPerg   := 'MOVR025'
Local cTitulo := 'Relatório Clientes com Contrato a Vencer'
Local wnRel   := 'MOVR025'

AjustaSX1(cPerg)

oReport:= ReportDef({|| Pergunte(cPerg,.T.)},cTitulo,wnRel)
oReport:PrintDialog()

Return Nil

/*/{Protheus.doc} ReportDef
Definição do layout do Relatório
@type function
@version 12.1.33
@author Daniel Leme
@since 18/10/2022
@return variant, Nil
/*/
Static Function ReportDef(cPerg,cTitulo,wnRel)

Local oReport    
oReport := TReport():New(wnRel,cTitulo,cPerg,{|oReport| ReportPrint(oReport)},cTitulo)

oSection1:= TRSection():New(oReport,"Contratos",{"AAM"}) 
oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1,"AAM_CODCLI"	,"AAM",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"AAM_LOJA"	,"AAM",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"AAM_NOMCLI"	,"AAM",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A1_CGC"	    ,"SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"AAM_TPCONT"	,"AAM",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"AAM_STATUS"	,"AAM",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"AAM_INIVIG"	,"AAM",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"AAM_FIMVIG"	,"AAM",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DDC_CODNEG"	,"DDC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DDC_INIVIG"	,"DDC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DDC_FIMVIG"	,"DDC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DDA_SERVIC"	,"DDA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DDA_TABFRE"	,"DDA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DDA_TIPTAB"	,"DDA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DDA_TABALT"	,"DDA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DDA_TIPALT"	,"DDA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*/{Protheus.doc} ReportDef
Impressão do Relatório
@type function
@version 12.1.33
@author Daniel Leme
@since 18/10/2022
@return variant, Nil
/*/
Static Function ReportPrint(oReport)
Local oSection1	:= oReport:Section(1)

oSection1:BeginQuery()
BeginSql Alias 'QRYREQ14'  
	SELECT  
	    AAM_CODCLI,
		AAM_LOJA  ,
		AAM_NOMCLI,
		A1_CGC	  ,
		AAM_TPCONT,
		AAM_STATUS,
		AAM_INIVIG,
		AAM_FIMVIG,
		DDC_CODNEG,
		DDC_INIVIG,
		DDC_FIMVIG,
		DDA_SERVIC,
		DDA_TABFRE,
		DDA_TIPTAB,
		DDA_TABALT,
		DDA_TIPALT
	  FROM %Table:AAM% AAM
	  INNER JOIN %Table:SA1% SA1
	    ON  A1_FILIAL = %xFilial:SA1%
	    AND A1_COD    = AAM_CODCLI
	    AND A1_LOJA   = AAM_LOJA
	    AND SA1.D_E_L_E_T_ = ' ' 
	  INNER JOIN %Table:DDC% 
	    ON DDC_FILIAL =  %xFilial:DDC%
	   AND DDC_NCONTR = AAM_CONTRT
	   AND DDC.D_E_L_E_T_ = ' '
	  INNER JOIN %Table:DDA% 
	    ON DDA_FILIAL = %xFilial:DDA%
	   AND DDA_NCONTR = DDC_NCONTR 
	   AND DDA_CODNEG = DDC_CODNEG 
	   AND DDA.D_E_L_E_T_ = ' ' 
	  WHERE AAM_FILIAL = %xFilial:AAM%
	    AND AAM_FIMVIG BETWEEN  %Exp:mv_par01% AND %Exp:mv_par02%
	    AND AAM_CODCLI BETWEEN  %Exp:mv_par03% AND %Exp:mv_par05%
	    AND AAM_LOJA   BETWEEN  %Exp:mv_par04% AND %Exp:mv_par06%
	    AND AAM.D_E_L_E_T_ = ' ' 
	ORDER BY AAM_FIMVIG DESC
EndSql		
oSection1:EndQuery() 	
                  
oSection1:Print() // processa as informacoes da tabela principal		

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1³ Autor ³ DLeme             ³ Data ³12/12/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas inclu¡ndo-as caso n„o existam        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1( cPerg )

Local aArea := GetArea()

U_DLM_PSx1( { cPerg, "01","Vencimento De ?" ,"Vencimento De ?","Vencimento De ?","mv_ch1","D",08	,0,0,"G","",""      ,""	,"","mv_par01" })
U_DLM_PSx1( { cPerg, "02","Vencimento Até?" ,"Vencimento Até?","Vencimento Até?","mv_ch2","D",08	,0,0,"G","",""      ,""	,"","mv_par02" })
U_DLM_PSx1( { cPerg, "03","Cliente De ?"    ,"Cliente De ?"   ,"Cliente De ?" 	,"mv_ch3","C",Len(SA1->A1_COD)	,0,0,"G","","SA1"   ,""	,"","mv_par03" })
U_DLM_PSx1( { cPerg, "04","Loja De ?"       ,"Loja De ?"      ,"Loja De ?"   	,"mv_ch4","C",Len(SA1->A1_LOJA)	,0,0,"G","",""      ,""	,"","mv_par04" })
U_DLM_PSx1( { cPerg, "05","Cliente Até?"    ,"Cliente Até?"   ,"Cliente Até?" 	,"mv_ch5","C",Len(SA1->A1_COD)	,0,0,"G","","SA1"   ,""	,"","mv_par05" })
U_DLM_PSx1( { cPerg, "06","Loja Até?"   	,"Loja Até?"   	  ,"Loja Até?"   	,"mv_ch6","C",Len(SA1->A1_LOJA)	,0,0,"G","",""      ,""	,"","mv_par06" })

//PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,;
//                            cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,;
//                           cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

RestArea(aArea)

Return Nil
