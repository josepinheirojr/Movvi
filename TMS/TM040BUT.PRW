#include "protheus.ch"
#include "fwmvcdef.ch"


#DEFINE NCNTFOR     01 //-- Indica que será somente um produto que esta no aCols principal

#DEFINE CTABELA     01
#DEFINE CDESCRI     02
#DEFINE NVALLIQ     03
#DEFINE NVALIMP     04
#DEFINE NVALTOT     05
#DEFINE NRENTAB     06

/*/-----------------------------------------------------------
PE TM040BUT()
Utilizado para calcular a cotação utilizando varias tabelas
que o cliente possa ter amarrada ao contrato.

@author Jose Luiz Pinheiro Junior         
@since 07/02/2022
@version 1.0
-----------------------------------------------------------/*/
User Function TM040BUT()             
Local aButtons := {}

If Type('__aTbCotAux') == 'U'
    Public __aTbCotAux := {} //-- Variavel utilizada no PE TM040GRV
EndIf

If Type('__lBloqueiaCot') == 'U'
    //-- se houve rentabilidade abaixo do contrato do cliente generico, bloqueia cotação
    Public __lBloqueiaCot := .F. //-- Variavel utilizada no PE TM040GRV
EndIf


//AAdd( aSetKey  ,{ VK_F2   ,{|| U_T40SELTAB() } } )
If INCLUI .Or. ALTERA 
    Aadd(aButtons, {'CLOCK02', {|| U_T40SELTAB() }, 'Cotacao Adicional', 'Cotacao Adicional' }) 
EndIf

Return aButtons




/*/{Protheus.doc} User Function T40SELTAB
Visualizacao das Tabelas de Fretes Auxiliares
@type  Function
@author Jose Luiz Pinheiro Junior
@since  08/02/2022
@version version
/*/
 
User Function T40SELTAB()
    Local aArea := GetArea()
    //Fontes
    Local cFontUti    := "Tahoma"
    Local oFontAno    := TFont():New(cFontUti,,-38)
    Local oFontSub    := TFont():New(cFontUti,,-20)
    Local oFontSubN   := TFont():New(cFontUti,,-20,,.T.)
    Local oFontBtn    := TFont():New(cFontUti,,-14)

    //Janela e componentes
    Private oDlgGrp
    Private oPanGrid
    Private oGetGrid
    Private aHeaderGrid := {}
    Private aColsGrid := {}

    //Tamanho da janela
    Private aTamanho := MsAdvSize()
    Private nJanLarg := aTamanho[5]
    Private nJanAltu := aTamanho[6]
 
    //Utilizado para calculo do Frete
    Private aPerfil := {}
    Private aFrtAlt := {}
    Private aPosicione := {}

    Private cTabCliGen := ""
    Private cMV_CliGen := AllTrim(SuperGetMV('MV_CLIGEN'))

    //Monta o cabecalho
    aTabFre := fMontaHead()
 
    //Criando a janela
    DEFINE MSDIALOG oDlgGrp TITLE "Cotação Adicional" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Labels gerais
        @ 004, 003 SAY "TMS"                      SIZE 200, 030 FONT oFontAno  OF oDlgGrp COLORS RGB(149,179,215) PIXEL
        @ 004, 050 SAY "Valores para "            SIZE 200, 030 FONT oFontSub  OF oDlgGrp COLORS RGB(031,073,125) PIXEL
        @ 014, 050 SAY "Cotação Adicional"        SIZE 200, 030 FONT oFontSubN OF oDlgGrp COLORS RGB(031,073,125) PIXEL
 
        //Botões
        @ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Cancelar"       SIZE 050, 018 OF oDlgGrp ACTION (__aTbCotAux := {}, oDlgGrp:End())   FONT oFontBtn PIXEL
        @ 006, (nJanLarg/2-001)-(0052*02) BUTTON oBtnLege  PROMPT "Selecionar"     SIZE 050, 018 OF oDlgGrp ACTION (fLinhaAtu()) PIXEL
 
        //Dados
        @ 024, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT "Tabelas encontrada no perfil do cliente" OF oDlgGrp COLOR 0, 16777215 PIXEL
        oGrpDad:oFont := oFontBtn
            oPanGrid := tPanel():New(033, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13)  ,  (nJanAltu/2 - 45) )
            oGetGrid := FWBrowse():New()
            oGetGrid:DisableFilter()
            oGetGrid:DisableConfig()
            oGetGrid:DisableReport()
            oGetGrid:DisableSeek()
            oGetGrid:DisableSaveConfig()
            oGetGrid:SetFontBrowse(oFontBtn)
            oGetGrid:SetDataArray()
            oGetGrid:lHeaderClick :=.f.
            oGetGrid:SetBlkBackColor({|| IIf( cMV_CliGen $ oGetGrid:oData:aArray[oGetGrid:At(), Len(aHeaderGrid)  ]   , RGB(238,221,130) , Nil )})
            oGetGrid:AddLegend("oGetGrid:oData:aArray[oGetGrid:At(), Len(aHeaderGrid)  ] = '" + cMV_CliGen + "' ", "BLACK",  "Calculo pela tabela custo")
            oGetGrid:AddLegend("oGetGrid:oData:aArray[oGetGrid:At(), Len(aHeaderGrid)  ] = 'OK' ", "GREEN",  "Calculo realizado normalmente")
            oGetGrid:AddLegend("oGetGrid:oData:aArray[oGetGrid:At(), Len(aHeaderGrid)  ] <> 'OK' ", "RED",    "Calculo com valor de frete zerado")
            oGetGrid:SetColumns(aHeaderGrid)
            oGetGrid:SetArray(aColsGrid)
            oGetGrid:SetOwner(oPanGrid)
            oGetGrid:Activate()
 
        FWMsgRun(, {|oSay| fMontDados(oSay,aTabFre) }, "Processando", "Calculando Cotação Adicional")
    ACTIVATE MsDialog oDlgGrp CENTERED
 
    RestArea(aArea)
