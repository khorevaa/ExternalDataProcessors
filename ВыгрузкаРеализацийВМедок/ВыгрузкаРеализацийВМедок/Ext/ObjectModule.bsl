﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Перем КодЯзыкаПечать;
	
#Область ПрограммныйИнтерфейс

// Конвертирует документ РТУ в XML формат для загрузки в ME.DOC
//
// Параметры:
//  ДокументСсылка	 - 	 - 
// 
// Возвращаемое значение:
//   - 
//
Функция Конвертировать(Знач ДокументСсылка, XML = Истина) Экспорт 

	Если XML Тогда
		Возврат ВXML(ДокументСсылка);
	Иначе
		ВызватьИсключение "Не реализовано. Обратитесь к разработчику";
	КонецЕсли;                             	
	
КонецФункции

Функция ВXML(Знач ДокументСсылка)
	
	XMLWriter = Новый ЗаписьXML;
	XMLWriter.УстановитьСтроку(КодировкаПоУмолчанию());
	XMLWriter.ЗаписатьОбъявлениеXML();

	ЗаписатьКорневойТег(XMLWriter, Данные(ДокументСсылка));
	
	Возврат XMLWriter.Закрыть();
	
КонецФункции

#КонецОбласти

#Область РаботаXML

Процедура ЗаписатьКорневойТег(ЗаписьXML, ДанныеЗаполнения)
	
	AddTagZVIT(ЗаписьXML, ДанныеЗаполнения);
	
КонецПроцедуры

Процедура AddTagZVIT(XMLWriter, ДанныеЗаполнения)
	
	XMLWriter.ЗаписатьНачалоЭлемента("ZVIT");	
	
	AddTagTransport(XMLWriter);	
	
	AddTagOrg(XMLWriter, ДанныеЗаполнения); 	
	
	XMLWriter.ЗаписатьКонецЭлемента();	
		
КонецПроцедуры

Процедура AddTagOrg(XMLWriter, ДанныеЗаполнения)
	
	XMLWriter.ЗаписатьНачалоЭлемента("ORG");	
	XMLWriter.ЗаписатьНачалоЭлемента("FIELDS"); 	
	
	WriteTag(XMLWriter,"EDRPOU",ДанныеЗаполнения.СведенияОПоставщике.КодПоЕДРПОУ);

	XMLWriter.ЗаписатьКонецЭлемента();
	AddTagCARD(XMLWriter, ДанныеЗаполнения); 
	XMLWriter.ЗаписатьКонецЭлемента(); 
	
КонецПроцедуры

Процедура AddTagCARD(XMLWriter, Знач ДанныеЗаполнения)
	
	XMLWriter.ЗаписатьНачалоЭлемента("CARD");	
	
	XMLWriter.ЗаписатьАтрибут("RTFDOC","1");
	XMLWriter.ЗаписатьНачалоЭлемента("FIELDS");
	
	WriteTag(XMLWriter,"DOCNAME",	XMLString("Видаткова накладна"));
	WriteTag(XMLWriter,"CHARCODE",	"AF_VN");
	WriteTag(XMLWriter,"PARTCODE",	XMLString(7));
	//WriteTag(XMLWriter,"NOTATION",XMLString("Примітка"));
	WriteTag(XMLWriter,"SDOCTYPE",	XMLString(10105));
	WriteTag(XMLWriter,"PCTTYPE",	XMLString(-1));
	WriteTag(XMLWriter,"PEDRPOU",	XMLString(73737373));
	
	XMLWriter.ЗаписатьКонецЭлемента();
	AddTagDocument(XMLWriter, ДанныеЗаполнения);
	XMLWriter.ЗаписатьКонецЭлемента(); 
	
			
КонецПроцедуры

Процедура AddTagTransport(XMLWriter)
	
	XMLWriter.ЗаписатьНачалоЭлемента("TRANSPORT");
	WriteTag(XMLWriter,"VERSION","4.1");
	WriteTag(XMLWriter,"CREATEDATE",Формат(ТекущаяДатаСеанса(),"ДФ=dd.MM.yyyy"));	
	XMLWriter.ЗаписатьКонецЭлемента(); 
	
КонецПроцедуры

