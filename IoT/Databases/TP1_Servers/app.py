from flask import Flask
from flask import render_template
from flask import request

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("hello.html", name="Bob")

@app.route("/german", methods=['GET'])
def german_home():
    return "Hallo, Flask! Wie get's ?"

@app.route("/parrot")
@app.route("/parrot/<sentence>")
def parrot(sentence="Nothing"):
    return render_template("yousay.html", what=sentence)

@app.route("/parameterized")
def parameterized():
    what_in = request.args.get("what")
    return render_template("youaskfor.html", what_out=what_in)