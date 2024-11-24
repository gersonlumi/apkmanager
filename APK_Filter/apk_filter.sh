#!/bin/bash

# Verifica se os comandos necessários estão disponíveis
for cmd in wget zcat awk cut wc grep read shuf xargs mkdir parallel; do
    if ! command -v $cmd &> /dev/null; then
        echo "Erro: O comando '$cmd' não está instalado. Por favor, instale-o e tente novamente."
        exit 1
    fi
done

# Função para ler variáveis com um valor padrão
function read_var() {
    local prompt=$1
    local default=$2
    local var
    read -p "$prompt (Default: $default): " var
    echo ${var:-$default}
}

# ApiKey deve ser adquirida no site do AndroZoo
APIKEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Inputs Default
inputdefault="./SETUP/latest_with-added-date.csv.gz"
dataini_default="2022-07"
datafin_default="2024-07"
min_antivirus_default="25"
max_antivirus_default="30"
tamanhomin_default="0"
tamanhomax_default="100"

# Lê as variáveis
echo
input=$(read_var "Digite o nome do arquivo gzip" $inputdefault)
echo
min_avs=$(read_var "Digite a quantidade mínima de AntiVírus" $min_antivirus_default )
echo
max_avs=$(read_var "Digite a quantidade máxima de AntiVírus" $max_antivirus_default )
echo
begindate=$(read_var "Digite a data inicial (aaaa-mm)" $dataini_default)
echo
enddate=$(read_var "Digite a data final (aaaa-mm)" $datafin_default)
echo
tamanhominapks=$(read_var "Digite o tamanho mínimo para os APKs (MB)" $tamanhomin_default)
echo
tamanhomaxapks=$(read_var "Digite o tamanho máximo para os APKs (MB)" $tamanhomax_default )
echo


tamanhomin=$tamanhominapks
tamanhomax=$tamanhomaxapks
multiplicador=1000000
tamanhominapks=$((tamanhominapks * multiplicador))
tamanhomaxapks=$((tamanhomaxapks * multiplicador))

# Arquivos com a lista de apks gerado pela pesquisa do zcat
lista_sha256="SHA256.csv"
lista_completa="Completa.csv"
lista_pkgname="PKGNAME.csv"
lista_sha256_pkgname="SHA256_PKGNAME.csv"
lista_stores="Lojas.csv"

# Função para efetuar o filtro na lista usando processamento paralelo
# Função para efetuar o filtro na lista usando processamento paralelo
function process_data() {
     # Converte a data para o formato desejado
formatted_begindate=$(date -d "$begindate-01" '+%b%y' | sed 's/.*/\u&/') # Converte para formato Jan20
formatted_enddate=$(date -d "$enddate-01" '+%b%y' | sed 's/.*/\u&/') # Converte para formato Jun24

# Pasta de destino dos APKs com datas formatadas
    workfolder="./PESQUISAS/${formatted_begindate}_${formatted_enddate}/${min_avs}_${max_avs}AVs/${lojas}/${tamanhomin}_${tamanhomax}MB"
    apksfolder=$workfolder/apks/
    local filter="$1"
    mkdir -p $apksfolder
    
    # Medir o tempo de execução do zcat e do processamento
    start_time=$(date +%s)

    # Processamento paralelo com awk usando parallel
    zcat $input | grep -v ',snaggamea' | \
    parallel --pipe --block 20M \
    "awk -F, -v minsize=$tamanhominapks -v maxsize=$tamanhomaxapks -v min_avs=$min_avs -v max_avs=$max_avs -v begindate=$begindate -v enddate=$enddate '$filter'" \
    > ${workfolder}/${lista_completa}

    end_time=$(date +%s)
    elapsed_time=$((end_time - start_time))

    cut -d',' -f12 ${workfolder}/${lista_completa} > ${workfolder}/${lista_stores}
    cut -d',' -f1 ${workfolder}/${lista_completa} > ${workfolder}/${lista_sha256}
    cut -d',' -f6 ${workfolder}/${lista_completa} > ${workfolder}/${lista_pkgname}
    cut -d',' -f1,6 ${workfolder}/${lista_completa} > ${workfolder}/${lista_sha256_pkgname}
    
    line_count=$(wc -l < ${workfolder}/${lista_sha256})

    echo "Foram encontrados $line_count APKs em $elapsed_time segundos"
    
}

# Menu de seleção para lojas
echo "Escolha as lojas de origem das amostras"
echo
select sn in \
    "Todas" \
    "Exceto_LojasChinesas (anzhi, appchina, mi.com, angeeks, hiapk)" \
    "Somente_LojasChinesas" \
    "Somente_GooglePlayStore (play.google.com)"; do
    echo
    case $sn in
        Todas )
            lojas=TodasLojas
            process_data '{if ($5 >= minsize && $5 <= maxsize && $8 >= min_avs && $8 <= max_avs && $11 >= begindate && $11 <= enddate) print}'
            break;;
        "Exceto_LojasChinesas (anzhi, appchina, mi.com, angeeks, hiapk)" )
            lojas=Exceto_LojasChinesas
            process_data '{if ($12 !~ /anzhi|appchina|mi\.com|angeeks|hiapk/ && $5 >= minsize && $5 <= maxsize && $8 >= min_avs && $8 <= max_avs && $11 >= begindate && $11 <= enddate) print}'
            break;;
        "Somente_LojasChinesas" )
            lojas=Somente_LojasChinesas
            process_data '{if ($12 ~ /^(anzhi|appchina|mi\.com|angeeks|hiapk)$/ && $5 >= minsize && $5 <= maxsize && $8 >= min_avs && $8 <= max_avs && $11 >= begindate && $11 <= enddate) print}'
            break;;
        "Somente_GooglePlayStore (play.google.com)" )
            lojas=GooglePlayStore
            process_data '{if ($12 ~ /play\.google\.com/ && $5 >= minsize && $5 <= maxsize && $8 >= min_avs && $8 <= max_avs && $11 >= begindate && $11 <= enddate) print}'
            break;;
    esac
done

echo
echo "Salvar esta pesquisa?"
select sn in "Sim" "Não"; do
    case $sn in
        Sim)
            mv $workfolder ${workfolder}_${line_count}
            break;;            
        Não)
            rm -rf "${workfolder}"
            exit;;
    esac
done


echo "Efetuar o download dos APKs agora?"
select sn in "Sim" "Não"; do
    case $sn in
        "Sim")
            workfolder="${workfolder}_${line_count}"
            apksfolder=$workfolder/apks/
            # Criar a pasta de destino se não existir
            mkdir -p "$apksfolder"
            
            # Número de arquivos para baixar
            read -p "Quantos APKs deseja baixar aleatoriamente? " num_apks

            # Defina o número de downloads simultâneos
            num_parallel_downloads=18

            # Arquivo para registrar os APKs baixados com sucesso
            output_file="${workfolder}/apks_baixados.csv"

            # Use xargs para executar o wget em paralelo e registrar os downloads bem-sucedidos
            shuf -n "$num_apks" "${workfolder}/${lista_sha256_pkgname}" | xargs -P "$num_parallel_downloads" -I {} bash -c '
                line="{}"
                sha256=$(echo "$line" | awk -F, "{print  \$1}")
                url="https://androzoo.uni.lu/api/download?apikey='$APIKEY'&sha256=$sha256"
                if wget --retry-on-http-error=502,503 -N --content-disposition -P "'$apksfolder'" "$url"; then
                    echo "$line" >> "'$output_file'"
                fi
            '
            break;;
        "Não")
            echo "Operação Finalizada."
            break;;
    esac
done
