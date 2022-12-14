#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "PROTDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWCOMMAND.CH"


/*/-----------------------------------------------------------
{Protheus.doc} MOVI010()
Importacao de Dados Contratos de Clientes

@author Jose Luiz Pinheiro Junior        
@since 05/10/2022
@version 1.0
-----------------------------------------------------------/*/
User Function MOVI010(nElem)

Local   aRet  := {}
Default nElem := 1

If ParamBox({	{6,"Arquivo para importar",padr("",150),"",,"",90 ,.T.,"Arquivos","",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE/*+ GETF_RETDIRECTORY*/},;
				{3,"Dividir arquivo?",{0},{"0=N?o Utiliza","1=550 Linhas","2=700 Linhas","3=850 Linhas"},160,,.F.};
				},"Importa??o de Contratos do Clientes",@aRet)
	If aRet[2] == 1
		ExecImp( AllTrim(aRet[1]) )
	Else
		PartSE2TXT(AllTrim(aRet[1]),Iif(aRet[2]==2,550,Iif(aRet[2]==3,700,850)))
	EndIf
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
Private cRotina    := "MOVI010"
Private cArqImp    := _cArqImp
Private cArqLog    := _cArqImp
Private nRotinaAut := 3
Private cAliasImp  := ""
Private aFieldsCab := Nil
Private aCabPos    := Nil
Private cFieldsQue := Nil

Private cFieldsLog := ""

Private aLogErro   := {}

Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.
Private lAutoErrNoFile	:= .T.

cTitulo    := "Contrato do Clientes"
cAliasImp  := "AAM"

ChkFile("AAM")
ChkFile("DDA")
ChkFile("DDC")
ChkFile("DT9")
ChkFile("SA1")


DEFINE MSDIALOG oDlg TITLE cTitulo From 0,0 to 150,470 of oMainWnd PIXEL

@ 08, 10 Say "Esta rotina ir? importar: " + cTitulo   SIZE 130,10 OF oDlg PIXEL

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
	Alert("Arquivos "+ cArqImp + " n?o encontrados!")
	Return
EndIf 

For nI := 1 To Len(aFiles)
	cArqImp := cDir + aFiles[nI][1]
	If ! File(cArqImp)
		Alert(cArqImp + " n?o encontrado")
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

MsgInfo("Processamento conclu?do...")

Return




Static Function TrataImport(cFile, cLinha, nLinha, nPercent, lRet)
Static aFields
Static aKey

Local n1Cnt     := 0
Local aAuto    	:= {}
Local cField   	:= Nil
Local uField   	:= Nil
Local nLoop    	:= Nil
Local cErro    	:= Nil
Local nPos     	:= Nil
Local aLinha   	:= {}
//Local xDLinha  := ""
Local lSemFil  	:= .T.

Local cCodCli	:= ""
Local cLojCli	:= ""
Local aContrG   := {}
Local cContrG   := ''

Local cCodNeg   := ""
Local cServic   := ""
Local cTabFre   := ""
Local cTipTab   := ""

Local cNewContrat := ""  //Armazena o Nr do Novo Contrato
Local bSeek  := {|| DDC->(MsSeek(xFilial("DDC")+AAM->AAM_CONTRT))}
Local bWhile := {|| DDC->(!Eof()) .And. DDC->DDC_FILIAL + DDC->DDC_NCONTR == xFilial("DDC") + AAM->AAM_CONTRT}

Local lContinua 	:= .T.
Local nSaveSx8Len 	:= GetSx8Len()

Default aFields := Nil

If Empty(cLinha) .Or. !lRet
	Return(.F.)
Endif

