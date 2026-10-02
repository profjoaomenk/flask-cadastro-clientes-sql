from flask import Flask, render_template, request, redirect, url_for

from database import (
    listar_clientes,
    buscar_cliente,
    inserir_cliente,
    atualizar_cliente,
    excluir_cliente
)


app = Flask(__name__)


@app.route("/", methods=["GET", "POST"])
def index():

    mensagem = None

    if request.method == "POST":

        nome = request.form.get("nome", "").strip()
        cpf = request.form.get("cpf", "").strip()
        telefone = request.form.get("telefone", "").strip()

        if not nome or not cpf or not telefone:
            mensagem = "Todos os campos são obrigatórios"

        else:
            inserir_cliente(nome, cpf, telefone)

            return redirect(url_for("index"))

    clientes = listar_clientes()

    return render_template(
        "index.html",
        mensagem=mensagem,
        clientes=clientes
    )


@app.route("/editar/<int:cliente_id>", methods=["GET", "POST"])
def editar(cliente_id):

    cliente = buscar_cliente(cliente_id)

    if not cliente:
        return "Cliente não encontrado", 404

    if request.method == "POST":

        nome = request.form.get("nome", "").strip()
        cpf = request.form.get("cpf", "").strip()
        telefone = request.form.get("telefone", "").strip()

        atualizar_cliente(
            cliente_id,
            nome,
            cpf,
            telefone
        )

        return redirect(url_for("index"))

    return render_template(
        "editar.html",
        cliente=cliente
    )


@app.route("/excluir/<int:cliente_id>", methods=["POST"])
def excluir(cliente_id):

    excluir_cliente(cliente_id)

    return redirect(url_for("index"))


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )
