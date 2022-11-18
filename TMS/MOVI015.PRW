#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "PROTDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWCOMMAND.CH"


/*/-----------------------------------------------------------
{Protheus.doc} MOVI015()
Importacao da estrutura de Região

@author Jose Luiz Pinheiro Junior        
@since 05/10/2022
@version 1.0
-----------------------------------------------------------/*/
User Function MOVI015(nElem)

Local   aRet  := {}
Default nElem := 1

If nElem == 1
	If ParamBox({	{6,"Arquivo para importar",padr("",150),"",,"",90 ,.T.,"Arquivos","",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE/*+ GETF_RETDIRECTORY*/},;
					{3,"Dividir arquivo?",{0},{"0=Não Utiliza","1=550 Linhas","2=700 Linhas","3=850 Linhas"},160,,.F.};
					},"Importação de Estrutura de Região",@aRet)
		If aRet[2] == 1
			ExecImp( AllTrim(aRet[1]) )
		Else
			PartSE2TXT(AllTrim(aRet[1]),Iif(aRet[2]==2,550,Iif(aRet[2]==3,700,850)))
		EndIf
	EndIf
Else
	//-- Chama rotina de exportação de DUY
	ExecExp()

EndIf

Return



/*/-----------------------------------------------------------
PartSE2TXT()
Realiza quebra de tamanho do arquivo
@version 1.0
-----------------------------------------------------------/*/
Static Function PartSE2TXT(cArqTxt,nLinhas)
Local lContinua := File(cArqTxt)
Local cCabec := ""
Local cBuffer := ""
Local nHandle,nNewHandle
Local nNewFile := 0
Local nLin := 0


If lContinua
	nHandle := FT_FUSE(cArqTxt)
	lContinua := nHandle <> -1
EndIf

If lContinua 

	cArqTxt := StrTran(UPPER(cArqTxt),".CSV",".TXT")
	
	FT_FGOTOP()
	If !FT_FEOF()
		cCabec  := FT_FREADLN()
		FT_FSKIP()	
	EndIf
	While !FT_FEOF()	
		nLin++
	   	cBuffer  := FT_FREADLN()

		If nNewHandle == Nil .Or. (nLin % nLinhas) == 0
			If nNewHandle != Nil
				fClose(nNewHandle)
			EndIf
			nNewFile++
			nNewHandle   := fCreate(StrTran(UPPER(cArqTxt),".TXT","_"+StrZero(nNewFile,3)+".TXT"), 0)
			fWrite(nNewHandle, cCabec + CRLF)
		EndIf
		fWrite(nNewHandle, cBuffer + CRLF)

		FT_FSKIP()	
	EndDo
	
	fClose(nNewHandle)
	FT_FUSE()
EndIf

If !lContinua
	MsgAlert("Erro ao dividor arquivo")
Else
	MsgInfo("Sucesso ao dividir arquivo")
EndIf

Return



Static Function ExecImp(_cArqImp)
Local nRegua       := 0

Private bData      := {|cVar| SToD(cVar)}
Private bNum       := {|cVar| Val(StrTran(Alltrim(cVar), ",", "."))}

Private nTotal     := 0
Private nErro      := 0
Private nSucesso   := 0
Private cNaoCampos := Space(200)

Private oTotal     := Nil
Private oErro      := Nil
Private oSucesso   := Nil
Private oRegua     := Nil

Private oConfirma  := Nil
Private oLogErro   := Nil
Private oCancela   := Nil

Private cTitulo    := ""
Private cRotina    := "MOVI015"
Private cArqImp    := _cArqImp
Private cArqLog    := _cArqImp
Private nRotinaAut := 3
Private cAliasImp  := ""
Private aFieldsCab := Nil
Private aCabPos    := Nil
Private cFieldsQue := Nil

Private cFieldsLog := ""

Private bAuto      := &('{|x,y,z|TMSA115(x,y,z)}')
Private aLogErro   := {}

Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.
Private lAutoErrNoFile	:= .T.

cTitulo    := "Estrutura de Região"
cAliasImp  := "DUY"

ChkFile("CC2")
ChkFile("DUY")

DEFINE MSDIALOG oDlg TITLE cTitulo From 0,0 to 150,470 of oMainWnd PIXEL

@ 08, 10 Say "Esta rotina irá importar: " + cTitulo   SIZE 130,10 OF oDlg PIXEL