Процедура AddTagDocument(XMLWriter, ДанныеЗаполнения)
	
	LINE 	= "0";
	TAB 	= "0"; // шапка
	Шапка 						= ДанныеЗаполнения.Шапка;
	СведенияОПоставщике 		= ДанныеЗаполнения.СведенияОПоставщике;
	СведенияОПокупателе			= ДанныеЗаполнения.СведенияОПокупателе;
	ВсегоКоличествоТовары 		= ДанныеЗаполнения.Товары.Итог("Количество");
	ВсегоКоличествоТара			= ДанныеЗаполнения.Тара.Итог("Количество");	
	ОписаниеСумм 				= ПолучитьОписаниеСумм(ДанныеЗаполнения.ЗапросТовары);
	ДанныеПредставителя 		= ОбщегоНазначения.ДанныеФизЛица(Шапка.Организация,Шапка.ПредставительПоставщика, Шапка.Дата);
	ДолжностьПредставителя 		= СокрЛП(ДанныеПредставителя.Должность);	
	ДолжностьФИОПредставителя 	= ?(ЗначениеЗаполнено(ДолжностьПредставителя),ДолжностьПредставителя + " ","") + 
		?(ДанныеПредставителя.Фамилия = Неопределено,"",ДанныеПредставителя.Фамилия + " ") + 
		?(ДанныеПредставителя.Имя = Неопределено,"",ДанныеПредставителя.Имя + " ") +
		?(ДанныеПредставителя.Отчество = Неопределено,"",ДанныеПредставителя.Отчество);
								
	XMLWriter.ЗаписатьНачалоЭлемента("DOCUMENT");
	
	// конвертация ШАПКИ
	СуммаЭквивалента = СуммаЭквивалента(ДанныеЗаполнения.ЗапросТара);
	WriteTagAndAttr(XMLWriter,,XMLString(ВсегоКоличествоТара),										GetAttrStruct(LINE,TAB,"COUNT_N"));	
	WriteTagAndAttr(XMLWriter,,XMLString(СуммаБланковПрописью(ВсегоКоличествоТара,КодЯзыкаПечать)),	GetAttrStruct(LINE,TAB,"COUNT_N_TEXT"));	
	WriteTagAndAttr(XMLWriter,,DateFormat(Шапка.Дата,Истина),										GetAttrStruct(LINE,TAB,"DOCDATE"));
	WriteTagAndAttr(XMLWriter,,XMLString(Шапка.СуммаДокумента),										GetAttrStruct(LINE,TAB,"DOCSUM"));
	WriteTagAndAttr(XMLWriter,,XMLString(ОписаниеСумм.Сумма),										GetAttrStruct(LINE,TAB,"SUM"));
	WriteTagAndAttr(XMLWriter,,XMLString(ОписаниеСумм.Сумма),										GetAttrStruct(LINE,TAB,"DOCSUM_TEXT"));	
	WriteTagAndAttr(XMLWriter,,XMLString(НомерДоговора(Шапка.ДоговорКонтрагента)),					GetAttrStruct(LINE,TAB,"DOG_NUM"));	
	WriteTagAndAttr(XMLWriter,,XMLString(СуммаЭквивалента),											GetAttrStruct(LINE,TAB,"EQUIVALENT"));
	WriteTagAndAttr(XMLWriter,,XMLString(СведенияОПоставщике.ЮридическийАдрес),						GetAttrStruct(LINE,TAB,"FIRM_ADR"));
	WriteTagAndAttr(XMLWriter,,XMLString(СведенияОПоставщике.МФО),									GetAttrStruct(LINE,TAB,"FIRM_CBANK"));
	WriteTagAndAttr(XMLWriter,,XMLString(СведенияОПоставщике.КодПоЕДРПОУ),							GetAttrStruct(LINE,TAB,"FIRM_EDRPOU"));
	WriteTagAndAttr(XMLWriter,,XMLString(СведенияОПоставщике.ПолноеНаименование),					GetAttrStruct(LINE,TAB,"FIRM_NAME"));
	WriteTagAndAttr(XMLWriter,,XMLString(Строка(СведенияОПоставщике.Банк)),							GetAttrStruct(LINE,TAB,"FIRM_NMBANK"));
	WriteTagAndAttr(XMLWriter,,XMLString(СведенияОПоставщике.НомерСчета),							GetAttrStruct(LINE,TAB,"FIRM_RS"));
	WriteTagAndAttr(XMLWriter,,XMLString(ФИО(ДанныеПредставителя)),									GetAttrStruct(LINE,TAB,"FIRM_RUK"));
	WriteTagAndAttr(XMLWriter,,XMLString(ДолжностьПредставителя),									GetAttrStruct(LINE,TAB,"FIRM_RUKPOS"));
	WriteTagAndAttr(XMLWriter,,XMLString(ДанныеЗаполнения.ЗапросТовары.Количество()),				GetAttrStruct(LINE,TAB,"KVO"));
	WriteTagAndAttr(XMLWriter,,XMLString(Шапка.МестоСоставленияДокумента),							GetAttrStruct(LINE,TAB,"MISZE_SKL"));
	WriteTagAndAttr(XMLWriter,,XMLString(Шапка.Номер),												GetAttrStruct(LINE,TAB,"NUM"));
	WriteTagAndAttr(XMLWriter,,XMLString(СведенияОПокупателе.ЮридическийАдрес),						GetAttrStruct(LINE,TAB,"SIDE_CDADR_K"));
	//НД
	
	//WriteTagAndAttr(XMLWriter,,XMLString(2222222222),												GetAttrStruct(LINE,TAB,"SIDE_CDINDTAXNUM_K"));
	
	WriteTagAndAttr(XMLWriter,,XMLString(СведенияОПокупателе.ПолноеНаименование),					GetAttrStruct(LINE,TAB,"SIDE_CD_K"));
	
	// НД
	//WriteTagAndAttr(XMLWriter,,XMLString("Директор Директорович"),								GetAttrStruct(LINE,TAB,"SIDE_DIR_FIO"));
	//WriteTagAndAttr(XMLWriter,,XMLString("Директор"),												GetAttrStruct(LINE,TAB,"SIDE_DIR_POS"));
	
	WriteTagAndAttr(XMLWriter,,XMLString(СведенияОПокупателе.КодПоЕДРПОУ),							GetAttrStruct(LINE,TAB,"SIDE_EDRPOU_K"));
	WriteTagAndAttr(XMLWriter,,XMLString(СуммаЭквивалента),											GetAttrStruct(LINE,TAB,"SUMEQUIVALENT"));
	WriteTagAndAttr(XMLWriter,,XMLString(ОписаниеСумм.СуммаНДС),									GetAttrStruct(LINE,TAB,"PDV"));
	WriteTagAndAttr(XMLWriter,,XMLString(ОписаниеСумм.СуммаНДС),									GetAttrStruct(LINE,TAB,"SUMPDV_TEXT"));	
	
	Если ЗначениеЗаполнено(Шапка.ДоверенностьДата) Тогда
		
		WriteTagAndAttr(XMLWriter,,DateFormat(Шапка.ДоверенностьДата,Истина),						GetAttrStruct(LINE,TAB,"WARRANT_DATE"));
		WriteTagAndAttr(XMLWriter,,XMLString(Шапка.ДоверенностьНомер),								GetAttrStruct(LINE,TAB,"WARRANT_NUM"));
		
	КонецЕсли; 
	
	// заполнение ЗапросТовары	
	ЕдиницаЦены = Неопределено;	
	Для каждого СтрокаТабличнойЧасти Из ДанныеЗаполнения.ЗапросТовары Цикл
		
		LINE 	= XMLString(СтрокаТабличнойЧасти.НомерСтрокиТЧ-1);
		TAB 	= "1"; 		
		WriteTagAndAttr(XMLWriter,,XMLString(СтрокаТабличнойЧасти.НомерСтрокиТЧ),	GetAttrStruct(LINE,TAB,NameAtr(TAB,1)));
		WriteTagAndAttr(XMLWriter,,XMLString(СтрокаТабличнойЧасти.Товар), 			GetAttrStruct(LINE,TAB,NameAtr(TAB,2)));
		WriteTagAndAttr(XMLWriter,,XMLString(СтрокаТабличнойЧасти.Количество), 		GetAttrStruct(LINE,TAB,NameAtr(TAB,3)));
		WriteTagAndAttr(XMLWriter,,XMLString(СтрокаТабличнойЧасти.ЕдиницаЦены), 	GetAttrStruct(LINE,TAB,NameAtr(TAB,4)));
		WriteTagAndAttr(XMLWriter,,XMLString(СтрокаТабличнойЧасти.Цена), 			GetAttrStruct(LINE,TAB,NameAtr(TAB,5)));
		WriteTagAndAttr(XMLWriter,,XMLString(СтрокаТабличнойЧасти.Сумма),			GetAttrStruct(LINE,TAB,NameAtr(TAB,6)));		
		
		Если ЕдиницаЦены = Неопределено Тогда
			ЕдиницаЦены = СтрокаТабличнойЧасти.ЕдиницаЦены;			
		КонецЕсли; 		
		
	КонецЦикла;                                                                                                         
		
	// заполнение ЗапросТара	
	Если ЕдиницаЦены = Неопределено Тогда
		ВызватьИсключение "Единица измерения неопределена. Проверьте значение единицы номенклатуры";		
	КонецЕсли;              
	
	Для каждого СтрокаТабличнойЧасти Из ДанныеЗаполнения.ЗапросТара Цикл
		
		LINE 	= XMLString(СтрокаТабличнойЧасти.НомерСтрокиТЧ-1);
		TAB 	= "2";		
		WriteTagAndAttr(XMLWriter,,XMLString(LINE), 							GetAttrStruct(LINE,TAB,"TAB2_FIELD1"));
		WriteTagAndAttr(XMLWriter,,XMLString(СтрокаТабличнойЧасти.Товар), 		GetAttrStruct(LINE,TAB,"TAB2_FIELD2"));
		WriteTagAndAttr(XMLWriter,,XMLString(СтрокаТабличнойЧасти.Количество),	GetAttrStruct(LINE,TAB,"TAB2_FIELD3"));
		WriteTagAndAttr(XMLWriter,,XMLString(СтрокаТабличнойЧасти.ЕдиницаЦены),	GetAttrStruct(LINE,TAB,"TAB2_FIELD4"));
		// для номенклатуры будет использована спец.единица измерения, для корректного пересчета.
		// если она не заполнена, то значение = 1 (по умолчанию),
		// по-этому, если возмущаются - отправить смотреть на ЕдиницаИзмеренияМест
		WriteTagAndAttr(XMLWriter,,XMLString(СтрокаТабличнойЧасти.Количество * СтрокаТабличнойЧасти.Коэффициент), 	
			GetAttrStruct(LINE,TAB,"TAB2_FIELD5"));
			
		WriteTagAndAttr(XMLWriter,,XMLString(ЕдиницаЦены), 						GetAttrStruct(LINE,TAB,"TAB2_FIELD6"));
		
	КонецЦикла;  	
	
	XMLWriter.ЗаписатьКонецЭлемента();
	
