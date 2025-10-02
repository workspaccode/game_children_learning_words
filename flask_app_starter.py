#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Flask Backend Starter for Game Children Learning Words
تطبيق تعليم الأطفال الكلمات - Backend Flask
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import firebase_admin
from firebase_admin import credentials, auth, firestore
from decouple import config
import logging
from datetime import datetime, timedelta
import uuid
import stripe

# ================================
# APP INITIALIZATION
# ================================

app = Flask(__name__)

# Configuration
app.config['SECRET_KEY'] = config('SECRET_KEY', default='dev-secret-key')
app.config['JWT_SECRET_KEY'] = config('JWT_SECRET_KEY', default='jwt-secret-key')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=24)

# Extensions
cors = CORS(app, origins=config('CORS_ORIGINS', default='*').split(','))
jwt = JWTManager(app)
limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ================================
# FIREBASE INITIALIZATION
# ================================

try:
    # Initialize Firebase Admin SDK
    cred = credentials.Certificate(config('FIREBASE_CREDENTIALS_PATH'))
    firebase_admin.initialize_app(cred, {
        'projectId': config('FIREBASE_PROJECT_ID'),
        'storageBucket': config('FIREBASE_STORAGE_BUCKET', default=''),
    })
    
    # Firestore client
    db = firestore.client()
    logger.info("✅ Firebase initialized successfully")
    
except Exception as e:
    logger.error(f"❌ Firebase initialization failed: {e}")
    db = None

# ================================
# PAYMENT GATEWAYS INITIALIZATION
# ================================

# Stripe
stripe.api_key = config('STRIPE_SECRET_KEY', default='')

# Payment gateway configurations
PAYMENT_GATEWAYS = {
    'stripe': {
        'enabled': bool(config('STRIPE_SECRET_KEY', default='')),
        'name': 'Stripe',
        'currencies': ['SAR', 'USD', 'EUR']
    },
    'fawry': {
        'enabled': bool(config('FAWRY_MERCHANT_CODE', default='')),
        'name': 'فوري',
        'currencies': ['EGP']
    },
    'vodafone_cash': {
        'enabled': bool(config('VODAFONE_CASH_API_KEY', default='')),
        'name': 'فودافون كاش',
        'currencies': ['EGP']
    },
    'orange_cash': {
        'enabled': bool(config('ORANGE_CASH_CLIENT_ID', default='')),
        'name': 'أورانج كاش',
        'currencies': ['EGP']
    },
    'we_cash': {
        'enabled': bool(config('WE_CASH_APP_ID', default='')),
        'name': 'WE كاش',
        'currencies': ['EGP']
    },
    'etisalat_cash': {
        'enabled': bool(config('ETISALAT_CASH_MERCHANT_CODE', default='')),
        'name': 'اتصالات كاش',
        'currencies': ['EGP']
    },
    'mada': {
        'enabled': bool(config('MADA_MERCHANT_ID', default='')),
        'name': 'مدى',
        'currencies': ['SAR']
    }
}

# ================================
# HELPER FUNCTIONS
# ================================

def verify_firebase_token(token):
    """Verify Firebase ID token and return user data"""
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        logger.error(f"Token verification failed: {e}")
        return None

def get_user_by_id(user_id):
    """Get user document from Firestore"""
    if not db:
        return None
    
    try:
        user_ref = db.collection('users').document(user_id)
        user_doc = user_ref.get()
        
        if user_doc.exists:
            return user_doc.to_dict()
        return None
    except Exception as e:
        logger.error(f"Error getting user: {e}")
        return None

def create_response(success=True, data=None, message=None, status_code=200):
    """Create standardized API response"""
    response = {
        'success': success,
        'timestamp': datetime.utcnow().isoformat(),
    }
    
    if data is not None:
        response['data'] = data
    if message:
        response['message'] = message
    if not success and not message:
        response['message'] = 'An error occurred'
    
    return jsonify(response), status_code

# ================================
# API ROUTES
# ================================

@app.route('/')
def index():
    """Health check endpoint"""
    return create_response(
        data={
            'service': 'Game Children Learning Words API',
            'version': '1.0.0',
            'status': 'healthy',
            'firebase_connected': db is not None,
            'payment_gateways': {k: v['enabled'] for k, v in PAYMENT_GATEWAYS.items()}
        },
        message='API is running successfully'
    )

