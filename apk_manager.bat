@echo off
chcp 65001

REM Script utilizado para realizar a instalação dos samples em múltiplos dispositivos conectados.

:: Captura o tempo inicial (horas, minutos, segundos)
for /f "tokens=1-4 delims=:., " %%a in ("%time%") do (
    set /a start_h=%%a, start_m=%%b, start_s=%%c
)

REM Definição de pastas
set SETUP_DIR=SETUP
set APK_DIR=%SETUP_DIR%\APKs
set LOGS_TEMP_DIR=%SETUP_DIR%\LOGS_TEMP
set LOGS_DIR=LOGS
set ADB_DIR=%SETUP_DIR%\ADB
set ADB_PATH=%ADB_DIR%\adb.exe

REM Verifica se o adb.exe existe, caso contrário, descompacta adb.zip
if not exist "%ADB_PATH%" (
    echo O arquivo adb.exe não foi encontrado. Descompactando adb.zip...
    if exist .\adb.zip (
        mkdir "%ADB_DIR%"
        tar -xf .\adb.zip --directory %ADB_DIR%
        if exist "%ADB_PATH%" (
            echo Descompactação concluída com sucesso.
        ) else (
            echo Falha ao descompactar adb.zip. Verifique o arquivo e tente novamente.
            exit /b 1
        )
    ) else (
        echo O arquivo adb.zip não foi encontrado. Interrompendo o script.
        exit /b 1
    )
) else (
   rem echo adb.exe encontrado em %ADB_PATH%.
)



REM Define os arquivos de log e erros
set INSTALLED_APKS=%LOGS_TEMP_DIR%\Listas\installed_apks.txt
set INSTALL_ERROR_APKS=%LOGS_TEMP_DIR%\install_error_apks.txt
set LOGCAT_INSTALL=%LOGS_TEMP_DIR%\Logcat\logcat_install.json
set BEFORE_INSTALL_LIST=%LOGS_TEMP_DIR%\Listas\before_install.txt
set AFTER_INSTALL_LIST=%LOGS_TEMP_DIR%\Listas\after_install.txt
set INSTALLED_PACKAGES=%LOGS_TEMP_DIR%\Listas\uninstall.txt

if not exist %SETUP_DIR% (
    mkdir %SETUP_DIR%
    echo Criando diretório de Logs: %SETUP_DIR%
)


if not exist %APK_DIR% (
    mkdir %APK_DIR%
    echo Criando diretório de APKs: %APK_DIR%
)


if not exist "%LOGS_TEMP_DIR%" (
    mkdir "%LOGS_TEMP_DIR%"
    echo Criando diretório de Logs temporários: %LOGS_TEMP_DIR%
)

if not exist "%LOGS_TEMP_DIR%\Listas" (
    mkdir "%LOGS_TEMP_DIR%\Listas"
    echo Criando diretório Listas: %LOGS_TEMP_DIR%\Listas%
)

if not exist "%LOGS_TEMP_DIR%\Logcat" (
    mkdir "%LOGS_TEMP_DIR%\Logcat"
    echo Criando diretório Logcat: %LOGS_TEMP_DIR%\Logcat%
)

if not exist "%LOGS_DIR%" (
    mkdir "%LOGS_DIR%"
    echo Criando diretório de Logs: %LOGS_DIR%
)

if not exist %ADB_DIR% (
    mkdir "%ADB_DIR%"
    tar -xf .\adb.zip --directory %ADB_DIR%
)


:: Verificar se existem dispositivos conectados
setlocal enabledelayedexpansion
set device_found=0

for /f "tokens=1 delims= " %%a in ('%ADB_PATH% devices') do (
    if "%%a"=="List" (
        rem Ignorar cabeçalho "List of devices attached"
    ) else if not "%%a"=="" (
        set "device_id=%%a"
        set device_found=1
        echo Dispositivo encontrado: !device_id!
    )
)

if "!device_found!"=="0" (
    echo Nenhum dispositivo conectado. Interrompendo o script.
    exit /b 1
)

