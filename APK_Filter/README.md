
# APK_FILTER 

Esta pasta contém um script em bash para efetuar pesquisas no Dataset AndroZoo. 

## Funcionalidades  
- **Seleção das amostras:** É possível filtrar os apks presentes no arquivo do Dataset AndroZoo.  
- **Download das amostras:** Após executar o processo de seleção, é possível efetuar o download das amostras filtradas.  
- **Geração de Logs:** Produz logs detalhados das amostras que foram selecionadas. 

---

## Configuração  

1. **Pré-requisitos** 
   - Deixe a estrutura de pastas da forma que foi clonada. Outras pastas necessárias serão criadas automaticamente após a execução do script.

   - É necessário obter uma **API Key** para efetuar o download das amostras - Coloque ela na linha 21 do script - https://androzoo.uni.lu/access

   - Dentro da pasta  **SETUP** é necessário colocar o arquivo do Dataset - https://androzoo.uni.lu/static/lists/latest_with-added-date.csv.gz.

   - Uma versão do Dataset (Agosto de 2024) pode ser encontrada neste link: https://drive.google.com/drive/folders/1Phpi-Fb8oq3SN_nGJUzXzuHGdQrmZ2v-

2. **Execução**  
  Ao rodar o script, ele irá requisitar algumas informações, para todas elas existem valores padrão que são configurados nas linhas 24 a 30 do script.  

     - Nome do arquivo gzip - Nome do arquivo do Dataset.

     - Quantidade mínima de AntiVírus 
     - Quantidade máxima de AntiVírus
    
  Os valores acima representam o número de antivírus que identificou determinada amostra como malware. Detalhes desse processo de avaliação podem ser obtidos através da documentação do Dataset. 

     - Data inicial (aaaa-mm)
     - Data final (aaaa-mm)

As datas acima representam o período que as amostras foram inseridas no Dataset.

     - Tamanho mínimo para os APKs (MB)
     - Tamanho máximo para os APKs (MB)

Os valores acima servem para limitar os tamanho das amostras que você deseja obter.


Após os valores preenchidos, o script irá efetuar a pesquisa dentro do arquivo, isso pode demorar alguns minutos. 
Ao fim da pesquisa, será mostrado na tela o número de amostras identificadas e também aparecerá a opção de efetuar o download das amostras.

---

## Logs/Resultados

- **Resultados:**  
 - Após a execução o script irá criar uma pasta chamada **PESQUISAS** e dentro dela outra pasta contendo os resultados.
 - Cada nova pesquisa é salva em uma pasta própria, o nome de cada pasta é baseado nos filtros.

---

## Observações  

- Este projeto é recomendado para uso em ambientes de teste ou análise, devido à inclusão de APKs potencialmente maliciosos.  
