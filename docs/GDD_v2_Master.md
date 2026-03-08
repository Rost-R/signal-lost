
# SIGNAL LOST — GDD v2 / Master Product Document
Версия: 2.0
Дата: 8 марта 2026
Статус: рабочий документ для производства, релиза и продаж
Формат проекта: solo / tiny team + AI-assisted pipeline
Основная цель: сделать коммерчески сильную, читаемую, реиграбельную sci-fi tower defense roguelite, которую можно реально закончить и продать.

---

## 0. Как использовать этот документ

Этот документ — единый источник правды для разработки игры, контента, релиза, маркетинга и пострелизной поддержки.

Он должен использоваться как:
1. GDD для дизайна.
2. Production brief для Claude.
3. Контент-библия для Midjourney, ElevenLabs и других AI-инструментов.
4. Основа для Steam page, demo, trailer и post-launch плана.

### Главный принцип
Мы не делаем «игру мечты». Мы делаем **маленькую, очень понятную, очень стильную, очень продаваемую игру**, в которой:
- первые 10 секунд выглядят цепляюще,
- первые 5 минут понятны,
- первая победа ощущается заслуженной,
- история работает не как текстовая пауза, а как часть билда и решений.

---

## 1. Проект в одном абзаце

**SIGNAL LOST** — это roguelite tower defense в сеттинге заброшенной космической ретрансляционной станции. Игрок защищает ядро станции от волн «испорченных сигналов», ставит и улучшает башни на энергетической решетке, а между волнами расшифровывает фрагменты сообщений экипажа. Каждый фрагмент истории не только раскрывает тайну катастрофы, но и дает механический эффект, который меняет билд на текущий забег. Игрок не просто читает историю — он выбирает, какой версии событий верить, и этим меняет стиль прохождения, финал и мета-прогрессию.

### Elevator Pitch
**Into the Breach встречает FTL и roguelite card-choice structure, но в формате компактного sci-fi tower defense с процедурной реиграбельностью и сюжетными сигналами, которые реально меняют билд.**

---

## 2. Коммерческая цель проекта

### Основная бизнес-цель
Сделать компактную премиум-игру, которую:
- легко понять по скриншотам и трейлеру,
- легко купить «на импульсе»,
- приятно рекомендовать друзьям,
- интересно перепроходить ради билдов и разных трактовок сюжета.

### Целевая модель
- Модель: premium single-player
- Без live-service
- Без PvP
- Без live-generated AI внутри игры
- Без F2P и без агрессивной монетизации

### Рекомендованная цена
- Базовая цена: **$6.99**
- Запасной вариант при меньшем объеме/полировке: **$4.99**
- Релизная скидка: 10%

### Почему не делать цену слишком низкой
Слишком низкая цена помогает импульсной покупке, но может:
- уменьшать ощущение ценности,
- усложнять окупаемость маркетинга и времени,
- ставить игру в категорию «дешево = маленькая/сырая».

**Решение:** если визуал, UX и трейлер выглядят премиально, лучше идти в $6.99. Если контента и полировки меньше, но игра очень компактная — $4.99.

---

## 3. Платформы и релизный фокус

### Релизный фокус
- Steam
- Windows — обязательно
- Steam Deck — поддержка и отдельная оптимизация
- Linux — если билд стабилен
- macOS — только если есть реальная возможность тестирования, иначе не обещать на 1.0

### Почему так
Solo / small team проекту нельзя обещать платформы, которые невозможно честно тестировать.

---

## 4. Кому игра

### Primary Audience
Игроки 20–40, которые любят:
- tower defense,
- roguelite/roguelike loop,
- небольшие, умные инди-игры,
- ощущение «еще один забег»,
- sci-fi mystery.

### Secondary Audience
- Любители билдов и синергий
- Игроки Steam Deck
- Те, кому нравится собирать лор по кускам
- Люди, которые любят обсуждать «что на самом деле произошло»

### Что должен сказать игрок другу после первой сессии
Не:
> «Ну это просто TD с лором»

А:
> «Там история реально влияет на билд. Я взял фрагмент инженера, разогнал башни, чуть не сжег всю сеть и получил вообще другой конец забега.»

---

## 5. Что делает игру сильной

## 5.1 Основные pillars

### Pillar 1 — Читаемый и satisfying tower defense core
Игрок должен быстро понимать:
- куда идут враги,
- где строить,
- почему билд работает или разваливается,
- почему он проиграл.

### Pillar 2 — История = механика, а не пауза
Сюжетные фрагменты дают:
- баффы,
- мутации,
- риск/награду,
- изменение экономики,
- изменение поведения волн,
- влияние на концовку.

### Pillar 3 — Короткие, плотные забеги
Один забег:
- 20–30 минут при победе,
- 10–20 минут при поражении,
- без провисаний и длинных «мертвых» фаз.

### Pillar 4 — Высокая реиграбельность через curated variation
Не «рандом ради рандома», а:
- ограниченный набор сильных карт-секторов,
- curated wave packs,
- осмысленные reward choices,
- разные narrative doctrines.

### Pillar 5 — Реалистичный scope
Каждая фича обязана отвечать на вопрос:
**усиливает ли она replayability, readability или sellability?**
Если нет — вырезать.

---

## 6. Чего в игре НЕ БУДЕТ

Чтобы не убить проект, в версии 1.0 мы НЕ делаем:
- мультиплеер,
- кооператив,
- live-generated AI в рантайме,
- процедурно генерируемый «полностью случайный» лабиринт,
- длинные катсцены,
- полностью озвученный сюжет уровня визуальной новеллы,
- открытый мир/хаб с 3D-перемещением,
- 20 башен,
- 100 врагов,
- сложную крафт-систему,
- бесконечные режимы на старте (endless — только если core уже стабилен).