:menu
echo.
echo ========================================
echo Menu de Gerenciamento de APKs
echo ========================================
echo 1) Instalar APKs
echo 2) Remover APKs
echo 3) Sair
echo.
choice /C 123 /M "Escolha uma opção: "

if %errorlevel% equ 1 (
    echo Iniciando instalação
) else if %errorlevel% equ 2 (
    call :DesinstalarAPKs
    exit /b
) else if %errorlevel% equ 3 (
    echo Saindo...
    exit /b
) else (
    echo Opção inválida. Tente novamente.
    goto menu
)

REM Verifica se existem APKs na pasta de instalação
dir "%APK_DIR%\*.apk" /b /s >nul 2>nul

if %errorlevel% equ 0 (
    echo A pasta %APK_DIR% contém arquivos .apk.

) else (
    echo A pasta %APK_DIR% não contém arquivos .apk.
    echo Script encerrado. 
    exit /b 1
)


REM Limpa o cache dos logs do sistema em cada dispositivo
for /f "skip=1 tokens=1" %%d in ('%ADB_PATH% devices') do (
    if NOT "%%d"=="List" (
        %ADB_PATH% -s %%d logcat -c
        %ADB_PATH% -s %%d logcat -b all -v color -d
    )
)

REM Apaga os arquivos no diretório de Logs temporário
del /s /q %LOGS_TEMP_DIR%\*.*


REM Gera a lista de pacotes instalados antes da instalação dos APKs para cada dispositivo
for /f "skip=1 tokens=1" %%d in ('%ADB_PATH% devices') do (
    if NOT "%%d"=="List" (
        %ADB_PATH% -s %%d shell pm list packages -f > %BEFORE_INSTALL_LIST%.%%d
    )
)


REM Percorre todos os arquivos APK na pasta e instala em cada dispositivo
for %%f in (%APK_DIR%\*.apk) do (
    for /f "skip=1 tokens=1" %%d in ('%ADB_PATH% devices') do (
        if NOT "%%d"=="List" (

            REM Verifica se o APK já está instalado
            REM %ADB_PATH% -s %%d shell pm list packages | findstr "%%~nf"
            REM if %errorlevel% neq 0 (
                                
                REM Executa instalação com paralelismo, cada comando é aberto em novo terminal. Parâmetro "/b" deixa em segundo plano.
                REM start /b "" %ADB_PATH% -s %%d install "%%f"

                REM Instala o APK no dispositivo %%d sem paralelismo. 
                %ADB_PATH% -s %%d install "%%f"

                REM Verifica se houve erro na instalação
                if errorlevel 1 (
                    echo ERRO no dispositivo %%d ao instalar %%f >> %INSTALL_ERROR_APKS%

                    REM Deleta o APK caso ocorra erro na instalação
                    REM del %%f /Q
                ) else (
                    echo SUCESSO no dispositivo %%d ao instalar %%f >> %INSTALLED_APKS%

                    REM Captura logs relacionados ao antivírus após a instalação
                    %ADB_PATH% -s %%d logcat *:D -d >> %LOGCAT_INSTALL%.%%d.json
                )
            ) else (
                echo O APK %%f já está instalado no dispositivo %%d.
            )
        )
    )
)

REM Gera a lista de pacotes instalados após a instalação dos APKs em cada dispositivo
for /f "skip=1 tokens=1" %%d in ('%ADB_PATH% devices') do (
    if NOT "%%d"=="List" (
        %ADB_PATH% -s %%d shell pm list packages -f > %AFTER_INSTALL_LIST%.%%d
    )
)

REM Compara as listas antes e depois para identificar pacotes instalados
for /f "skip=1 tokens=1" %%d in ('%ADB_PATH% devices') do (
    if NOT "%%d"=="List" (
        for /f "tokens=*" %%a in (%AFTER_INSTALL_LIST%.%%d) do (
            findstr /c:"%%a" %BEFORE_INSTALL_LIST%.%%d >nul
            if errorlevel 1 (
                echo %%a >> %INSTALLED_PACKAGES%.%%d
            )
        )
    )
)

REM Filtra o conteúdo dos arquivos INSTALLED_PACKAGES para manter somente o package name
REM Para que seja possível desinstalar os APKs depois com o script "Uninstall"