КонецПроцедуры

Процедура WriteTagAndAttr(XMLWriter, Знач Tag = "ROW", Знач value, Description)
	         
	XMLWriter.WriteStartElement(Tag);
	
	XMLWriter.WriteAttribute("LINE",Description["LINE"]);
	XMLWriter.WriteAttribute("TAB",	Description["TAB"]);
	XMLWriter.WriteAttribute("NAME",Description["NAME"]);
	
	WriteTag(XMLWriter,"VALUE",value);
	
	XMLWriter.ЗаписатьКонецЭлемента();	
	
КонецПроцедуры

Процедура WriteTag(XMLWriter, Знач Tag, Знач Value)
	
	XMLWriter.WriteStartElement(Tag);
	Попытка
		XMLWriter.WriteText(Value);	
	Исключение
	    Сообщить(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	XMLWriter.WriteEndElement();	
	
КонецПроцедуры

#КонецОбласти

#Область СистемаКомпоновкиДанных

Функция ПолучитьМакетКомпоновки(СхемаКомпоновки, Настройки, ТипГенератора = Неопределено) Экспорт 
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	Возврат КомпоновщикМакета.Выполнить(СхемаКомпоновки, Настройки, , , ?(ТипГенератора = Неопределено,Тип("ГенераторМакетаКомпоновкиДанных"),ТипГенератора));
	
КонецФункции

Процедура ВывестиВТаблицуИлиДерево(ОбъектВывода, МакетКомпоновки, ВнешниеНаборыДанных = Неопределено) Экспорт 
	
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	Если ТипЗнч(ВнешниеНаборыДанных) = Тип("Структура")  Тогда
		ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,ВнешниеНаборыДанных,,Истина);
	Иначе
		ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,,,Истина);
	КонецЕсли;	
	
	ПроцессорВывода 	= Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.ОтображатьПроцентВывода = Истина;
	ПроцессорВывода.УстановитьОбъект(ОбъектВывода);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает структуру, содержащую значения реквизитов прочитанные из информационной базы
