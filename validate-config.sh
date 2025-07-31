#!/bin/bash

# Скрипт для валидации конфигурации Alertmanager

set -e

echo "🔍 Проверка конфигурации Alertmanager..."

# Проверяем наличие Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен"
    exit 1
fi

# Проверяем наличие конфигурационного файла
if [ ! -f "alertmanager.yml" ]; then
    echo "❌ Файл alertmanager.yml не найден"
    exit 1
fi

# Проверяем наличие шаблонов
if [ ! -d "templates" ]; then
    echo "❌ Директория templates не найдена"
    exit 1
fi

if [ ! -f "templates/email.tmpl" ]; then
    echo "❌ Файл templates/email.tmpl не найден"
    exit 1
fi

if [ ! -f "templates/telegram.tmpl" ]; then
    echo "❌ Файл templates/telegram.tmpl не найден"
    exit 1
fi

# Валидируем конфигурацию с помощью Alertmanager
echo "📋 Валидация конфигурации..."
docker run --rm \
    -v "$(pwd)/alertmanager.yml:/etc/alertmanager/alertmanager.yml" \
    -v "$(pwd)/templates:/etc/alertmanager/template" \
    prom/alertmanager:latest \
    --config.file=/etc/alertmanager/alertmanager.yml \
    --check-config

if [ $? -eq 0 ]; then
    echo "✅ Конфигурация валидна!"
else
    echo "❌ Ошибка в конфигурации"
    exit 1
fi

# Проверяем синтаксис YAML
echo "📝 Проверка синтаксиса YAML..."
if command -v python3 &> /dev/null; then
    python3 -c "import yaml; yaml.safe_load(open('alertmanager.yml'))"
    echo "✅ YAML синтаксис корректен"
elif command -v python &> /dev/null; then
    python -c "import yaml; yaml.safe_load(open('alertmanager.yml'))"
    echo "✅ YAML синтаксис корректен"
else
    echo "⚠️ Python не найден, пропускаем проверку YAML"
fi

echo "🎉 Все проверки пройдены успешно!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Обновите настройки в alertmanager.yml"
echo "2. Создайте файл .env на основе env.example"
echo "3. Запустите: docker-compose up -d"
echo "4. Откройте http://localhost:9093 для проверки" 