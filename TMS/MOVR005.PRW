#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MOVR005
Impressao da Tabela de Frete
@type function
@version 12.1.33
@author Rodolfo Kneubuhl Rosseto
@since 20/09/2022
@return variant, Nil
/*/
User Function MOVR005()

Local oPrint
Local lEnd     := .T.
Local cDesNeg  := "TABELA DE FRETES RODOVIARIO"
Local lRet     := .T.
Local cPerg    := "MOVR005"

Private nLin   := 200
Private Inclui := .F.
Private cFileLogo := "lgrl"+SM0->M0_CODIGO+".bmp"

AjustaSX1( cPerg )

oPrint := PcoPrtIni(cDesNeg,.F.,1,.T.,@lRet,cPerg,,,)

If lRet
	RptStatus( {|lEnd| MOVR5Imp(@lEnd,oPrint)})
	PcoPrtEnd(oPrint)
EndIf

Return lRet

/*/{Protheus.doc} MOVR5Imp
Funcao de Impressao
@type function
@version 12.1.33
@author Rodolfo Kneubuhl Rosseto
@since 20/09/2022
@return variant, Nil
/*/
Static Function MOVR5Imp(lEnd,oPrint)

Local aItensPro := {}
Local cAliasDWI := GetNextAlias()
Local n1Cnt     := 0 
Local n2Cnt     := 0
Local aSqlOri   := {}
Local aSQLDes   := {}
Local nQuebra   := 800
Local cSqlOri	:= ""
Local cSqlDes	:= ""
Local nX		:= 0
Local cCodCli 	:= ""
Local cLojCli 	:= ""
Local cContrat 	:= ""
Local lCont 	:= .T.
Local aReg 		:= {}

Private cTabFre := ""
Private cTipTab := ""
Private aValorEst := {}
Private aObsDVE := {}

If lCont
	cQuery := "   SELECT DT0_CDRORI, DT0_CDRDES, DDA_TABFRE, DDA_TIPTAB, AAM_CODCLI, AAM_LOJA, AAM_CONTRT "
	cQuery += "   FROM " + RetSqlName("AAM") + " AAM "
	cQuery += "   JOIN " + RetSqlName("DDA") + " DDA "
	cQuery += "     ON DDA.DDA_FILIAL = '" + xFilial("DDA") + "' "
	cQuery += "     AND DDA.DDA_NCONTR = AAM.AAM_CONTRT "
	cQuery += "     AND DDA.DDA_SERVIC BETWEEN '" +mv_par07+ "' AND '" +mv_par08+ "' "
	cQuery += "     AND DDA.DDA_CODNEG BETWEEN '" +mv_par05+ "' AND '" +mv_par06+ "' "
	cQuery += "     AND DDA.DDA_TABFRE BETWEEN '" +mv_par09+ "' AND '" +mv_par11+ "' "
	cQuery += "     AND DDA.DDA_TIPTAB BETWEEN '" +mv_par10+ "' AND '" +mv_par12+ "' "
	cQuery += "     AND DDA.D_E_L_E_T_ = ' ' "
	cQuery += "   JOIN " + RetSqlName("DT0") + " DT0 "
	cQuery += "     ON DT0.DT0_FILIAL = '" + xFilial("DT0") + "' "
	cQuery += "     AND DT0.DT0_TABFRE = DDA.DDA_TABFRE "
	cQuery += "     AND DT0.D_E_L_E_T_ = ' ' "
	cQuery += "    WHERE AAM.AAM_FILIAL = '" + xFilial("AAM") + "' "
	cQuery += "     AND AAM.AAM_CODCLI BETWEEN '" +mv_par01+ "' AND '" +mv_par03+ "' "
	cQuery += "     AND AAM.AAM_LOJA BETWEEN '" +mv_par02+ "' AND '" +mv_par04+ "' "
	cQuery += "     AND AAM.AAM_STATUS = '1' " //--Ativo
	cQuery += "     AND AAM.D_E_L_E_T_ = ' ' "
	cQuery += "     GROUP BY DT0_CDRORI, DT0_CDRDES, DDA_TABFRE, DDA_TIPTAB, AAM_CODCLI, AAM_LOJA, AAM_CONTRT "
	cQuery += "     ORDER BY AAM_CODCLI, AAM_LOJA "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDWI)

	While (cAliasDWI)->(!Eof())
		//-- Verifica as regioes superiores
		aRegioes 	:= {}
		aItensPro	:= {}
		Aadd(aReg, { (cAliasDWI)->DT0_CDRORI, (cAliasDWI)->DT0_CDRDES })
		
		If !Empty(cCodCli+cLojCli)
			If cCodCli+cLojCli <> (cAliasDWI)->AAM_CODCLI+(cAliasDWI)->AAM_LOJA				
				cSqlOri  	:= ""
				cSqlDes  	:= ""
				aSQLOri  	:= {}
				aSQLDes  	:= {}
				aReg 		:= {}
			EndIf
		EndIf
		
		cTabFre  	:= (cAliasDWI)->DDA_TABFRE
		cTipTab  	:= (cAliasDWI)->DDA_TIPTAB
		cCodCli  	:= (cAliasDWI)->AAM_CODCLI
		cLojCli  	:= (cAliasDWI)->AAM_LOJA
		cContrat 	:= (cAliasDWI)->AAM_CONTRT

		TMSAddReg(@aRegioes,(cAliasDWI)->DT0_CDRORI,(cAliasDWI)->DT0_CDRDES,,StrZero(1,Len(DT3->DT3_PSQTXA)))
		For nX := 1 To Len(aRegioes)
			If !( aRegioes[nX,1] $ cSqlOri ) .And. Ascan(aSQLOri,{|x| (aRegioes[nX,1] $ x)}) == 0	 
				cSqlOri += "'"+aRegioes[nX,1]+"',"
				If Mod(nX,nQuebra) == 0 
					cSqlOri := Substr(cSqlOri,1,Len(cSqlOri) - 1)
					Aadd( aSQLOri, cSqlOri )
					cSqlOri := ''
				EndIf
			EndIf
			If !( aRegioes[nX,2] $ cSqlDes )  .And. Ascan(aSQLDes,{|x| (aRegioes[nX,2] $ x)}) == 0	 
				cSqlDes += "'"+aRegioes[nX,2]+"',"
				If Mod(nX,nQuebra) == 0
					cSqlDes := Substr(cSqlDes,1,Len(cSqlDes) - 1)
					Aadd( aSQLDes, cSqlDes )
					cSqlDes := ''
				EndIf
			EndIf
		Next nX		
		
		(cAliasDWI)->(DbSkip())

		If cCodCli+cLojCli <> (cAliasDWI)->AAM_CODCLI+(cAliasDWI)->AAM_LOJA
			If Mod(nX,nQuebra) <> 0 .And. cSqlOri <> ''
				cSqlOri := Substr(cSqlOri,1,Len(cSqlOri) - 1)
				Aadd( aSQLOri, cSqlOri )
			EndIf

			If Mod(nX,nQuebra) <> 0 .And. cSqlDes <> ''
				cSqlDes := Substr(cSqlDes,1,Len(cSqlDes) - 1)
				Aadd( aSQLDes, cSqlDes )
			EndIf

			For n1Cnt := 1 To Len(aSqlOri)
				For n2Cnt := 1 To Len(aSqlDes)
					MontaArr(aItensPro,aSqlOri[n1Cnt],aSqlDes[n2Cnt],cTabFre,cTipTab,aReg)
				Next n2Cnt
			Next n1Cnt

			MOVR5Cab(oPrint,aItensPro,cCodCli,cLojCli,cContrat,cTabFre,cTipTab)
			MOVR5It(oPrint,aItensPro)
			MOVR5Fim(oPrint,cTabFre,cTipTab,cContrat)

		EndIf

	EndDo
	(cAliasDWI)->(dbCloseArea())
EndIf

Return

/*/{Protheus.doc} MontaArr
Montagem do Array
@type function
@version 12.1.33
@author Rodolfo Kneubuhl Rosseto
@since 20/09/2022
@return variant, Nil
/*/
Static Function MontaArr(aItensPro,cSqlOri,cSqlDes,cTabFre,cTipTab,aReg)

Local nX		 := 0
Local cQuery    := ""
Local cCompImp  := ""
Local aCompImp  := {}
Local aCompFai  := {}
Local cCompFai  := ""
Local cCompFaiPri := ""
Local cTipFre   := ""
Local cFilOri   := ""
Local cNumPro   := ""
Local cNumPri   := ""
Local cTabFrePri:= ""
Local cTipTabPri:= ""
Local cAliasDVD := GetNextAlias()
Local cAliasDWJ := GetNextAlias()
Local cAliasQry := GetNextAlias()
Local aStruDT1  := DT1->(dbStruct())
Local aStruDWJ  := DWJ->(dbStruct())
Local cCdrOri   := ""
Local cCdrDes   := ""
Local cCodPro   := ""
Local cEst      := ""
Local cRegiao   := ""
Local nPrcTab   := 0
Local nPrcAju   := 0
Local aEstado   := {}
Local aCab      := {}
Local cRegPri   := ""
Local cOrdem    := ""
Local cCompPri  := ""
Local lMin      := .F.
Local nValMin   := 0
Local lPraca    := .F.
Local cCompEst  := ""
Local cCompEstPri:= ""
Local cEstOri    := ""
Local cCompMin   := ""
Local cCompPrMin := ""
Local cRegOri    := ""
Local cRegDes    := ""
Local lReajuste  := .T. 
Local cAliasDVE	:= ""
Local cQryDVE 	:= ""
Local cAliMIN	:= ""
Local cQryMIN 	:= ""
Local nPosOBS 	:= 0
Local nCont 	:= 0

cAliasDVE := GetNextAlias()
cQryDVE := "   SELECT DVE_XIMPCO, DVE_XIMPMI, DVE_XIMPFA, DVE_CODPAS, DVE_XTEXTO "
cQryDVE += "   FROM " + RetSqlName("DTL") + " DTL "
cQryDVE += "   JOIN " + RetSqlName("DVE") + " DVE "
cQryDVE += "     ON DVE.DVE_FILIAL = '" + xFilial("DVE") + "' "
cQryDVE += "     AND DVE.DVE_TABFRE = DTL.DTL_TABFRE "
cQryDVE += "     AND DVE.DVE_TIPTAB = DTL.DTL_TIPTAB "
cQryDVE += "     AND DVE.D_E_L_E_T_ = ' ' "
cQryDVE += "    WHERE DTL.DTL_FILIAL = '" + xFilial("DTL") + "' "
cQryDVE += "     AND DTL.DTL_TABFRE = '" + cTabFre + "' "
cQryDVE += "     AND DTL.DTL_TIPTAB = '" + cTipTab + "' "
cQryDVE += "     AND DTL.D_E_L_E_T_ = ' ' "
cQryDVE := ChangeQuery(cQryDVE)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryDVE),cAliasDVE)

While (cAliasDVE)->(!Eof())
	
	If !Empty((cAliasDVE)->DVE_XTEXTO)
		nPosOBS := Ascan(aObsDVE, { |x| x[1] == (cAliasDVE)->DVE_CODPAS } )
		If nPosOBS == 0		
			Aadd(aObsDVE, { (cAliasDVE)->DVE_CODPAS, (cAliasDVE)->DVE_XTEXTO })
		EndIf
	EndIf
	
	If (cAliasDVE)->DVE_XIMPCO == "1" //-- Sim - Imprime Componente
		If !Empty(cCompImp)
			cCompImp += "',"
		EndIf
		cCompImp += "'"+(cAliasDVE)->DVE_CODPAS
		If (cAliasDVE)->DVE_XIMPMI == "1" //-- Sim - Imprime Minimo
			lMin := .T.
			If !Empty(cCompMin)
				cCompMin += "',"
			EndIf				             
			cCompMin += "'"+(cAliasDVE)->DVE_CODPAS
		EndIf
	EndIf	
	If (cAliasDVE)->DVE_XIMPFA == "1" //-- Sim - Imprime Faixa
		If !Empty(cCompFai)
			cCompFai += ","
		EndIf
		cCompFai += (cAliasDVE)->DVE_CODPAS
	EndIf
	(cAliasDVE)->(DbSkip())
EndDo
(cAliasDVE)->(dbCloseArea())

If !Empty(cCompFai)
	cCompFaiPri := cCompFai
EndIf

If Empty(cCompImp)
	MsgAlert("Nao existem componentes configurados") // "N„o existem componentes configurados para impress„o no tipo de negociaÁ„o "
	Return aItensPro
Else	
	If !Empty(cCompImp)
		cCompImp += "'"
		cCompPri := cCompImp
	EndIf
	If !Empty(cCompMin)
		cCompMin += "'"
		cCompPrMin := cCompMin
	EndIf
EndIf

If !Empty(cSqlOri) .And. !Empty(cSqlDes)	
	
	cQuery := " SELECT CODPAS, MIN(ITEM) ITEM, VALATE, VALOR, MIN(INTERV) INTERV, MAX(ORIGEM) ORIGEM "
	cQuery += " FROM ( "
	cQuery += " SELECT DT1_CODPAS CODPAS, DT1_ITEM ITEM, DT1_VALATE VALATE, DT1_VALOR VALOR, MIN(DT1_INTERV) INTERV, 'TAB' ORIGEM "
	cQuery += " FROM " + RetSqlName("DT0") + " DT0 "
	
	cQuery += " JOIN " + RetSqlName("DT1") + " DT1 "
	cQuery += " ON DT1.DT1_FILIAL = '" + xFilial("DT1") + "' " 
	cQuery += " AND DT1.DT1_TABFRE = DT0.DT0_TABFRE "
	cQuery += " AND DT1.DT1_TIPTAB = DT0.DT0_TIPTAB "
	cQuery += " AND DT1.DT1_CODPAS IN ( " +cCompImp+ " ) "
	cQuery += " AND DT1.DT1_CDRORI IN ( " +cSqlOri + " ) "
	cQuery += " AND DT1.DT1_CDRDES IN ( " +cSqlDes + " ) "
	cQuery += " AND DT1.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE DT0.DT0_FILIAL = '" + xFilial("DT0") + "' "
	cQuery += " AND DT0.DT0_TABFRE = '" + cTabFre + "' "
	cQuery += " AND DT0.DT0_TIPTAB = '" + cTipTab + "' "
	cQuery += " AND DT0.DT0_CDRORI IN ( " +cSqlOri + " ) "
	cQuery += " AND DT0.DT0_CDRDES IN ( " +cSqlDes + " ) "
	cQuery += " AND DT0.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY DT1_CODPAS, DT1_ITEM, DT1_VALATE, DT1_VALOR, DT1_INTERV "

	cQuery += " UNION ALL "
	
	cQuery += " SELECT DVD_CODPAS CODPAS, DVD_ITEM ITEM, DVD_VALATE VALATE, DVD_PERAJU VALOR, MIN(DVD_INTERV) INTERV, 'AJU' ORIGEM "
	
	cQuery += " FROM " + RetSqlName("DVC") + " DVC "
	
	cQuery += " JOIN " + RetSqlName("DVD") + " DVD "
	cQuery += " ON DVD.DVD_FILIAL = '" + xFilial("DVD") + "' " 
	cQuery += " AND DVD.DVD_TABFRE = DVC.DVC_TABFRE "
	cQuery += " AND DVD.DVD_TIPTAB = DVC.DVC_TIPTAB "
	cQuery += " AND DVD.DVD_CODPAS IN ( " +cCompImp+ " ) "
	cQuery += " AND DVD.DVD_CDRORI IN ( " +cSqlOri + " ) "
	cQuery += " AND DVD.DVD_CDRDES IN ( " +cSqlDes + " ) "
	cQuery += " AND DVD.DVD_PERAJU <> 0 "
	cQuery += " AND DVD.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DVC.DVC_FILIAL = '" + xFilial("DVC") + "' "
	cQuery += " AND DVC.DVC_TABFRE = '" + cTabFre + "' "
	cQuery += " AND DVC.DVC_TABFRE = '" + cTipTab + "' "
	cQuery += " AND DVC.DVC_CDRORI IN ( " +cSqlOri + " ) "
	cQuery += " AND DVC.DVC_CDRDES IN ( " +cSqlDes + " ) "
	cQuery += " AND DVC.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY DVD_CODPAS, DVD_ITEM, DVD_VALATE, DVD_PERAJU, DVD_INTERV "
	cQuery += " ) QRY "
	cQuery += " GROUP BY CODPAS, VALATE, VALOR "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDWJ)
	While (cAliasDWJ)->(!Eof())		
		If (AllTrim((cAliasDWJ)->CODPAS) $ cCompImp)        
			Aadd(aCab,{Alltrim((cAliasDWJ)->CODPAS),(cAliasDWJ)->VALATE,(cAliasDWJ)->VALOR,(cAliasDWJ)->INTERV,cTabFre,cTipTab,""})
		EndIf
		(cAliasDWJ)->(DbSkip())
	EndDo
	(cAliasDWJ)->(DbCloseArea())

	If lMin
		cAliMIN	:= GetNextAlias()
		cQryMIN := " SELECT 'MN'||DT1_CODPAS CODPAS , MIN(DT1_ITEM) ITEM , MAX(DT1_VALATE) VALATE , MIN(DT1_VALOR) VALOR, MIN(DT1_INTERV) INTERV ,'1' ORIGEM "
 		cQryMIN += " FROM " + RetSqlName("DT1") + " DT1 "
		cQryMIN += " JOIN " + RetSqlName("DT0") + " DT0 "
 		cQryMIN += " ON DT0.DT0_FILIAL = '" + xFilial("DT0") + "' "
		cQryMIN += " AND DT0_TABFRE = DT1.DT1_TABFRE "
		cQryMIN += " AND DT0_TIPTAB = DT1.DT1_TIPTAB "
		cQryMIN += " AND DT0.D_E_L_E_T_ = ' ' "

   		cQryMIN += " JOIN " + RetSqlName("DTK") + " DTK "
		cQryMIN += " ON DTK.DTK_FILIAL = '" + xFilial("DTK") + "' "
		cQryMIN += " AND DTK.DTK_CODPAS = DT1.DT1_CODPAS "
		cQryMIN += " AND DTK.DTK_VALMIN > 0 "
		cQryMIN += " AND DTK.D_E_L_E_T_ = ' ' "
	
 		cQryMIN += " WHERE DT1.DT1_FILIAL = '" + xFilial("DT1") + "' "
		cQryMIN += " AND DT1.DT1_CODPAS IN ( " +cCompImp+ " ) "
		cQryMIN += " AND DT1.DT1_CDRORI IN ( " +cSqlOri + " ) "
		cQryMIN += " AND DT1.DT1_CDRDES IN ( " +cSqlDes + " ) "
		cQryMIN += " AND DT1.D_E_L_E_T_ = ' ' "
		cQryMIN += " GROUP BY DT1_CODPAS, DT1_ITEM "

		cQryMIN := ChangeQuery(cQryMIN)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryMIN),cAliMIN)
		While (cAliMIN)->(!Eof())		
			If (Left(AllTrim((cAliMIN)->CODPAS),2)  == "MN") 
				Aadd(aCab,{"MN",(cAliMIN)->VALATE,(cAliMIN)->VALOR,(cAliMIN)->INTERV,cTabFre,cTipTab,""})
			EndIf
			(cAliMIN)->(DbSkip())
		EndDo
		(cAliMIN)->(DbCloseArea())
	EndIf
	
	For nCont := 1 To Len(aReg)
	
		//-- Verifica se o estado j· foi impresso.
	   If Ascan( aEstado, { |x| x == AllTrim(Posicione("DUY",1,xFilial("DUY")+aReg[nCont][02],"DUY_EST")) } ) <> 0
			Loop
		EndIf
	
		cQuery := " SELECT DUY_EST, DUY_DESCRI, DUY_GRPVEN, "
		cQuery += " DT1_CDRORI, DT1_CDRDES, DT1_CODPRO, DT1_CODPAS, DT1_ITEM, "
		cQuery += " DT1_VALATE, DT1_VALOR, DT1_INTERV, '1' ORIGEM, 0 VALMIN "
		cQuery += " FROM " + RetSqlName("DT1") + " DT1 "
		cQuery += " JOIN " + RetSqlName("DUY") + " DUY "
		cQuery += " ON DUY.DUY_FILIAL = '" + xFilial("DUY") + "' "
		cQuery += " AND DUY.DUY_GRPVEN = DT1.DT1_CDRDES "
		cQuery += " AND DUY.D_E_L_E_T_ = ' ' " 
		cQuery += " WHERE DT1.DT1_FILIAL = '" + xFilial("DT1") + "' "
		cQuery += " AND DT1.DT1_CODPAS IN ( " +cCompImp+ " ) "
		cQuery += " AND DT1.DT1_CDRORI IN ( " +cSqlOri + " ) "
		cQuery += " AND DT1.DT1_CDRDES IN ( " +cSqlDes + " ) "
		cQuery += " AND DT1.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY DUY_EST, DT1_CDRORI, DT1_CDRDES,ORIGEM, DT1_CODPAS, DT1_ITEM "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDVD)
		For nX := 1 To Len(aStruDT1)
			If aStruDT1[nX][2]<>"C" 
				TcSetField(cAliasDVD,aStruDT1[nX][1],aStruDT1[nX][2],aStruDT1[nX][3],aStruDT1[nX][4])
			EndIf
		Next nX                     
		TcSetField(cAliasDVD,"VALMIN","N",TamSX3("DWD_VALMIN")[1],TamSX3("DWD_VALMIN")[2])
		While (cAliasDVD)->(!Eof())
			cCdrOri  := (cAliasDVD)->DT1_CDRORI
			cCdrDes  := (cAliasDVD)->DT1_CDRDES
			cCodPro  := (cAliasDVD)->DT1_CODPRO
			cEst     := (cAliasDVD)->DUY_EST
			cRegiao  := (cAliasDVD)->DUY_DESCRI
			cRegPri  := (cAliasDVD)->DUY_GRPVEN
			aCompImp := {}
			aCompFai := {}
			cCompEstPri := ""
			cCompEst    := ""
			While (cAliasDVD)->(!Eof()) .And. (cAliasDVD)->(DT1_CDRORI+DT1_CDRDES+DT1_CODPRO) == cCdrOri+cCdrdes+cCodPro
				nPrcTab := 0
				If (cAliasDVD)->ORIGEM == "2"
					cTab := cTabFrePri
					cTip := cTipTabPri
				Else
					cTab := cTabFre
					cTip := cTipTab
				EndIf
				DT1->(dbSetOrder(1))
				If DT1->(MsSeek(xFilial("DT1")+cTab+cTip+(cAliasDVD)->(DT1_CDRORI+DT1_CDRDES+DT1_CODPRO+DT1_CODPAS+DT1_ITEM)))
					nPrcTab := DT1->DT1_VALOR
				Else
					DT0->(dbSetOrder(1))
					DT0->(MsSeek(xFilial("DT0")+cTab+cTip+(cAliasDVD)->(DT1_CDRORI+DT1_CDRDES+DT1_CODPRO)))
					DTG->(dbSetOrder(1))
					DTG->(MsSeek(xFilial("DTG")+cTab+cTip+DT0->DT0_TABTAR+(cAliasDVD)->(DT1_CODPAS+DT1_ITEM)))
					nPrcTab := DTG->DTG_VALOR
				EndIf
				
				nPrcAju := (cAliasDVD)->DT1_VALOR //(nPrcTab * (cAliasDVD)->DVD_PERAJU) / 100

				//-- Valores por Estado
				nValMin := 0
				If Posicione("DUY",1,xFilial("DUY")+cRegPri,"DUY_CATGRP") == StrZero(1,Len(DUY->DUY_CATGRP)) //-- Estado
					If Ascan(aValorEst, { |x| x[1]+x[2] == cEst + (cAliasDVD)->DT1_CODPAS } ) == 0
						If lReajuste
							If Left(AllTrim((cAliasDVD)->DT1_CODPAS),2)  == "MN"
								 nValMin := (cAliasDVD)->VALMIN
							Else
								DTK->(dbSetOrder(1))
								If DTK->(DbSeek(xFilial("DTK")+cTab+cTip+(cAliasDVD)->(DT1_CDRORI+DT1_CDRDES+DT1_CODPRO+DT1_CODPAS)))
								   DVO->(dbSetOrder(1))
									If DVO->(DbSeek(xFilial("DVO")+cFilOri+cNumPro+(cAliasDVD)->(DT1_CDRORI+DT1_CDRDES+DT1_CODPRO+""+DT1_CODPAS)))
										nValMin := (DVO->DVO_PERMIN * (DTK->DTK_VALMIN / 100	))
									EndIf
								EndIf								
							EndIf	
						EndIf
						Aadd(aValorEst,{ cEst, (cAliasDVD)->DT1_CODPAS, nPrcAju, nValMin })
					EndIf
				EndIf

				If (!lPraca .Or. Posicione("DUY",1,xFilial("DUY")+cRegPri,"DUY_CATGRP") <> StrZero(1,Len(DUY->DUY_CATGRP)))
					If (cAliasDVD)->ORIGEM == "2"
						If (cAliasDVD)->DT1_CODPAS $ cCompFaiPri .Or. Left(AllTrim((cAliasDVD)->DT1_CODPAS),2)  == "MN"
							If !( (cAliasDVD)->DT1_CODPAS $ cCompEstPri )
								cCompEstPri += "'" + (cAliasDVD)->DT1_CODPAS + "',"
							EndIf
							If Left(AllTrim((cAliasDVD)->DT1_CODPAS),2)  == "MN"  
								Aadd(aCompFai,{ Alltrim((cAliasDVD)->DT1_CODPAS), (cAliasDVD)->DT1_VALATE, (cAliasDVD)->VALMIN, (cAliasDVD)->DT1_INTERV, .F. })
							Else
								Aadd(aCompFai,{ Alltrim((cAliasDVD)->DT1_CODPAS), (cAliasDVD)->DT1_VALATE, nPrcAju, (cAliasDVD)->DT1_INTERV, .F. })
							EndIf
						Else
							If Left(AllTrim((cAliasDVD)->DT1_CODPAS),2)  == "MN"  
								Aadd(aCompImp,{ Alltrim((cAliasDVD)->DT1_CODPAS), 0, (cAliasDVD)->VALMIN, (cAliasDVD)->DT1_INTERV })
							Else
								Aadd(aCompImp,{ Alltrim((cAliasDVD)->DT1_CODPAS), 0, nPrcAju, (cAliasDVD)->DT1_INTERV })
							EndIf
						EndIf
					Else
						If (cAliasDVD)->DT1_CODPAS $ cCompFai .Or. Left(AllTrim((cAliasDVD)->DT1_CODPAS),2)  == "MN"  
							If !( (cAliasDVD)->DT1_CODPAS $ cCompEst )
								cCompEst += "'" + (cAliasDVD)->DT1_CODPAS + "',"
							EndIf
							If Left(AllTrim((cAliasDVD)->DT1_CODPAS),2) == "MN"  
								Aadd(aCompFai,{ Alltrim((cAliasDVD)->DT1_CODPAS), (cAliasDVD)->DT1_VALATE, (cAliasDVD)->VALMIN, (cAliasDVD)->DT1_INTERV, .F. })
							Else
								Aadd(aCompFai,{ Alltrim((cAliasDVD)->DT1_CODPAS), (cAliasDVD)->DT1_VALATE, nPrcAju, (cAliasDVD)->DT1_INTERV, .F. })
							EndIf
						Else
							If Left(AllTrim((cAliasDVD)->DT1_CODPAS),2) == "MN"  
								Aadd(aCompImp,{ Alltrim((cAliasDVD)->DT1_CODPAS), 0, (cAliasDVD)->VALMIN, (cAliasDVD)->DT1_INTERV })
							Else
								Aadd(aCompImp,{ Alltrim((cAliasDVD)->DT1_CODPAS), 0, nPrcAju, (cAliasDVD)->DT1_INTERV })
							EndIf
						EndIf		
					EndIf
				EndIf
				(cAliasDVD)->(dbSkip())
			EndDo
			
			
			//-- Componentes por estado
			cCompEst := SubStr(cCompEst,1,Len(cCompEst)-1)
			If !Empty(cCompEst)
				cCompEstPri := SubStr(cCompEstPri,1,Len(cCompEstPri)-1)
				If Empty(cCompEstPri)
					cCompEstPri := "' '"
				EndIf			
				cEstOri := Posicione("DUY",1,xFilial("DUY")+cCdrOri,"DUY_EST")
				cEstDes := Posicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_EST")
								
				cQuery := " SELECT DUY_EST, DUY_DESCRI, DUY_GRPVEN, "
				cQuery += " 		 DWJ_CDRORI,DWJ_CDRDES,DWJ_CODPRO,DWJ_SERVIC, "
				cQuery += " 		 DWJ_RGOTAB,DWJ_RGDTAB,DWJ_PRDTAB,DWJ_CODPAS,DWJ_ITEM, "
				cQuery += " 		 DWJ_PERAJU,DWJ_VALATE,DWJ_INTERV, '1' ORIGEM, 0 VALMIN "
				cQuery += " FROM "
				cQuery += RetSqlName("DWJ")+" DWJ, "
				cQuery += RetSqlName("DUY")+" DUY "
				cQuery += "  WHERE DWJ_FILIAL = '"+xFilial("DWJ")+"'"
				cQuery += "    AND DWJ_FILORI = '"+cFilOri+"'"
				cQuery += "    AND DWJ_NUMPRO = '"+cNumPro+"'"
				cQuery += "    AND DWJ_CODPAS IN ( " +cCompImp+ " )"
				cQuery += "    AND DWJ_CODPAS NOT IN ( " +cCompEst+ " )"
				cQuery += "    AND DWJ_CDRORI = '" +cEstOri+ "' "
				cQuery += "    AND DWJ_CDRDES = '" +cEstDes+ "' "
				cQuery += "    AND DWJ_PERAJU <> 0 "
				cQuery += "    AND DWJ.D_E_L_E_T_ = ' '"
				cQuery += "    AND DUY_FILIAL = '"+xFilial("DUY")+"'"
				cQuery += "    AND DUY_CATGRP = '1' "
				If cTipFre == "1" //-- CIF
					cQuery += " AND DUY_GRPVEN = DWJ_CDRDES"
					cQuery += " AND DUY.D_E_L_E_T_ = ' '"
				Else
					cQuery += " AND DUY_GRPVEN = DWJ_CDRORI"
					cQuery += " AND DUY.D_E_L_E_T_ = ' '"
				EndIf	
				If !Empty(cNumPri)
					cQuery += " UNION ALL "
					cQuery += " SELECT DUY_EST, DUY_DESCRI, DUY_GRPVEN, "
					cQuery += " 		 DWJ_CDRORI,DWJ_CDRDES,DWJ_CODPRO,DWJ_SERVIC, "
					cQuery += " 		 DWJ_RGOTAB,DWJ_RGDTAB,DWJ_PRDTAB,DWJ_CODPAS,DWJ_ITEM, "
					cQuery += " 		 DWJ_PERAJU,DWJ_VALATE,DWJ_INTERV, '2' ORIGEM, 0 VALMIN"
					cQuery += " FROM "
					cQuery += RetSqlName("DWJ")+" DWJ, "
					cQuery += RetSqlName("DUY")+" DUY "
					cQuery += "  WHERE DWJ_FILIAL = '"+xFilial("DWJ")+"'"
					cQuery += "    AND DWJ_FILORI = '"+cFilOri+"'"
					cQuery += "    AND DWJ_NUMPRO = '"+cNumPri+"'"
					cQuery += "    AND DWJ_CODPAS IN ( " +cCompPri+ " )"
					cQuery += "    AND DWJ_CODPAS NOT IN ( " +cCompEstPri+ " )"
					cQuery += "    AND DWJ_CDRORI = '" +cEstOri+ "' "
					cQuery += "    AND DWJ_CDRDES = '" +cEstDes+ "' "
					cQuery += "    AND DWJ_PERAJU <> 0 "
					cQuery += "    AND DWJ.D_E_L_E_T_ = ' '"
					cQuery += "    AND DUY_FILIAL = '"+xFilial("DUY")+"'"
					cQuery += "    AND DUY_CATGRP = '1' "
					If cTipFre == "1" //-- CIF
						cQuery += " AND DUY_GRPVEN = DWJ_CDRDES"
						cQuery += " AND DUY.D_E_L_E_T_ = ' '"
					Else
						cQuery += " AND DUY_GRPVEN = DWJ_CDRORI"
						cQuery += " AND DUY.D_E_L_E_T_ = ' '"
					EndIf	
				EndIf
				If cTipFre == "1" //-- CIF
					cQuery += " ORDER BY DUY_EST,DWJ_CDRORI,DWJ_CDRDES,ORIGEM,DWJ_CODPAS,DWJ_ITEM"
				Else
					cQuery += " ORDER BY DUY_EST,DWJ_CDRDES,DWJ_CDRORI,ORIGEM,DWJ_CODPAS,DWJ_ITEM"
				EndIf	
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
				For nX := 1 To Len(aStruDWJ)
					If aStruDWJ[nX][2]<>"C"
						TcSetField(cAliasQry,aStruDWJ[nX][1],aStruDWJ[nX][2],aStruDWJ[nX][3],aStruDWJ[nX][4])
					EndIf
				Next nX                      
				While (cAliasQry)->(!Eof())
					nPrcTab := 0
					If (cAliasQry)->ORIGEM == "2"
						cTab := cTabFrePri
						cTip := cTipTabPri
					Else
						cTab := cTabFre
						cTip := cTipTab
					EndIf
					DT1->(dbSetOrder(1))
					If DT1->(MsSeek(xFilial("DT1")+cTab+cTip+(cAliasQry)->(DWJ_RGOTAB+DWJ_RGDTAB+DWJ_PRDTAB+DWJ_CODPAS+DWJ_ITEM)))
						nPrcTab := DT1->DT1_VALOR
					Else
						DT0->(dbSetOrder(1))
						DT0->(MsSeek(xFilial("DT0")+cTab+cTip+(cAliasQry)->(DWJ_RGOTAB+DWJ_RGDTAB+DWJ_PRDTAB)))
						DTG->(dbSetOrder(1))
						DTG->(MsSeek(xFilial("DTG")+cTab+cTip+DT0->DT0_TABTAR+(cAliasQry)->(DWJ_CODPAS+DWJ_ITEM)))
						nPrcTab := DTG->DTG_VALOR
					EndIf
					nPrcAju := (nPrcTab * (cAliasQry)->DWJ_PERAJU) / 100
					If (cAliasQry)->ORIGEM == "2"
						If (cAliasQry)->DWJ_CODPAS $ cCompFaiPri
							If Ascan( aCompFai, { |x| x[1]+Alltrim(Str(x[2])) == (cAliasQry)->DWJ_CODPAS + AllTrim(Str((cAliasQry)->DWJ_VALATE)) } ) == 0
								Aadd(aCompFai,{ Alltrim((cAliasQry)->DWJ_CODPAS), (cAliasQry)->DWJ_VALATE, nPrcAju, (cAliasQry)->DWJ_INTERV, .F. })
							EndIf
						Else
							If Ascan( aCompImp, { |x| x[1] == (cAliasQry)->DWJ_CODPAS } ) == 0
								Aadd(aCompImp,{ Alltrim((cAliasQry)->DWJ_CODPAS), 0, nPrcAju, (cAliasQry)->DWJ_INTERV })
							EndIf
						EndIf
					Else
						If (cAliasQry)->DWJ_CODPAS $ cCompFai
							If Ascan( aCompFai, { |x| x[1]+Alltrim(Str(x[2])) == (cAliasQry)->DWJ_CODPAS + AllTrim(Str((cAliasQry)->DWJ_VALATE)) } ) == 0
								Aadd(aCompFai,{ Alltrim((cAliasQry)->DWJ_CODPAS), (cAliasQry)->DWJ_VALATE, nPrcAju, (cAliasQry)->DWJ_INTERV, .F. })
							EndIf
						Else
							If Ascan( aCompImp, { |x| x[1] == (cAliasQry)->DWJ_CODPAS } ) == 0
								Aadd(aCompImp,{ Alltrim((cAliasQry)->DWJ_CODPAS), 0, nPrcAju, (cAliasQry)->DWJ_INTERV })
							EndIf
						EndIf
					EndIf
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())
			EndIf
			

			If (Len(aCompFai) > 0 .Or. Len(aCompImp) > 0) .And. Posicione("DUY",1,xFilial("DUY")+cRegPri,"DUY_CATGRP") <> "1"
	         DWM->(DbSetOrder(1))
				If DWM->(MsSeek(xFilial("DWM")+cEst+cRegPri))
					cOrdem := DWM->DWM_PRIORI
				Else
					cOrdem := Replicate("9",Len(DWM->DWM_PRIORI))
				EndIf
				If cTipFre == '3' //-- CIF/FOB
					cRegOri := Posicione('DUY',1,xFilial('DUY')+aReg[nCont][01],'DUY_DESCRI')
					cRegDes := Posicione('DUY',1,xFilial('DUY')+aReg[nCont][02],'DUY_DESCRI')
					If Ascan( aItensPro, { |x| x[1]+x[2] == cRegOri+cRegDes } ) == 0 
						Aadd(aItensPro,{ cRegOri, cRegDes, AClone(aCompFai), AClone(aCompImp), AClone(aCab), cOrdem })
					EndIf
				Else
					If Ascan( aItensPro, { |x| x[1]+x[2] == cEst + cRegiao } ) == 0 
						Aadd(aItensPro,{ cEst, cRegiao, AClone(aCompFai), AClone(aCompImp), AClone(aCab), cOrdem })
						//-- Armazena o estado da regiao
						If Ascan( aEstado, { |x| x == cEst } ) == 0
							aAdd( aEstado, cEst )
						EndIf
					EndIf
				EndIf					
			EndIf
		EndDo
		(cAliasDVD)->(dbCloseArea())
	Next nCont
	
	//-- Ordena por estado e regiao
	aItensPro := ASort( aItensPro,,,{|x,y| x[1]+x[6]+x[2] < y[1]+y[6]+y[2] })
EndIf

Return aItensPro

/*/{Protheus.doc} MOVR5Cab
Impressao do Cabecalho
@type function
@version 12.1.33
@author Rodolfo Kneubuhl Rosseto
@since 20/09/2022
@return variant, Nil
/*/
Static Function MOVR5Cab(oPrint,aItensPro,cCodCli,cLojCli,cContrat,cTabFre,cTipTab)

Local cTipFre  := "1"
Local cCodReg  := Iif(cTipFre == "1",DW7->DW7_CDRORI,DW7->DW7_CDRDES)
Local nIniCell := 0
Local nTotBox  := 0
Local cCodPas  := ""
Local cDesPas  := ""
Local lTemFai  := .F.
Local lPerFai  := .F.
Local cDesFai  := ""
Local nX       := 0
Local lAcima   := .F.
Local cNome    := ""
Local cCNPJ    := ""
Local cTabOld  := ""
Local cTipOld  := ""
Local nTotCab  := 0
Local cDesFTit	:= ""
Local cTabFrePri:= ""
Local cTipTabPri:= ""

If !Empty(aItensPro)
	SA1->(dbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1")+cCodCli+cLojCli))
	AAM->(dbSetOrder(1))
	AAM->(MsSeek(xFilial("AAM")+cContrat))
	cNome    := SA1->A1_NOME
	cCNPJ    := SA1->A1_CGC
	
	PcoPrtCab(oPrint,4,cFileLogo)
	nLin  := 200

	PcoPrtCol({20,800,1600,2000},.T.,1)
	PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,cNome,oPrint,4,2,/*RgbColor*/," CLIENTE: ")
	PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,Transform(cCNPJ,"@R 99.999.999/9999-99"),oPrint,4,2,/*RgbColor*/," CNPJ: ")
	PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),60,cTabFre + " - " + cTipTab,oPrint,4,2,/*RgbColor*/," TABELA: ")
	nLin+=60

	PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,AllTrim(SA1->A1_END),oPrint,4,2,/*RgbColor*/," ENDERE«O")
	PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,AllTrim(SA1->A1_DDD) + "-" + AllTrim(SA1->A1_TEL),oPrint,4,2,/*RgbColor*/," TELEFONE")
	PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),60,DtoC(AAM->AAM_INIVIG),oPrint,4,2,/*RgbColor*/," VIG NCIA")
	nLin+=80
	
	PcoPrtCol({20,2000},.T.,1)
	PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,"Origem" + Posicione("DUY",1,xFilial("DUY")+cCodReg,"DUY_DESCRI"),oPrint,4,2,RGB(230,230,230))
	nLin+=80
	
	PcoPrtCol({020,070,450,2000},.T.,3)
	PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),120,"UF",oPrint,4,2,/*RgbColor*/)
	PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),120,"REGI√O",oPrint,4,2,/*RgbColor*/)
	
	//-- Qtde de texto no primeiro item do cabecalho
	cCodPas := aItensPro[1,5,1,1]
	For nX := 1 To Len(aItensPro[1,5])
		If cCodPas == aItensPro[1,5,nX,1]
			nTotCab ++
		Else
			Exit
		EndIf
		cCodPas := aItensPro[1,5,nX,1]
	Next nX

	nTotBox := Len(aItensPro[1,5])
	cCodPas := aItensPro[1,5,1,1]
	cTabFre := aItensPro[1,5,1,5]
	cTipTab := aItensPro[1,5,1,6]
	lNumPri := .F.
	cTabFrePri:= cTabFre
	cTipTabPri:= cTipTab

	If cCodPas == "MN"
		cDesPas := 	"Frete MÌn."
		Posicione("DT3",1,xFilial("DT3")+"02","DT3_DESCRI")
	Else
		cDesPas := AllTrim(Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_DESCRI"))
		If "FRETE PESO" $ Upper(cDesPas)
			cDesPas += " ( Reais por Conhecimento ) "
		EndIf
	EndIf
	lTemFai := (aItensPro[1,5,1,2] > 0)
	lPerFai := DT3->DT3_TIPFAI == "02"
	cDesFai := ""

	PcoPrtCell(PcoPrtPos(3),nLin,(PcoPrtTam(3)/nTotBox)*nTotCab,60,cDesPas,oPrint,4,2,/*RgbColor*/,,,,,.T.)
	nLin+=60

	nIniCell := PcoPrtPos(3)
	For nX := 1 To nTotBox
		If nX > 1
			nIniCell := nIniCell + PcoPrtTam(3)/nTotBox
		EndIf
		If aItensPro[1,5,nX,1] <> cCodPas
			cCodPas := aItensPro[1,5,nX,1]
			cTabFre := aItensPro[1,5,nX,5]
			cTipTab := aItensPro[1,5,nX,6]
			lNumPri := aItensPro[1,5,nX,7]
			If cCodPas == "MN"
				cDesPas := 	"Frete MÌn."
				Posicione("DT3",1,xFilial("DT3")+"02","DT3_DESCRI")
			Else
				cDesPas := AllTrim(Posicione("DT3",1,xFilial("DT3")+cCodPas,"DT3_DESCRI"))
				If "FRETE PESO" $ Upper(cDesPas)
					cDesPas += " ( Reais por Conhecimento ) " 
				EndIf
			EndIf
			lTemFai := (aItensPro[1,5,nX,2] > 0)
			lPerFai := DT3->DT3_TIPFAI == "02"
			If lPerFai
				If cCodPas == "MN"
					cDesFai := "(R$)"
				Else
					cDesFai := "(%)"
				EndIf
				lPerFai := .F.
			EndIf	
			PcoPrtCell(nIniCell,nLin-60,PcoPrtTam(3)/nTotBox,60,cDesPas,oPrint,4,2,/*RgbColor*/,,,,,.T.) 
		EndIf
		cTabOld := cTabFre
		cTipOld := cTipTab
		cDesFai := ""
		lAcima  := .F.
		
		If lTemFai
			If aItensPro[1,5,nX,2] >= 999999.9999
				If nX-1 > 0 .And. aItensPro[1,5,nX,1] == aItensPro[1,5,nX-1,1]				   
					lAcima  := .T.
					cDesFai := AllTrim(Transform(aItensPro[1,5,nX-1,2],"@E 99,999.99"))
				EndIf              
				cDesFTit:= ""
				If DT3->DT3_TIPFAI == "01" //-- Peso
				   If aItensPro[1,5,nX,4] == 1000   //-- Intervalo
						cDesFTit := "-R$/Ton"				  		
					ElseIF aItensPro[1,5,nX,4] == 100   //-- Intervalo	
						cDesFTit := "R$/100 Kg ou"
						cDesFai  := "FraÁ„o"
					Else	
						cDesFTit := "-R$/Kg"
					EndIf	
					
				ElseIf DT3->DT3_TIPFAI == "02"
					If cCodPas == "MN"
						cDesFai := "(R$)"
					Else
						cDesFai := "(%)"
					EndIf
				Else
					cDesFai := "(R$)"
				EndIf
				PcoPrtCell(nIniCell,nLin,PcoPrtTam(3)/nTotBox,60,cDesFai,oPrint,4,2,/*RgbColor*/,If(lAcima," Acima ","")+cDesFTit,,,,.T.)
			Else
				cDesFai := AllTrim(Transform(aItensPro[1,5,nX,2],"@E 99,999.99"))
				cDesFTit:= ""
				If DT3->DT3_TIPFAI == "01" //-- Peso
					cDesFTit:= "-Kg"
				ElseIf DT3->DT3_TIPFAI == "02"
					If cCodPas == "MN"
						cDesFai := "(R$)"
					Else
						cDesFai := "(%)"
					EndIf
				Else
					cDesFai := "(R$)"
				EndIf
				PcoPrtCell(nIniCell,nLin,PcoPrtTam(3)/nTotBox,60,cDesFai,oPrint,4,2,/*RgbColor*/,"Ate"+cDesFTit,,,,.T.)
			EndIf
		EndIf

	Next nX
EndIf
nLin+= 60

Return

/*/{Protheus.doc} MOVR5It
Impressao dos Itens
@type function
@version 12.1.33
@author Rodolfo Kneubuhl Rosseto
@since 20/09/2022
@return variant, Nil
/*/
Static Function MOVR5It(oPrint,aItensPro)

Local nX      := 0
Local nCnt    := 0
Local nCnt1   := 0
Local nTotBox := 0
Local nTamBox := 0
Local cDesPrc := ''

For nX := 1 To Len(aItensPro)
	If PcoPrtLim(nLin)
		RTMSR14Cab(oPrint,aItensPro)
	EndIf
	//-- Impressao do Estado
	PcoPrtCol({020,070,450,2000},.T.,3)
	PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aItensPro[nX,1],oPrint,4,2,/*RgbColor*/)
	//-- Impressao do Municipio
	PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,Capital(aItensPro[nX,2]),oPrint,4,2,/*RgbColor*/)

	//-- Impressao dos precos
	nTotBox  := Len(aItensPro[nX,5])
	nIniCell := PcoPrtPos(3)
	nTamBox  := PcoPrtTam(3)/nTotBox
	For nCnt := 1 To nTotBox
		If nCnt > 1
			nIniCell := nIniCell + nTamBox
		EndIf
		nValor := 0
		For nCnt1 := 1 To Len(aItensPro[nX,3])
			If !aItensPro[nX,3,nCnt1,5]
				If aItensPro[nX,3,nCnt1,1] == aItensPro[nX,5,nCnt,1] .And. ;
					aItensPro[nX,3,nCnt1,2] <= aItensPro[nX,5,nCnt,2]
					nValor := aItensPro[nX,3,nCnt1,3]
					aItensPro[nX,3,nCnt1,5] := .T.
				EndIf				
			EndIf
		Next nCnt1
		cDesPrc := AllTrim(TransForm(nValor,"@E 9,999.99"))
		PcoPrtCell(nIniCell,nLin,nTamBox,50,cDesPrc,oPrint,4,2,/*RgbColor*/,,.T.,,,.T.)
	Next nCnt
	nLin += 50