// по ссылке на объект.
// 
//  Если доступа к одному из реквизитов нет, возникнет исключение прав доступа.
//  Если необходимо зачитать реквизит независимо от прав текущего пользователя,
//  то следует использовать предварительный переход в привилегированный режим.
// 
// Функция не предназначена для получения значений реквизитов пустых ссылок.
//
// Параметры:
//  Ссылка    - ЛюбаяСсылка - объект, значения реквизитов которого необходимо получить.
//
//  Реквизиты - Строка - имена реквизитов, перечисленные через запятую, в формате
//              требований к свойствам структуры.
//              Например, "Код, Наименование, Родитель".
//            - Структура, ФиксированнаяСтруктура - в качестве ключа передается
//              псевдоним поля для возвращаемой структуры с результатом, а в качестве
//              значения (опционально) фактическое имя поля в таблице.
//              Если значение не определено, то имя поля берется из ключа.
//            - Массив, ФиксированныйМассив - имена реквизитов в формате требований
//              к свойствам структуры.
//
// Возвращаемое значение:
//  Структура - содержит имена (ключи) и значения затребованных реквизитов.
//              Если строка затребованных реквизитов пуста, то возвращается пустая структура.
//              Если в качестве объекта передана пустая ссылка, то все реквизиты вернутся со значением Неопределено.
//
Функция ЗначенияРеквизитовОбъекта(Ссылка, Знач Реквизиты) Экспорт
	
	Если ТипЗнч(Реквизиты) = Тип("Строка") Тогда
		Если ПустаяСтрока(Реквизиты) Тогда
			Возврат Новый Структура;
		КонецЕсли;
		Реквизиты = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(Реквизиты, ",");
	КонецЕсли;
	
	СтруктураРеквизитов = Новый Структура;
	Если ТипЗнч(Реквизиты) = Тип("Структура") Или ТипЗнч(Реквизиты) = Тип("ФиксированнаяСтруктура") Тогда
		СтруктураРеквизитов = Реквизиты;
	ИначеЕсли ТипЗнч(Реквизиты) = Тип("Массив") Или ТипЗнч(Реквизиты) = Тип("ФиксированныйМассив") Тогда
		Для Каждого Реквизит Из Реквизиты Цикл
			СтруктураРеквизитов.Вставить(СтрЗаменить(Реквизит, ".", ""), Реквизит);
		КонецЦикла;
	Иначе
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru='Неверный тип второго параметра Реквизиты: %1';uk='Невірний тип другого параметра Реквізити: %1'"), Строка(ТипЗнч(Реквизиты)));
	КонецЕсли;
	
	ТекстПолей = "";
	Для Каждого КлючИЗначение Из СтруктураРеквизитов Цикл
		ИмяПоля   = ?(ЗначениеЗаполнено(КлючИЗначение.Значение),
		              СокрЛП(КлючИЗначение.Значение),
		              СокрЛП(КлючИЗначение.Ключ));
		
		Псевдоним = СокрЛП(КлючИЗначение.Ключ);
		
		ТекстПолей  = ТекстПолей + ?(ПустаяСтрока(ТекстПолей), "", ",") + "
		|	" + ИмяПоля + " КАК " + Псевдоним;
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.Текст =
	"ВЫБРАТЬ
	|" + ТекстПолей + "
	|ИЗ
	|	" + Ссылка.Метаданные().ПолноеИмя() + " КАК ПсевдонимЗаданнойТаблицы
	|ГДЕ
	|	ПсевдонимЗаданнойТаблицы.Ссылка = &Ссылка
	|";
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	
	Результат = Новый Структура;
	Для Каждого КлючИЗначение Из СтруктураРеквизитов Цикл
		Результат.Вставить(КлючИЗначение.Ключ);
	КонецЦикла;
	ЗаполнитьЗначенияСвойств(Результат, Выборка);
	
	Возврат Результат;
	
