Перем Целое Экспорт;
Перем Дробное Экспорт;
Перем Булево Экспорт;
Перем Строка Экспорт;
Перем Дата Экспорт;
Перем Время Экспорт;
Перем ДатаВремя Экспорт;
Перем Ссылка Экспорт;

Перем Типы;
Перем ПримитивныеТипы;

Функция Типы() Экспорт
	Возврат Типы;
КонецФункции

Функция ЭтоПримитивныйТип(Знач Тип) Экспорт
	Если ТипЗнч(Тип) = Тип("Тип") Тогда
		Тип = Строка(Тип);
	КонецЕсли;

	Возврат ПримитивныеТипы.Найти(Тип) <> Неопределено;
КонецФункции

Функция ЭтоСсылочныйТип(Знач Тип) Экспорт
	Если ТипЗнч(Тип) = Тип("Тип") Тогда
		Тип = Строка(Тип);
	КонецЕсли;

	Возврат Типы.Найти(Тип) = Неопределено И Не ЭтоПримитивныйТип(Тип); 
КонецФункции

Целое = "Целое";
Дробное = "Дробное";
Булево = "Булево";
Строка = "Строка";
Дата = "Дата";
Время = "Время";
ДатаВремя = "ДатаВремя";
Ссылка = "Ссылка";

Типы = Новый Массив;
Типы.Добавить(Целое);
Типы.Добавить(Дробное);
Типы.Добавить(Булево);
Типы.Добавить(Строка);
Типы.Добавить(Дата);
Типы.Добавить(Время);
Типы.Добавить(ДатаВремя);
Типы.Добавить(Ссылка);

ПримитивныеТипы = Новый Массив;
ПримитивныеТипы.Добавить(Целое);
ПримитивныеТипы.Добавить(Дробное);
ПримитивныеТипы.Добавить(Булево);
ПримитивныеТипы.Добавить(Строка);
ПримитивныеТипы.Добавить(Дата);
ПримитивныеТипы.Добавить(Время);
ПримитивныеТипы.Добавить(ДатаВремя);
