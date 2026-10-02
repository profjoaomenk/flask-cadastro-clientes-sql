# Flask Cadastro de Clientes — Azure SQL Database

Aplicação web desenvolvida em **Python + Flask** para cadastro de clientes, com persistência dos dados em um **Azure SQL Database**.

O projeto demonstra a integração entre:

* Python
* Flask
* HTML/CSS
* Azure App Service
* Azure SQL Database
* Azure CLI
* `sqlcmd`
* Variáveis de ambiente
* CRUD completo

A aplicação permite realizar as operações:

* **Create** — cadastrar cliente
* **Read** — consultar clientes
* **Update** — alterar cliente
* **Delete** — excluir cliente

---

# 1. Arquitetura

```text
                        INTERNET
                           │
                           ▼
                 ┌────────────────────┐
                 │   Azure App Service │
                 │                    │
                 │  Python + Flask    │
                 │                    │
                 │     app.py         │
                 │        │           │
                 │        ▼           │
                 │   database.py      │
                 │        │           │
                 │     getenv()       │
                 └────────┼───────────┘
                          │
                          │ SQL
                          ▼
                 ┌────────────────────┐
                 │   Azure SQL Server │
                 │                    │
                 │ sql-server-rm9999  │
                 │        │           │
                 │        ▼           │
                 │      clientes      │
                 │        │           │
                 │        ▼           │
                 │     cadastro       │
                 └────────────────────┘
```

---

# 2. Recursos Azure

Durante a implantação serão criados os seguintes recursos:

| Recurso            | Nome                    |
| ------------------ | ----------------------- |
| Resource Group     | `rg-flask-clientes`     |
| App Service Plan   | `plan-flask-clientes`   |
| Web App            | `flask-cadastro-rm9999` |
| Azure SQL Server   | `sql-server-rm9999`     |
| Azure SQL Database | `clientes`              |
| Tabela             | `cadastro`              |

> **Importante 1:** o nome do Web App e SQL Server precisam ser globalmente únicos no Azure. Caso `flask-cadastro-rm9999` ou `sql-server-rm9999` já esteja em uso, altere as variável `APP_NAME` e `SQL_SERVER` no arquivo `deploy-azure.sh`.

> **Importante 2:** Substitua a região no script por uma da lista de sua política na variável `LOCATION`

---

# 3. Estrutura do projeto

```text
flask-cadastro-clientes-sql/
│
├── app.py
├── database.py
├── requirements.txt
├── deploy-azure.sh
├── .gitignore
├── README.md
│
├── sql/
│   └── 01-criar-tabela.sql
│
├── static/
│   └── style.css
│
└── templates/
    ├── index.html
    └── editar.html
```

## Descrição dos arquivos

| Arquivo                   | Função                        |
| ------------------------- | ----------------------------- |
| `app.py`                  | Aplicação Flask e rotas       |
| `database.py`             | Conexão e operações SQL       |
| `requirements.txt`        | Dependências Python           |
| `deploy-azure.sh`         | Criação dos recursos e deploy |
| `sql/01-criar-tabela.sql` | Criação da tabela             |
| `templates/index.html`    | Cadastro e listagem           |
| `templates/editar.html`   | Alteração de cadastro         |
| `static/style.css`        | Estilos da aplicação          |
| `.gitignore`              | Arquivos ignorados pelo Git   |
| `README.md`               | Documentação                  |

---

# 4. Pré-requisitos

Para executar o projeto localmente ou realizar o deploy, são necessários:

* Conta Microsoft Azure
* Azure CLI
* Git
* Python 3.10 ou superior
* Bash
* Internet

O script de implantação verifica automaticamente a existência do `sqlcmd` e realiza sua instalação caso ele não esteja disponível no ambiente

---

# 5. Clonar o projeto

No Azure Cloud Shell:

```bash
git clone https://github.com/profjoaomenk/flask-cadastro-clientes-sql.git
```

Entre no diretório:

```bash
cd flask-cadastro-clientes-sql
```

Confira os arquivos:

```bash
ls -la
```

