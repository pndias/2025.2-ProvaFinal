#!/bin/bash
set -e

APP_DIR="$(cd "$(dirname "$0")" && pwd)/app"
IMAGE_NAME="django-dev"
CONTAINER_NAME="django-dev-container"
PORT=8000

echo "=== 1. Construindo imagem Docker ==="
docker build -t "$IMAGE_NAME" -f "$APP_DIR/Dockerfile.dev" "$APP_DIR"

echo "=== 2. Removendo container anterior (se existir) ==="
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

echo "=== 3. Iniciando container com volume e porta mapeados ==="
docker run -d --name "$CONTAINER_NAME" \
  -p "$PORT:$PORT" \
  -v "$APP_DIR:/app" \
  "$IMAGE_NAME" \
  sleep infinity

echo "=== 4. Criando projeto Django (se não existir) ==="
if [ ! -f "$APP_DIR/manage.py" ]; then
  docker exec "$CONTAINER_NAME" django-admin startproject meusite .
fi

echo "=== 5. Criando aplicação (se não existir) ==="
if [ ! -d "$APP_DIR/principal" ]; then
  docker exec "$CONTAINER_NAME" python3 manage.py startapp principal
fi

echo "=== 6. Executando migrações ==="
docker exec "$CONTAINER_NAME" python3 manage.py migrate

echo "=== 7. Criando superusuário (admin/admin123) ==="
docker exec -e DJANGO_SUPERUSER_PASSWORD=admin123 "$CONTAINER_NAME" \
  python3 manage.py createsuperuser --username admin --email admin@example.com --noinput 2>/dev/null || echo "Superusuário já existe."

echo "=== 8. Iniciando servidor de desenvolvimento ==="
docker exec -d "$CONTAINER_NAME" python3 manage.py runserver 0.0.0.0:$PORT

echo ""
echo "Pronto! Acesse:"
echo "  Home:  http://localhost:$PORT/"
echo "  Admin: http://localhost:$PORT/admin/"
echo ""
echo "Para parar: docker stop $CONTAINER_NAME"
echo "Para logs:  docker logs -f $CONTAINER_NAME"
