# Практическая работа №1 — Локальный Lakehouse: медальон и бенчмарк сжатия

**Автор:** Мань Линь Во · **Вариант:** 2 — TPC-H Q10 «Returned Item Reporting» · **Масштаб:** sf1

Полный отчёт с обоснованиями и результатами — в [`отчет.md`](отчет.md).

## Стек

MinIO (S3) → Lakekeeper (Iceberg REST Catalog, метаданные в PostgreSQL) → Trino (SQL-движок) + Spark (второй движок для чтения Bronze). Всё в Docker Desktop на Windows.

```
tpch.sf1 ──CTAS──► bronze.q10 ──очистка/обогащение──► silver.q10 ──агрегат──► gold.q10
(генератор)        4 сырые таблицы    customer_enriched,            top_returned_customers
                                      returned_items (year-партиции)   (топ-20)
```

## Структура репозитория

| Путь | Содержимое |
|---|---|
| `отчет.md` | Отчёт: сервисы, медальон, бенчмарк, schema evolution, time travel, Spark, выводы |
| `sql/01_bronze.sql` | Bronze: сырые `nation`, `customer`, `orders`, `lineitem` (PARQUET + ZSTD) |
| `sql/02_silver.sql` | Silver: `customer_enriched` и `returned_items` (партиции по `year(orderdate)`) |
| `sql/03_gold.sql` | Gold: топ-20 клиентов по выручке от возвратов за Q4 1993 |
| `sql/04_bench_*.sql` | Bronze с кодеками NONE / SNAPPY / GZIP / ZSTD для бенчмарка |
| `sql/05_q10_template.sql` | Запрос Q10 для замеров (`__S__` = схема) |
| `sql/06_schema_evolution.sql` | ADD COLUMN + MERGE + RENAME COLUMN на Silver |
| `sql/07_time_travel.sql` | Ошибочный UPDATE → `FOR VERSION AS OF` → `rollback_to_snapshot` |
| `sql/08_spark_bronze.sql` | Чтение Bronze из Spark |
| `results/*.csv` | Сырые результаты бенчмарка (запись, размер, время Q10) |
| `config/*.properties` | Каталоги Trino (`bronze`, `silver`, `gold`, `tpch`) |
| `spark/spark-defaults.conf` | Подключение Spark к Lakekeeper и MinIO |

## Методология (кратко)

1. **Пайплайн:** скрипты `01`→`02`→`03` выполняются в Trino (`trino --file`). Корректность Gold проверена сравнением с эталонным Q10 на `tpch.sf1`: 20/20 клиентов, расхождение ≤ 1,2·10⁻¹⁰.
2. **Размер:** сумма `file_size_in_bytes` из системной таблицы Iceberg `"<таблица>$files"`.
3. **Время записи:** 4 CTAS Bronze подряд, замер `Measure-Command` в PowerShell.
4. **Время запроса:** перед каждым кодеком перезапуск Trino и MinIO (сброс кэшей) → 1 холодный + 2 тёплых прогона Q10; каждый прогон проверен на 20 строк.
5. Trino запущен с `JAVA_TOOL_OPTIONS=-Xmx2G` — ограничение памяти под машину с 7,6 ГБ RAM.

## Главный результат бенчмарка (Bronze, PARQUET, sf1)

| Кодек | Размер, МБ | Запись, с | Q10 холодный, с | Q10 тёплый, с |
|---|---|---|---|---|
| NONE | 489,6 | 27,3 | 10,00 | 6,94 |
| SNAPPY | 259,4 | 16,8 | 7,85 | 5,18 |
| GZIP | 183,2 | 25,9 | 6,98 | 3,48 |
| **ZSTD** | 188,3 | **15,0** | **6,87** | **3,29** |

ZSTD выбран для всех слоёв: размер на уровне GZIP, при этом самая быстрая запись и самый быстрый запрос.
