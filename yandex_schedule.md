Чтобы работать с API, необходимо получить Токен в Яндексе:

Перейти на страницу разработчика https://developer.tech.yandex.ru/service
Зарегистрироваться, либо если есть аккаунт авторизироваться.
Нажать на кнопку "Подключить API".
Получить Ключ.
Зарегистрировать новое приложение, например AA_Kerlanov.
Скопировать сгенерированный ключ.
Зайти в постман и создать коллекцию "Яндекс.Расписания.Керланов_А.А."
Перейти во вкладку Authorization.
Кликнуть по выпадающему списку и выбрать "API Key".
В поле Ключ ввести "Autorization".
В поле Значение ввести скопированный ключ (ctrl + v).
В поле "Add to" - выбрать "header".
В первом запросе (далее новые будут создаваться с помощью Duplicate и изменяться) в разделе "Autorization" выбрать "Inherit auth from parent" (это наследство с помощью которого теперь Постман в новом запросе будет сам брать ключ API из самой коллекции).
Так же необходимо добавить переменную 'apikey' со значением (Value) ключа API Яндекса, во вкладку Variables.
Теперь наша переменная будет применяться на всю коллекцию
Пройти процедуру активации ключа.
Использовать ключ в каждом запросе к API.




Какие использую переменные и для чего.

Для начала создам в коллекции переменную с названием {BasicURL} для удобства создания запросов последующем, чтобы не вводить каждый раз URL, а так же с помощью использования переменных в запросах повышаю безопасность (больше актуально для токенов). https://api.rasp.yandex-net.ru/v3.0 - это BasicURL, основа URL'a.
В запросе "Список станций следования" требуется 'свежий' uid из любого запроса из двух: "1) расписание рейсов между станциями" или "2) расписание рейсов по станции", по этому я создал динамическую переменную в запросе "2)" (скрипт, который записывает значение каждый раз когда мы выполняем запрос), вот он:

var jsonData = pm.response.json();
var uid = jsonData.schedule[0].thread.uid;
pm.collectionVariables.set("uid", uid);
console.log("✅ UID сохранен:", uid); // позволяет при нажатии ctrl + alt + c посмотреть успешность выполнения операции в консоле.



Какие запросы и скрипты включены в коллекцию.

Расписание рейсов между станциями.

Позитивный [GET] запрос

--URL
https://api.rasp.yandex-net.ru/v3.0/search/?from=s2000005&to=s9616627

--headers

Content-Type: application/json

--[Params]

from = s2000005 
Код станции отправления "Москва (Павелецкий вокзал)"
to = s9616627 
Код станции прибытия "Симферополь-Пасс."

--Authorization

Inherit auth from parent

-- Скрипты

1)pm.test("Status code is 200", function () {pm.response.to.have.status(200);});
Проверка успешности выполнения запроса (200) - значит ОК.
2)pm.test("Content-Type is present", function () {pm.response.to.have.header("Content-Type");});
Этот тест проверяет, что сервер в своем ответе обязательно указывает заголовок Content-Type, который сообщает клиенту, в каком формате представлены данные.
3)pm.test("Тело ответа содержит искомый город Симферополь", function () {pm.expect(pm.response.text()).to.include("Симферополь");});
Этот тест проверяет, что в тексте ответа от сервера упоминается город Симферополь, так как была задана в параметрах станция в данном городе.
4)pm.test("Тело ответа содержит искомый город Москва", function () {pm.expect(pm.response.text()).to.include("Москва");});
Аналогично с предыдущим тестом про Симферополь.
5)pm.test("Response time is less than 200ms", function () {
pm.expect(pm.response.responseTime).to.be.below(200);});
Этот тест проверяет, что сервер отвечает достаточно быстро - менее чем за 200 миллисекунд.
Негативный [GET] запрос

--URL

https://api.rasp.yandex-net.ru/v3.0/search/?from=c213&to=c213

--[Params]

from = c213 
"Москва"
to = c213 
Код населенного пункта «c213» («c» от сокращенного «city»).
Совпадают точка "А" и точка "Б" в запросе, система должна выдать ошибку 400.

-- Скрипты (помимо проверки наличия Content-Type в ответе от сервера и скорости ответа (200 мс))
1)pm.test("Status code is 400", function () {pm.response.to.have.status(400);});
Должна быть ошибка на стороне клиента "400" (некорректные данные на ввод).

2. Расписание рейсов по станции.
Позитивный [GET] запрос

--URL
https://api.rasp.yandex-net.ru/v3.0/schedule/?station=s9600213

--headers

Content-Type: application/json

--[Params]

station = s9600213 

Код станции Шереметьево

-- Скрипты

