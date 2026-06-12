import os
from flask import Flask, request, redirect, url_for
import pymysql
import boto3
from botocore.exceptions import NoCredentialsError

app = Flask(__name__)

# --- AWS S3 Configuration ---
S3_BUCKET_NAME = os.environ.get("S3_BUCKET_NAME", "your-app-image-uploads")

# Fallback pattern targeting your deployment region directly if the environment variable is dropped
AWS_REGION = os.environ.get("AWS_DEFAULT_REGION", "ap-south-1")
s3_client = boto3.client('s3', region_name=AWS_REGION)

# --- Database Connection ---
try:
    db = pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ["DB_NAME"]
    )
    cursor = db.cursor()

    # Updated schema to include an image_key column
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        image_key VARCHAR(255) DEFAULT NULL
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

    # Re-verify/ping database connection to keep it alive
    db.ping(reconnect=True)
    cursor = db.cursor()
    cursor.execute("SELECT * FROM users")
    users = cursor.fetchall()

    # Note the added enctype="multipart/form-data" for file handling
    output = """
    <h1>User Form with Image Upload</h1>

    <form action="/submit" method="POST" enctype="multipart/form-data">
        <input type="text" name="username" placeholder="Enter Name" required>
        <br><br>
        <label>Upload Profile Image:</label>
        <input type="file" name="user_image" accept="image/*" required>
        <br><br>
        <button type="submit">Submit</button>
    </form>

    <h2>Stored Users & Images</h2>
    <ul>
    """

    for user in users:
        username = user[1]
        image_key = user[2] if user[2] else "No image"
        output += f"<li><strong>{username}</strong> (Image File: {image_key})</li>"

    output += "</ul>"
    return output


@app.route('/submit', methods=['POST'])
def submit():
    if db is None:
        return "<h3>Database connection failed.</h3>"

    username = request.form.get('username')
    file = request.files.get('user_image')

    if not file or file.filename == '':
        return "<h3>No file selected!</h3>", 400

    # 1. Upload file directly to Amazon S3
    try:
        # Standardize filename to prevent collisions if necessary
        s3_file_key = f"uploads/{username}_{file.filename}"
        
        # Uploading file object straight from memory to S3
        s3_client.upload_fileobj(
            file,
            S3_BUCKET_NAME,
            s3_file_key,
            ExtraArgs={"ContentType": file.content_type}
        )
        
    except NoCredentialsError:
        return "<h3>AWS Credentials not found. Check EKS IAM roles.</h3>", 500
    except Exception as e:
        return f"<h3>Failed to upload to S3: {e}</h3>", 500

    # 2. Insert record into MySQL database
    try:
        db.ping(reconnect=True)
        cursor = db.cursor()
        sql = "INSERT INTO users(name, image_key) VALUES(%s, %s)"
        cursor.execute(sql, (username, s3_file_key))
        db.commit()
    except Exception as e:
        return f"<h3>Database insert failed: {e}</h3>", 500

    # Successful submission triggers the S3 event notification natively in AWS
    return """
    <h3>Inserted and Uploaded Successfully!</h3>
    <p>S3 event notification triggered automatically.</p>
    <a href="/">Go Back</a>
    """

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
