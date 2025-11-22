#!/bin/bash

# Скрипт для запуска ToneLib-GFX в Docker с поддержкой графики и звука

set -e

# Цветовые коды вывода
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
NC='\\033[0m' # Нет цвета

echo -e "${GREEN}[ToneLib-GFX Docker]${NC} Подготовка среды..."

# Разрешить соединения X11 контейнера
echo -e "${YELLOW}[INFO]${NC} Разрешение соединений X11..."
if ! xhost +local:docker > /dev/null 2>&1; then
    echo -e "${YELLOW}[WARNING]${NC} Невозможно настроить xhost. Графический интерфейс может не функционировать."
fi

# Экспорт переменных окружения
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

# Запуск контейнера
echo -e "${GREEN}[START]${NC} Запускаю ToneLib-GFX..."
docker compose up

# Очистка при выходе
echo -e "${GREEN}[CLEANUP]${NC} Удаляю разрешения X11..."
xhost -local:docker > /dev/null 2>&1 || true

echo -e "${GREEN}[OK]${NC} Завершено!"
