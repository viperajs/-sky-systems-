if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/config/locales/ru.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

-- Russian translation
Locales["ru"] = {
  WardrobeHelpNotify = "Открыть гардероб",
  WardrobeTitle = "Гардероб",
  WardrobeCivilianMissing = "Гражданский наряд ещё не сохранён.",
  WardrobeCivilianRestored = "Гражданский наряд загружен.",
  WardrobeUnsupportedFramework = "Гардероб не работает с выбранным фреймворком ({framework}).",
  WardrobeMissingSkinchanger = "Для гардероба на ESX должен быть запущен skinchanger.",
  WardrobeMissingEsxSkin = "Для гардероба на ESX должен быть запущен esx_skin.",
  WardrobeMissingQbClothing = "Для гардероба на {framework} должен быть запущен qb-clothing.",
  WardrobeMissing17Movement = "Для гардероба должен быть запущен 17mov_CharacterSystem.",
  WardrobeMissingQsAppearance = "Для гардероба должен быть запущен qs-appearance.",
  WardrobeMissingAk47Clothing = "Для гардероба должен быть запущен ak47_clothing.",
  WardrobeMissingAk47QbClothing = "Для гардероба должен быть запущен ak47_qb_clothing.",
  WardrobeMissingTgiannClothing = "Для гардероба должен быть запущен tgiann-clothing.",
  WardrobeMissingNfSkin = "Для гардероба должен быть запущен nf-skin.",
  WardrobeMissingBlAppearance = "Для гардероба должен быть запущен bl_appearance.",
  WardrobeMissingIzzyAppearance = "Для гардероба должен быть запущен izzy-appearance.",
  WardrobeMissingCodemAppearance = "Для гардероба должен быть запущен codem-appearance.",
  WardrobeMissingHexClothing = "Для гардероба должен быть запущен hex_clothing.",
  WardrobeMissingIllenium = "Для гардероба должен быть запущен illenium-appearance.",
  WardrobeCustomUnavailable = "Настроенная пользовательская интеграция гардероба недоступна.",
  WardrobeDisabled = "Гардероб отключен в конфигурации.",
  WardrobeMissingRcoreClothing = "Для гардероба должен быть запущен rcore_clothing.",
  WardrobeUnknownJob = "Работа гардероба недоступна.",
  GarageHelpNotify = "Открыть гараж",
  GarageTitle = "Гараж",
  HelicopterGarageHelpNotify = "Открыть вертолётную площадку",
  BoatGarageHelpNotify = "Открыть причал",
  GarageParkHelpNotify = "Припарковать транспорт",
  HelicopterGarageParkHelpNotify = "Припарковать вертолёт",
  BoatGarageParkHelpNotify = "Припарковать лодку",
  GarageParkDriverRequired = "Вы должны быть на водительском месте, чтобы припарковать транспорт.",
  GarageParkInvalidVehicle = "Этот транспорт нельзя припарковать здесь.",
  GarageParkFailedNotify = "Не удалось припарковать транспорт.",
  GarageSpawnBlockedNotify = "Точка спавна занята.",
  StorageHelpNotify = "Открыть хранилище",
  LockerHelpNotify = "Открыть шкафчик",
  TrunkTitle = "Багажник",
  TrunkHelpNotify = "Открыть багажник",
  TrunkPropRemoveHelp = "Удалить установленный объект",
  TrunkUnavailable = "Не удалось получить доступ к этому багажнику.",
  BossMenuHelpNotify = "Открыть управление",
  Payroll = {
    title = "Зарплата",
    paid = "Получена зарплата: {amount}",
    insufficient = "Недостаточно средств на счёте компании для выплаты вашей зарплаты.",
  },
  PublicFormsTitle = "Публичные формы",
  PublicFormsHelpNotify = "Заполнить публичные формы",
  PublicFormsUnavailable = "Киоск публичных форм недоступен.",
  WholesaleShopTitle = "Оптовый магазин",
  WholesaleShopHelpNotify = "Открыть оптовый магазин",
  WholesaleShopUnavailable = "Для этого места не настроен оптовый поставщик.",
  NoPermission = "У вас нет прав для использования этой команды.",
  CameraUploadFailed = "Не удалось загрузить снимок с камеры.",
  MultiJob = {
    Title = "Jobs",
    GiveTitle = "Give Job",
    RemoveTitle = "Remove Job",
    ConsoleOnly = "/{command} can only be used in-game.",
    MenuUnavailable = "Multi-job menu is unavailable.",
    UsageGive = "Usage: /{command} <playerId> <job> [grade]",
    UsageRemove = "Usage: /{command} <playerId> <job>",
    AddFailed = "Failed to add job ({error}).",
    Added = "Added {job} grade {grade} to ID {target}.",
    Unlocked = "New job unlocked: {job}.",
    RemoveFailed = "Failed to remove job.",
    Removed = "Removed {job} from ID {target}.",
    RemovedTarget = "Job removed: {job}.",
    DefaultJobProtected = "The configured default job cannot be removed.",
    ProtectedJobCannotRemove = "This job cannot be removed by yourself.",
    AdminTitle = "Multi-job Admin",
    UsageAdmin = "Usage: /{command} <playerId> [list|add|set|remove] [job] [grade]",
    AdminListHeader = "ID {target} ({player}) has {count}/{max} jobs:",
    AdminListEmpty = "No jobs stored.",
    AdminListRow = "{job} ({label}) grade {grade} - {gradeLabel}{flags}",
    AdminFlagActive = "active",
    AdminFlagProtected = "protected",
    AdminAdded = "Added {job} grade {grade} to ID {target}.",
    AdminSet = "Set {job} grade {grade} for ID {target}.",
    AdminRemoved = "Removed {job} from ID {target}.",
    AdminUpdatedTarget = "Your job access was updated: {job} grade {grade}."
  },  Panic = {
    Title = "Тревога",
    Sent = "Тревожная кнопка активирована.",
    NotOnDuty = "Вы должны быть на смене, чтобы использовать тревожную кнопку.",
    Cooldown = "Тревожная кнопка перезаряжается. Подождите {seconds}с.",
    MappingDescription = "Активировать тревожный сигнал",
    WaypointSet = "Метка установлена на место тревоги.",
    WaypointMissing = "Нет активного места тревоги.",
    LocationUnknown = "Неизвестное местоположение",
    MissingItem = "Для использования тревожной кнопки вам нужен {item}.",
  },
  Ping = {
    Title = "Пинг",
    Sent = "Метка местоположения отправлена.",
    NotOnDuty = "Вы должны быть на смене, чтобы отправить пинг.",
    Cooldown = "Пинг перезаряжается. Подождите {seconds}с.",
    MappingDescription = "Отправить метку местоположения",
    LocationUnknown = "Неизвестное местоположение",
    MissingItem = "Для отправки пинга вам нужен {item}.",
  },
  HeliCam = {
    Title = "Вертолётная камера",
    CamEnabled = "Вертолётная камера включена.",
    CamDisabled = "Вертолётная камера отключена.",
    NotAuthorized = "У вас нет доступа к использованию вертолётной камеры.",
    NotOnDuty = "Вы должны быть на смене, чтобы использовать вертолётную камеру.",
    TooLow = "Вертолёт находится слишком низко для активации камеры.",
    TargetLocked = "Цель захвачена.",
    TargetReleased = "Захват цели снят.",
    TargetLost = "Цель потеряна.",
    RappelDenied = "Вы не можете спуститься по тросу с этого места.",
    RappelStarted = "Спуск по тросу начат.",
    PhotoSaved = "Фото с вертолёта сохранено в галерею.",
    PhotoFailed = "Не удалось сохранить фото с вертолёта.",
    Spotlight = {
      ForwardOn = "Прожектор включён.",
      ForwardOff = "Прожектор выключен.",
      TrackingOn = "Режим слежения прожектора активирован.",
      TrackingOff = "Режим слежения прожектора отключён.",
      ManualOn = "Ручной режим прожектора активирован.",
      ManualOff = "Ручной режим прожектора отключён.",
      Brightness = "Яркость прожектора: {value}",
      Radius = "Радиус прожектора: {value}"
    }
  },
  InteractionLabels = {
    job_garage              = "Рабочий гараж",
    garage_vehicle_spawn    = "Точка спавна транспорта",
    garage_vehicle_park     = "Парковка транспорта",
    garage_helicopter_menu  = "Вертолётный гараж",
    garage_helicopter_spawn = "Точка спавна вертолёта",
    garage_helicopter_park  = "Парковка вертолёта",
    garage_boat_menu        = "Лодочный причал",
    garage_boat_spawn       = "Точка спавна лодки",
    garage_boat_park        = "Парковка лодки",
    boss_menu               = "Меню начальника",
    duty_terminal           = "Терминал смены",
    wardrobe                = "Гардероб",
    storage                 = "Хранилище",
    locker                  = "Шкафчик",
    wholesale_shop          = "Оптовый магазин",
    public_forms            = "Публичные формы",
    jail_terminal           = "Тюремный терминал",
    jail_jobs               = "Тюремные работы",
    jail_job_npc            = "Тюремные работы",
    jail_inmate_alcoholic   = "Заключённый: Алкоголик",
    jail_inmate_drugdealer  = "Заключённый: Наркодилер",
    jail_inmate_codelist    = "Заключённый: Информатор",
    jail_inmate_wirecutter  = "Заключённый: Посыльный с инструментами",
    jail_inmate_doctor      = "Тюремный врач",
    jail_canteen_cook       = "Повар столовой",
    jail_confiscated_return = "Конфискованные предметы",
    jail_electric_box       = "Электрощиток",
    jail_fence_cut          = "Точка разреза забора",
  },
  Nui = {
    IntlLocale = "ru-RU",
    currency = "$",
    menuTitles = {
      locker = "Личный шкафчик",
      storage = "Хранилище",
      trunk = "Хранилище транспорта",
      ["trunk-props"] = "Предметы транспорта",
      search = "Поиск",
      garage = "Гараж",
      vehshop = "Магазин транспорта",
      management = "Управление",
      shop = "Оптовый магазин",
      ["impound-storage"] = "Хранилище штрафстоянки",
      refunds = "Возвраты"
    },
    menu = {
      goToVehicleShop = "Перейти в магазин транспорта",
      backToGarage = "Вернуться в гараж"
    },
    workshopConfig = {
      header = { title = "Job Configurator" },
      sidebar = { features = "Features", entries = "Jobs", interactions = "Interactions" },
      sections = { general = "General", shop = "Shop", props = "Props", vehicles = "Vehicles", locations = "Locations" },
      actions = { add = "Add", addItem = "Add item", addPart = "Add part", addProp = "Add prop", addVehicle = "Add vehicle", apply = "Apply", back = "Back", cancel = "Cancel", close = "Close", done = "Done", edit = "Edit", newEntry = "New job", pickColor = "Pick", reset = "Reset", save = "Save", set = "Set", teleport = "Teleport", unset = "Unset" },
      editor = { editTitle = "Edit job", newTitle = "New job" },
      overview = { subtitle = "Select a job to edit or create a new one from the last saved settings.", emptySubtitle = "Create the first job to start moving this config into the database.", counts = "{shop} shop / {vehicles} vehicles / {props} props" },
      features = {
        title = "Функции",
        subtitle = "Включайте или отключайте функции ресурса для всех настроенных работ.",
        instantTuning = { label = "Мгновенный тюнинг", description = "Разрешает прямой тюнинг в настроенных публичных точках." },
        partsDelivery = { label = "Доставка деталей", description = "Включает заказы деталей мастерской и зоны доставки." },
        carryItems = { label = "Физическая обработка деталей", description = "Требует переносить доставленные детали через мастерскую." },
        nitro = { label = "Нитро", description = "Включает установку нитро и ускорение автомобиля." },
        antiLag = { label = "Антилаг", description = "Включает установку антилага и эффекты выхлопа." },
        twoStep = { label = "Two-Step", description = "Включает two-step launch control и эффекты выхлопа." },
        wheelDamage = { label = "Повреждения колес", description = "Включает реалистичные повреждения колес и ремонт." },
        customHandling = { label = "Пользовательский handling", description = "Включает настройку трансмиссии и handling." },
        mileageHud = { label = "HUD пробега", description = "Показывает пробег автомобиля во время езды." },
        workshopLift = { label = "Подъемник мастерской", description = "Включает используемые точки подъемников в мастерских." }
      },
globalSettings = { title = "Global settings", notice = "These values apply to all configured jobs. Saving them from this job updates the behavior globally." },
      tuning = { globalTitle = "Global pricing settings", globalBadge = "Global", globalNotice = "These values apply to all configured jobs. Saving them from this job updates pricing behavior globally.", nitroAccess = "Доступ к нитро для этой работы", nitroAccessHelp = "Переопределить глобальную настройку нитро для этой работы механика.", nitroAccessInherit = "Использовать глобальную настройку нитро", nitroAccessEnabled = "Включить нитро для этой работы", nitroAccessDisabled = "Отключить нитро для этой работы" },
      fields = { allowedJobs = "Разрешенные работы", animationDict = "Animation dict", animationName = "Animation name", blip = "Blip", bone = "Bone", category = "Категория", color = "Цвет работы", consumeItems = "Расходовать предметы", cost = "Стоимость", distance = "Дистанция", enabled = "Включено", garageType = "Тип гаража", heading = "Направление", item = "Предмет", jobName = "Название работы", label = "Метка", marker = "Маркер", mechanicOnly = "Механик", name = "Имя", offsetX = "Offset X", offsetY = "Offset Y", offsetZ = "Offset Z", offDutyEnabled = "Вне смены включено", offDutyJob = "Работа вне смены", ped = "Ped", pedModel = "Ped model", price = "Цена", prop = "Prop", requiredItems = "Требуемые предметы", scenario = "Scenario", sprite = "Sprite", stage = "Этап", transport = "Транспорт", trunkCapacity = "Объем багажника", type = "Тип", value = "Значение", x = "X", y = "Y", z = "Z", minGrade = "Мин. ранг", livery = "Окраска", fuelType = "Тип топлива", primaryColor = "Основной цвет", secondaryColor = "Вторичный цвет", pearlescentColor = "Перламутровый цвет", wheelColor = "Цвет колёс", extras = "Дополнения", extraId = "ID дополнения", propCounts = "Лимиты пропов", count = "Лимит", properties = "Свойства транспорта", property = "Свойство" },
      placeholders = { allowedJobs = "mechanic, tuner", itemName = "Item name", jobName = "job name", label = "Label", model = "Model", vehicleName = "Name", liveryIndex = "e.g. 0", paintIndex = "0-160", propCounts = "{ \"prop_model\": 4 }", properties = "{ \"windowTint\": 1 }" },
      fuelTypes = {
        default = "По умолчанию (обычный)",
        regular = "Обычный",
        plus = "Plus",
        premium = "Премиум",
        diesel = "Дизель",
      },
      descriptions = { color = "Color used by Sky Jobs menus, blips, and job UI accents.", jobName = "Framework job name registered for this job.", offDutyEnabled = "Enable an off-duty counterpart for this job.", offDutyJob = "Job name used when this employee goes off duty." },
      messages = { empty = "No jobs configured yet.", featuresSaved = "Features saved.", invalidJson = "Correct invalid JSON fields before saving.", loading = "Loading jobs...", nameExists = "A job with this job name already exists.", noTuningOptions = "No options configured in this category.", saved = "Settings saved.", saveFailed = "Unable to save changes." },
      locations = { addSubtitle = "Choose which point type to place.", addTitle = "Add location point", deleteFailed = "Unable to delete location.", deleteSaved = "Location removed. Save settings to apply it.", emptySubtitle = "This configurator has no registered location definitions.", emptyTitle = "No locations configured.", garageMenu = "Menu", garagePark = "Park", garageSpawn = "Spawn", placeFailed = "Unable to place location.", placementHint = "Press Enter to place and Backspace to cancel.", placementSaved = "Location updated. Save settings to apply it.", placementTitle = "Placement mode", teleported = "Teleported to location.", teleportFailed = "Unable to teleport to location.", unset = "Not set" },
      carryItems = { missingProp = "Enter a prop model before opening placement.", placementFailed = "Unable to edit attach placement.", placementSaved = "Attach placement updated. Save settings to apply it.", selectItem = "Select delivery item" },
      extensions = { invalidJson = "Неверный JSON. Исправьте синтаксис перед сохранением.", jsonObjectRequired = "Значение должно быть JSON-объектом.", partsDeliveryShop = "Магазин доставки деталей", tuningCostProfile = { label = "Цены тюнинга", description = "Настройте стоимость производительности, внешнего вида, колес и специальных опций для этой работы." } },
garageTypes = { boat = "Boat", helicopter = "Helicopter", vehicle = "Vehicle" },
      colorPopup = { title = "Job color" },
      dialogs = { delete = { cancel = "Cancel", confirm = "Delete", message = "Delete {name}?", title = "Delete job" } },
      screenPosition = { preview = "HUD" },
      interactions = { title = "Interactions", empty = "No interactions configured.", addMarkerSetting = "Add marker setting", noPedSelected = "No ped selected", headers = { interaction = "Interaction", key = "Key", marker = "Marker", blip = "Blip", npc = "NPC" }, tabs = { behavior = "Behavior", marker = "Marker", blip = "Blip", npc = "NPC" }, status = { on = "On", off = "Off" }, fields = { unique = "Unique", forceMarkerInteraction = "Force marker interaction", interactionDistance = "Interaction distance", placementModel = "Placement model" }, help = { unique = "Limits the interaction type to one configured point for a location when enabled.", forceMarkerInteraction = "Forces marker-style interaction handling even when target/NPC interaction support is available.", interactionDistance = "Maximum distance from the point where the player can use the interaction.", placementModel = "Object model shown while placing this interaction in the creator." } },
      assetPicker = { search = "Search", allCategories = "All categories", itemCount = "{count} items", markerTitle = "Marker type", markerSubtitle = "Choose a DrawMarker type.", blipTitle = "Blip sprite", blipSubtitle = "Choose a map blip sprite.", pedTitle = "Ped model", pedSubtitle = "Choose a FiveM ped model.", chooseMarker = "Choose marker", chooseBlip = "Choose blip", choosePed = "Choose ped" },
      markerFields = { posX = "Position X", posY = "Position Y", posZ = "Position Z", dirX = "Direction X", dirY = "Direction Y", dirZ = "Direction Z", rotX = "Rotation X", rotY = "Rotation Y", rotZ = "Rotation Z", scaleX = "Scale X", scaleY = "Scale Y", scaleZ = "Scale Z", red = "Red", green = "Green", blue = "Blue", alpha = "Alpha", bobUpAndDown = "Bob up/down", faceCamera = "Face camera", rotationOrder = "Rotation order", rotate = "Rotate", textureDict = "Texture dict", textureName = "Texture name", drawOnEnts = "Draw on entities" },
      instantTuning = { title = "Instant Tuning", defaultLabel = "Default label", defaultLabelHelp = "Text shown at instant tuning points.", interactionDistanceHelp = "Default distance from which a point can be used.", priceMultiplier = "Price multiplier", priceMultiplierHelp = "Multiplier applied to instant tuning prices.", forceMarkerHelp = "Forces marker-style interaction handling even when target support is available.", mechanicOnlyHelp = "Restricts every instant tuning point to configured mechanic jobs.", allowedJobsHelp = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", emptyLocations = "No instant tuning locations configured.", emptyLocationsHelp = "Add a location, then use Set to capture your current position." }
  ,

      configs = { sky_mechanicjob = { title = "Работы механика", subtitle = "Настройте работы механика, магазины, транспорт и точки мастерских." } },
      settingSections = { general = "Общее", partsTheft = "Кража деталей", vehicleCare = "Уход за авто", wear = "Износ", wheelDamage = "Повреждения колес", mileageHud = "HUD пробега", instantTuning = "Instant Tuning", carryItems = "Переносимые детали" },
      settingFields = { key = "Ключ", label = "Метка", name = "Название предмета", amount = "Количество", price = "Цена", item = "Предмет", repair = "Ремонтировать набором", classId = "ID класса", multiplier = "Множитель", kilometersToZero = "Километры до нуля", removeAfterUse = "Расходовать предмет", flow = "Процесс установки", transport = "Транспорт", prop = "Prop", bone = "Bone", x = "X", y = "Y", z = "Z", rx = "Rot X", ry = "Rot Y", rz = "Rot Z", category = "Категория" },
      settings = {
        primaryColor = { label = "Основной цвет", description = "Main mechanic configurator color and default job color fallback. Use a hex value such as #EDC001." },
        orderInstallNonMinigameDurationMs = { label = "Простая длительность установки", description = "Milliseconds used for order install steps that do not run a minigame." },
        tuningWorkshopRequireForInstall = { label = "Require workshop for installs", description = "Require tuning order installs to start and complete near a self-service tuning point." },
        tuningWorkshopRequireForRemoval = { label = "Require workshop for removals", description = "Require tuning removals to start and complete near a self-service tuning point." },
        tuningWorkshopDistance = { label = "Workshop requirement distance", description = "Maximum distance from a self-service tuning point for required install or removal actions." },
        addRevenueToSociety = { label = "Deposit revenue to society", description = "Deposit paid tuning order money into the tuning job society account." },
        publicUsersSeePrices = { label = "Public users see prices", description = "Show regular tuning prices to non-mechanic public users." },
        fallbackVehicleValue = { label = "Fallback vehicle value", description = "Value used when no vehicle price can be resolved." },
        priceType = { label = "Тип цены", description = "Percentage calculates each tuning cost from the vehicle price. Fixed uses the entered money amount.", options = { percentage = "Процент", fixed = "Фиксировано" } },
        freeVehicles = { label = "Free tuning vehicles", description = "Vehicle spawn models that receive free tuning orders.", itemLabel = "Vehicle model" },
        partsTheftItem = { label = "Инструмент кражи", description = "Inventory item used to steal wheels and catalytic converters." },
        partsTheftRemoveItemAfterUse = { label = "Consume theft tool", description = "Remove the theft tool item after a successful theft action." },
        partsTheftStolenWheelItem = { label = "Украденное колесо", description = "Inventory item awarded when wheels are stolen." },
        partsTheftCatalyticConverterItem = { label = "Катализатор", description = "Inventory item awarded when a catalytic converter is stolen." },
        partsTheftDealerAccount = { label = "Dealer payout account", description = "Account used for stolen parts dealer payouts, such as money or bank." },
        partsTheftDealerSellDistance = { label = "Dealer sell distance", description = "Maximum distance from the dealer to sell stolen parts." },
        partsTheftDispatchEnabled = { label = "Отправить вызов полиции", description = "Create a police dispatch when a wheel or catalytic converter is stolen." },
        partsTheftDispatchJobs = { label = "Dispatch jobs", description = "Job names that receive parts theft dispatches.", itemLabel = "Job name" },
        partsTheftDispatchTitle = { label = "Dispatch title", description = "Title shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchMessage = { label = "Dispatch message", description = "Message shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchCooldownSeconds = { label = "Dispatch cooldown", description = "Seconds before the same vehicle part can create another dispatch." },
        partsTheftDealerItems = { label = "Dealer items", description = "Stolen items the dealer will buy and their payout values.", itemLabel = "Dealer item" },
        vehicleCareWashItem = { label = "Wash item", description = "Inventory item used to wash a vehicle." },
        vehicleCareWashRemoveAfterUse = { label = "Consume wash item", description = "Remove the wash item after use." },
        vehicleCareWaxItem = { label = "Wax item", description = "Inventory item used to wax a vehicle." },
        vehicleCareWaxRemoveAfterUse = { label = "Consume wax item", description = "Remove the wax item after use." },
        vehicleCareWaxCleanKilometers = { label = "Wax clean kilometers", description = "Distance a waxed vehicle stays clean." },
        vehicleCareRepairItem = { label = "Repair item", description = "Inventory item used by the vehicle repair action." },
        vehicleCareRepairRemoveAfterUse = { label = "Consume repair item", description = "Remove the repair item after use." },
        vehicleCareRepairDurationMs = { label = "Repair duration", description = "Repair progress duration in milliseconds." },
        vehicleCareRepairMaxDistance = { label = "Repair max distance", description = "Maximum distance from the vehicle while repairing." },
        vehicleCareRepairVehicleDamage = { label = "Fix vehicle damage", description = "Repair normal GTA vehicle damage when using the repair action." },
        vehicleCareRepairFixRealisticWheelDamage = { label = "Fix realistic wheel damage", description = "Also reset realistic wheel damage when using the repair action." },
        vehicleCareRepairWearParts = { label = "Repair kit restored parts", description = "Choose which wear and service parts the repair item restores. Disable fluids here if oil, coolant, brake fluid, or transmission fluid should require the diagnostics repair flow.", itemLabel = "Wear part" },
        wearParts = { label = "Детали износа", description = "Vehicle wear parts, their lifetime distance, required repair item, item consumption, and install flow.", itemLabel = "Wear part", fields = { flow = { options = { wheel = "Wheel", performance = "Performance", underbody_neon = "Underbody / lift", oil_change = "Oil change", fluid_refill = "Fluid refill", catalytic_converter = "Catalytic converter", hood_install = "Hood install" } } } },
        wheelDamageDefaultMultiplier = { label = "Default multiplier", description = "Base wheel damage multiplier." },
        wheelDamageOffroadWheelsMultiplier = { label = "Off-road wheel multiplier", description = "Multiplier used when the vehicle has off-road wheels." },
        wheelDamageVehicleClassMultipliers = { label = "Vehicle class multipliers", description = "Damage multipliers per GTA vehicle class.", itemLabel = "Vehicle class" },
        mileageHudDigits = { label = "Digits", description = "Number of digits shown in the mileage HUD." },
        mileageHudPosition = { label = "Position", description = "Drag the mileage HUD preview to the desired screen position." },
        partsDeliveryTimeSeconds = { label = "Delivery time", description = "Seconds between ordering parts and the delivery becoming ready." },
        partsDeliveryTimerHudEnabled = { label = "Show delivery timer", description = "Show a small in-game timer HUD after a parts order is placed." },
        partsDeliveryTimerHudPosition = { label = "Timer position", description = "Drag the parts delivery timer HUD preview to the desired screen position." },
        partsDeliveryOwnCard = { label = "Own card payment", description = "Allow players to pay parts delivery orders with their own money." },
        partsDeliveryCompanyCard = { label = "Company card payment", description = "Allow parts delivery orders to use company funds." },
        partsDeliveryOpenDurationMs = { label = "Open duration", description = "Milliseconds required to unpack a ready parts delivery." },
        instantTuningInteractionDistance = { label = "Interaction distance", description = "Default distance for using instant tuning points." },
        instantTuningForceMarkerInteraction = { label = "Force marker interaction", description = "Use marker-style E interaction even when target support is enabled." },
        instantTuningMechanicOnly = { label = "Mechanic only", description = "Restrict all instant tuning locations to configured mechanic jobs." },
        instantTuningAllowedJobs = { label = "Allowed jobs", description = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", itemLabel = "Job name" },
        instantTuningPriceMultiplier = { label = "Price multiplier", description = "Multiplier applied to instant tuning prices." },
        instantTuningLabel = { label = "Default label", description = "Default text shown at instant tuning points." },
        instantTuningMarkerEnabled = { label = "Marker enabled", description = "Draw a world marker at instant tuning locations." },
        instantTuningMarkerType = { label = "Marker type", description = "GTA marker type used for instant tuning locations." },
        instantTuningBlipEnabled = { label = "Blip enabled", description = "Show map blips for instant tuning locations." },
        instantTuningBlipName = { label = "Blip name", description = "Map blip name." },
        instantTuningBlipSprite = { label = "Blip sprite", description = "GTA blip sprite id." },
        instantTuningBlipColor = { label = "Blip color", description = "GTA blip color id." },
        instantTuningLocations = { label = "Locations", description = "Instant tuning points. Use 0 distance to inherit the default interaction distance.", itemLabel = "Locations" },
        carryItems = { label = "Переносимые детали", description = "Delivered parts that should become physical carried props.", itemLabel = "Carry item", fields = { transport = { options = { hand = "Руки", forklift = "Погрузчик", engine_lift = "Подъемник двигателя" } } } }
      },
      settingValues = {
        tyres = "Tyres", brake_pads = "Brake Pads", suspension = "Suspension", spark_plugs = "Spark Plugs", engine_oil = "Engine Oil", coolant = "Coolant", brake_fluid = "Brake Fluid", transmission_fluid = "Transmission Fluid", clutch = "Clutch", air_filter = "Air Filter", traction_battery = "Traction Battery", inverter = "Power Inverter", catalytic_converter = "Catalytic Converter",
        vehicleClass_0 = "Compacts", vehicleClass_1 = "Sedans", vehicleClass_2 = "SUVs", vehicleClass_3 = "Coupes", vehicleClass_4 = "Muscle", vehicleClass_5 = "Sports Classics", vehicleClass_6 = "Sports", vehicleClass_7 = "Super", vehicleClass_8 = "Motorcycles", vehicleClass_9 = "Off-road", vehicleClass_10 = "Industrial", vehicleClass_11 = "Utility", vehicleClass_12 = "Vans", vehicleClass_13 = "Cycles", vehicleClass_14 = "Boats", vehicleClass_15 = "Helicopters", vehicleClass_16 = "Planes", vehicleClass_17 = "Service", vehicleClass_18 = "Emergency", vehicleClass_19 = "Military", vehicleClass_20 = "Commercial", vehicleClass_21 = "Trains", vehicleClass_22 = "Open Wheel"
      }
  },
    jobConfigurator = {
      actions = { backToScripts = "Скрипты" },
      selector = {
        title = "Конфигуратор работ",
        subtitle = "Выберите, какой рабочий скрипт вы хотите настроить.",
        description = "Выберите ресурс, который вы хотите настроить.",
        loading = "Загрузка конфигураторов...",
        comingSoon = "Скоро",
        emptyTitle = "Нет доступных скриптов для настройки.",
        emptySubtitle = "У вас нет прав ни для одного зарегистрированного конфигуратора работ.",
        unavailable = "Не зарегистрировано"
      }
    },
    radial = {
      empty = "Сейчас нет доступных действий.",
      errors = {
        generic = "Действие недоступно."
      },
      title = "Круговое меню",
      hint = "Выберите действие для выполнения.",
      pressKey = "Нажмите {key}",
      actions = {
        billing = {
          label = "Выставить счёт",
          description = "Выставить счёт ближайшему человеку.",
          badge = {
            distance = "{distance} м"
          },
          states = {
            disabled = "Выставление счетов недоступно.",
            notOnDuty = "Заступите на смену, чтобы выставлять счета.",
            notAuthorized = "У вас нет доступа к выставлению счетов.",
            noPatients = "Рядом нет людей для выставления счёта."
          }
        },
        panic = {
          label = "Тревожная кнопка",
          description = "Активировать тревожный сигнал для вашего текущего местоположения.",
          states = {
            disabled = "Тревожная кнопка недоступна.",
            notOnDuty = "Заступите на смену, чтобы использовать тревожную кнопку.",
            notAuthorized = "У вас нет доступа к использованию тревожной кнопки."
          }
        },
        tablet = {
          label = "Открыть планшет",
          description = "Открыть интерфейс планшета.",
          states = {
            notOnDuty = "Заступите на смену, чтобы использовать планшет.",
            notAuthorized = "У вас нет доступа к использованию планшета.",
            missingItem = "Для этого вам нужен планшет."
          }
        },
        removeProp = {
          label = "Удалить объект",
          description = "Удалить ближайший установленный объект.",
          states = {
            noNearby = "Рядом нет установленных объектов.",
            failed = "Не удалось удалить объект."
          }
        },
        carryPatient = {
          label = "Нести человека",
          description = "Перенести ближайшего человека в безопасное место.",
          dropLabel = "Отпустить человека",
          dropDescription = "Отпустить человека, которого вы несёте.",
          badge = {
            distance = "{distance} м"
          },
          states = {
            disabled = "Перенос людей недоступен.",
            beingCarried = "Вас уже несут.",
            inVehicle = "Сначала выйдите из транспорта.",
            selfIncapacitated = "Вы недостаточно устойчивы, чтобы нести кого-то.",
            noPatients = "Рядом нет людей для переноса.",
            tooFar = "Подойдите ближе, прежде чем нести человека."
          }
        },
        playerSearch = {
          label = "Обыскать человека",
          description = "Обыскать ближайшего человека.",
          badge = {
            distance = "{distance} м"
          },
          states = {
            disabled = "Обыск недоступен.",
            notOnDuty = "Заступите на смену, чтобы обыскивать людей.",
            notAuthorized = "У вас нет доступа к обыску людей.",
            noPlayers = "Рядом нет людей для обыска.",
            tooFar = "Подойдите ближе перед обыском.",
            inVehicle = "Сначала выйдите из транспорта."
          }
        },
        handcuff = {
          label = "Надеть наручники",
          description = "Надеть наручники на ближайшего человека.",
          badge = {
            distance = "{distance} м"
          },
          states = {
            disabled = "Использование наручников недоступно.",
            notOnDuty = "Заступите на смену, чтобы использовать наручники.",
            inVehicle = "Сначала выйдите из транспорта.",
            targetInVehicle = "Сначала вытащите человека из транспорта.",
            noPlayers = "Рядом нет людей для задержания.",
            tooFar = "Подойдите ближе перед использованием наручников.",
            missingItem = "Для этого вам нужны наручники.",
            alreadyCuffed = "На этом человеке уже надеты наручники."
          }
        },
        unhandcuff = {
          label = "Снять наручники",
          description = "Снять наручники с ближайшего человека.",
          badge = {
            distance = "{distance} м"
          },
          states = {
            disabled = "Снятие наручников недоступно.",
            notOnDuty = "Заступите на смену, чтобы снимать наручники.",
            inVehicle = "Сначала выйдите из транспорта.",
            targetInVehicle = "Сначала вытащите человека из транспорта.",
            noPlayers = "Рядом нет людей для снятия наручников.",
            tooFar = "Подойдите ближе перед снятием наручников.",
            notCuffed = "На этом человеке нет наручников."
          }
        },
        wheelClamp = {
          label = "Блокировка колеса",
          description = "Зафиксировать ближайший транспорт блокировкой колеса.",
          states = {
            disabled = "Блокировка колёс недоступна.",
            notOnDuty = "Заступите на смену, чтобы блокировать транспорт.",
            inVehicle = "Сначала выйдите из транспорта.",
            noVehicle = "Рядом нет транспорта.",
            tooFarVehicle = "Подойдите ближе к транспорту.",
            noWheel = "Подойдите ближе к колесу.",
            tooFar = "Подойдите ближе к колесу."
          }
        },
        wheelClampRemove = {
          label = "Снять блокировку",
          description = "Снять блокировку колеса с транспорта.",
          states = {
            disabled = "Блокировка колёс недоступна.",
            notOnDuty = "Заступите на смену, чтобы снимать блокировки.",
            inVehicle = "Сначала выйдите из транспорта.",
            noClamp = "Рядом нет блокировки колеса.",
            tooFar = "Подойдите ближе к блокировке колеса."
          }
        },
        jail = {
          label = "Отправить в тюрьму",
          description = "Задержать ближайшего игрока в настроенной тюремной зоне.",
          states = {
            notAuthorized = "У вас нет доступа к отправке игроков в тюрьму.",
            notOnDuty = "Заступите на смену, чтобы использовать это действие.",
            noPlayers = "Рядом нет людей в радиусе действия.",
            noJails = "Тюремные зоны не настроены.",
            spawnNotSet = "Сначала настройте точку появления в тюрьме.",
            invalidTarget = "Не удалось найти этого человека.",
            failed = "Не удалось выполнить это действие."
          }
        }
      }
    },
    shop = {
      shoppingCart = "Корзина покупок",
      purchase = "Купить",
      balance = "Доступные средства",
      catalog = "Каталог поставщика",
      empty = "На этой точке нет доступных товаров.",
      emptyCart = "Ваша корзина пуста.",
      insufficientFunds = "Недостаточно средств для этой покупки.",
      limitReached = "Достигнут лимит ({limit}).",
      errors = {
        invalidStation = "Неверная станция.",
        emptyBasket = "Корзина пуста.",
        unknown = "Неизвестная ошибка.",
        purchase = "Не удалось купить товары из корзины."
      }
    },
    garage = {
      states = {
        stored = "Готов",
        parked = "Используется"
      },
      title = "Гараж",
      empty = "Нет доступного служебного транспорта.",
      emptyAir = "На этой площадке нет доступных вертолётов.",
      ownedTitle = "Служебный транспорт",
      shopTitle = "Магазин транспорта",
      shopBalance = "Средства фракции",
      shopEmpty = "На этой точке нет доступного транспорта для покупки.",
      shopEmptyAir = "На этой площадке нет доступных вертолётов для покупки.",
      emptyFleet = "Служебный транспорт ещё не был приобретён.",
      noAccess = "Нет доступа",
      confirmSellTitle = "Подтверждение продажи",
      confirmSellConfirm = "Продать",
      confirmSellCancel = "Отмена",
      confirmSellMessage = "Продать {name} за {price}?",
      confirmPurchaseTitle = "Подтверждение покупки",
      confirmPurchaseConfirm = "Купить",
      confirmPurchaseCancel = "Отмена",
      confirmPurchaseMessage = "Купить {name} за {price}?",
      purchaseSuccessTitle = "Транспорт куплен",
      purchaseSuccessMessage = "{name} добавлен в автопарк.",
      defaultVehicleName = "Транспорт",
      stats = {
        topSpeed = "Макс. скорость",
        acceleration = "Разгон",
        braking = "Торможение",
        traction = "Сцепление"
      },
      actions = {
        parkOut = "Выгнать",
        buyVehicle = "Купить транспорт",
        openTrunk = "Открыть багажник",
        editStretcher = "Редактировать носилки",
        sellVehicle = "Продать транспорт",
        changePlate = "Изменить номер"
      },
      placeholders = {
        selectVehicle = "Выберите транспорт для просмотра деталей.",
        statsLoading = "Загрузка информации о транспорте..."
      },
      errors = {
        loadVehicles = "Не удалось загрузить транспорт гаража.",
        loadStats = "Не удалось загрузить характеристики транспорта.",
        parkOut = "Не удалось выгнать транспорт.",
        unavailable = "Гараж недоступен.",
        vehicleUnavailable = "Транспорт недоступен.",
        purchase = "Не удалось купить транспорт.",
        openTrunk = "Не удалось открыть багажник.",
        noAccess = "Нет доступа к этому транспорту.",
        stretcherEditor = "Не удалось открыть редактор носилок.",
        stretcherPermission = "Только высший ранг может редактировать крепления носилок.",
        sellVehicle = "Не удалось продать транспорт.",
        editorUnavailable = "Редактор недоступен.",
        changePlate = "Не удалось изменить номер."
      },
      changePlateTitle = "Изменение номерного знака",
      changePlateButton = "Применить",
      plateEditor = {
        button = "Изменить номер",
        title = "Изменение номера",
        hint = "Изменить номерной знак этого транспорта.",
        save = "Сохранить номер",
        errors = {
          empty = "Введите номер.",
          invalid = "Номер недействителен.",
          update = "Не удалось обновить номер."
        }
      },
      status = {
        parkedBy = "Последний раз взят: {name}",
        unknownDriver = "Неизвестно"
      }
    },
    duty = {
      fields = {
        grade = "Ранг",
        location = "Станция",
        name = "Имя",
        badge = "Жетон"
      },
      instructions = {
        drag = "Перетащите вашу карту сотрудника на сенсор, чтобы управлять сменой.",
        dragCard = "Перетащите карту сотрудника на сенсор, чтобы начать смену."
      },
      screen = {
        welcome = "Добро пожаловать, {name}",
        goodbye = "Смена завершена. Берегите себя, {name}.",
        ready = "Доступ к смене разрешён.",
        completed = "Смена успешно завершена.",
        idleTitle = "Ожидание сканирования",
        totalHours = "Всего часов",
        shiftDuration = "Длительность смены",
        currentTime = "Текущее время: {time}",
        defaultStation = "Основной терминал",
        devPrompt = "Загрузите тестовые данные для предпросмотра терминала смены в браузере.",
        loadMock = "Загрузить тестовые данные",
        loading = "Загрузка..."
      },
      toasts = {
        failed = "Не удалось обновить статус смены."
      },
      errors = {
        unavailable = "Терминал смены недоступен."
      },
      title = "Терминал смены"
    },
    storage = {
      inventory = "Инвентарь",
      storage = "Хранилище",
      locker = "Шкафчик",
      trunk = "Багажник транспорта",
      trunkProps = "Предметы транспорта",
      openPropMenu = "Объекты",
      search = "Обыск",
      items = "Предметы",
      weapons = "Оружие",
      transferTitle = "Передача",
      transferButton = "Передать",
      capacityUnlimited = "Безлимитная вместимость",
      errors = {
        trunkFull = "Багажник заполнен.",
        searchReadOnly = "Вы можете только забирать предметы у человека.",
        invalidTransfer = "Передача не удалась.",
        invalidAmount = "Неверное количество.",
        notEnoughItems = "Недостаточно предметов.",
        inventoryFull = "Недостаточно места в инвентаре.",
        storageFull = "Хранилище заполнено.",
        lockerFull = "Шкафчик заполнен.",
        restrictedItem = "У вас нет доступа к этому предмету.",
        invalidProp = "Не удалось выбрать объект."
      },
      officerInventory = "Инвентарь сотрудника",
      loadout = "Снаряжение",
      armory = "Оружейная",
      armoryTitle = "Оружейная снаряжения",
      storageTitle = "Защищённое хранилище",
      storageSubtitle = "Только для авторизованного персонала",
      emptyItems = "Нет доступных предметов.",
      emptyWeapons = "Нет доступного оружия.",
      emptyProps = "Нет доступных объектов.",
      searchItems = "Предметы",
      searchWeapons = "Оружие",
      lockerUnlocking = "Открытие шкафчика...",
      restrictedPill = "Ограничено",
      restrictedTooltip = "У вас нет доступа к этому предмету.",
      capacityLabel = "{used}/{capacity}",
      propPlacement = {
        title = "Размещение объекта",
        place = "Разместить ({key})",
        cancel = "Отмена ({key})"
      }
    },
    creator = {
      title = "Редактор",
      description = "Настройка записей.",
      selectJob = "Выберите категорию работы.",
      empty = "Пока не настроено ни одного {entryLabelPlural}.",
      keyboardHint = "Используйте стрелки для навигации по списку и действиям.",
      placementHelp = "Стрелки — перемещение, PageUp/PageDown — высота, Q/E — вращение, Enter — разместить, Backspace — отмена.",
      editTitle = "Маркеры",
      editSubtitle = "Используйте кнопку метки на карте, чтобы сохранить ваши текущие координаты.",
      editKeyboardHint = "Используйте стрелки для выбора маркера, влево/вправо для выбора Установить/Очистить, Enter — выполнить, Backspace — назад.",
      missingEntry = "Запись не найдена.",
      actions = {
        add = "Добавить {label}",
        newEntry = "Новая запись {entryLabel}"
      },
      status = {
        set = "Установлено",
        unset = "Не установлено"
      },
      modals = {
        createTitle = "Создать {entryLabel}",
        createButton = "Создать {entryLabel}",
        renameTitle = "Переименовать {entryLabel}",
        renameButton = "Сохранить название",
        deleteTitle = "Удалить {entryLabel}",
        deleteMessage = "Вы действительно хотите удалить {name}?",
        deleteConfirmLabel = "Удалить",
        deleteCancelLabel = "Отмена"
      }
    },
    management = {
      noAccess = "У вас нет доступа к инструментам управления.",
      refunds = {
        description = "Просматривайте смерти за сегодня и вчера и возвращайте удалённые предметы.",
        refreshButton = "Обновить",
        updatedAt = "Обновлено {time}",
        errors = {
          loadFailed = "Не удалось загрузить возвраты."
        }
      },
      dashboard = {
        sidebarTitle = "Панель",
        menuTitle = "Обзор",
        onlineMembers = "Сотрудников онлайн",
        funds = "Средства",
        onDuty = "На смене",
        offDuty = "Не на смене",
        mostActive = "Самый активный"
      },
      finance = {
        sidebarTitle = "Денежный поток",
        menuTitle = "Финансовый обзор",
        expenseCategories = "Категории расходов",
        revenueCategories = "Категории доходов",
        kpis = {
          revenue = "Доход",
          expenses = "Расходы",
          profit = "Прибыль"
        },
        cashFlow = "Тренд денежного потока",
        lastUpdated = "Обновлено {time}",
        emptyStates = {
          timeline = "За этот период транзакций не найдено.",
          categories = "Данные по категориям пока отсутствуют."
        },
        categories = {
          deposits = "Пополнения",
          withdrawals = "Снятия",
          supplies = "Поставки",
          vehicles = "Транспорт",
          salaries = "Зарплаты",
          bonuses = "Бонусы"
        },
        errors = {
          load = "Не удалось загрузить финансовую сводку."
        }
      },
      transactions = {
        sidebarTitle = "Средства",
        menuTitle = "Управление средствами",
        currentBalance = "Текущий баланс",
        withdrawButton = "Снять",
        depositButton = "Пополнить",
        recentTransactions = "Последние транзакции",
        columnNames = {
          timestamp = "Время",
          name = "Имя",
          action = "Действие",
          content = "Сумма"
        },
        actions = {
          deposited = "Средства внесены",
          withdrawn = "Средства сняты",
          supplies_purchased = "Закуплены поставки",
          vehicle_purchased = "Транспорт куплен",
          vehicle_sold = "Транспорт продан",
          salary_paid = "Зарплата выплачена",
          bonus_paid = "Бонус выплачен"
        },
        errors = {
          load = "Не удалось загрузить транзакции.",
          failed = "Транзакция не выполнена."
        }
      },
      billingSpecs = {
        sidebarTitle = "Шаблоны счетов",
        menuTitle = "Причины выставления счетов",
        description = "Настройте причины, которые сотрудники могут выбирать при выставлении счетов, и задайте их стандартные цены.",
        reasonColumn = "Причина",
        priceColumn = "Цена",
        actionsColumn = "Действия",
        reasonLabel = "Причина счёта",
        reasonPlaceholder = "например: Реакция на патруль",
        amountLabel = "Стандартная цена",
        emptyState = "Причины выставления счетов ещё не добавлены.",
        addButton = "Добавить",
        addFirstButton = "Создать первую причину",
        deleteButton = "Удалить",
        saveButton = "Сохранить",
        reasonRequired = "Введите причину, чтобы сохранить эту строку.",
        saveSuccess = "Шаблоны счетов обновлены.",
        saveError = "Не удалось сохранить шаблоны счетов.",
        loadError = "Не удалось загрузить шаблоны счетов.",
        updatedAt = "Обновлено в {time}"
      },
      members = {
        sidebarTitle = "Сотрудники",
        menuTitle = "Состав",
        inviteTitle = "Пригласить во фракцию",
        inviteSubtitle = "Выберите игрока и назначьте ему начальный ранг.",
        selectPlayer = "Выберите игрока",
        selectRank = "Выберите ранг",
        sendInvite = "Пригласить",
        columnNames = {
          name = "Имя",
          rank = "Ранг",
          last_online = "Последний онлайн",
          total_work_time = "Рабочее время (ч)",
          actions_done = "Выполнено действий",
          actions = "Действия"
        },
        bonus = {
          title = "Выдать бонус",
          confirmButton = "Выплатить бонус",
          actionLabel = "Бонус",
          invalidAmount = "Введите корректную сумму бонуса.",
          failed = "Не удалось выплатить бонус.",
          unexpectedError = "Непредвиденная ошибка при выплате бонуса."
        },
        errors = {
          load = "Не удалось получить список сотрудников.",
          loadUnexpected = "Непредвиденная ошибка при получении сотрудников.",
          invite = "Не удалось отправить приглашение.",
          inviteUnexpected = "Непредвиденная ошибка при отправке приглашения."
        }
      },
      roles = {
        sidebarTitle = "Роли",
        menuTitle = "Роли",
        createRoleButton = "Создать роль",
        columnNames = {
          grade = "Уровень",
          label = "Название роли",
          salary = "Зарплата",
          salaryInterval = "Интервал (мин)",
          actions = "Действия"
        },
        editMenu = {
          title = "Редактирование роли",
          createTitle = "Создать роль",
          createSaveButton = "Создать",
          newRoleBreadcrumb = "Новая роль",
          unnamedRole = "Безымянная роль",
          gradeMeta = "Ранг {grade}",
          backButton = "Назад",
          saveButton = "Сохранить",
          general = "Основное",
          permissions = "Разрешения",
          salary = "Зарплата",
          salaryDescription = "Установите зарплату для этой роли.",
          salaryInterval = "Интервал выплаты",
          salaryIntervalDescription = "Выберите, как часто эта роль получает зарплату (в минутах работы).",
          roleName = "Название роли",
          roleNameDescription = "Установите название роли.",
          highestRoleInfo = "Это высший ранг и он автоматически имеет доступ ко всем разрешениям."
        },
        unsavedChanges = {
          title = "Несохранённые изменения",
          message = "У вас есть несохранённые изменения для этой роли. Выйти и отменить их?",
          confirm = "Выйти без сохранения",
          cancel = "Продолжить редактирование"
        },
        permissionsEmpty = "Разрешения не найдены.",
        permissionEntries = {
          viewLogs = {
            label = "Просмотр логов",
            description = "Позволяет просматривать логи транзакций и активности."
          },
          manageRoles = {
            label = "Управление ролями",
            description = "Позволяет создавать, редактировать, перемещать и удалять ранги."
          },
          manageMembers = {
            label = "Управление сотрудниками",
            description = "Позволяет повышать, понижать, увольнять и выдавать бонусы."
          },
          manageWarehouse = {
            label = "Доступ к хранилищу",
            description = "Позволяет взаимодействовать с общим хранилищем."
          },
          manageMoney = {
            label = "Управление средствами",
            description = "Позволяет вносить или снимать деньги организации."
          },
          editOutfits = {
            label = "Редактирование одежды",
            description = "Позволяет обновлять сохранённые комплекты одежды."
          },
          createOutfits = {
            label = "Создание одежды",
            description = "Позволяет создавать новые комплекты одежды."
          },
          deleteOutfits = {
            label = "Удаление одежды",
            description = "Позволяет удалять сохранённые комплекты одежды."
          },
          purchaseSupplies = {
            label = "Заказ поставок",
            description = "Позволяет заказывать оборудование у оптового поставщика за средства фракции."
          },
          purchaseVehicles = {
            label = "Покупка транспорта",
            description = "Позволяет покупать новый служебный транспорт за средства фракции."
          },
          garageVehicles = {
            label = "Ограничения гаража",
            description = "Выберите транспорт, к которому эта роль не имеет доступа в гараже."
          },
          tabletApps = {
            label = "Ограничения приложений планшета",
            description = "Выберите приложения планшета, к которым эта роль не имеет доступа."
          },
          all = {
            label = "Полный доступ",
            description = "Даёт все разрешения независимо от других настроек."
          }
        },
        permissionOptions = {
          storageHint = "Добавьте предметы, которые нельзя забирать с этой ролью.",
          storageItemsTitle = "Ограниченные предметы",
          storageWeaponsTitle = "Ограниченное оружие",
          allowedWeaponsTitle = "Разрешённое оружие",
          weaponHint = "Добавьте оружие, к которому эта роль имеет доступ.",
          vehicleHint = "Выберите транспорт, к которому эта роль не имеет доступа.",
          appHint = "Выберите приложения планшета, к которым эта роль не имеет доступа.",
          itemPlaceholder = "Введите предмет",
          weaponPlaceholder = "Введите оружие",
          weaponSelectPlaceholder = "Выберите оружие",
          vehiclePlaceholder = "Выберите транспорт",
          appPlaceholder = "Выберите приложение планшета",
          addButton = "Добавить",
          emptyVehicles = "Нет доступного транспорта.",
          emptyApps = "Нет доступных приложений планшета.",
          errors = {
            empty = "Пожалуйста, введите значение.",
            duplicate = "Опция уже добавлена.",
            itemMissing = "Предмет не существует.",
            vehicleMissing = "Выберите транспорт.",
            appMissing = "Выберите приложение планшета.",
            weaponMissing = "Оружие не существует.",
            weaponSelectMissing = "Выберите оружие."
          }
        },
        errors = {
          save = "Не удалось сохранить роль.",
          saveUnexpected = "Непредвиденная ошибка при сохранении роли.",
          permissionsLoad = "Не удалось получить разрешения.",
          permissionsUnexpected = "Непредвиденная ошибка при получении разрешений."
        }
      },
      logs = {
        sidebarTitle = "Логи",
        menuTitle = "Логи",
        errors = {
          load = "Не удалось загрузить логи."
        },
        columnNames = {
          timestamp = "Время",
          name = "Имя",
          action = "Действие",
          content = "Содержимое"
        },
        actions = {
          stored = "Предмет сохранён",
          removed = "Предмет изъят",
          deposited = "Средства внесены",
          withdrawn = "Средства сняты",
          outfit_created = "Комплект одежды создан",
          outfit_updated = "Комплект одежды обновлён",
          outfit_deleted = "Комплект одежды удалён",
          permissions_updated = "Разрешения обновлены",
          invite_sent = "Приглашение отправлено",
          invite_accepted = "Приглашение принято",
          invite_declined = "Приглашение отклонено",
          bonus_paid = "Бонус выплачен",
          member_promoted = "Сотрудник повышен",
          member_demoted = "Сотрудник понижен",
          member_fired = "Сотрудник уволен",
          supplies_purchased = "Поставки закуплены",
          vehicle_purchased = "Транспорт куплен",
          vehicle_sold = "Транспорт продан",
          salary_paid = "Зарплата выплачена"
        }
      },
      dialogs = {
        deleteOutfit = {
          title = "Удаление комплекта одежды",
          message = "Вы действительно хотите удалить \"{name}\"?",
          confirm = "Удалить комплект",
          cancel = "Отмена"
        }
      }
    },
    cloakroom = {
      title = "Раздевалка",
      civilianClothes = "Гражданская одежда",
      newOutfit = "Новый комплект",
      edit = {
        save = "Сохранить",
        rotateAlt = "Повернуть",
        outfitNameTitle = "Название комплекта",
        saveOutfit = "Сохранить комплект"
      }
    },
    tablet = {
      apps = {
        management = "Меню начальника",
        patients = "Пациенты",
        citizens = "Граждане",
        offences = "Нарушения",
        cases = "Дела",
        social_work = "Общественные работы",
        vehicles = "Транспорт",
        weapons = "Оружие",
        prison = "Тюрьма",
        warrants = "Ордера",
        bolos = "Ориентировки",
        conditions = "Состояния",
        reports = "Отчёты",
        camera = "Камера",
        gallery = "Галерея",
        map = "Карта",
        chat = "Чат",
        calendar = "Календарь",
        calculator = "Калькулятор",
        settings = "Настройки"
      }
    },
    common = {
      close = "Закрыть",
      unknownError = "Неизвестная ошибка.",
      unexpectedError = "Произошла непредвиденная ошибка.",
      time = {
        now = "Сейчас"
      },
      pagination = {
        prev = "Назад",
        next = "Вперёд",
        page = "Страница {current} из {total}"
      },
      gallery = {
        title = "Галерея",
        subtitle = "Выберите фото или видео.",
        loading = "Загрузка галереи...",
        empty = "Элементы галереи отсутствуют.",
        photoAlt = "Медиа из галереи"
      },
      back = "Назад",
      confirm = {
        unsavedTitle = "Несохранённые изменения",
        unsavedMessage = "Отменить изменения или сохранить их перед выходом?",
        unsavedDiscard = "Отменить изменения",
        unsavedSave = "Сохранить изменения"
      }
    },
    reports = {
      unknown = "Неизвестно"
    },
    publicForms = {
      complaint = {
        fields = {
          fullName = "Полное имя",
          phone = "Номер телефона",
          incidentDate = "Дата инцидента",
          incidentTime = "Время инцидента",
          location = "Место инцидента",
          officerName = "Имя сотрудника",
          badgeNumber = "Номер жетона",
          description = "Детали жалобы",
          witnesses = "Свидетели",
          desiredOutcome = "Желаемое решение",
          email = "Электронная почта",
          address = "Домашний адрес",
          signature = "Подпись"
        },
        title = "Жалоба гражданина",
        subtitle = "Сообщите о поведении сотрудников или проблемах отдела.",
        placeholders = {
          fullName = "Введите ваше полное официальное имя",
          phone = "###-###-####",
          email = "name@email.com",
          address = "Улица, город, область",
          incidentDate = "MM/DD/YYYY",
          incidentTime = "HH:MM",
          location = "Где это произошло?",
          officerName = "Имя сотрудника или подразделение",
          badgeNumber = "Номер жетона, если известен",
          description = "Подробно опишите произошедшее...",
          witnesses = "Укажите свидетелей или других участников",
          desiredOutcome = "Какого результата вы ожидаете?",
          signature = "Введите ваше полное имя"
        }
      },
      application = {
        fields = {
          fullName = "Полное имя",
          dateOfBirth = "Дата рождения",
          phone = "Номер телефона",
          experience = "Соответствующий опыт",
          availability = "Доступность",
          whyJoin = "Почему вы хотите вступить?",
          email = "Электронная почта",
          address = "Домашний адрес",
          education = "Образование",
          certifications = "Сертификаты",
          references = "Рекомендации",
          signature = "Подпись"
        },
        title = "Заявление на работу",
        subtitle = "Подайте заявку на вступление в отдел.",
        placeholders = {
          fullName = "Введите ваше полное официальное имя",
          dateOfBirth = "MM/DD/YYYY",
          phone = "###-###-####",
          email = "name@email.com",
          address = "Улица, город, область",
          education = "Школа, академия или колледж",
          experience = "Правоохранительная деятельность, охрана или сфера услуг",
          certifications = "Первая помощь, оружейная подготовка или другое обучение",
          availability = "Предпочитаемые смены или дата начала",
          whyJoin = "Расскажите, почему вы хотите здесь работать...",
          references = "Имена и контактная информация",
          signature = "Введите ваше полное имя"
        }
      },
      title = "Публичные формы",
      subtitle = "Подайте жалобу или заявление на работу.",
      stationLabel = "Станция",
      dateLabel = "Дата",
      timeLabel = "Время",
      stamp = {
        label = "PD",
        complaint = "CMP",
        application = "APP"
      },
      tabs = {
        complaint = "Форма жалобы",
        application = "Заявление на работу",
        myForms = "Мои заявки"
      },
      myForms = {
        title = "Мои заявки",
        empty = "Вы ещё не отправляли формы.",
        back = "Назад",
        notesTitle = "Ответы",
        notesEmpty = "Ответов пока нет.",
        statusNew = "Ожидает",
        statusReviewed = "Рассмотрено",
        statusArchived = "Архивировано"
      },
      actions = {
        submit = "Отправить форму",
        clear = "Очистить поля",
        close = "Закрыть"
      },
      status = {
        submitting = "Отправка...",
        success = "Форма успешно отправлена.",
        error = "Не удалось отправить форму."
      },
      errors = {
        required = "Пожалуйста, заполните обязательные поля."
      }
    },
    tabletForms = {
      title = "Входящие формы",
      eyebrow = "Публичные формы",
      listed = "отображено",
      filters = {
        label = "Тип",
        all = "Все формы",
        complaint = "Жалобы",
        application = "Заявления"
      },
      search = {
        placeholder = "Поиск по имени, станции или ID"
      },
      status = {
        new = "Новая",
        reviewed = "Рассмотрена",
        archived = "Архивирована"
      },
      state = {
        empty = "Нет форм, соответствующих текущим фильтрам.",
        loading = "Загрузка форм...",
        saving = "Сохранение..."
      },
      errors = {
        load = "Не удалось загрузить формы.",
        update = "Не удалось обновить статус формы."
      },
      detail = {
        complaintTitle = "Детали жалобы",
        applicationTitle = "Детали заявления"
      },
      actions = {
        refresh = "Обновить",
        markReviewed = "Отметить как рассмотренное",
        archive = "Архивировать",
        back = "Назад к списку"
      },
      notifications = {
        timeNow = "Сейчас",
        complaintType = "Жалоба",
        applicationType = "Заявление",
        app = "Формы",
        title = "Новая публичная форма",
        body = "{type} от {name} ({station})"
      },
      fields = {
        type = "Тип формы",
        id = "ID формы",
        station = "Станция",
        submitted = "Отправлено",
        status = "Статус",
        contact = "Контакт"
      },
      notes = {
        title = "Заметки",
        loading = "Загрузка заметок...",
        empty = "Заметок пока нет.",
        placeholder = "Напишите заметку...",
        visibleBadge = "Видно гражданину",
        visibleToCitizen = "Видно гражданину",
        submit = "Добавить заметку"
      }
    },
    gallery = {
      eyebrow = "Галерея улик",
      title = "Фотоплёнка",
      filters = {
        all = "Все",
        camera = "Камера",
        speedcam = "Камеры скорости",
        cctv = "CCTV",
        mugshot = "Фото ареста"
      },
      labels = {
        count = "{count} фото",
        sort = "Сначала новые",
        photoAlt = "Фото из галереи",
        photoFullAlt = "Фото в полном размере",
        takenBy = "Снято",
        captured = "Захвачено",
        unknownTime = "Неизвестное время",
        unknownTakenBy = "Неизвестно"
      },
      state = {
        loading = "Загрузка снимков...",
        emptyTitle = "Фотографий пока нет.",
        emptySubtitle = "Ваши последние снимки с камеры появятся здесь."
      },
      errors = {
        load = "Не удалось загрузить галерею.",
        delete = "Не удалось удалить фото."
      },
      confirm = {
        deleteTitle = "Удаление фото",
        deleteMessage = "Удалить это фото? Это действие нельзя отменить.",
        deleteConfirm = "Удалить",
        deleteCancel = "Отмена"
      },
      mock = {
        caption = "ТЕСТОВЫЙ СНИМОК"
      }
    },
    camera = {
      help = {
        focused = "Нажмите Space, чтобы включить управление.",
        blurred = "Нажмите Space, чтобы снова использовать планшет."
      },
      mode = {
        photo = "Фото",
        video = "Видео",
        switchPhoto = "Переключить в режим фото",
        switchVideo = "Переключить в режим видео"
      },
      capture = {
        photo = "Сделать фото"
      },
      queue = {
        title = "Очередь",
        empty = "Загрузок пока нет.",
        kind = {
          photo = "Загрузка фото",
          video = "Загрузка видео"
        },
        status = {
          loading = "Загрузка...",
          success = "Сохранено",
          error = "Ошибка"
        }
      },
      preview = {
        lastShot = "Последний снимок",
        lastCapture = "Последний захват"
      },
      record = {
        start = "Начать запись",
        stop = "Остановить запись",
        live = "REC",
        saving = "Сохранение видео...",
        name = "Клип камеры",
        description = "Запись планшета",
        errors = {
          config = "Конфигурация загрузки отсутствует.",
          upload = "Ошибка загрузки.",
          save = "Не удалось сохранить видео.",
          unsupported = "Запись не поддерживается.",
          empty = "Видео ещё не записано.",
          busy = "Запись уже выполняется.",
          notRecording = "Запись уже остановлена."
        }
      },
      errors = {
        timeout = "Время загрузки истекло.",
        capture = "Непредвиденная ошибка при создании фото.",
        upload = "Ошибка загрузки."
      }
    },
    cctv = {
      eyebrow = "Сеть наблюдения",
      title = "CCTV",
      listed = "отображено",
      actions = {
        refresh = "Обновить"
      },
      search = {
        placeholder = "Поиск камер по имени, ID или местоположению"
      },
      filters = {
        all = "Все камеры",
        bodycam = "Бодикамы",
        dashcam = "Видеорегистраторы",
        cctv = "Камеры CCTV",
        speedcam = "Камеры скорости"
      },
      types = {
        bodycam = "Бодикам",
        dashcam = "Видеорегистратор",
        speedcam = "Камера скорости",
        cctv = "Камера CCTV"
      },
      status = {
        online = "Онлайн",
        maintenance = "Обслуживание",
        offline = "Оффлайн"
      },
      live = {
        active = "Прямая трансляция активна",
        maintenance = "Трансляция приостановлена на обслуживание",
        offline = "Сигнал потерян",
        placeholderTitle = "Трансляция недоступна",
        placeholderSubtitle = "Выберите сотрудника с активным бодикамом.",
        speedcamPlaceholderTitle = "Камера скорости оффлайн",
        speedcamPlaceholderSubtitle = "Отремонтируйте или замените устройство, чтобы восстановить трансляцию."
      },
      labels = {
        speedcamLocation = "Обочина",
        onDuty = "На смене",
        durability = "Прочность"
      },
      state = {
        loading = "Загрузка камер...",
        empty = "Нет камер, соответствующих текущим фильтрам.",
        select = "Выберите камеру для просмотра трансляции."
      },
      controls = {
        tiltUp = "Наклон вверх",
        panLeft = "Поворот влево",
        panRight = "Поворот вправо",
        tiltDown = "Наклон вниз"
      },
      capture = {
        name = "CCTV - {label}",
        description = "{location} ({id})",
        saved = "Сохранено в галерею.",
        error = "Не удалось сделать снимок.",
        action = "Сделать снимок",
        loading = "Создание снимка..."
      },
      record = {
        name = "Клип CCTV - {label}",
        description = "{location} ({id})",
        save = "Сохранить последние {minutes} мин",
        saving = "Сохранение...",
        requested = "Запрос на сохранение отправлен.",
        saved = "Видео сохранено в галерею.",
        errors = {
          config = "Конфигурация загрузки отсутствует.",
          upload = "Ошибка загрузки.",
          save = "Не удалось сохранить видео.",
          unsupported = "Запись не поддерживается.",
          empty = "Буфер пока недоступен.",
          request = "Не удалось запросить видео бодикама.",
          timeout = "Время сохранения бодикама истекло.",
          busy = "Запись уже выполняется.",
          notRecording = "Запись уже остановлена."
        }
      },
      waypoint = {
        set = "Метка установлена.",
        missing = "Местоположение недоступно."
      },
      errors = {
        load = "Не удалось загрузить камеры."
      }
    },
    chat = {
      targets = {
        allUnits = "Общий чат",
        centralDispatch = "Центральная диспетчерская"
      },
      header = {
        eyebrowRoom = "Канал сотрудников",
        eyebrowPrivate = "Приватная линия",
        metaRoom = "Комната",
        metaDirect = "Личное",
        metaStaff = "Сотрудник"
      },
      sidebar = {
        eyebrow = "Связь",
        title = "Сеть сотрудников",
        groupTitle = "Групповой чат",
        allUnits = "Все сотрудники",
        staffTitle = "Сотрудники",
        loading = "Загрузка сотрудников...",
        empty = "Нет доступных сотрудников."
      },
      staff = {
        unknownMember = "Неизвестный сотрудник",
        onDuty = "На смене",
        offDuty = "Не на смене",
        grade = "Ранг {level}",
        fallback = "Сотрудник"
      },
      composer = {
        placeholderRoom = "Напишите обновление для подразделения...",
        placeholderDirect = "Сообщение для {name}...",
        pendingAlt = "Ожидающая отправка"
      },
      messages = {
        avatarAlt = "Аватар {name}",
        avatarFallback = "Аватар сотрудника",
        unknownAuthor = "Неизвестно",
        sharedEvidenceAlt = "Общая улика",
        tapToExpand = "Нажмите для увеличения"
      },
      preview = {
        ready = "Медиа готово к отправке"
      },
      profile = {
        action = "Установить фото профиля",
        galleryTitle = "Установить фото профиля",
        gallerySubtitle = "Выберите фото для аватара команды.",
        photoAlt = "Фото профиля",
        selfPhotoAlt = "Фото профиля",
        error = "Не удалось обновить фото профиля."
      },
      actions = {
        remove = "Удалить",
        send = "Отправить"
      },
      state = {
        syncing = "Синхронизация сообщений...",
        emptyRoom = "Сообщений пока нет.",
        emptyPrivate = "Личных сообщений пока нет.",
        emptyRoomHint = "Будьте первым, кто свяжется с подразделением.",
        emptyPrivateHint = "Начните личный диалог с этим сотрудником."
      },
      errors = {
        load = "Не удалось загрузить историю чата.",
        send = "Не удалось отправить сообщение.",
        members = "Не удалось загрузить сотрудников."
      }
    },
    bossMenu = {
      header = {
        eyebrow = "Меню начальника",
        title = "Управление",
        balanceLabel = "Баланс"
      },
      state = {
        loading = "Загрузка данных управления..."
      }
    },
    tabletSettings = {
      header = {
        eyebrow = "Настройки планшета",
        title = "Персонализация",
        modeLabel = "Режим",
        modeLight = "Светлый",
        modeDark = "Тёмный"
      },
      appearance = {
        title = "Внешний вид",
        description = "Переключите интерфейс между светлой и тёмной темой.",
        light = "Светлый",
        dark = "Тёмный"
      },
      wallpaper = {
        title = "Обои",
        description = "Используйте стандартный фон, выберите фото из галереи или добавьте свою ссылку.",
        labels = {
          default = "Стандартный фон",
          gallery = "Фото из галереи",
          url = "Своя ссылка"
        },
        useDefault = "Использовать стандартный",
        chooseGallery = "Выбрать из галереи",
        customUrlLabel = "Ссылка на изображение",
        customUrlPlaceholder = "https://example.com/wallpaper.jpg",
        apply = "Применить",
        hint = "Лучший результат с изображениями 1920x1080 или выше."
      }
    },
    calendar = {
      weekdays = {
        mon = "Пн",
        tue = "Вт",
        wed = "Ср",
        thu = "Чт",
        fri = "Пт",
        sat = "Сб",
        sun = "Вс"
      },
      selectedDateFallback = "Выберите дату",
      header = {
        eyebrow = "Общий календарь",
        title = "Расписание сотрудников",
        metaPrimary = "Видно всем сотрудникам",
        metaSecondary = "Все могут добавлять записи",
        hint = "Нажмите на день, чтобы добавить смену или событие"
      },
      actions = {
        dayEntries = "Записи дня",
        addEntry = "Добавить запись"
      },
      today = "Сегодня",
      more = "+ ещё {count}",
      modal = {
        addEntry = {
          eyebrow = "Добавить запись",
          titleLabel = "Название",
          titlePlaceholder = "Брифинг, тренировка, патруль",
          datetimeLabel = "Дата и время",
          colorLabel = "Цвет",
          clear = "Очистить",
          submit = "Добавить в календарь"
        },
        dayEntries = {
          eyebrow = "Записи дня",
          empty = "Записей пока нет. Добавьте брифинг или патруль для подразделения."
        }
      }
    },
    calculator = {
      header = {
        eyebrow = "Полевые инструменты",
        title = "Калькулятор",
        modeLabel = "Режим"
      },
      keys = {
        clearAll = "AC",
        clearEntry = "CE"
      },
      mode = {
        standard = "Стандартный"
      },
      status = {
        resetRequired = "Требуется сброс",
        ready = "Готов"
      },
      errors = {
        error = "Ошибка"
      }
    },
    tabletHome = {
      status = {
        defaultDate = "Понедельник, 01 Янв"
      },
      calendar = {
        eventToday = "Событие сегодня",
        eventTomorrow = "Событие завтра",
        allDay = "Весь день",
        timeAt = " в {time}"
      },
      chat = {
        messageFrom = "Сообщение от {name}",
        newMessage = "Новое сообщение",
        authorFallback = "Сотрудник",
        messageBody = "{author}: {message}",
        sentPhoto = "{author} отправил фото.",
        sentMessage = "{author} отправил сообщение."
      },
      notifications = {
        title = "Уведомления",
        clearAll = "Очистить всё",
        empty = "Новых уведомлений нет."
      }
    },
    map = {
      eyebrow = "Картографический центр",
      title = "Сетка Сан-Андреас",
      markerLabel = "Метка",
      signalLost = "Сигнал потерян",
      markerTypes = {
        label = "Список меток",
        dispatch = "Диспетчер",
        officers = "Сотрудники",
        speedcams = "Камеры скорости",
        vehicles = "Транспорт",
        trackers = "Трекеры"
      },
      markerList = {
        listed = "отображено",
        officersTitle = "Список сотрудников",
        speedcamsTitle = "Панель камер скорости",
        vehiclesTitle = "Панель транспорта",
        trackersTitle = "Панель трекеров",
        officersEmpty = "Нет сотрудников на смене.",
        speedcamsEmpty = "Нет доступных камер скорости.",
        trackersEmpty = "Нет активных трекеров.",
        vehiclesEmpty = "Нет активного транспорта."
      },
      dispatch = {
        title = "Панель диспетчера",
        empty = "Сейчас нет вызовов.",
        status = {
          active = "Активно",
          accepted = "Принято",
          done = "Завершено"
        },
        panelTitle = "Детали вызова",
        statusLabel = "Статус",
        acceptedBy = "Принял",
        doneBy = "Завершил",
        coords = "Координаты",
        actions = {
          accept = "Принять",
          done = "Отметить выполненным",
          delete = "Удалить"
        },
        unknown = "Неизвестно"
      },
      status = {
        available = "Свободен",
        busy = "Занят",
        pursuit = "В погоне",
        offDuty = "Не на смене"
      },
      vehicle = {
        status = {
          active = "Активен",
          offline = "Оффлайн"
        }
      },
      tracker = {
        status = {
          active = "Активен",
          offline = "Оффлайн"
        }
      },
      speedcam = {
        status = {
          online = "Онлайн",
          maintenance = "Обслуживание",
          offline = "Оффлайн"
        }
      },
      officerPanel = {
        title = "Детали сотрудника",
        callsign = "Позывной {id}",
        rank = "Ранг",
        health = "Здоровье",
        coords = "Координаты",
        lastUpdateUnknown = "Только что"
      },
      speedcamPanel = {
        title = "Детали камеры скорости",
        limit = "Лимит",
        tolerance = "Погрешность",
        health = "Состояние",
        coords = "Координаты"
      },
      vehiclePanel = {
        title = "Детали транспорта",
        plate = "Номер {plate}",
        netId = "Net ID",
        health = "Состояние",
        coords = "Координаты"
      },
      trackerPanel = {
        title = "Детали трекера",
        plate = "Номер {plate}",
        attachedBy = "Установил",
        attachedAt = "Установлен",
        netId = "Net ID",
        status = "Статус",
        coords = "Координаты"
      },
      actions = {
        openCctv = "Открыть CCTV",
        setWaypoint = "Установить метку"
      },
      waypoint = {
        set = "Метка установлена.",
        missing = "Местоположение недоступно."
      },
      styles = {
        atlas = "Атлас",
        roads = "Дороги",
        satellite = "Спутник"
      },
      missing = {
        title = "Изображение карты отсутствует",
        body = "Поместите изображения карты в frontend/public/img."
      },
      details = {
        title = "Детали",
        empty = "Выберите метку для просмотра деталей."
      },
      zones = {
        title = "Зоны исключения",
        untitled = "Безымянная зона",
        hint = "Нажимайте по карте, чтобы добавить точки. Минимум 3.",
        pointCount = "{count} точек",
        empty = "Зон исключения пока нет.",
        actions = {
          toggle = "Зоны",
          new = "Новая зона",
          cancel = "Отмена",
          save = "Сохранить зону",
          undo = "Отменить",
          clear = "Очистить",
          delete = "Удалить"
        },
        modal = {
          title = "Название зоны исключения",
          confirm = "Сохранить зону"
        },
        errors = {
          points = "Добавьте минимум 3 точки.",
          nameRequired = "Введите название зоны.",
          saveFailed = "Не удалось сохранить зону исключения.",
          deleteFailed = "Не удалось удалить зону исключения."
        }
      },
      monitorZones = {
        title = "Зоны электронного браслета",
        untitled = "Безымянная зона",
        hint = "Нажимайте по карте, чтобы добавить точки. Минимум 3.",
        pointCount = "{count} точек",
        empty = "Зон мониторинга пока нет.",
        mode = {
          allow = "Разрешённая зона",
          exclude = "Запрещённая зона"
        },
        actions = {
          allow = "Разрешённая зона",
          exclude = "Запрещённая зона",
          cancel = "Отмена",
          save = "Сохранить зону",
          undo = "Отменить",
          clear = "Очистить",
          delete = "Удалить"
        },
        modal = {
          title = "Название зоны мониторинга",
          confirm = "Сохранить зону"
        },
        errors = {
          points = "Добавьте минимум 3 точки.",
          nameRequired = "Введите название зоны.",
          noMonitor = "Выберите электронный браслет.",
          saveFailed = "Не удалось сохранить зону мониторинга.",
          deleteFailed = "Не удалось удалить зону мониторинга."
        }
      },
      panic = {
        panelTitle = "Детали тревоги",
        triggeredBy = "Активировал",
        createdAt = "Активировано",
        coords = "Координаты"
      },
      dev = {
        officerName = "Сотрудник Avery Lane",
        callsign = "LIN-23",
        rank = "Сержант",
        unit = "Центральный патруль",
        speedcamName = "Камера скорости Del Perro",
        vehicleName = "Юнит 12",
        trackerName = "Трекер ALPHA",
        trackerOfficer = "Сотрудник Ruiz",
        dispatchTitle = "Камера скорости повреждена",
        dispatchMessage = "Устройству Del Perro требуется обслуживание.",
        panicOfficer = "Сотрудник Sinclair",
        panicLocation = "Mission Row"
      }
    },
    panicNotification = {
      badge = "Тревога",
      title = "Тревожный сигнал",
      subtitle = "{name} нажал тревожную кнопку.",
      callsign = "Позывной {id}",
      locationLabel = "Местоположение",
      locationUnknown = "Неизвестное местоположение",
      hint = "Нажмите {key}, чтобы установить метку на игровой карте."
    },
    incidentNotification = {
      panic = {
        title = "Тревожный сигнал",
        subtitle = "{name} нажал тревожную кнопку."
      },
      dispatch = {
        title = "Диспетчерское уведомление",
        subtitle = "{name} отправил новый вызов."
      },
      ping = {
        title = "Метка местоположения",
        subtitle = "{name} поделился меткой местоположения."
      },
      actions = {
        openMap = {
          key = "M",
          label = "Открыть карту в планшете"
        },
        setWaypoint = {
          key = "G",
          label = "Установить метку"
        },
        dismiss = {
          key = "Backspace",
          label = "Закрыть"
        }
      }
    },
    gradeChange = {
      promotedTitle = "Повышение",
      demotedTitle = "Понижение",
      unchangedTitle = "Ранг обновлён",
      previousLabel = "Предыдущий ранг",
      newLabel = "Текущий ранг",
      unknownLabel = "Ранг не назначен",
      levelFallback = "Ранг {level}"
    },
    employeeGpsJammer = {
      title = "GPS-глушитель",
      disabled = "GPS-глушение недоступно.",
      success = "GPS-сигнал сотрудника заглушён.",
      failed = "Не удалось заглушить GPS-сигнал.",
      targetJammed = "Ваш рабочий GPS-сигнал заглушён.",
      errors = {
        disabled = "GPS-глушение недоступно.",
        no_players = "Рядом никого нет.",
        too_far = "Подойдите ближе, прежде чем использовать GPS-глушитель.",
        invalid_target = "Не удалось найти этого человека.",
        not_on_duty = "У этого человека нет активного рабочего GPS-сигнала.",
        protected_job = "GPS-сигнал этого сотрудника защищён.",
        missing_item = "Для этого вам нужен GPS-глушитель.",
        cooldown = "Подождите немного, прежде чем снова использовать GPS-глушитель.",
        failed = "Не удалось заглушить GPS-сигнал.",
      },
    },
    bonusNotification = {
      title = "Выдан бонус",
      subtitle = "От {name}",
      amountLabel = "Бонус",
      unknownManager = "Руководство"
    },
    wheelClamp = {
      attached = "Колёсный блокиратор установлен"
    },
    search = {
      previewTitle = "Обыск {name}",
      previewSubtitle = "Проверка вещей на оружие и контрабанду...",
      previewCancel = "Нажмите X для отмены",
      unknownTarget = "Неизвестно"
    },
    heliCamHud = {
      title = "Управление вертолётной камерой",
      actions = {
        toggleCam = "Переключить камеру",
        vision = "Переключить зрение",
        spotlight = "Режим прожектора",
        lockTarget = "Захват цели",
        display = "Переключить дисплей",
        takePhoto = "Сделать фото",
        rappel = "Спуск",
        brightness = "Яркость",
        radius = "Радиус"
      }
    },
    jailHud = {
      title = "Оставшееся время",
      trashLabel = "Мусор",
      trashFull = "Пакет заполнен",
      trashDropoff = "Отнесите в мусорный контейнер"
    },
    jailJobs = {
      title = "Тюремные работы",
      subtitle = "Выберите задание, чтобы скоротать время.",
      actions = {
        cleaning = "Уборка",
        gardening = "Садоводство",
        carry_goods = "Перенос грузов"
      },
      currentJob = "Текущая работа:",
      stop = "Остановить работу",
      close = "Закрыть",
      contraband = {
        title = "Контрабанда",
        message = "Вы нашли {item}. Рискнёте оставить себе или выбросите?",
        keep = "Оставить",
        toss = "Выбросить"
      },
      boxInspect = {
        title = "Осмотреть коробку",
        message = "Внутри вы нашли {item}. {description}",
        take = "Взять",
        leave = "Оставить внутри",
        close = "Закрыть"
      }
    },
    socialWork = {
      eyebrow = "Общественные работы",
      title = "Социальные работы",
      listed = "отображено",
      search = {
        placeholder = "Поиск по имени или ID"
      },
      filters = {
        all = "Все",
        label = "Статус",
        placeholder = "Статус"
      },
      actions = {
        refresh = "Обновить",
        back = "Назад к списку"
      },
      state = {
        loading = "Загрузка общественных работ...",
        empty = "Нет общественных работ, соответствующих текущим фильтрам."
      },
      status = {
        active = "Активно",
        overdue = "Просрочено",
        completed = "Завершено",
        imprisoned = "Заключён"
      },
      labels = {
        remainingShort = "осталось",
        imprison = "Заключить",
        imprisonNotice = "Срок истёк. Требуется заключение.",
        noDeadline = "Без срока",
        expired = "Истекло"
      },
      sections = {
        summary = "Сводка работ",
        summarySubtitle = "Обзор назначенных заданий."
      },
      fields = {
        name = "Имя",
        status = "Статус",
        remaining = "Оставшиеся задания",
        completed = "Выполненные задания",
        total = "Всего заданий",
        assigned = "Назначено",
        deadline = "Срок",
        timeLeft = "Оставшееся время",
        assignedBy = "Назначил",
        unknown = "Неизвестно"
      },
      assign = {
        title = "Назначить общественные работы",
        subtitle = "Отправьте ближайшего игрока на социальные работы.",
        playerLabel = "Игрок",
        playerPlaceholder = "Выберите игрока",
        taskLabel = "Задания",
        taskPlaceholder = "Количество заданий",
        deadlineLabel = "Лимит времени (минуты)",
        deadlinePlaceholder = "Необязательно",
        submit = "Назначить",
        success = "Общественные работы назначены.",
        error = "Не удалось назначить общественные работы."
      },
      errors = {
        load = "Не удалось загрузить общественные работы."
      },
      date = {
        unknown = "Неизвестно"
      },
      jobs = {
        title = "Общественные работы",
        subtitle = "Выберите задание для выполнения наказания.",
        currentJob = "Текущее задание:",
        stop = "Остановить задание",
        actions = {
          cleaning = "Уборка",
          carry_goods = "Перенос грузов"
        }
      },
      hud = {
        title = "Общественные работы",
        remaining = "Осталось заданий",
        completed = "Выполнено заданий",
        deadline = "Оставшееся время",
        expired = "Истекло",
        trashLabel = "Мусор",
        trashFull = "Пакет заполнен",
        trashDropoff = "Отнесите в мусорный контейнер"
      }
    },
    socialWorkCreator = {
      title = "Редактор общественных работ",
      description = "Настройка точек общественных работ по всему городу.",
      empty = "Точки общественных работ ещё не настроены.",
      keyboardHint = "Используйте стрелки для навигации по списку и действиям.",
      editTitle = "Метки общественных работ",
      editSubtitle = "Используйте кнопку метки на карте, чтобы сохранить текущие координаты.",
      editKeyboardHint = "Используйте стрелки для выбора метки, влево/вправо для выбора Установить/Очистить, Enter для выполнения, Backspace для возврата.",
      missingEntry = "Точка общественных работ не найдена.",
      actions = {
        newSite = "Новая точка"
      },
      status = {
        set = "Установлено",
        unset = "Не установлено"
      },
      markers = {
        social_work_job_npc = "NPC задания",
        social_work_dumpster = "Мусорный контейнер",
        social_work_box_dropoff = "Точка сдачи груза"
      },
      modals = {
        createTitle = "Создать точку",
        createButton = "Создать точку",
        renameTitle = "Переименовать точку",
        renameButton = "Сохранить название",
        deleteTitle = "Удалить точку",
        deleteMessage = "Вы действительно хотите удалить {name}?",
        deleteConfirmLabel = "Удалить",
        deleteCancelLabel = "Отмена"
      }
    },
    impoundCreator = {
      title = "Редактор штрафстоянки",
      description = "Настройка мест штрафстоянки и точек спавна.",
      empty = "Штрафстоянки ещё не настроены.",
      keyboardHint = "Используйте стрелки для навигации по списку и действиям.",
      editTitle = "Метки штрафстоянки",
      editSubtitle = "Используйте кнопку метки на карте, чтобы сохранить текущие координаты.",
      editKeyboardHint = "Используйте стрелки для выбора метки, влево/вправо для выбора Установить/Очистить/Удалить, Enter для выполнения, Backspace для возврата. Переместитесь за список, чтобы открыть кнопки добавления.",
      missingEntry = "Штрафстоянка не найдена.",
      actions = {
        newLot = "Новая стоянка",
        add = {
          impound_delivery = "Добавить точку сдачи",
          impound_spawn = "Добавить точку спавна"
        }
      },
      status = {
        set = "Установлено",
        unset = "Не установлено"
      },
      markers = {
        impound_lot = "Штрафстоянка",
        impound_spawn = "Точка спавна",
        impound_delivery = "Точка сдачи"
      },
      modals = {
        createTitle = "Создать стоянку",
        createButton = "Создать стоянку",
        renameTitle = "Переименовать стоянку",
        renameButton = "Сохранить название",
        deleteTitle = "Удалить стоянку",
        deleteMessage = "Вы действительно хотите удалить {name}?",
        deleteConfirmLabel = "Удалить",
        deleteCancelLabel = "Отмена"
      }
    },
    impoundStorage = {
      title = "Хранилище штрафстоянки",
      subtitle = "Закажите доставку хранимого транспорта на стоянку.",
      empty = "Для этой стоянки нет хранимого транспорта.",
      emptyAll = "Транспорт на штрафстоянке не найден.",
      unknownModel = "Неизвестно",
      unknownLot = "Неизвестно",
      sections = {
        impounds = "Активные штрафстоянки",
        stored = "Хранимый транспорт"
      },
      columns = {
        plate = "Номер",
        model = "Модель",
        stored = "Хранится",
        lot = "Стоянка",
        status = "Статус",
        fee = "Плата за хранение"
      },
      actions = {
        deliver = "Заказать доставку",
        allowPickup = "Разрешить выдачу",
        seize = "Изъять",
        seized = "Изъято",
        close = "Закрыть",
        refresh = "Обновить"
      },
      status = {
        pickup = "Выдача разрешена",
        seized = "Изъято"
      },
      time = {
        days = "{count} дн."
      },
      errors = {
        load = "Не удалось загрузить хранимый транспорт.",
        deliver = "Не удалось заказать доставку.",
        seized = "Этот транспорт изъят для расследования.",
        update = "Не удалось обновить статус штрафстоянки."
      }
    },
    impoundDecision = {
      title = "Решение по штрафстоянке",
      message = "Решите, можно ли забрать {vehicle} или изъять его для расследования.",
      vehicleFallback = "этот транспорт",
      allowPickup = "Разрешить выдачу",
      seize = "Изъять для расследования"
    },
    jailCreator = {
      title = "Редактор тюрьмы",
      description = "Размещайте точки спавна тюрьмы и управляйте локациями.",
      empty = "Тюрьмы ещё не настроены.",
      keyboardHint = "Используйте стрелки для навигации по списку и действиям.",
      editTitle = "Метки тюрьмы",
      editSubtitle = "Используйте кнопку метки на карте, чтобы сохранить текущие координаты.",
      editKeyboardHint = "Используйте стрелки для выбора метки, влево/вправо для выбора Установить/Очистить/Удалить, Enter для выполнения, Backspace для возврата. Переместитесь за список, чтобы открыть кнопки добавления.",
      missingEntry = "Тюрьма не найдена.",
      actions = {
        newJail = "Новая тюрьма"
      },
      modals = {
        createTitle = "Создать тюрьму",
        createButton = "Создать тюрьму",
        renameTitle = "Переименовать тюрьму",
        renameButton = "Сохранить название",
        deleteTitle = "Удалить тюрьму",
        deleteMessage = "Вы действительно хотите удалить {name}?",
        deleteConfirmLabel = "Удалить",
        deleteCancelLabel = "Отмена"
      }
    },
    jailInmates = {
      title = "Обмен у заключённых",
      close = "Закрыть",
      trade = "Совершить обмен",
      requiredLabel = "Вы отдаёте",
      rewardLabel = "Вы получаете",
      acceptedLabel = "Принимает",
      contrabandLabel = "Контрабанда",
      npc = {
        alcoholic = "Пьяница из блока",
        drugDealer = "Дилер из прачечной",
        doctor = "Тюремный доктор",
        canteen = "Повар столовой"
      },
      dialogs = {
        alcoholic = {
          one = "Однажды я обменял десерт на швабру. Лучший день в моей жизни.",
          two = "Если бы здесь был бар, я был бы работником месяца.",
          three = "Есть что-нибудь с запахом чистых полов и плохих решений?",
          four = "Я называю это тюремным одеколоном. А вы — чистящим спиртом."
        },
        drugDealer = {
          one = "Есть что-нибудь интересное из мусора? Плачу сигаретами.",
          two = "Тише, охрана думает, что я книжный клуб.",
          three = "Принеси контрабанду, и я сделаю твой день дымным.",
          four = "Мусор скрывает сокровища. А я их оценщик."
        },
        doctor = {
          one = "Не двигайся. Это будет быстро.",
          two = "Сегодня бесплатно. Просто не ищи проблем.",
          three = "Выглядишь плохо. Давай подлатаю тебя.",
          four = "Часы работы медпункта здесь никогда не заканчиваются."
        },
        canteen = {
          one = "Сегодня свежие подносы. Вставайте в очередь и не задерживайтесь.",
          two = "Тебе горячую еду или лекцию?",
          three = "За хорошее поведение дают добавку. Иногда.",
          four = "Я видел и худший аппетит."
        }
      },
      doctor = {
        costLabel = "Стоимость",
        rewardLabel = "Лечение",
        actionLabel = "Получить лечение",
        costValue = "Бесплатно",
        rewardValue = "Полное лечение"
      },
      canteen = {
        costLabel = "Стоимость",
        rewardLabel = "Еда",
        actionLabel = "Получить еду",
        costValue = "Бесплатно",
        rewardValue = "Набор еды"
      },
      items = {
        cleaning_alcohol = "Чистящий спирт",
        cigarettes = "Сигареты",
        coke = "Кокаин",
        weed = "Марихуана",
        burger = "Бургер",
        water = "Вода"
      }
    },
    invites = {
      title = "Приглашение на работу",
      description = "Присоединиться к {job} как {role}?",
      invitedBy = "Пригласил {name}",
      expires = "Срок действия предложения скоро истечёт.",
      accept = "Принять",
      decline = "Отклонить",
      errors = {
        missing = "Приглашение недоступно.",
        failed = "Не удалось ответить на приглашение."
      }
    },
    stationCreator = {
      title = "Редактор станций",
      description = "Настройка позиций меток станции.",
      empty = "Станции ещё не настроены.",
      keyboardHint = "Используйте ↑/↓ для выбора, ←/→ для переключения действий, Enter для подтверждения, Backspace для закрытия.",
      editTitle = "Метки станции",
      editSubtitle = "Используйте кнопку метки на карте, чтобы сохранить текущие координаты.",
      editKeyboardHint = "Используйте ↑/↓ для выбора метки, ←/→ для выбора Установить/Очистить/Удалить, Enter для выполнения, Backspace для возврата.",
      sections = {
        markers = "Метки",
        zone = "Тюремная зона"
      },
      zone = {
        subtitle = "Добавьте точки зоны, чтобы определить границы тюрьмы.",
        hint = "Используйте кнопку метки на карте для добавления точек. Удаляйте точки с помощью иконки корзины.",
        empty = "Точек зоны пока нет.",
        pointLabel = "Точка зоны {index}",
        actions = {
          add = "Добавить точку зоны",
          update = "Обновить",
          clear = "Очистить зону"
        }
      },
      missingStation = "Станция не найдена.",
      actions = {
        newStation = "Новая станция",
        editJobBlip = "Редактировать blip работы",
        newJail = "Новая тюрьма",
        add = {
          wardrobe = "Добавить метку гардероба",
          garage_vehicle_menu = "Добавить взаимодействие гаража транспорта",
          garage_vehicle_spawn = "Добавить спавн гаража транспорта",
          garage_vehicle_park = "Добавить парковку гаража транспорта",
          garage_helicopter_menu = "Добавить взаимодействие вертолётной площадки",
          garage_helicopter_spawn = "Добавить спавн вертолётной площадки",
          garage_helicopter_park = "Добавить парковку вертолётной площадки",
          garage_boat_menu = "Добавить взаимодействие причала",
          garage_boat_spawn = "Добавить спавн причала",
          garage_boat_park = "Добавить парковку причала",
          boss_menu = "Добавить метку меню босса",
          wholesale_shop = "Добавить метку оптового магазина",
          duty_terminal = "Добавить метку терминала смены",
          public_forms = "Добавить киоск публичных заявлений",
          jail_solitary_cell = "Добавить одиночную камеру"
        }
      },
      status = {
        set = "Установлено",
        unset = "Не установлено"
      },
      markers = {
        position = "Позиция станции",
        storage = "Хранилище",
        locker = "Шкафчик",
        wardrobe = "Гардероб",
        duty_terminal = "Терминал смены",
        public_forms = "Киоск публичных заявлений",
        boss_menu = "Меню босса",
        garage_vehicle_menu = "Взаимодействие гаража транспорта",
        garage_vehicle_spawn = "Спавн гаража транспорта",
        garage_vehicle_park = "Парковка гаража транспорта",
        garage_helicopter_menu = "Взаимодействие вертолётной площадки",
        garage_helicopter_spawn = "Спавн вертолётной площадки",
        garage_helicopter_park = "Парковка вертолётной площадки",
        garage_boat_menu = "Взаимодействие причала",
        garage_boat_spawn = "Спавн причала",
        garage_boat_park = "Парковка причала",
        wholesale_shop = "Оптовый магазин",
        jail_spawn = "Спавн тюрьмы",
        jail_release = "Точка освобождения",
        jail_menu = "Тюремный терминал",
        jail_job_npc = "NPC тюремной работы",
        jail_inmate_alcoholic = "Заключённый: Алкоголик",
        jail_inmate_drugdealer = "Заключённый: Наркодилер",
        jail_inmate_doctor = "Заключённый: Доктор",
        jail_canteen_cook = "Повар столовой",
        jail_dumpster = "Тюремный мусорный контейнер",
        jail_box_dropoff = "Точка сдачи груза",
        jail_electric_box = "Электрощиток",
        jail_fence_cut = "Точка разреза забора",
        jail_fence_exit = "Выход через забор",
        jail_solitary_cell = "Одиночная камера",
        jail_confiscated_return = "Конфискованные предметы"
      },
      modals = {
        createTitle = "Создать станцию",
        createButton = "Создать станцию",
        renameTitle = "Переименовать станцию",
        renameButton = "Сохранить название",
        deleteTitle = "Удалить станцию",
        deleteMessage = "Вы действительно хотите удалить {name}?",
        deleteConfirmLabel = "Удалить",
        deleteCancelLabel = "Отмена",
        jobBlipTitle = "Blip работы: {job}",
        jobBlipMessage = "Настройте blip станции для этой конкретной работы. Отключите его, если у этой работы не должно быть blip станции.",
        jobBlipSave = "Сохранить blip",
        jobBlipReset = "Сбросить",
        jobBlipInvalidNumber = "Неверное значение для {field}."
      },
      blip = {
        enabled = "Показывать blip",
        useStationName = "Добавлять название станции",
        shortRange = "Короткая дистанция",
        name = "Название",
        sprite = "Sprite",
        color = "Цвет",
        scale = "Масштаб",
        display = "Отображение"
      }
    },
    jailAssign = {
      title = "Отправить в тюрьму",
      selectPlayer = "Выбрать игрока",
      selectPlayerPlaceholder = "Выберите игрока",
      selectJail = "Выбрать тюрьму",
      selectJailPlaceholder = "Выберите тюрьму",
      solitaryLabel = "Одиночная камера",
      solitaryUnavailable = "Для этой тюрьмы не настроены одиночные камеры.",
      durationLabel = "Срок (месяцы)",
      monthHint = "1 месяц = {minutes} минут",
      cancelButton = "Отмена",
      assignButton = "Отправить в тюрьму",
      assigning = "Отправка в тюрьму...",
      noPlayers = "Нет ближайших игроков в радиусе {range} м.",
      noJails = "Тюрьмы ещё не настроены. Сначала используйте редактор тюрьмы.",
      spawnMissing = "Для этой тюрьмы не настроен спавн.",
      jailStatusReady = "Спавн готов",
      jailStatusMissing = "Спавн не настроен",
      success = "Игрок отправлен в тюрьму на {months} месяцев.",
      errors = {
        invalid_target = "Выберите ближайшего игрока и тюрьму.",
        spawn_not_set = "Для этой тюрьмы не настроен спавн.",
        solitary_unavailable = "Для этой тюрьмы не настроены одиночные камеры.",
        failed = "Не удалось отправить игрока в тюрьму."
      }
    },
    bolos = {
      eyebrow = "Доска BOLO",
      title = "BOLO",
      listed = "список",
      unknown = "Неизвестно",
      search = {
        placeholder = "Поиск BOLO по названию, ID, типу или тегу"
      },
      actions = {
        refresh = "Обновить",
        manageTypes = "Управление типами",
        new = "Новый BOLO",
        back = "Назад к списку",
        add = "Добавить",
        addPhoto = "Добавить фото",
        remove = "Удалить"
      },
      state = {
        loading = "Загрузка BOLO...",
        empty = "Нет BOLO, соответствующих текущим фильтрам.",
        saving = "Сохранение...",
        noTags = "Теги не назначены.",
        noReports = "Связанные отчёты отсутствуют."
      },
      detail = {
        summary = "Сводка BOLO",
        untitled = "BOLO без названия"
      },
      fields = {
        title = "Название BOLO",
        id = "ID BOLO",
        type = "Тип",
        status = "Статус",
        priority = "Приоритет",
        created = "Создано",
        updated = "Последнее обновление"
      },
      placeholders = {
        title = "Название BOLO",
        id = "Автоматически создаётся, если пусто",
        type = "Выберите тип",
        description = "Добавьте описание...",
        tag = "Добавить тег",
        reportSelect = "Выберите отчёт"
      },
      sections = {
        description = "Описание",
        descriptionSubtitle = "Укажите детали и инструкции.",
        tags = "Теги",
        tagsSubtitle = "Добавьте быстрые идентификаторы для BOLO.",
        reports = "Связанные отчёты",
        reportsSubtitle = "Прикрепите связанные файлы отчётов.",
        gallery = "Галерея",
        gallerySubtitle = "Прикрепите изображения из галереи к BOLO."
      },
      gallery = {
        title = "Выберите фото",
        subtitle = "Выберите изображение из галереи для прикрепления к BOLO.",
        loading = "Загрузка галереи...",
        empty = "Фотографии в галерее отсутствуют.",
        photoAlt = "Фото галереи"
      },
      typesModal = {
        title = "Типы BOLO",
        subtitle = "Добавьте или удалите типы BOLO для этого устройства.",
        placeholder = "Добавить тип BOLO",
        empty = "Типы BOLO не настроены."
      },
      types = {
        person = "Человек",
        vehicle = "Транспорт",
        property = "Имущество",
        missing = "Пропавший",
        other = "Другое"
      },
      status = {
        active = "Активно",
        located = "Обнаружено",
        closed = "Закрыто",
        cancelled = "Отменено"
      },
      priority = {
        low = "Низкий",
        medium = "Средний",
        high = "Высокий",
        critical = "Критический"
      },
      errors = {
        load = "Не удалось загрузить BOLO.",
        save = "Не удалось сохранить BOLO.",
        titleRequired = "Введите название BOLO перед сохранением.",
        typeRequired = "Выберите тип BOLO перед сохранением.",
        gallery = "Не удалось загрузить галерею."
      }
    },
    warrants = {
      eyebrow = "Хранилище ордеров",
      title = "Ордеры",
      listed = "в списке",
      unknown = "Неизвестно",
      search = {
        placeholder = "Поиск ордеров по названию, ID, типу или тегу"
      },
      actions = {
        refresh = "Обновить",
        manageTypes = "Управление типами",
        new = "Новый ордер",
        back = "Назад к списку",
        add = "Добавить",
        addPhoto = "Добавить фото",
        remove = "Удалить"
      },
      state = {
        loading = "Загрузка ордеров...",
        empty = "Нет ордеров, соответствующих текущим фильтрам.",
        saving = "Сохранение...",
        noTags = "Теги не назначены.",
        noReports = "Связанные отчёты отсутствуют.",
        noOffences = "Связанные правонарушения отсутствуют."
      },
      detail = {
        summary = "Сводка ордера",
        untitled = "Ордер без названия"
      },
      fields = {
        title = "Название ордера",
        id = "ID ордера",
        type = "Тип",
        status = "Статус",
        priority = "Приоритет",
        created = "Создан",
        updated = "Последнее обновление"
      },
      placeholders = {
        title = "Название ордера",
        id = "Будет сгенерирован автоматически, если оставить пустым",
        type = "Выберите тип",
        description = "Добавьте описание...",
        tag = "Добавить тег",
        reportSelect = "Выберите отчёт",
        offenceSelect = "Выберите правонарушение"
      },
      sections = {
        description = "Описание",
        descriptionSubtitle = "Добавьте сводку и инструкции.",
        tags = "Теги",
        tagsSubtitle = "Добавьте быстрые идентификаторы для ордера.",
        reports = "Связанные отчёты",
        reportsSubtitle = "Прикрепите связанные файлы отчётов.",
        offences = "Правонарушения",
        offencesSubtitle = "Свяжите правонарушения с этим ордером.",
        gallery = "Галерея",
        gallerySubtitle = "Прикрепите изображения из галереи к ордеру."
      },
      gallery = {
        title = "Выберите фото",
        subtitle = "Выберите изображение из галереи для прикрепления к ордеру.",
        loading = "Загрузка галереи...",
        empty = "Фото в галерее отсутствуют.",
        photoAlt = "Фото из галереи"
      },
      typesModal = {
        title = "Типы ордеров",
        subtitle = "Добавьте или удалите типы ордеров для этого устройства.",
        placeholder = "Добавить тип ордера",
        empty = "Типы ордеров не настроены."
      },
      types = {
        arrest = "Арест",
        search = "Обыск",
        bench = "Судебный",
        probation = "Испытательный срок"
      },
      status = {
        active = "Активен",
        served = "Исполнен",
        expired = "Истёк",
        cancelled = "Отменён"
      },
      priority = {
        low = "Низкий",
        medium = "Средний",
        high = "Высокий",
        critical = "Критический"
      },
      errors = {
        load = "Не удалось загрузить ордеры.",
        save = "Не удалось сохранить ордер.",
        titleRequired = "Введите название ордера перед сохранением.",
        typeRequired = "Выберите тип ордера перед сохранением.",
        gallery = "Не удалось загрузить галерею."
      }
    },
    prison = {
      eyebrow = "Журнал задержаний",
      title = "Тюрьма",
      listed = "в списке",
      search = {
        placeholder = "Поиск по имени или ID"
      },
      filters = {
        all = "Все",
        label = "Статус",
        placeholder = "Статус"
      },
      actions = {
        refresh = "Обновить",
        back = "Назад к списку",
        saveDuration = "Сохранить срок",
        minusMinutes = "-15 мин",
        minusSmall = "-5 мин",
        plusSmall = "+5 мин",
        plusMinutes = "+15 мин",
        saveNotes = "Сохранить заметки",
        saveWarrant = "Привязать ордер",
        addOffence = "Добавить правонарушение",
        setSolitary = "Отправить в одиночную камеру",
        setGeneral = "Вернуть в общую камеру"
      },
      state = {
        loading = "Загрузка заключённых...",
        empty = "Нет заключённых, соответствующих текущим фильтрам.",
        saving = "Сохранение...",
        noOffences = "Связанные правонарушения отсутствуют."
      },
      labels = {
        mugshot = "Фото задержания"
      },
      detail = {
        summary = "Сводка заключённого"
      },
      fields = {
        booked = "Арестован",
        remaining = "Оставшееся время",
        identifier = "Идентификатор",
        unknown = "Неизвестно",
        remainingMinutes = "Оставшиеся минуты",
        warrant = "Ордер",
        offences = "Правонарушения",
        housing = "Размещение"
      },
      sections = {
        duration = "Срок заключения",
        durationSubtitle = "Измените оставшееся время в минутах.",
        notes = "Заметки",
        notesSubtitle = "Записывайте наблюдения по этому сроку.",
        links = "Связанный ордер и правонарушения",
        linksSubtitle = "Прикрепите ордер и правонарушения, связанные с этим заключением.",
        housing = "Размещение",
        housingSubtitle = "Переключение между одиночной и общей камерой."
      },
      placeholders = {
        note = "Добавьте заметки...",
        warrant = "Выберите ордер",
        offence = "Выберите правонарушение"
      },
      status = {
        in_prison = "В тюрьме",
        breaked_out = "Сбежал",
        released = "Освобождён"
      },
      solitary = {
        active = "Одиночная камера",
        inactive = "Общая камера",
        badge = "Одиночка"
      },
      duration = {
        minutesOnly = "Осталось {minutes}м",
        full = "Осталось {hours}ч {minutes}м"
      },
      linked = {
        warrantFallback = "Ордер"
      },
      date = {
        unknown = "Неизвестно"
      },
      errors = {
        load = "Не удалось загрузить заключённых.",
        duration = "Не удалось обновить срок.",
        note = "Не удалось сохранить заметку.",
        links = "Не удалось обновить связи.",
        solitary = "Не удалось обновить одиночное заключение.",
        solitary_unavailable = "Для этой тюрьмы не настроены одиночные камеры."
      }
    },
    billing = {
      title = "Выставить штраф",
      subtitle = "Взимайте оплату с ближайших граждан за услуги.",
      selectLabel = "Выберите человека",
      selectPlaceholder = "Выберите человека",
      noPlayers = "Нет людей поблизости в радиусе {range} м.",
      amountLabel = "Сумма штрафа",
      reasonLabel = "Причина (кратко)",
      reasonPlaceholder = "Например: Патрульная служба",
      presetsLabel = "Правонарушения",
      presetSearchPlaceholder = "Поиск правонарушения или штрафа",
      presetNoMatches = "Нет правонарушений, соответствующих вашему запросу.",
      presetReasonHeader = "Правонарушение",
      presetAmountHeader = "Штраф",
      presetCustomAmount = "Своя сумма",
      paperDefaultCategory = "Уведомление о нарушении парковки",
      ticketReceiptTitle = "Уведомление о штрафе",
      ticketReceiptSubtitle = "Зарегистрировано",
      ticketReceiptCitizenLabel = "Гражданин",
      ticketReceiptOfficerLabel = "Сотрудник",
      ticketReceiptReasonLabel = "Описание нарушения",
      ticketReceiptAmountLabel = "Общий штраф",
      ticketReceiptAcknowledge = "Подтвердить",
      cancelButton = "Отмена",
      submitButton = "Выставить штраф",
      submitting = "Отправка...",
      success = "Штраф успешно выставлен.",
      paperTicketNumber = "Штраф №",
      paperDate = "Дата",
      paperTime = "Время",
      paperCitizenLabel = "Гражданин",
      paperOfficerLabel = "Сотрудник",
      paperViolationLabel = "Нарушение",
      paperNotice = "Оплата требуется немедленно. Неуплата может привести к эвакуации транспорта.",
      paperSignatureLabel = "Подпись сотрудника",
      paperTotalFine = "Общий штраф",
      errors = {
        failed = "Не удалось выставить штраф.",
        invalid_target = "Человек недоступен.",
        empty_reason = "Укажите краткую причину.",
        too_far = "Человек слишком далеко.",
        not_authorized = "У вас нет прав на выставление штрафов.",
        not_on_duty = "Вы должны быть на смене для выставления штрафов.",
        amount_out_of_range = "Сумма штрафа вне допустимого диапазона.",
        insufficient_funds = "Человек не может оплатить этот штраф.",
        player_unavailable = "Человек недоступен.",
        disabled = "Система штрафов отключена."
      }
    }
  }
}
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
