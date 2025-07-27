bind = "0.0.0.0:8000"
wsgi_app = "jagatku.asgi:application"
worker_class = "jagatku.uvicorn.MyUvicornWorker"
