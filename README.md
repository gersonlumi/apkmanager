
# APK_MANAGER  

Repositório contendo um script para instalação e remoção de APKs em dispositivos Android. 

Este projeto contém um **script em batch** desenvolvido para execução em sistemas operacionais **Windows**. Ele realiza a instalação e remoção de APKs, além de gerar logs detalhados para análise.  

## Funcionalidades  
- **Instalação de APKs:** Instale múltiplos APKs automaticamente em 1 ou mais dispositivos Android.  
- **Remoção de APKs:** Remova APKs instalados com base em listas geradas previamente.  
- **Geração de Logs:** Produz logs detalhados, incluindo erros e APKs instalados com sucesso.  
- **Compatibilidade com grandes volumes de dados:** Inclui suporte a pacotes grandes, como datasets com centenas de APKs.  

---

## Configuração  

1. **Pré-requisitos**  
   - Coloque o arquivo `adb.zip` na **mesma pasta** que o arquivo `apk_manager.bat`.  

2. **Primeira execução**  
   - Ao rodar o script pela primeira vez, ele:  
     - Criará as pastas necessárias.  
     - Extrairá o conteúdo do arquivo `adb.zip` automaticamente para a pasta correta.  

3. **Preparação de APKs**  
   - Adicione os arquivos `.apk` na pasta:  
     ```
     SETUP/APKs
     ```  
   - Recomenda-se **excluir essa pasta** da verificação do **Windows Defender** para evitar interferências.  

---

## Logs e Tratamento de Erros  

- **Logs de erros:**  
  - Erros durante a instalação serão registrados em um arquivo de log específico.  

- **APK com erro:**  
  - O script pode remover automaticamente APKs que falharam na instalação.  
  - Para habilitar essa funcionalidade, **remova o comentário da linha 183 no script**.  

---

## Resultado da Instalação  

- O script gera uma lista com os APKs instalados com sucesso.  
- Essa lista é usada para facilitar a **remoção posterior** dos APKs, se necessário.  

---

## Dataset para Testes  

No link abaixo é possível obter **900 APKs infectados** (divididos em 6 partes) para serem utilizados nos testes se necessário.
As amostras foram retiradas do dataset **AndroZoo**. Os filtros aplicados para obter os APKs foram:

- Período de Julho de 2022 a Julho de 2024.
- Detecção por no minimo 30 soluções de antivírus do serviço VirusTotal.

https://drive.google.com/drive/folders/1Phpi-Fb8oq3SN_nGJUzXzuHGdQrmZ2v-?usp=sharing

Senha para descompactar os arquivos: apkmanager

---

## Observações  

- Este projeto é recomendado para uso em ambientes de teste ou análise, devido à inclusão de APKs potencialmente maliciosos.  