Return
 


//-- Monta o aHeaderGrid e dimensiona de acordo com a quantidade de componentes.
//-- pesquisa no tabela de Frete Auxiliar - PA0.
Static Function fMontaHead()
    Local nAtual
    Local aHeadAux   := {}
    Local aTabFre    := {}
    Local cQuery     := ""
    Local cAliasPA0  := GetNextAlias()
    Local nSeek      := 0
    Local cBusca     := ""

    //Adicionando colunas
    //[1] - Titulo
    //[2] - Tipo
    //[3] - Tamanho
    //[4] - Decimais
    //[5] - Máscara
    aAdd(aHeadAux, { "Serv/Tabela/Tipo"  ,  "C", TamSX3('PA0_SERVIC')[01] + TamSX3('PA0_TABFRE')[01] + TamSX3('PA0_TIPTAB')[01],    0, ""}) //-- 01
    aAdd(aHeadAux, { "Descricao"         ,  "C", TamSX3('DTL_DESCRI')[01],    0, ""})  //-- 02
    aAdd(aHeadAux, { "Frete"             ,  "N", 15,  2, "@E 999,999,999,999.99"} )    //-- 03
    aAdd(aHeadAux, { "Imposto"           ,  "N", 15,  2, "@E 999,999,999,999.99"} )    //-- 04
    aAdd(aHeadAux, { "Frete+Imposto"     ,  "N", 15,  2, "@E 999,999,999,999.99"} )    //-- 05
    aAdd(aHeadAux, { "RENTABILIDADE"     ,  "N",  6,  2, "@E 999.99"} )                //-- 06


    cQuery := ""
    cQuery += " SELECT PA0_SERVIC, PA0_TABFRE, PA0_TIPTAB, DTL_DESCRI, DT3_CODPAS, DT3_DESCRI "
    cQuery += "   FROM " + RetSQLName('PA0') + " PA0 "
    cQuery += "   JOIN " + RetSQLName('DTL') + " DTL "
    cQuery += "     ON DTL_FILIAL = '" + FWxFilial('DTL') + "' "
    cQuery += "    AND DTL_TABFRE = PA0_TABFRE "
    cQuery += "    AND DTL_TIPTAB = PA0_TIPTAB "
    cQuery += "    AND DTL.D_E_L_E_T_ = ' ' "
    cQuery += "   JOIN " + RetSQLName('DVE') + " DVE "
    cQuery += "     ON DVE_FILIAL = '" + FWxFilial('DVE') + "' "
    cQuery += "    AND DVE_TABFRE = DTL_TABFRE "
    cQuery += "    AND DVE_TIPTAB = DTL_TIPTAB "
    cQuery += "    AND DVE.D_E_L_E_T_ = ' ' "
    cQuery += "   JOIN " + RetSQLName('DT3') + " DT3 "
    cQuery += "     ON DT3_FILIAL = '" + FWxFilial('DT3') + "' "
    cQuery += "    AND DT3_CODPAS = DVE_CODPAS "
    cQuery += "    AND DT3.D_E_L_E_T_ = ' ' "
    cQuery += "  WHERE PA0_FILIAL = ' ' "
    cQuery += "    AND PA0_NCONTR = '" + M->DT4_NCONTR + "' " //-- colocar o codigo da tabela
    cQuery += "    AND PA0_SERVIC = '" + M->DT4_SERVIC + "' " //--
    cQuery += "    AND PA0.D_E_L_E_T_ = ' ' "
    cQuery += "  ORDER BY PA0_TABFRE, PA0_TIPTAB, DT3_CODPAS "

    PLSQuery(cQuery, cAliasPA0)

    //Se houve dados
    If ! (cAliasPA0)->(EoF())
         While ! (cAliasPA0)->(EoF())

            cBusca := (  (cAliasPA0)->PA0_SERVIC + '-' + (cAliasPA0)->PA0_TABFRE + '-' + (cAliasPA0)->PA0_TIPTAB  )
            If (nSeek := ASCAN(aTabFre,{|x| cBusca == x[1] } ) ) = 0
                aAdd(aTabFre, { cBusca , AllTrim((cAliasPA0)->DTL_DESCRI) } )
            EndIf

            cBusca := ( (cAliasPA0)->DT3_CODPAS + '-' + Alltrim((cAliasPA0)->DT3_DESCRI) )
            If (nSeek := ASCAN(aHeadAux,{|x| cBusca == x[1] } ) ) = 0
                aAdd(aHeadAux, { cBusca ,  "N", 15,  2, "@E 999,999,999,999.99"} )
            EndIf

            (cAliasPA0)->(DbSkip())
        EndDo
    EndIf
	(cAliasPA0)->(dbCloseArea())

    //-- Realiza a pesquisa da tabela para o cliente generico
    SA1->(DbSetOrder(1)) //-- A1_FILIAL+A1_COD+A1_LOJA
    If !Empty(cMV_CliGen) .And. SA1->(MsSeek(FWxFilial('SA1')+cMV_CliGen))  //posiciona na tabela SA1
        cTabCliGen := ""
        //cCliGen := SA1->A1_COD
        //cLojGen := SA1->A1_LOJA

        cQuery := ""
        cQuery += "SELECT DDA_SERVIC, DDA_XTBCUS, DDA_XTPCUS, DTL_DESCRI, DT3_CODPAS, DT3_DESCRI "
        cQuery += "  FROM " + RetSQLName('AAM') + " AAM "
        cQuery += "  JOIN " + RetSQLName('DDA') + " DDA "
        cQuery += "    ON DDA_FILIAL = '" + FWxFilial('DDA') + "'  "
        cQuery += "   AND DDA_NCONTR = AAM_CONTRT "
        cQuery += "   AND DDA_SERVIC = '" + M->DT4_SERVIC + "' "
        cQuery += "   AND DDA_TABFRE = '" + M->DT4_TABFRE + "' "
        cQuery += "   AND DDA_TIPTAB = '" + M->DT4_TIPTAB + "' "
        cQuery += "   AND DDA_XTBCUS <> ' ' AND DDA.D_E_L_E_T_ = ' ' "
        cQuery += "  JOIN " + RetSQLName('DTL') + " DTL "
        cQuery += "    ON DTL_FILIAL = '" + FWxFilial('DTL') + "' "
        cQuery += "   AND DTL_TABFRE = DDA_XTBCUS "
        cQuery += "   AND DTL_TIPTAB = DDA_XTPCUS "
        cQuery += "   AND DTL.D_E_L_E_T_ = ' ' "
        cQuery += "  JOIN " + RetSQLName('DVE') + " DVE "
        cQuery += "    ON DVE_FILIAL = '" + FWxFilial('DVE') + "' "
        cQuery += "   AND DVE_TABFRE = DTL_TABFRE "
        cQuery += "   AND DVE_TIPTAB = DTL_TIPTAB "
        cQuery += "   AND DVE.D_E_L_E_T_ = ' ' "
        cQuery += "  JOIN " + RetSQLName('DT3') + " DT3 "
        cQuery += "    ON DT3_FILIAL = '" + FWxFilial('DT3') + "' "
        cQuery += "   AND DT3_CODPAS = DVE_CODPAS "
        cQuery += "   AND DT3.D_E_L_E_T_ = ' ' "
        cQuery += " WHERE AAM_FILIAL = '" + FWxFilial('AAM') + "' "
        cQuery += "   AND AAM_CODCLI = '" + SA1->A1_COD + "' "
        cQuery += "   AND AAM_LOJA = '"   + SA1->A1_LOJA + "' "
        cQuery += "   AND AAM_FIMVIG = '  ' "
        cQuery += "   AND AAM.D_E_L_E_T_ = ' ' "
        cQuery += "   ORDER BY  DDA_XTBCUS, DDA_XTPCUS, DT3_CODPAS "

        PLSQuery(cQuery, cAliasPA0)

        //Se houve dados
        If ! (cAliasPA0)->(EoF())
            While ! (cAliasPA0)->(EoF())

                cTabCliGen := (  (cAliasPA0)->DDA_SERVIC + (cAliasPA0)->DDA_XTBCUS + (cAliasPA0)->DDA_XTPCUS  ) //-- alimenta a variavel para pesquisa futura da tabela do cliente generico.
                cBusca := (  (cAliasPA0)->DDA_SERVIC + '-' + (cAliasPA0)->DDA_XTBCUS + '-' + (cAliasPA0)->DDA_XTPCUS  )
                If (nSeek := ASCAN(aTabFre,{|x| cBusca == x[1] } ) ) = 0
                    aAdd(aTabFre, { cBusca , AllTrim((cAliasPA0)->DTL_DESCRI) } )
                EndIf

                cBusca := ( (cAliasPA0)->DT3_CODPAS + '-' + Alltrim((cAliasPA0)->DT3_DESCRI) )
                If (nSeek := ASCAN(aHeadAux,{|x| cBusca == x[1] } ) ) = 0
                    aAdd(aHeadAux, { cBusca ,  "N", 15,  2, "@E 999,999,999,999.99"} )
                EndIf

                (cAliasPA0)->(DbSkip())
            EndDo
        EndIf
	    (cAliasPA0)->(dbCloseArea())
    EndIf

    aAdd(aHeadAux, { "Mensagem"    ,  "C", 150,    0, ""})  //-- ultima coluna

    //Adicionando colunas
    //[1] - Titulo
    //[2] - Tipo
    //[3] - Tamanho
    //[4] - Decimais
    //[5] - Máscara
    //aAdd(aHeadAux, {"Código",            "C", TamSX3('BM_GRUPO')[01],   0, ""})
    //aAdd(aHeadAux, {"Descricao",         "C", TamSX3('BM_DESC')[01],    0, ""})
    //aAdd(aHeadAux, {"Status Grupo",      "C", TamSX3('BM_STATUS')[01],  0, ""})
    //aAdd(aHeadAux, {"Procedencia",       "C", TamSX3('BM_PROORI')[01],  0, ""})
    //aAdd(aHeadAux, {"Total de Produtos", "N", 18,                       0, "@E 999,999,999,999,999,999"})
    //aAdd(aHeadAux, {"SBM RecNo",         "N", 18,                       0, "@E 999,999,999,999,999,999"})
 

    //Percorrendo e criando as colunas
    For nAtual := 1 To Len(aHeadAux)
        aAdd(aHeaderGrid, FWBrwColumn():New())
        aHeaderGrid[nAtual]:SetData(&("{||oGetGrid:oData:aArray[oGetGrid:At(),"+Str(nAtual)+"]}"))
        aHeaderGrid[nAtual]:SetTitle( aHeadAux[nAtual][1] )
        aHeaderGrid[nAtual]:SetType(aHeadAux[nAtual][2] )
        aHeaderGrid[nAtual]:SetSize( aHeadAux[nAtual][3] )
        aHeaderGrid[nAtual]:SetDecimal( aHeadAux[nAtual][4] )
        aHeaderGrid[nAtual]:SetPicture( aHeadAux[nAtual][5] )
    Next