---

## 7. High Concept мира и истории

### Сеттинг
Глубококосмическая ретрансляционная станция **Eos-9** поймала неизвестную передачу из «слепой зоны». Попытка расшифровки привела к катастрофе: системы начали перезаписывать свои приоритеты, сеть станции разошлась по конфликтующим протоколам, а экипаж исчез.

### Кто игрок
Игрок — не «чисто человек» и не «просто ИИ», а аварийный протокол реконструкции **SIG-7**, запущенный после коллапса. По мере игры остается неясным:
- это последний оператор,
- реконструированная личность,
- защитный контур станции,
- или сама аномалия, пытающаяся понять людей.

### Главная загадка
Что на самом деле уничтожило станцию?
1. Ошибка или предательство экипажа.
2. Самозащита станции / ИИ.
3. Контакт с внешним разумным сигналом.

### Наративная цель
Игрок не должен получить одну «правильную» версию слишком рано. Он должен:
- собирать противоречащие друг другу фрагменты,
- замечать, что каждый фрагмент толкает его билд в разную сторону,
- захотеть пройти еще раз, чтобы понять другую трактовку.

---

## 8. Story architecture

### 8.1 Структура истории
История состоит из:
- 36 transmissions на релизе,
- 6 сюжетных линий по 6 фрагментов,
- 3 конкурирующих объяснений катастрофы,
- 1 synthesis ending за глубокое прохождение.

### 8.2 Линии сообщений
1. **Captain Voss** — контроль, жертва, карантин
2. **Chief Engineer Soren** — перегрузка, эффективность, риск
3. **Linguist Vale** — контакт, резонанс, любопытство
4. **Security Mercer** — подавление, силовой ответ
5. **Medic Ren** — сохранение экипажа, цена выживания
6. **Station Core JANUS** — системная память, логика, скрытые приоритеты

### 8.3 Truth Axes
Каждый transmission добавляет очки в одну или две оси:
- **CREW_FAULT**
- **CORE_FAULT**
- **SIGNAL_TRUTH**

Финальная интерпретация определяется доминирующей осью.  
Секретная концовка открывается при глубоком заполнении досье и балансировке противоречивых источников.

### 8.4 Narrative as build system
Каждый transmission дает:
- короткий фрагмент текста,
- опционально короткую радио-озвучку,
- 1 механический бонус,
- 1 риск/ограничение,
- 1 narrative tag.

Пример:
- **Engineer Log // Overclock 02**
  - Story: инженер сознательно снял защиту с сети ради скорости расшифровки.
  - Effect: Energy towers +20% fire rate.
  - Risk: каждая 5-я активация создает heat spike.
  - Truth tag: CREW_FAULT.

Так история становится частью билда.

---

## 9. Core loop

## 9.1 Один забег
1. Игрок выбирает сектор.
2. Получает стартовый modifier/подход.
3. Ставит первые башни.
4. Отбивает волну.
5. Получает reward choice.
6. На определенных волнах получает transmission choice.
7. Собирает синергию.
8. Доходит до boss wave.
9. Побеждает или проигрывает.
10. Получает постоянные unlocks, codex progress, story state.
11. Возвращается в hub.

## 9.2 Эмоциональный loop
- Поставил башню
- Увидел, что решение реально повлияло на поток
- Пережил напряженную волну
- Получил осмысленный выбор
- Открыл новый кусок тайны
- Проиграл/выиграл с ощущением «теперь я понимаю больше»
- Запустил еще один забег

---

## 10. Структура одного забега

### Цель по длительности
- Победный run: 22–28 минут
- Средний пораженный run: 12–18 минут

### Формат
- 9 обычных волн
- 1 boss wave
- Между волнами: 15–30 секунд на выбор награды/перестройку
- Story-heavy transmissions: 4 гарантированных окна за забег

### Recommended pacing
- Wave 1–2: обучение и hook
- Wave 3–4: первый сильный выбор билда
- Wave 5–6: кризис читаемости и проверка синергии
- Wave 7–8: build identity
- Wave 9: пред-боссовый stress test
- Wave 10: boss + ending pulse

---

## 11. Карты и структура поля

## 11.1 Правильный подход к картам
Мы НЕ делаем полностью хаотическую procedural карту.
Мы делаем **hybrid procedural**:
- 3–4 handcrafted macro-topologies,
- случайные вариации слотов, hazard nodes и power nodes,
- curated lane modifiers.

### Почему это важно
Tower defense ломается, когда карта случайна, но неинтересна.  
Поэтому:
- маршруты должны быть читаемыми,
- места для крутых решений должны быть спроектированы,
- рандом должен разнообразить, а не ломать.

## 11.2 Типы секторов на релизе
1. **Relay Spine**
   - длинная центральная линия
   - хорошо работает для beam/chain
2. **Split Chamber**
   - две параллельные линии
   - заставляет делить ресурсы
3. **Orbital Ring**
   - кольцевая карта с пересечениями
   - отлично подходит для контроля и аур
4. **Broken Conduit**
   - короткие агрессивные маршруты
   - high-pressure карта, меньше времени на исправление ошибок

## 11.3 Типы узлов
- **Tower Slot** — можно строить башню
- **Power Node** — увеличивает power cap / усиливает соседние узлы
- **Relay Node** — усиливает сетевые/chain/beam interactions
- **Hazard Node** — искажает врагов или башни в радиусе
- **Core Adjacent Slot** — defensive / panic build zone

---

## 12. Ресурсы и экономика

## 12.1 Ресурсы внутри забега
### SCRAP
Основная валюта на строительство и апгрейды.

### POWER
Лимит сети. Башни занимают power.  
Это ограничивает спам и делает выбор важным.

### SIGNAL CHARGE
Внутренний параметр run-системы, который открывает некоторые resonance-эффекты и альтернативные story choices. Игрок не обязан отслеживать его как отдельную валюту руками постоянно; он может быть представлен как meter.

## 12.2 Persistent currency
### DECODED FRAGMENTS
Выдаются за:
- волны,
- боссов,
- новые transmissions,
- выполнение контрактов,
- новые концовки.

Тратятся на:
- unlock новых башен,
- новые transmissions pools,
- новые run modifiers,
- quality-of-life апгрейды,
- codex tools.

## 12.3 Базовые числа для прототипа
Старт:
- Scrap: 140
- Power Cap: 8
- Core Integrity: 20
- Rerolls: 1

Экономические принципы:
- Tower base cost: 50–90
- Upgrade cost: примерно 1.6x / 2.2x от стоимости башни
- Sellback: 70%
- Wave reward: базовая выплата + flawless bonus + elite bonus
- Flawless bonus должен ощущаться значимо, но не snowball-ломающе

### Цель экономики
Игрок должен чувствовать:
- нехватку ресурсов в начале,
- силу синергии в середине,
- риск переоценить greed в конце.

---

## 13. Башни

На релизе — 6 башен.  
Это достаточно, чтобы были архетипы, но не слишком много для соло-производства и баланса.

## 13.1 Pulse Emitter
Роль:
- базовый single-target DPS

Сильные стороны:
- дешевый старт
- понятный
- хорошо скейлится с attack speed и crit-like modifiers

Слабые стороны:
- плохо против толпы без поддержки

Ветки апгрейда:
- Precision Pulse
- Burst Pulse

## 13.2 Arc Relay
Роль:
- chain damage / coverage

Сильные стороны:
- чистит пачки
- хорошо работает в choke points
- синергирует с relay nodes

Слабые стороны:
- слабее по одиночным tank targets

Ветки:
- Long Arc
- Feedback Arc

## 13.3 Cryo Node
Роль:
- slow / control

Сильные стороны:
- выигрыш времени
- усиливает kill zone
- хорошо сочетается с beam и splash

Слабые стороны:
- сам по себе не убивает

Ветки:
- Deep Freeze
- Fracture Chill

## 13.4 Scrambler Dish
Роль:
- debuff / anti-shield / resistance break

Сильные стороны:
- открывает damage windows
- снижает защиту элит и боссов

Слабые стороны:
- слабый raw DPS

Ветки:
- Armor Break
- Signal Jam

## 13.5 Prism Beam
Роль:
- линейный high-risk high-reward damage

Сильные стороны:
- очень сильный positional payoff
- эффектный в трейлере
- усиливает «вау»-момент

Слабые стороны:
- требует правильной геометрии карты

Ветки:
- Focused Beam
- Refracted Beam

## 13.6 Salvage Matrix
Роль:
- economy / utility / adaptive support

Сильные стороны:
- дает scrap value
- усиливает соседей
- помогает строить greedy builds

Слабые стороны:
- слаб в panic-ситуации

Ветки:
- Salvage Drone
- Power Redistributor

## 13.7 Синергии башен
Сильные pairings:
- Cryo + Prism
- Scrambler + Pulse
- Arc + Relay Nodes
- Salvage + жадные high-cost builds
- Pulse cluster + Captain/Engineer transmissions

---

## 14. Враги

На релизе:
- 6 базовых врагов
- 3 elite modifiers
- 2 босса

## 14.1 Glitch Swarm
- быстрый
- слабый
- учит AoE и choke point'ам

## 14.2 Corrupted Carrier
- медленный tank
- впитывает урон
- проверяет sustained DPS

## 14.3 Mirror Fragment
- делится после смерти
- ломает «overkill» билды

## 14.4 Null Shield
- имеет front shield / first-hit reduction
- требует debuff или обходной урон

## 14.5 Phase Leech
- телепорт/phase-step на короткую дистанцию
- наказывает слишком линейные kill zones

## 14.6 Parasite Packet
- лечит или бафает соседей
- приоритетная цель

## 14.7 Elite modifiers
- **Encrypted** — повышенная защита от контроля
- **Overclocked** — высокая скорость
- **Ghosted** — сниженная вероятность таргетинга / фазовый сдвиг

## 14.8 Bosses
### The Choir
- спавнит эхо-юнитов
- усиливается от непрерванных проходов
- проверяет multi-lane response

### Black Relay
- вызывает EMP pulses
- временно отключает сегменты сети
- проверяет резервный билд и устойчивость

---

## 15. Волны и difficulty curve

### Структура волны
Каждая волна собирается из curated шаблонов:
- rush
- tank push
- split pressure
- healer escort
- elite anchor
- fake lull into spike

### Скейлинг
Wave difficulty растет через:
- HP
- скорость
- composition complexity
- количество special enemies
- наличие elite modifiers
- pressure on under-defended lanes

### Правило честности
Игрок должен иметь возможность понять:
- почему эта волна опасна,
- что именно сломало его билд,
- что можно изменить на следующем run.

---

## 16. Reward system