КонецФункции

Функция Расширение() Экспорт 
	Возврат "xml";		
КонецФункции

Функция НазваниеФайла(Префикс) Экспорт 
	Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("%1.%2",Префикс,Расширение());		
КонецФункции

Функция КодировкаПоУмолчанию() Экспорт 
	Возврат "windows-1251";	
КонецФункции

Функция DateFormat(Значение, Полный = Истина)
	
	Если Полный Тогда
		Возврат Формат(Значение,"ДФ='dd.MM.yyyy 00:00:00'");       	
	КонецЕсли; 
	
	Возврат Формат(Значение,"ДФ=dd.MM.yyyy" );
	
КонецФункции

Функция GetAttrStruct(LINE="0",TAB="0",NAME="COUNT_N_TEXT")
	
	AttributeDescription 		= NewAttrDescriptionTagRow();
	AttributeDescription.LINE 	= LINE;
	AttributeDescription.TAB 	= TAB;
	AttributeDescription.NAME 	= NAME;
	
	return New FixedStructure(AttributeDescription);	
	
КонецФункции

Функция NewAttrDescriptionTagRow()
	
	Возврат New Structure("LINE,TAB,NAME","0","0","");
	
КонецФункции

Функция NameAtr(TAB,FIELD)
	Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("TAB%1_FIELD%2",TAB,FIELD);	
КонецФункции