Return aTabFre
 


//-- Monta o e dimensiona aColsGrid e
//-- chama a rotina de calculo do frete
Static Function fMontDados(oSay,aTabFre)
    Local aArea     := GetArea()
    Local nX        := 0
    Local cBloco    := ""
    Local lCont     := .F.
    Local nPos      := 0
    Local nVCus     := 0
    Local nVTot     := 0
    Local nPRent    := 0

    //Zera a grid
    aColsGrid := {}
    cBloco := "{"
    For nX := 1 To Len(aHeaderGrid)
        If aHeaderGrid[nX]:CTYPE == "C"
            cBloco += "'  '"
        Else
            cBloco += "0"
        EndIf
        If nX < Len(aHeaderGrid)
            cBloco += ","
        EndIf
    Next nX
    cBloco += ",.F.}"

    If Len(aTabFre) > 0
        lCont := .T.
        For nX := 1 To Len(aTabFre)
            aAdd(aColsGrid, &(cBloco) )
            aColsGrid[nX,1] := aTabFre[nX,1]
            aColsGrid[nX,2] := aTabFre[nX,2]
        Next nX
    Else
        MsgStop("Nao foram encontrada Tabelas Auxiliares!", "Atencao")
        aColsGrid := {}
        //aAdd(aColsGrid, { " ", " ", 0 , 0 , 0  ,.F. } )
    EndIf
 

    If lCont
		aPerfil := TMSPerfil(cCliDev,cLojDev,.T.,.F.)
        For nX := 1 To Len(aColsGrid)
            fCalFre(nX)
        Next nX

        //-- Calcula a Rentabilidade
	    If (nPos := Ascan(aColsGrid, {|x| cMV_CliGen $ x[Len(aHeaderGrid)] }) ) > 0
            nVCus := aColsGrid[nPos,NVALTOT] //-- Valor pela tabela de Custos

            For nX := 1 To Len(aColsGrid)
                nPRent := 0
                nVTot  := aColsGrid[nX,NVALTOT] //-- Valor do frete Calculado
                If nVTot > 0
                    nPRent := (((nVTot / nVCus) - 1) * 100)
                    aColsGrid[nX,NRENTAB] := nPRent
                EndIf
            Next nX
        EndIf

        //-- Orderna o Vetor pela Coluna da Rentabilidade + Frete+Imposto (col. 6 + 5)
        ASort( aColsGrid ,,, { | x, y | x[6] + x[5] > y[6] + y[5] } ) 

        //Define o array
        oSay:SetText("Atribuindo os dados na tela")
        oGetGrid:SetArray(aColsGrid)
        oGetGrid:Refresh()
    EndIf

    RestArea(aArea)
