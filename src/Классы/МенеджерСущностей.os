#Использовать asserts
#Использовать logos
#Использовать reflector

// Хранит данные о типах полей, колонках, настроек таблиц для типов сущностей
Перем МодельДанных;

// Хранит коннектор к БД, транслирующий команды менеджера сущностей в запросы к БД
Перем Коннектор;
Перем СтрокаСоединенияКоннектора;
Перем ПараметрыКоннектора;

Перем Лог;

// Конструктор объекта МенеджерСущностей.
//
// Параметры:
//   ТипКоннектора - Тип - Тип класса, реализующего интерфейс Коннектор.
//   СтрокаСоединения - Строка - Строка соединения к БД, к которой подключается коннектор.
//   ППараметрыКоннектора - Массив - Массив дополнительных параметров коннектора. Содержимое произвольное.
//
Процедура ПриСозданииОбъекта(Знач ТипКоннектора, Знач СтрокаСоединения = "", Знач ППараметрыКоннектора = Неопределено)
	Лог = Логирование.ПолучитьЛог("oscript.lib.entity.manager");
	Лог.Отладка("Инициализация менеджера сущностей с коннектором %1", ТипКоннектора);
	ПроверитьПоддержкуИнтерфейсаКоннектора(ТипКоннектора);

	МодельДанных = Новый МодельДанных;
	
	Коннектор = Новый(ТипКоннектора);
	
	СтрокаСоединенияКоннектора = СтрокаСоединения;
	Если ППараметрыКоннектора = Неопределено Тогда
		ПараметрыКоннектора = Новый Массив;
	Иначе
		ПараметрыКоннектора = ППараметрыКоннектора;	
	КонецЕсли;
КонецПроцедуры

// Регистрирует переданный тип класса-сценария в модели данных.
//
// Параметры:
//   ТипСущности - Тип - Тип для добавления в модель
//
Процедура ДобавитьКлассВМодель(ТипСущности) Экспорт
	ПроверитьЧтоКлассЯвляетсяСущностью(ТипСущности);
	
	МодельДанных.СоздатьОбъектМодели(ТипСущности);
КонецПроцедуры

// Запускает процессы инициализации коннектора и таблиц БД.
//
Процедура Инициализировать() Экспорт
	Коннектор.Открыть(СтрокаСоединенияКоннектора, ПараметрыКоннектора);
	ОбъектыМодели = МодельДанных.ПолучитьОбъектыМодели();
	Для Каждого ОбъектМодели Из ОбъектыМодели Цикл
		Коннектор.ИнициализироватьТаблицу(ОбъектМодели);
	КонецЦикла;
КонецПроцедуры

// Сохраняет сущность в БД.
//
// Параметры:
//   Сущность - Произвольный - Объект (экземпляр класса, зарегистрированного в модели) для сохранения в БД.
//
Процедура Сохранить(Сущность) Экспорт
	ТипСущности = ТипЗнч(Сущность);

	ПроверитьЧтоКлассЯвляетсяСущностью(ТипСущности);
	ПроверитьЧтоТипСущностиЗарегистрированВМодели(ТипСущности);
	ПроверитьНеобходимостьЗаполненияИдентификатора(Сущность);

	ОбъектМодели = МодельДанных.Получить(ТипСущности);
	
	Коннектор.Сохранить(ОбъектМодели, Сущность);
КонецПроцедуры

// Осуществляет поиск сущностей переданного типа по идентификатору.
//
// Параметры:
//   ТипСущности - Тип - Тип искомой сущности.
//   Идентификатор - Произвольный - Идентификатор искомой сущности. Тип значения зависит от используемого типа поля
//       с аннотацией &Идентификатор.
//
//  Возвращаемое значение:
//   Массив - Массив найденных сущностей. В качестве элементов массива выступают
//     экземпляры класса с типом, равным переданному "ТипуСущности", с заполненными значениями полей.
//
Функция Получить(ТипСущности, Идентификатор) Экспорт

	ОбъектМодели = МодельДанных.Получить(ТипСущности);
	
	НайденныеСущности = Новый Массив;
	
	ЗначенияКолонок = Коннектор.ПолучитьЗначенияКолонокСущности(ОбъектМодели, Идентификатор);
	Если ЗначенияКолонок.Количество() = 0 Тогда
		Возврат НайденныеСущности;
	КонецЕсли;
	
	Сущность = Новый(ТипСущности);

	Для Каждого Колонка Из ОбъектМодели.Колонки() Цикл
		ЗначениеКолонки = ЗначенияКолонок.Получить(Колонка.ИмяКолонки);
		Если Колонка.ТипКолонки = ТипыКолонок.Ссылка И ЗначениеЗаполнено(ЗначениеКолонки) Тогда
			ПодчиненныеСущности = Получить(Колонка.ТипСсылки, ЗначениеКолонки);
			ЗначениеКолонки = ПодчиненныеСущности[0];
		КонецЕсли;
		ОбъектМодели.УстановитьЗначениеКолонкиВПоле(Сущность, Колонка.ИмяКолонки, ЗначениеКолонки);
	КонецЦикла;
	
	НайденныеСущности.Добавить(Сущность);

	Возврат НайденныеСущности;
КонецФункции