Функция Данные(Знач СсылкаНаОбъект)
	
	//чтобы сильно не "мудрить", основная логика взята из процедуры Печать модуля объекта документа РТУ 	
	СтруктураВозврата = Новый Структура(
		"ЗапросТовары,ЗапросТара,Шапка,Товары,Тара", 
		Новый ТаблицаЗначений,
		Новый ТаблицаЗначений,
		Новый Соответствие,
		СсылкаНаОбъект.Товары,
		СсылкаНаОбъект.ВозвратнаяТара);

	БанковскийСчетОрганизации = СсылкаНаОбъект.БанковскийСчетОрганизации;
	ПолучилПоДругомуДокументу = СсылкаНаОбъект.ПолучилПоДругомуДокументу;
	Товары 	= СсылкаНаОбъект.Товары;
	Тара	= СсылкаНаОбъект.ВозвратнаяТара;
	
	ДопКолонка = Константы.ДополнительнаяКолонкаПечатныхФормДокументов.Получить();
	Если ДопКолонка = Перечисления.ДополнительнаяКолонкаПечатныхФормДокументов.Артикул Тогда
		ВыводитьКоды    = Истина;
		Колонка         = "Артикул";
		ТекстКодАртикул = "Артикул";
	ИначеЕсли ДопКолонка = Перечисления.ДополнительнаяКолонкаПечатныхФормДокументов.Код Тогда
		ВыводитьКоды    = Истина;
		Колонка         = "Код";
		ТекстКодАртикул = "Код";
	Иначе
		ВыводитьКоды    = Ложь;
		Колонка         = "";
		ТекстКодАртикул = "Код";
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СсылкаНаОбъект);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Номер,
	|	Дата,
	|	ДоговорКонтрагента,
	|	ДоговорКонтрагента.ВидДоговора КАК ВидДоговораКонтрагента,
	|	ДоговорКонтрагента.ВедениеВзаиморасчетов КАК ДоговорВедениеВзаиморасчетов,
	|	ДоговорКонтрагента.НаименованиеДляПечати КАК ДоговорНаименованиеДляПечати,	
	|	ДоговорКонтрагента.ВыводитьИнформациюОСделкеПриПечатиДокументов КАК ПечататьСделку,	
	|	Сделка,
	|	Контрагент КАК Покупатель,
	|	Организация,
	|	Организация КАК Поставщик,
	|	ПредставительОрганизации КАК ПредставительПоставщика,
	|	ВЫРАЗИТЬ(МестоСоставленияДокумента КАК СТРОКА(1000)) КАК МестоСоставленияДокумента,
	|   ДоверенностьСерия,
	|	ДоверенностьНомер,
	|	ДоверенностьДата,
	|	Получил,
	|	ПолучилПоДругомуДокументу,
	|	ДокументПодтверждающийПолномочия, 
	|	АдресДоставки,
	|	СуммаДокумента,
	|	ВалютаДокумента,
	|	УчитыватьНДС,
	|	СуммаВключаетНДС
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|
	|ГДЕ
	|	РеализацияТоваровУслуг.Ссылка = &ТекущийДокумент";
	Шапка = Запрос.Выполнить().Выбрать();
	Шапка.Следующий();
	
	СтруктураВозврата.Шапка = Шапка;	
	СтрокаВыборкиПоляСодержания = ОбработкаТабличныхЧастей.ПолучитьЧастьЗапросаДляВыбораСодержания("РеализацияТоваровУслуг");
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СсылкаНаОбъект);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НомерТЧ,
	|	НомерСтрокиТЧ,
	|	Номенклатура,
	|	ВЫРАЗИТЬ(Номенклатура.НаименованиеПолное КАК СТРОКА(1000)) КАК Товар,
	|	Номенклатура.Код     КАК Код,
	|	Номенклатура."+ ТекстКодАртикул + " КАК КодАртикул,
	|	Количество,
	|	КоличествоМест,
	|	ЕдиницаИзмерения.Представление КАК ЕдиницаЦены,
	|	ЕдиницаИзмеренияМест.Представление КАК ЕдиницаМест,
	|	Цена,
	|	Сумма,
	|	СуммаНДС,
	|	ПроцентСкидкиНаценки КАК Скидка,
	|	ПроцентАвтоматическихСкидок КАК АвтоматическаяСкидка,
	|	ХарактеристикаНоменклатуры КАК Характеристика,
	|	СерияНоменклатуры КАК Серия
	|ИЗ 
	|	(ВЫБРАТЬ
	|		1 КАК НомерТЧ,
	|		МИНИМУМ(НомерСтроки) КАК НомерСтрокиТЧ,
	|		Номенклатура         КАК Номенклатура,
	|		ЕдиницаИзмерения     КАК ЕдиницаИзмерения,
	|		ЕдиницаИзмеренияМест КАК ЕдиницаИзмеренияМест,
	|		Цена                 КАК Цена,
	|		СтавкаНДС            КАК СтавкаНДС,
	|		ПроцентСкидкиНаценки КАК ПроцентСкидкиНаценки,
	|		ПроцентАвтоматическихСкидок КАК ПроцентАвтоматическихСкидок,
	|		СерияНоменклатуры    КАК СерияНоменклатуры,
	|		ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
	|		СУММА(Количество)    КАК Количество,
	|		СУММА(КоличествоМест)КАК КоличествоМест,
	|		СУММА(Сумма)         КАК Сумма,
	|		СУММА(СуммаНДС)      КАК СуммаНДС
	|	ИЗ
	|		Документ.РеализацияТоваровУслуг.Товары КАК РеализацияТоваровУслуг
	|	ГДЕ
	|		РеализацияТоваровУслуг.Ссылка = &ТекущийДокумент
	|	СГРУППИРОВАТЬ ПО
	|		Номенклатура,
	|		ЕдиницаИзмерения,
	|		ЕдиницаИзмеренияМест,
	|		Цена,
	|		СтавкаНДС,
	|		ПроцентСкидкиНаценки,
	|		ПроцентАвтоматическихСкидок,
	|		СерияНоменклатуры,
	|		ХарактеристикаНоменклатуры
	|	) КАК ВложенныйЗапросПоТоварам
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|   2,
	|   РеализацияТоваровУслуг.НомерСтроки,
	|	РеализацияТоваровУслуг.Номенклатура,
	|	" + СтрокаВыборкиПоляСодержания + ",
	|	Номенклатура.Код     КАК Код,
	|	Номенклатура."+ ТекстКодАртикул + " КАК КодАртикул,
	|	Количество,
	|	NULL,
	|	Номенклатура.ЕдиницаХраненияОстатков.Представление КАК ЕдиницаЦены,
	|	NULL,
	|	Цена,
	|	Сумма,
	|	СуммаНДС,
	|	ПроцентСкидкиНаценки,
	|	ПроцентАвтоматическихСкидок,
	|	NULL,
	|	NULL
	|	
	|ИЗ
	|	Документ.РеализацияТоваровУслуг.Услуги КАК РеализацияТоваровУслуг
	|
	|ГДЕ
	|	РеализацияТоваровУслуг.Ссылка = &ТекущийДокумент
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерТЧ, НомерСтрокиТЧ
	|";
	
	ЗапросТовары = Запрос.Выполнить().Выгрузить();
	
	СтруктураВозврата.ЗапросТовары = ЗапросТовары;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", СсылкаНаОбъект);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	НомерСтроки						КАК НомерСтрокиТЧ,
	|	Номенклатура,
	|	ВЫРАЗИТЬ(Номенклатура.НаименованиеПолное КАК СТРОКА(1000))  КАК Товар,
	|	Номенклатура.Код                КАК Код,
	|	ЕСТЬNULL(Номенклатура.ЕдиницаИзмеренияМест.Коэффициент,1) Как Коэффициент,
	|	Номенклатура."+ ТекстКодАртикул + " КАК КодАртикул,
	|	Количество,
	|	Номенклатура.ЕдиницаХраненияОстатков.Представление КАК ЕдиницаЦены,	
	|	Цена,
	|	Сумма
	|ИЗ
	|	Документ.РеализацияТоваровУслуг.ВозвратнаяТара КАК РеализацияТоваровУслуг
	|
	|ГДЕ
	|	РеализацияТоваровУслуг.Ссылка = &ТекущийДокумент
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтрокиТЧ
	|";
	
	ЗапросТара = Запрос.Выполнить().Выгрузить();
	
	СтруктураВозврата.ЗапросТара = ЗапросТара;
	
	// Формируем шапку 	
	КодЯзыкаПечать 		= Локализация.ПолучитьЯзыкФормированияПечатныхФорм(УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "РежимФормированияПечатныхФорм"));
	СведенияОПоставщике = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Поставщик, Шапка.Дата,,,КодЯзыкаПечать);
	СведенияОПокупателе = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Покупатель, Шапка.Дата,,,КодЯзыкаПечать);
	
	Если ЗначениеЗаполнено(БанковскийСчетОрганизации) Тогда
		
		НомерСчета = БанковскийСчетОрганизации.НомерСчета;
		Банк       = БанковскийСчетОрганизации.Банк;
		МФО		   = БанковскийСчетОрганизации.Банк.Код;
		
		СведенияОПоставщике.Вставить("НомерСчета",       НомерСчета);
		СведенияОПоставщике.Вставить("Банк",             Банк);
		СведенияОПоставщике.Вставить("МФО",              МФО);
		
	КонецЕсли;  	
	
	СтруктураВозврата.Вставить("СведенияОПоставщике",СведенияОПоставщике);
	СтруктураВозврата.Вставить("СведенияОПокупателе",СведенияОПокупателе); 	
	
	Возврат СтруктураВозврата;	
	