Return
 

 
//-- Funcao chamada para confirmar a linha atual
//-- referente a tabela escolhida.
//-- Recalcula o frete e atualiza as variaveis da TMSA040.
Static Function fLinhaAtu()
    Local nLinha   := oGetGrid:At()   
    Local aMsgErr  := {}
    Local nX       := 0
    Local aTmp     := {}
    Local cMsgErr  := ""
    Local aFreTmp  := {}
    Local aFrtAux  := {}
    Local nPos     := 0
    Local nPRent   := 0
    Local cNContr  := ""
    Local cChave   := ""
    Local aArea    := { SA1->(GetArea()) , AAM->(GetArea()) , DDA->(GetArea()) , GetArea() } 

    cMsgErr := AllTrim(aColsGrid[nLinha , Len(aHeaderGrid) ])
    nPRent  := aColsGrid[nLinha,NRENTAB] //-- Rentabilidade Calculada

    If cMsgErr == cMV_CliGen
        AAdd(aMsgErr,{ '  ' ,'00',''})
        AAdd(aMsgErr,{ '  ' ,'00',''})
        AAdd(aMsgErr,{ '*** Valores calculado na tabela de custo - não pode ser selecionada.' ,'00',''})

        If	!Empty( aMsgErr )
            TmsMsgErr( aMsgErr )
        EndIf
    ElseIf cMsgErr <> 'OK'
        aTmp := StrToArray( cMsgErr , "#" )    

        For nX := 1 To Len(aTmp)
            AAdd(aMsgErr,{ aTmp[nX] ,'00',''})
        Next nX

        AAdd(aMsgErr,{ '  ' ,'00',''})
        AAdd(aMsgErr,{ '  ' ,'00',''})
        AAdd(aMsgErr,{ '*** Tabela com Frete zerado não pode ser selecionada.' ,'00',''})

        If	!Empty( aMsgErr )
            TmsMsgErr( aMsgErr )
        EndIf
    Else
        If MsgYesNo("Deseja aplicar o calculo selecionado na Cotação ?","Atenção")

            __lBloqueiaCot := .F. //-- variavel de controle de bloqueio da cotação.

            //-- Calcula a Rentabilidade
            If (nPos := Ascan(aColsGrid, {|x| x[Len(aHeaderGrid)] == cMV_CliGen }) ) > 0
                aTmp := StrToArray( aColsGrid[nPos,1] , "-" )
                //aTmp[1] //-- serviço
                //aTmp[2] //-- Tabela de Frete
                //aTmp[3] //-- Tipo da Tabela

                AAM->(DbSetOrder(4)) //-- AAM_FILIAL+AAM_CODCLI+AAM_LOJA+AAM_CONTRT
                cChave := FWxFilial('AAM') + cMV_CliGen
                AAM->(MsSeek( cChave ) )
                While AAM->(!EoF()) .And. cChave == AAM->AAM_FILIAL+AAM->AAM_CODCLI+AAM->AAM_LOJA 
 				    If Empty(AAM->AAM_FIMVIG)
                        cNContr := AAM->AAM_CONTRT
                        Exit
                    EndIf
	        	    AAM->(DbSkip())
		        EndDo

				DDA->( dbOrderNickName("DDAESP01") ) //--DDA_FILIAL+DDA_NCONTR+DDA_SERVIC+DDA_XTBCUS+DDA_XTPCUS
                If DDA->(MsSeek(FWxFilial('DDA') +  cNContr + aTmp[1] + aTmp[2] + aTmp[3] ))
                    If nPRent < DDA->DDA_XPRENT
                        __lBloqueiaCot := .T. //-- realiza o bloqueio da cotação por rentabilidade.
                    EndIf
                EndIf            
            EndIf

            __aTbCotAux := StrToArray( aColsGrid[nLinha,1] , "-" ) //-- Variavel utilizado no PE TM040GRV
            aTmp        := StrToArray( aColsGrid[nLinha,1] , "-" )
            M->DT4_SERVIC  := aTmp[1] //-- serviço
            M->DT4_TABFRE  := aTmp[2] //-- Tabela de Frete
            M->DT4_TIPTAB  := aTmp[3] //-- Tipo da Tabela

            aFreTmp := fCalFre(nLinha , .T.)
            AAdd(aFrtAux,{GDFieldGet('DVF_CODPRO', NCNTFOR ),aFreTmp})

            If	! Empty(aFrtAux)
                aFrete := {}
                aFrete := AClone(aFrtAux)
            EndIf

            If ValType(oTValPas) == "O"
                oTValPas:Refresh()
                oTValImp:Refresh()
                oTValTot:Refresh()
            EndIf

            oDlgGrp:End() //-- Fecha tela de Cotação Auxiliar.

        EndIf
    EndIf