Next nX

Return

/*/{Protheus.doc} MOVR5Fim
Impressao do Final com Observacoes
@type function
@version 12.1.33
@author Rodolfo Kneubuhl Rosseto
@since 20/09/2022
@return variant, Nil
/*/
Static Function MOVR5Fim(oPrint,cTabFre,cTipTab,cContrat)

Local cObs      := ""
Local cObsAAM   := ""
Local nTamObs   := 0
Local cTxt      := ""
Local nCont 	:= 0

cObs += CHR(13)+CHR(10)

//--Existem textos na configuracao da tabela
If Len(aObsDVE) > 0
	For nCont := 1 To Len(aObsDVE)
		cTxt := &(aObsDVE[nCont][02])
		If !Empty(cTxt)
			cObs += AllTrim(Posicione("DT3",1,xFilial("DT3")+aObsDVE[nCont][01],"DT3_DESCRI"))+": "+cTxt+CHR(13)+CHR(10)
		EndIf
	Next nCont
EndIf

cObs += CHR(13)+CHR(10)+CHR(13)+CHR(10)

cObsAAM := E_MsMM(Posicione("AAM",1,xFilial("AAM")+cContrat,"AAM_CODMEM"),80)
For nCont := 1 To MlCount(cObsAAM,150)
	If	!Empty(AllTrim(MemoLine(cObsAAM,150,nCont)))
		cObs += AllTrim(MemoLine(cObsAAM,150,nCont))+CHR(13)+CHR(10)
	EndIf