cLinha := StrTran(cLinha, '"', '')

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

	//For _nI := 1 To Len(aCpoAAM)
	//	If (nPos := aScan(aFields,{|x| AllTrim(x[1]) == AllTrim(aCpoAAM[_nI])})) > 0 
	//		aAdd(aKey,nPos)
	//	EndIf
	//Next _nI
	
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
	cErro := "Tamanho da linha detalhe (" + Alltrim(Str(Len(aLinha))) + ") diferente da linha cabe?alho (" + Alltrim(Str(Len(aFields))) + ") Linha: " + Alltrim(Str(nLinha))
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
		uField := StrTran(uField, "|" , ";") //-- tratamento para retirar o pipe alterado na gera??o do csv para nao ocorrer altera??o de layout.
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


//Pesquisa se possui contrato ativo para o cliente e coloca final de vigencia.
nPos := aScan(aAuto, {|z| Upper(Alltrim(z[1])) $ "AAM_CODCLI"} )
cCodCli := aAuto[nPos][2]

nPos := aScan(aAuto, {|z| Upper(Alltrim(z[1])) $ "AAM_LOJA"} )
cLojCli := aAuto[nPos][2]

//-- guarda servico, tabela, tipo para o novo contrato
nPos := aScan(aAuto, {|z| Upper(Alltrim(z[1])) $ "AAM_XCDNEG"} )
cCodNeg   := aAuto[nPos][2]

nPos := aScan(aAuto, {|z| Upper(Alltrim(z[1])) $ "AAM_XSERVI"} )
cServic   := aAuto[nPos][2]

nPos := aScan(aAuto, {|z| Upper(Alltrim(z[1])) $ "AAM_XTBFRE"} )
cTabFre   := aAuto[nPos][2]

nPos := aScan(aAuto, {|z| Upper(Alltrim(z[1])) $ "AAM_XTPTAB"} )
cTipTab   := aAuto[nPos][2]


SA1->(DbSetOrder(1)) //-- A1_FILIAL+A1_COD+A1_LOJA
If !SA1->(MsSeek( xFilial("SA1") + cCodCli + cLojCli ))
	cErro := "Codigo do Cliente [" + cCodCli + cLojCli +"] nao encontrado. Linha: " + Alltrim(Str(nLinha))
	LogErro(2, cErro)
	nTotal+= 1 
	nErro += 1
	oTotal:Refresh()
	oErro:Refresh()
	lContinua := .F.
EndIf


DDB->(DbSetOrder(1)) //-- DDB_FILIAL+DDB_CODNEG
If !DDB->(MsSeek( xFilial("DDB") + cCodNeg ))
	cErro := "Codigo da Negociacao [" + cCodNeg +"] nao encontrado. Linha: " + Alltrim(Str(nLinha))
	LogErro(2, cErro)
	nTotal+= 1 
	nErro += 1
	oTotal:Refresh()
	oErro:Refresh()
	lContinua := .F.
EndIf


DC5->(DbSetOrder(1)) //-- DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
If !DC5->(MsSeek( xFilial("DC5") + cServic ))
	cErro := "Codigo do Servico [" + cServic +"] nao encontrado. Linha: " + Alltrim(Str(nLinha))
	LogErro(2, cErro)
	nTotal+= 1 
	nErro += 1
	oTotal:Refresh()
	oErro:Refresh()
	lContinua := .F.
EndIf


DTL->(DbSetOrder(1)) //-- DTL_FILIAL+DTL_TABFRE+DTL_TIPTAB
If !DTL->(MsSeek( xFilial("DTL") + cTabFre + cTipTab ))
	cErro := "Codigo da Tabela de Frete [" + cTabFre + cTipTab + "] nao encontrado. Linha: " + Alltrim(Str(nLinha))
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


cNContr := ''
aContrG := TMSContrat( cCodCli , cLojCli , dDatabase, , .F. ,"3" , .F. , ,,,,,,,,,,,,,,"")

