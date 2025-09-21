#!/bin/sh
cd ./scaw
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic --noinput
gunicorn scaw.wsgi:application --bind 0.0.0.0:8000