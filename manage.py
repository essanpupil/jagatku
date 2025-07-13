#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys

from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
    ConsoleSpanExporter,
)
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.instrumentation.django import DjangoInstrumentor

# Create resource with service information
resrouce = Resource(attributes={
    SERVICE_NAME: "jagatku"
})

# Create and configure the tracer provder
provider = TracerProvider(resource=resrouce)
processor = BatchSpanProcessor(ConsoleSpanExporter())
provider.add_span_processor(processor)

# Set global default tracer provider
trace.set_tracer_provider(provider)

# Create a tracer from the global tracer provider
tracer = trace.get_tracer("tracer.jagat")

def main():
    """Run administrative tasks."""
    # django setting module must be set before instrumenting
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'jagatku.settings')

    # Initialize django instrumentation
    DjangoInstrumentor().instrument()

    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()