КонецФункции

Функция ФИО(ДанныеПредставителя)
	
	Возврат ?(ДанныеПредставителя.Фамилия = Неопределено,"",ДанныеПредставителя.Фамилия + " ") + 
			?(ДанныеПредставителя.Имя = Неопределено,"",ДанныеПредставителя.Имя + " ") +
			?(ДанныеПредставителя.Отчество = Неопределено,"",ДанныеПредставителя.Отчество);	
			
КонецФункции

Функция СуммаНДСПрописью(Шапка, СуммаНДС)
	
	Если Шапка.УчитыватьНДС Тогда
		
		ВсегоНДС 	= ОбщегоНазначения.ФорматСумм(СуммаНДС,,"''");
		Текст 		= ?(Шапка.СуммаВключаетНДС, НСтр("ru='В том числе НДС:';uk='У тому числі ПДВ:'",КодЯзыкаПечать), НСтр("ru='Сумма НДС:';uk='Сума ПДВ:'",КодЯзыкаПечать));
		
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("%1 %2",Текст,ВсегоНДС);
		
	КонецЕсли; 
	
	Возврат "";
	
КонецФункции

Функция НомерДоговора(Знач ДоговорСсылка)
	Возврат ЗначенияРеквизитовОбъекта(ДоговорСсылка,"Номер").Номер;