O resultado deverá apresentar:

```text
app.py
database.py
requirements.txt
deploy-azure.sh
README.md
sql
static
templates
```

---

# 6. Verificar o Azure CLI

Execute:

```bash
az version
```

Verifique a conta atualmente conectada:

```bash
az account show
```

Para listar as assinaturas:

```bash
az account list --output table
```

Caso seja necessário escolher outra assinatura:

```bash
az account set --subscription "NOME_DA_ASSINATURA"
```

Confirme:

```bash
az account show --output table
```

---

# 7. Configuração das credenciais do Azure SQL

O projeto não armazena a senha do banco no código

O script utiliza as seguintes variáveis:

```text
SQL_USERNAME
SQL_PASSWORD
```

No Cloud Shell, configure:

```bash
export SQL_USERNAME="sqladmin"
export SQL_PASSWORD="SUA_SENHA_FORTE"
```

Para confirmar o usuário:

```bash
echo "$SQL_USERNAME"
```

Não execute:

```bash
echo "$SQL_PASSWORD"
```

para evitar expor a senha no terminal

---

# 8. Regras para a senha do Azure SQL

A senha deve atender aos requisitos do Azure SQL Database.

Utilize uma senha forte contendo, por exemplo:

* letras maiúsculas;
* letras minúsculas;
* números;
* caracteres especiais.

Exemplo:

```text
AzureSql#2026Senha
```

Não utilize essa senha em ambientes reais.

---

# 9. Permissão de execução do script

Antes de executar o deploy:

```bash
chmod +x deploy-azure.sh
```

Confira:

```bash
ls -l deploy-azure.sh
```

Deverá aparecer uma permissão semelhante a:

```text
-rwxr-xr-x
```

---

# 10. Executar o deploy

Execute:

```bash
./deploy-azure.sh
```

O script realizará automaticamente as seguintes etapas:

```text
1. Verificar Azure CLI
2. Verificar login
3. Verificar sqlcmd
4. Instalar sqlcmd se necessário
5. Criar Resource Group
6. Criar Azure SQL Server
7. Criar Azure SQL Database
8. Configurar Firewall
9. Criar tabela cadastro
10. Criar App Service Plan
11. Criar Web App
12. Configurar variáveis de ambiente
13. Configurar Startup Command
14. Empacotar aplicação
15. Realizar deploy
16. Reiniciar Web App
```

---

# 11. Instalação automática do sqlcmd

O script verifica se o comando está disponível:

```bash
command -v sqlcmd
```

Caso já esteja instalado:

```text
sqlcmd já está instalado.
```

Caso contrário, o script realiza automaticamente a instalação.

Depois verifica:

```bash
sqlcmd --version
```

Isso permite executar o projeto no Azure Cloud Shell mesmo quando o `sqlcmd` não está previamente instalado.

---

# 12. Criação do Resource Group

O script cria:

```text
rg-flask-clientes
```

Com:

```bash
az group create \
    --name rg-flask-clientes \
    --location brazilsouth
```

Todos os recursos principais da atividade ficarão agrupados nesse Resource Group.

---

# 13. Criação do Azure SQL Server

Será criado:

```text
sql-server-rm9999
```

O endereço completo do servidor será:

```text
sql-server-rm9999.database.windows.net
```

O usuário administrador será definido pela variável:

```bash
SQL_USERNAME
```

A senha será obtida de:

```bash
SQL_PASSWORD
```

---

# 14. Criação do Azure SQL Database

Será criado o banco:

```text
clientes
```

O banco ficará dentro do servidor:

```text
sql-server-rm9999
```

Portanto:

```text
Azure SQL Server
└── sql-server-rm9999
       │
       └── Database
             │
             └── clientes
```

---

# 15. Configuração do Firewall

O script está liberando todos os IPs para acesarem o Banco. Utilizado somente em ambientes de Desenvolvimento e para fins de aprendizado

Também é criada a regra:

```text
AllowAzureServices
```

Essa regra permite o acesso de serviços Azure ao servidor SQL

