\-- Таблица для хранения типов видов (классификация)
CREATE TABLE species_type (
    type_id       INTEGER PRIMARY KEY,         -- Уникальный идентификатор типа
    type_name     VARCHAR NOT NULL             -- Название типа (обязательное поле)
);

\-- Таблица для хранения информации о конкретных видах
CREATE TABLE species (
    species_id       INTEGER PRIMARY KEY,      -- Уникальный идентификатор вида
    type_id          INTEGER,                  -- Ссылка на тип вида (внешний ключ)
    species_name     VARCHAR NOT NULL,         -- Название вида (обязательное поле)
    species_amount   INTEGER,                  -- Количество особей (может быть NULL)
    date_start       DATE,                     -- Дата начала наблюдения за видом
    species_status   VARCHAR(100) NOT NULL DEFAULT 'active'::character varying, -- Статус вида
    -- Проверка допустимых значений статуса вида
    CONSTRAINT species_status_check CHECK (
        species_status::text = ANY (
            ARRAY[
                'active'::text,    -- Активный/существующий
                'absent'::text,    -- Отсутствующий
                'fairy'::text      -- Мифический/сказочный
            ]
        )
    )
);

\-- Таблица для хранения информации о местах обитания
CREATE TABLE places (
    place_id          INTEGER PRIMARY KEY,     -- Уникальный идентификатор места
    place_name        VARCHAR NOT NULL,        -- Название места (обязательное поле)
    place_size        NUMERIC(10,2),           -- Размер места (10 цифр, 2 после запятой)
    place_date_start  TIMESTAMP NOT NULL DEFAULT CURRENT_DATE -- Дата создания записи
);

\-- Таблица связи многие-ко-многим между видами и местами их обитания
CREATE TABLE species_in_places (
    place_id      INTEGER,                    -- Идентификатор места
    species_id    INTEGER,                    -- Идентификатор вида
    PRIMARY KEY (place_id, species_id)        -- Составной первичный ключ
);

\-- Фиксируем изменения в БД
COMMIT;

\-- Связываем виды с их типами
ALTER TABLE species ADD CONSTRAINT type_id_fkey 
    FOREIGN KEY (type_id) REFERENCES species_type(type_id);

\-- Связываем распределение видов с местами
ALTER TABLE species_in_places ADD CONSTRAINT place_id_fkey 
    FOREIGN KEY (place_id) REFERENCES places(place_id);

\-- Связываем распределение видов с самими видами
ALTER TABLE species_in_places ADD CONSTRAINT species_id_fkey 
    FOREIGN KEY (species_id) REFERENCES species(species_id);

	INSERT INTO species_type (type_id, type_name)
VALUES
(1, 'человек'),
(2, 'животные'),
(3, 'птицы'),
(4, 'рыбы'),
(5, 'цветы'),
(6, 'фрукты'),
(7, 'ягоды');

INSERT INTO places (place_id, place_name, place_size, place_date_start)
VALUES
(1, 'дом', 120.00, '2010-04-12 10:00:00.000'),
(2, 'сарай', 200.00, '2011-05-30 15:30:00.000'),
(3, 'сад', 350.00, '2010-04-12 12:35:15.000'),
(4, 'лес', 0.00, '1900-01-01 00:00:00.000'),
(5, 'река', 0.00, '1900-01-01 00:00:01.000');

INSERT INTO species (species_id, type_id, species_name, species_amount, date_start, species_status)
VALUES
(1, 1, 'малыш', 20, '2022-10-04', 'active'),
(2, 1, 'мужчина', 40, '2010-04-12', 'active'),
(3, 1, 'женщина', 42, '2010-04-12', 'active'),
(4, 2, 'собака', 30, '2010-05-30', 'active'),
(5, 2, 'кошка', 10, '2022-10-04', 'active'),
(6, 2, 'лошадь', 50, '2010-04-12', 'active'),
(7, 2, 'единорог', 1, '2010-04-12', 'fairy'),
(8, 2, 'лиса', 5, '2010-04-12', 'active'),
(9, 2, 'волк', 0, '2010-04-12', 'absent'),
(10, 2, 'скунс', 2, '2010-04-12', 'active'),
(11, 2, 'обезьяна', 6, '2023-04-10', 'active'),
(12, 3, 'попугай', 15, '2020-01-01', 'active'),
(13, 3, 'соловей', 7, '2010-04-12', 'active'),
(14, 3, 'дятел', 4, '2010-04-12', 'active'),
(15, 3, 'сова', 10, '2010-04-12', 'active'),
(16, 4, 'голубая рыба', 2, '2010-04-12', 'active'),
(17, 5, 'подсолнух', 1000, '2010-04-12', 'active'),
(18, 5, 'роза', 2000, '2010-04-12', 'active'),
(19, 5, 'тюльпан', 1500, '2010-04-12', 'active'),
(20, 6, 'яблоко', 0, '2010-04-12', 'absent'),
(21, 6, 'груша', 13, '2010-04-12', 'active'),
(22, 6, 'слива', 11, '2010-04-12', 'active'),
(23, 7, 'клубника', 30, '2010-04-12', 'active'),
(24, 7, 'вишня', 7, '2010-04-12', 'active');