КонецФункции

// Функция - Сумма бланков прописью
//
// Параметры:
//  Сумма	 - Число	 - 
//  КодЯзыка - Строка	 - 
// 
// Возвращаемое значение:
//   - 
//
Функция СуммаБланковПрописью(Сумма,КодЯзыка)	
	
	ПараметрыПрописи = Новый Соответствие();
	ПараметрыПрописи.Вставить("ru","бланк - разрешение, бланка - разрешения, бланков - разрешений, м, ,,,,0");
	ПараметрыПрописи.Вставить("uk","бланк - дозвіл, бланка - дозвола, бланків - дозволів, м, ,,,,0");
	
	Возврат ЧислоПрописью(Сумма,"Л="+КодЯзыка,ПараметрыПрописи.Получить(КодЯзыка));                  	
	
КонецФункции //СуммаБланковПрописью

Функция СуммаЭквивалента(Знач ЗапросТара)
	
	СуммаЭквивалента = 0;
	Для каждого ВыборкаСтрокТара Из ЗапросТара Цикл 
		СуммаЭквивалента = СуммаЭквивалента + ВыборкаСтрокТара.Количество * ВыборкаСтрокТара.Коэффициент;		
	КонецЦикла;	
	
	Возврат СуммаЭквивалента;
	
КонецФункции


Функция ПолучитьОписаниеСумм(Знач ТабличнаяЧасть)

	ОписаниеСумм = Новый Структура(
		"Сумма,СуммаНДС,ВсегоСкидок,ВсегоБезСкидок",0,0,0,0);
	
	Для каждого ВыборкаСтрок Из ТабличнаяЧасть Цикл
		
		// Скидка может быть NULL
		ПроцентСкидки = ?(НЕ ЗначениеЗаполнено(ВыборкаСтрок.Скидка),0,ВыборкаСтрок.Скидка) 
		              + ?(НЕ ЗначениеЗаполнено(ВыборкаСтрок.АвтоматическаяСкидка),0,ВыборкаСтрок.АвтоматическаяСкидка);
	
		Скидка 						= Ценообразование.ПолучитьСуммуСкидки(ВыборкаСтрок.Сумма, ПроцентСкидки);
		ОписаниеСумм.Сумма   		= ОписаниеСумм.Сумма    	+ ВыборкаСтрок.Сумма;
		ОписаниеСумм.СуммаНДС 		= ОписаниеСумм.СуммаНДС 	+ ВыборкаСтрок.СуммаНДС;
		ОписаниеСумм.ВсегоСкидок    = ОписаниеСумм.ВсегоСкидок 	+ Скидка;
		ОписаниеСумм.ВсегоБезСкидок = ОписаниеСумм.Сумма 		+ ОписаниеСумм.ВсегоСкидок;
		
	КонецЦикла; 
	
	Возврат Новый ФиксированнаяСтруктура(ОписаниеСумм);
	
КонецФункции

 // инициализация глобальных переменных
 
КодЯзыкаПечать 	= Локализация.ПолучитьЯзыкФормированияПечатныхФорм(УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глЗначениеПеременной("глТекущийПользователь"), "РежимФормированияПечатныхФорм"));

#КонецОбласти
    
#Иначе
 ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли