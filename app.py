import os
import cv2
import face_recognition
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

def load_reference_encodings(reference_folder):
    known_encodings = {}
    for root, dirs, files in os.walk(reference_folder):
        for name in dirs:
            subdir = os.path.join(root, name)
            for filename in os.listdir(subdir):
                image_path = os.path.join(subdir, filename)
                reference_image = face_recognition.load_image_file(image_path)
                reference_encoding = face_recognition.face_encodings(reference_image)[0]
                known_encodings[name] = reference_encoding
    return known_encodings

def recognize_person(face_encoding, known_encodings, threshold=0.55):
    min_distance = float('inf')
    recognized_person = "Unknown"
    
    for name, encoding in known_encodings.items():
        distance = face_recognition.face_distance([encoding], face_encoding)[0]
        if distance < min_distance and distance <= threshold:
            min_distance = distance
            recognized_person = name
            
    return recognized_person

@app.route('/recognize', methods=['POST'])
def recognize_faces():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400
    
    image = request.files['image']
    
    if image.filename == '':
        return jsonify({'error': 'No selected image file'}), 400
    
    # Load known face encodings
    reference_folder = "D:/Users/Lenovo/mayank_lad"  # Adjust this path as needed
    known_encodings = load_reference_encodings(reference_folder)

    try:
        # Read the image file and convert it to OpenCV format
        img = face_recognition.load_image_file(image)
        rgb_img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        
        # Detect faces and encode them
        face_locations = face_recognition.face_locations(rgb_img)
        face_encodings = face_recognition.face_encodings(rgb_img, face_locations)

        recognized_students = []
        for face_encoding in face_encodings:
            person_name = recognize_person(face_encoding, known_encodings)
            recognized_students.append(person_name)

        return jsonify({
            'recognized_students': recognized_students,
            'message': f'Recognized {len(recognized_students)} student(s).'
        })

    except Exception as e:
        print(f"Error during recognition process: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Ensure the uploads directory exists
    os.makedirs('uploads', exist_ok=True)
    # Run the Flask app on all available network interfaces
    app.run(host='0.0.0.0', port=5000, debug=True)
