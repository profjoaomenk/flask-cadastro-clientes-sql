from os import getenv
from mssql_python import connect


def get_connection():
    server = getenv("SQL_SERVER")
    database = getenv("SQL_DATABASE")
    username = getenv("SQL_USERNAME")
    password = getenv("SQL_PASSWORD")

    if not server:
        raise RuntimeError("Variável SQL_SERVER não configurada")

    if not database:
        raise RuntimeError("Variável SQL_DATABASE não configurada")

    if not username:
        raise RuntimeError("Variável SQL_USERNAME não configurada")

    if not password:
        raise RuntimeError("Variável SQL_PASSWORD não configurada")

    connection_string = (
        f"Server={server};"
        f"Database={database};"
        f"UID={username};"
        f"PWD={password};"
        "Encrypt=yes;"
        "TrustServerCertificate=no;"
    )

    return connect(connection_string)


def listar_clientes():
    connection = get_connection()

    try:
        cursor = connection.cursor()

        cursor.execute("""
            SELECT
                id,
                nome,
                cpf,
                telefone
            FROM cadastro
            ORDER BY id DESC
        """)

        return cursor.fetchall()

    finally:
        connection.close()


def buscar_cliente(cliente_id):
    connection = get_connection()

    try:
        cursor = connection.cursor()

        cursor.execute("""
            SELECT
                id,
                nome,
                cpf,
                telefone
            FROM cadastro
            WHERE id = ?
        """, (cliente_id,))

        return cursor.fetchone()

    finally:
        connection.close()


def inserir_cliente(nome, cpf, telefone):
    connection = get_connection()

    try:
        cursor = connection.cursor()

        cursor.execute("""
            INSERT INTO cadastro
                (nome, cpf, telefone)
            VALUES
                (?, ?, ?)
        """, (nome, cpf, telefone))

        connection.commit()

    finally:
        connection.close()


def atualizar_cliente(cliente_id, nome, cpf, telefone):
    connection = get_connection()

    try:
        cursor = connection.cursor()

        cursor.execute("""
            UPDATE cadastro
            SET
                nome = ?,
                cpf = ?,
                telefone = ?
            WHERE id = ?
        """, (nome, cpf, telefone, cliente_id))

        connection.commit()

    finally:
        connection.close()


def excluir_cliente(cliente_id):
    connection = get_connection()

    try:
        cursor = connection.cursor()

        cursor.execute("""
            DELETE FROM cadastro
            WHERE id = ?
        """, (cliente_id,))

        connection.commit()

    finally:
        connection.close()
