#!/bin/bash

# Função para validar se a data está no formato YYYY-MM
validate_date() {
    if ! date -d "$1-01" "+%Y-%m" &>/dev/null; then
        echo "Erro: Data inválida: $1. Use o formato YYYY-MM."
        exit 1
    fi
}

# Função para validar se o valor é numérico
validate_number() {
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo "Erro: Valor inválido (deve ser numérico): $1"
        exit 1
    fi
}

# Função para validar se um arquivo existe
validate_file() {
    if [[ ! -f "$1" ]]; then
        echo "Erro: Arquivo não encontrado: $1"
        exit 1
    fi
}

# Início do script principal
# Validar variáveis de entrada

# Exemplo de variáveis a serem validadas
input_file="input.txt"      # Substituir pela variável real do script
begindate="2023-01"         # Substituir pela variável real do script
enddate="2023-12"           # Substituir pela variável real do script
min_avs="5"                 # Substituir pela variável real do script
max_avs="10"                # Substituir pela variável real do script
tamanhominapks="1000"       # Substituir pela variável real do script
tamanhomaxapks="50000"      # Substituir pela variável real do script

# Validar cada variável
validate_file "$input_file"
validate_date "$begindate"
validate_date "$enddate"
validate_number "$min_avs"
validate_number "$max_avs"
validate_number "$tamanhominapks"
validate_number "$tamanhomaxapks"

# Prosseguir com o script apenas após as validações passarem
echo "Todas as entradas foram validadas com sucesso. Continuando o script..."