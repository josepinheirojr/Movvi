#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PRTOPDEF.CH"

#DEFINE cEOF Chr(13)+Chr(10)
STATIC cTitulo := "Integração Protheus x Parceiros"

/*/{Protheus.doc} MOVA005
//TODO Rotina principal para cad. [PAZ – Integração Protheus x Parceiro]
@author Jose Luiz Pinheiro JUnior
@type function
@since Nov/2021
@version 1.0
@return Nil
/*/
User Function MOVA005()
Local aArea       := GetArea()
Local oBrowse
Private cAlias 	:= "PAZ" 
Private aRotina	:= MenuDef() 


dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(1)) //-- PAZ_FILIAL+PAZ_ID
(cAlias)->(dbGotop())

dbSelectArea('PAZ')
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'PAZ' )
oBrowse:SetDescription( cTitulo )
oBrowse:AddLegend( "PAZ->PAZ_STATUS == '2' ", "BLUE" , "Processado c/ Sucesso")
oBrowse:AddLegend( "PAZ->PAZ_STATUS == '1' ", "GREEN", "Em Aberto (Aguardando Processamento)" )
oBrowse:AddLegend( "PAZ->PAZ_STATUS == '3' ", "RED"   , "Processado c/ Erro"  )

oBrowse:Activate()

RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
//TODO Função MenuDef   
@author Jose Luiz Pinheiro JUnior
@since Nov/2020 
@version 1.0
@return Array, aRot
@type static function
/*/
Static Function MenuDef()

Local aRot    := {}

ADD OPTION aRot TITLE "Pesquisar"    ACTION 'PesqBrw' 		  OPERATION 1 ACCESS 0	
ADD OPTION aRot TITLE 'Visualizar'   ACTION 'VIEWDEF.MOVA005' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRot TITLE 'Reprocessar'  ACTION 'U_MVREP005' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
//ADD OPTION aRot TITLE 'Alterar'      ACTION 'VIEWDEF.MOVA005' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
//ADD OPTION aRot TITLE 'Excluir'      ACTION 'VIEWDEF.MOVA005' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot


/*/{Protheus.doc} ModelDef
//TODO Função ModelDef   
@author Jose Luiz Pinheiro JUnior
@since Nov/2021
@version 1.0
@return Objeto, oModel
@type static function 
/*/
Static Function ModelDef() 
Local oModel 
Local oStruPAZ := FWFormStruct(1,"PAZ") 
	 
oModel:= MPFormModel():New("MD_ORACLEXPROTHEUS")  
oModel:SetDescription(cTitulo)    
oModel:addFields('PAZMASTER',,oStruPAZ)  

oModel:SetPrimaryKey({'PAZ_FILIAL', 'PAZ_ID' })	

Return oModel 

/*/{Protheus.doc} ViewDef
//TODO Função ViewDef   
@author Jose Luiz Pinheiro JUnior
@since Nov/2021
@version 1.0
@return Objeto, oView
@type static function
/*/
Static Function ViewDef() 
Local oModel := ModelDef() 
Local oStrPAZ:= FWFormStruct(2, 'PAZ')   
Local bBlock := {|| .T.}
Local oView 

oView := FWFormView():New()  
oView:SetModel(oModel)    
oView:AddField('FORM_CAB' , oStrPAZ,'PAZMASTER')  

oView:CreateHorizontalBox( 'CADPAZ', 100)
oView:SetOwnerView('FORM_CAB','CADPAZ')
oView:SetViewProperty('FORM_CAB' , 'SETCOLUMNSEPARATOR', {10})
	
oView:SetCloseOnOk( bBlock )
 	
Return oView

/*/{Protheus.doc} MVREP005
//TODO Função MVREP005   
@author Jose Luiz Pinheiro JUnior
@since Nov/2021  
@version 1.0
@return Objeto, oView
@type static function
/*/
User Function MVREP005() 
Local lPrepare := .F.
Local aEnvPAZ  := {}
Local lCont    := .F.

If (lPrepare := Type("cEmpAnt") == "U" .Or. Empty(cEmpAnt))
   //-- Prepara ambiente conf. orientação chamado
   PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'
EndIf

If PAZ->PAZ_STATUS == '3'
   lCont := .T.
ElseIf PAZ->PAZ_STATUS == '2'
   If MsgYesNo("Deseja reprocessar este registro com sucesso?")
      lCont := .T.
   EndIf
EndIf

If lCont .And. PAZ->PAZ_STATUS <> '1'
   aAdd(aEnvPAZ,{"PAZ_STATUS" ,"1"}) //-- Processado aguardando
   aAdd(aEnvPAZ,{"PAZ_TIPO"   ,PAZ->PAZ_TIPO})
   aAdd(aEnvPAZ,{"PAZ_ORIGEM" ,PAZ->PAZ_ORIGEM})
   aAdd(aEnvPAZ,{"PAZ_DESCRI" ,PAZ->PAZ_DESCRI})
   aAdd(aEnvPAZ,{"PAZ_MSG"    ,PAZ->PAZ_MSG})
   aAdd(aEnvPAZ,{"PAZ_CHAVE"  ,PAZ->PAZ_CHAVE}) //-- Chave para identificação do processo
   aAdd(aEnvPAZ,{"PAZ_EMAIL"  ,PAZ->PAZ_EMAIL})
   aAdd(aEnvPAZ,{"PAZ_IDREPR" ,PAZ->PAZ_ID})

   aPAZret := aClone(U_MVINCPAZ(aEnvPAZ))

   If aPAZRet[1]
      FwAlertSucces("Reprocessamento efetuado com sucesso para o ID:" + PAZ->PAZ_ID)
   Else
      FwAlertError("Reprocessamento não efetuado para o ID:" + PAZ->PAZ_ID)
   EndIf
Else
   FWAlertInfo("Reprocessamento só é liberado para registros processados anteriormente!") 
EndIf

Return Nil

/*/{Protheus.doc} MVINCPAZ
//TODO Função MVINCPAZ 
@author Jose Luiz Pinheiro JUnior
@since Nov/2021  
@version 1.0
@return Objeto, oView
@type static function
/*/
User Function MVINCPAZ(aInfo) 
Local aArea	      
Local cIDPAZ      
Local aRet        
Local aIntegr     
Local nCpoOrigem  
Local nCpoDescri  
Local nCpoMsg     
Local nI          
Local lRepr       
Local lPrepare := .F.

Default aInfo := {}

//-- Valida se o ambiente não está aberto.
If (lPrepare := Type("cEmpAnt") == "U" .Or. Empty(cEmpAnt) .Or. Select("SM0") <= 0 )
   //-- Prepara ambiente conf. orientação chamado
   PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'
EndIf

//-- Inicializa variáveis locais após a abertura de ambiente
aArea	      := GetArea()
cIDPAZ      := GetSx8Num("PAZ","PAZ_ID")
aRet        := {.F.,cIDPAZ,0}
aIntegr     := {}
nCpoOrigem  := 0
nCpoDescri  := 0
nCpoMsg     := 0
nI          := 0
lRepr       := IsInCallStack("U_MVREP005")

AAdd(aIntegr,{'005','Reversao Pagador Frete'})


If !Empty(aInfo)
   BEGIN TRANSACTION
      RecLock("PAZ",.T.)
         PAZ->PAZ_FILIAL := xFilial("PAZ")
         PAZ->PAZ_ID     := cIDPAZ
         For nI:=1 to len(aInfo)
            If lRepr .Or.  AllTrim(aInfo[nI,1]) != "PAZ_MSG" 
               PAZ->&(aInfo[nI,1])  := aInfo[nI,2]
            Else
               nCpoMsg := nI
            EndIf
         Next nI
         If !lRepr
            //Inclui o nome da interface
            If (nCpoOrigem := aScan(aInfo,{|x| x[1]	== 	'PAZ_ORIGEM'	}) ) > 0 //Obtem qual linha do array aInfo tem o conteúdo PAZ_ORIGEM (ex.: INT017)
               
               If (nCpoDescri := aScan(aIntegr,{|x| x[1]	$ 	aInfo[nCpoOrigem,2]	} ) ) > 0 //Obtem qual linha do array aIntegr tem vinculo com o conteúdo PAZ_ORIGEM (ex.: INT017 -> '017','Autônomos')
                  PAZ->PAZ_DESCRI := aIntegr[nCpoDescri,2] //Armazena o nome da interface no campo PAZ_DESCRI.
               EndIf

            EndIf
            If PAZ->PAZ_TIPO == "E"
               PAZ->&(aInfo[nCpoMsg,1])  := Decode64(Encode64(aInfo[nCpoMsg,2]))
            Else
               PAZ->&(aInfo[nCpoMsg,1])  := DecodeUTF8(aInfo[nCpoMsg,2], "cp1252")
            EndIf
         EndIf
         PAZ->PAZ_DATA   := Date()
         PAZ->PAZ_HORA   := Time()
         ConfirmSx8()
      PAZ->(MsUnLock())
   END TRANSACTION
   
   If cIDPAZ == Nil
      cIDPAZ := ""
   EndIf
   
   ConOut("[MOVA005] Inclusão realizada com sucesso! PAZ_ID: " + cIDPAZ + " - " + DtoC(Date())+" - "+Time())
   aRet[1] := .T.
   aRet[3] := PAZ->(Recno())

Else
   ConOut("[MOVA005] Informações não foram passadas para inclusão!")
   aRet[1] := .F.
EndIf

RestArea (aArea)
Return aRet

/*/{Protheus.doc} FLSCHPAZ
//TODO Função função para Schedule 
@author Jose Luiz Pinheiro JUnior
@since Jun/2020  
@version 1.0
@return Objeto, oView
@type static function
/*/
User Function MVSCHPAZ(xParSch) 
Local aArea	 := GetArea()

Default xParSch := {'01','01'}

//-- Processa todos os regitros em aberto para INT036
//U_INT36(xParSch)

//-- Processa todos os regitros em aberto para INT042
//U_INT42(xParSch)

RestArea (aArea)

Return Nil
