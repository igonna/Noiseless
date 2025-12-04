# Backend API Implementation Guide

This guide explains the backend API endpoints you need to implement to support user data persistence.

## Base URL

Currently configured in `NoiselessAPIService.swift`:
```
http://192.168.18.184:6469
```

## Required Endpoints

### 1. Save User Data

**Endpoint:** `POST /user-data`

**Description:** Saves user onboarding data to the backend

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "identity": "Student",
  "identityDetail": "Computer Science major",
  "location": "New York",
  "skills": ["Programming", "Design", "Communication"],
  "traits": ["Curious", "Organized", "Creative"],
  "source": [],
  "vision": ["Career growth", "Learn new skills"],
  "visionDetail": "I want to become a senior developer",
  "values": ["Learning", "Innovation", "Balance"],
  "constraints": ["Limited time", "Budget conscious"],
  "constraintsDetail": "Only have 2 hours per day",
  "timeBudget": "2 hours/day"
}
```

**Response (Success - 200 or 201):**
```json
{
  "success": true,
  "message": "User data saved successfully"
}
```

**Response (Error - 400/500):**
```json
{
  "success": false,
  "error": "Error message here"
}
```

---

### 2. Get User Data

**Endpoint:** `GET /user-data`

**Description:** Retrieves the user's onboarding data

**Headers:**
```
Content-Type: application/json
```

**Query Parameters (Optional):**
```
userId: string (if you implement multi-user support)
```

**Response (Success - 200):**
```json
{
  "identity": "Student",
  "identityDetail": "Computer Science major",
  "location": "New York",
  "skills": ["Programming", "Design", "Communication"],
  "traits": ["Curious", "Organized", "Creative"],
  "source": [],
  "vision": ["Career growth", "Learn new skills"],
  "visionDetail": "I want to become a senior developer",
  "values": ["Learning", "Innovation", "Balance"],
  "constraints": ["Limited time", "Budget conscious"],
  "constraintsDetail": "Only have 2 hours per day",
  "timeBudget": "2 hours/day"
}
```

**Response (Not Found - 404):**
```json
{
  "success": false,
  "error": "User data not found"
}
```

---

## Implementation Examples

### Node.js (Express)

```javascript
const express = require('express');
const app = express();

app.use(express.json());

// In-memory storage (replace with database)
let userData = {};

// Save user data
app.post('/user-data', (req, res) => {
  try {
    userData = req.body;
    console.log('User data saved:', userData);

    res.status(201).json({
      success: true,
      message: 'User data saved successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Get user data
app.get('/user-data', (req, res) => {
  try {
    if (!userData || Object.keys(userData).length === 0) {
      return res.status(404).json({
        success: false,
        error: 'User data not found'
      });
    }

    res.status(200).json(userData);
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.listen(6469, '0.0.0.0', () => {
  console.log('Server running on http://0.0.0.0:6469');
});
```

### Python (Flask)

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

# In-memory storage (replace with database)
user_data = {}

@app.route('/user-data', methods=['POST'])
def save_user_data():
    try:
        global user_data
        user_data = request.json
        print('User data saved:', user_data)

        return jsonify({
            'success': True,
            'message': 'User data saved successfully'
        }), 201
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/user-data', methods=['GET'])
def get_user_data():
    try:
        if not user_data:
            return jsonify({
                'success': False,
                'error': 'User data not found'
            }), 404

        return jsonify(user_data), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=6469)
```

---

## Database Schema Recommendation

If using MongoDB:

```javascript
const userDataSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  identity: String,
  identityDetail: String,
  location: String,
  skills: [String],
  traits: [String],
  source: [String],
  vision: [String],
  visionDetail: String,
  values: [String],
  constraints: [String],
  constraintsDetail: String,
  timeBudget: String,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});
```

If using PostgreSQL:

```sql
CREATE TABLE user_data (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(255) UNIQUE NOT NULL,
  identity VARCHAR(255),
  identity_detail TEXT,
  location VARCHAR(255),
  skills JSONB,
  traits JSONB,
  source JSONB,
  vision JSONB,
  vision_detail TEXT,
  values JSONB,
  constraints JSONB,
  constraints_detail TEXT,
  time_budget VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Testing the API

### Using cURL

**Save data:**
```bash
curl -X POST http://192.168.18.184:6469/user-data \
  -H "Content-Type: application/json" \
  -d '{
    "identity": "Student",
    "identityDetail": "Computer Science major",
    "location": "New York",
    "skills": ["Programming", "Design"],
    "traits": ["Curious", "Organized"],
    "source": [],
    "vision": ["Career growth"],
    "visionDetail": "Senior developer",
    "values": ["Learning"],
    "constraints": ["Limited time"],
    "constraintsDetail": "2 hours/day",
    "timeBudget": "2 hours/day"
  }'
```

**Get data:**
```bash
curl -X GET http://192.168.18.184:6469/user-data \
  -H "Content-Type: application/json"
```

---

## Security Considerations

1. **Authentication:** Add JWT or session-based authentication
2. **Authorization:** Ensure users can only access their own data
3. **Validation:** Validate all input data on the server side
4. **Rate Limiting:** Implement rate limiting to prevent abuse
5. **HTTPS:** Use HTTPS in production (update baseURL in NoiselessAPIService.swift)
6. **Data Privacy:** Encrypt sensitive data at rest and in transit

---

## Next Steps

1. Implement the two endpoints in your backend
2. Test them using cURL or Postman
3. Update the `baseURL` in `NoiselessAPIService.swift` if needed
4. Add authentication if required
5. Deploy to a production server and update the baseURL to use HTTPS