@app.route('/api/health')
def health_check():
    """Detailed health check"""
    checks = {
        'api': True,
        'firebase': db is not None,
        'stripe': bool(config('STRIPE_SECRET_KEY', default='')),
        'fawry': bool(config('FAWRY_MERCHANT_CODE', default='')),
    }
    
    all_healthy = all(checks.values())
    status_code = 200 if all_healthy else 503
    
    return create_response(
        success=all_healthy,
        data={
            'checks': checks,
            'timestamp': datetime.utcnow().isoformat()
        },
        message='All systems operational' if all_healthy else 'Some systems are down',
        status_code=status_code
    )

# ================================
# AUTHENTICATION ROUTES
# ================================

@app.route('/api/auth/login', methods=['POST'])
@limiter.limit("5 per minute")
def login():
    """Authenticate user with Firebase token"""
    try:
        data = request.get_json()
        if not data or 'firebase_token' not in data:
            return create_response(
                success=False,
                message='Firebase token is required',
                status_code=400
            )
        
        # Verify Firebase token
        firebase_user = verify_firebase_token(data['firebase_token'])
        if not firebase_user:
            return create_response(
                success=False,
                message='Invalid Firebase token',
                status_code=401
            )
        
        user_id = firebase_user['uid']
        
        # Get user from database
        user_data = get_user_by_id(user_id)
        if not user_data:
            return create_response(
                success=False,
                message='User not found in database',
                status_code=404
            )
        
        # Create JWT access token
        access_token = create_access_token(
            identity=user_id,
            additional_claims={
                'user_type': user_data.get('userType', 'user'),
                'email': user_data.get('email', ''),
            }
        )
        
        return create_response(
            data={
                'access_token': access_token,
                'user': {
                    'id': user_id,
                    'email': user_data.get('email'),
                    'displayName': user_data.get('displayName'),
                    'userType': user_data.get('userType'),
                    'profile': user_data.get('profile', {})
                }
            },
            message='Login successful'
        )
        
    except Exception as e:
        logger.error(f"Login error: {e}")
        return create_response(
            success=False,
            message='Login failed',
            status_code=500
        )

# ================================
# USER MANAGEMENT ROUTES
# ================================

@app.route('/api/users/profile', methods=['GET'])
@jwt_required()
def get_user_profile():
    """Get current user profile"""
    try:
        user_id = get_jwt_identity()
        user_data = get_user_by_id(user_id)
        
        if not user_data:
            return create_response(
                success=False,
                message='User not found',
                status_code=404
            )
        
        # Get additional data based on user type
        additional_data = {}
        
        if user_data.get('userType') == 'parent':
            # Get children
            children_ref = db.collection('users').where('parentId', '==', user_id)
            children_docs = children_ref.get()
            additional_data['children'] = [doc.to_dict() for doc in children_docs]
            
            # Get subscriptions
            subs_ref = db.collection('subscriptions').where('parentId', '==', user_id)
            subs_docs = subs_ref.get()
            additional_data['subscriptions'] = [doc.to_dict() for doc in subs_docs]
        
        elif user_data.get('userType') == 'teacher':
            # Get classrooms
            classrooms_ref = db.collection('classrooms').where('teacherId', '==', user_id)
            classrooms_docs = classrooms_ref.get()
            additional_data['classrooms'] = [doc.to_dict() for doc in classrooms_docs]
            
            # Get subscriptions (as teacher)
            subs_ref = db.collection('subscriptions').where('teacherId', '==', user_id)
            subs_docs = subs_ref.get()
            additional_data['subscriptions'] = [doc.to_dict() for doc in subs_docs]
        
        return create_response(
            data={
                **user_data,
                **additional_data
            }
        )
        
    except Exception as e:
        logger.error(f"Get profile error: {e}")
        return create_response(
            success=False,
            message='Failed to get profile',
            status_code=500
        )

# ================================
# PAYMENT ROUTES
# ================================

