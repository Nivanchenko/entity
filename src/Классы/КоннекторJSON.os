#Использовать asserts
#Использовать fluent
#Использовать fs
#Использовать json
#Использовать logos
#Использовать semaphore

// Для хранения статуса соединения
Перем Открыт;

Перем ПарсерJSON;
Перем БазовыйКаталог;
Перем ХранилищеВПамяти;

Перем Лог;

// Конструктор объекта АбстрактныйКоннектор.
//
Процедура ПриСозданииОбъекта()
	
	Открыт = Ложь;
	Лог = Логирование.ПолучитьЛог("oscript.lib.entity.connector.json");
	ПарсерJSON = Новый ПарсерJSON;

КонецПроцедуры

// Открыть соединение с БД.
//
// Параметры:
//   СтрокаСоединения - Строка - Строка соединения с БД.
//   ПараметрыКоннектора - Массив - Дополнительные параметры инициализиации коннектора.
//
Процедура Открыть(СтрокаСоединения, ПараметрыКоннектора) Экспорт
	Открыт = Истина;
	Лог.Отладка("Открытие коннектора со строкой соединения %1", СтрокаСоединения);
	Ожидаем.Что(ФС.КаталогСуществует(СтрокаСоединения), "Существует каталог для выгрузки данных сущностей");
	БазовыйКаталог = СтрокаСоединения;
КонецПроцедуры

// Закрыть соединение с БД.
//
Процедура Закрыть() Экспорт
	Открыт = Ложь;
КонецПроцедуры

// Получить статус соединения с БД.
//
//  Возвращаемое значение:
//   Булево - Состояние соединения. Истина, если соединение установлено и готово к использованию.
//       В обратном случае - Ложь.
//
Функция Открыт() Экспорт
	Возврат Открыт;
КонецФункции

// Начинает новую транзакцию в БД.
//
Процедура НачатьТранзакцию() Экспорт
	ВызватьИсключение "Не поддерживается";
КонецПроцедуры

// Фиксирует открытую транзакцию в БД.
//
Процедура ЗафиксироватьТранзакцию() Экспорт
	ВызватьИсключение "Не поддерживается";
КонецПроцедуры

// Отменяет открытую транзакцию в БД.
//
Процедура ОтменитьТранзакцию() Экспорт
	ВызватьИсключение "Не поддерживается";
КонецПроцедуры

// Создает таблицу в БД по данным модели.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//
Процедура ИнициализироватьТаблицу(ОбъектМодели) Экспорт
	ИмяФайла = ОбъединитьПути(БазовыйКаталог, ОбъектМодели.ИмяТаблицы()) + ".json";
	Если НЕ ФС.Существует(ИмяФайла) Тогда
		Лог.Отладка("Инициализация таблицы %1 в файле %1", ОбъектМодели.ИмяТаблицы(), ИмяФайла);
		Таблица = Новый Соответствие;
		ЗаписатьОбъектВФайл(Таблица, ИмяФайла);
	КонецЕсли;
КонецПроцедуры

