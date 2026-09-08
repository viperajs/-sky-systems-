if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/config/locales/pl.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

-- Polish translation
Locales["pl"] = {
  WardrobeHelpNotify = "Otwórz Szafę",
  WardrobeTitle = "Garderoba",
  WardrobeCivilianMissing = "Jeszcze nie zapisano stroju cywilnego.",
  WardrobeCivilianRestored = "Strój cywilny załadowany.",
  WardrobeUnsupportedFramework = "Garderoba nie dziala z wybranym frameworkiem ({framework}).",
  WardrobeMissingSkinchanger = "Garderoba wymaga uruchomionego skinchanger na ESX.",
  WardrobeMissingEsxSkin = "Garderoba wymaga uruchomionego esx_skin na ESX.",
  WardrobeMissingQbClothing = "Garderoba wymaga uruchomionego qb-clothing na {framework}.",
  WardrobeMissing17Movement = "Garderoba wymaga uruchomionego 17mov_CharacterSystem.",
  WardrobeMissingQsAppearance = "Garderoba wymaga uruchomionego qs-appearance.",
  WardrobeMissingAk47Clothing = "Garderoba wymaga uruchomionego ak47_clothing.",
  WardrobeMissingAk47QbClothing = "Garderoba wymaga uruchomionego ak47_qb_clothing.",
  WardrobeMissingTgiannClothing = "Garderoba wymaga uruchomionego tgiann-clothing.",
  WardrobeMissingNfSkin = "Garderoba wymaga uruchomionego nf-skin.",
  WardrobeMissingBlAppearance = "Garderoba wymaga uruchomionego bl_appearance.",
  WardrobeMissingIzzyAppearance = "Garderoba wymaga uruchomionego izzy-appearance.",
  WardrobeMissingCodemAppearance = "Garderoba wymaga uruchomionego codem-appearance.",
  WardrobeMissingHexClothing = "Garderoba wymaga uruchomionego hex_clothing.",
  WardrobeMissingIllenium = "Garderoba wymaga uruchomionego illenium-appearance.",
  WardrobeCustomUnavailable = "Skonfigurowana niestandardowa integracja garderoby nie jest dostepna.",
  WardrobeDisabled = "Garderoba jest wylaczona w konfiguracji.",
  WardrobeMissingRcoreClothing = "Garderoba wymaga uruchomionego rcore_clothing.",
  WardrobeUnknownJob = "Praca w garderobie jest niedostępna.",
  GarageHelpNotify = "Otwórz Garaż",
  GarageTitle = "Garaż",
  HelicopterGarageHelpNotify = "Otwórz Helipad",
  BoatGarageHelpNotify = "Otworzyć dok",
  GarageParkHelpNotify = "Zaparkuj pojazd",
  HelicopterGarageParkHelpNotify = "Zaparkuj helikopter",
  BoatGarageParkHelpNotify = "Zaparkować łódź",
  GarageParkDriverRequired = "Musisz być na miejscu kierowcy, aby zaparkować.",
  GarageParkInvalidVehicle = "Ten pojazd nie może być zaparkowany tutaj.",
  GarageParkFailedNotify = "Nie można zaparkować pojazdu.",
  GarageSpawnBlockedNotify = "Punkt odrodzenia zablokowany",
  StorageHelpNotify = "Uzyskaj dostęp do magazynu",
  LockerHelpNotify = "Otwórz szafę",
  TrunkTitle = "Bagażnik",
  TrunkHelpNotify = "Uzyskaj dostęp do bagażnika",
  TrunkPropRemoveHelp = "Usuń ustawiony rekwizyt",
  TrunkUnavailable = "Nie można uzyskać dostępu do tego bagażnika.",
  BossMenuHelpNotify = "Otwórz Zarządzanie",
  Payroll = {
    title = "Lista płac",
    paid = "Otrzymano wynagrodzenie: {amount}",
    insufficient = "Nie ma wystarczająco pieniędzy w kasie firmy na twoje wynagrodzenie.",
  },
  PublicFormsTitle = "Formularze publiczne",
  PublicFormsHelpNotify = "Wypełnij formularze publiczne",
  PublicFormsUnavailable = "Kiosk formularzy publicznych niedostępny.",
  WholesaleShopTitle = "Sprzedaż hurtowa",
  WholesaleShopHelpNotify = "Otwórz Sklep hurtowy",
  WholesaleShopUnavailable = "Ta lokalizacja nie ma skonfigurowanego dostawcy hurtowego.",
  NoPermission = "Nie masz uprawnień do używania tej komendy.",
  CameraUploadFailed = "Nie udało się przesłać obrazu z kamery.",
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
    Title = "Panika",
    Sent = "Przycisk paniki aktywowany.",
    NotOnDuty = "Musisz byc na sluzbie, aby uzyc przycisku paniki.",
    Cooldown = "Przycisk paniki ma odnowienie. Poczekaj {seconds}s.",
    MappingDescription = "Wywołaj alarm paniki",
    WaypointSet = "Punkt GPS ustawiony na lokalizacje paniki.",
    WaypointMissing = "Brak aktywnej lokalizacji paniki.",
    LocationUnknown = "Nieznana lokalizacja",
    MissingItem = "Potrzebujesz {item}, aby użyć przycisku paniki.",
  },
  Ping = {
    Title = "Ping",
    Sent = "Udostepniono ping lokalizacji.",
    NotOnDuty = "Musisz byc na sluzbie, aby wyslac ping.",
    Cooldown = "Ping ma odnowienie. Poczekaj {seconds}s.",
    MappingDescription = "Wyślij znacznik lokalizacji",
    LocationUnknown = "Nieznana lokalizacja",
    MissingItem = "Potrzebujesz {item}, aby wysłać ping.",
  },
  HeliCam = {
    Title = "Kamera heli",
    CamEnabled = "Kamera heli wlaczona.",
    CamDisabled = "Kamera heli wylaczona.",
    NotAuthorized = "Nie masz uprawnien do uzywania kamery heli.",
    NotOnDuty = "Musisz byc na sluzbie, aby uzywac kamery heli.",
    TooLow = "Helikopter jest za nisko, aby aktywowac kamere.",
    TargetLocked = "Cel zablokowany.",
    TargetReleased = "Blokada celu zwolniona.",
    TargetLost = "Utracono cel.",
    RappelDenied = "Nie mozesz zjezdzac na linie z tego miejsca.",
    RappelStarted = "Rozpoczeto zjazd na linie.",
    PhotoSaved = "Zdjecie heli zapisane w galerii.",
    PhotoFailed = "Nie udalo sie zapisac zdjecia heli.",
    Spotlight = {
      ForwardOn = "Swiatlo szperacza wlaczone.",
      ForwardOff = "Swiatlo szperacza wylaczone.",
      TrackingOn = "Szperacz sledzacy aktywny.",
      TrackingOff = "Szperacz sledzacy wylaczony.",
      ManualOn = "Szperacz reczny aktywny.",
      ManualOff = "Szperacz reczny wylaczony.",
      Brightness = "Jasnosc szperacza: {value}",
      Radius = "Promien szperacza: {value}"
    }
  },
  InteractionLabels = {
    job_garage              = "Garaz sluzbowy",
    garage_vehicle_spawn    = "Punkt spawnu pojazdu",
    garage_vehicle_park     = "Parkowanie pojazdu",
    garage_helicopter_menu  = "Hangar smiglowca",
    garage_helicopter_spawn = "Punkt spawnu smiglowca",
    garage_helicopter_park  = "Parkowanie smiglowca",
    garage_boat_menu        = "Przystan",
    garage_boat_spawn       = "Punkt spawnu lodzi",
    garage_boat_park        = "Cumowanie lodzi",
    boss_menu               = "Zarzadzanie",
    duty_terminal           = "Terminal sluzby",
    wardrobe                = "Szatnia",
    storage                 = "Magazyn",
    locker                  = "Szafka",
    wholesale_shop          = "Hurtownia",
    public_forms            = "Formularze publiczne",
    jail_terminal           = "Terminal więzienny",
    jail_jobs               = "Prace więzienne",
    jail_job_npc            = "Prace więzienne",
    jail_inmate_alcoholic   = "Więzień: Alkoholik",
    jail_inmate_drugdealer  = "Więzień: Dealer narkotyków",
    jail_inmate_codelist    = "Więzień: Informator",
    jail_inmate_wirecutter  = "Więzień: Dostawca narzędzi",
    jail_inmate_doctor      = "Lekarz więzienny",
    jail_canteen_cook       = "Kucharz kantyny",
    jail_confiscated_return = "Skonfiskowane przedmioty",
    jail_electric_box       = "Skrzynka elektryczna",
    jail_fence_cut          = "Miejsce przecięcia ogrodzenia",
  },
  Nui = {
    IntlLocale = "pl-PL",
    currency = "zł",
    menuTitles = {
      locker = "Osobista szafa",
      storage = "Magazyn",
      trunk = "Magazyn pojazdów",
      ["trunk-props"] = "Akcesoria pojazdów",
      search = "Szukaj",
      garage = "Garaż",
      vehshop = "Sklep z pojazdami",
      management = "Zarządzanie",
      shop = "Hurtownia",
      ["impound-storage"] = "Magazyn odholowu",
      refunds = "Zwroty"
    },
    menu = {
      goToVehicleShop = "Przejdź do sklepu z pojazdami",
      backToGarage = "Wróć do garażu"
    },
    radial = {
      empty = "Brak dostępnych akcji w tej chwili.",
      errors = {
        generic = "Akcja niedostępna."
      },
      title = "Akcje służbowe",
      hint = "Wybierz akcję do wykonania.",
      pressKey = "Naciśnij {key}",
      actions = {
        billing = {
          label = "Wystaw rachunek",
          description = "Wystaw rachunek najbliższej osobie.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Wystawianie rachunku niedostępne.",
            notOnDuty = "Wejdź na służbę, aby wystawiać faktury.",
            notAuthorized = "Nie masz uprawnień do wystawiania faktur.",
            noPatients = "Brak pobliskich osób do rozliczenia."
          }
        },
        panic = {
          label = "Przycisk paniki",
          description = "Wyzwól alarm paniki dla swojej aktualnej lokalizacji.",
          states = {
            disabled = "Przycisk paniki jest niedostępny.",
            notOnDuty = "Wejdź na służbę, aby użyć przycisku paniki.",
            notAuthorized = "Nie masz uprawnień do użycia przycisku paniki."
          }
        },
        tablet = {
          label = "Otwórz tablet",
          description = "Otwórz interfejs tabletu.",
          states = {
            notOnDuty = "Przejść na służbę, aby używać tabletu.",
            notAuthorized = "Nie masz upoważnienia do korzystania z tabletu.",
            missingItem = "Potrzebujesz tabletu, aby to zrobić."
          }
        },
        removeProp = {
          label = "Usuń rekwizyt",
          description = "Usuń pobliski ustawiony rekwizyt.",
          states = {
            noNearby = "Brak pobliskiego rekwizytu.",
            failed = "Nie udało się usunąć rekwizytu."
          }
        },
        carryPatient = {
          label = "Przenieś osobę",
          description = "Przenieś najbliższą osobę do bezpieczeństwa.",
          dropLabel = "Upuść osobę",
          dropDescription = " Zwolnij osobę, którą niesiesz.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Transport niedostępny.",
            beingCarried = "Już jesteś przenoszony.",
            inVehicle = "Najpierw opuść pojazd.",
            selfIncapacitated = "Nie jesteś stabilny na tyle, by przenosić kogoś.",
            noPatients = "Brak pobliskich osób do przeniesienia.",
            tooFar = "Zbliż się przed przeniesieniem kogoś."
          }
        },
        playerSearch = {
          label = "Szukać osoby",
          description = "Znajdź najbliższą osobę.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Wyszukiwanie gracza niedostępne.",
            notOnDuty = "Przejdź na służbę, aby wyszukiwać osoby.",
            notAuthorized = "Nie masz upoważnienia do wyszukiwania osób.",
            noPlayers = "Brak pobliskich osób do wyszukania.",
            tooFar = "Zbliż się przed wyszukiwaniem.",
            inVehicle = "Najpierw opuść pojazd."
          }
        },
        handcuff = {
          label = "Zacumować osobę",
          description = "Zacamuj najbliższą osobę.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Zamknięcie rękami niedostępne.",
            notOnDuty = "Przejdź na służbę, aby korzystać z kajdanek.",
            inVehicle = "Najpierw opuść pojazd.",
            targetInVehicle = "Najpierw usuń osobę z pojazdu.",
            noPlayers = "Brak pobliskich osób do zapięcia.",
            tooFar = "Zbliż się przed zacumowaniem.",
            missingItem = "Potrzebujesz kajdanek, aby to zrobić.",
            alreadyCuffed = "Ta osoba jest już zawiązana."
          }
        },
        unhandcuff = {
          label = "Zdejmij kajdanki",
          description = "Zdejmij kajdanki z najbliższej osoby.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Zdejmowanie kajdanek niedostępne.",
            notOnDuty = "Przejdź na służbę, aby zdjąć kajdanki.",
            inVehicle = "Najpierw opuść pojazd.",
            targetInVehicle = "Najpierw usuń osobę z pojazdu.",
            noPlayers = "Brak pobliskich osób do zdejmowania kajdanek.",
            tooFar = "Zbliż się przed zdejmowaniem kajdanek.",
            notCuffed = "Ta osoba nie jest zawiązana."
          }
        },
        wheelClamp = {
          label = "Haczyk na koło",
          description = "Upewnij się, że najbliższy pojazd jest zabezpieczony blokadą koła.",
          states = {
            disabled = "Zablokowanie koła niedostępne.",
            notOnDuty = "Przejść do służby, aby zacumować pojazdy.",
            inVehicle = "Najpierw opuść pojazd.",
            noVehicle = "Brak pojazdu w pobliżu.",
            tooFarVehicle = "Zbliż się do pojazdu.",
            noWheel = "Zbliż się do koła.",
            tooFar = "Zbliż się do koła."
          }
        },
        wheelClampRemove = {
          label = "Usuń zacisk",
          description = "Zdejmij zacisk z pojazdu.",
          states = {
            disabled = "Zaciskanie kół jest niedostępne.",
            notOnDuty = "Przejdź do służby, aby usunąć zaciski.",
            inVehicle = "Najpierw opuść pojazd.",
            noClamp = "Brak zacisku na kole w pobliżu.",
            tooFar = "Zbliż się do zacisku na koło."
          }
        },
        jail = {
          label = "Wysłać do więzienia",
          description = "Zatrzymać najbliższego gracza na skonfigurowanej lokalizacji więzienia.",
          states = {
            notAuthorized = "Nie masz uprawnień do wysyłania graczy do więzienia.",
            notOnDuty = "Przejdź do służby, aby użyć tej akcji.",
            noPlayers = "Brak osób w pobliżu w zasięgu.",
            noJails = "Brak skonfigurowanych lokalizacji więzień.",
            spawnNotSet = "Najpierw skonfiguruj punkt startowy więzienia.",
            invalidTarget = "Nie można znaleźć tej osoby.",
            failed = "Nie można wykonać tej akcji."
          }
        }
      }
    },
    shop = {
      shoppingCart = "Koszyk na zakupy",
      purchase = "Kup",
      balance = "Dostępne fundusze",
      catalog = "Katalog dostawcy",
      empty = "Brak dostępnych zapasów w tej lokalizacji.",
      emptyCart = "Twój koszyk jest pusty.",
      insufficientFunds = "Za mało funduszy na ten zakup.",
      limitReached = "Osiągnięto limit ({limit}).",
      errors = {
        invalidStation = "Nieprawidłowa stacja.",
        emptyBasket = "Koszyk pusty.",
        unknown = "Nieznany błąd.",
        purchase = "Zakup w koszyku nie powiódł się."
      }
    },
    garage = {
      states = {
        stored = "Gotowe",
        parked = "W użyciu"
      },
      title = "Garaż",
      empty = "Brak dostępnych pojazdów floty.",
      emptyAir = "Brak dostępnych helikopterów na tym placu.",
      ownedTitle = "Własna flota",
      shopTitle = "Sklep z pojazdami",
      shopBalance = "Fundusze frakcji",
      shopEmpty = "Brak dostępnych pojazdów do zakupu w tej lokalizacji.",
      shopEmptyAir = "Brak dostępnych helikopterów do zakupu na tym placu.",
      emptyFleet = "Jeszcze nie zakupiono pojazdów flotowych.",
      noAccess = "Brak dostępu",
      confirmSellTitle = "Potwierdź sprzedaż",
      confirmSellConfirm = "Sprzedaj",
      confirmSellCancel = "Anuluj",
      confirmSellMessage = "Sprzedać {name} za {price}?",
      confirmPurchaseTitle = "Potwierdź zakup",
      confirmPurchaseConfirm = "Kup",
      confirmPurchaseCancel = "Anuluj",
      confirmPurchaseMessage = "Kupić {name} za {price}?",
      purchaseSuccessTitle = "Pojazd zakupiony",
      purchaseSuccessMessage = "{name} dodano do floty.",
      defaultVehicleName = "Pojazd",
      stats = {
        topSpeed = "Maksymalna prędkość",
        acceleration = "Przyspieszenie",
        braking = "Hamowanie",
        traction = "Przyczepność"
      },
      actions = {
        parkOut = "Parkuj i wyjdź",
        buyVehicle = "Kup pojazd",
        openTrunk = "Otwórz bagażnik",
        editStretcher = "Edytuj nosze",
        sellVehicle = "Sprzedaj pojazd",
        changePlate = "Zmień tablicę"
      },
      placeholders = {
        selectVehicle = "Wybrać pojazd, aby zobaczyć szczegóły.",
        statsLoading = "Ładowanie informacji o pojeździe..."
      },
      errors = {
        loadVehicles = "Nie udało się załadować pojazdów z garażu.",
        loadStats = "Nie udało się załadować statystyk pojazdu.",
        parkOut = "Nie udało się odparkować pojazdu.",
        unavailable = "Garaż jest niedostępny.",
        vehicleUnavailable = "Pojazd niedostępny.",
        purchase = "Zakup pojazdu nie powiódł się.",
        openTrunk = "Nie udało się otworzyć bagażnika.",
        noAccess = "Brak dostępu do tego pojazdu.",
        stretcherEditor = "Nie można otworzyć edytora noszy.",
        stretcherPermission = "Tylko najwyższy stopień może edytować zamocowania noszy.",
        sellVehicle = "Nie udało się sprzedać pojazdu.",
        editorUnavailable = "Edytor niedostępny.",
        changePlate = "Nie udało się zmienić tablicy."
      },
      changePlateTitle = "Zmień tablicę rejestracyjną",
      changePlateButton = "Zastosuj",
      plateEditor = {
        button = "Edytuj tablicę",
        title = "Edytuj tablicę",
        hint = "Zmień tablicę tego pojazdu.",
        save = "Zapisz tablicę",
        errors = {
          empty = "Wprowadź tablicę.",
          invalid = "Tablica jest nieprawidłowa.",
          update = "Nie udało się zaktualizować tablicy."
        }
      },
      status = {
        parkedBy = "Ostatnio wyciągnięty przez {name}",
        unknownDriver = "Nieznany"
      }
    },
    duty = {
      fields = {
        grade = "Stopień",
        location = "Stacja",
        name = "Nazwa",
        badge = "Odznaka"
      },
      instructions = {
        drag = "Przeciągnij swoją kartę pracownika na sensor, aby zarządzać zmianą.",
        dragCard = "Przeciągnij kartę pracownika na sensor, aby rozpocząć zmianę."
      },
      screen = {
        welcome = "Witamy {name}",
        goodbye = "Zmiana zakończona. Do zobaczenia, {name}.",
        ready = "Dostęp do zmiany przyznany.",
        completed = "Zmiana zakończyła się pomyślnie.",
        idleTitle = "Oczekiwanie na skan",
        totalHours = "Łączna liczba godzin",
        shiftDuration = "Czas trwania zmiany",
        currentTime = "Aktualny czas: {time}",
        defaultStation = "Główny terminal",
        devPrompt = "Wczytaj dane testowe, aby podglądać terminal służbowy w przeglądarce.",
        loadMock = "Wczytaj dane testowe",
        loading = "Wczytywanie..."
      },
      toasts = {
        failed = "Nie można zaktualizować statusu służby."
      },
      errors = {
        unavailable = "Terminal służbowy jest niedostępny."
      },
      title = "Terminal zmiany"
    },
    storage = {
      inventory = "Inwentarz",
      storage = "Magazyn",
      locker = "Skrzynka",
      trunk = "Bagażnik pojazdu",
      trunkProps = "Atrybuty pojazdu",
      openPropMenu = "Atrybuty",
      search = "Szukaj",
      items = "Przedmioty",
      weapons = "Broń",
      transferTitle = "Przeniesienie",
      transferButton = "Przenieść",
      capacityUnlimited = "Nieograniczona pojemność",
      errors = {
        trunkFull = "Bagażnik jest pełny.",
        searchReadOnly = "Możesz usuwać tylko przedmioty z osoby.",
        invalidTransfer = "Przesyłanie nie powiodło się.",
        invalidAmount = "Nieprawidłowa ilość.",
        notEnoughItems = "Za mało przedmiotów.",
        inventoryFull = "Za mało miejsca w inwentarzu.",
        storageFull = "Aby wyczyścić magazyn.",
        lockerFull = "Aby wyczyścić szafkę.",
        restrictedItem = "Aby uzyskać dostęp do tego przedmiotu.",
        invalidProp = "Nie udało się wybrać rekwizytu."
      },
      officerInventory = "Inwentarz personelu",
      loadout = "Wyposażenie",
      armory = "Zbrojownia",
      armoryTitle = "Wyposażenie zbrojowni",
      storageTitle = "Bezpieczne przechowywanie",
      storageSubtitle = "Tylko upoważniony personel",
      emptyItems = "Brak dostępnych przedmiotów.",
      emptyWeapons = "Brak dostępnej broni.",
      emptyProps = "Brak dostępnych rekwizytów.",
      searchItems = "Przedmioty",
      searchWeapons = "Broń",
      lockerUnlocking = "Odblokowywanie szafki...",
      restrictedPill = "Ograniczone",
      restrictedTooltip = "Nie masz dostępu do tego przedmiotu.",
      capacityLabel = "{użyte}/{pojemność}",
      propPlacement = {
        title = " Rozmieszczenie rekwizytów",
        place = "Umieść ({key})",
        cancel = "Anuluj ({key})"
      }
    },
    creator = {
      title = "Twórca",
      description = "Konfiguruj wpisy.",
      selectJob = "Wybierz kategorię pracy.",
      empty = "Jeszcze nie skonfigurowano {entryLabelPlural}.",
      keyboardHint = "Użyj klawiszy strzałek, aby poruszać się po liście i akcjach.",
      placementHelp = "Strzałki przesuwają, PageUp/PageDown wysokość, Q/E obracają, Enter zatwierdza, Backspace anuluje.",
      editTitle = "Znacznik",
      editSubtitle = "Użyj przycisku pinezki na mapie, aby zapisać swoje aktualne współrzędne.",
      editKeyboardHint = "Użyj klawiszy strzałek, aby wybrać znacznik, lewo/prawo, aby wybrać Ustaw/Wymaż, Enter, aby go uruchomić, Backspace, aby wrócić.",
      missingEntry = "Nie znaleziono wpisu.",
      actions = {
        add = "Dodaj {label}",
        newEntry = "Nowy {entryLabel}"
      },
      status = {
        set = "Ustaw",
        unset = "Usuń ustawienie"
      },
      modals = {
        createTitle = "Utwórz {entryLabel}",
        createButton = "Utwórz {entryLabel}",
        renameTitle = "Zmień nazwę {entryLabel}",
        renameButton = "Zapisz nazwę",
        deleteTitle = "Usuń {entryLabel}",
        deleteMessage = "Czy na pewno chcesz usunąć {name}?",
        deleteConfirmLabel = "Usuń",
        deleteCancelLabel = "Anuluj"
      }
    },
    management = {
      noAccess = "Nie masz dostępu do żadnych narzędzi zarządzania.",
      refunds = {
        description = "Przejrzyj zgony z dzisiaj i wczoraj oraz zwróć usunięte przedmioty.",
        refreshButton = "Odśwież",
        updatedAt = "Zaktualizowano {time}",
        errors = {
          loadFailed = "Nie udało się załadować zwrotów."
        }
      },
      dashboard = {
        sidebarTitle = "Kokpit",
        menuTitle = "Przegląd",
        onlineMembers = "Członkowie online",
        funds = "Fundusze",
        onDuty = "Na służbie",
        offDuty = "Po służbie",
        mostActive = "Najaktywniejsi"
      },
      finance = {
        sidebarTitle = "Przepływ gotówki",
        menuTitle = "Podsumowanie finansowe",
        expenseCategories = "Kategorie wydatków",
        revenueCategories = "Kategorie przychodów",
        kpis = {
          revenue = "Przychód",
          expenses = "Wydatki",
          profit = "Zysk"
        },
        cashFlow = "Trend przepływu gotówki",
        lastUpdated = "Zaktualizowano {time}",
        emptyStates = {
          timeline = "Brak zapisów transakcji w tym okresie.",
          categories = "Brak danych kategorii jeszcze."
        },
        categories = {
          deposits = "Depozyty",
          withdrawals = "Wypłaty",
          supplies = "Zaopatrzenie",
          vehicles = "Pojazdy",
          salaries = "Wynagrodzenia",
          bonuses = "Bony"
        },
        errors = {
          load = "Nie można załadować zrzutu finansowego."
        }
      },
      transactions = {
        sidebarTitle = "Fundusze",
        menuTitle = "Zarządzanie funduszami",
        currentBalance = "Bieżące saldo",
        withdrawButton = "Wypłać",
        depositButton = "Wpłać",
        recentTransactions = "Ostatnie transakcje",
        columnNames = {
          timestamp = "Znacznik czasu",
          name = "Nazwa",
          action = "Akcja",
          content = "Kwota"
        },
        actions = {
          deposited = "Wydano pieniądze",
          withdrawn = "Wypłacono pieniądze",
          supplies_purchased = "Zakup zaopatrzenia",
          vehicle_purchased = "Kupiono pojazd",
          vehicle_sold = "Sprzedano pojazd",
          salary_paid = "Wypłacono wynagrodzenie",
          bonus_paid = "Wypłacono premię"
        },
        errors = {
          load = "Nie można załadować transakcji.",
          failed = "Transakcja nie powiodła się."
        }
      },
      billingSpecs = {
        sidebarTitle = "Szablony rozliczeń",
        menuTitle = "Powody rozliczeń",
        description = "Skonfiguruj powody, dla których pracownicy mogą wybierać podczas rozliczeń, i zdefiniuj ich domyślne ceny.",
        reasonColumn = "Powód",
        priceColumn = "Cena",
        actionsColumn = "Akcje",
        reasonLabel = "Powód rozliczenia",
        reasonPlaceholder = "np. Reakcja na patrol",
        amountLabel = "Domyślna cena",
        emptyState = "Jeszcze nie dodano powodów rozliczeń.",
        addButton = "Dodaj",
        addFirstButton = "Utwórz swój pierwszy powód",
        deleteButton = "Usuń",
        saveButton = "Zapisz",
        reasonRequired = "Wprowadź powód, aby zapisać ten wiersz.",
        saveSuccess = "Specyfikacje rozliczeniowe zaktualizowane.",
        saveError = "Nie można zapisać specyfikacji rozliczeniowych.",
        loadError = "Nie można załadować specyfikacji rozliczeniowych.",
        updatedAt = "Zaktualizowano o {time}"
      },
      members = {
        sidebarTitle = "Członkowie",
        menuTitle = "Lista osób",
        inviteTitle = "Zaproś do frakcji",
        inviteSubtitle = "Wybierz gracza i przypisz mu rangę początkową.",
        selectPlayer = "Wybierz gracza",
        selectRank = "Wybierz rangę",
        sendInvite = "Zaproś",
        columnNames = {
          name = "Nazwa",
          rank = "Ranga",
          last_online = "Ostatnio online",
          total_work_time = "Czas pracy (h)",
          actions_done = "Wykonane działania",
          actions = "Działania"
        },
        bonus = {
          title = "Przyznaj premię",
          confirmButton = "Wypłać premię",
          actionLabel = "Premia",
          invalidAmount = "Wprowadź poprawną kwotę premii.",
          failed = "Nie udało się wypłacić premii.",
          unexpectedError = "Wystąpił nieoczekiwany błąd podczas wypłaty premii."
        },
        errors = {
          load = "Nie udało się pobrać członków.",
          loadUnexpected = "Napotkano nieoczekiwany błąd podczas pobierania członków.",
          invite = "Nie udało się wysłać zaproszenia.",
          inviteUnexpected = "Nieoczekiwany błąd podczas wysyłania zaproszenia."
        }
      },
      roles = {
        sidebarTitle = "Role",
        menuTitle = "Role",
        createRoleButton = "Utwórz rolę",
        columnNames = {
          grade = "Stopień",
          label = "Nazwa roli",
          salary = "Wynagrodzenie",
          salaryInterval = "Przedział (min)",
          actions = "Działania"
        },
        editMenu = {
          title = "Edytuj rolę",
          createTitle = "Utwórz rolę",
          createSaveButton = "Utwórz",
          newRoleBreadcrumb = "Nowa rola",
          unnamedRole = "Rola bez nazwy",
          gradeMeta = "Ranga {grade}",
          backButton = "Wróć",
          saveButton = "Zapisz",
          general = "Ogólne",
          permissions = "Uprawnienia",
          salary = "Wynagrodzenie",
          salaryDescription = "Ustaw wynagrodzenie dla tej roli.",
          salaryInterval = "Przedział wypłat",
          salaryIntervalDescription = "Wybierz, jak często ta rola otrzymuje wynagrodzenie (w minutach pracy).",
          roleName = "Nazwa roli",
          roleNameDescription = "Ustaw nazwę roli dla tej roli.",
          highestRoleInfo = "To najwyższy rang i automatycznie ma dostęp do wszystkich uprawnień."
        },
        unsavedChanges = {
          title = "Niezapisane zmiany",
          message = "Masz niezapisane zmiany dla tej roli. Opuścić mimo wszystko i odrzucić je?",
          confirm = "Opuścić bez zapisywania zmian",
          cancel = "Kontynuować edycję"
        },
        permissionsEmpty = "Nie znaleziono uprawnień.",
        permissionEntries = {
          viewLogs = {
            label = "Podgląd logów",
            description = "Pozwala na odczyt dzienników transakcji i działań zadań."
          },
          manageRoles = {
            label = "Zarządzaj rolami",
            description = "Pozwala na tworzenie, edytowanie, przenoszenie i usuwanie stopni."
          },
          manageMembers = {
            label = "Zarządzaj członkami",
            description = "Zezwala na promowanie, degradowanie, zwalnianie lub wypłacanie premii."
          },
          manageWarehouse = {
            label = "Uzyskać dostęp do magazynu",
            description = "Umożliwia interakcję ze wspólnym inwentarzem magazynowym."
          },
          manageMoney = {
            label = "Zarządzać funduszami",
            description = "Umożliwia wpłatę lub wypłatę pieniędzy społeczności."
          },
          editOutfits = {
            label = "Edytować stroje",
            description = "Umożliwia aktualizację zapisanego wkładu garderoby."
          },
          createOutfits = {
            label = "Tworzyć stroje",
            description = "Umożliwia tworzenie nowych wpisów garderoby."
          },
          deleteOutfits = {
            label = "Usunąć stroje",
            description = "Umożliwia usuwanie zapisanych wpisów garderoby."
          },
          purchaseSupplies = {
            label = "Zamówić zapasy",
            description = "Umożliwia zamawianie sprzętu od hurtowego dostawcy przy użyciu funduszy frakcji."
          },
          purchaseVehicles = {
            label = "Kupować pojazdy",
            description = "Umożliwia zakup nowych pojazdów flotowych przy użyciu funduszy frakcji."
          },
          garageVehicles = {
            label = "Ograniczenia dostępności pojazdów w garażu",
            description = "Wybierz, do których pojazdów flotowych ta rola nie ma dostępu w garażu."
          },
          tabletApps = {
            label = "Ograniczenia aplikacji na tablecie",
            description = "Wybierz, do których aplikacji na tablecie ta rola nie ma dostępu."
          },
          all = {
            label = "Pełny dostęp",
            description = "Przyznaje wszystkie uprawnienia bez względu na inne przełączniki."
          }
        },
        permissionOptions = {
          storageHint = "Dodaj przedmioty, których nie można usunąć tą rolą.",
          storageItemsTitle = "Ograniczone przedmioty",
          storageWeaponsTitle = "Ograniczone bronie",
          allowedWeaponsTitle = "Dozwolone bronie",
          weaponHint = "Dodaj bronie, do których ta rola ma dostęp.",
          vehicleHint = "Wybierz pojazdy, do których ta rola nie ma dostępu.",
          appHint = "Wybierz aplikacje na tablecie, do których ta rola nie ma dostępu.",
          itemPlaceholder = "Wpisz, aby dodać przedmiot",
          weaponPlaceholder = "Wpisz, aby dodać broń",
          weaponSelectPlaceholder = "Wybierz broń",
          vehiclePlaceholder = "Wybierz pojazd",
          appPlaceholder = "Wybierz aplikację na tablecie",
          addButton = "Dodaj",
          emptyVehicles = "Brak dostępnych pojazdów.",
          emptyApps = "Brak dostępnych aplikacji na tablecie.",
          errors = {
            empty = "Proszę wprowadzić wartość.",
            duplicate = "Opcja już dodana.",
            itemMissing = "Przedmiot nie istnieje.",
            vehicleMissing = "Wybierz pojazd.",
            appMissing = "Wybierz aplikację na tablecie.",
            weaponMissing = "Broń nie istnieje.",
            weaponSelectMissing = "Wybierz broń."
          }
        },
        errors = {
          save = "Nie udało się zapisać roli.",
          saveUnexpected = "Nieoczekiwany błąd podczas zapisywania roli.",
          permissionsLoad = "Nie udało się pobrać uprawnień.",
          permissionsUnexpected = "Nieoczekiwany błąd podczas pobierania uprawnień."
        }
      },
      logs = {
        sidebarTitle = "Dziennik",
        menuTitle = "Dziennik",
        errors = {
          load = "Nie udało się wczytać logów."
        },
        columnNames = {
          timestamp = "Znacznik czasu",
          name = "Nazwa",
          action = "Akcja",
          content = "Zawartość"
        },
        actions = {
          stored = "Przedmiot przechowywany",
          removed = "Usunięto element",
          deposited = "Zostały zdeponowane pieniądze",
          withdrawn = "Zostały wypłacone pieniądze",
          outfit_created = "Utworzono strój",
          outfit_updated = "Zaktualizowano strój",
          outfit_deleted = "Usunięto strój",
          permissions_updated = "Zaktualizowano uprawnienia",
          invite_sent = "Wysłano zaproszenie",
          invite_accepted = "Zaakceptowano zaproszenie",
          invite_declined = "Odrzucono zaproszenie",
          bonus_paid = "Wypłacono bonus",
          member_promoted = "Awansowano członka",
          member_demoted = "Degradowano członka",
          member_fired = "Zwolniono członka",
          supplies_purchased = "Kupiono zapasy",
          vehicle_purchased = "Kupiono pojazd",
          vehicle_sold = "Sprzedano pojazd",
          salary_paid = "Wypłacono wynagrodzenie"
        }
      },
      dialogs = {
        deleteOutfit = {
          title = "Usuń strój",
          message = "Czy na pewno chcesz usunąć \"{name}\"?",
          confirm = "Usuń strój",
          cancel = "Anuluj"
        }
      }
    },
    cloakroom = {
      title = "Szatnia",
      civilianClothes = "Ubrania cywilne",
      newOutfit = "Nowy strój",
      edit = {
        save = "zapisać",
        rotateAlt = "obrócić",
        outfitNameTitle = "Nazwa stroju",
        saveOutfit = "zapisać strój"
      }
    },
    tablet = {
      apps = {
        management = "Menu Szefa",
        patients = "Pacjenci",
        citizens = "Obywatele",
        offences = "Wykroczenia",
        cases = "Sprawy",
        social_work = "Praca socjalna",
        vehicles = "Pojazdy",
        weapons = "Broń",
        prison = "Więzienie",
        warrants = "Nakazy przeszukania",
        bolos = "Ostrzeżenia poszukiwawcze",
        conditions = "Schorzenia",
        reports = "Raporty",
        camera = "Kamera",
        gallery = "Galeria",
        map = "Mapa",
        chat = "Czat",
        calendar = "Kalendarz",
        calculator = "Kalkulator",
        settings = "Ustawienia"
      }
    },
    common = {
      close = "Zamknij",
      unknownError = "Nieznany błąd.",
      unexpectedError = "Wystąpił nieoczekiwany błąd.",
      time = {
        now = "Teraz"
      },
      pagination = {
        prev = "Poprzedni",
        next = "Następny",
        page = "Strona {current} z {total}"
      },
      gallery = {
        title = "Galeria",
        subtitle = "Wybierz zdjęcie lub wideo.",
        loading = "Wczytywanie galerii...",
        empty = "Brak dostępnych elementów galerii.",
        photoAlt = "Media z galerii"
      },
      back = "Powrót",
      confirm = {
        unsavedTitle = "Nie zapisane zmiany",
        unsavedMessage = "Porzucić zmiany lub zapisać przed wyjściem?",
        unsavedDiscard = "Porzucić zmiany",
        unsavedSave = "Zapisz zmiany"
      }
    },
    reports = {
      unknown = "Nieznany"
    },
    publicForms = {
      complaint = {
        fields = {
          fullName = "Imię i nazwisko",
          phone = "Numer telefonu",
          incidentDate = "Data incydentu",
          incidentTime = "Czas incydentu",
          location = "Lokalizacja incydentu",
          officerName = "Imię i nazwisko pracownika",
          badgeNumber = "Numer odznaki",
          description = "Szczegóły skargi",
          witnesses = " świadkowie",
          desiredOutcome = "Żądane rozwiązanie",
          email = "Adres e-mail",
          address = "Adres zamieszkania",
          signature = "Podpis"
        },
        title = "Skarga obywatelska",
        subtitle = "Zgłosić zachowanie personelu lub sprawy departamentu.",
        placeholders = {
          fullName = "Wprowadź swoje pełne imię i nazwisko",
          phone = "###-###-####",
          email = "name@email.com",
          address = "Ulica, miasto, stan",
          incidentDate = "MM/DD/RRRR",
          incidentTime = "GG:MM",
          location = "Gdzie to się wydarzyło?",
          officerName = "Imię i nazwisko personelu lub jednostki",
          badgeNumber = "Numer odznaki, jeśli znany",
          description = "Opisać szczegółowo, co się stało...",
          witnesses = "Wymienić świadków lub inne strony",
          desiredOutcome = "Jakie wyniki chcesz uzyskać?",
          signature = "Wpisz swoje pełne imię i nazwisko"
        }
      },
      application = {
        fields = {
          fullName = "Pełne imię i nazwisko",
          dateOfBirth = "Data urodzenia",
          phone = "Numer telefonu",
          experience = "Doświadczenie zawodowe",
          availability = "Dostępność",
          whyJoin = "Dlaczego chcesz dołączyć?",
          email = "Adres e-mail",
          address = "Adres zamieszkania",
          education = "Edukacja",
          certifications = "Certyfikaty",
          references = "Referencje",
          signature = "Podpis"
        },
        title = "Aplikacja o pracę",
        subtitle = "Aplikuj, aby dołączyć do departamentu.",
        placeholders = {
          fullName = "Wprowadź swoje pełne imię i nazwisko",
          dateOfBirth = "MM/DD/RRRR",
          phone = "###-###-####",
          email = "name@email.com",
          address = "Ulica, miasto, stan",
          education = "Liceum, szkoła policealna lub wyższa",
          experience = "Rola w służbach porządkowych, bezpieczeństwie lub obsłudze",
          certifications = "Szkolenia z pierwszej pomocy, posiadanie broni lub związane z tym szkolenia",
          availability = "Preferowane zmiany lub data rozpoczęcia",
          whyJoin = "Powiedz nam, dlaczego chcesz tutaj pracować...",
          references = "Nazwy i dane kontaktowe",
          signature = "Wprowadź swoje pełne imię i nazwisko"
        }
      },
      title = "Formularze publiczne",
      subtitle = "Złożyć skargę lub podanie o pracę.",
      stationLabel = "Stacja",
      dateLabel = "Data",
      timeLabel = "Godzina",
      stamp = {
        label = "PD",
        complaint = "CMP",
        application = "APLIKACJA"
      },
      tabs = {
        complaint = "Formularz skargi",
        application = "Podanie o pracę",
        myForms = "Moje zgłoszenia"
      },
      myForms = {
        title = "Moje zgłoszenia",
        empty = "Nie złożyłeś jeszcze żadnych formularzy.",
        back = "Wstecz",
        notesTitle = "Odpowiedzi",
        notesEmpty = "Brak odpowiedzi.",
        statusNew = "Oczekujące",
        statusReviewed = "Sprawdzone",
        statusArchived = "Zarchiwizowane"
      },
      actions = {
        submit = "Złóż formularz",
        clear = "Wyczyść pola",
        close = "Zamknij"
      },
      status = {
        submitting = "Wysyłanie...",
        success = "Formularz został pomyślnie przesłany.",
        error = "Nie można przesłać formularza."
      },
      errors = {
        required = "Proszę uzupełnić wymagane pola."
      }
    },
    tabletForms = {
      title = "Skrzynka formularzy",
      eyebrow = "Formularze publiczne",
      listed = "wymienione",
      filters = {
        label = "Typ",
        all = "Wszystkie formularze",
        complaint = "Skargi",
        application = "Aplikacje"
      },
      search = {
        placeholder = "Szukaj po nazwie, stacji lub id"
      },
      status = {
        new = "Nowy",
        reviewed = "Zrecenzowany",
        archived = "Zarchiwizowany"
      },
      state = {
        empty = "Brak formularzy pasujących do obecnych filtrów.",
        loading = "Ładowanie formularzy...",
        saving = "Zapisywanie..."
      },
      errors = {
        load = "Nie można załadować formularzy.",
        update = "Nie można zaktualizować statusu formularza."
      },
      detail = {
        complaintTitle = "Szczegóły skargi",
        applicationTitle = "Szczegóły wniosku"
      },
      actions = {
        refresh = "Odśwież",
        markReviewed = "Oznacz jako zrecenzowane",
        archive = "Archiwizuj",
        back = "Powrót do listy"
      },
      notifications = {
        timeNow = "Teraz",
        complaintType = "Skarga",
        applicationType = "Wniosek",
        app = "Formularze",
        title = "Nowy publiczny formularz",
        body = "{type} od {name} ({station})"
      },
      fields = {
        type = "Typ formularza",
        id = "ID formularza",
        station = "Stacja",
        submitted = "Zgłoszono",
        status = "Stan",
        contact = "Kontakt"
      },
      notes = {
        title = "Notatki",
        loading = "Ładowanie notatek...",
        empty = "Brak notatek.",
        placeholder = "Napisz notatkę...",
        visibleBadge = "Widoczne dla obywatela",
        visibleToCitizen = "Widoczne dla obywatela",
        submit = "Dodaj notatkę"
      }
    },
    gallery = {
      eyebrow = "Galeria dowodów",
      title = "Kamera Rolka",
      filters = {
        all = "Wszystkie",
        camera = "Kamera",
        speedcam = "Radarowe pomiary prędkości",
        cctv = "CCTV",
        mugshot = "Zdjęcia portretowe"
      },
      labels = {
        count = "{count} zdjęć",
        sort = "Najnowsze najpierw",
        photoAlt = "Zdjęcie z galerii",
        photoFullAlt = "Zdjęcie w pełnym rozmiarze",
        takenBy = "Zrobione przez",
        captured = "Zarejestrowane",
        unknownTime = "Nieznany czas",
        unknownTakenBy = "Nieznany"
      },
      state = {
        loading = "Ładowanie nagrań...",
        emptyTitle = "Brak zdjęć.",
        emptySubtitle = "Twoje najnowsze zdjęcia z kamery pojawią się tutaj."
      },
      errors = {
        load = "Nie można załadować galerii.",
        delete = "Nie można usunąć zdjęcia."
      },
      confirm = {
        deleteTitle = "Usuń zdjęcie",
        deleteMessage = "Czy na pewno chcesz usunąć to zdjęcie? Nie można tego cofnąć.",
        deleteConfirm = "Usuń",
        deleteCancel = "Anuluj"
      },
      mock = {
        caption = "ZDJĘCIE DO POKAZU"
      }
    },
    camera = {
      help = {
        focused = "Naciśnij spację, aby włączyć przemieszczanie się.",
        blurred = "Naciśnij spację, aby znowu korzystać z tabletu."
      },
      mode = {
        photo = "Zdjęcie",
        video = "Wideo",
        switchPhoto = "Przełącz na tryb zdjęcia",
        switchVideo = "Przełącz na tryb wideo"
      },
      capture = {
        photo = "Wykonaj zdjęcie"
      },
      queue = {
        title = "Kolejka",
        empty = "Brak przesłanych zdjęć.",
        kind = {
          photo = "Przesyłanie zdjęcia",
          video = "Przesyłanie wideo"
        },
        status = {
          loading = "Wgrywanie...",
          success = "Zapisano",
          error = "Nie powiodło się"
        }
      },
      preview = {
        lastShot = "Ostatnie zdjęcie",
        lastCapture = "Ostatnie nagranie"
      },
      record = {
        start = "Rozpocznij nagrywanie",
        stop = "Zatrzymaj nagrywanie",
        live = "Nagrywanie",
        saving = "Zapisywanie wideo...",
        name = "Kamera klip",
        description = "Nagrywanie na tablecie",
        errors = {
          config = "Brak pliku konfiguracyjnego do załadowania.",
          upload = "Nie udało się załadować.",
          save = "Nie można zapisać filmu.",
          unsupported = "Nagrywanie nie jest obsługiwane.",
          empty = "Na razie nie nagrano żadnego filmu.",
          busy = "Nagrywanie jest zajęte.",
          notRecording = "Nagrywanie zostało już zatrzymane."
        }
      },
      errors = {
        timeout = "Przekroczono czas na przesłanie.",
        capture = "Nieoczekiwany błąd podczas robienia zdjęcia.",
        upload = "Nie udało się załadować."
      }
    },
    cctv = {
      eyebrow = "Sieć monitoringu",
      title = "Kamera CCTV",
      listed = "wyświetlone",
      actions = {
        refresh = "Odśwież"
      },
      search = {
        placeholder = "Wyszukaj kamery po nazwie, ID lub lokalizacji"
      },
      filters = {
        all = "Wszystkie kamery",
        bodycam = "Kamery na ciele",
        dashcam = "Kamery samochodowe",
        cctv = "Kamery CCTV",
        speedcam = "Fotoradary"
      },
      types = {
        bodycam = "Kamera na ciele",
        dashcam = "Kamera samochodowa",
        speedcam = "Kamera prędkości",
        cctv = "Kamera CCTV"
      },
      status = {
        online = "Online",
        maintenance = "Konserwacja",
        offline = "Offline"
      },
      live = {
        active = " Strumień na żywo aktywny",
        maintenance = "Strumień wstrzymany na konserwację",
        offline = "Utracono sygnał",
        placeholderTitle = "Brak dostępnego strumienia",
        placeholderSubtitle = "Wybierz pracownika z kamerką na ciele.",
        speedcamPlaceholderTitle = "Fotoradar offline",
        speedcamPlaceholderSubtitle = "Napraw lub wymień urządzenie, aby przywrócić strumień."
      },
      labels = {
        speedcamLocation = "Przy drodze",
        onDuty = "Na służbie",
        durability = "Trwałość"
      },
      state = {
        loading = "Ładowanie kamer...",
        empty = "Nie ma kamer pasujących do bieżących filtrów.",
        select = "Wybierz kamerę, aby wyświetlić jej strumień."
      },
      controls = {
        tiltUp = "Przechyl w górę",
        panLeft = "Obróć w lewo",
        panRight = "Obróć w prawo",
        tiltDown = "Przechyl w dół"
      },
      capture = {
        name = "CCTV - {label}",
        description = "{location} ({id})",
        saved = "Zapisano w galerii.",
        error = "Nie można zrobić zdjęcia.",
        action = "Uwiecznij",
        loading = "Trwa robienie zdjęcia..."
      },
      record = {
        name = "CCTV Klip - {label}",
        description = "{location} ({id})",
        save = "Zapisz ostatnie {minutes} min",
        saving = "Zapisuję...",
        requested = "Wniosek o zapis wysłany.",
        saved = "Wideo zapisano w galerii.",
        errors = {
          config = "Brak konfiguracji do przesłania.",
          upload = "Przesyłanie nie powiodło się.",
          save = "Nie można zapisać wideo.",
          unsupported = "Nagrywanie nieobsługiwane.",
          empty = "Brak bufora do tej pory.",
          request = "Nie można poprosić o wideo z kamerki ciała.",
          timeout = "Zakończył się czas na zapis z kamerki ciała.",
          busy = "Nagrywanie jest zajęte.",
          notRecording = "Nagrywanie już zostało zatrzymane."
        }
      },
      waypoint = {
        set = "Punkt nawigacji ustawiony.",
        missing = "Lokalizacja niedostępna."
      },
      errors = {
        load = "Nie można załadować kamer."
      }
    },
    chat = {
      targets = {
        allUnits = "Czat wszystkich jednostek",
        centralDispatch = "Centrum dyspozytorskie"
      },
      header = {
        eyebrowRoom = "Kanał personelu",
        eyebrowPrivate = "Prywatna linia",
        metaRoom = "Pokój",
        metaDirect = "Bezpośrednio",
        metaStaff = "Personel"
      },
      sidebar = {
        eyebrow = "Komunikacja",
        title = "Sieć personelu",
        groupTitle = "Czat grupowy",
        allUnits = "Wszystkie jednostki",
        staffTitle = "Personel",
        loading = "Ładowanie personelu...",
        empty = "Brak dostępnego personelu."
      },
      staff = {
        unknownMember = "Nieznany członek personelu",
        onDuty = "Na służbie",
        offDuty = "Po służbie",
        grade = "Stopień {level}",
        fallback = "Personel"
      },
      composer = {
        placeholderRoom = "Napisać aktualizację jednostki...",
        placeholderDirect = "Wiadomość {name}...",
        pendingAlt = "Oczekujące udostępnienie"
      },
      messages = {
        avatarAlt = "Awatar {name}",
        avatarFallback = "Awatar personelu",
        unknownAuthor = "Nieznany",
        sharedEvidenceAlt = "Udostępnione dowody",
        tapToExpand = "Stuknij, aby rozwinąć"
      },
      preview = {
        ready = "Multimedia gotowe do wysłania"
      },
      profile = {
        action = "Ustawić zdjęcie profilu",
        galleryTitle = "Ustawić zdjęcie profilu",
        gallerySubtitle = "Wybierz zdjęcie do awatara zespołu.",
        photoAlt = "Zdjęcie profilowe",
        selfPhotoAlt = "Zdjęcie profilowe",
        error = "Nie można zaktualizować zdjęcia profilowego."
      },
      actions = {
        remove = "usuń",
        send = "Wyślij"
      },
      state = {
        syncing = "Synchronizacja wiadomości...",
        emptyRoom = "Nie ma jeszcze rozmów.",
        emptyPrivate = "Nie ma jeszcze prywatnych wiadomości.",
        emptyRoomHint = "Bądź pierwszym, który się zaloguje do jednostki.",
        emptyPrivateHint = "Rozpocznij bezpośrednią linę kontaktową z tym pracownikiem."
      },
      errors = {
        load = "Nie można załadować historii czatu.",
        send = "Nie można wysłać wiadomości.",
        members = "Nie można załadować personelu."
      }
    },
    bossMenu = {
      header = {
        eyebrow = "Menu Szefa",
        title = "Zarządzanie",
        balanceLabel = "Saldo"
      },
      state = {
        loading = "Ładowanie danych zarządzania..."
      }
    },
    tabletSettings = {
      header = {
        eyebrow = "Ustawienia tabletu",
        title = "Personalizacja",
        modeLabel = "Tryb",
        modeLight = "Jasny",
        modeDark = "Ciemny"
      },
      appearance = {
        title = "Wygląd",
        description = "Przełącz interfejs między jasnym a ciemnym.",
        light = "Jasny",
        dark = "Ciemny"
      },
      wallpaper = {
        title = "Tapeta",
        description = "Użyj domyślnego tła, wybierz z galerii lub dodaj własny link.",
        labels = {
          default = "Domyślne tło",
          gallery = "Zdjęcie z galerii",
          url = "Niestandardowy URL"
        },
        useDefault = "Użyj domyślnego",
        chooseGallery = "Wybierz z galerii",
        customUrlLabel = "Niestandardowy adres URL obrazu",
        customUrlPlaceholder = "https://example.com/wallpaper.jpg",
        apply = "Zastosuj",
        hint = "Najlepsze wyniki przy obrazach 1920x1080 lub wyższych."
      }
    },
    calendar = {
      weekdays = {
        mon = "Pon",
        tue = "Wt",
        wed = "Śr",
        thu = "Czw",
        fri = "Pi",
        sat = "Sob",
        sun = "Nie"
      },
      selectedDateFallback = "Wybierz datę",
      header = {
        eyebrow = "Wspólny kalendarz",
        title = "Harmonogram personelu",
        metaPrimary = "Widoczny dla wszystkich pracowników",
        metaSecondary = "Każdy może dodawać wpisy",
        hint = "Naciśnij dzień, aby dodać zmianę lub wydarzenie"
      },
      actions = {
        dayEntries = "Wpisy dnia",
        addEntry = "Dodaj wpis"
      },
      today = "Dziś",
      more = "+{count} więcej",
      modal = {
        addEntry = {
          eyebrow = "Dodaj wpis",
          titleLabel = "Tytuł",
          titlePlaceholder = "Zmiana służby, szkolenie, patrol",
          datetimeLabel = "Data i czas",
          colorLabel = "Kolor",
          clear = "Wyczyść",
          submit = "Dodaj do kalendarza"
        },
        dayEntries = {
          eyebrow = "Dni wpisów",
          empty = "Nie ma jeszcze wpisów. Dodaj briefing lub patrol do udostępnienia jednostce."
        }
      }
    },
    calculator = {
      header = {
        eyebrow = "Narzędzia terenowe",
        title = "Kalkulator",
        modeLabel = "Tryb"
      },
      keys = {
        clearAll = "Wyłącznik",
        clearEntry = "Wyczyścić wpis"
      },
      mode = {
        standard = "Standardowy"
      },
      status = {
        resetRequired = "Wymagane resetowanie",
        ready = "Gotowy"
      },
      errors = {
        error = "Błąd"
      }
    },
    tabletHome = {
      status = {
        defaultDate = "Poniedziałek, 01 stycznia"
      },
      calendar = {
        eventToday = "Wydarzenie dziś",
        eventTomorrow = "Wydarzenie jutro",
        allDay = "Cały dzień",
        timeAt = " o {time}"
      },
      chat = {
        messageFrom = "Wiadomość od {name}",
        newMessage = "Nowa wiadomość",
        authorFallback = "Personel",
        messageBody = "{author}: {message}",
        sentPhoto = "{author} wysłał zdjęcie.",
        sentMessage = "{author} wysłał wiadomość."
      },
      notifications = {
        title = "Powiadomienia",
        clearAll = "Wyczyść wszystko",
        empty = "Wszystko na bieżąco."
      }
    },
    map = {
      eyebrow = "Mapa deska",
      title = "Siatka San Andreas",
      markerLabel = "Znacznik",
      markerTypes = {
        label = "Lista znaczników",
        dispatch = "Wysyłka",
        officers = "Personel",
        speedcams = "Radary prędkości",
        vehicles = "Pojazdy",
        trackers = "Trackery"
      },
      markerList = {
        listed = "wymienione",
        officersTitle = "Grafik personelu",
        speedcamsTitle = "Tablica radarów prędkości",
        vehiclesTitle = "Tablica pojazdów",
        trackersTitle = "Tablica trackerów",
        officersEmpty = "Brak personelu na służbie.",
        speedcamsEmpty = "Brak dostępnych radarów prędkości.",
        trackersEmpty = "Brak trackerów online.",
        vehiclesEmpty = "Brak pojazdów online."
      },
      dispatch = {
        title = "Tablica dyspozycji",
        empty = "Brak dyspozycji w tej chwili.",
        status = {
          active = "Aktywne",
          accepted = "Zaakceptowane",
          done = "Zakończone"
        },
        panelTitle = "Szczegóły dyspozycji",
        statusLabel = "Status",
        acceptedBy = "Zaakceptowane przez",
        doneBy = "Zakończone przez",
        coords = "Współrzędne",
        actions = {
          accept = "Akceptuj",
          done = "Oznacz jako zakończone",
          delete = "Usuń"
        },
        unknown = "Nieznany"
      },
      status = {
        available = "Dostępny",
        busy = "Zajęty",
        pursuit = "W pościgu",
        offDuty = "Na urlopie"
      },
      vehicle = {
        status = {
          active = "Aktywne",
          offline = "Poza siecią"
        }
      },
      tracker = {
        status = {
          active = "Aktywne",
          offline = "Poza siecią"
        }
      },
      speedcam = {
        status = {
          online = "Online",
          maintenance = "Serwis",
          offline = "Poza siecią"
        }
      },
      officerPanel = {
        title = "Szczegóły personelu",
        callsign = "Wywołanie {id}",
        rank = "Ranga",
        health = "Zdrowie",
        coords = "Współrzędne",
        lastUpdateUnknown = "Przed chwilą"
      },
      speedcamPanel = {
        title = "Szczegóły fotoradaru prędkości",
        limit = "Limit",
        tolerance = "Tolerancja",
        health = "Zdrowie",
        coords = "Współrzędne"
      },
      vehiclePanel = {
        title = "Szczegóły pojazdu",
        plate = "Tablica {plate}",
        netId = "ID sieci",
        health = "Zdrowie",
        coords = "Współrzędne"
      },
      trackerPanel = {
        title = "Szczegóły tracker'a",
        plate = "Tablica {plate}",
        attachedBy = "Przyczepione przez",
        attachedAt = "Przyczepione",
        netId = "ID sieci",
        status = "Stan",
        coords = "Współrzędne"
      },
      actions = {
        openCctv = "Otwórz CCTV",
        setWaypoint = "Ustaw punkt"
      },
      waypoint = {
        set = "Punkt nawigacji ustawiony.",
        missing = "Lokalizacja niedostępna."
      },
      signalLost = "Utracono sygnał",
      styles = {
        atlas = "Atlas",
        roads = "Drogi",
        satellite = "Satelita"
      },
      missing = {
        title = "Brak obrazu mapy",
        body = "Umieść obrazy mapy w frontend/public/img."
      },
      details = {
        title = "Szczegóły",
        empty = "Wybierz znacznik, aby zobaczyć szczegóły."
      },
      zones = {
        title = "Strefy wykluczenia",
        untitled = "Strefa bez nazwy",
        hint = "Kliknij mapę, aby dodać punkty. Minimum 3.",
        pointCount = "{count} punktów",
        empty = "Brak stref wykluczenia jeszcze.",
        actions = {
          toggle = "Strefy",
          new = "Nowa strefa",
          cancel = "Anuluj",
          save = "Zapisz strefę",
          undo = "Cofnij",
          clear = "Wyczyść",
          delete = "Usuń"
        },
        modal = {
          title = "Nazwij strefę wykluczenia",
          confirm = "Zapisz strefę"
        },
        errors = {
          points = "Dodaj co najmniej 3 punkty.",
          nameRequired = "Wprowadź nazwę strefy.",
          saveFailed = "Nie można zapisać strefy wykluczenia.",
          deleteFailed = "Nie można usunąć strefy wykluczenia."
        }
      },
      monitorZones = {
        title = "Strefy zegara na kostkę",
        untitled = "Strefa bez nazwy",
        hint = "Kliknij mapę, aby dodać punkty. Minimum 3.",
        pointCount = "{count} punktów",
        empty = "Brak stref monitorowania jeszcze.",
        mode = {
          allow = "Strefa dozwolona",
          exclude = "Strefa ograniczona"
        },
        actions = {
          allow = "Strefa dozwolona",
          exclude = "Strefa ograniczona",
          cancel = "Anuluj",
          save = "Zapisz strefę",
          undo = "Cofnij",
          clear = "Wyczyść",
          delete = "Usuń"
        },
        modal = {
          title = "Nazwij strefę monitorowania",
          confirm = "Zapisz strefę"
        },
        errors = {
          points = "Dodaj co najmniej 3 punkty.",
          nameRequired = "Wprowadź nazwę strefy.",
          noMonitor = "Wybierz zegar na kostkę.",
          saveFailed = "Nie można zapisać strefy monitorowania.",
          deleteFailed = "Nie można usunąć strefy monitorowania."
        }
      },
      panic = {
        panelTitle = "Szczegóły paniki",
        triggeredBy = "Wywołane przez",
        createdAt = "Wywołane",
        coords = "Współrzędne"
      },
      dev = {
        officerName = "Zespół Avery Lane",
        callsign = "LIN-23",
        rank = "Sierżant",
        unit = "Centralny patrol",
        speedcamName = "Kamera prędkości Del Perro",
        vehicleName = "Jednostka 12",
        trackerName = "Tracker ALPHA",
        trackerOfficer = "Funkcjonariusz Ruiz",
        dispatchTitle = "Uszkodzona kamera prędkości",
        dispatchMessage = "Jednostka Del Perro wymaga konserwacji.",
        panicOfficer = "Funkcjonariusz Sinclair",
        panicLocation = "Mission Row"
      }
    },
    panicNotification = {
      badge = "Panika",
      title = "Alarm paniki",
      subtitle = "{name} nacisnął przycisk paniki.",
      callsign = "Znak wywoławczy {id}",
      locationLabel = "Lokalizacja",
      locationUnknown = "Nieznana lokalizacja",
      hint = "Naciśnij {key}, aby ustawić punkt nawigacyjny na mapie w grze."
    },
    incidentNotification = {
      panic = {
        title = "Alarm paniki",
        subtitle = "{name} nacisnąć przycisk alarmowy."
      },
      dispatch = {
        title = "Powiadomić dyspozytora",
        subtitle = "{name} udostępnić nowe zgłoszenie."
      },
      ping = {
        title = "Pingować lokalizację",
        subtitle = "{name} udostępnić ping na żywo lokalizacji."
      },
      actions = {
        openMap = {
          key = "M",
          label = "Zobaczyć w Tablet Map App"
        },
        setWaypoint = {
          key = "G",
          label = "Ustawić punkt nawigacyjny."
        },
        dismiss = {
          key = "Backspace",
          label = "Odrzucić"
        }
      }
    },
    gradeChange = {
      promotedTitle = "Awans",
      demotedTitle = "Degradacja",
      unchangedTitle = "Ranga zaktualizowana",
      previousLabel = "Poprzednia ranga",
      newLabel = "Obecna ranga",
      unknownLabel = "Nieprzypisana ranga",
      levelFallback = "Poziom {level}"
    },
    employeeGpsJammer = {
      title = "Zagłuszacz GPS",
      disabled = "Zagłuszanie GPS jest niedostępne.",
      success = "Sygnał GPS pracownika zakłócony.",
      failed = "Nie udało się zakłócić sygnału GPS.",
      targetJammed = "Twój sygnał GPS służby jest zakłócany.",
      errors = {
        disabled = "Zagłuszanie GPS jest niedostępne.",
        no_players = "Brak osoby w pobliżu.",
        too_far = "Zbliż się przed użyciem zagłuszacza GPS.",
        invalid_target = "Nie można odnaleźć tej osoby.",
        not_on_duty = "Nie znaleziono aktywnego sygnału GPS służby na tej osobie.",
        protected_job = "Ten sygnał GPS pracownika jest chroniony.",
        missing_item = "Potrzebujesz zagłuszacza GPS, aby to zrobić.",
        cooldown = "Poczekaj chwilę przed ponownym użyciem zagłuszacza GPS.",
        failed = "Nie udało się zakłócić sygnału GPS.",
      },
    },
    bonusNotification = {
      title = "Premia przyznana",
      subtitle = "Od {name}",
      amountLabel = "Premia",
      unknownManager = "Zarządzenie"
    },
    wheelClamp = {
      attached = "Załączony jest blokada kół"
    },
    search = {
      previewTitle = "Szukaj {name}",
      previewSubtitle = "Skanowanie rzeczy osobistych pod kątem broni i kontrabandy...",
      previewCancel = "Naciśnij X, aby anulować",
      unknownTarget = "Nieznane"
    },
    heliCamHud = {
      title = "Sterowanie kamerą w helikopterze",
      actions = {
        toggleCam = "Przełączenie kamery",
        vision = "Przełączenie widoku",
        spotlight = "Tryb reflektora",
        lockTarget = "Zablokuj cel",
        display = "Przełączanie wyświetlania",
        takePhoto = "Zrób zdjęcie",
        rappel = "Zejście na linie",
        brightness = "Jasność",
        radius = "Promień"
      }
    },
    jailHud = {
      title = "Pozostały czas",
      trashLabel = "Śmieci",
      trashFull = "Torba pełna",
      trashDropoff = "Dostarcz do kontenera na śmieci"
    },
    jailJobs = {
      title = "Prace w więzieniu",
      subtitle = "Wybrać zadanie do spędzenia czasu.",
      actions = {
        cleaning = "Sprzątanie",
        gardening = "Ogród",
        carry_goods = "Nosić towary"
      },
      currentJob = "Aktualne zadanie:",
      stop = "Przerwać zadanie",
      close = "Zamknij",
      contraband = {
        title = "Kontrabanda",
        message = "Znalazłeś {item}. Czy ryzykować i zatrzymać, czy wyrzucić?",
        keep = "Zatrzymać",
        toss = "Wyrzucić"
      },
      boxInspect = {
        title = "Sprawdzić pudełko",
        message = "Wewnątrz znajdziesz {item}. {description}",
        take = "Zabierz to",
        leave = "Zostaw to w środku",
        close = "Zamknij"
      }
    },
    socialWork = {
      eyebrow = "Praca społeczna",
      title = "Praca społeczna",
      listed = "wymienione",
      search = {
        placeholder = "Szukaj według nazwy lub id"
      },
      filters = {
        all = "Wszystkie",
        label = "Status",
        placeholder = "Status"
      },
      actions = {
        refresh = "Odśwież",
        back = "Powrót do listy"
      },
      state = {
        loading = "Ładowanie pracy społecznej...",
        empty = "Brak zgodnych z filtrami usług społecznych."
      },
      status = {
        active = "Aktywne",
        overdue = "Przeterminowane",
        completed = "Zakończone",
        imprisoned = "Uwięzione"
      },
      labels = {
        remainingShort = "pozostało",
        imprison = "Uwięzić",
        imprisonNotice = "Minął termin. Wymagana kara więzienia.",
        noDeadline = "Brak terminu",
        expired = "Wygasłe"
      },
      sections = {
        summary = "Podsumowanie usługi",
        summarySubtitle = "Przegląd przypisanych zadań."
      },
      fields = {
        name = "Nazwa",
        status = "Status",
        remaining = "Pozostałe zadania",
        completed = "Zakończone zadania",
        total = "Wszystkie zadania",
        assigned = "Przypisano",
        deadline = "Termin",
        timeLeft = "Pozostały czas",
        assignedBy = "Przypisane przez",
        unknown = "Nieznane"
      },
      assign = {
        title = "Przydziel pracę społeczną",
        subtitle = "Wyślij pobliskiego gracza do zadań społecznych.",
        playerLabel = "Gracz",
        playerPlaceholder = "Wybrać gracza",
        taskLabel = "Zadania",
        taskPlaceholder = "Liczba zadań",
        deadlineLabel = "Limit czasowy (minuty)",
        deadlinePlaceholder = "Opcjonalnie",
        submit = "Przydzielić",
        success = "Praca społeczna przypisana.",
        error = "Nie można przypisać pracy społecznej."
      },
      errors = {
        load = "Nie można załadować pracy społecznej."
      },
      date = {
        unknown = "Nieznany"
      },
      jobs = {
        title = "Praca społeczna",
        subtitle = "Wybrać zadanie, aby dokończyć zdanie.",
        currentJob = "Aktualne zadanie:",
        stop = "Zatrzymać zadanie",
        actions = {
          cleaning = "Sprzątanie",
          carry_goods = "Przenosić towary"
        }
      },
      hud = {
        title = "Praca społeczna",
        remaining = "Pozostałych zadań",
        completed = "Zadania ukończone",
        deadline = "Pozostały czas",
        expired = "Wygasło",
        trashLabel = "Śmieci",
        trashFull = "Pełny worek",
        trashDropoff = "Dostarcz do kontenera na śmieci"
      }
    },
    socialWorkCreator = {
      title = "Twórca prac społecznych",
      description = "Skonfiguruj miejsca usług społecznych w mieście.",
      empty = "Jeszcze nie skonfigurowano miejsc prac społecznych.",
      keyboardHint = "Użyj klawiszy strzałek, aby poruszać się po liście i wykonywać akcje.",
      editTitle = "Znaczniki prac społecznych",
      editSubtitle = "Użyj przycisku pinezki na mapie, aby zapamiętać swoje bieżące współrzędne.",
      editKeyboardHint = "Użyj klawiszy strzałek, aby wybrać znacznik, lewy/prawy, aby wybrać Ustaw/Wyczyść, Enter, aby go uruchomić, Backspace, aby wrócić.",
      missingEntry = "Nie znaleziono miejsca pracy społecznej.",
      actions = {
        newSite = "Nowa Lokalizacja"
      },
      status = {
        set = "Ustaw",
        unset = "Wyczyść"
      },
      markers = {
        social_work_job_npc = "NPC pracy",
        social_work_dumpster = "Śmietnik",
        social_work_box_dropoff = "Przenośnik oddawczy"
      },
      modals = {
        createTitle = "Utwórz miejsce",
        createButton = "Utwórz miejsce",
        renameTitle = "Zmień nazwę miejsca",
        renameButton = "Zapisz nazwę",
        deleteTitle = "Usuń miejsce",
        deleteMessage = "Czy na pewno chcesz usunąć {name}?",
        deleteConfirmLabel = "Usuń",
        deleteCancelLabel = "Anuluj"
      }
    },
    impoundCreator = {
      title = "Twórca przechowalni",
      description = "Skonfiguruj lokalizacje parkingów i punkty pojawienia się pojazdów.",
      empty = "Jeszcze nie skonfigurowano parkingów.",
      keyboardHint = "Użyj klawiszy strzałek, aby nawigować po liście i akcjach.",
      editTitle = "Znaczniki na parkingu",
      editSubtitle = "Użyj przycisku pinezki na mapie, aby zapisać swoje aktualne współrzędne.",
      editKeyboardHint = "Użyj klawiszy strzałek, aby wybrać znacznik, lewy/prawy aby wybrać Ustaw/Wyczyść/Usuń, Enter, aby go uruchomić, Backspace, aby wrócić. Przejdź poza listę, aby dotrzeć do przycisków Dodaj.",
      missingEntry = "Brak parkingu na liście.",
      actions = {
        newLot = "Nowy parking",
        add = {
          impound_delivery = "Dodaj odstawianie",
          impound_spawn = "Dodaj spawn"
        }
      },
      status = {
        set = "Ustaw",
        unset = "Anuluj ustawianie"
      },
      markers = {
        impound_lot = "Parking",
        impound_spawn = "Spawn na parkingu",
        impound_delivery = "Odstawianie na parkingu"
      },
      modals = {
        createTitle = "Utwórz parking",
        createButton = "Utwórz parking",
        renameTitle = "Zmień nazwę parkingu",
        renameButton = "Zapisz nazwę",
        deleteTitle = "Usuń parking",
        deleteMessage = "Czy na pewno chcesz usunąć {name}?",
        deleteConfirmLabel = "Usuń",
        deleteCancelLabel = "Anuluj"
      }
    },
    impoundStorage = {
      title = "Magazyn parkingowy",
      subtitle = "Zamów pojazdy do dostawy na parking.",
      empty = "Brak zapasowanych pojazdów na tym parkingu.",
      emptyAll = "Nie znaleziono żadnych zarekwirowanych pojazdów.",
      unknownModel = "Nieznany",
      unknownLot = "Nieznany",
      sections = {
        impounds = "Aktywne zarekwirowania",
        stored = "Zapaszone pojazdy"
      },
      columns = {
        plate = "Tablica rejestracyjna",
        model = "Model",
        stored = "Zapaszone",
        lot = "Parking",
        status = "Status",
        fee = "Opłata za przechowywanie"
      },
      actions = {
        deliver = "Zamów dostawę",
        allowPickup = "Zezwól na odbiór",
        seize = "Zaznacz zajęcie",
        seized = "Zajęte",
        close = "Zamknij",
        refresh = "Odśwież"
      },
      status = {
        pickup = "Dozwolony odbiór",
        seized = "Zajęte"
      },
      time = {
        days = "{count} dzień(e)"
      },
      errors = {
        load = "Nie można załadować zapasowanych pojazdów.",
        deliver = "Nie można zamówić dostawy.",
        seized = "Ten pojazd jest zajęty do celów śledztwa.",
        update = "Nie można zaktualizować statusu parkingu."
      }
    },
    impoundDecision = {
      title = "Decyzja parkingowa",
      message = "Zdecyduj, czy {vehicle} może zostać odebrany lub zajęty do celów śledztwa.",
      vehicleFallback = "chciałbyś korzystać z tego pojazdu",
      allowPickup = "zezwolić na odbiór",
      seize = "zabezpieczyć do dochodzenia"
    },
    jailCreator = {
      title = "Twórca aresztu",
      description = "Umieścić punkty odrodzenia aresztu i zarządzać lokalizacjami.",
      empty = "Nie skonfigurowano jeszcze aresztów.",
      keyboardHint = "Użyj klawiszy strzałek, aby nawigować po liście i akcjach.",
      editTitle = "Znaki aresztu",
      editSubtitle = "Użyj przycisku pinezki mapy, aby zapisać swoje aktualne współrzędne.",
      editKeyboardHint = "Użyj klawiszy strzałek, aby wybrać znacznik, lewy/prawy, aby wybrać Ustaw/Wyczyść/Usuń, Enter, aby go uruchomić, Backspace, aby wrócić. Przesuń się poza listą, aby dotrzeć do przycisków Dodaj.",
      missingEntry = "Nie znaleziono aresztu.",
      actions = {
        newJail = "Nowy areszt"
      },
      modals = {
        createTitle = "Utwórz areszt",
        createButton = "Utwórz areszt",
        renameTitle = "Zmień nazwę aresztu",
        renameButton = "Zapisz nazwę",
        deleteTitle = "Usuń areszt",
        deleteMessage = "Czy na pewno chcesz usunąć {nazwa}?",
        deleteConfirmLabel = "Usuń",
        deleteCancelLabel = "Anuluj"
      }
    },
    jailInmates = {
      title = "Handel więźniem",
      close = "Zamknij",
      trade = "Dokonać wymiany",
      requiredLabel = "Dajesz",
      rewardLabel = "Dostajesz",
      acceptedLabel = "Akceptuje",
      contrabandLabel = "Kontrabanda",
      npc = {
        alcoholic = "Barman w bloku cel",
        drugDealer = "Dealer w pralni",
        doctor = "Lekarz więzienny",
        canteen = "Kuchnia kantynowa"
      },
      dialogs = {
        alcoholic = {
          one = "Raz wymieniłem deser na mopa. To był najlepszy dzień mojego życia.",
          two = "Gdyby w tym miejscu był bar, byłbym pracownikiem miesiąca.",
          three = "Masz coś pachnącego jak czyste podłogi i złe decyzje?",
          four = "Nazywam to woń więzienną. Ty nazywasz to alkohol do sprzątania."
        },
        drugDealer = {
          one = "Masz coś ostrzegającego z kosza? Płacę w papierosach.",
          two = "Ucisz głos, strażnicy myślą, że jestem klubem książki.",
          three = "Przynieś mi kontrabandę, a ja uczynię twój dzień palnym.",
          four = "Kosz skrywa skarby. Jestem rzeczoznawcą skarbów."
        },
        doctor = {
          one = "Trzymaj się. To będzie szybkie.",
          two = "Dziś bez opłat. Po prostu trzymaj się z dala od problemów.",
          three = "Wyglądasz na zmęczonego. Pozwól, że cię naprawię.",
          four = "Godziny kliniki nigdy się nie kończą tutaj."
        },
        canteen = {
          one = "Świeży talerz dzisiaj. Ustaw się w kolejce i ruszaj dalej.",
          two = "Chcesz gorący posiłek czy wykład?",
          three = "Dobre zachowanie daje drugą porcję. W większości przypadków.",
          four = "Widziałem gorsze apetyty."
        }
      },
      doctor = {
        costLabel = "Koszt",
        rewardLabel = "Leczenie",
        actionLabel = "Uzyskać leczenie",
        costValue = "Dołożyć",
        rewardValue = "Pełne leczenie"
      },
      canteen = {
        costLabel = "Koszt",
        rewardLabel = "Posiłek",
        actionLabel = "Odebrać posiłek",
        costValue = "Bezpłatne",
        rewardValue = "Pakiet żywności"
      },
      items = {
        cleaning_alcohol = "Alkohol do dezynfekcji",
        cigarettes = "Papierosy",
        coke = "Kokaina",
        weed = "Marihuana",
        burger = "Menu",
        water = "Woda"
      }
    },
    invites = {
      title = "Zaproszenie do pracy",
      description = "Dołączyć do {job} jako {role}?",
      invitedBy = "Zaproszono przez {name}",
      expires = "Ta oferta wygaśnie wkrótce.",
      accept = "Akceptować",
      decline = "Odrzucić",
      errors = {
        missing = "Zaproszenie niedostępne.",
        failed = "Nie udało się odpowiedzieć na zaproszenie."
      }
    },
    stationCreator = {
      title = "Twórca stacji",
      description = "Ustawić pozycje znaczników stacji.",
      empty = "Brak skonfigurowanych stacji.",
      keyboardHint = "Użyj ↑/↓ aby wybrać, ←/→ aby zmienić akcje, Enter aby potwierdzić, Backspace aby zamknąć.",
      editTitle = "Znaczniki stacji",
      editSubtitle = "Użyj przycisku pinezki na mapie, aby zapisać swoje bieżące współrzędne.",
      editKeyboardHint = "Użyj ↑/↓ aby wybrać znacznik, ←/→ aby wybrać Ustaw/Usuń/Kasuj, Enter aby uruchomić, Backspace aby wrócić.",
      sections = {
        markers = "Znaczniki",
        zone = "Strefa więzienna"
      },
      zone = {
        subtitle = "Dodaj punkty strefy, aby zdefiniować granice więzienia.",
        hint = "Użyj przycisku pinezki na mapie, aby dodać punkty. Usuń punkty ikoną kosza.",
        empty = "Brak punktów strefy.",
        pointLabel = "Punkt strefy {index}",
        actions = {
          add = "Dodaj punkt strefy",
          update = "Aktualizuj",
          clear = "Wyczyść strefę"
        }
      },
      missingStation = "Nie znaleziono stacji.",
      actions = {
        newStation = "Nowa stacja",
        editJobBlip = "Edytuj znacznik pracy",
        newJail = "Nowe więzienie",
        add = {
          wardrobe = "Dodaj znacznik szafy garderobowej",
          garage_vehicle_menu = "Dodaj interakcję z garażem pojazdów",
          garage_vehicle_spawn = "Dodaj spawn pojazdu w garażu",
          garage_vehicle_park = "Dodaj parkowanie pojazdów w garażu",
          garage_helicopter_menu = "Dodaj interakcję z helipadem",
          garage_helicopter_spawn = "Dodaj spawn helikoptera",
          garage_helicopter_park = "Dodaj parkowanie helikoptera",
          garage_boat_menu = "Dodać interakcję z pomostem",
          garage_boat_spawn = "Dodać punkt pojawiania się na pomoście",
          garage_boat_park = "Dodać miejsce postoju na pomoście",
          boss_menu = "Dodaj znacznik menu szefa",
          wholesale_shop = "Dodaj znacznik sklepu hurtowego",
          duty_terminal = "Dodaj znacznik terminala służbowego",
          public_forms = "Dodaj publiczny stoiska z formularzami",
          jail_solitary_cell = "Dodaj samotną celę"
        }
      },
      status = {
        set = "Ustawić",
        unset = "Cofnąć ustawienie"
      },
      markers = {
        position = "Pozycja posterunku",
        storage = "Magazyn",
        locker = "Szafka",
        wardrobe = "Szafa",
        duty_terminal = "Terminal służbowy",
        public_forms = "Publiczna forma kiosku",
        boss_menu = "Menu szefa",
        garage_vehicle_menu = "Interakcja z garażem pojazdów",
        garage_vehicle_spawn = "Spawn pojazdów w garażu",
        garage_vehicle_park = "Parkowanie pojazdów w garażu",
        garage_helicopter_menu = "Interakcja z lądowiskiem helikopterów",
        garage_helicopter_spawn = "Spawn helikoptera na lądowisku",
        garage_helicopter_park = "Parkowanie helikoptera na lądowisku",
        garage_boat_menu = "interakcjonować z dokiem",
        garage_boat_spawn = "pojawiać się na doku",
        garage_boat_park = "parkować na doku",
        wholesale_shop = "Sklep hurtowy",
        jail_spawn = "Spawn więzienia",
        jail_release = "Punkt zwolnienia",
        jail_menu = "Terminal więzienny",
        jail_job_npc = "NPC prace więzienia",
        jail_inmate_alcoholic = "Więzień: Alkoholik",
        jail_inmate_drugdealer = "Więzień: Diler narkotyków",
        jail_inmate_doctor = "Więzień: Lekarz",
        jail_canteen_cook = "Kucharz kantyny",
        jail_dumpster = "Śmieciarka więzienna",
        jail_box_dropoff = "Drop-off przenoszenia",
        jail_electric_box = "Skrzynia elektryczna",
        jail_fence_cut = "Miejsce cięcia ogrodzenia",
        jail_fence_exit = "Wyjście z ogrodzenia",
        jail_solitary_cell = "Pojedyncza cela",
        jail_confiscated_return = "Skonfiskowane przedmioty"
      },
      modals = {
        createTitle = "Utwórz stację",
        createButton = "Utwórz stację",
        renameTitle = "Zmień nazwę stacji",
        renameButton = "Zapisz nazwę",
        deleteTitle = "Usuń stację",
        deleteMessage = "Czy na pewno chcesz usunąć {name}?",
        deleteConfirmLabel = "Usuń",
        deleteCancelLabel = "Anuluj",
        jobBlipTitle = "Znacznik pracy: {job}",
        jobBlipMessage = "Skonfiguruj znacznik posterunku dla tej pracy. Wyłącz, jeśli ta praca nie powinna mieć znacznika.",
        jobBlipSave = "Zapisz znacznik",
        jobBlipReset = "Resetuj",
        jobBlipInvalidNumber = "Nieprawidłowa wartość dla {field}."
      },
      blip = {
        enabled = "Pokaż znacznik",
        useStationName = "Dołącz nazwę posterunku",
        shortRange = "Krótki zasięg",
        name = "Etykieta",
        sprite = "Ikona",
        color = "Kolor",
        scale = "Rozmiar",
        display = "Wyświetlanie"
      }
    },
    jailAssign = {
      title = "Wyślij do więzienia",
      selectPlayer = "Wybierz gracza",
      selectPlayerPlaceholder = "Wybierz gracza",
      selectJail = "Wybierz więzienie",
      selectJailPlaceholder = "Wybierz lokalizację więzienia",
      solitaryLabel = "Izolacja",
      solitaryUnavailable = "Brak skonfigurowanych cel izolacyjnych dla tego więzienia.",
      durationLabel = "Czas trwania (miesiące)",
      monthHint = "1 miesiąc = {minutes} minut",
      cancelButton = "Anuluj",
      assignButton = "Wysłać do więzienia",
      assigning = "Wysyłanie do więzienia...",
      noPlayers = "Brak pobliskich graczy w odległości {range} m.",
      noJails = "Jeszcze nie skonfigurowano więzień. Najpierw użyj kreatora więzień.",
      spawnMissing = "Ten więzień nie ma ustawionego spawn.",
      jailStatusReady = "Gotowe do pojawienia się",
      jailStatusMissing = "Nie ustawiono spawnu",
      success = "Gracz wysłany do więzienia na {months} miesięcy.",
      errors = {
        invalid_target = "Wybierz pobliskiego gracza i więzienie.",
        spawn_not_set = "Ten więzień nie ma ustawionego spawnu.",
        solitary_unavailable = "Brak pojedynczych cel śledczych skonfigurowanych dla tego więzienia.",
        failed = "Nie udało się wysłać gracza do więzienia."
      }
    },
    bolos = {
      eyebrow = "Tablica BOLO",
      title = "BOLOs",
      listed = "wymienione",
      unknown = "Nieznany",
      search = {
        placeholder = "Wyszukaj BOLO według tytułu, id, typu lub tagu"
      },
      actions = {
        refresh = "Odśwież",
        manageTypes = "Zarządzaj typami",
        new = "Nowy BOLO",
        back = "Wróć do listy",
        add = "Dodaj",
        addPhoto = "Dodaj zdjęcie",
        remove = "Usuń"
      },
      state = {
        loading = "Ładowanie BOLOs...",
        empty = "Nie znaleziono BOLO pasujących do bieżących filtrów.",
        saving = "Zapisuję...",
        noTags = "Brak przypisanych tagów.",
        noReports = "Brak jeszcze powiązanych raportów."
      },
      detail = {
        summary = "Podsumowanie BOLO",
        untitled = "Nienazwany BOLO"
      },
      fields = {
        title = "Tytuł BOLO",
        id = "ID BOLO",
        type = "Typ",
        status = "Status",
        priority = "Priorytet",
        created = "Utworzono",
        updated = "Ostatnia aktualizacja"
      },
      placeholders = {
        title = "Tytuł BOLO",
        id = "Automatycznie generowany, jeśli puste",
        type = "Wybierz typ",
        description = "Dodaj opis...",
        tag = "Dodaj tag",
        reportSelect = "Wybierz raport"
      },
      sections = {
        description = "Opis",
        descriptionSubtitle = "Złap szczegóły i instrukcje.",
        tags = "Tagi",
        tagsSubtitle = "Dodaj szybkie identyfikatory dla BOLO.",
        reports = "Powiązane raporty",
        reportsSubtitle = "Dołącz powiązane pliki raportów.",
        gallery = "Galeria",
        gallerySubtitle = "Dołączyć zdjęcia z galerii do BOLO."
      },
      gallery = {
        title = "Wybrać zdjęcie",
        subtitle = "Wybrać zdjęcie z galerii do dołączenia do BOLO.",
        loading = "Ładowanie galerii...",
        empty = "Brak dostępnych zdjęć w galerii.",
        photoAlt = "Zdjęcie z galerii"
      },
      typesModal = {
        title = "Typy BOLO",
        subtitle = "Dodaj lub usuń typy BOLO dla tego urządzenia.",
        placeholder = "Dodać typ BOLO",
        empty = "Brak skonfigurowanych typów BOLO."
      },
      types = {
        person = "Osoba",
        vehicle = "Pojazd",
        property = "Mienie",
        missing = "Zaginione",
        other = "Inne"
      },
      status = {
        active = "Aktywny",
        located = "Zlokalizowany",
        closed = "Zamknięty",
        cancelled = "Anulowany"
      },
      priority = {
        low = "Niski",
        medium = "Średni",
        high = "Wysoki",
        critical = "Krytyczny"
      },
      errors = {
        load = "Nie można załadować BOLO.",
        save = "Nie można zapisać BOLO.",
        titleRequired = "Wprowadź tytuł BOLO przed zapisaniem.",
        typeRequired = "Wybierz typ BOLO przed zapisaniem.",
        gallery = "Nie można załadować galerii."
      }
    },
    warrants = {
      eyebrow = "Warta nakazu",
      title = "Nakazy",
      listed = "wymienione",
      unknown = "Nieznany",
      search = {
        placeholder = "Wyszukaj nakazy według tytułu, id, typu lub tagu"
      },
      actions = {
        refresh = "Odśwież",
        manageTypes = "Zarządzaj typami",
        new = "Nowy nakaz",
        back = "Powrót do listy",
        add = "Dodaj",
        addPhoto = "Dodaj zdjęcie",
        remove = "Usuń"
      },
      state = {
        loading = "Ładowanie nakazów...",
        empty = "Brak nakazów pasujących do obecnych filtrów.",
        saving = "Zapisywanie...",
        noTags = "Brak przypisanych tagów.",
        noReports = "Brak powiązanych raportów jeszcze.",
        noOffences = "Brak powiązanych wykroczeń jeszcze."
      },
      detail = {
        summary = "Podsumowanie nakazu",
        untitled = "Nie zatytułowany nakaz"
      },
      fields = {
        title = "Tytuł nakazu",
        id = "Identyfikator nakazu",
        type = "Rodzaj",
        status = "Status",
        priority = "Priorytet",
        created = "Utworzono",
        updated = "Ostatnia aktualizacja"
      },
      placeholders = {
        title = "Tytuł nakazu",
        id = "Generowany automatycznie, jeśli puste",
        type = "Wybierz rodzaj",
        description = "Dodaj opis...",
        tag = "Dodaj tag",
        reportSelect = "Wybierz raport",
        offenceSelect = "Wybierz wykroczenie"
      },
      sections = {
        description = "Opis",
        descriptionSubtitle = "Złap podsumowanie i instrukcje.",
        tags = "Tagi",
        tagsSubtitle = "Dołącz szybkie identyfikatory dla nakazu.",
        reports = "Powiązane raporty",
        reportsSubtitle = "Dołącz powiązane pliki raportów.",
        offences = "Wykroczenia",
        offencesSubtitle = "Powiąż wykroczenia z tym nakazem.",
        gallery = "Galeria",
        gallerySubtitle = "Dołącz zdjęcia z galerii do nakazu."
      },
      gallery = {
        title = "Wybierz zdjęcie",
        subtitle = "Wybierz zdjęcie z galerii do dołączenia do nakazu.",
        loading = "Wczytywanie galerii...",
        empty = "Brak dostępnych zdjęć galerii.",
        photoAlt = "Zdjęcie z galerii"
      },
      typesModal = {
        title = "Rodzaje nakazów",
        subtitle = "Dodaj lub usuń rodzaje nakazów dla tego urządzenia.",
        placeholder = "Dodaj rodzaj nakazu",
        empty = "Brak skonfigurowanych rodzajów nakazów."
      },
      types = {
        arrest = "Areszt",
        search = "Szukaj",
        bench = "Miejsce tymczasowego zatrzymania",
        probation = " Probacja"
      },
      status = {
        active = "Aktywny",
        served = "Wysłane",
        expired = "Wygasłe",
        cancelled = "Anulowane"
      },
      priority = {
        low = "Niski",
        medium = "Średni",
        high = "Wysoki",
        critical = "Krytyczny"
      },
      errors = {
        load = "Nie można załadować nakazów.",
        save = "Nie można zapisać nakazu.",
        titleRequired = "Wprowadź tytuł nakazu przed zapisaniem.",
        typeRequired = "Wybierz rodzaj nakazu przed zapisaniem.",
        gallery = "Nie można załadować galerii."
      }
    },
    prison = {
      eyebrow = "Dziennik zatrzymań",
      title = "Więzienie",
      listed = "na liście",
      search = {
        placeholder = "wyszukiwać po nazwie lub id"
      },
      filters = {
        all = "Wszystkie",
        label = "Status",
        placeholder = "wybrać status"
      },
      actions = {
        refresh = "Odśwież",
        back = "Powrót do listy",
        saveDuration = "Zapisz czas trwania",
        minusMinutes = "-15 min",
        minusSmall = "-5 min",
        plusSmall = "+5 min",
        plusMinutes = "+15 min",
        saveNotes = "Zapisz notatki",
        saveWarrant = "Połącz nakaz aresztowania",
        addOffence = "Dodaj przestępstwo",
        setSolitary = "Prześlę do izolatki",
        setGeneral = "Wróć do ogólnej"
      },
      state = {
        loading = "Wczytywanie więźniów...",
        empty = "Brak więźniów pasujących do obecnych filtrów.",
        saving = "Zapisuję...",
        noOffences = "Brak jeszcze powiązanych przestępstw."
      },
      labels = {
        mugshot = " Zdjęcie profilowe"
      },
      detail = {
        summary = "Podsumowanie więźnia"
      },
      fields = {
        booked = "Zarejestrowany",
        remaining = "Pozostały czas",
        identifier = "Identyfikator",
        unknown = "Nieznany",
        remainingMinutes = "Pozostałe minuty",
        warrant = "Nakaz aresztowania",
        offences = "Przestępstwa",
        housing = "Zakwaterowanie"
      },
      sections = {
        duration = "Wymiar wyroku",
        durationSubtitle = "Dostosuj czas pozostały w minutach.",
        notes = "Notatki",
        notesSubtitle = "Zapisz obserwacje dla tego wyroku.",
        links = "Powiązany nakaz i przestępstwa",
        linksSubtitle = "Dołącz nakaz i przestępstwa związane z tym pobytem.",
        housing = "Zakwaterowanie",
        housingSubtitle = "Przełącz między izolatką a ogólną populacją."
      },
      placeholders = {
        note = "Dodaj notatki...",
        warrant = "Wybierz nakaz aresztowania",
        offence = "Wybierz przestępstwo"
      },
      status = {
        in_prison = "W więzieniu",
        breaked_out = "Uciekł",
        released = "Wolny na wolności"
      },
      solitary = {
        active = "Izolacja",
        inactive = "Ogólna populacja",
        badge = "Izolatka"
      },
      duration = {
        minutesOnly = "{minutes} m pozostało",
        full = "{hours}h {minutes}m zostało"
      },
      linked = {
        warrantFallback = "Ważny dokument"
      },
      date = {
        unknown = "Nieznany"
      },
      errors = {
        load = "Nie można załadować więźniów.",
        duration = "Nie można zaktualizować czasu trwania.",
        note = "Nie można zapisać notatki.",
        links = "Nie można zaktualizować linków.",
        solitary = "Nie można zaktualizować odosobnienia.",
        solitary_unavailable = "Brak skonfigurowanych cel odosobnienia dla tego więzienia."
      }
    },
    workshopConfig = {
      header = { title = "Job Configurator" },
      sidebar = { features = "Features", entries = "Jobs", interactions = "Interactions" },
      sections = { general = "General", shop = "Shop", props = "Props", vehicles = "Vehicles", locations = "Locations" },
      actions = { add = "Add", addItem = "Add item", addPart = "Add part", addProp = "Add prop", addVehicle = "Add vehicle", apply = "Apply", back = "Back", cancel = "Cancel", close = "Close", done = "Done", edit = "Edit", newEntry = "New job", pickColor = "Pick", reset = "Reset", save = "Save", set = "Set", teleport = "Teleport", unset = "Unset" },
      editor = { editTitle = "Edit job", newTitle = "New job" },
      overview = { subtitle = "Select a job to edit or create a new one from the last saved settings.", emptySubtitle = "Create the first job to start moving this config into the database.", counts = "{shop} shop / {vehicles} vehicles / {props} props" },
      features = {
        title = "Funkcje",
        subtitle = "Wlacz lub wylacz funkcje zasobu dla wszystkich skonfigurowanych prac.",
        instantTuning = { label = "instantTuning", description = "" },
        partsDelivery = { label = "Dostawa czesci", description = "Wlacza zamowienia czesci warsztatowych i strefy dostaw." },
        carryItems = { label = "Fizyczna obsluga czesci", description = "Wymaga przenoszenia dostarczonych czesci przez warsztat." },
        nitro = { label = "nitro", description = "" },
        antiLag = { label = "antiLag", description = "" },
        twoStep = { label = "twoStep", description = "" },
        wheelDamage = { label = "Uszkodzenia kol", description = "Wlacza realistyczne uszkodzenia kol i naprawy." },
        customHandling = { label = "customHandling", description = "" },
        mileageHud = { label = "HUD przebiegu", description = "Pokazuje przebieg pojazdu podczas jazdy." },
        workshopLift = { label = "Podnosnik warsztatowy", description = "Wlacza uzywalne punkty podnosnika w warsztatach." }
      },
globalSettings = { title = "Global settings", notice = "These values apply to all configured jobs. Saving them from this job updates the behavior globally." },
      tuning = { globalTitle = "Global pricing settings", globalBadge = "Global", globalNotice = "These values apply to all configured jobs. Saving them from this job updates pricing behavior globally.",
        nitroAccess = "Dostęp do nitro dla tej pracy",
        nitroAccessHelp = "Nadpisz globalne ustawienie funkcji Nitro dla tej pracy mechanika.",
        nitroAccessInherit = "Użyj globalnego ustawienia Nitro",
        nitroAccessEnabled = "Włącz Nitro dla tej pracy",
        nitroAccessDisabled = "Wyłącz Nitro dla tej pracy",
      },
      fields = { allowedJobs = "Allowed jobs", animationDict = "Animation dict", animationName = "Animation name", blip = "Blip", bone = "Bone", category = "Category", color = "Job color", consumeItems = "Consume items", cost = "Cost", distance = "Distance", enabled = "Enabled", garageType = "Garage type", heading = "Heading", item = "Item", jobName = "Job name", label = "Label", marker = "Marker", mechanicOnly = "Mechanic", name = "Name", offsetX = "Offset X", offsetY = "Offset Y", offsetZ = "Offset Z", offDutyEnabled = "Off-duty enabled", offDutyJob = "Off-duty job", ped = "Ped", pedModel = "Ped model", price = "Price", prop = "Prop", requiredItems = "Required items", scenario = "Scenario", sprite = "Sprite", stage = "Stage", transport = "Transport", trunkCapacity = "Trunk capacity", type = "Type", value = "Value", x = "X", y = "Y", z = "Z",
        minGrade = "Minimalny stopień",
        livery = "Liveria",
        fuelType = "Typ paliwa",
        primaryColor = "Kolor główny",
        secondaryColor = "Kolor dodatkowy",
        pearlescentColor = "Kolor perłowy",
        wheelColor = "Kolor kół",
        extras = "Akcesoria",
        extraId = "ID akcesorium",
        propCounts = "Limity rekwizytów",
        count = "Limit",
        properties = "Właściwości pojazdu",
        property = "Właściwość",
      },
      placeholders = { allowedJobs = "mechanic, tuner", itemName = "Item name", jobName = "job name", label = "Label", model = "Model", vehicleName = "Name",
        liveryIndex = "e.g. 0",
        paintIndex = "0-160",
        propCounts = "{ \"prop_model\": 4 }",
        properties = "{ \"windowTint\": 1 }",
      },
      fuelTypes = {
        default = "Domyślny (zwykły)",
        regular = "Zwykły",
        plus = "Plus",
        premium = "Premium",
        diesel = "Diesel",
      },
      descriptions = { color = "Color used by Sky Jobs menus, blips, and job UI accents.", jobName = "Framework job name registered for this job.", offDutyEnabled = "Enable an off-duty counterpart for this job.", offDutyJob = "Job name used when this employee goes off duty." },
      messages = { empty = "No jobs configured yet.", featuresSaved = "Features saved.", invalidJson = "Correct invalid JSON fields before saving.", loading = "Loading jobs...", nameExists = "A job with this job name already exists.", noTuningOptions = "No options configured in this category.", saved = "Settings saved.", saveFailed = "Unable to save changes." },
      locations = { addSubtitle = "Choose which point type to place.", addTitle = "Add location point", deleteFailed = "Unable to delete location.", deleteSaved = "Location removed. Save settings to apply it.", emptySubtitle = "This configurator has no registered location definitions.", emptyTitle = "No locations configured.", garageMenu = "Menu", garagePark = "Park", garageSpawn = "Spawn", placeFailed = "Unable to place location.", placementHint = "Press Enter to place and Backspace to cancel.", placementSaved = "Location updated. Save settings to apply it.", placementTitle = "Placement mode", teleported = "Teleported to location.", teleportFailed = "Unable to teleport to location.", unset = "Not set" },
      carryItems = { missingProp = "Enter a prop model before opening placement.", placementFailed = "Unable to edit attach placement.", placementSaved = "Attach placement updated. Save settings to apply it.", selectItem = "Select delivery item" },
      extensions = { invalidJson = "Nieprawidlowy JSON. Popraw skladnie przed zapisem.", jsonObjectRequired = "Wartosc musi byc obiektem JSON.", partsDeliveryShop = "Sklep dostawy czesci", tuningCostProfile = { label = "Ceny tuningu", description = "Skonfiguruj koszty osiagow, wygladu, kol i opcji specjalnych dla tej pracy." } },
garageTypes = { boat = "Boat", helicopter = "Helicopter", vehicle = "Vehicle" },
      colorPopup = { title = "Job color" },
      dialogs = { delete = { cancel = "Cancel", confirm = "Delete", message = "Delete {name}?", title = "Delete job" } },
      screenPosition = { preview = "HUD" },
      interactions = { title = "Interactions", empty = "No interactions configured.", addMarkerSetting = "Add marker setting", noPedSelected = "No ped selected", headers = { interaction = "Interaction", key = "Key", marker = "Marker", blip = "Blip", npc = "NPC" }, tabs = { behavior = "Behavior", marker = "Marker", blip = "Blip", npc = "NPC" }, status = { on = "On", off = "Off" }, fields = { unique = "Unique", forceMarkerInteraction = "Force marker interaction", interactionDistance = "Interaction distance", placementModel = "Placement model" }, help = { unique = "Limits the interaction type to one configured point for a location when enabled.", forceMarkerInteraction = "Forces marker-style interaction handling even when target/NPC interaction support is available.", interactionDistance = "Maximum distance from the point where the player can use the interaction.", placementModel = "Object model shown while placing this interaction in the creator." } },
      assetPicker = { search = "Search", allCategories = "All categories", itemCount = "{count} items", markerTitle = "Marker type", markerSubtitle = "Choose a DrawMarker type.", blipTitle = "Blip sprite", blipSubtitle = "Choose a map blip sprite.", pedTitle = "Ped model", pedSubtitle = "Choose a FiveM ped model.", chooseMarker = "Choose marker", chooseBlip = "Choose blip", choosePed = "Choose ped" },
      markerFields = { posX = "Position X", posY = "Position Y", posZ = "Position Z", dirX = "Direction X", dirY = "Direction Y", dirZ = "Direction Z", rotX = "Rotation X", rotY = "Rotation Y", rotZ = "Rotation Z", scaleX = "Scale X", scaleY = "Scale Y", scaleZ = "Scale Z", red = "Red", green = "Green", blue = "Blue", alpha = "Alpha", bobUpAndDown = "Bob up/down", faceCamera = "Face camera", rotationOrder = "Rotation order", rotate = "Rotate", textureDict = "Texture dict", textureName = "Texture name", drawOnEnts = "Draw on entities" },
      instantTuning = { title = "Instant Tuning", defaultLabel = "Default label", defaultLabelHelp = "Text shown at instant tuning points.", interactionDistanceHelp = "Default distance from which a point can be used.", priceMultiplier = "Price multiplier", priceMultiplierHelp = "Multiplier applied to instant tuning prices.", forceMarkerHelp = "Forces marker-style interaction handling even when target support is available.", mechanicOnlyHelp = "Restricts every instant tuning point to configured mechanic jobs.", allowedJobsHelp = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", emptyLocations = "No instant tuning locations configured.", emptyLocationsHelp = "Add a location, then use Set to capture your current position." }
  ,

      configs = { sky_mechanicjob = { title = "Prace mechanika", subtitle = "Skonfiguruj prace mechanika, sklepy, pojazdy i lokalizacje warsztatu." } },
      settingSections = { general = "Ogolne", partsTheft = "Kradziez czesci", vehicleCare = "Pielegnacja pojazdu", wear = "Zuzycie", wheelDamage = "Uszkodzenia kol", mileageHud = "HUD przebiegu", instantTuning = "Instant Tuning", carryItems = "Przenoszone czesci" },
      settingFields = { key = "Klucz", label = "Etykieta", name = "Nazwa itemu", amount = "Ilosc", price = "Cena", item = "Item", repair = "Napraw kitem", classId = "ID klasy", multiplier = "Mnoznik", kilometersToZero = "Kilometry do zera", removeAfterUse = "Zuzyj item", flow = "Przebieg instalacji", transport = "Transport", prop = "Prop", bone = "Bone", x = "X", y = "Y", z = "Z", rx = "Rot X", ry = "Rot Y", rz = "Rot Z", category = "Kategoria" },
      settings = {
        primaryColor = { label = "Kolor glowny", description = "Main mechanic configurator color and default job color fallback. Use a hex value such as #EDC001." },
        orderInstallNonMinigameDurationMs = { label = "Prosty czas instalacji", description = "Milliseconds used for order install steps that do not run a minigame." },
        tuningWorkshopRequireForInstall = { label = "Wymagaj warsztatu do montazu", description = "Require tuning order installs to start and complete near a self-service tuning point." },
        tuningWorkshopRequireForRemoval = { label = "Wymagaj warsztatu do demontazu", description = "Require tuning removals to start and complete near a self-service tuning point." },
        tuningWorkshopDistance = { label = "Wymagana odleglosc warsztatu", description = "Maximum distance from a self-service tuning point for required install or removal actions." },
        addRevenueToSociety = { label = "Wplac przychod do society", description = "Deposit paid tuning order money into the tuning job society account." },
        publicUsersSeePrices = { label = "Publiczni gracze widza ceny", description = "Show regular tuning prices to non-mechanic public users." },
        fallbackVehicleValue = { label = "Domyslna wartosc pojazdu", description = "Value used when no vehicle price can be resolved." },
        priceType = { label = "Typ ceny", description = "Percentage calculates each tuning cost from the vehicle price. Fixed uses the entered money amount.", options = { percentage = "Procent", fixed = "Stala" } },
        freeVehicles = { label = "Darmowe pojazdy tuningowe", description = "Vehicle spawn models that receive free tuning orders.", itemLabel = "Vehicle model" },
        partsTheftItem = { label = "Narzędzie kradziezy", description = "Inventory item used to steal wheels and catalytic converters." },
        partsTheftRemoveItemAfterUse = { label = "Zuzyj narzedzie kradziezy", description = "Remove the theft tool item after a successful theft action." },
        partsTheftStolenWheelItem = { label = "Skradzione kolo", description = "Inventory item awarded when wheels are stolen." },
        partsTheftCatalyticConverterItem = { label = "Katalizator", description = "Inventory item awarded when a catalytic converter is stolen." },
        partsTheftDealerAccount = { label = "Dealer payout account", description = "Account used for stolen parts dealer payouts, such as money or bank." },
        partsTheftDealerSellDistance = { label = "Dealer sell distance", description = "Maximum distance from the dealer to sell stolen parts." },
        partsTheftDispatchEnabled = { label = "Wyslij dispatch policji", description = "Create a police dispatch when a wheel or catalytic converter is stolen." },
        partsTheftDispatchJobs = { label = "Dispatch jobs", description = "Job names that receive parts theft dispatches.", itemLabel = "Job name" },
        partsTheftDispatchTitle = { label = "Dispatch title", description = "Title shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchMessage = { label = "Dispatch message", description = "Message shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchCooldownSeconds = { label = "Dispatch cooldown", description = "Seconds before the same vehicle part can create another dispatch." },
        partsTheftDealerItems = { label = "Dealer items", description = "Stolen items the dealer will buy and their payout values.", itemLabel = "Dealer item" },
        vehicleCareWashItem = { label = "Item mycia", description = "Inventory item used to wash a vehicle." },
        vehicleCareWashRemoveAfterUse = { label = "Zuzyj item mycia", description = "Remove the wash item after use." },
        vehicleCareWaxItem = { label = "Item wosku", description = "Inventory item used to wax a vehicle." },
        vehicleCareWaxRemoveAfterUse = { label = "Zuzyj item wosku", description = "Remove the wax item after use." },
        vehicleCareWaxCleanKilometers = { label = "Wax clean kilometers", description = "Distance a waxed vehicle stays clean." },
        vehicleCareRepairItem = { label = "Item naprawy", description = "Inventory item used by the vehicle repair action." },
        vehicleCareRepairRemoveAfterUse = { label = "Zuzyj item naprawy", description = "Remove the repair item after use." },
        vehicleCareRepairDurationMs = { label = "Czas naprawy", description = "Repair progress duration in milliseconds." },
        vehicleCareRepairMaxDistance = { label = "Repair max distance", description = "Maximum distance from the vehicle while repairing." },
        vehicleCareRepairVehicleDamage = { label = "Fix vehicle damage", description = "Repair normal GTA vehicle damage when using the repair action." },
        vehicleCareRepairFixRealisticWheelDamage = { label = "Fix realistic wheel damage", description = "Also reset realistic wheel damage when using the repair action." },
        vehicleCareRepairWearParts = { label = "Repair kit restored parts", description = "Choose which wear and service parts the repair item restores. Disable fluids here if oil, coolant, brake fluid, or transmission fluid should require the diagnostics repair flow.", itemLabel = "Wear part" },
        wearParts = { label = "Czesci zuzycia", description = "Vehicle wear parts, their lifetime distance, required repair item, item consumption, and install flow.", itemLabel = "Wear part", fields = { flow = { options = { wheel = "Wheel", performance = "Performance", underbody_neon = "Underbody / lift", oil_change = "Oil change", fluid_refill = "Fluid refill", catalytic_converter = "Catalytic converter", hood_install = "Hood install" } } } },
        wheelDamageDefaultMultiplier = { label = "Domyslny mnoznik", description = "Base wheel damage multiplier." },
        wheelDamageOffroadWheelsMultiplier = { label = "Off-road wheel multiplier", description = "Multiplier used when the vehicle has off-road wheels." },
        wheelDamageVehicleClassMultipliers = { label = "Vehicle class multipliers", description = "Damage multipliers per GTA vehicle class.", itemLabel = "Vehicle class" },
        mileageHudDigits = { label = "Cyfry", description = "Number of digits shown in the mileage HUD." },
        mileageHudPosition = { label = "Pozycja", description = "Drag the mileage HUD preview to the desired screen position." },
        partsDeliveryTimeSeconds = { label = "Czas dostawy", description = "Seconds between ordering parts and the delivery becoming ready." },
        partsDeliveryTimerHudEnabled = { label = "Show delivery timer", description = "Show a small in-game timer HUD after a parts order is placed." },
        partsDeliveryTimerHudPosition = { label = "Timer position", description = "Drag the parts delivery timer HUD preview to the desired screen position." },
        partsDeliveryOwnCard = { label = "Own card payment", description = "Allow players to pay parts delivery orders with their own money." },
        partsDeliveryCompanyCard = { label = "Company card payment", description = "Allow parts delivery orders to use company funds." },
        partsDeliveryOpenDurationMs = { label = "Open duration", description = "Milliseconds required to unpack a ready parts delivery." },
        instantTuningInteractionDistance = { label = "Dystans interakcji", description = "Default distance for using instant tuning points." },
        instantTuningForceMarkerInteraction = { label = "Force marker interaction", description = "Use marker-style E interaction even when target support is enabled." },
        instantTuningMechanicOnly = { label = "Tylko mechanicy", description = "Restrict all instant tuning locations to configured mechanic jobs." },
        instantTuningAllowedJobs = { label = "Dozwolone prace", description = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", itemLabel = "Job name" },
        instantTuningPriceMultiplier = { label = "Mnoznik ceny", description = "Multiplier applied to instant tuning prices." },
        instantTuningLabel = { label = "Domyslna etykieta", description = "Default text shown at instant tuning points." },
        instantTuningMarkerEnabled = { label = "Marker enabled", description = "Draw a world marker at instant tuning locations." },
        instantTuningMarkerType = { label = "Marker type", description = "GTA marker type used for instant tuning locations." },
        instantTuningBlipEnabled = { label = "Blip enabled", description = "Show map blips for instant tuning locations." },
        instantTuningBlipName = { label = "Blip name", description = "Map blip name." },
        instantTuningBlipSprite = { label = "Blip sprite", description = "GTA blip sprite id." },
        instantTuningBlipColor = { label = "Blip color", description = "GTA blip color id." },
        instantTuningLocations = { label = "Lokalizacje", description = "Instant tuning points. Use 0 distance to inherit the default interaction distance.", itemLabel = "Locations" },
        carryItems = { label = "Przenoszone czesci", description = "Delivered parts that should become physical carried props.", itemLabel = "Carry item", fields = { transport = { options = { hand = "Reka", forklift = "Wozek widlowy", engine_lift = "Podnosnik silnika" } } } }
      },
      settingValues = {
        tyres = "Tyres", brake_pads = "Brake Pads", suspension = "Suspension", spark_plugs = "Spark Plugs", engine_oil = "Engine Oil", coolant = "Coolant", brake_fluid = "Brake Fluid", transmission_fluid = "Transmission Fluid", clutch = "Clutch", air_filter = "Air Filter", traction_battery = "Traction Battery", inverter = "Power Inverter", catalytic_converter = "Catalytic Converter",
        vehicleClass_0 = "Compacts", vehicleClass_1 = "Sedans", vehicleClass_2 = "SUVs", vehicleClass_3 = "Coupes", vehicleClass_4 = "Muscle", vehicleClass_5 = "Sports Classics", vehicleClass_6 = "Sports", vehicleClass_7 = "Super", vehicleClass_8 = "Motorcycles", vehicleClass_9 = "Off-road", vehicleClass_10 = "Industrial", vehicleClass_11 = "Utility", vehicleClass_12 = "Vans", vehicleClass_13 = "Cycles", vehicleClass_14 = "Boats", vehicleClass_15 = "Helicopters", vehicleClass_16 = "Planes", vehicleClass_17 = "Service", vehicleClass_18 = "Emergency", vehicleClass_19 = "Military", vehicleClass_20 = "Commercial", vehicleClass_21 = "Trains", vehicleClass_22 = "Open Wheel"
      }
  },
    jobConfigurator = {
      actions = {
        backToScripts = "Skrypty"
      },
      selector = {
        title = "Konfigurator prac",
        subtitle = "Wybierz, który skrypt pracy chcesz skonfigurować.",
        description = "Wybierz zasób, który chcesz skonfigurować.",
        loading = "Ładowanie konfiguratorów...",
        comingSoon = "Wkrotce",
        emptyTitle = "Brak dostępnych skryptów do konfiguracji.",
        emptySubtitle = "Nie masz uprawnień do żadnego zarejestrowanego konfiguratora prac.",
        unavailable = "Niezarejestrowany"
      }
    },
    billing = {
      title = "Wystawić rachunek",
      subtitle = "Obciążyć pobliskich obywateli za usługi.",
      selectLabel = "Wybierz osobę",
      selectPlaceholder = "Wybierz osobę",
      noPlayers = "Brak pobliskich osób w odległości {range} m.",
      amountLabel = "Kwota rachunku",
      reasonLabel = "Powód (krótki)",
      reasonPlaceholder = "Przykład: Patrol służbowy",
      presetsLabel = "Wykroczenia",
      presetSearchPlaceholder = "Szukaj wykroczenia lub mandatu",
      presetNoMatches = "Nie znaleziono wykroczeń pasujących do wyszukiwania.",
      presetReasonHeader = "Wykroczenie",
      presetAmountHeader = "Mandat",
      presetCustomAmount = "Niestandardowy",
      paperDefaultCategory = "Zawiadomienie o naruszeniu parkowania",
      ticketReceiptTitle = "Zawiadomienie o mandacie",
      ticketReceiptSubtitle = "Wprowadzono w",
      ticketReceiptCitizenLabel = "Obywatel",
      ticketReceiptOfficerLabel = "Personel wydający",
      ticketReceiptReasonLabel = "Podsumowanie opłaty",
      ticketReceiptAmountLabel = "Razem mandat",
      ticketReceiptAcknowledge = "Potwierdź",
      cancelButton = "Anuluj",
      submitButton = "Wystawić rachunek",
      submitting = "Wysyłanie...",
      success = "Rachunek został pomyślnie wystawiony.",
      paperTicketNumber = "Numer biletu",
      paperDate = "Data",
      paperTime = "Czas",
      paperCitizenLabel = "Obywatel",
      paperOfficerLabel = "Personel",
      paperViolationLabel = "Naruszenie",
      paperNotice = "Płatność jest wymagana natychmiast. Brak zapłaty może skutkować odholowaniem.",
      paperSignatureLabel = "Podpis personelu",
      paperTotalFine = "Razem mandat",
      errors = {
        failed = "Nie można wystawić rachunku.",
        invalid_target = "Osoba niedostępna.",
        empty_reason = "Podaj krótki powód.",
        too_far = "Osoba oddaliła się zbyt daleko.",
        not_authorized = "Nie masz uprawnień do wystawiania rachunków.",
        not_on_duty = "Musisz być na służbie, aby wystawiać rachunki.",
        amount_out_of_range = "Kwota rachunku poza dozwolonym zakresem.",
        insufficient_funds = "Osoba nie może sobie pozwolić na tę opłatę.",
        player_unavailable = "Osoba niedostępna.",
        disabled = "System rozliczeń wyłączony."
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
