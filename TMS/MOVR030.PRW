#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MOVR030
RelatÛrio de OcorrÍncias por Nota Fiscal - REQ18
@type function
@version 12.1.33
@author Daniel Leme
@since 18/10/2022
@return variant, Nil
/*/
User Function MOVR030()

Local cPerg   := 'MOVR030'
Local cTitulo := 'RelatÛrio de OcorrÍncias por Nota Fiscal'
Local wnRel   := 'MOVR030'

AjustaSX1(cPerg)

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

oSection1:= TRSection():New(oReport,"Contratos",{"AAM"}) 
oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1,"DUA_FILIAL"	,"DUA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_PRZENT"	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DTC_NUMNFC"	,"DTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DTC_VALOR"	,"DTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DTC_QTDVOL"	,"DTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DTC_PESO"	,"DTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_PESO"	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_DOC"	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_DATEMI"	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_DOCTMS"	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_CHVCTE"	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_VALTOT"	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_PRZORI"	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DUA_DATOCO"	,"DUA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DUA_HOROCO"	,"DUA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DUA_CODOCO"	,"DUA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT2_DESCRI"	,"DT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT2_RESOCO"	,"DT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_DOC "	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_STATUS"	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT6_DATENT"	,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DUA_FILOCO"	,"DUA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DUA_USERGI"	,"DUA",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_TIPCOL"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_DESSER"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_NUMSOL"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_NOME"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_DATSOL"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_DATPRV"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_HORCOI"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_DATPRV"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_HORCOF"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_END"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_CEP"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_BAIRRO"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_MUN"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DT5_EST"	,"DT5",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DA4_NOME"	,"DA4",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DA4_TIPMOT"	,"DA4",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DA3_PLACA"	,"DA3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DTQ_ROTA"	,"DTQ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
// DT6_DESDOC
// DTQ_ROTA (COLOCAR DESCRI«√O)
// DT2_RESOCO (DescriÁ„o)
// A1_CGC DT6_NOMREM DUY_DESCRI
// A1_CGC DT6_NOMDES DUY_DESCRI
// A1_CGC DT6_NOMDEV DUY_DESCRI DUY_FILDES DUY_EST ,A1_XCLASS  

// DT5_HORCOI (Modificar o campo para Real)
// DT5_HORCOF (Modificar o campo para Real)
// DUE_CGC
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


oSection1:BeginQuery()
BeginSql Alias 'QRYREQ18'  
SELECT
		 DUA_FILIAL
		,DT6_PRZENT
		,DTC_NUMNFC
		,DTC_VALOR
		,DTC_QTDVOL
		,DTC_PESO
		,DT6_PESO
		,DT6_DOC
		,DT6_DATEMI
		,DT6_DOCTMS
		,DT6_CHVCTE
		,DT6_VALTOT
		,DT6_PRZORI
		,DUA_DATOCO
		,DUA_HOROCO
		,DUA_CODOCO
		,DT2_DESCRI
		,DT2_RESOCO
		,DT6_DOC 
		,DT6_STATUS
		,DT6_DATENT
		,DUA_FILOCO
		,DUA_USERGI
		,DT5_TIPCOL
		,DT5_DESSER
		,DT5_NUMSOL
		,DT5_NOME
		,DT5_DATSOL
		,DT5_DATPRV
		,DT5_HORCOI
		,DT5_DATPRV
		,DT5_HORCOF
		,DT5_END
		,DT5_CEP
		,DT5_BAIRRO
		,DT5_MUN
		,DT5_EST
		,DA4_NOME
		,DA4_TIPMOT
		,DA3_PLACA
		,DTQ_ROTA
		FROM %table:DUA% DUA
		JOIN %table:DT2% DT2
			ON DT2_FILIAL = %xFilial:DT2%
			AND DT2_CODOCO = DUA_CODOCO
			AND DT2_SERTMS = DUA_SERTMS
			AND DT2.%NotDel%
		JOIN %table:DT6% DT6
			ON  DT6_FILIAL = %xFilial:DT6%
			AND DT6_FILDOC = DUA_FILDOC
			AND DT6_DOC    = DUA_DOC
			AND DT6_SERIE  = DUA_SERIE
			AND DT6.%NotDel%
		LEFT JOIN %table:DTC% DTC 
		    ON	DTC.%NotDel%
			AND DTC.DTC_FILIAL = %xFilial:DTC%
			AND (DTC.DTC_FILDOC = DT6.DT6_FILDOC OR DTC.DTC_FILDOC = ORI.DT6_FILDCO)
			AND (DTC.DTC_DOC    = DT6.DT6_DOC    OR DTC.DTC_DOC    = ORI.DT6_DOCDCO)
			AND (DTC.DTC_SERIE  = DT6.DT6_SERIE  OR DTC.DTC_SERIE  = ORI.DT6_SERDCO)
		LEFT JOIN %table:DT5% DT5 ON
			DT5_FILIAL = %xFilial:DT5%
			AND DT5_FILDOC = DUA_FILDOC
			AND DT5_DOC    = DUA_DOC
			AND DT5_SERIE  = DUA_SERIE
			AND DT5.%NotDel%
		LEFT JOIN %table:DUD% DUD 
	      ON DUD_FILIAL  = %xFilial:DUD%
	      AND DUD_FILDOC = DT5_FILIAL 
	      AND DUD_DOC    = DT5_NUMSOL 
	      AND DUD_SERIE  = 'COL'
	      AND DUD.%NotDel%
		LEFT JOIN %table:DTQ% VIAGEM ON ( (VIAGEM.DTQ_FILIAL = %xFilial:DTQ% AND VIAGEM.%NotDel%) AND DUD_FILORI  = VIAGEM.DTQ_FILORI AND DUD_VIAGEM = VIAGEM.DTQ_VIAGEM)
		LEFT JOIN %table:DTR% COMVGA ON ( (COMVGA.DTR_FILIAL = %xFilial:DTR% AND COMVGA.%NotDel%) AND VIAGEM.DTQ_FILORI = COMVGA.DTR_FILORI AND VIAGEM.DTQ_VIAGEM = COMVGA.DTR_VIAGEM)
		LEFT JOIN %table:DA3% VEICUL ON ( (VEICUL.DA3_FILIAL = %xFilial:DA3% AND VEICUL.%NotDel%) AND COMVGA.DTR_CODVEI = VEICUL.DA3_COD )
		LEFT JOIN %table:DUP% MOTVGA ON ( (MOTVGA.DUP_FILIAL = %xFilial:DUP% AND MOTVGA.%NotDel%) AND VIAGEM.DTQ_FILORI = MOTVGA.DUP_FILORI AND VIAGEM.DTQ_VIAGEM = MOTVGA.DUP_VIAGEM)
		LEFT JOIN %table:DA4% MOTORI ON ( (MOTORI.DA4_FILIAL = %xFilial:DA4% AND MOTORI.%NotDel%) AND MOTVGA.DUP_CODMOT = MOTORI.DA4_COD )

		WHERE DUA_FILIAL = %xFilial:DUA%
			AND DUA_DATOCO BETWEEN %Exp:DTOS(mv_par01)% AND %Exp:DTOS(mv_par02)%
			AND DUA.%NotDel%
	ORDER BY DUA_FILIAL, DUA_DATOCO, DUA_HOROCO
	
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

U_DLM_PSx1( { cPerg, "01","Dt OcorrÍncia De ?","Dt OcorrÍncia De ?","Dt OcorrÍncia De ?","mv_ch1","D",08	,0,0,"G","",""      ,""	,"","mv_par01" })
U_DLM_PSx1( { cPerg, "02","Dt OcorrÍncia AtÈ?","Dt OcorrÍncia AtÈ?","Dt OcorrÍncia AtÈ?","mv_ch2","D",08	,0,0,"G","",""      ,""	,"","mv_par02" })

//PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,;
//                            cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,;
//                           cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

RestArea(aArea)

Return Nil