setlocal enabledelayedexpansion

for /f "skip=1 tokens=1" %%d in ('%ADB_PATH% devices') do (
    if NOT "%%d"=="List" (
        for /f "tokens=*" %%v in ('%ADB_PATH% -s %%d shell getprop ro.build.version.release') do (
            if "%%v"=="10" (
                for /f "tokens=3 delims==\" %%a in ('findstr /r "base.apk=" %INSTALLED_PACKAGES%.%%d') do (
                    echo %%a >> %INSTALLED_PACKAGES%.%%d.tmp
                )
            ) else (
                for /f "tokens=4 delims==\" %%a in ('findstr /r "base.apk=" %INSTALLED_PACKAGES%.%%d') do (
                    echo %%a >> %INSTALLED_PACKAGES%.%%d.tmp
                )
            )
        )
    move /y %INSTALLED_PACKAGES%.%%d.tmp %INSTALLED_PACKAGES%.%%d > nul
    copy %INSTALLED_PACKAGES%.%%d %LOGS_TEMP_DIR%\Listas\uninstall.txt > nul

    REM Conta o número de linhas no arquivo gerado usando delayed expansion
    for /f %%n in ('find /c /v "" ^< %INSTALLED_PACKAGES%.%%d') do (
        set LINES=%%n
    )

    REM Mostra o número de linhas com espaçamento
    echo O arquivo %INSTALLED_PACKAGES%.%%d tem !LINES! linhas.
    echo.
    )
 )      
   
endlocal

REM Captura todos os logs do sistema e salva em um arquivo para cada dispositivo
for /f "skip=1 tokens=1" %%d in ('%ADB_PATH% devices') do (
    if NOT "%%d"=="List" (
        %ADB_PATH% -s %%d logcat *:D -d > "%LOGS_TEMP_DIR%\Logcat\logcat.%%d.json"
    )
)


REM Formata a hora sem caracteres especiais
for /f "tokens=1-3 delims=:,." %%a in ("%time%") do set hora=%%a_%%b_%%c

REM Copia e renomeia a pasta de Logs incluindo a hora atual
xcopy "%LOGS_TEMP_DIR%" "%LOGS_DIR%\Logs_%hora%" /E /I /Q > nul

:: Captura o tempo final (horas, minutos, segundos)
for /f "tokens=1-4 delims=:., " %%a in ("%time%") do (
    set /a end_h=%%a, end_m=%%b, end_s=%%c
)

:: Calcula o tempo decorrido em segundos
set /a start_time=(%start_h% * 3600) + (%start_m% * 60) + %start_s%
set /a end_time=(%end_h% * 3600) + (%end_m% * 60) + %end_s%
set /a total_seconds=%end_time% - %start_time%

:: Corrige os valores negativos (se houver transição de hora ou minuto)
if %total_seconds% lss 0 (
    set /a total_seconds+=86400
)

:: Exibe o tempo decorrido
set /a total_minutes=%total_seconds% / 60
echo.
echo.
if %total_seconds% lss 60 (    
echo O tempo decorrido foi de %total_seconds% segundos.
) else (
echo O tempo decorrido foi de %total_minutes% minutos.
)
echo.
echo Script finalizado!
exit /b


:DesinstalarAPKs {
    setlocal enabledelayedexpansion

    REM Verifica se o arquivo existe
    if not exist "%INSTALLED_PACKAGES%" (
        echo Arquivo "%INSTALLED_PACKAGES%" não encontrado!
        exit /b 1
    )

    REM Loop sobre todos os dispositivos conectados
    for /f "skip=1 tokens=1" %%d in ('%ADB_PATH% devices') do (
        if NOT "%%d"=="List" (
            echo Desinstalando APKs no dispositivo %%d...

            REM Executa a desinstalacao em paralelo sem abrir nova janela
            start /b cmd /c (
                for /f "usebackq delims=" %%i in ("%INSTALLED_PACKAGES%.%%d") do (
                    %ADB_PATH% -s %%d uninstall %%i
                )
                echo Desinstalacao concluida no dispositivo %%d!
            )
        )
    )

    endlocal
    goto :eof
}