//-- Coloca fim de vigencia no contrato para cria??o de um novo
If !Empty(aContrG) 
	cContrG := aContrG[1,1]
	AAM->(DbSetOrder(1)) //-- AAM_FILIAL+AAM_CONTRT
	AAM->(MsSeek(xFilial("AAM") + cContrG))

	RecLock("AAM",.F.)
	AAM->AAM_FIMVIG := (dDataBase - 1)
	AAM->(MsUnlock())

	DDC->(DbSetOrder(1)) //-- DDC_FILIAL+DDC_NCONTR+DDC_ITEM
	If Eval(bSeek)
		While Eval(bWhile)
			RecLock("DDC",.F.)
			DDC->DDC_FIMVIG := (dDataBase - 1)
			DDC->(MsUnlock())
			DDC->(DbSkip())
		EndDo
	EndIf
EndIf

//cChvAAM := Iif(lSemFil,xFilial("AAM"),"")
//aEval(aKey,{|x,y| cChvAAM += PadR(aAuto[x][2],Len(AAM->(&(aAuto[x][1]))))})

If aFieldsCab == Nil
	lMsErroAuto     := .F.
	lMsHelpAuto     := .T.
	lAutoErrNoFile	:= .T.

	cNewContrat := GetSX8Num( "AAM", "AAM_CONTRT" )  //Armazena o Nr do Novo Contrato

	lContinua := .T.
	AAM->(DbSetOrder(1)) //-- AAM_FILIAL+AAM_CONTRT

	While (nPos := aScan(aAuto, {|z| Empty(z[2]) .Or. Upper(Alltrim(z[1])) $ Upper(Alltrim(cNaoCampos))})) > 0
		aDel(aAuto, nPos)
		aSize(aAuto, Len(aAuto) - 1)
	EndDo

	BeginTran() 

	//-- Realiza a Inclusao do Contrato.
	RegToMemory("AAM",.T.)
	Aeval(aAuto,{| e | M->&( e[1] ) := e[2] })
	If lSemFil
		M->AAM_FILIAL := xFilial("AAM")
	EndIf

	M->AAM_CONTRT := cNewContrat
	M->AAM_INIVIG := dDataBase
	RecLock("AAM",  .T. )
	For n1Cnt := 1 TO FCount()
		If Type("M->"+FieldName(n1Cnt)) <> "U"                     
			FieldPut(n1Cnt,M->&(FieldName(n1Cnt)))
		EndIf
	Next n1Cnt
	AAM->(MsUnlock())

	DDA->(DbSetOrder(1)) //-- DDA_FILIAL+DDA_NCONTR+DDA_CODNEG+DDA_ITEM
	RegToMemory("DDA",.T.)

	M->DDA_NCONTR := cNewContrat
	M->DDA_CODNEG := cCodNeg
	M->DDA_ITEM	  := StrZero(1, TamSx3("DDA_ITEM")[1] )
	M->DDA_SERVIC := cServic
	M->DDA_TABFRE := cTabFre
	M->DDA_TIPTAB := cTipTab

	RecLock("DDA",  .T. )
	For n1Cnt := 1 TO FCount()
		If Type("M->"+FieldName(n1Cnt)) <> "U"                     
			FieldPut(n1Cnt,M->&(FieldName(n1Cnt)))
		EndIf
	Next n1Cnt
	DDA->(MsUnlock())


	RegToMemory("DDC",.T.)
	M->DDC_NCONTR := cNewContrat
	M->DDC_CODNEG := cCodNeg
	M->DDC_ITEM	  := StrZero(1, TamSx3("DDA_ITEM")[1] )
	M->DDC_INIVIG := dDataBase
	M->DDC_TPCONT := "1" //-- Vitalicia

	RecLock("DDC",  .T. )
	For n1Cnt := 1 TO FCount()
		If Type("M->"+FieldName(n1Cnt)) <> "U"                     
			FieldPut(n1Cnt,M->&(FieldName(n1Cnt)))
		EndIf
	Next n1Cnt
	DDC->(MsUnlock())
	lMsErroAuto := .F.

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
                       "Importa??o de "   + cTitulo + CRLF + ;
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
