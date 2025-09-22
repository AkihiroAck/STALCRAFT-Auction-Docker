#!/bin/sh
cd ./scaw


python manage.py makemigrations
python manage.py migrate

echo "Восстанавливаем данные..."
ITEM_COUNT=$(PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USERNAME -d $POSTGRES_DATABASE_NAME -t -c "SELECT COUNT(*) FROM public.auction_item" | tr -d ' ')
SALEHISTORY_COUNT=$(PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USERNAME -d $POSTGRES_DATABASE_NAME -t -c "SELECT COUNT(*) FROM public.auction_salehistory" | tr -d ' ')

if [ "$SALEHISTORY_COUNT" -eq "0" ] && [ "$ITEM_COUNT" -eq "0" ]; then
    echo "Таблица пустая, выполняем импорт..."
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USERNAME -d $POSTGRES_DATABASE_NAME -f ../auction_item.sql
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USERNAME -d $POSTGRES_DATABASE_NAME -f ../auction_salehistory.sql
else
    echo "Импорт пропущен. В таблицах уже есть данные (items: $ITEM_COUNT, salehistory: $SALEHISTORY_COUNT)"
fi


python manage.py collectstatic --noinput
gunicorn scaw.wsgi:application --bind 0.0.0.0:8000