// Сохраняет сущность в БД.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//   Сущность - Произвольный - Объект (экземпляр класса, зарегистрированного в модели) для сохранения в БД.
//
Процедура Сохранить(ОбъектМодели, Сущность) Экспорт
	ИмяФайла = ОбъединитьПути(БазовыйКаталог, ОбъектМодели.ИмяТаблицы()) + ".json";
	Семафор = Семафоры.Получить(ИмяФайла);
	Семафор.Захватить();

	Таблица = ПрочитатьОбъектИзФайла(ИмяФайла);

	Идентификатор = ОбъектМодели.ПолучитьЗначениеИдентификатора(Сущность);
	Если НЕ ЗначениеЗаполнено(Идентификатор) Тогда
		
		Если ОбъектМодели.Идентификатор().ТипКолонки <> ТипыКолонок.Целое Тогда
			Сообщение = СтрШаблон(
				"Ошибка при сохранении сущности с типом %1.
				|Генерация идентификаторов поддерживается только для колонок с типом ""Целое""",
				ОбъектМодели.ТипСущности()
			);
			ВызватьИсключение Сообщение;
		КонецЕсли;

		МаксимальныйИдентификатор = ПроцессорыКоллекций.ИзКоллекции(Таблица)
		    .Обработать("Результат = Число(Элемент.Ключ)")
			.Максимум();
		
		Если МаксимальныйИдентификатор = Неопределено Тогда
			МаксимальныйИдентификатор = 0;
		КонецЕсли;

		Идентификатор = МаксимальныйИдентификатор + 1;

		ОбъектМодели.УстановитьЗначениеКолонкиВПоле(
			Сущность,
			ОбъектМодели.Идентификатор().ИмяКолонки,
			Идентификатор
		);

	КонецЕсли;
	Если ТипЗнч(Идентификатор) = Тип("Число") Тогда
		Идентификатор = Формат(Идентификатор, "ЧГ=");
	КонецЕсли;
	
	Лог.Отладка("Сохранение сущности с типом %1 и идентификатором %2", ОбъектМодели.ТипСущности(), Идентификатор);
	
	Таблица.Вставить(Идентификатор, РазложитьОбъектВСоответствие(Сущность, ОбъектМодели));
	ЗаписатьОбъектВФайл(Таблица, ИмяФайла, ОбъектМодели);

	Семафор.Освободить();

КонецПроцедуры

// Удаляет сущность из таблицы БД.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//   Сущность - Произвольный - Объект (экземпляр класса, зарегистрированного в модели) для удаления из БД.
//
Процедура Удалить(ОбъектМодели, Сущность) Экспорт
	
	ИмяФайла = ОбъединитьПути(БазовыйКаталог, ОбъектМодели.ИмяТаблицы()) + ".json";
	Семафор = Семафоры.Получить(ИмяФайла);
	Семафор.Захватить();
		
	Таблица = ПрочитатьОбъектИзФайла(ИмяФайла);

	Идентификатор = ОбъектМодели.ПолучитьЗначениеИдентификатора(Сущность);
	Если ТипЗнч(Идентификатор) = Тип("Число") Тогда
		Идентификатор = Формат(Идентификатор, "ЧГ=");
	КонецЕсли;

	Лог.Отладка(
		"Удаление сущности с типом %1 и идентификатором %2",
		ОбъектМодели.ТипСущности(),
		Идентификатор
	);

	Таблица.Удалить(Идентификатор);

	ЗаписатьОбъектВФайл(Таблица, ИмяФайла, ОбъектМодели);
	
	Семафор.Освободить();

КонецПроцедуры

// Осуществляет поиск строк в таблице по указанному отбору.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//   Отбор - Массив - Отбор для поиска. Каждый элемент массива должен иметь тип "ЭлементОтбора".
//       Каждый элемент отбора преобразуется к условию поиска. В качестве "ПутьКДанным" указываются имена колонок.
//
//  Возвращаемое значение:
//   Массив - Массив, элементами которого являются "Соответствия". Ключом элемента соответствия является имя колонки,
//     значением элемента соответствия - значение колонки.
//
Функция НайтиСтрокиВТаблице(ОбъектМодели, Знач Отбор) Экспорт

	НайденныеСтроки = Новый Массив;

	ИмяФайла = ОбъединитьПути(БазовыйКаталог, ОбъектМодели.ИмяТаблицы()) + ".json";
	Таблица = ПрочитатьОбъектИзФайла(ИмяФайла);
	
	Лог.Отладка("Поиск сущностей в таблице %1", ОбъектМодели.ИмяТаблицы());
	
	ПроцессорКоллекций = ПроцессорыКоллекций.ИзКоллекции(Таблица);
	
	Для Каждого ЭлементОтбора Из Отбор Цикл
		СтрокаУсловие = СтрШаблон(
			"Результат = Элемент.Значение.Получить(""%1"") %2 ДополнительныеПараметры.Значение",
			ЭлементОтбора.ПутьКДанным,
			ЭлементОтбора.ВидСравнения
		);
		ДополнительныеПараметры = Новый Структура("Значение", ЭлементОтбора.Значение);
		ПроцессорКоллекций = ПроцессорКоллекций.Фильтровать(СтрокаУсловие, ДополнительныеПараметры);
	КонецЦикла;

	ДанныеТаблицы = ПроцессорКоллекций.ВМассив();
	
	Для Каждого СтрокаДанныхТаблицы Из ДанныеТаблицы Цикл
		ЗначенияКолонок = Новый Соответствие;
		Для Каждого Колонка Из ОбъектМодели.Колонки() Цикл
			Если Колонка.ТипКолонки = ТипыКолонок.ДвоичныеДанные Тогда
				Значение = ПолучитьДвоичныеДанныеИзBase64Строки(СтрокаДанныхТаблицы.Значение.Получить(Колонка.ИмяКолонки));
			Иначе
				Значение = СтрокаДанныхТаблицы.Значение.Получить(Колонка.ИмяКолонки);
			КонецЕсли;
			ЗначенияКолонок.Вставить(Колонка.ИмяКолонки, Значение);
		КонецЦикла;
		НайденныеСтроки.Добавить(ЗначенияКолонок);
	КонецЦикла;

	Возврат НайденныеСтроки;
КонецФункции

// Удаляет строки в таблице по указанному отбору.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//   Отбор - Массив - Отбор для поиска. Каждый элемент массива должен иметь тип "ЭлементОтбора".
//       Каждый элемент отбора преобразуется к условию поиска. В качестве "ПутьКДанным" указываются имена колонок.
//
Процедура УдалитьСтрокиВТаблице(ОбъектМодели, Знач Отбор) Экспорт
	
	Лог.Отладка("Удаление сущностей в таблице %1", ОбъектМодели.ИмяТаблицы());

	ИмяФайла = ОбъединитьПути(БазовыйКаталог, ОбъектМодели.ИмяТаблицы()) + ".json";
	Семафор = Семафоры.Получить(ИмяФайла);
	Семафор.Захватить();
	
	НайденныеСтроки = НайтиСтрокиВТаблице(ОбъектМодели, Отбор);
	
	Лог.Отладка("К удалению сущностей: %1 шт.", НайденныеСтроки.Количество());

	Таблица = ПрочитатьОбъектИзФайла(ИмяФайла);
	
	Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
		Идентификатор = НайденнаяСтрока.Получить(ОбъектМодели.Идентификатор().ИмяКолонки);
		Если ТипЗнч(Идентификатор) = Тип("Число") Тогда
			Идентификатор = Формат(Идентификатор, "ЧГ=");
		КонецЕсли;

		Таблица.Удалить(Идентификатор);
	КонецЦикла;

	ЗаписатьОбъектВФайл(Таблица, ИмяФайла, ОбъектМодели);

	Семафор.Освободить();

КонецПроцедуры

Процедура ЗаписатьОбъектВФайл(Значение, ИмяФайла, ОбъектМодели = Неопределено)
	ТекстJSON = ПарсерJSON.ЗаписатьJSON(Значение);
	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла, "UTF-8");
	ЗаписьТекста.Записать(ТекстJSON);
	ЗаписьТекста.Закрыть();
КонецПроцедуры

Функция РазложитьОбъектВСоответствие(Значение, ОбъектМодели)
	Соответствие = Новый Соответствие;
	Для Каждого Колонка Из ОбъектМодели.Колонки() Цикл
		ЗначениеПараметра = ОбъектМодели.ПолучитьПриведенноеЗначениеПоля(Значение, Колонка.ИмяПоля);
		Соответствие.Вставить(Колонка.ИмяКолонки, ЗначениеПараметра);
	КонецЦикла;

	Возврат Соответствие;
КонецФункции

Функция ПрочитатьОбъектИзФайла(ИмяФайла)
	ЧтениеТекста = Новый ЧтениеТекста(ИмяФайла, "UTF-8");
	ТекстJSON = ЧтениеТекста.Прочитать();
	Объект = ПарсерJSON.ПрочитатьJSON(ТекстJSON);
	ЧтениеТекста.Закрыть();
	Возврат Объект;
КонецФункции
