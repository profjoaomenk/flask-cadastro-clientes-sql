#!/bin/bash

set -euo pipefail


# ==========================================================
# CONFIGURAÇÕES
# ==========================================================

RESOURCE_GROUP="rg-flask-clientes"
APP_SERVICE_PLAN="plan-flask-clientes"
RUNTIME="PYTHON:3.14"
SKU="F1"
SQL_DATABASE="clientes"
IP_START="0.0.0.0"
IP_END="255.255.255.255"
SQL_FILE="sql/01-criar-tabela.sql"

#
# Recupera as Variáveis de Ambiente (Padrão Terminal Bash)
#
LOCATION="${LOCATION:-}"
APP_NAME="${APP_NAME:-}"
SQL_USERNAME="${SQL_USERNAME:-}"
SQL_PASSWORD="${SQL_PASSWORD:-}"
SQL_SERVER="${SQL_SERVER:-}"

#
# Validação das Variáveis de Ambiente (Padrão Terminal Bash)
#
if [ -z "$LOCATION" ]; then
    echo "ERRO: LOCATION não foi definida"
    exit 1
fi

if [ -z "$APP_NAME" ]; then
    echo "ERRO: APP_NAME não foi definida"
    exit 1
fi

if [ -z "$SQL_USERNAME" ]; then
    echo "ERRO: SQL_USERNAME não foi definida"
    exit 1
fi

if [ -z "$SQL_PASSWORD" ]; then
    echo "ERRO: SQL_PASSWORD não foi definida"
    exit 1
fi

if [ -z "$SQL_SERVER" ]; then
    echo "ERRO: SQL_SERVER não foi definida"
    exit 1
fi

# ==========================================================
# INSTALAR SQLCMD
# ==========================================================

echo
echo "=================================================="
echo "VERIFICANDO SQLCMD"
echo "=================================================="

if command -v sqlcmd >/dev/null 2>&1; then

    echo "sqlcmd já está instalado"

    sqlcmd --version

else

    echo "sqlcmd não encontrado."
    echo "Instalando sqlcmd..."

    # ------------------------------------------------------
    # Azure Cloud Shell utiliza Azure Linux.
    # Instalação através do instalador oficial da Microsoft
    # ------------------------------------------------------

    curl -L \
        https://aka.ms/download-msodbcsql \
        -o /tmp/msodbcsql.tar.gz

    echo
    echo "Instalando ferramentas SQL da Microsoft..."

    # Instalação do sqlcmd moderno através do pacote oficial.
    curl -L \
        https://github.com/microsoft/go-sqlcmd/releases/latest/download/sqlcmd-linux-amd64.tar.bz2 \
        -o /tmp/sqlcmd.tar.bz2

    mkdir -p /tmp/sqlcmd

    tar -xjf /tmp/sqlcmd.tar.bz2 \
        -C /tmp/sqlcmd

    cp /tmp/sqlcmd/sqlcmd /usr/local/bin/sqlcmd

    chmod +x /usr/local/bin/sqlcmd

    echo
    echo "sqlcmd instalado"

    sqlcmd --version

fi


# ==========================================================
# RESOURCE GROUP
# ==========================================================

echo
echo "=================================================="
echo "1. RESOURCE GROUP"
echo "=================================================="

az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output table


# ==========================================================
# AZURE SQL SERVER
# ==========================================================

echo
echo "=================================================="
echo "2. AZURE SQL SERVER"
echo "=================================================="

if az sql server show \
    --name "$SQL_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    >/dev/null 2>&1; then

    echo "SQL Server já existe"

else

    echo "Criando SQL Server..."

    az sql server create \
        --name "$SQL_SERVER" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --admin-user "$SQL_USERNAME" \
        --admin-password "$SQL_PASSWORD" \
        --output table

fi


# ==========================================================
# AZURE SQL DATABASE
# ==========================================================

echo
echo "=================================================="
echo "3. AZURE SQL DATABASE"
echo "=================================================="

if az sql db show \
    --name "$SQL_DATABASE" \
    --server "$SQL_SERVER" \
    --resource-group "$RESOURCE_GROUP" \
    >/dev/null 2>&1; then

    echo "Banco de dados já existe"

else

    echo "Criando banco de dados..."

    az sql db create \
        --name "$SQL_DATABASE" \
        --server "$SQL_SERVER" \
        --resource-group "$RESOURCE_GROUP" \
        --service-objective Basic \
        --output table

fi


# ==========================================================
# FIREWALL
# ==========================================================

echo
echo "=================================================="
echo "4. FIREWALL AZURE SQL"
echo "=================================================="