AEval(aArea,{|x,y| RestArea(x) })
Return


//-- Realiza o calculo do frete da tabela selecionada.
Static Function fCalFre(nLinha,lAtuVar)
Local cSeqAlt    := ""
Local aMsgErr    := {}
Local cMsgErr    := ""
Local lAjuste    := .F.
Local aValAux    := {}
Local lTMSCFec   := TMSCFec() // Carga Fechada
Local aTipVei    := {}
Local n1Cnt      := 0
Local nPosTipVei := 0
Local nPosQtdVei := 0
Local nSeek      := 0
Local aPesCub    := {}
Local nPerCub    := 0
Local nFatCub    := 0
Local lInvOri    := (M->DT4_INVORI == "1")
Local nX         := 0
Local nY         := 0
Local cServic    := ""
Local cTabFre    := ""
Local cTipTab    := ""
Local aTmp       := {}
Local cFilDes    := ""
Local lTM040CUB	 := ExistBlock("TM040CUB")	//-- Pto que permite a alteração do Peso Cubado, antes do calculo do Frete

Local nQtdVol := GDFieldGet( 'DVF_QTDVOL' , NCNTFOR )
Local nQtdUni := GDFieldGet( 'DVF_QTDUNI' , NCNTFOR )
Local nPeso	  := GDFieldGet( 'DVF_PESO'   , NCNTFOR )
Local nPesoM3 := GDFieldGet( 'DVF_PESOM3' , NCNTFOR )
Local nValMer := GDFieldGet( 'DVF_VALMER' , NCNTFOR )
Local nBasSeg := GDFieldGet( 'DVF_BASSEG' , NCNTFOR )
Local cCodPro := GDFieldGet( 'DVF_CODPRO' , NCNTFOR )
Local nMetro3 := GDFieldGet( 'DVF_METRO3' , NCNTFOR )