> Em ambientes reais, recomenda-se utilizar uma arquitetura de rede mais restritiva. A configuração acima é utilizada para facilitar a atividade didática

---

# 16. Criação da tabela

O arquivo:

```text
sql/01-criar-tabela.sql
```

contém:

```sql
IF OBJECT_ID('dbo.cadastro', 'U') IS NULL
BEGIN

    CREATE TABLE dbo.cadastro (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nome NVARCHAR(150) NOT NULL,
        cpf VARCHAR(14) NOT NULL,
        telefone VARCHAR(20) NOT NULL
    );

END;
GO
```

A tabela criada será:

```text
cadastro
```

com as colunas:

| Coluna     | Tipo            | Descrição       |
| ---------- | --------------- | --------------- |
| `id`       | `INT IDENTITY`  | Identificador   |
| `nome`     | `NVARCHAR(150)` | Nome do cliente |
| `cpf`      | `VARCHAR(14)`   | CPF             |
| `telefone` | `VARCHAR(20)`   | Telefone        |

---

# 17. Verificar a tabela com sqlcmd

Depois da criação do banco, é possível consultar:

```bash
sqlcmd \
    -S sql-server-rm9999.database.windows.net \
    -d clientes \
    -U "$SQL_USERNAME" \
    -P "$SQL_PASSWORD" \
    -C \
    -Q "SELECT * FROM cadastro;"
```

Inicialmente não haverá registros

---

# 18. CRUD da aplicação

A aplicação implementa quatro operações principais.

## CREATE

O formulário envia:

```text
nome
cpf
telefone
```

A aplicação executa:

```sql
INSERT INTO cadastro
    (nome, cpf, telefone)
VALUES
    (?, ?, ?);
```

---

## READ

A aplicação consulta:

```sql
SELECT
    id,
    nome,
    cpf,
    telefone
FROM cadastro
ORDER BY id DESC;
```

Os registros são exibidos na página principal.

---

## UPDATE

A aplicação executa:

```sql
UPDATE cadastro
SET
    nome = ?,
    cpf = ?,
    telefone = ?
WHERE id = ?;
```

---

## DELETE

A aplicação executa:

```sql
DELETE FROM cadastro
WHERE id = ?;
```

---

# 19. Variáveis de ambiente da aplicação

A aplicação não possui as informações do banco diretamente no código.

Em `database.py`:

```python
from os import getenv
```

As informações são recuperadas utilizando:

```python
server = getenv("SQL_SERVER")
database = getenv("SQL_DATABASE")
username = getenv("SQL_USERNAME")
password = getenv("SQL_PASSWORD")
```

As variáveis utilizadas são:

| Variável       | Valor                                    |
| -------------- | ---------------------------------------- |
| `SQL_SERVER`   | `sql-server-rm9999.database.windows.net` |
| `SQL_DATABASE` | `clientes`                               |
| `SQL_USERNAME` | usuário do SQL Server                    |
| `SQL_PASSWORD` | senha do SQL Server                      |

---

# 20. Variáveis no Azure App Service

O script configura automaticamente essas variáveis no Web App:

```text
SQL_SERVER
SQL_DATABASE
SQL_USERNAME
SQL_PASSWORD
```

O comando utilizado é:

```bash
az webapp config appsettings set \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings \
        SQL_SERVER="$SQL_SERVER_FQDN" \
        SQL_DATABASE="$SQL_DATABASE" \
        SQL_USERNAME="$SQL_USERNAME" \
        SQL_PASSWORD="$SQL_PASSWORD"
```

No Azure App Service, essas configurações são disponibilizadas para a aplicação como variáveis de ambiente.

Consequentemente, o mesmo código Python pode ser executado:

```text
Local
  │
  └── getenv()
       │
       ▼
   Azure SQL


Azure App Service
  │
  └── getenv()
       │
       ▼
   Azure SQL
```

---

# 21. `SCM_DO_BUILD_DURING_DEPLOYMENT`

O script configura:

```text
SCM_DO_BUILD_DURING_DEPLOYMENT=true
```