@ 18,  10 Say "Cpo Nao Importar: "  SIZE 50,10 OF oDlg PIXEL
@ 17,  58 MSGET oCampos VAR cNaoCampos  SIZE 150,08 OF oDlg   PIXEL

@ 30,  10 Say "Processado:"        SIZE 30,10 OF oDlg PIXEL
@ 29,  43 MSGET oTotal VAR nTotal  SIZE 32,08 OF oDlg PICTURE "@ER 999,999,999"  PIXEL When .F.

@ 30,  95 Say "Sucesso:"        SIZE 30,10 OF oDlg PIXEL
@ 29, 120 MSGET oSucesso VAR nSucesso  SIZE 32,08 OF oDlg PICTURE "@ER 999,999,999"  PIXEL When .F.

@ 30, 180 Say "Erro:"        SIZE 30,10 OF oDlg PIXEL
@ 29, 193 MSGET oErro VAR nErro  SIZE 32,08 OF oDlg PICTURE "@ER 999,999,999"  PIXEL When .F.

@ 48,010 METER oRegua VAR nRegua TOTAL 100 SIZE 215,8 OF oDlg NOPERCENTAGE PIXEL

oConfirma := TButton():New(63, 060,"Confirma"   , oDlg,{|| Importa()   } , 32,10,,oDlg:oFont,.F.,.T.,.F.,,.F.,,,.F.)
oLogErro  := TButton():New(63, 100,"Log Erros"  , oDlg,{|| LogErro(4)  } , 32,10,,oDlg:oFont,.F.,.T.,.F.,,.F.,,,.F.)
oCancela  := TButton():New(63, 140,"Fechar"     , oDlg,{|| oDlg:End()  } , 32,10,,oDlg:oFont,.F.,.T.,.F.,,.F.,,,.F.)

oLogErro:Disable()

ACTIVATE MSDIALOG oDlg CENTERED
Return