Default lAtuVar := .F.


aTmp := StrToArray( aColsGrid[nLinha,1] , "-" )
cServic  := aTmp[1] //-- serviço
cTabFre  := aTmp[2] //-- Tabela de Frete
cTipTab  := aTmp[3] //-- Tipo da Tabela


//-- chama a TMSContrat caso seja alteração e o usuario nao tenha alterado nada na tela inicial.
If ALTERA .And. Len(aContrt) == 0
    aContrt := TMSContrat( cCliDev, cLojDev,, M->DT4_SERVIC,, M->DT4_TIPFRE,,,,,,,,,,,,,,,,M->DT4_CODNEG )
EndIf
lAjuste := Iif(aContrt[1 , 18]=="1",.T.,.F.)
nFatCub := aContrt[1,  2]
aPesCub := {}


//-- Calcula o peso cubado pelo percentual de cubagem informado no complemento do produto
nPerCub := TmsPerCub(GdFieldGet('DVF_CODPRO',NCNTFOR),cCliDev,cLojDev)
If	!Empty(nPerCub)
    nPeso := GdFieldGet('DVF_PESO',NCNTFOR)
    //GdFieldPut( 'DVF_FATCUB' ,0,NCNTFOR)
    //GdFieldPut( 'DVF_PESOM3' ,nPeso + ( nPeso * ( nPerCub / 100 ) ),NCNTFOR)
    //-- Calcula o peso cubado pelo fator de cubagem informado no contrato do cliente
ElseIf !Empty(nFatCub)
    nSeek := AScan(aCubagem,{|x| x[1] == GDFieldGet('DVF_CODPRO',NCNTFOR)})
    If	nSeek > 0
        nPQtdVol := AScan(aHeadDTE,{|x|x[2]=='DTE_QTDVOL'})
        nPAltura := AScan(aHeadDTE,{|x|x[2]=='DTE_ALTURA'})
        nPCompri := AScan(aHeadDTE,{|x|x[2]=='DTE_COMPRI'})
        nPLargur := AScan(aHeadDTE,{|x|x[2]=='DTE_LARGUR'})
        nPesoM3  := 0
        If	nPQtdVol>0 .And. nPAltura>0 .And. nPCompri>0 .And. nPLargur>0
            For n1Cnt := 1 To Len(aCubagem[nSeek,2])
                If !aCubagem[nSeek,2,n1Cnt,Len(aCubagem[nSeek,2,n1Cnt])] //--Delete
                    nPesoM3 += aCubagem[nSeek,2,n1Cnt,nPQtdVol] * aCubagem[nSeek,2,n1Cnt,nPAltura] * aCubagem[nSeek,2,n1Cnt,nPCompri] * aCubagem[nSeek,2,n1Cnt,nPLargur]

                        //-- Formato do vetor aPesCub
                        //-- [01] = Fil.Origem
                        //-- [02] = No.da Nota Fiscal
                        //-- [03] = Serie da Nota Fiscal
                        //-- [04] = Cliente Remetente
                        //-- [05] = Loja Cliente Remetente
                        //-- [06] = Produto
                        //-- [07] = Altura
                        //-- [08] = Largura
                        //-- [09] = Comprimento

                        AAdd(aPesCub,{	M->DT4_FILORI,'','',;
                                        M->DT4_CLIREM,M->DT4_LOJREM,GDFieldGet('DVF_CODPRO',NCNTFOR),; 
                                        aCubagem[nSeek,2,n1Cnt,nPAltura], aCubagem[nSeek,2,n1Cnt,nPLargur],aCubagem[nSeek,2,n1Cnt,nPCompri]})							  																						  
                EndIf
            Next n1Cnt
        EndIf
        nPesoM3 := nPesoM3 * nFatCub
                        
        aRet := TamSX3("DVF_PESOM3")
        If Len(CValToChar(Int(nPesoM3))) > aRet[1] - (aRet[2] + 1)
            MsgAlert("Problema no campo PesoM3 / Fator de Cubagem: " + CValToChar(nPesoM3) + SubStr(PesqPict('DVF','DVF_PESOM3'), 3), "Peso Cubado" )
            Return(.F.)
        EndIf
        //GdFieldPut( 'DVF_FATCUB' ,nFatCub ,NCNTFOR )
        //GdFieldPut( 'DVF_PESOM3' ,nPesoM3 ,NCNTFOR )
    EndIf
