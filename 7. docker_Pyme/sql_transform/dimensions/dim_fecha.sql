-- 1. Eliminar la tabla existente
DROP TABLE IF EXISTS dim_fecha CASCADE;

-- 2. Creación de la tabla final dim_fecha con PK de tipo INTEGER
CREATE TABLE dim_fecha (
    id_fecha INTEGER PRIMARY KEY, -- CAMBIO: Ahora es INTEGER (YYYYMMDD)
    fecha_real DATE NOT NULL,      -- Mantenemos el tipo DATE como columna informativa
    anio INTEGER NOT NULL,
    trimestre INTEGER NOT NULL,
    nombre_trimestre VARCHAR(10) NOT NULL,
    mes INTEGER NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    dia_del_mes INTEGER NOT NULL,
    dia_del_anio INTEGER NOT NULL,
    dia_de_la_semana INTEGER NOT NULL,
    nombre_dia VARCHAR(20) NOT NULL,
    es_fin_de_semana BOOLEAN NOT NULL,
    nombre_mes_anio VARCHAR(20) NOT NULL,
    clave_anio_mes INTEGER NOT NULL,
    clave_anio_trimestre INTEGER NOT NULL
);

-- 3. Generación de datos
DO $$
DECLARE
    curr_date DATE := '2016-01-01';
    end_date DATE := '2022-12-31'; -- Sugerencia: extiende un poco más por si hay entregas tardías
BEGIN
    WHILE curr_date <= end_date LOOP
        INSERT INTO dim_fecha (
            id_fecha, fecha_real, anio, trimestre, nombre_trimestre, mes, nombre_mes, 
            dia_del_mes, dia_del_anio, dia_de_la_semana, nombre_dia, es_fin_de_semana,
            nombre_mes_anio, clave_anio_mes, clave_anio_trimestre
        )
        SELECT
            -- Convertimos la fecha a entero YYYYMMDD para el ID
            TO_CHAR(curr_date, 'YYYYMMDD')::INTEGER,
            curr_date,
            EXTRACT(YEAR FROM curr_date)::INTEGER,
            EXTRACT(QUARTER FROM curr_date)::INTEGER,
            'Q' || EXTRACT(QUARTER FROM curr_date),
            EXTRACT(MONTH FROM curr_date)::INTEGER,
            TO_CHAR(curr_date, 'TMMonth'),
            EXTRACT(DAY FROM curr_date)::INTEGER,
            EXTRACT(DOY FROM curr_date)::INTEGER,
            EXTRACT(DOW FROM curr_date)::INTEGER,
            TO_CHAR(curr_date, 'TMDay'),
            CASE WHEN EXTRACT(DOW FROM curr_date) IN (0, 6) THEN TRUE ELSE FALSE END,
            TO_CHAR(curr_date, 'YYYY-Mon'),
            (EXTRACT(YEAR FROM curr_date) * 100 + EXTRACT(MONTH FROM curr_date))::INTEGER,
            (EXTRACT(YEAR FROM curr_date) * 10 + EXTRACT(QUARTER FROM curr_date))::INTEGER;

        curr_date := curr_date + interval '1 day';
    END LOOP;
END $$;
