#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

/*/{Protheus.doc} CriandoDocumentoPDFeMesclando
Mesclando arquivos usando usando 
@type function
@author Rodrigo Araujo
@since 24/03/2024
/*/
User Function Exp0033()
	Local cDrive, cDir, cExt, cNome
	Local i:= 0
	Local cDestino  := ""
	Local cArquivos := ""
	Local aArquivos := {}
	Local cArgumento:= ""
	Local cMesclado := "Documento Mesclado.pdf"
	Local cSmartIni := GetRemoteIniName() //Pega o caminho do smartclient.exe para poder localizar o arquivo gswin64.exe
	Local cGsWin64  := "" //Local onde está o executável do Ghostscript
	Local cArgsBat  := ""
    Local oReport
	Local oFont12   := TFont():New("Arial",,13,,.F.,,,,,.F.,.F.)
	Local oFont14   := TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
    Local nAviso    := 0

    nAviso := Aviso("Mesclar documentos","Gerar arquivos PDF com Protheus e Mesclar os arquivos em um só" + CRLF + CRLF +;
                    "Neste exemplo irei criar 2 arquivos chamados:" + CRLF + CRLF +;
                    "'Documento Gerado pelo Protheus1.pdf' e 'Documento Gerado pelo Protheus2.pdf'" + CRLF + CRLF +;
                    "Ao Mesclar, o novo arquivo se chamará 'Documento Mesclado.pdf'",{"Continuar","Fechar"},2)
    If nAviso==2
        Return
    Endif
    
    SplitPath( cSmartIni, @cDrive, @cDir, @cNome, @cExt )
	cDir := IIF(Right(cDir,1)=="\", cDir, cDir + "\")
	cGsWin64 := cDrive+cDir + "gs\gswin64.exe"

	If !File(cGsWin64)
		MsgStop("O plugin GSWIN64.EXE não existe!","ATENÇÃO")
		Return
	Endif

	If File(cGsWin64) //localizar o arquivo gswin64.exe
		cDestino := tFileDialog( "", 'Selecione Pasta de Destino',, "C:\LocalData\Mesclar Aquivos\", .F.,  GETF_RETDIRECTORY  )
        cDestino := IIF(Right(cDestino,1)=="\", cDestino, cDestino + "\")

		If ExistDir(cDestino)

            /*Inicio - Gerando um documento em PDF*/
            //Arquivo 1
            oReport:= FWMSPrinter():New("Documento Gerado pelo Protheus1.pdf",6, .f., cDestino, .t.,.T.,,,.T.,.F.,,.F.,1)		
            oReport:SetResolution(70)
            oReport:SetPortrait()
            oReport:SetPaperSize( 9 ) 
            oReport:SetMargin(10, 10, 10, 10)		
            oReport:nDevice := IMP_PDF
            oReport:cPathPDF:= cDestino    

            oReport:Say(100, 050, "Visão geral do Ghostscript", oFont14) 
            oReport:Say(120, 050, "Ghostscript é um intérprete para a linguagem PostScript® e arquivos PDF . Ele está disponível sob a licença GNU", oFont12) 
            oReport:Say(140, 050, "GPL Affero ou licenciado para uso comercial pela Artifex Software, Inc. Ele está em desenvolvimento ativo há", oFont12)
            oReport:Say(160, 050, "mais de 30 anos e foi portado para vários sistemas diferentes durante esse período.", oFont12) 
            oReport:Say(180, 050, "Ghostscript consiste em uma camada de interpretação PostScript e uma biblioteca gráfica.", oFont12) 
            oReport:Print()

            //Arquivo 2
            oReport:= FWMSPrinter():New("Documento Gerado pelo Protheus2.pdf",6, .f., cDestino, .t.,.T.,,,.T.,.F.,,.F.,1)		
            oReport:SetResolution(70)
            oReport:SetPortrait()
            oReport:SetPaperSize( 9 ) 
            oReport:SetMargin(10, 10, 10, 10)		
            oReport:nDevice := IMP_PDF
            oReport:cPathPDF:= cDestino    

            oReport:Say(100, 050, "GitHub", oFont14) 
            oReport:Say(120, 050, "GitHub é uma plataforma de hospedagem de código-fonte e arquivos com controle de versão usando o Git.", oFont12) 
            oReport:Say(140, 050, "Ele permite que programadores, utilitários ou qualquer usuário cadastrado na plataforma contribuam", oFont12) 
            oReport:Say(160, 050, "em projetos privados e/ou Open Source de qualquer lugar do mundo.", oFont12) 
            oReport:Print()
            /*Fim*/

			cArquivos := TFileDialog( "Arquivos PDF (*.pdf)",'Selecione os arquivos',,'C:\LocalData\Mesclar Aquivos',.F.,GETF_MULTISELECT)
			aArquivos := Separa(cArquivos,";")

			//Preparando os argumentoos com os arquivos que serão mesclados
			For i := 1 To Len(aArquivos)
				cArgumento += CHR(34) + aArquivos[i]+ CHR(34) + " "
				cArgsBat += "%" + Alltrim(str(i+1)) + " "
			Next

            If Len(aArquivos) > 0
                //Criando o arquivo bat com a sintaxe para mesclar
                //MemoWrite( cDestino + "\mesclarpdf.bat", "@ECHO OFF" + CRLF + cGsWin64 + " -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=%1 -dBATCH %2 %3")
                //cArgsBat = Contem a quantidade de arquivos que serão mesclados
                MemoWrite( cDestino + "mesclarpdf.bat", "@ECHO OFF" + CRLF + cGsWin64 + " -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=%1 -dBATCH " + cArgsBat)

                If File(cDestino + "mesclarpdf.bat")
                    //Aqui eu executo o batch para que ele possa mescar os arquivos
                    //Coloco o CHR(34) antes e depois pois a pasta e o arquivo podem ter espaços e isso garante que o programa gswin64.exe irá ler os arquivos corretamente.
                    ShellExecute("open",;
                        CHR(34) + cDestino + "mesclarpdf.bat" + CHR(34),;
                        CHR(34) + cDestino + cMesclado + CHR(34) + " " + cArgumento,;
                        cDestino,2)

                    Sleep(1000) //aguardo alguns segundos antes de excluir os arquivos não mais necessarios
                    If File(cDestino + cMesclado)
                        fErase(cDestino + "mesclarpdf.bat")
                    Endif

                Endif
            Endif
		Endif

	Endif
Return