EndIf



If lTMSCFec
    aTipVei := {}

    nPosTipVei := Ascan( aHeaderDVT, { |x| AllTrim(x[2]) == 'DVT_TIPVEI' } )
    nPosQtdVei := Ascan( aHeaderDVT, { |x| AllTrim(x[2]) == 'DVT_QTDVEI' } )
    For n1Cnt := 1 To Len(aColsDVT)
        If !aColsDVT[n1Cnt][Len(aColsDVT[n1Cnt])]
            nSeek := AScan(aTipVei,{ |x| x[1] == aColsDVT[n1Cnt][nPosTipVei] })
            If	nSeek > 0
                aTipVei[nSeek,2] += aColsDVT[n1Cnt][nPosQtdVei]
            Else
                AAdd(aTipVei,{ aColsDVT[n1Cnt][nPosTipVei], aColsDVT[n1Cnt][nPosQtdVei] })
            EndIf
        EndIf
    Next
EndIf


//--	Ponto de Entrada que possibilita a alteracao do valor do frete.
//--	Cliente Devedor	- LTCLIDEV 
//--	Loja Devedor	- LTLOJDEV 
//--	Peso Cubado		- LTPESOM3
If lTM040CUB
    nPesoPto := ExecBlock( "TM040CUB",.F.,.F.,{cCliDev, cLojDev, nPesoM3, nPeso, M->DT4_TIPFRE, M->DT4_SERVIC, M->DT4_TIPTRA, M->DT4_SERTMS,M->DT4_CODNEG } )
    If ValType(nPesoPto) == "N"
        nPesoM3  := nPesoPto
    EndIf
EndIf

//-- Calculo do Frete...
aFrtAlt := {}
cSeqAlt := StrZero(0,Len( DVC->DVC_SEQTAB ))
aFrtAlt := TmsCalFret(	cTabfre	,;
                        cTipTab			,;
                        @cSeqAlt		,;
                        M->DT4_CDRORI	,;
                        M->DT4_CDRDES	,;
                        cCliDev			,;
                        cLojDev			,;
                        cCodPro			,;
                        M->DT4_SERVIC	,;
                        M->DT4_SERTMS	,;
                        M->DT4_TIPTRA	,;
                        aContrt[ 1, 1 ]	,;
                        aMsgErr			,;
                                        ,;
                        nValMer			,;
                        nPeso			,;
                        nPesoM3			,;
                        0				,;
                        nQtdVol			,;
                        0				,;
                        nBasSeg			,;
                        nMetro3			,;
                        0				,;
                        0				,;
                        0				,;
                        0				,;
                        .T.				,;
                        lCliGen			,;
                        lAjuste			,;
                        0				,;
                        nQtdUni			,;
                        0				,;
                        0				,;
                        0				,;
                        aValAux			,;
                        aTipVei			,;
                        M->DT4_DOCTMS   ,;
                        ,;
                        ,;
                        ,;
                        ,;
                        ,;
                        ,;
                        ,;
                        ,;
                        ,;
                        aPesCub			,;
                        ,;
                        M->DT4_CLIDEV	,;
                        M->DT4_LOJDEV	,;
                        ,;
                        "",; // Exclui TDA
                        IIF(Len(aPerfil)>=49,aPerfil[49],""),;
                        MyPosicione("SA1", 1, xFilial("SA1") + M->DT4_CLIREM + M->DT4_LOJREM, "A1_TDA"),;
                        MyPosicione("SA1", 1, xFilial("SA1") + M->DT4_CLIDES + M->DT4_LOJDES, "A1_TDA"),;
                        ,;
                        M->DT4_CLIDES,;
                        M->DT4_LOJDES,;
                        ,;
                        ,;
                        ,;
                        ,;
                        ,;
                        M->DT4_CODNEG,;
                        {},;
                        {},;
                        ,; //--lCbrCol
                        ,; //--lBlqCol
                        lInvOri )


nSeek := Ascan( aFrtAlt,{|x| x[3] == 'TF' })
cMsgErr := ""
If	Empty( nSeek ) .Or. Empty( aFrtAlt[ nSeek, 2 ] ) .Or. nSeek != Len(aFrtAlt) .Or. !Empty( aMsgErr)
    If !Empty( nSeek ) .And. Empty( aFrtAlt[ nSeek, 2 ] )
        AAdd(aMsgErr,{ 'Valor do Frete Zerado' ,'00',''})
    ElseIf nSeek != Len(aFrtAlt)
        AAdd(aMsgErr,{ 'Falha na linha totalizadora da composicao do frete' ,'00',''})
    EndIf

    For nX := 1 To Len(aMsgErr)
        cMsgErr += AllTrim(aMsgErr[ nX , 01 ]) //-- Mensagem de Erro
        cMsgErr += '#'
    Next nX

    aColsGrid[nLinha,Len(aHeaderGrid)] := AllTrim(cMsgErr) //-- Mensagem de Erro

    //-- Inicializa Teclas de Atalhos
    aFrtAlt := {}
    Return( .F. )
