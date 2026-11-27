from flask import Flask
from flask_socketio import SocketIO
from app.Blueprints.Dashboard.dashboard import dashboard_bp
from app.Blueprints.Ingestion.ingestion import ingestion_bp
from app.WebSocket.events import init_websocket_events, simulate_live_traffic
import os

app = Flask(__name__, static_folder='app/static/')
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret')

socketio = SocketIO(app, cors_allowed_origins="*")

init_websocket_events(socketio)

app.register_blueprint(dashboard_bp)
app.register_blueprint(ingestion_bp)

# ✅ Always run simulation when the app starts
simulate_live_traffic()

# ✅ This only runs when starting locally
if __name__ == '__main__':
    socketio.run(app, debug=False, host='0.0.0.0', port=1122)
