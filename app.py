from flask import Flask, request
import pymysql
import os

app = Flask(__name__)

try:
    db = pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ["DB_NAME"]
    )

    cursor = db.cursor()

    # Create table automatically if it doesn't exist
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL
    )
    """)

    db.commit()

except Exception as e:
    print(f"Database connection failed: {e}")
    db = None

@app.route('/', methods=['GET'])
def home():

    if db is None:
        return "<h3>Database connection failed.</h3>"

    cursor = db.cursor()

    cursor.execute("SELECT * FROM users")

    users = cursor.fetchall()

    output = """
    <h1>User Form</h1>

    <form action="/submit" method="POST">
        <input type="text" name="username" placeholder="Enter Name" required>
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

    if db is None:
        return "<h3>Database connection failed.</h3>"

    username = request.form.get('username')

    cursor = db.cursor()

    sql = "INSERT INTO users(name) VALUES(%s)"

    cursor.execute(sql, (username,))

    db.commit()

    return """
    <h3>Inserted Successfully!</h3>
    <a href="/">Go Back</a>
    """

app.run(host='0.0.0.0', port=5000)