@app.route('/api/payments/gateways', methods=['GET'])
@jwt_required()
def get_payment_gateways():
    """Get available payment gateways"""
    try:
        country_code = request.args.get('country', 'EG').upper()
        
        available_gateways = []
        
        for gateway_id, gateway_info in PAYMENT_GATEWAYS.items():
            if not gateway_info['enabled']:
                continue
                
            # Filter by country
            if country_code == 'EG' and gateway_id in ['vodafone_cash', 'orange_cash', 'we_cash', 'etisalat_cash', 'fawry']:
                available_gateways.append({
                    'id': gateway_id,
                    'name': gateway_info['name'],
                    'currencies': gateway_info['currencies'],
                    'type': 'mobile_wallet' if 'cash' in gateway_id else 'payment_service'
                })
            elif country_code == 'SA' and gateway_id in ['mada', 'stripe']:
                available_gateways.append({
                    'id': gateway_id,
                    'name': gateway_info['name'],
                    'currencies': gateway_info['currencies'],
                    'type': 'card' if gateway_id == 'mada' else 'payment_service'
                })
            elif gateway_id == 'stripe':  # Global
                available_gateways.append({
                    'id': gateway_id,
                    'name': gateway_info['name'],
                    'currencies': gateway_info['currencies'],
                    'type': 'payment_service'
                })
        
        return create_response(
            data={
                'gateways': available_gateways,
                'country': country_code
            }
        )
        
    except Exception as e:
        logger.error(f"Get gateways error: {e}")
        return create_response(
            success=False,
            message='Failed to get payment gateways',
            status_code=500
        )

@app.route('/api/payments/create-intent', methods=['POST'])
@jwt_required()
@limiter.limit("10 per minute")
def create_payment_intent():
    """Create payment intent for subscription"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        required_fields = ['amount', 'currency', 'gateway', 'subscription_id']
        if not all(field in data for field in required_fields):
            return create_response(
                success=False,
                message='Missing required fields',
                status_code=400
            )
        
        # Validate gateway
        gateway = data['gateway']
        if gateway not in PAYMENT_GATEWAYS or not PAYMENT_GATEWAYS[gateway]['enabled']:
            return create_response(
                success=False,
                message='Invalid or disabled payment gateway',
                status_code=400
            )
        
        # Create payment intent based on gateway
        intent_id = str(uuid.uuid4())
        
        if gateway == 'stripe':
            # Create Stripe payment intent
            intent = stripe.PaymentIntent.create(
                amount=int(data['amount'] * 100),  # Convert to cents
                currency=data['currency'].lower(),
                metadata={
                    'user_id': user_id,
                    'subscription_id': data['subscription_id'],
                    'intent_id': intent_id
                }
            )
            
            payment_intent_data = {
                'id': intent_id,
                'client_secret': intent.client_secret,
                'amount': data['amount'],
                'currency': data['currency'],
                'gateway': gateway,
                'stripe_payment_intent_id': intent.id,
                'expires_at': (datetime.utcnow() + timedelta(hours=1)).isoformat()
            }
        
        else:
            # For other gateways, create basic intent
            # (In production, you would integrate with actual gateway APIs)
            payment_intent_data = {
                'id': intent_id,
                'client_secret': f"{gateway}_intent_{intent_id}",
                'amount': data['amount'],
                'currency': data['currency'],
                'gateway': gateway,
                'payment_url': f"https://sandbox-{gateway}.com/pay/{intent_id}",
                'expires_at': (datetime.utcnow() + timedelta(minutes=30)).isoformat()
            }
        
        # Store payment intent in database
        db.collection('payment_intents').document(intent_id).set({
            **payment_intent_data,
            'user_id': user_id,
            'subscription_id': data['subscription_id'],
            'status': 'created',
            'created_at': datetime.utcnow().isoformat()
        })
        
        return create_response(
            data={'payment_intent': payment_intent_data},
            message='Payment intent created successfully'
        )
        
    except Exception as e:
        logger.error(f"Create payment intent error: {e}")
        return create_response(
            success=False,
            message='Failed to create payment intent',
            status_code=500
        )

# ================================
# ERROR HANDLERS
# ================================

@app.errorhandler(404)
def not_found(error):
    return create_response(
        success=False,
        message='Endpoint not found',
        status_code=404
    )

@app.errorhandler(500)
def internal_error(error):
    return create_response(
        success=False,
        message='Internal server error',
        status_code=500
    )

@app.errorhandler(429)
def rate_limit_error(error):
    return create_response(
        success=False,
        message='Rate limit exceeded',
        status_code=429
    )

# ================================
# MAIN
# ================================

if __name__ == '__main__':
    # Development server
    app.run(
        host=config('FLASK_HOST', default='127.0.0.1'),
        port=config('FLASK_PORT', default=5000, cast=int),
        debug=config('DEBUG', default=True, cast=bool)
    )