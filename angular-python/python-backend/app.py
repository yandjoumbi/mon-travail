from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import date

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# A sample API endpoint that returns data
@app.route('/', methods=['GET'])
def greeting():
    return jsonify({"message": "Hello from Murielle Wando"})

@app.route('/date', methods=['GET'])
def todayDate():
    today_date = date.today()
    return jsonify({"date": f"{today_date}"})

@app.route('/products', methods=['GET'])
def getProducts():
    hair_products = ['shampoo', 'soaps', 'moisturize', 'hair lotion']
    return hair_products


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000,debug=True)
