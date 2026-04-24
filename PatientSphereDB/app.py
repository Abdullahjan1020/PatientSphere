import bcrypt
from flask import Flask, request, jsonify
from pymongo import MongoClient
from bson import ObjectId
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# MongoDB Connection
client = MongoClient("mongodb://localhost:27017/")
db = client['PatientSphereDB']
users_collection = db['users']
user_profiles_collection = db['user_profiles']
doctor_collection = db['doctors']
appointment_collection = db['appointments']

# --- Security Helper Functions ---
def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

def check_password(password, hashed_password):
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password)

# --- ROUTES ---

# 1. User Registration
@app.route('/register', methods=['POST'])
def register_user():
    try:
        data = request.json
        first_name = data.get('first_name')
        last_name = data.get('last_name')
        email = data.get('email', '').lower()
        password = data.get('password')

        if users_collection.find_one({"email": email}):
            return jsonify({"error": "User already exists"}), 400

        hashed_pw = hash_password(password)

        user_data = {
            "first_name": first_name,
            "last_name": last_name,
            "email": email,
            "password": hashed_pw
        }
        
        result = users_collection.insert_one(user_data)

        return jsonify({
            "message": "User registered successfully",
            "user_id": str(result.inserted_id)
        }), 201
    except Exception as e:
        print(f"Registration Error: {e}")
        return jsonify({"error": str(e)}), 500

# 2. User Login
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
                    "id": str(user['_id']),
                    "first_name": user.get('first_name'),
                    "email": user.get('email')
                }
            }), 200
        
        return jsonify({"error": "Invalid credentials"}), 401
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# 3. Fetch Profile Data (NEW: Fixes the 'Empty Fields' issue)
@app.route('/get_profile/<user_id>', methods=['GET'])
def get_profile(user_id):
    try:
        profile = user_profiles_collection.find_one({"user_id": ObjectId(user_id)})
        
        if profile:
            return jsonify({
                "age": profile.get("age", ""),
                "gender": profile.get("gender", "Male"),
                "blood_group": profile.get("blood_group", "O+"),
                "height": profile.get("height", ""),
                "weight": profile.get("weight", ""),
                "bmi": profile.get("bmi", "0.0"),
                "sos_contact": profile.get("sos_contact", "")
            }), 200
        else:
            return jsonify({"message": "No profile found"}), 404
    except Exception as e:
        print(f"Fetch Error: {e}")
        return jsonify({"error": "Invalid User ID format"}), 400

# 4. Update/Create Profile
@app.route('/update_profile', methods=['POST'])
def update_profile():
    try:
        data = request.json
        user_id = data.get('user_id')

        if not user_id:
            return jsonify({"error": "User ID is required"}), 400

        profile_data = {
            "user_id": ObjectId(user_id),
            "age": data.get('age'),
            "gender": data.get('gender'),
            "blood_group": data.get('blood_group'),
            "height": data.get('height'),
            "weight": data.get('weight'),
            "bmi": data.get('bmi'),
            "sos_contact": data.get('sos_contact')
        }

        # upsert=True ensures it creates a new one if it doesn't exist, 
        # or updates the existing one based on user_id.
        user_profiles_collection.update_one(
            {"user_id": ObjectId(user_id)},
            {"$set": profile_data},
            upsert=True
        )

        return jsonify({"message": "Profile synced successfully"}), 200
    except Exception as e:
        print(f"Update Error: {e}")
        return jsonify({"error": str(e)}), 500
    
#5. Get all Doctors
@app.route('/get_doctors', methods=['GET'])
def get_doctors():
    try:
        doctors = list(doctor_collection.find())
        for doc in doctors:
            doc['_id'] = str(doc['_id'])
        return jsonify(doctors), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
#6. Book Appointment
@app.route('/book_appointment', methods=['POST'])
def book_appointment():
    try:
        data = request.json
        appointment_data = {
            "user_id": ObjectId(data.get('user_id')),
            "doctors_id": data.get('doctors_id'),
            "doctor_name": data.get('doctor_name'),
            "department": data.get('department'),
            "date": data.get('date'),
            "time": data.get('time'),
            "status": "Scheduled"
        }
        result = appointment_collection.insert_one(appointment_data)
        return jsonify({"message": "Appointment booked!", "id": str(result.inserted_id)}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
# Get latetest appointment for Dashboard
@app.route('/get_latest_appointment/<user_id>', methods=['GET'])
def get_latest_appointment(user_id):
    try:
        appointment = appointment_collection.find_one(
            {"user_id":ObjectId(user_id), "status": "Scheduled"},
            sort=[("data", -1)]
        )
        if appointment:
            appointment['_id'] = str(appointment['_id'])
            appointment['user_id'] = str(appointment['user_id'])
            return jsonify(appointment), 200
        else:
            return jsonify({"messege": "No upcoming appointments"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
if __name__ == '__main__':
    # Make sure to use the IP address of your machine for mobile testing
    app.run(debug=True, host='0.0.0.0', port=5000)