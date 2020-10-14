&Колонка(Тип = "Целое")
&Идентификатор
Перем Целое Экспорт;

&Колонка(Тип = "Дробное")
Перем Дробное Экспорт;

&Колонка(Тип = "Строка")
Перем Строка Экспорт;

&Колонка(Тип = "Булево")
Перем БулевоИстина Экспорт;

&Колонка(Тип = "Булево")
Перем БулевоЛожь Экспорт;

&Колонка(Тип = "Дата")
Перем Дата Экспорт;

&Колонка(Тип = "Время")
Перем Время Экспорт;

&Колонка(Тип = "ДатаВремя")
Перем ДатаВремя Экспорт;

&Колонка(Тип = "Ссылка", ТипСсылки = "СущностьСоВсемиТипамиКолонок")
Перем Ссылка Экспорт;

&ПодчиненнаяТаблица(
	Тип = "Массив", 
	ТипЭлемента = "Строка", 
	ИмяТаблицы = "ВсеТипыКолонок_Массив"
)
Перем Массив Экспорт;

&ПодчиненнаяТаблица(
	Тип = "Структура", 
	ТипЭлемента = "Строка", 
	ИмяТаблицы = "ВсеТипыКолонок_Структура"
)
Перем Структура Экспорт;

&ПодчиненнаяТаблица(
	Тип = "Массив", 
	ТипЭлемента = "СущностьСоВсемиТипамиКолонок", 
	ИмяТаблицы = "ВсеТипыКолонок_МассивСсылок"
)
Перем МассивСсылок Экспорт;

&ПодчиненнаяТаблица(
	Тип = "Массив", 
	ТипЭлемента = "СущностьСоВсемиТипамиКолонок", 
	ИмяТаблицы = "ВсеТипыКолонок_МассивСсылокКаскад",
	КаскадноеЧтение = Истина
)
Перем МассивСсылокКаскад Экспорт;

&Сущность
Процедура ПриСозданииОбъекта()

КонецПроцедуры