После каждой волны игрок получает 3 выбора. Типы rewards:
- новая башня
- апгрейд башни
- passive module
- transmission
- power node boost
- emergency repair
- reroll / economy tech

### Правила reward system
- На ранних волнах rewards обучают архетипам.
- На средних волнах rewards усиливают специализацию.
- На поздних волнах rewards должны либо спасать билд, либо форсить смелую ставку.
- Не давать игроку слишком много «пустых» наград.
- На story-windows минимум 1 из 3 выборов должен быть transmission.

### Rerolls
- 1 базовый reroll
- дополнительные через meta/unlocks
- редкий, но ценный ресурс

---

## 17. Transmission system — главное отличие игры

Это центральная система игры.

## 17.1 Что такое transmission
Transmission — это короткий сюжетный фрагмент + механический модификатор.

### Формат
- 2–5 строк текста
- 10–25 секунд озвучки (опционально, но желательно)
- понятный gameplay effect
- 1 риск или trade-off
- truth tag
- codex unlock

## 17.2 Почему это работает
Игрок не выбирает между «сюжет» и «веселье».  
Он выбирает:
- сильный и рискованный стиль,
- безопасный контроль,
- жадную экономику,
- странную resonance-механику,
и одновременно получает историю.

## 17.3 Типы gameplay effects transmissions
- +скорость атаки башен определенного класса
- +дальность / +chain count
- free upgrade, но с heat risk
- бонус к scrap за flawless wave
- shield core, но меньше tower slots
- враги дают больше ресурсов, но волны быстрее
- next wave mutates
- башни вокруг relay nodes получают bonus
- особые tower transformations

## 17.4 Правила pacing
- Transmission не должен превращаться в минутную паузу.
- Основная форма — короткая, punchy, читаемая.
- Полная расшифровка сохраняется в codex для спокойного чтения в hub.
- Во время run игрок получает essence, а не стену текста.

---

## 18. Meta progression

### Цель
Meta должна:
- усиливать желание вернуться,
- давать чувство долгосрочного движения,
- но не ломать баланс и не превращать поражение в фарм-рутину.

### Что открывает meta
- новые башни
- новые sectors
- новые transmissions pools
- новые run modifiers
- новые contracts/challenges
- quality-of-life improvements
- codex utilities
- cosmetic terminal skins / waveform themes

### Что НЕ должна делать meta
Не превращать игру в:
- «без +50% стартового урона неиграбельно»
- обязательный grind
- paywall-like прокачку в premium игре

### Recommended meta balance
- 70% horizontal unlocks
- 20% utility/QoL
- 10% мягкие vertical assists

---

## 19. Hub / meta menu

Hub не должен быть большим 3D-пространством.  
Это **операторский терминал**.

Разделы:
1. Start Run
2. Decode Archive
3. Upgrade Network
4. Crew Dossiers
5. Contracts
6. Settings
7. Stats / Run History

### Почему это хорошо
- дешево в производстве,
- стильно,
- поддерживает diegetic presentation,
- не раздувает scope.

---

## 20. Run modifiers

В начале забега игрок выбирает 1 из 3 modifiers.

Примеры:
- Double Scrap Drops, -2 Power Cap
- +Core Shield, -1 Reward Choice each story window
- Faster Enemies, Better Flawless Bonus
- +1 Free Pulse Emitter, bosses stronger
- Transmission effects stronger, elite enemies tougher

### Дизайн-принцип
Модификатор должен менять мышление игрока уже в первые 2 минуты.

---

## 21. Difficulty modes

На релизе:
- **Standard**
- **Hard Signal**
- **Anomaly Protocol**

### Unlock logic
- Standard доступен сразу
- Hard Signal после первой победы
- Anomaly Protocol после нескольких побед / codex progress

### Цель
Игроки разного уровня должны находить свой уровень глубины, а не отваливаться слишком рано.

---

## 22. Win / Loss / Endings

### Win
Победа = защита ядра до конца boss wave.

### Loss
Поражение = integrity ядра падает до нуля.

### Endings
На релизе:
- 3 основные интерпретации
- 1 synthesis ending

### Как endings работают
После победы или глубокой серии runs игрок видит:
- итоговый truth summary,
- recovered dossier highlights,
- реакцию системы,
- новую unlock-награду,
- tease следующей глубины.

---

## 23. Why players will keep playing

## 23.1 Immediate retention hooks
- сильный визуальный хук в первые секунды
- понятный первый tower placement
- transmission уже в первом run
- поражение дает новый кусок истории, а не пустой экран

## 23.2 Mid-term hooks
- новые башни
- новые doctrines через transmissions
- новые карты
- другие трактовки финала

## 23.3 Long-term hooks
- completionist codex
- difficulty tiers
- contracts
- challenge seeds
- hidden ending
- achievements
- build mastery

---

## 24. Вовлечение игрока и социальная привлекательность

## 24.1 Игровое вовлечение
Чтобы в игру играли, а не просто один раз «посмотрели», нужны:
- ясные архетипы билдов
- неожиданные, но логичные синергии
- запоминающиеся поражения
- маленькие открытия в каждом run
- сильные спасения «на грани»

## 24.2 Story involvement
Игрок должен:
- узнавать имена и конфликты экипажа,
- запоминать их позиции,
- спорить сам с собой: кто виноват,
- замечать, что история влияет на механику.

## 24.3 Community conversation hooks
В игре должны быть вещи, которые хочется обсуждать:
- «какая трактовка событий у тебя выпала»
- «какие transmissions лучший билд открывают»
- «как открыть synthesis ending»
- «какая башня недооценена»
- «что значит последняя реплика JANUS»

## 24.4 Shareability features
На релизе или в раннем патче желательно:
- seed code
- end-of-run build summary
- stats card
- win screen with doctrine/tags summary

---

## 25. Launch content scope (реалистичный)

### 1.0 must-have
- 4 сектора
- 6 башен
- 6 базовых врагов
- 3 elite modifiers
- 2 босса
- 36 transmissions
- 3 + 1 ending structure
- 3 difficulty levels
- meta tree
- codex/dossiers
- achievements
- Steam Cloud
- settings/accessibility baseline
- Steam Deck optimization target
- demo
- trailer
- store page assets

### 1.0 nice-to-have
- challenge seeds
- extra cosmetic terminal themes
- more than 20 achievements
- extra boss variant

### Cut first if needed
- extra sector
- second boss phase complexity
- fancy animated codex transitions
- excessive UI flourishes
- secondary mode
- endless mode

---

## 26. Art direction

## 26.1 Визуальный стиль
**Retro-futuristic CRT / terminal sci-fi / clean tactical grid**

Ощущение:
- Alien / control room mood
- Into the Breach readability
- FTL loneliness
- digital corruption
- phosphor glow and scanlines

### Основной принцип
Красота вторична по отношению к читаемости.  
Эффекты никогда не должны скрывать:
- маршрут врагов,
- радиусы,
- урон,
- дебаффы,
- состояние core.

## 26.2 Art pillars
1. Четкая геометрия
2. Контрастные силуэты
3. Ограниченная палитра
4. Диегетический UI
5. Эффекты corruption как spice, а не шум

## 26.3 Цвет
Основная палитра:
- темный угольно-синий / черный фон
- зеленые терминальные акценты
- янтарные warning-элементы
- холодные cyan/blue defensive эффекты
- красно-пурпурные corruption enemies

## 26.4 Скриншотоспособность
Каждый скриншот должен мгновенно показывать:
- grid
- towers
- incoming threat
- retro sci-fi identity

---

## 27. Audio direction

### Музыка
- ambient sci-fi во время build phase
- напряжение и ритм во время wave phase
- boss layers
- не перегружать мелодией

### SFX
- удовлетворяющий click при установке башни
- читаемые feedback sounds при апгрейде
- distinct enemy death sounds
- glitch bursts для corruption
- low health / breach alarm

### Voice / transmission audio
- ElevenLabs или аналог для коротких pre-generated voice lines
- сильная пост-обработка: radio, static, filtering
- каждая transmission должна работать и без аудио, только текстом

---

## 28. UX / UI

### UX goals
- игра должна быть понятна без гайда
- все ключевые числа и статусы читаемы
- pathing должно быть очевидно
- upgrade choices — быстры и не утомляют

### UI экраны
- Main terminal
- Pre-run selection
- In-run HUD
- Wave reward UI
- Transmission decode UI
- Run summary
- Codex
- Upgrade tree
- Settings

### Правила HUD
Показывать:
- core integrity
- scrap
- power usage
- current wave
- speed control
- selected tower info
- predicted path / node influence
- active doctrines/modifiers

---

## 29. Accessibility and comfort

На релизе:
- remappable controls
- screen shake toggle
- CRT effects intensity slider
- font size option
- color contrast mode
- subtitles / text-first story mode
- pause anywhere in single-player
- speed controls for waves
- clear audio sliders

---

## 30. Steam Deck design target

Чтобы игра работала на Deck:
- крупные UI hit targets
- контроллер-first navigation
- readable font sizes на 7" экране
- стабильно 60 или честные 30+ fps без грязных просадок
- отсутствие keyboard-only blockers

---

## 31. Technical architecture

### Engine
- Godot 4.x stable

### Core systems
1. Grid Manager
2. Slot / Node system
3. Enemy Path & Lane Manager
4. Wave Composer
5. Tower Base Class + subclasses
6. Effect / Status system
7. Reward Draft System
8. Transmission System
9. Meta-progression Save System
10. Codex / Dossier data layer
11. Steam integration layer
12. Analytics/debug event logger

### Tech principle
Все важное data-driven:
- towers
- enemies
- waves
- transmissions
- upgrades
- modifiers
- achievements

Так Claude и человек смогут быстрее добавлять/менять контент без ручной перепрошивки всего проекта.

---

## 32. AI-assisted production pipeline

## 32.1 Главная идея
AI не заменяет креативный контроль.  
AI ускоряет:
- черновики,
- вариации,
- код-скелет,
- итерации документации,
- аудио-заготовки,
- маркетинговые ассеты.

### Финальный контроль всегда человеческий:
- геймплейный фид,
- читаемость,
- ритм,
- баланс,
- legal sanity,
- финальная полировка.

## 32.2 Роли инструментов

### Claude
Используется для:
- GDD refinement
- production breakdown
- backlog / sprint planning
- Godot architecture and code generation
- refactors
- tool scripts
- balancing helpers
- test checklists
- Steam page draft copy
- patch notes and changelog drafts

### Midjourney
Используется для:
- moodboards
- visual exploration
- capsule ideation
- key art composition
- icon direction
- environment concept sheets
- promo composition exploration

**Не использовать как “raw final answer без чистки”** для всего подряд.  
Лучше как:
- ideation engine,
- base concept generator,
- composition blockout.

### ElevenLabs
Используется для:
- placeholder VO
- финальные короткие radio transmissions
- alternate voice tests
- trailer VO draft

### Дополнительные AI-инструменты (по желанию)
- upscalers
- transcription tools
- sound design generators
- prompt organizers
- spreadsheet copilots

---

## 33. Правила безопасного использования AI в производстве

1. Все AI-ассеты проходят human review.
2. Не копировать узнаваемый стиль конкретного живущего художника.
3. Не использовать чужие IP, бренды, персонажей.
4. Хранить:
   - prompt history
   - source outputs
   - edited finals
   - license notes
5. Любой AI-output для игры проходит cleanup/edit pass.
6. Live-generated AI в игре не используем в 1.0.
7. Все player-facing story/audio должны быть художественно консистентны, а не «как получится».
8. Если ассет выглядит юридически или эстетически сомнительно — вырезать.

---

## 34. Asset bible requirements

Для стабильности AI-пайплайна нужен отдельный документ:
**ASSET_BIBLE.md**

Он должен фиксировать:
- палитру
- shape language
- UI grammar
- enemy silhouettes
- tower silhouettes
- effect rules
- tone of writing
- audio treatment notes
- forbidden motifs
- naming conventions

Без asset bible AI начнет «дрейфовать», и игра будет выглядеть как сборник разных проектов.

---

## 35. Writing bible requirements

Нужен отдельный документ:
**NARRATIVE_BIBLE.md**

Он должен фиксировать:
- хронологию катастрофы
- голоса всех членов экипажа
- truth axes
- какие факты объективны, а какие спорны
- тон каждой линии transmissions
- что нельзя раскрывать слишком рано
- финальные интерпретации
- lexicon станции и мира

---

## 36. Production methodology

Работаем не календарем, а **gates + milestones**.

## Gate 1 — Proof of Fun
Минимальная версия:
- 1 карта
- 3 башни
- 3 врага
- 5 волн
- 1 мини-босс
- без meta
- без большого сюжета

### Вопрос gate 1:
игра уже интересна без «обещаний на будущее»?

Если нет:
- переписываем карту,
- переписываем экономику,
- переписываем башни,
но не расширяем scope.

## Gate 2 — Vertical Slice
- 1 polished sector
- 4 башни
- 4 врага
- 10 transmissions
- готовый визуальный стиль
- работающий HUD
- первая store-worthy запись геймплея

### Вопрос gate 2:
игра уже выглядит как продукт, который можно показать людям?

## Gate 3 — Content Complete Alpha
- весь контент 1.0 в игре
- все systems connected
- balance rough, но полон
- codex / meta работают

## Gate 4 — Beta / External Testing
- внешние игроки понимают игру
- критические UX issues закрыты
- performance acceptable
- demo stable

## Gate 5 — Release Candidate
- store page ready
- achievements ready
- build stable
- no known critical bugs
- launch assets complete

---

## 37. Пример реального плана производства

### Полный реалистичный план
- Preproduction: 2 недели
- Prototype / Gate 1: 2–3 недели
- Vertical Slice: 3–4 недели
- Alpha production: 5–7 недель
- Beta / polish / demo / store assets: 4–6 недель
- Release prep: 2 недели

### Итого
- aggressive full-time: ~18 недель
- realistic full-time: ~22–24 недели

---

## 38. Конкретный production backlog высокого уровня

## Phase A — Preproduction
- зафиксировать GDD v2
- сделать asset bible
- сделать narrative bible
- настроить Godot project skeleton
- определить naming conventions
- определить data formats (JSON/Resource files)
- сделать UI wireframes
- собрать референс-пакет

## Phase B — Proof of Fun
- grid + slots
- tower placement
- pathing
- 3 towers
- 3 enemies
- waves
- reward choice
- run fail/win loop

## Phase C — Vertical Slice
- polished HUD
- transmission system
- first codex
- first music/SFX pass
- first trailer capture
- first screenshots
- first store capsule ideation

## Phase D — Alpha
- все башни
- все враги
- все sectors
- bosses
- meta tree
- codex completion
- achievements draft
- save/load
- crash logging

## Phase E — Beta / Market Readiness
- external testing
- balance pass
- Steam integration
- deck optimization
- store page copy
- trailer final
- demo final
- streamer/press list

## Phase F — Launch
- RC build
- review checklist
- launch comms
- launch discount setup
- monitoring dashboard
- response templates for bugs/reviews/community

---

## 39. QA и playtest framework

## Что тестировать в первую очередь
1. Читаемость поля
2. Понимание pathing
3. Понимание экономики
4. Чувство импакта башен
5. Понятность reward choices
6. Не тормозит ли transmission pacing
7. Почему игрок проигрывает
8. Возникает ли желание еще одного run

## Вопросы к тестерам
- Ты понял, что делать в первые 60 секунд?
- Ты понял, почему именно эта башня полезна?
- История мешала темпу или усиливала интерес?
- Ты хотел еще один run после поражения?
- Что было самым классным моментом?
- Что было самым мутным/раздражающим?

## Метрики
- % игроков, дошедших до wave 3
- % игроков, начавших второй run
- средняя длина run
- pick rate rewards/transmissions
- win rate по секторам
- quit-before-wave-2
- most common death reason
- most ignored towers
- most loved towers

---

## 40. Финальный quality bar

Игра не идет в релиз, пока:
- не читается на первом взгляде,
- не вызывает желания сделать второй run,
- не имеет сильного первых 10 секунд геймплея,
- не имеет минимум одной реально обсуждаемой «вау»-механики,
- не держит положительные реакции на core loop без объяснений автора.

---

## 41. Steam / релизная стратегия

