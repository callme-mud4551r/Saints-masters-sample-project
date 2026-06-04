from flask import Flask, request
import pymysql
import os

app = Flask(__name__)

db = pymysql.connect(
    host=os.environ["DB_HOST"],
    user=os.environ["DB_USER"],
    password=os.environ["DB_PASSWORD"],
    database=os.environ["DB_NAME"]
)

@app.route('/', methods=['GET'])
def home():

    cursor = db.cursor()

    cursor.execute("SELECT * FROM users")

    users = cursor.fetchall()

    output = """

    <h1>User Form</h1>

    <form action="/submit" method="POST">

        <input type="text" name="username" placeholder="Enter Name">

        <button type="submit">Submit</button>

    </form>

    <h2>Stored Users</h2>

    <ul>
    """

    for user in users:

        output += f"<li>{user[1]}</li>"

    output += "</ul>"

    return output

@app.route('/submit', methods=['POST'])
def submit():

    username = request.form.get('username')

    cursor = db.cursor()

    sql = "INSERT INTO users(name) VALUES(%s)"

    cursor.execute(sql, (username,))

    db.commit()

    return '''
        <h3>Inserted Successfully!</h3>

        <a href="/">Go Back</a>
    '''

app.run(host='0.0.0.0', port=5000)