Next nCont

nTamObs := MlCount(cObs,250) * 35
If nTamObs > 0
	nLin += 60
	If PcoPrtLim(nLin + nTamObs)
		PcoPrtCab(oPrint,4,cFileLogo)
		nLin  := 200
	EndIf
	PcoPrtCol({20,2000},.T.,1)
	PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),nTamObs,cObs,oPrint,4,2,/*RgbColor*/,"Observacoes")
EndIf

nLin += ( nTamObs + 060 )
If PcoPrtLim(nLin)
	PcoPrtCab(oPrint,4,cFileLogo)
	nLin  := 200
EndIf

nLin += 100
If PcoPrtLim(nLin)
	PcoPrtCab(oPrint,4,cFileLogo)
	nLin  := 200
EndIf

PcoPrtCol({20,800,1200,2000},.T.,2)
PcoPrtCell(100,nLin,PcoPrtTam(1),60,"CLIENTE",oPrint,5,2)
PcoPrtCell(1000,nLin,PcoPrtTam(1),60,"CARIMBO",oPrint,5,2)

nLin += 100
If PcoPrtLim(nLin)
	PcoPrtCab(oPrint,4,cFileLogo)
	nLin  := 200
EndIf
PcoPrtCell(100,nLin,PcoPrtTam(1),60,Replicate("_",20),oPrint,5,2)
PcoPrtCell(500,nLin,PcoPrtTam(2),60,Replicate("_",20),oPrint,5,2)
PcoPrtCell(1000,nLin,PcoPrtTam(3),60,Replicate("_",20),oPrint,5,2)
PcoPrtCell(1500,nLin,PcoPrtTam(4),60,Replicate("_",20),oPrint,5,2)

