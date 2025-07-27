from django.http import HttpResponse
from django.utils.deprecation import MiddlewareMixin
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

class HealthCheckMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.path == '/healthy':
            return HttpResponse('OK')
        return self.get_response(request)


class OpenTelemetryMiddleware(MiddlewareMixin):
    def process_request(self, request):
        with tracer.start_as_current_span("middleware_request") as span:
            span.set_attribute("path", request.path)
            span.set_attribute("method", request.method)

    def process_response(self, request, response):
        return response