az sql server firewall-rule create \
    --resource-group "$RESOURCE_GROUP" \
    --server "$SQL_SERVER" \
    --name CloudShell \
    --start-ip-address "$IP_START" \
    --end-ip-address "$IP_END" \
    --output table


# ==========================================================
# PERMITIR SERVIÇOS AZURE (Fins demostrativos)
# ==========================================================

echo
echo "=================================================="
echo "5. FIREWALL - SERVIÇOS AZURE"
echo "=================================================="

az sql server firewall-rule create \
    --resource-group "$RESOURCE_GROUP" \
    --server "$SQL_SERVER" \
    --name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0 \
    --output table


# ==========================================================
# STRING DE CONEXÃO PARA SQLCMD
# ==========================================================

SQL_SERVER_FQDN="${SQL_SERVER}.database.windows.net"


# ==========================================================
# CRIAR TABELA
# ==========================================================

echo
echo "=================================================="
echo "6. CRIANDO TABELA CADASTRO"
echo "=================================================="


if [ ! -f "$SQL_FILE" ]; then

    echo "ERRO: arquivo $SQL_FILE não encontrado"

    exit 1

fi


sqlcmd \
    -S "$SQL_SERVER_FQDN" \
    -d "$SQL_DATABASE" \
    -U "$SQL_USERNAME" \
    -P "$SQL_PASSWORD" \
    -C \
    -i "$SQL_FILE"


echo
echo "Tabela cadastro criada/verificada"


# ==========================================================
# APP SERVICE PLAN
# ==========================================================

echo
echo "=================================================="
echo "7. APP SERVICE PLAN"
echo "=================================================="

if az appservice plan show \
    --name "$APP_SERVICE_PLAN" \
    --resource-group "$RESOURCE_GROUP" \
    >/dev/null 2>&1; then

    echo "App Service Plan já existe"

else

    az appservice plan create \
        --name "$APP_SERVICE_PLAN" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku "$SKU" \
        --is-linux \
        --output table

fi


# ==========================================================
# WEB APP
# ==========================================================

echo
echo "=================================================="
echo "8. WEB APP"
echo "=================================================="

if az webapp show \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    >/dev/null 2>&1; then

    echo "Web App já existe"

else

    az webapp create \
        --name "$APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --plan "$APP_SERVICE_PLAN" \
        --runtime "$RUNTIME" \
        --output table

fi


# ==========================================================
# APPLICATION SETTINGS
# ==========================================================

echo
echo "=================================================="
echo "9. VARIÁVEIS DE AMBIENTE DO WEB APP"
echo "=================================================="

az webapp config appsettings set \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings \
        SCM_DO_BUILD_DURING_DEPLOYMENT=true \
        SQL_SERVER="$SQL_SERVER_FQDN" \
        SQL_DATABASE="$SQL_DATABASE" \
        SQL_USERNAME="$SQL_USERNAME" \
        SQL_PASSWORD="$SQL_PASSWORD"


# ==========================================================
# STARTUP COMMAND
# ==========================================================

echo
echo "=================================================="
echo "10. STARTUP COMMAND"
echo "=================================================="

az webapp config set \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --startup-file "gunicorn --bind=0.0.0.0 app:app"


# ==========================================================
# CRIAR ZIP
# ==========================================================

echo
echo "=================================================="
echo "11. EMPACOTANDO APLICAÇÃO"
echo "=================================================="

rm -f app.zip

zip -r app.zip . \
    -x ".git/*" \
    -x ".venv/*" \
    -x "__pycache__/*" \
    -x "*.pyc" \
    -x "app.zip"


# ==========================================================
# DEPLOY
# ==========================================================

echo
echo "=================================================="
echo "12. DEPLOY FLASK"
echo "=================================================="

az webapp deploy \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --src-path "./app.zip" \
    --type zip


# ==========================================================
# RESTART
# ==========================================================

echo
echo "=================================================="
echo "13. RESTART"
echo "=================================================="

az webapp restart \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP"


# ==========================================================
# RESULTADO
# ==========================================================

echo
echo
echo "=================================================="
echo "DEPLOY CONCLUÍDO"
echo "=================================================="

echo
echo "Azure SQL Server:"
echo "$SQL_SERVER_FQDN"

echo
echo "Azure SQL Database:"
echo "$SQL_DATABASE"

echo
echo "Tabela:"
echo "cadastro"

echo
echo "Web App:"
echo "https://${APP_NAME}.azurewebsites.net"

echo
echo "=================================================="
