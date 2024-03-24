#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} Exp0033
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
	Local cMesclado := "arquivo-mesclado.pdf"
	Local cSmartIni := GetRemoteIniName() //Pega o caminho do smartclient.exe para poder localizar o arquivo gswin64.exe
	Local cGsWin64  := "" //Local onde está o executável do Ghostscript
	Local cArgsBat  := ""

	SplitPath( cSmartIni, @cDrive, @cDir, @cNome, @cExt )
	cDir := IIF(Right(cDir,1)=="\", cDir, cDir + "\")
	cGsWin64 := cDrive+cDir + "gs\gswin64.exe"

	If !File(cGsWin64)
		MsgStop("O arquivo GSWIN64.EXE não existe!","ATENÇÃO")
		Return
	Else
		cDestino := tFileDialog( "", 'Selecione Pasta de Destino',, "C:\LocalData\Mesclar Aquivos\", .F.,  GETF_RETDIRECTORY  )
        cDestino := IIF(Right(cDestino,1)=="\", cDestino, cDestino + "\")

		If ExistDir(cDestino)
			cArquivos := TFileDialog( "Arquivos PDF (*.pdf)",'Selecione os arquivos',,'C:\LocalData\Mesclar Aquivos',.F.,GETF_MULTISELECT)
			aArquivos := Separa(cArquivos,";")

			//Preparando os argumentoos com os arquivos que serão mesclados
			For i := 1 To Len(aArquivos)
				cArgumento += CHR(34) + aArquivos[i]+ CHR(34) + " "
				cArgsBat += "%" + Alltrim(str(i+1)) + " "
			Next

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
Return
