#!/usr/bin/env python3
"""
Complete Pregnancy Tracking Flask Application
This app provides trimester-specific quick actions with AI-powered guidance.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from datetime import datetime
from pregnancy_tracking_service import pregnancy_service, Trimester

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Configuration
app.config['JSON_SORT_KEYS'] = False

# JWT Secret (in production, use environment variable)
JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'your-secret-key-here')

def token_required(f):
    """Simple token validation decorator"""
    from functools import wraps
    
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]  # Bearer <token>
            except IndexError:
                return jsonify({"error": "Invalid token format"}), 401
        
        if not token:
            return jsonify({"error": "Token is missing"}), 401
        
        # In production, validate JWT token here
        # For now, we'll just check if token exists
        if token == "invalid":
            return jsonify({"error": "Invalid or expired token"}), 401
        
        return f(*args, **kwargs)
    
    return decorated

# ============================================================================
# AUTO-TRIMESTER SELECTION API
# ============================================================================

@app.route('/api/pregnancy/auto-trimester/<int:week>', methods=['GET'])
@token_required
def get_auto_trimester(week):
    """Auto-select trimester based on pregnancy week and get AI insights"""
    try:
        if week < 1 or week > 40:
            return jsonify({
                "success": False,
                "error": "Pregnancy week must be between 1 and 40"
            }), 400
        
        result = pregnancy_service.get_auto_trimester_info(week)
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting auto-trimester info: {str(e)}"
        }), 500

# ============================================================================
# TRIMESTER 1 QUICK ACTIONS APIs
# ============================================================================

@app.route('/api/pregnancy/trimester-1/pregnancy-test', methods=['GET'])
@token_required
def get_pregnancy_test_guide():
    """Get comprehensive pregnancy test guide for Trimester 1"""
    try:
        result = pregnancy_service.get_quick_action_guidance(1, "pregnancy-test")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting pregnancy test guide: {str(e)}"
        }), 500

@app.route('/api/pregnancy/trimester-1/first-prenatal-visit', methods=['GET'])
@token_required
def get_first_prenatal_visit_guide():
    """Get first prenatal visit guide for Trimester 1"""
    try:
        result = pregnancy_service.get_quick_action_guidance(1, "first-prenatal-visit")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting first prenatal visit guide: {str(e)}"
        }), 500

@app.route('/api/pregnancy/trimester-1/early-ultrasound', methods=['GET'])
@token_required
def get_early_ultrasound_guide():
    """Get early ultrasound guide for Trimester 1"""
    try:
        result = pregnancy_service.get_quick_action_guidance(1, "early-ultrasound")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting early ultrasound guide: {str(e)}"
        }), 500

@app.route('/api/pregnancy/trimester-1/early-symptoms', methods=['GET'])
@token_required
def get_early_symptoms_guide():
    """Get early symptoms guide for Trimester 1"""
    try:
        result = pregnancy_service.get_quick_action_guidance(1, "early-symptoms")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting early symptoms guide: {str(e)}"
        }), 500

# ============================================================================
# TRIMESTER 2 QUICK ACTIONS APIs
# ============================================================================

@app.route('/api/pregnancy/trimester-2/mid-pregnancy-scan', methods=['GET'])
@token_required
def get_mid_pregnancy_scan_guide():
    """Get mid-pregnancy scan guide for Trimester 2"""
    try:
        result = pregnancy_service.get_quick_action_guidance(2, "mid-pregnancy-scan")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting mid-pregnancy scan guide: {str(e)}"
        }), 500

@app.route('/api/pregnancy/trimester-2/glucose-screening', methods=['GET'])
@token_required
def get_glucose_screening_guide():
    """Get glucose screening guide for Trimester 2"""
    try:
        result = pregnancy_service.get_quick_action_guidance(2, "glucose-screening")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting glucose screening guide: {str(e)}"
        }), 500

@app.route('/api/pregnancy/trimester-2/fetal-movement', methods=['GET'])
@token_required
def get_fetal_movement_guide():
    """Get fetal movement guide for Trimester 2"""
    try:
        result = pregnancy_service.get_quick_action_guidance(2, "fetal-movement")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting fetal movement guide: {str(e)}"
        }), 500

@app.route('/api/pregnancy/trimester-2/birthing-classes', methods=['GET'])
@token_required
def get_birthing_classes_guide():
    """Get birthing classes guide for Trimester 2"""
    try:
        result = pregnancy_service.get_quick_action_guidance(2, "birthing-classes")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting birthing classes guide: {str(e)}"
        }), 500

@app.route('/api/pregnancy/trimester-2/nutrition-tips', methods=['GET'])
@token_required
def get_nutrition_tips_guide():
    """Get nutrition tips guide for Trimester 2"""
    try:
        result = pregnancy_service.get_quick_action_guidance(2, "nutrition-tips")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting nutrition tips guide: {str(e)}"
        }), 500

# ============================================================================
# TRIMESTER 3 QUICK ACTIONS APIs
# ============================================================================

@app.route('/api/pregnancy/trimester-3/kick-counter', methods=['GET'])
@token_required
def get_kick_counter_guide():
    """Get kick counter guide for Trimester 3"""
    try:
        result = pregnancy_service.get_quick_action_guidance(3, "kick-counter")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting kick counter guide: {str(e)}"
        }), 500

@app.route('/api/pregnancy/trimester-3/contractions', methods=['GET'])
@token_required
def get_contractions_guide():
    """Get contractions guide for Trimester 3"""
    try:
        result = pregnancy_service.get_quick_action_guidance(3, "contractions")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting contractions guide: {str(e)}"
        }), 500

@app.route('/api/pregnancy/trimester-3/birth-plan', methods=['GET'])
@token_required
def get_birth_plan_guide():
    """Get birth plan guide for Trimester 3"""
    try:
        result = pregnancy_service.get_quick_action_guidance(3, "birth-plan")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting birth plan guide: {str(e)}"
        }), 500

@app.route('/api/pregnancy/trimester-3/hospital-bag', methods=['GET'])
@token_required
def get_hospital_bag_guide():
    """Get hospital bag guide for Trimester 3"""
    try:
        result = pregnancy_service.get_quick_action_guidance(3, "hospital-bag")
        return jsonify(result), 200
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting hospital bag guide: {str(e)}"
        }), 500

# ============================================================================
# GENERAL TRIMESTER APIs
# ============================================================================

@app.route('/api/pregnancy/trimester/<int:trimester>/quick-actions', methods=['GET'])
@token_required
def get_trimester_quick_actions(trimester):
    """Get all quick actions for a specific trimester"""
    try:
        if trimester < 1 or trimester > 3:
            return jsonify({
                "success": False,
                "error": "Trimester must be 1, 2, or 3"
            }), 400
        
        trimester_enum = Trimester(trimester)
        quick_actions = pregnancy_service.get_trimester_quick_actions(trimester_enum)
        phase_info = pregnancy_service.get_trimester_phase_info(trimester_enum)
        
        formatted_actions = []
        for action in quick_actions:
            formatted_actions.append({
                "name": action.name,
                "icon": action.icon,
                "description": action.description,
                "endpoint": action.endpoint,
                "features": action.features
            })
        
        return jsonify({
            "success": True,
            "trimester": trimester,
            "phase": phase_info.get("name", ""),
            "description": phase_info.get("description", ""),
            "focus": phase_info.get("focus", ""),
            "quick_actions": formatted_actions,
            "total_actions": len(formatted_actions)
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting trimester quick actions: {str(e)}"
        }), 500

@app.route('/api/pregnancy/trimester/<int:trimester>', methods=['GET'])
@token_required
def get_trimester_info(trimester):
    """Get general information about a specific trimester"""
    try:
        if trimester < 1 or trimester > 3:
            return jsonify({
                "success": False,
                "error": "Trimester must be 1, 2, or 3"
            }), 400
        
        trimester_enum = Trimester(trimester)
        phase_info = pregnancy_service.get_trimester_phase_info(trimester_enum)
        quick_actions = pregnancy_service.get_trimester_quick_actions(trimester_enum)
        
        # Get AI insights for the trimester
        ai_prompt = f"""
        Provide comprehensive information about Trimester {trimester}:
        
        1. What are the key developmental milestones?
        2. What should the mother expect during this trimester?
        3. What are the most important care recommendations?
        4. What should she prepare for?
        
        Please provide detailed, helpful information for an expecting mother.
        """
        
        ai_insights = pregnancy_service.get_ai_insights(ai_prompt)
        
        return jsonify({
            "success": True,
            "trimester": trimester,
            "phase": phase_info.get("name", ""),
            "description": phase_info.get("description", ""),
            "focus": phase_info.get("focus", ""),
            "ai_insights": {
                "milestones": ai_insights.guidance,
                "care_recommendations": ai_insights.preparation,
                "what_to_expect": ai_insights.what_to_expect,
                "important_notes": ai_insights.important_notes
            },
            "quick_actions_count": len(quick_actions),
            "quick_actions_endpoint": f"/api/pregnancy/trimester/{trimester}/quick-actions"
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error getting trimester info: {str(e)}"
        }), 500

# ============================================================================
# HEALTH AND STATUS APIs
# ============================================================================

@app.route('/api/pregnancy/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "Pregnancy Tracking Service",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0",
        "features": [
            "Auto-trimester selection",
            "Trimester-specific quick actions",
            "AI-powered guidance",
            "Comprehensive pregnancy tracking"
        ]
    }), 200

@app.route('/api/pregnancy/openai/status', methods=['GET'])
def openai_status():
    """Check OpenAI integration status"""
    try:
        from pregnancy_tracking_service import OPENAI_AVAILABLE
        
        if OPENAI_AVAILABLE:
            return jsonify({
                "success": True,
                "openai_available": True,
                "status": "OpenAI integration active",
                "model": "gpt-3.5-turbo"
            }), 200
        else:
            return jsonify({
                "success": True,
                "openai_available": False,
                "status": "Using fallback responses",
                "note": "Install openai package and set OPENAI_API_KEY for AI features"
            }), 200
            
    except Exception as e:
        return jsonify({
            "success": False,
            "error": f"Error checking OpenAI status: {str(e)}"
        }), 500

# ============================================================================
# ERROR HANDLERS
# ============================================================================

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        "success": False,
        "error": "Endpoint not found",
        "message": "The requested pregnancy tracking endpoint does not exist"
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        "success": False,
        "error": "Internal server error",
        "message": "An unexpected error occurred in the pregnancy tracking service"
    }), 500

# ============================================================================
# MAIN APPLICATION
# ============================================================================

if __name__ == '__main__':
    print("🤰 Starting Pregnancy Tracking Service...")
    print("=" * 50)
    print("Available endpoints:")
    print("  GET  /api/pregnancy/auto-trimester/<week>")
    print("  GET  /api/pregnancy/trimester-1/*")
    print("  GET  /api/pregnancy/trimester-2/*")
    print("  GET  /api/pregnancy/trimester-3/*")
    print("  GET  /api/pregnancy/health")
    print("  GET  /api/pregnancy/openai/status")
    print("=" * 50)
    
    # Run the app
    app.run(debug=True, host='0.0.0.0', port=8000)
