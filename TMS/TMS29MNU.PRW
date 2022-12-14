#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS29MNU
Altera o menu para identificar a chamado da op??o pois a rotina ? MVC

@author Jose Luiz Pinheiro Junior
@since 24/10/22
@version 1.0
/*/
//-------------------------------------------------------------------
User Function TMS29MNU()             
Local nPosBut := 0

//-- Altera a Fun??o do padr?o para que se posso identificar o pagametro de chamada.
Do while (nPosBut := Ascan(aRotina,{|e| 'Tmsa029Lib' $ e[2] })) > 0
    aRotina[nPosBut][2] := STRTRAN(aRotina[nPosBut][2], "Tmsa029Lib","U_TM029M01")
Enddo

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} TM029M01
Realiza a chamada da fun??o do padra?o passando o parametro recebido.

@author Jose Luiz Pinheiro Junior
@since 24/10/22
@version 1.0
/*/
//-------------------------------------------------------------------
User Function TM029M01(uParam)
Static nOpc029

nOpc029 := uParam

Return Tmsa029Lib(uParam)



//-------------------------------------------------------------------
/*/{Protheus.doc} TM029PAR
Utilizado para devolver o conteudo do parametro.

@author Jose Luiz Pinheiro Junior
@since 24/10/22
@version 1.0
/*/
//-------------------------------------------------------------------
User Function TM029PAR()
Default nOpc029 := ""

Return nOpc029