1)var jsonData = pm.response.json(); var uid = jsonData.schedule[0].thread.uid; pm.collectionVariables.set("uid", uid); console.log("✅ UID сохранен:", uid);  
Для сохранения новой переменной "uid" в коллекцию, она является динамической, так как значение может перезаписываться с каждым новым запросом.  
2)pm.test("Status code is 200", function () { pm.response.to.have.status(200); }); 3)pm.test("Response time is less than 200ms", function () { pm.expect(pm.response.responseTime).to.be.below(200); });  
4)pm.test("Тело ответа содержит искомую станцию Шереметьево", function () { pm.expect(pm.response.text()).to.include("Шереметьево");  
});  
Этот тест проверяет, что в тексте ответа от сервера упоминается станция Шереметьево, так как она была задана в параметрах при отправке запроса.
Негативный GET запрос

Проверка поведения системы на невалидные данные в запросе.
--URL
https://api.rasp.yandex-net.ru/v3.0/schedule/?station=
--[Params]
station =
Нет значения ключу.
--Скрипты
1)pm.test("Status code is 400", function () { pm.response.to.have.status(400);});
Проверка корректности обработки клиентской ошибки (400-ой) сервером.
2)pm.test("Response time is less than 200ms", function () { pm.expect(pm.response.responseTime).to.be.below(200);});
3)pm.test("Content-Type is present", function () { pm.response.to.have.header("Content-Type");});



3. Список станций следования
Позитивный [GET] запрос

--URL
https://api.rasp.yandex-net.ru/v3.0/thread/?uid={{uid}} (uid значение ключа из переменной, созданной в позитивном запросе "Расписание рейсов по станции").
--headers
Content-Type: application/json
--[Params]
uid = {{uid}} // (из переменной) 
Это идентификатор нитки в Яндекс Расписаниях. Идентификатор нитки может меняться со временем. Поэтому перед каждым запросом станций нитки необходимо получать актуальный идентификатор запросом расписания рейсов между станциями или расписания рейсов по станции.
-- Скрипты
1)pm.test("Status code is 200", function () { pm.response.to.have.status(200);});
2)pm.test("Тело ответа содержит дни отправки со станции", function () {pm.expect(pm.response.text()).to.include("days");});
Поверхностно, но проверяем, содержится ли строка "days" в ответе от сервера - дни отправки транспорта по календарю.
3)pm.test("Response time is less than 200ms", function () { pm.expect(pm.response.responseTime).to.be.below(200);});
Негативный [GET] запрос

--URL
https://api.rasp.yandex-net.ru/v3.0/thread/?uid= (uid здесь не указываем)
--[Params]
Оставляем key = uid, но удаляем value (значение) = {{uid}}
-- Скрипты
1)pm.test("Status code is 400", function () { pm.response.to.have.status(400); });
Проверка корректности обработки невалидных данных сервером, ожидаем 400 ошибку, так как ошибка в запросе, например в параметрах.2)pm.test("Response time is less than 200ms", function () { pm.expect(pm.response.responseTime).to.be.below(200); });



4. Список ближайших станций
Позитивный [GET] запрос

--URL
https://api.rasp.yandex-net.ru/v3.0/nearest_stations/?lat=50.440046&lng=40.4882367&distance=50
--[Params]
lat = 50.440046
Широта согласно WGS84 
lng = 40.4882367
Долгота согласно WGS84. 
distanse = 50
Радиус, в котором следует искать станции, в километрах. 
-- Скрипты
1)pm.test("Status code is 200", function () { pm.response.to.have.status(200); });
Ожидаем успешное выполнение запроса2)pm.test("Тело ответа содержит Павловск (ближайшую станцию)", function () { pm.expect(pm.response.text()).to.include("Павловск"); });
Тело ответа по-любому должно содержать станцию "Павловск", в соответствии с заданными координатами в параметрах при запросе. Проверим, действительно ли система корректно обрабатывает вводные данные.3)pm.test("Response time is less than 200ms", function () { pm.expect(pm.response.responseTime).to.be.below(200); });
Негативный [GET] запрос

--URL
https://api.rasp.yandex-net.ru/v3.0/nearest_stations/?lat=50.440046&lng=9999999&distance=50
--[Params]
lat = 50.440046
Широта согласно WGS84 
lng = 9999999
Невалидные данные долготы. 
distanse = 50
Радиус, в котором следует искать станции, в километрах. 
-- Скрипты
1)pm.test("Status code is 400", function () { pm.response.to.have.status(400); });
Ожидаем 400 ошибку, невалидные данные (нужно исправить на валидные)2)pm.test("Response time is less than 200ms", function () { pm.expect(pm.response.responseTime).to.be.below(200); });
