#ifdef SPANISH
	#define STR0001 "Este programa imprimira las Cotizaciones.           "
	#define STR0002 "                                                    "
	#define STR0003 "Cotizacion Flete "
	#define STR0004 "A Rayas"
	#define STR0005 "Administracion"
	#define STR0006 "Imprimiendo Cotizacion de Flete."
	#define STR0007 "*** ANULADO POR EL OPERADOR ***"
	#define STR0008 "Sucursal.....: "
	#define STR0009 "Numero.......: "
	#define STR0010 "Fch Cotizac..: "
	#define STR0011 "Fch Validez..: "
	#define STR0012 "Telefono.....: "
	#define STR0013 "Contacto...: "
	#define STR0014 "Remitente....: "
	#define STR0015 "Destinatario.: "
	#define STR0016 "Deudor.......: "
	#define STR0017 "Destino......: "
	#define STR0018 "Peso Real....: "
	#define STR0019 "Peso Cubico...: "
	#define STR0020 "Producto.....: "
	#define STR0021 "Bultos.......: "
	#define STR0022 "Embalaje......: "
	#define STR0023 "Valor Mercad.: "
	#define STR0024 "Tipo de Flete.: "
	#define STR0025 "Tipo Tabla...: "
	#define STR0026 "Descuento.....: "
	#define STR0027 " C L I E N T E "
	#define STR0028 " C A R G A "
	#define STR0029 " F L E T E   C O M B I N A D O "
	#define STR0030 " O B S E R V A C I O N E S "
	#define STR0031 "TOTAL DE FLETE"
	#define STR0032 "Operador  : "
	#define STR0033 "Unitizadores..."
	#define STR0034 "Archivo Solicitante:"
	#define STR0035 "Contacto......:"
#else
	#ifdef ENGLISH
		#define STR0001 "This program will print the Quotations.             "
		#define STR0002 "                                                    "
		#define STR0003 "Freight Quotation"
		#define STR0004 "Z.form"
		#define STR0005 "Management"
		#define STR0006 "Printing The Freight Quotation."
		#define STR0007 "*** CANCELED BY OPERATOR ***"
		#define STR0008 "Branch......:  "
		#define STR0009 "Number.......: "
		#define STR0010 "Quotation date:"
		#define STR0011 "Validity Date: "
		#define STR0012 "Telephone....: "
		#define STR0013 "Contact...: "
		#define STR0014 "Sender.......: "
		#define STR0015 "Addressee....: "
		#define STR0016 "Debtor.......: "
		#define STR0017 "Destination...: "
		#define STR0018 "Real Weight...: "
		#define STR0019 "Cb.Weight.....: "
		#define STR0020 "Product.......: "
		#define STR0021 "Volumes.......: "
		#define STR0022 "Packaging.....: "
		#define STR0023 "Goods Value...: "
		#define STR0024 "Freight Type.: "
		#define STR0025 "Table Type...: "
		#define STR0026 "Discount......: "
		#define STR0027 " C U S T O M E R "
		#define STR0028 " L O A D "
		#define STR0029 " A G R E E D  F R E I G H T "
		#define STR0030 " N O T E S "
		#define STR0031 "FREIGHT TOTAL"
		#define STR0032 "Attendant: "
		#define STR0033 "Unitizers.....: "
		#define STR0034 "Cd.Solicitante:"
		#define STR0035 "Contato......:"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este programa irá imprimir as cotacoes.             ", "Este programa ira imprimir as Cotacoes.             " )
		#define STR0002 "                                                    "
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Cotação De Frete", "Cotacao de Frete" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Imprimindo A Cotação De Frete.", "Imprimindo a Cotacao de Frete." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "*** cancelado pelo operador ***", "*** CANCELADO PELO OPERADOR ***" )
		#define STR0008 "Filial.......: "
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Número.......: ", "Numero.......: " )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Data cotação.: ", "Data Cotacao.: " )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Data validade: ", "Data Validade: " )
		#define STR0012 "Telefone.....: "
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Contacto...: ", "Contato...: " )
		#define STR0014 "Remetente....: "
		#define STR0015 "Destinatario.: "
		#define STR0016 "Devedor......: "
		#define STR0017 "Destino.......: "
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Peso real.....: ", "Peso Real.....: " )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Peso cubado...: ", "Peso Cubado...: " )
		#define STR0020 "Produto.......: "
		#define STR0021 "Volumes.......: "
		#define STR0022 "Embalagem.....: "
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Valor mercad..: ", "Valor Mercad..: " )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Tipo do frete.: ", "Tipo do Frete.: " )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Tipo tabela..: ", "Tipo Tabela..: " )
		#define STR0026 "Desconto......: "
		#define STR0027 If( cPaisLoc $ "ANG|PTG", " c l i e n t e ", " C L I E N T E " )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", " c a r g a ", " C A R G A " )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", " f r e t e   c o m b i n a d o ", " F R E T E   C O M B I N A D O " )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", " o b s e r v a ç õ e s ", " O B S E R V A C O E S " )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Total De Frete", "TOTAL DE FRETE" )
		#define STR0032 "Atendente: "
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Paletes..: ", "Unitizadores..: " )
		#define STR0034 "Cd.Solicitante:"
		#define STR0035 "Contato......:"
	#endif
#endif
