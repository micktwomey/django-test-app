FROM python:3.13-slim-bookworm
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN mkdir -p /app
WORKDIR /app

# Install just our dependencies to speed up builds with caching
COPY pyproject.toml .
COPY uv.lock .
COPY .python-version .
RUN uv sync --locked --no-install-project

# Now install the app
COPY django_test_app/ django_test_app/
COPY manage.py .
RUN uv sync --locked

ENV DJANGO_SETTINGS_MODULE="django_test_app.settings"
EXPOSE 8000
CMD ["uv", "run", "hypercorn", "--bind", "0.0.0.0:8000", "django_test_app.asgi:application"]