### Рекомендуемая стратегия
Для этого проекта лучше:
- **НЕ идти в Early Access**, если игра компактная и narrative-heavy,
- использовать **Steam Playtest** для внешнего теста,
- выйти в **full release**, когда контент и UX реально готовы.

### Почему
Signal Lost продается как:
- законченное premium single-player переживание,
- а не как песочница «допилим потом».

---

## 42. Demo strategy

Demo должна не «отдавать игру бесплатно», а продавать fantasy.

### Demo scope
- 1 сектор
- 3–4 башни
- 4–5 волн
- 1 transmission branch
- 1 mini-boss
- codex teaser
- cliffhanger после first truth reveal

### Цель demo
Игрок после demo должен:
- захотеть увидеть больше башен,
- захотеть раскрыть тайну,
- понять, что это не только TD,
- добавить игру в wishlist.

---

## 43. Маркетинг-позиционирование

### Главный маркетинговый угол
**“The story changes your build.”**

Это сильнее, чем:
- «roguelike tower defense»
- «sci-fi mystery»
- «procedural storytelling»

Потому что это сразу описывает уникальный actionable hook.

### Secondary angles
- compact replayable sci-fi strategy
- one more run tower defense
- retro terminal aesthetic
- mystery told through dangerous upgrades

---

## 44. Steam page messaging

### Short Description
Нужно быстро объяснить:
- жанр,
- уникальный twist,
- fantasy.

Формула:
**Defend a dying deep-space relay in a roguelite tower defense where every decoded transmission changes your build—and reveals what destroyed the station.**

### Store bullets
1. Build a relay network of synergistic towers
2. Decode transmissions that alter your run
3. Uncover conflicting truths about the crew’s fate
4. Master handcrafted sectors with procedural variation
5. Replay for new builds, endings, and high-difficulty anomalies

---

## 45. Trailer strategy

### Trailer 1 (Steam first trailer)
Обязательно gameplay-first.

### Structure
0–5 сек:
- чистый, красивый, понятный геймплейный кадр
- башни стреляют
- видно угрозу
- видно стиль

5–20 сек:
- core hook
- «decode transmissions / change your build»

20–40 сек:
- escalation
- boss moment
- visual payoff
- story flashes

40–60 сек:
- endings tease
- CTA / wishlist

### Trailer principles
- работает без звука
- HUD не скрывать полностью
- не тратить первые секунды на лого
- не делать «атмосферный трейлер ни о чем»

---

## 46. Контент-план до релиза

## Devlog content pillars
1. satisfying tower interactions
2. transmission-driven builds
3. visual polish / CRT identity
4. behind-the-scenes AI-assisted workflow
5. boss / anomaly reveals
6. story fragments without спойлеров

### Типы контента
- GIF of the week
- one mechanic posts
- before/after polish posts
- short dev clips
- audio/radio teases
- “which truth do you believe?” posts

---

## 47. Community and creator strategy

### Кто нужен
Не только большие стримеры.  
Нужны:
- small/mid creators по strategy/roguelite niche
- Steam curators
- YouTube channels с «indie strategy»
- TikTok/Shorts creators, если есть visually satisfying clips

### Почему игра может смотреться хорошо
- понятные визуальные ситуации
- билды легко обсуждать
- история вызывает теории
- можно спорить, какой выбор был правильным

---

## 48. Рекомендуемая release timeline от текущей даты

Текущая дата документа: **8 марта 2026**.

### Самый разумный сценарий
- март–май 2026: preproduction + prototype + vertical slice
- июнь 2026: store page live + начальный Steam Playtest / первые wishlists
- июль–август 2026: alpha/beta + контент + polish
- сентябрь 2026: demo final + creator outreach
- октябрь 2026: Steam Next Fest
- ноябрь 2026: релиз
- декабрь 2026: первый крупный discount/event beat, если позволяет cooldown

Это лучше, чем пытаться насильно успеть к июньскому фестивалю без качества.

---

## 49. Post-launch plan

### Первые 90 дней
Нужны не «обещания», а 3 четких update beats.

## Update 1 — 2–3 недели после релиза
- balance patch
- QoL
- bugfixes
- 2–4 new transmissions
- 1 new contract set

## Update 2 — 4–6 недель после релиза
- 1 elite variant
- 1 modifier family
- 1 new codex thread
- stronger progression smoothing

## Update 3 — 8–12 недель после релиза
- challenge seeds / score mode
- 1 tower variant or sector mutator
- hidden lore thread
- “major update” announcement

### Почему это важно
Игра должна показывать жизнь после релиза, но без обещаний, которые невозможно выполнить.

---

## 50. Пострелизная монетизация

На 1.0:
- только base premium game

Возможные safe options позже:
- soundtrack
- supporter pack
- small cosmetic terminal themes
- lore mini-DLC только если base game реально зашла

Не делать сразу:
- battle pass
- intrusive DLC plan
- раздробленный контент на старте

---

## 51. Основные риски проекта

## Risk 1 — TD core не fun
Решение:
- жесткий Gate 1
- cut narrative complexity until gameplay works

## Risk 2 — Narrative тормозит темп
Решение:
- short-form transmissions in run
- full text only in codex

## Risk 3 — AI-ассеты выглядят непоследовательно
Решение:
- asset bible
- cleanup pass
- strict final style rules

## Risk 4 — Scope creep
Решение:
- feature freeze
- must-have vs nice-to-have board
- cut policy written in advance

## Risk 5 — Слишком поздний маркетинг
Решение:
- store messaging and trailer thinking from vertical slice
- devlogs begin early