/*/-----------------------------------------------------------
Importa()
Realiza o processamento da importacao
@version 1.0
-----------------------------------------------------------/*/
Static Function Importa()
Local nI			:= 0
Local lRet			:= .T.
Local cBkpFil		:= cFilAnt
Local lHelpInDark	:= HelpInDark(.T.)
//Local cRootPath		:= GetSrvProfString( "Rootpath", "" )
Local cDir			:= Substr(cArqImp,1,RAT("\",Substr(cArqImp,1,Len(cArqImp)-1)))

LogErro(1) // Inicializo Log de Erros

SX3->(dbSetOrder(2)) // X3_CAMPO

If !(".TXT" $ Upper(cArqImp) .Or. ".CSV" $ Upper(cArqImp))
	cArqImp += "*.TXT"
EndIf

aFiles  := Directory( cArqImp, "D")

If Len(aFiles) == 0
	Alert("Arquivos "+ cArqImp + " não encontrados!")
	Return
EndIf 

For nI := 1 To Len(aFiles)
	cArqImp := cDir + aFiles[nI][1]
	If ! File(cArqImp)
		Alert(cArqImp + " não encontrado")
		Return
	Endif
	oRegua:Set(000)
	oRegua:Refresh()

	LogErro(2, "Importando arquivo: "+ cArqImp)
	LeTxt(cArqImp, { |cFile, cLinha, nLinha, nPercent, lRet|  lRet := TrataImport(cFile, cLinha, nLinha, nPercent, lRet)    })
	
	oRegua:Set(100)
	oRegua:Refresh()
	ProcessMessages()	
Next nI

SX3->(dbSetOrder(1)) // X3_ARQUIVO+X3_ORDEM

oLogErro:Enable()
oConfirma:Disable()
cFilAnt := cBkpFil

HelpInDark(lHelpInDark)

MsgInfo("Processamento concluído...")

Return




Static Function TrataImport(cFile, cLinha, nLinha, nPercent, lRet)
Static aFields
Static aKey

Local _nI		:= 0
Local aAuto    	:= {}
Local cField   	:= Nil
Local uField   	:= Nil
Local nLoop    	:= Nil
Local cErro    	:= Nil
Local nPos     	:= Nil
Local aLinha   	:= {}
//Local xDLinha  := ""
Local lSemFil  	:= .T.
Local cMvCodReg3 := SuperGetMv('MV_CGRPREG',.F.,"TMS120CDUF(__cEstReg)+__cCodIbge")

Local cGrpSup	 := ""
Local cGrpVen	 := ""

Local cChvDUY	:= ""
Local aCpoDUY	:= {"DUY_FILIAL","DUY_GRPVEN"}
Local nOpcx		:= 3

Local lContinua 	:= .T.
Local nSaveSx8Len 	:= GetSx8Len()

Private __cEstReg   := ''
Private __cFilReg   := ''
Private __cCodIbge   := ''

Default aFields := Nil

If Empty(cLinha) .Or. !lRet
	Return(.F.)
Endif

cLinha := StrTran(cLinha, '"', '')
cLinha := StrTran(cLinha, CHR(160), '')

oRegua:Set(nPercent)
SysRefresh()

If nLinha == 1
	aFields := {}
	aKey := {}
	cErro := ""
	cLinha  := Upper(StrTran(cLinha, " " , ""))

	If Right(cLinha, 1) # ";"
		cLinha += ";"
	Endif

	Do While (nPos := At(";", cLinha)) > 0
		cField := Substr(cLinha, 1, nPos - 1)
		cLinha := Substr(cLinha   , nPos + 1)
		If ! SX3->(dbSeek(cField))
			cErro += cField + " nao encontrado no dicionario." + chr(13)+chr(10)
			//LogErro(2, cErro)
			Conout(cErro)
		Endif
		Aadd(aFields, {cField, SX3->X3_TIPO, SX3->X3_TAMANHO})
		
		cFieldsLog += cField
	EndDo

	//-- Caso tenho erro de dicionarios nao processa mais.
	If !Empty(cErro)
		MsgStop(cErro, "Campo nao encontrado no Dicionario.")
		Final()
	EndIf


	For _nI := 1 To Len(aCpoDUY)
		If (nPos := aScan(aFields,{|x| AllTrim(x[1]) == AllTrim(aCpoDUY[_nI])})) > 0 
			aAdd(aKey,nPos)
		EndIf
	Next _nI


	If aFieldsCab # Nil
		aCabPos := {}
		For nLoop := 1 to Len(aFieldsCab)
			If (nPos := aScan(aFields, {|z| z[1] == aFieldsCab[nLoop]})) > 0
				Aadd(aCabPos, nPos)
			Else
				alert("Erro campo " + aFieldsCab[nLoop] + " nao existente no cabecalho")
			Endif
		Next
	Endif

	Return
Endif

cLinha := '{"' + StrTran(cLinha, ";", '", "') + '"}'
aLinha := &(cLinha)

If Len(aLinha) # Len(aFields)
	cErro := "Tamanho da linha detalhe (" + Alltrim(Str(Len(aLinha))) + ") diferente da linha cabeçalho (" + Alltrim(Str(Len(aFields))) + ") Linha: " + Alltrim(Str(nLinha))
	LogErro(2, cErro)
	nTotal+= 1 
	nErro += 1
	oTotal:Refresh()
	oErro:Refresh()
	Return(.T.)
Endif

For nLoop := 1 to Len(aLinha) 
	uField := aLinha[nLoop]
	If aFields[nLoop, 2] == "D"
		uField := Eval(bData, uField)
	ElseIf aFields[nLoop, 2] == "N"
		uField := Eval(bNum, uField)
	ElseIf aFields[nLoop, 2] == "C"
		uField := AllTrim(PadR(aLinha[nLoop],aFields[nLoop, 3]))
		uField := StrTran(uField, "|" , ";") //-- tratamento para retirar o pipe alterado na geração do csv para nao ocorrer alteração de layout.
		uField := A140IRemASC(uField) //-- NoAcento(Ansitooem(uField))
	Endif
	Aadd(aAuto, {aFields[nLoop, 1], uField, Nil})
	If Right(aFields[nLoop, 1], 7) == "_FILIAL" .And. cFilAnt != uField .And. !Empty(uField)
		cFilAnt := uField
	EndIf

	//-- Verifica se o campo Filial veio no arquivo, pois a FILIAL pertence a chave de pesquisa.
	If Right(aFields[nLoop, 1], 7) == "_FILIAL"
		lSemFil := .F.
	EndIf
Next


If (nPos := aScan(aAuto, {|z| Upper(Alltrim(z[1])) $ "DUY_EST"} )) > 0
	__cEstReg := aAuto[nPos][2]
EndIf

If (nPos := aScan(aAuto, {|z| Upper(Alltrim(z[1])) $ "DUY_CODMUN"} )) > 0
	__cCodIbge := aAuto[nPos][2]
EndIf

If (nPos := aScan(aAuto, {|z| Upper(Alltrim(z[1])) $ "DUY_GRPSUP"} )) > 0
	cGrpSup := aAuto[nPos][2]
EndIf


DUY->(DbSetOrder(1)) //-- DUY_FILIAL+DUY_GRPVEN
If !DUY->(MsSeek(xFilial("DUY")+ Padr(cGrpSup, Len(DUY->DUY_GRPVEN))  ))
	cErro := "Codigo da Região Superior [" + cGrpSup + "] nao encontrado. Linha: " + Alltrim(Str(nLinha))
	LogErro(2, cErro)
	nTotal+= 1 
	nErro += 1
	oTotal:Refresh()
	oErro:Refresh()
	lContinua := .F.
EndIf

If Empty(__cEstReg)
	cErro := "Conteudo Estado da Região [" + __cEstReg + "] nao encontrado. Linha: " + Alltrim(Str(nLinha))
	LogErro(2, cErro)
	nTotal+= 1 
	nErro += 1
	oTotal:Refresh()
	oErro:Refresh()
	lContinua := .F.
EndIf

If Empty(__cCodIbge)
	cErro := "Conteudo Codigo do IBGE da Região [" + __cCodIbge + "] nao encontrado. Linha: " + Alltrim(Str(nLinha))
	LogErro(2, cErro)
	nTotal+= 1 
	nErro += 1
	oTotal:Refresh()
	oErro:Refresh()
	lContinua := .F.
EndIf


If !lContinua
	Return(.T.)
EndIf

cGrpVen := ""
cChvDUY := Iif(lSemFil,xFilial("DUY"),"")
nPos := aScan(aAuto, {|z| Upper(Alltrim(z[1])) $ "DUY_GRPVEN"} )
If nPos > 0
	cGrpVen := aAuto[nPos][2]
	aEval(aKey,{|x,y| cChvDUY += PadR(aAuto[x][2],Len(DUY->(&(aAuto[x][1]))))})
else
	cGrpVen := &(cMvCodReg3)
	Aadd(aAuto,{"DUY_GRPVEN" , cGrpVen ,NIL})
	cChvDUY += PadR(cGrpVen , Len(DUY->DUY_GRPVEN))
EndIf

If aFieldsCab == Nil
	lMsErroAuto     := .F.
	lMsHelpAuto     := .T.
	lAutoErrNoFile	:= .T.
	lContinua 		:= .T.
	nOpcx			:= 3

	While (nPos := aScan(aAuto, {|z| Empty(z[2]) .Or. Upper(Alltrim(z[1])) $ Upper(Alltrim(cNaoCampos))})) > 0
		aDel(aAuto, nPos)
		aSize(aAuto, Len(aAuto) - 1)
	EndDo

	DUY->(DbSetOrder(1)) //-- DUY_FILIAL+DUY_GRPVEN
	If !Empty(cGrpVen)
		lContinua := !(DUY->(MsSeek(cChvDUY)))
	EndIf

	If !lContinua 
		nOpcx := 4 //-- Alteração
	EndIf

	BeginTran() 

	MsExecAuto({|x,y,z|Tmsa115(x,y,z)},aAuto,nOpcx)
	While (GetSx8Len() > nSaveSx8Len)
		If !lMsErroAuto
			ConfirmSX8()
		Else
			RollBackSX8()
		Endif
	EndDo

	CheckErro(nLinha)

	EndTran() 

	MsUnLockAll()
Endif

DbCommitAll()
Return(.T.)




/*/-----------------------------------------------------------
LogErro()
Realiza a gracao do arquivo de erro
@version 1.0
-----------------------------------------------------------/*/
Static Function LogErro(nAcao, cMsg) // nAcao=1 ->Cria/Inicializa | nAcao=2 Adiciona mensagem | nAcao =3 Fecha Arquivo | nAcao = 4 Abre no notepad
Static cNameLogFile
Static cFileName
Static nLogHandle

Local cDirTMP		:= AllTrim(GetTempPath()) //-- Diretorio temporario do Windows

default cNameLogFile:= Nil
default cFileName 	:= Nil
default nLogHandle	:= Nil


If cNameLogFile == Nil .Or. nAcao == 1
	cNameLogFile := NameLogFile()
	cFileName    := "LogCarga_" + cRotina +"_"+ AllTrim(StrTran(Time(),":","")) + ".TXT"
	cNameLogFile += cFileName

	nLogHandle   := fCreate(cNameLogFile, 0)
	fWrite(nLogHandle, "Log de Erros em " + Dtoc(Date()) + " - " + Time() + " Hs." + CRLF + ;
                       "Importação de "   + cTitulo + CRLF + ;
                       "Arquivo "         + cArqImp + CRLF + ;
                       "Tabela "          + RetSqlName(cAliasImp) + CRLF + CRLF)
	fClose(nLogHandle)
	Return
Endif

If nAcao == 2 .And. cMsg <> Nil
	nLogHandle := FOpen(cNameLogFile,2)
	fSeek(nLogHandle,0,2)
	If nLogHandle > 0         
		fWrite(nLogHandle, CRLF + cMsg + CRLF)
		fClose(nLogHandle)
	Endif
Endif

If nAcao == 3
//	fClose(nLogHandle)
Endif

If nAcao == 4
//	fClose(nLogHandle)
	LogErro(2, CRLF + "Fim do processamento em " + Dtoc(Date()) + " - " + Time() + " Hs.")
	fErase(cDirTMP + cFileName)
	CpyS2T( cNameLogFile, cDirTMP, .T. )   // Copia arquivo do Server para o Remote
	WinExec( "Notepad.exe " + cDirTMP + cFileName)
Endif

Return



Static Function NameLogFile()
Local cDirFile := GetSrvProfString( "StartPath", "" )

cDirFile := cDirFile + If(Right(cDirFile, 1) == "\", "", "\")
Return(cDirFile)



Static Function CheckErro(nLinha)
Local cErro := Nil
nTotal ++

If lMsErroAuto
	nErro ++
	cErro := "Erro na Linha: " + Alltrim(Str(nLinha)) + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	cFileLog := NomeAutoLog()                                  
	aEval(GetAutoGRLog(), {|z| cErro += z + Chr(13) + Chr(10)})
	LogErro(2, cErro)
	Disarmtransaction()
Else
	nSucesso ++
Endif

oTotal:Refresh()
oErro:Refresh()
oSucesso:Refresh()
Return



/*/-----------------------------------------------------------
LeTXT()
Realiza a leitura do arquivo TXT
@version 1.0
-----------------------------------------------------------/*/
Static Function LeTXT(cFile, bBlock)
Local nBuf	   := 16 * 1024  // 16K
Local nHdl	   := fOpen(cFile, 0)
Local nTam	   := fSeek(nHdl, 0, 2)
Local nLin	   := 0
Local nLido    := 0
Local nPos     := Nil
Local cBuffer  := ""
Local lLeuTudo := .F.
Local cLinha   := ""
Local nPercent := 0
Local lRet	   := .T.

fSeek(nHdl, 0)
While nLido < nTam
	If Len(cBuffer) < nBuf .And. ! lLeuTudo
		cBuffer  += fReadStr(nHdl, nBuf)
		lLeuTudo := fSeek(nHdl, 0, 1) = nTam
	Endif
	nPos     := At(Chr(13) + Chr(10), cBuffer)
	cLinha   := Substr(cBuffer, 1, nPos - 1)
	nLin     ++
	nLido    += Len(cLinha) + 2 // Assumo Chr(13)+Chr(10) no final da linha
	nPercent := Min(80, (nLido * 100 / nTam) + 1) + 20
	Eval(bBlock, cFile, cLinha, nLin, nPercent, lRet)
	If !lRet
		Exit
	EndIf

	cBuffer := Substr(cBuffer, nPos + 2)
Enddo
fClose(nHdl)

Return(lRet)




/*/{Protheus.doc} ExecExp
Função utilizada para exportar estrutura de região
@author Jose Luiz Pinheiro Junior        
@since 03/11/2022
@version 1.0
/*/
Static Function ExecExp()
Local cQuery 		:= ""
Local cPerg  		:= "MOVI015E" 
Local aItem			:= {}
Local i				:= 0
Local nI 			:= 0
Local aStru 		:= DUY->(dbStruct())
                           
Private cAlias 		:= GetNextAlias()
Private Titulo  	:= "Estrutura de Região - " + DToC(Date())
Private aCabEx		:= {}
Private aItenXcel	:= {}

AjustaSX1( cPerg )
Pergunte(cPerg, .T.)

If MsgYesNo('Deseja iniciar o processo de exportação da Estrutura de Região?')
	cQuery := ""
	// Adiciona os campos que existirem no DT6 na matriz de campos a serem selecionados
	aEval(aStru,{|e| If(DUY->(FieldPos(e[1])) > 0 , cQuery += ","+AllTrim(e[1]), Nil)})
	cQuery := "SELECT " + SubStr(cQuery,2)
	cQuery += "  FROM "+RetSqlName("DUY")+ " DUY "
	cQuery += " WHERE DUY.DUY_FILIAL = '" + xFilial("DUY") + "'"
	cQuery += "   AND DUY_GRPVEN BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQuery += "   AND DUY_EST    BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cQuery += "   AND DUY_GRPSUP BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
	cQuery += "   AND DUY_CDRCOL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "

	cQuery += " AND DUY.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY " + SqlOrder(DUY->(IndexKey(1)) )
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
	For nI := 1 to Len(aStru)
		If aStru[nI,2] != 'C'
			TCSetField(cAlias, aStru[nI,1], aStru[nI,2],aStru[nI,3],aStru[nI,4])
		Endif
	Next
	(cAlias)->(dbGoTop())

	AADD(aStru, {"  " ,"C", 01, 0})
	aItenXcel := {}
	Do While !(cAlias)->(Eof())	
			
		//Exporta para excel!
		aItem := Array(Len(aStru))
		
		For i := 1 to Len(aStru)
			If i == Len(aStru)  // Coluna de compatibilizacao com a abertura no EXCEL
				aItem[i] := ' '//CHR(160)
			ElseIf aStru[i][2] == "C"
				aItem[i] := CHR(160)+(cAlias)->&(aStru[i][1])
			ElseIf aStru[i][2] == "D"
				aItem[i] := If(!Empty((cAlias)->&(aStru[i][1])), DTOC((cAlias)->&(aStru[i][1])) , "")
			Else
				aItem[i] := (cAlias)->&(aStru[i][1])
			EndIf
		Next i
			
		AADD(aItenXcel,aItem)
		aItem := {}

		(cAlias)->(dbSkip())
	Enddo
Else
	Return
EndIf
(cAlias)->(DbCloseArea())

MsgRun("Favor Aguardar.....", "Exportando os Registros",{||DlgToExcel({{"GETDADOS",titulo,aStru,aItenXcel}})})

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

U_DLM_PSx1( { cPerg, "01","Codigo Região De ?" 			,"Codigo Região De" 		,"Codigo Região De" 		,"mv_ch1","C",06	,0,0,"G","","DUY" 		,""		,"","mv_par01" })
U_DLM_PSx1( { cPerg, "02","Codigo Região Ate ?" 		,"Codigo Região Ate ?"		,"Codigo Região Ate ?"		,"mv_ch2","C",06    ,0,0,"G","","DUY"  		,""  	,"","mv_par02" })
U_DLM_PSx1( { cPerg, "03","Estado De ?" 				,"Estado De ?" 				,"Estado De ?" 				,"mv_ch3","C",02    ,0,0,"G","","12"  		,""  	,"","mv_par03" })
U_DLM_PSx1( { cPerg, "04","Estado Ate ?" 				,"Estado Ate ?" 			,"Estado Ate ?" 			,"mv_ch4","C",02    ,0,0,"G","","12"  		,""  	,"","mv_par04" })
U_DLM_PSx1( { cPerg, "05","Grupo Superior De ?" 		,"Grupo Superior De ?" 		,"Grupo Superior De ?" 		,"mv_ch5","C",06	,0,0,"G","","DUY"	 	,""     ,"","mv_par05" })
U_DLM_PSx1( { cPerg, "06","Grupo Superior Ate ?" 		,"Grupo Superior Ate ?" 	,"Grupo Superior Ate ?" 	,"mv_ch6","C",06	,0,0,"G","","DUY"	 	,""     ,"","mv_par06" })
U_DLM_PSx1( { cPerg, "07","Regiao Coligada De ?" 		,"Regiao Coligada De ?" 	,"Regiao Coligada De ?" 	,"mv_ch7","C",06	,0,0,"G","","DUY1"		,""     ,"","mv_par07" })
U_DLM_PSx1( { cPerg, "08","Regiao Coligada Ate ?" 		,"Regiao Coligada Ate ?" 	,"Regiao Coligada Ate ?" 	,"mv_ch8","C",06	,0,0,"G","","DUY1"		,""     ,"","mv_par08" })

//PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,;
//                            cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,;
//                           cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

RestArea(aArea)

Return Nil
