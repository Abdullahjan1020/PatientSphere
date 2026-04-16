import bcrypt
from flask import Flask, request, jsonify
from pymongo import MongoClient
from bson import ObjectId # Import this to handle MongoDB IDs
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

client = MongoClient("mongodb://localhost:27017/")
db = client['PatientSphereDB']
users_collection = db['users']
user_profiles_collection = db['user_profiles']

# --- Security Helper Functions ---
def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

def check_password(password, hashed_password):
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password)

# --- Routes ---

@app.route('/login', methods=['POST'])
def login_user():
    try:
        data = request.json
        email = data.get('email', '').lower()
        password = data.get('password', '')

        user = users_collection.find_one({"email": email})

        if user and check_password(password, user['password']):
            return jsonify({
                "message": "Login successful",
                "user": {
                    "id": str(user['_id']), # Return the Unique Object ID as a string
                    "first_name": user.get('first_name'),
                    "email": user.get('email')
                }
            }), 200
        
        return jsonify({"error": "Invalid credentials"}), 401
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/update_profile', methods=['POST'])
def update_profile():
    try:
        data = request.json
        user_id = data.get('user_id') # We now expect the ObjectID string

        if not user_id:
            return jsonify({"error": "User ID is required for integrity"}), 400

        profile_data = {
            "user_id": ObjectId(user_id), # Store as actual ObjectId for fast indexing
            "age": data.get('age'),
            "gender": data.get('gender'),
            "blood_group": data.get('blood_group'),
            "height": data.get('height'),
            "weight": data.get('weight'),
            "bmi": data.get('bmi'),
            "sos_contact": data.get('sos_contact')
        }

        # Update by user_id instead of email
        user_profiles_collection.update_one(
            {"user_id": ObjectId(user_id)},
            {"$set": profile_data},
            upsert=True
        )

        return jsonify({"message": "Bio-data linked to ObjectID successfully"}), 200

    except Exception as e:
        print(f"Profile Error: {e}")
        return jsonify({"error": "Data integrity fault"}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)