"""
    the main server logic
"""
import flask
app = flask.Flask(__name__)

@app.route("/")
def index():
    # the index page
    return "fuckyou", 200

@app.route("/health")
def health_check():
    # healthcheck
    return "healthy", 200