Essa configuração solicita ao Azure App Service que realize o processo de build durante o deployment, incluindo a instalação das dependências especificadas no `requirements.txt`.

O projeto possui:

```text
requirements.txt
```

com as dependências:

```text
Flask==3.1.2
gunicorn==23.0.0
mssql-python
```

---

# 22. Startup Command

O Web App será configurado para executar:

```bash
gunicorn --bind=0.0.0.0 app:app
```

Isso significa:

```text
gunicorn
   │
   └── app.py
         │
         └── app
```

O objeto:

```python
app = Flask(__name__)
```

é utilizado pelo Gunicorn

---

# 23. Acessar a aplicação

Ao final do script será apresentada uma URL semelhante a:

```text
https://flask-cadastro-rm9999.azurewebsites.net
```

Abra essa URL no navegador.

A página apresentará:

```text
Cadastro de Clientes

Nome
CPF
Telefone

[ Cadastrar cliente ]

Clientes cadastrados
```

---

# 24. Teste do CREATE

Preencha:

```text
Nome:
João da Silva

CPF:
111.111.111-11

Telefone:
(11) 99999-9999
```

Clique:

```text
Cadastrar cliente
```

Depois consulte o banco:

```bash
sqlcmd \
    -S sql-server-rm9999.database.windows.net \
    -d clientes \
    -U "$SQL_USERNAME" \
    -P "$SQL_PASSWORD" \
    -C \
    -Q "SELECT * FROM cadastro;"
```

O registro deverá aparecer na tabela.

---

# 25. Teste do READ

A página inicial apresenta todos os registros cadastrados.

A consulta utilizada pela aplicação é:

```sql
SELECT
    id,
    nome,
    cpf,
    telefone
FROM cadastro
ORDER BY id DESC;
```

---

# 26. Teste do UPDATE

Na listagem de clientes, clique:

```text
Editar
```

Altere alguma informação.

Clique:

```text
Salvar alterações
```

Depois confirme diretamente no Azure SQL:

```bash
sqlcmd \
    -S sql-server-rm9999.database.windows.net \
    -d clientes \
    -U "$SQL_USERNAME" \
    -P "$SQL_PASSWORD" \
    -C \
    -Q "SELECT * FROM cadastro;"
```

---

# 27. Teste do DELETE

Na listagem, clique:

```text
Excluir
```

Depois confirme:

```bash
sqlcmd \
    -S sql-server-rm9999.database.windows.net \
    -d clientes \
    -U "$SQL_USERNAME" \
    -P "$SQL_PASSWORD" \
    -C \
    -Q "SELECT * FROM cadastro;"
```

O registro excluído não deverá mais aparecer.

---

# 28. Evidência do CRUD

Para comprovar o funcionamento do projeto, recomenda-se apresentar:

### CREATE

Cadastro realizado pelo navegador.

### READ

Lista de clientes carregada pela aplicação.

### UPDATE

Cliente alterado pelo navegador.

### DELETE

Cliente excluído pelo navegador.

### Confirmação no banco

Executar:

```sql
SELECT * FROM cadastro;
```

diretamente no Azure SQL Database.

Isso demonstra que a aplicação realmente está persistindo os dados no banco.

---

# 29. Verificar os recursos criados

Resource Groups:

```bash
az group list --output table
```

Web Apps:

```bash
az webapp list --output table
```

App Service Plans:

```bash
az appservice plan list --output table
```

SQL Servers:

```bash
az sql server list --output table
```

Databases:

```bash
az sql db list \
    --resource-group rg-flask-clientes \
    --server sql-server-rm9999 \
    --output table
```

---

# 30. Verificar as configurações do Web App

Para listar apenas os nomes das configurações:

```bash
az webapp config appsettings list \
    --name flask-cadastro-rm9999 \
    --resource-group rg-flask-clientes \
    --query "[].name" \
    --output table
```

Não é necessário exibir os valores das configurações, principalmente a senha.

---

# 31. Logs da aplicação

Caso a aplicação apresente algum problema:

