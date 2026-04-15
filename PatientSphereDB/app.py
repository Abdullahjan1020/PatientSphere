import bcrypt
from flask import Flask, request, jsonify
from pymongo import MongoClient
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# 1. MongoDB Connection Setup
client = MongoClient("mongodb://localhost:27017/")
db = client['PatientSphereDB']
users_collection = db['users']

# --- Security Helper Functions ---

def hash_password(password):
    """Converts plain text password into a secure hash."""
    # Generate a salt and hash the password
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

def check_password(password, hashed_password):
    """Compares a plain text password with a stored hash."""
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password)

# --- API Routes ---

@app.route('/register', methods=['POST'])
def register_user():
    try:
        user_data = request.json
        # Normalize email to lowercase [Real-world Best Practice]
        email = user_data.get('email', '').lower()
        password = user_data.get('password', '')

        # Check if user already exists
        if users_collection.find_one({"email": email}):
            return jsonify({"error": "User already exists"}), 400

        # SECURITY: Replace plain text password with a secure hash
        hashed = hash_password(password)
        
        # Prepare the document for MongoDB
        new_user = {
            "first_name": user_data.get('first_name'),
            "last_name": user_data.get('last_name'),
            "email": email,
            "password": hashed  # This is now binary/hashed data
        }

        users_collection.insert_one(new_user)
        print(f"Securely registered: {email}")
        return jsonify({"message": "User registered successfully with hashing!"}), 201

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": "Internal Server Error"}), 500

@app.route('/login', methods=['POST'])
def login_user():
    try:
        data = request.json
        email = data.get('email', '').lower()
        password = data.get('password', '')

        # 1. Find the user by email
        user = users_collection.find_one({"email": email})

        if user:
            # 2. Compare the provided password with the stored hash
            if check_password(password, user['password']):
                print(f"Successful login: {email}")
                return jsonify({
                    "message": "Login successful",
                    "user": {
                        "first_name": user.get('first_name'),
                        "email": user.get('email')
                    }
                }), 200
        
        # If user not found OR password doesn't match
        print(f"Failed login attempt for: {email}")
        return jsonify({"error": "Invalid email or password"}), 401

    except Exception as e:
        print(f"Login Error: {e}")
        return jsonify({"error": "Internal Server Error"}), 500

if __name__ == '__main__':
    # Running on 0.0.0.0 to accept connections from your mobile hotspot
    app.run(debug=True, host='0.0.0.0', port=5000)