// Осуществляет поиск сущности переданного типа по идентификатору.
//
// Параметры:
//   ТипСущности - Тип - Тип искомой сущности.
//   Идентификатор - Произвольный - Идентификатор искомой сущности. Тип значения зависит от используемого типа поля
//       с аннотацией &Идентификатор.
//
//  Возвращаемое значение:
//   Произвольный - Если сущность была найдена, то возвращается экземпляр класса с типом, равным переданному 
//     "ТипуСущности", с заполненными значениями полей. Иначе возвращается "Неопределено".
//
Функция ПолучитьОдно(ТипСущности, Идентификатор) Экспорт
	НайденныеСущности = Получить(ТипСущности, Идентификатор);
	
	Если НайденныеСущности.Количество() = 0 Тогда
		Возврат Неопределено;
	Иначе
		Возврат НайденныеСущности[0];
	КонецЕсли;
КонецФункции

// Удаляет удаление сущности из базы данных.
// Сущность должна иметь заполненный идентификатор.
//
// Параметры:
//   Сущность - Произвольный - Удаляемая сущность
//
Функция Удалить(Сущность) Экспорт
	ОбъектМодели = МодельДанных.Получить(ТипЗнч(Сущность));
	Коннектор.Удалить(ОбъектМодели, Сущность);
КонецФункции

// Посылает коннектору запрос на закрытие соединения.
//
Процедура Закрыть() Экспорт
	Если Коннектор.Открыт() Тогда
		Коннектор.Закрыть();
	КонецЕсли;
	МодельДанных.Очистить();
КонецПроцедуры

// Посылает коннектору запрос на начало транзакции.
//
Процедура НачатьТранзакцию() Экспорт
	Коннектор.НачатьТранзакцию();
КонецПроцедуры

// Посылает коннектору запрос на фиксацию транзакции.
//
Процедура ЗафиксироватьТранзакцию() Экспорт
	Коннектор.ЗафиксироватьТранзакцию();
КонецПроцедуры

// Посылает коннектору запрос на отмену транзакции.
//
Процедура ОтменитьТранзакцию() Экспорт
	Коннектор.ОтменитьТранзакцию();
КонецПроцедуры

// Возвращает текущий активный коннектор.
//
//  Возвращаемое значение:
//   АбстрактныйКоннектор - Возвращает экземпляр коннектора. Конкретная реализация определяется параметром 
//      ТипКоннектора при вызове конструктора МенеджерСущностей. 
//
Функция ПолучитьКоннектор() Экспорт
	Возврат Коннектор;
КонецФункции

// <Описание процедуры>
//
// Параметры:
//   ТипКоннектора - Тип - Тип, проверяемый на реализацию интерфейса
//
Процедура ПроверитьПоддержкуИнтерфейсаКоннектора(ТипКоннектора)
	
	ИнтерфейсКоннектор = Новый ИнтерфейсОбъекта;
	ИнтерфейсКоннектор.ИзОбъекта(Тип("АбстрактныйКоннектор"));

	РефлекторОбъекта = Новый РефлекторОбъекта(ТипКоннектора);
	ПоддерживаетсяИнтерфейсКоннектора = РефлекторОбъекта.РеализуетИнтерфейс(ИнтерфейсКоннектор);
	
	Ожидаем.Что(
		ПоддерживаетсяИнтерфейсКоннектора, 
		СтрШаблон("Тип <%1> не реализует интерфейс коннектора", ТипКоннектора)
	).ЭтоИстина();

КонецПроцедуры

// <Описание процедуры>
//
// Параметры:
//   ТипКласса - Тип - Тип, в котором проверяется наличие необходимых аннотаций.
//
Процедура ПроверитьЧтоКлассЯвляетсяСущностью(ТипКласса)
	
	РефлекторОбъекта = Новый РефлекторОбъекта(ТипКласса);
	ТаблицаМетодов = РефлекторОбъекта.ПолучитьТаблицуМетодов("Сущность", Ложь);
	Ожидаем.Что(ТаблицаМетодов, СтрШаблон("Класс %1 не имеет аннотации &Сущность", ТипКласса)).ИмеетДлину(1);
	
	ТаблицаСвойств = РефлекторОбъекта.ПолучитьТаблицуСвойств("Идентификатор");
	Ожидаем.Что(ТаблицаСвойств, СтрШаблон("Класс %1 не имеет поля с аннотацией &Идентификатор", ТипКласса)).ИмеетДлину(1);

КонецПроцедуры

Процедура ПроверитьЧтоТипСущностиЗарегистрированВМодели(ТипСущности)
	ОбъектМодели = МодельДанных.Получить(ТипСущности);
	Ожидаем.Что(ОбъектМодели, "Тип сущности не зарегистрирован в модели данных").Не_().Равно(Неопределено);
КонецПроцедуры

Процедура ПроверитьНеобходимостьЗаполненияИдентификатора(Сущность)
	ОбъектМодели = МодельДанных.Получить(Тип(Сущность));
	Если ОбъектМодели.Идентификатор().ГенерируемоеЗначение Тогда
		Возврат;
	КонецЕсли;
	
	ЗначениеИдентификатора = ОбъектМодели.ПолучитьЗначениеИдентификатора(Сущность);
	Ожидаем.Что(
		ЗначениеИдентификатора, СтрШаблон("Сущность с типом %1 должна иметь заполненный идентификатор", Тип(Сущность))
	).Заполнено();

КонецПроцедуры