nLin += 50
If PcoPrtLim(nLin)
	PcoPrtCab(oPrint,4,cFileLogo)
	nLin  := 200
EndIf
PcoPrtCell(100,nLin,PcoPrtTam(1),60,"MOVVI LOGISTICA",oPrint,5,2)
PcoPrtCell(500,nLin,PcoPrtTam(2),60,"NOME LEGIVEL",oPrint,5,2)
PcoPrtCell(1000,nLin,PcoPrtTam(3),60,"RG",oPrint,5,2)
PcoPrtCell(1500,nLin,PcoPrtTam(4),60,"ASSINATURA",oPrint,5,2)

Return NIL


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

U_DLM_PSx1( { cPerg, "01","Cliente De ?" 		,"Cliente De ?" 	,"Cliente De ?" 	,"mv_ch1","C",08	,0,0,"G","","SA1"   ,"001"	,"","mv_par01" })
U_DLM_PSx1( { cPerg, "02","Loja De ?" 			,"Loja De ?" 		,"Loja De ?" 		,"mv_ch2","C",04    ,0,0,"G","",""      ,"002"  ,"","mv_par02" })
U_DLM_PSx1( { cPerg, "03","Cliente Ate ?" 		,"Cliente Ate ?" 	,"Cliente Ate ?" 	,"mv_ch3","C",08    ,0,0,"G","","SA1"   ,"001"  ,"","mv_par03" })
U_DLM_PSx1( { cPerg, "04","Loja Ate ?" 			,"Loja Ate ?" 		,"Loja Ate ?" 		,"mv_ch4","C",04    ,0,0,"G","",""      ,"002"  ,"","mv_par04" })
U_DLM_PSx1( { cPerg, "05","Negociacao De ?" 	,"Negociacao De ?" 	,"Negociacao De ?" 	,"mv_ch5","C",02	,0,0,"G","","DDB"   ,""     ,"","mv_par05" })
U_DLM_PSx1( { cPerg, "06","Negociacao Ate ?" 	,"Negociacao Ate ?" ,"Negociacao Ate ?" ,"mv_ch6","C",02	,0,0,"G","","DDB"   ,""     ,"","mv_par06" })
U_DLM_PSx1( { cPerg, "07","Servico De ?" 		,"Servico De ?" 	,"Servico De ?" 	,"mv_ch7","C",03	,0,0,"G","","DLJ"   ,""     ,"","mv_par07" })
U_DLM_PSx1( { cPerg, "08","Servico Ate ?" 		,"Servico Ate ?" 	,"Servico Ate ?" 	,"mv_ch8","C",03	,0,0,"G","","DLJ"   ,""     ,"","mv_par08" })
U_DLM_PSx1( { cPerg, "09","Tabela De ?" 		,"Tabela De ?" 		,"Tabela De ?" 		,"mv_ch9","C",04	,0,0,"G","","DTL"   ,""     ,"","mv_par09" })
U_DLM_PSx1( { cPerg, "10","Tipo De ?" 			,"Tipo De ?" 		,"Tipo De ?" 		,"mv_ch10","C",02	,0,0,"G","",""     	,""     ,"","mv_par10" })
U_DLM_PSx1( { cPerg, "11","Tabela Ate ?" 		,"Tabela Ate ?" 	,"Tabela Ate ?" 	,"mv_ch11","C",04	,0,0,"G","","DTL"  	,""     ,"","mv_par11" })
U_DLM_PSx1( { cPerg, "12","Tipo Ate ?" 			,"Tipo Ate ?" 		,"Tipo Ate ?" 		,"mv_ch12","C",02	,0,0,"G","",""     	,""     ,"","mv_par12" })

//PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,;
//                            cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,;
//                           cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)


RestArea(aArea)

Return Nil