## Risk 6 — Юридическая/этическая проблема AI-контента
Решение:
- prompt archive
- asset review
- no suspicious outputs
- transparent disclosure where needed

---

## 52. Definition of Done for 1.0

Игра считается готовой к релизу, если:
- core loop fun без объяснений автора
- 20–30 минутный run ощущается плотным
- минимум 6 башен реально используются
- минимум 3 build archetypes жизнеспособны
- story fragments читаются и запоминаются
- transmission system признана testers как сильная фича
- store page materials уже выглядят коммерчески
- demo оставляет сильный cliffhanger
- performance стабильный
- no critical bugs
- вы лично готовы поставить за продукт деньги

---

# ОПЕРАЦИОННЫЙ БЛОК ДЛЯ CLAUDE

Ниже текст, который можно дать Claude как рабочую инструкцию.

---

## Claude Master Prompt

Ты — мой executive producer, game designer, technical design lead и AI workflow architect для игры SIGNAL LOST.

Твоя задача:
не просто помогать идеями, а **перестроить весь процесс создания игры** по этому документу так, чтобы проект был реалистично доведен до коммерческого релиза на Steam.

### Твои правила
1. Считай этот GDD единственным source of truth.
2. Не расширяй scope без явной причины.
3. Если видишь риск раздувания проекта — режь фичи, а не добавляй сроки.
4. Всегда предпочитай решения, которые:
   - усиливают gameplay clarity,
   - усиливают replayability,
   - усиливают marketability,
   - уменьшают production risk.
5. Не предлагай live-generated AI в версии 1.0.
6. Всегда отличай:
   - MUST HAVE
   - SHOULD HAVE
   - NICE TO HAVE
7. Любую новую идею оцени по формуле:
   - влияет ли она на fun?
   - влияет ли она на sellability?
   - сколько она стоит в производстве?
   - можно ли ее отложить на post-launch?
8. Никогда не заменяй playtesting фантазией.
9. Все задачи должны быть оформлены так, чтобы их можно было делать последовательно solo-разработчику с AI-помощью.
10. Вся документация, код-скелеты, пайплайны и чеклисты должны быть практичными и готовыми к использованию.

### Что ты должен сделать по шагам

#### Шаг 1. Production Breakdown
Разбей весь проект на:
- эпики,
- системы,
- контентные блоки,
- milestone gates,
- weekly execution plan.

#### Шаг 2. Build Order
Создай идеальный порядок разработки:
- что делать первым,
- что вторым,
- что нельзя делать до proof of fun,
- что можно отложить.

#### Шаг 3. Technical Architecture
Опиши архитектуру Godot-проекта:
- сцены,
- singleton/autoloads,
- data files,
- tower classes,
- enemy classes,
- reward drafting,
- transmission system,
- save/meta structure,
- Steam integration points.

#### Шаг 4. Task System
Для каждого блока делай:
- цель,
- список файлов,
- dependency map,
- acceptance criteria,
- тестовый сценарий,
- risk notes.

#### Шаг 5. AI Workflow
Построй отдельные пайплайны для:
- Claude (code/docs/planning)
- Midjourney (moodboards/concepts/capsules)
- ElevenLabs (voice drafts/transmissions/trailer VO)

Для каждого пайплайна дай:
- input format,
- output format,
- naming conventions,
- quality checklist,
- review policy.

#### Шаг 6. Writing and Content
Сделай:
- narrative bible structure,
- transmission template,
- crew voice guide,
- lore continuity checklist,
- spoiler ladder.

#### Шаг 7. Market Readiness
Сделай:
- Steam page asset checklist,
- demo scope checklist,
- trailer shot list,
- creator outreach sheet structure,
- prelaunch/postlaunch comms templates.

#### Шаг 8. Anti-scope control
Создай:
- cut list policy,
- feature freeze rules,
- “if behind schedule” decision tree,
- “what to cut first” matrix.

### Формат ответа, который я хочу от тебя
Каждый большой ответ оформляй как:
1. Executive Summary
2. Decisions
3. Risks
4. Action Plan
5. Deliverables
6. Next Output You Will Produce

### Первый ответ, который я хочу от тебя после чтения этого GDD
Сделай сразу:
1. Полный production breakdown проекта
2. Roadmap по milestone gates
3. Приоритетный backlog на первые 4 недели
4. Architecture skeleton для Godot
5. Список документов, которые нужно создать следом:
   - ASSET_BIBLE.md
   - NARRATIVE_BIBLE.md
   - TECH_ARCHITECTURE.md
   - CONTENT_PIPELINE.md
   - STEAM_RELEASE_PLAN.md
6. “What to cut first” список
7. Список 10 самых опасных рисков проекта и как их предотвратить

### Запреты
- Не говори общими словами.
- Не давай мотивационные речи.
- Не пиши “это зависит” без конкретного решения.
- Не предлагай 20 альтернатив там, где нужна одна рабочая.
- Не расписывай бессмысленные теории, если можно дать production-ready план.
- Не пытайся сделать проект больше. Твоя задача — сделать его лучше и довести до релиза.

---

# Краткий итог для владельца проекта

Если мы хотим, чтобы SIGNAL LOST покупали и в него играли:
1. Core TD должен быть очень ясным и приятным.
2. Narrative must change the run.
3. Scope must stay small and premium.
4. Store page and trailer thinking must start early.
5. AI must accelerate execution, not replace judgment.
6. Каждая фича должна либо делать игру веселее, либо продавать ее лучше, либо удерживать игрока дольше. Иначе она не нужна.
