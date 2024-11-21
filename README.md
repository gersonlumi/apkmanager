# APK_MANAGER
Repositório contendo script para instalação e remoção de APKs em dispositivos Android.

Este é um script em formato "batch", deve ser executado em máquinas Windows. 

O Script possui o objetivo de instalar ou remover apks e produzir os logs necessários para análise.

O arquivo "adb.zip" deve ficar na mesma pasta que o arquivo "apk_manager.bat"

Ao executar o script pela primeira vez, ele irá criar as pastas necessárias e extrair o arquivo "adb.zip" para a pasta correta.

Dentro da pasta "SETUP/APKs" devem ser colocados os arquivos ".apk" que serão instalados nos dispositivos. É recomendável adicionar essa pasta nas
configurações de exclusão do Windows Defender.

Erros na instalação serão direcionados para um arquivo de log específico. APKs que falharam na instalação, podem ser removidos automaticamente pelo script na mesma hora, basta
remover o comentário da linha 183. 

Ao executar a instalação, o script produz também uma lista com os apks que foram instalados com sucesso. Essa lista é usada na função de remover os apks.

No repositório existe uma pasta com 900 APKs (divididos em 6 partes) infectados retirados do Dataset AndroZoo que podem ser usados nos testes.