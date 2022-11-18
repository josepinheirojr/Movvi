//-- ATENCAO!! pode deixar todos xtranslate comentados ou apenas um deles.. nunca deixar dois translates ativos..


#xtranslate ConOut(<uVar>) => U_LogInt(<uVar>,.T.,"LOGINT\" + cArqLog)
//-- troca todos os Conout's para LOGINTYYYYMMDD.CSV

//#xtranslate ConOut(<uVar>) => U_LogInt(<uVar>,.F.,"LOGINT\" + cArqLog)
// Mantém funcionalidade original do Conout nas integrações

//#xtranslate ConOut(<uVar>) => Nil // Desliga todos os conouts
// desliga todos os conouts