EndIf

cFilDes  := MyPosicione("DUY",1, xFilial("DUY") + M->DT4_CDRDES,"DUY_FILDES")

//-- Calcula impostos
TmsA040Imp( aFrtAlt, cCliDev, cLojDev, M->DT4_DOCTMS, M->DT4_TIPFRE, M->DT4_CDRDES, .T. , ,cFilDes, Tmsa040TCli(), , M->DT4_CDRORI, M->DT4_FILORI, Iif(M->DT4_INCISS=="1","S","N"), M->DT4_CLIREM, M->DT4_LOJREM, M->DT4_CLIDES, M->DT4_LOJDES, , ,M->DT4_TIPNFC , cCodPro )

//-- coloca o valor dos componentes indiduais.
For nX := 1 To Len(aFrtAlt)

    If aFrtAlt[ nX , 3 ] == 'TF'
        aColsGrid[nLinha,NVALLIQ] := aFrtAlt[ nX, 2 ] //-- Valor calculado total frete liquido
        aColsGrid[nLinha,NVALIMP] := aFrtAlt[ nX, 5 ] //-- Valor calculado do Imposto
        aColsGrid[nLinha,NVALTOT] := aFrtAlt[ nX, 6 ] //-- Valor calculado total frete Bruto (+imposto)

        If cTabCliGen == (cServic + cTabFre + cTipTab) //-- Realiza a comparação para saber se calculo da tabela do cliente generico
            aColsGrid[nLinha,Len(aHeaderGrid)] := cMV_CliGen + " - Tabela de Custo - Cliente Generico"   //-- Calculado com sucesso - codigo do cliente generico
        Else
            aColsGrid[nLinha,Len(aHeaderGrid)] := 'OK'    //-- Calculado com sucesso
        EndIf

        //-- Atualiza as variaveis utilizadas no padrao TMSA040.
        If lAtuVar
            nTValPas := aColsGrid[nLinha,NVALLIQ] := aFrtAlt[ nX, 2 ]
            nTValImp := aColsGrid[nLinha,NVALIMP] := aFrtAlt[ nX, 5 ] 
            nTValTot := aColsGrid[nLinha,NVALIMP] := aFrtAlt[ nX, 6 ] 
        EndIf

        Exit
    EndIf

    For nY := 1 To Len(aHeaderGrid)
        If (aFrtAlt[ nX , 1 ]  $  aHeaderGrid[nY]:CTITLE)
            aColsGrid[nLinha,nY] := aFrtAlt[ nX, 2 ] //-- Valor calculado componente
            Exit
        EndIf
    Next nY
Next nX

Return AClone(aFrtAlt)



//-- Funcao utiliza para ganhar performance.
Static Function MyPosicione(cAlias,nOrdem,cChave,cCampoRet)
Local nPos := 0
Local cAuxFil := cEmpAnt+cFilAnt+xFilial(cAlias)
Local nOrdAux := StrZero(nOrdem,2)
Local xRetorno

(cAlias)->( dbSetOrder(nOrdem) )

If ( nPos := aScan(aPosicione,{|x|x[1]+x[2]+x[3]+x[4]==cAuxFil+cAlias+nOrdAux+cChave}) ) > 0
    (cAlias)->( dbGoto(aPosicione[nPos, 5]) )
    xRetorno := &(cAlias+"->("+cCampoRet+")")
Else
	If	(cAlias)->(MsSeek(cChave)) 
		aAdd(aPosicione, { cAuxFil, cAlias, nOrdAux, cChave, (cAlias)->(Recno()) } )
	EndIf
	xRetorno := &(cAlias+"->("+cCampoRet+")")
EndIf

Return(xRetorno)



/*

Tabela de cores 
CLR_BLACK         // RGB( 0, 0, 0 )
CLR_BLUE           // RGB( 0, 0, 128 )
CLR_GREEN        // RGB( 0, 128, 0 )
CLR_CYAN          // RGB( 0, 128, 128 )
CLR_RED            // RGB( 128, 0, 0 )
CLR_MAGENTA    // RGB( 128, 0, 128 )
CLR_BROWN       // RGB( 128, 128, 0 )
CLR_HGRAY        // RGB( 192, 192, 192 )
CLR_LIGHTGRAY // RGB( 192, 192, 192 )
CLR_GRAY          // RGB( 128, 128, 128 )
CLR_HBLUE        // RGB( 0, 0, 255 )
CLR_HGREEN      // RGB( 0, 255, 0 )
CLR_HCYAN        // RGB( 0, 255, 255 )
CLR_HRED          // RGB( 255, 0, 0 )
CLR_HMAGENTA  // RGB( 255, 0, 255 )
CLR_YELLOW      // RGB( 255, 255, 0 )
CLR_WHITE        // RGB( 255, 255, 255 ) 

*/