```bash
az webapp log config \
    --name flask-cadastro-rm9999 \
    --resource-group rg-flask-clientes \
    --web-server-logging filesystem
```

Depois:

```bash
az webapp log tail \
    --name flask-cadastro-rm9999 \
    --resource-group rg-flask-clientes
```

Os logs podem ajudar a identificar problemas como:

* erro de conexão com Azure SQL;
* variável de ambiente ausente;
* erro no Flask;
* erro no Gunicorn;
* erro de instalação de dependências;
* erro de execução da aplicação.

---

# 32. Problemas comuns

## `sqlcmd: command not found`

O `deploy-azure.sh` verifica e instala automaticamente o `sqlcmd`.

Para verificar manualmente:

```bash
sqlcmd --version
```

---

## Erro de conexão com Azure SQL

Verifique:

```bash
echo "$SQL_SERVER"
echo "$SQL_DATABASE"
echo "$SQL_USERNAME"
```

Não exiba a senha.

Confirme também as regras de firewall:

```bash
az sql server firewall-rule list \
    --resource-group rg-flask-clientes \
    --server sql-server-rm9999 \
    --output table
```

---

## Erro `Login failed`

Confirme:

```text
SQL_USERNAME
SQL_PASSWORD
```

O usuário precisa ser o administrador configurado durante a criação do Azure SQL Server.

---

## Aplicação não inicia

Verifique os logs:

```bash
az webapp log tail \
    --name flask-cadastro-rm9999 \
    --resource-group rg-flask-clientes
```

Confirme também o Startup Command:

```text
gunicorn --bind=0.0.0.0 app:app
```

---

## Erro relacionado ao `requirements.txt`

Confirme:

```bash
cat requirements.txt
```

Deve conter:

```text
Flask==3.1.2
gunicorn==23.0.0
mssql-python
```

E confirme:

```text
SCM_DO_BUILD_DURING_DEPLOYMENT=true
```

---

# 33. Fluxo resumido da implantação

```text
┌───────────────────────┐
│      GitHub           │
│                       │
│  Código Flask         │
│  SQL                  │
│  deploy-azure.sh      │
└───────────┬───────────┘
            │
            │ git clone
            ▼
┌───────────────────────┐
│    Azure Cloud Shell  │
│                       │
│ ./deploy-azure.sh     │
└───────────┬───────────┘
            │
            ├─────────────────────┐
            │                     │
            ▼                     ▼
┌──────────────────┐    ┌──────────────────┐
│   Azure SQL      │    │ Azure App Service│
│                  │    │                  │
│ sql-server-rm9999│    │ Flask            │
│                  │    │ Gunicorn         │
│ clientes         │    │                  │
│                  │    │ getenv()         │
│ cadastro         │◄───┤                  │
└──────────────────┘    └────────┬─────────┘
                                 │
                                 ▼
                              Browser
```

---

# 34. Comando único

Depois de clonar o projeto e configurar as credenciais:

```bash
export SQL_USERNAME="sqladmin"
export SQL_PASSWORD="SUA_SENHA_FORTE"

chmod +x deploy-azure.sh

./deploy-azure.sh
```

A partir desse ponto, o script será responsável pela criação e configuração dos recursos.

---

# 35. Resultado final

Ao final da atividade teremos:

```text
Azure
│
├── Resource Group
│   └── rg-flask-clientes
│
├── App Service Plan
│   └── plan-flask-clientes
│
├── Web App
│   └── flask-cadastro-rm9999
│       │
│       ├── Flask
│       ├── Gunicorn
│       └── getenv()
│
└── Azure SQL Server
    └── sql-server-rm9999.database.windows.net
        │
        └── Database
            └── clientes
                │
                └── cadastro
                    ├── id
                    ├── nome
                    ├── cpf
                    └── telefone
```

O projeto demonstra uma aplicação **Python/Flask hospedada no Azure App Service**, utilizando **Azure SQL Database como camada de persistência**, com configuração por **variáveis de ambiente** e implantação automatizada por **Azure CLI**