INSERT INTO species_in_places (place_id, species_id)
VALUES(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(2, 6),
(4, 8),
(4, 9),
(4, 10),
(1, 11),
(1, 12),
(4, 13),
(4, 14),
(4, 15),
(5, 16),
(3, 17),
(3, 18),
(3, 19),
(3, 20),
(4, 20),
(3, 21),
(3, 22),
(3, 23),
(3, 24);

/*Составьте запрос, который выведет имя вида (species.species_name) с наименьшим id 
(species.species_id). Результат будет соответствовать букве «м».
*/

select s.species_name
from species AS s
order by s.species_id
limit 1;

/*Составьте запрос, который выведет имя вида (species.species_name) с количеством представителей 
(species.species_amount) более 1800. Результат будет соответствовать букве «б».*/

select s.species_name
from species AS s
where s.species_amount > 1800;

/*Составьте запрос, который выведет имя вида (species.species_name), 
начинающегося на «п» и относящегося к типу 5 (species.type_id = 5). 
Результат будет соответствовать букве «о».*/

select s.species_name
from species AS s
where s.type_id = 5 and s.species_name LIKE 'п%';

/*Составьте запрос, который выведет имя вида (species.species_name), 
заканчивающееся на «са», или количество представителей (species.species_amount) 
которого равно 5. Результат будет соответствовать букве «в».*/

select s.species_name
from species AS s
where s.species_name LIKE '%са' OR s.species_amount = 5;

/*Составьте запрос, который выведет имя вида (species.species_name), 
появившегося в 2023 году (species.date_start). Результат будет соответствовать букве «ы».*/



select s.species_name
from species AS s
where to_char(s.date_start, 'YYYY') = '2023';

/*Составьте запрос, который выведет имя (species.species_name) отсутствующего 
(species_status = 'absent') вида, расположенного в месте с id, равным 3 (places.place_id = 3). 
Для написания запроса вам понадобятся две таблицы — species и species_in_places. 
Результат будет соответствовать букве «с».*/

select s.species_name
from species AS s
inner join species_in_places AS sp on s.species_id = sp.species_id
inner join places AS p on sp.place_id = p.place_id
where s.species_status = 'absent' and p.place_id = 3;

/*Составьте запрос, который выведет имя вида (species.species_name), 
расположенного в доме (places.place_name = 'дом') и появившегося в мае (species.date_start), 
а также количество представителей вида (species.species_amount). 
Для написания запроса вам понадобятся три таблицы — species, species_in_places и places. 
Название вида будет соответствовать букве «п».*/

select s.species_name, s.species_amount
from species AS s
inner join species_in_places AS sip on s.species_id = sip.species_id
inner join places AS pl on sip.place_id = pl.place_id
where pl.place_name = 'дом' and EXTRACT(MONTH FROM s.date_start) = 5;

/*Составьте запрос, который выведет имя вида (species.species_name), 
состоящее из двух слов (содержит пробел). Результат будет соответствовать знаку «!».*/

select s.species_name
from species AS s
where s.species_name LIKE '% %';

/*Составьте запрос, который выведет имя вида (species.species_name), 
появившегося с малышом в один день(species.date_start). Результат будет соответствовать букве «ч».*/

select t1.species_name
from species AS t1
inner join species AS t2 on t1.date_start = t2.date_start
where t2.species_id = 1 and t1.species_id != 1;

/*Составьте запрос, который выведет имя вида (species.species_name), 
расположенного в здании с наибольшей площадью(places.place_size). 
Зданиями считаются только дом и сарай. Для написания запроса вам понадобятся три таблицы — 
species, species_in_places и places. Результат будет соответствовать букве «ж».*/

select sp.species_name
from species AS sp
join species_in_places AS sip on sp.species_id = sip.species_id
join places AS pl on sip.place_id = pl.place_id
where pl.place_name IN ('дом', 'сарай') and pl.place_size = (
select max(place_size)
from places
where place_name IN ('дом','сарай'));

/*Составьте запрос/запросы, которые найдут имя вида (species.species_name), 
относящегося к пятому по численности виду, проживающему дома (places.place_name='дом'). 
Для написания запроса вам понадобятся три таблицы — species, species_in_places и places. 
Результат будет соответствовать букве «ш».*/

WITH ranked_species AS (
    SELECT 
        sp.species_name,
        sp.species_amount,
        RANK() OVER (ORDER BY sp.species_amount DESC) as rank_num
    FROM species AS sp
    JOIN species_in_places AS sip ON sp.species_id = sip.species_id
    JOIN places AS pl ON sip.place_id = pl.place_id
    WHERE pl.place_name = 'дом'
)
SELECT species_name
FROM ranked_species
WHERE rank_num = 5;

select *
from species_type

/*Составьте запрос, который выведет имя сказочного вида (species.species_name), 
не расположенного ни в одном месте. Вид считается сказочным, если его статус — fairy 
(species.species_status = 'fairy'). Для написания запроса вам понадобятся две таблицы — 
species и species_in_places. Результат будет соответствовать букве «т».*/

SELECT sp.species_name
FROM species AS sp
LEFT JOIN species_in_places AS sip ON sp.species_id = sip.species_id
WHERE sp.species_status = 'fairy' AND sip.place_id IS NULL;






 
