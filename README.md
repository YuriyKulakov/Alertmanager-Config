# Alertmanager Configuration

Конфигурация Alertmanager для отправки уведомлений по email и Telegram.

## Структура файлов

```
alertmanager-config/
├── alertmanager.yml          # Основная конфигурация
├── templates/
│   ├── email.tmpl           # Шаблоны для email
│   └── telegram.tmpl        # Шаблоны для Telegram
├── docker-compose.yml       # Docker Compose для запуска
└── README.md               # Этот файл
```

## Настройка Email

### Gmail SMTP

1. Включите двухфакторную аутентификацию в Google аккаунте
2. Создайте пароль приложения:
   - Перейдите в настройки безопасности Google
   - Выберите "Пароли приложений"
   - Создайте новый пароль для "Почта"
3. Обновите конфигурацию в `alertmanager.yml`:

```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'your-email@gmail.com'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'
```

### Другие SMTP серверы

Для других SMTP серверов измените настройки:

```yaml
global:
  smtp_smarthost: 'your-smtp-server:587'
  smtp_from: 'alertmanager@yourdomain.com'
  smtp_auth_username: 'your-username'
  smtp_auth_password: 'your-password'
```

## Настройка Telegram

### Создание бота

1. Найдите @BotFather в Telegram
2. Отправьте команду `/newbot`
3. Следуйте инструкциям для создания бота
4. Получите токен бота

### Получение Chat ID

1. Добавьте бота в нужную группу или начните с ним чат
2. Отправьте сообщение боту
3. Откройте в браузере: `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
4. Найдите `chat_id` в ответе

### Обновление конфигурации

Замените в `alertmanager.yml`:

```yaml
telegram_configs:
- bot_token: 'YOUR_BOT_TOKEN'
  chat_id: 'YOUR_CHAT_ID'
```

## Настройка получателей

Обновите email адреса в конфигурации:

```yaml
receivers:
- name: 'team-notifications'
  email_configs:
  - to: 'team@yourdomain.com'  # Замените на реальный email

- name: 'critical-alerts'
  email_configs:
  - to: 'admin@yourdomain.com'  # Замените на реальный email
```

## Запуск с Docker Compose

Создайте файл `docker-compose.yml`:

```yaml
version: '3.8'

services:
  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - ./templates:/etc/alertmanager/template
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    restart: unless-stopped
```

## Запуск

```bash
cd alertmanager-config
docker-compose up -d
```

## Проверка конфигурации

1. Откройте веб-интерфейс: http://localhost:9093
2. Перейдите в раздел "Configuration" для проверки настроек
3. Используйте "Test" для отправки тестового уведомления

## Интеграция с Prometheus

Добавьте в конфигурацию Prometheus:

```yaml
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

## Примеры алертов

### Критический алерт
```yaml
- alert: HighCPUUsage
  expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "High CPU usage on {{ $labels.instance }}"
    description: "CPU usage is {{ $value }}% on {{ $labels.instance }}"
```

### Предупреждение
```yaml
- alert: HighMemoryUsage
  expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High memory usage on {{ $labels.instance }}"
    description: "Memory usage is {{ $value }}% on {{ $labels.instance }}"
```

## Безопасность

1. Не храните пароли в открытом виде в конфигурации
2. Используйте переменные окружения или секреты
3. Ограничьте доступ к Alertmanager веб-интерфейсу
4. Регулярно обновляйте токены и пароли

## Мониторинг Alertmanager

Добавьте алерты для самого Alertmanager:

```yaml
- alert: AlertmanagerDown
  expr: up{job="alertmanager"} == 0
  for: 1m
  labels:
    severity: critical
  annotations:
    summary: "Alertmanager is down"
    description: "Alertmanager instance {{ $labels.instance }} is down"
``` 

Author: Yuriy Kulakov
