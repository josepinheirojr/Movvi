#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MOVR010
Exportacao da Tabela de Frete
@type function
@version 12.1.33
@author Rodolfo Kneubuhl Rosseto
@since 22/09/2022
@return variant, Nil
/*/
User Function MOVR010()

//AjustaSX1( "MOVR010" )

RptStatus( {|lEnd| MOV10Imp()})

Return

/*/{Protheus.doc} MOV10Imp
Funcao de Impressao
@type function
@version 12.1.33
@author Rodolfo Kneubuhl Rosseto
@since 22/09/2022
@return variant, Nil
/*/
Static Function MOV10Imp()

Local aCabec 	:= {}
Local cQuery 	:= ""
Local cQryAJU	:= ""
Local cAlias 	:= ""
Local cAliAJU 	:= ""
Local aDados 	:= {}
Local cSeqTab 	:= ""
Local lCont 	:= .T.
Local nPos 		:= 0

If Pergunte("MOVR010",.T.)
	lCont := .T.
Else
	lCont := .F.
EndIf

If lCont
	cAliAJU := GetNextAlias()
	cQryAJU := " SELECT MAX(DVC_SEQTAB) DVC_SEQTAB "
	cQryAJU += " FROM " + RetSqlName("DVC") + " DVC "
	cQryAJU += " WHERE DVC.DVC_FILIAL = '"+xFilial("DVC")+"'"
	cQryAJU += " AND DVC.DVC_TABFRE BETWEEN '" +mv_par01+ "' AND '" +mv_par03+ "' "
	cQryAJU += " AND DVC.DVC_TIPTAB BETWEEN '" +mv_par02+ "' AND '" +mv_par04+ "' "
	cQryAJU += " AND DVC.DVC_CDRORI BETWEEN '" +mv_par05+ "' AND '" +mv_par06+ "' "
	cQryAJU += " AND DVC.DVC_CDRDES BETWEEN '" +mv_par07+ "' AND '" +mv_par08+ "' "
	cQryAJU += " AND DVC.D_E_L_E_T_ = ' '"
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQryAJU),cAliAJU,.T.,.T.)
		
	If (cAliAJU)->(Eof()) .Or. Empty((cAliAJU)->DVC_SEQTAB)
		cSeqTab := StrZero(1, Len(DVC->DVC_SEQTAB))	
	Else
		cSeqTab := (cAliAJU)->DVC_SEQTAB
	EndIf
	(cAliAJU)->(DbCloseArea())

	cAlias 	:= GetNextAlias()
	cQuery := " SELECT DVD_CODPAS CODPAS, DVD_ITEM ITEM, DVD_VALATE VALATE, DVD_PERAJU VALOR, MIN(DVD_INTERV) INTERV, 'AJUSTE' ORIGEM,  DVC.DVC_TABFRE AS TABFRE, DVC.DVC_TIPTAB AS TIPTAB, DVD.DVD_CDRORI AS CDRORI, DVD.DVD_CDRDES AS CDRDES "
	cQuery += " FROM " + RetSqlName("DVC") + " DVC "
	cQuery += " JOIN " + RetSqlName("DVD") + " DVD "
	cQuery += " ON DVD.DVD_FILIAL = '" + xFilial("DVD") + "' " 
	cQuery += " AND DVD.DVD_TABFRE = DVC.DVC_TABFRE "
	cQuery += " AND DVD.DVD_TIPTAB = DVC.DVC_TIPTAB "
	cQuery += " AND DVD.DVD_SEQTAB = DVC.DVC_SEQTAB "
	cQuery += " AND DVD.DVD_CDRORI BETWEEN '" +mv_par05+ "' AND '" +mv_par06+ "' "
	cQuery += " AND DVD.DVD_CDRDES BETWEEN '" +mv_par07+ "' AND '" +mv_par08+ "' "
	cQuery += " AND DVD.DVD_PERAJU <> 0 "
	cQuery += " AND DVD.DVD_SEQTAB = '" + cSeqTab + "' "
	cQuery += " AND DVD.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DVC.DVC_FILIAL = '" + xFilial("DVC") + "' "
	cQuery += " AND DVC.DVC_TABFRE BETWEEN '" +mv_par01+ "' AND '" +mv_par03+ "' "
	cQuery += " AND DVC.DVC_TABFRE BETWEEN '" +mv_par02+ "' AND '" +mv_par04+ "' "
	cQuery += " AND DVC.DVC_SEQTAB = '" + cSeqTab + "' "
	cQuery += " AND DVC.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY DVD_CODPAS, DVD_ITEM, DVD_VALATE, DVD_PERAJU, DVD_INTERV, DVC_TABFRE, DVC_TIPTAB, DVD_CDRORI, DVD_CDRDES "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias)
	While (cAlias)->(!Eof())	
		Aadd(aDados,{(cAlias)->TABFRE,;
		(cAlias)->TIPTAB,;
		(cAlias)->CDRORI,;
		(cAlias)->CDRDES,;
		(cAlias)->ORIGEM,;
		(cAlias)->CODPAS,;
		(cAlias)->ITEM,;
		Transform((cAlias)->VALATE, "@E 999,999,999.9999"),;
		Transform((cAlias)->VALOR, "@E 99,999,999,999.99"),;
		Transform((cAlias)->INTERV, "@E 999,999,999.9999") })
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	cAlias 	:= GetNextAlias()
	cQuery := " SELECT DT1_CODPAS CODPAS, DT1_ITEM ITEM, DT1_VALATE VALATE, DT1_VALOR VALOR, MIN(DT1_INTERV) INTERV, 'TABELA' ORIGEM, DT0.DT0_TABFRE AS TABFRE, DT0.DT0_TIPTAB AS TIPTAB, DT1.DT1_CDRORI AS CDRORI, DT1.DT1_CDRDES AS CDRDES "
	cQuery += " FROM " + RetSqlName("DT0") + " DT0 "
	cQuery += " JOIN " + RetSqlName("DT1") + " DT1 "
	cQuery += " ON DT1.DT1_FILIAL = '" + xFilial("DT1") + "' " 
	cQuery += " AND DT1.DT1_TABFRE = DT0.DT0_TABFRE "
	cQuery += " AND DT1.DT1_TIPTAB = DT0.DT0_TIPTAB "
	cQuery += " AND DT1.DT1_CDRORI BETWEEN '" +mv_par05+ "' AND '" +mv_par06+ "' "
	cQuery += " AND DT1.DT1_CDRDES BETWEEN '" +mv_par07+ "' AND '" +mv_par08+ "' "
	cQuery += " AND DT1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DT0.DT0_FILIAL = '" + xFilial("DT0") + "' "
	cQuery += " AND DT0.DT0_TABFRE BETWEEN '" +mv_par01+ "' AND '" +mv_par03+ "' "
	cQuery += " AND DT0.DT0_TIPTAB BETWEEN '" +mv_par02+ "' AND '" +mv_par04+ "' "
	cQuery += " AND DT0.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY DT1_CODPAS, DT1_ITEM, DT1_VALATE, DT1_VALOR, DT1_INTERV, DT0_TABFRE, DT0_TIPTAB, DT1_CDRORI, DT1_CDRDES "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias)
	While (cAlias)->(!Eof())	
		nPos := Ascan( aDados, { |x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7] == (cAlias)->TABFRE+(cAlias)->TIPTAB+(cAlias)->CDRORI+(cAlias)->CDRDES+"AJUSTE"+(cAlias)->CODPAS+(cAlias)->ITEM } )
		If nPos == 0 //--So adiciona se nao tem ajuste
			Aadd(aDados,{(cAlias)->TABFRE,;
			(cAlias)->TIPTAB,;
			(cAlias)->CDRORI,;
			(cAlias)->CDRDES,;
			(cAlias)->ORIGEM,;
			(cAlias)->CODPAS,;
			(cAlias)->ITEM,;
			Transform((cAlias)->VALATE, "@E 999,999,999.9999"),;
			Transform((cAlias)->VALOR, "@E 99,999,999,999.99"),;
			Transform((cAlias)->INTERV, "@E 999,999,999.9999") })
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())	

	AADD(aCabec, {"Tabela","C",010,0})
	AADD(aCabec, {"Tipo","C",010,0})
	AADD(aCabec, {"Cdrori","C",010,0})
	AADD(aCabec, {"Cdrdes","C",010,0})
	AADD(aCabec, {"Origem","C",010,0})
	AADD(aCabec, {"Comp","C",010,0})
	AADD(aCabec, {"Item","C",010,0})
	AADD(aCabec, {"Valate","C",014,0})
	AADD(aCabec, {"Valor","C",014,0})
	AADD(aCabec, {"Fracao","C",014,0})

	If Len(aDados) > 0
		ArraytoExcel( aDados,aCabec)
	EndIf
EndIf

Return

/*/{Protheus.doc} ArraytoExcel
Gera os dados em Excel
@type function
@version 12.1.33
@author Rodolfo Kneubuhl Rosseto
@since 22/09/2022
@return variant, Nil
/*/
Static Function ArraytoExcel( aDados,aStru2)

Local oFWMsExcel	:= Nil
Local cArqNew 		:= GetTempPath() + "exptab.xmnl"
Local nCont 		:= 0

oFWMsExcel := FWMsExcelEx():New()

oFWMsExcel:AddworkSheet( "Plan1" )
oFWMsExcel:AddTable( "Plan1", "Tabela" )

//--Colunas
For nCont := 1 To Len(aStru2)
	oFWMsExcel:AddColumn( "Plan1", "Tabela", aStru2[nCont][01], 1, 1, .F.)
Next nCont

//--Linhas
For nCont := 1 To Len(aDados)
	oFWMsExcel:AddRow( "Plan1", "Tabela", aDados[nCont] )
Next nCont

oFWMsExcel:Activate()
oFWMsExcel:GetXMLFile(cArqNew)
//Abrindo o excel e abrindo o arquivo
MsgAlert("Arquivo Gerado em : "+cArqNew)
oFWMsExcel := MsExcel():New()               //Abre uma nova conexão com Excel
oFWMsExcel:WorkBooks:Open(cArqNew)         //Abre uma planilha
oFWMsExcel:SetVisible(.T.)                  //Visualiza a planilha
oFWMsExcel:Destroy()

Return
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

U_DLM_PSx1( { cPerg, "01","Tabela De ?" 		,"Tabela De ?" 		,"Tabela De ?" 		,"mv_ch1","C",04	,0,0,"G","","DTL"   ,""	,"","mv_par01" })
U_DLM_PSx1( { cPerg, "02","Tipo De ?" 			,"Tipo De ?" 		,"Tipo De ?" 		,"mv_ch2","C",02	,0,0,"G","",""   	,""	,"","mv_par02" })
U_DLM_PSx1( { cPerg, "03","Tabela Ate ?" 		,"Tabela Ate ?"		,"Tabela Ate ?"		,"mv_ch3","C",04	,0,0,"G","","DTL"   ,""	,"","mv_par03" })
U_DLM_PSx1( { cPerg, "04","Tipo Ate ?" 			,"Tipo Ate ?" 		,"Tipo Ate ?" 		,"mv_ch4","C",02	,0,0,"G","",""   	,""	,"","mv_par04" })
U_DLM_PSx1( { cPerg, "05","Origem De ?" 		,"Origem De ?" 		,"Origem De ?" 		,"mv_ch5","C",06	,0,0,"G","","DUY"   ,""	,"","mv_par05" })
U_DLM_PSx1( { cPerg, "06","Origem Ate ?" 		,"Origem Ate ?" 	,"Origem Ate ?"		,"mv_ch6","C",06	,0,0,"G","","DUY"   ,""	,"","mv_par06" })
U_DLM_PSx1( { cPerg, "07","Destino De ?" 		,"Destino De ?" 	,"Destino De ?"		,"mv_ch7","C",06	,0,0,"G","","DUY"   ,""	,"","mv_par07" })
U_DLM_PSx1( { cPerg, "08","Destino Ate ?" 		,"Destino Ate ?"	,"Destino Ate ?"	,"mv_ch8","C",06	,0,0,"G","","DUY"   ,""	,"","mv_par08" })

//PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,;
//                            cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,;
//                           cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

RestArea(aArea)

Return Nil
