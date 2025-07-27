from uvicorn_worker import UvicornWorker


class MyUvicornWorker(UvicornWorker):
    CONFIG_KWARGS = {"lifespan": "off"}
