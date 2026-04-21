from flask import Flask, jsonify
import jsonimport, mariadb
import dbconnectie

app = Flask(__name__)

# Routes
@app.route("/")
def hello_world():
    pizza1 = Pizza("All you can (M)eat", 10)
    pizza2 = Pizza("Quatrio Stagioni", 11)
    pizza3 = Pizza("Pepperoni", 6)
    pizza4 = Pizza("Margharita", 8)
    factuur1 = Factuur("10-4-2026", "Betaald")
    BDO = Factuur("De factuur is afgehandeld door BDO voo pizza", factuur1)
    return BDO.toJson() + pizza1.toJson()

app.route("/Pizza/all")
def get_all_pizzas():
    conn = None
    try:
        conn = mariadb.connect(**dbconnectie.mariadb_config)

        cursor = conn.cursor()
        cursor.execute("SELECT naam, prijs FROM Pizza")

        rows = cursor.fetchall()

        return jsonify(rows)

    except Exception as e:
        return f"Er is iets misgegaan: {e}"
    finally:
        if conn is not None:
            conn.close()

# Klasses
class Pizza:
    def __init__(self, soort, prijs):
        self.soort = soort
        self.prijs = prijs
    def toJson (self):
        return json.dumps(self.__dict__)

class Factuur:
    def __init__(self, datum, status):
        self.datum = datum
        self.status = status
    def toJson (self):
        return json.dumps(self, default=lambda o: o.__dict__, indent=4)
        