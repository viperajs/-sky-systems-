if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/config/locales/rs.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

-- Rs translation
Locales["rs"] = {
  WardrobeHelpNotify = "Otvoriti garderobu",
  WardrobeTitle = "Ormar",
  WardrobeCivilianMissing = "Još uvek nema sačuvanu civilnu odoru.",
  WardrobeCivilianRestored = "Civilna odora učitana.",
  WardrobeUnsupportedFramework = "Garderoba ne radi sa izabranim frameworkom ({framework}).",
  WardrobeMissingSkinchanger = "Garderoba zahteva da skinchanger bude pokrenut na ESX-u.",
  WardrobeMissingEsxSkin = "Garderoba zahteva da esx_skin bude pokrenut na ESX-u.",
  WardrobeMissingQbClothing = "Garderoba zahteva da qb-clothing bude pokrenut na {framework}.",
  WardrobeMissing17Movement = "Garderoba zahteva da 17mov_CharacterSystem bude pokrenut.",
  WardrobeMissingQsAppearance = "Garderoba zahteva da qs-appearance bude pokrenut.",
  WardrobeMissingAk47Clothing = "Garderoba zahteva da ak47_clothing bude pokrenut.",
  WardrobeMissingAk47QbClothing = "Garderoba zahteva da ak47_qb_clothing bude pokrenut.",
  WardrobeMissingTgiannClothing = "Garderoba zahteva da tgiann-clothing bude pokrenut.",
  WardrobeMissingNfSkin = "Garderoba zahteva da nf-skin bude pokrenut.",
  WardrobeMissingBlAppearance = "Garderoba zahteva da bl_appearance bude pokrenut.",
  WardrobeMissingIzzyAppearance = "Garderoba zahteva da izzy-appearance bude pokrenut.",
  WardrobeMissingCodemAppearance = "Garderoba zahteva da codem-appearance bude pokrenut.",
  WardrobeMissingHexClothing = "Garderoba zahteva da hex_clothing bude pokrenut.",
  WardrobeMissingIllenium = "Garderoba zahteva da illenium-appearance bude pokrenut.",
  WardrobeCustomUnavailable = "Konfigurisana prilagodjena integracija garderobe nije dostupna.",
  WardrobeDisabled = "Garderoba je iskljucena u konfiguraciji.",
  WardrobeMissingRcoreClothing = "Garderoba zahteva da rcore_clothing bude pokrenut.",
  WardrobeUnknownJob = "Posao garderobe nije dostupan.",
  GarageHelpNotify = "Otvoriti garažu",
  GarageTitle = "Garaža",
  HelicopterGarageHelpNotify = "Otvoriti helipad",
  BoatGarageHelpNotify = "Otvoriti pristanište",
  GarageParkHelpNotify = "Parkirati vozilo",
  HelicopterGarageParkHelpNotify = "Parkirati helikopter",
  BoatGarageParkHelpNotify = "Parkirati brod",
  GarageParkDriverRequired = "Potrebujete biti za volanom da biste parkirali.",
  GarageParkInvalidVehicle = "Ovaj vozilo ne može biti parkirano ovde.",
  GarageParkFailedNotify = "Nemoguće parkirati vozilo.",
  GarageSpawnBlockedNotify = "Tačka pojavljivanja je blokirana.",
  StorageHelpNotify = "Pristup skladištu",
  LockerHelpNotify = "Otvoriti orman",
  TrunkTitle = "Prtljažnik",
  TrunkHelpNotify = "Pristupiti prtljažniku",
  TrunkPropRemoveHelp = "Ukloniti postavljeni predmet",
  TrunkUnavailable = "Nemoguće pristupiti ovom prtljažniku.",
  BossMenuHelpNotify = "Otvoriti upravljanje",
  Payroll = {
    title = "Platni spisak",
    paid = "Plata primljena: {amount}",
    insufficient = "Nema dovoljno novca u kasi firme za tvoju platu.",
  },
  PublicFormsTitle = "Javni obrasci",
  PublicFormsHelpNotify = "Popuniti javne obrasce",
  PublicFormsUnavailable = "Kiosk za javne obrasce nedostupan.",
  WholesaleShopTitle = "Veleprodaja",
  WholesaleShopHelpNotify = "Otvoriti veleprodajnu prodavnicu",
  WholesaleShopUnavailable = "Ova lokacija nema konfigurisanog dobavljača na veliko.",
  NoPermission = "Nemate dozvolu za korišćenje ove komande.",
  CameraUploadFailed = "Slanje kamere nije uspelo.",
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
    Sent = "Panic dugme aktivirano.",
    NotOnDuty = "Morate biti na duznosti da koristite panic dugme.",
    Cooldown = "Panic dugme se puni. Sacekajte {seconds}s.",
    MappingDescription = "Aktiviraj paničnu uzbunu",
    WaypointSet = "Waypoint postavljen na panic lokaciju.",
    WaypointMissing = "Nema aktivne panic lokacije.",
    LocationUnknown = "Nepoznata lokacija",
    MissingItem = "Potreban vam je {item} za korišćenje dugmeta za paniku.",
  },
  Ping = {
    Title = "Ping",
    Sent = "Lokacijski ping poslat.",
    NotOnDuty = "Morate biti na duznosti da posaljete ping.",
    Cooldown = "Ping se puni. Sacekajte {seconds}s.",
    MappingDescription = "Pošalji oznaku lokacije",
    LocationUnknown = "Nepoznata lokacija",
    MissingItem = "Potreban vam je {item} za slanje pinga.",
  },
  HeliCam = {
    Title = "Heli kamera",
    CamEnabled = "Heli kamera ukljucena.",
    CamDisabled = "Heli kamera iskljucena.",
    NotAuthorized = "Nemate ovlascenje da koristite heli kameru.",
    NotOnDuty = "Morate biti na duznosti da koristite heli kameru.",
    TooLow = "Helikopter je prenisko za aktivaciju kamere.",
    TargetLocked = "Meta zakljucana.",
    TargetReleased = "Brava mete oslobođena.",
    TargetLost = "Meta izgubljena.",
    RappelDenied = "Ne mozete se spustiti uzetom sa ovog sedista.",
    RappelStarted = "Spustanje uzetom pokrenuto.",
    PhotoSaved = "Heli fotografija sacuvana u galeriji.",
    PhotoFailed = "Nije moguce sacuvati heli fotografiju.",
    Spotlight = {
      ForwardOn = "Reflektor ukljucen.",
      ForwardOff = "Reflektor iskljucen.",
      TrackingOn = "Prateci reflektor aktivan.",
      TrackingOff = "Prateci reflektor iskljucen.",
      ManualOn = "Rucni reflektor aktivan.",
      ManualOff = "Rucni reflektor iskljucen.",
      Brightness = "Jacina reflektora: {value}",
      Radius = "Radijus reflektora: {value}"
    }
  },
  InteractionLabels = {
    job_garage              = "Radni garaža",
    garage_vehicle_spawn    = "Spawn tačka vozila",
    garage_vehicle_park     = "Parking za vozilo",
    garage_helicopter_menu  = "Helikopterski hangar",
    garage_helicopter_spawn = "Spawn tačka helikoptera",
    garage_helicopter_park  = "Parking za helikopter",
    garage_boat_menu        = "Pristanište",
    garage_boat_spawn       = "Spawn tačka čamca",
    garage_boat_park        = "Priveznica čamca",
    boss_menu               = "Uprava",
    duty_terminal           = "Terminal dežurstva",
    wardrobe                = "Garderoba",
    storage                 = "Skladište",
    locker                  = "Ormarić",
    wholesale_shop          = "Veleprodaja",
    public_forms            = "Javni obrasci",
    jail_terminal           = "Zatvorski terminal",
    jail_jobs               = "Zatvorski poslovi",
    jail_job_npc            = "Zatvorski poslovi",
    jail_inmate_alcoholic   = "Zatvorenik: Alkoholičar",
    jail_inmate_drugdealer  = "Zatvorenik: Diler droge",
    jail_inmate_codelist    = "Zatvorenik: Informator",
    jail_inmate_wirecutter  = "Zatvorenik: Dostavljač alata",
    jail_inmate_doctor      = "Zatvorski lekar",
    jail_canteen_cook       = "Kuvar u kantini",
    jail_confiscated_return = "Oduzeti predmeti",
    jail_electric_box       = "Električni ormar",
    jail_fence_cut          = "Tačka presecanja ograde",
  },
  Nui = {
    IntlLocale = "sr-RS",
    currency = "dinar",
    menuTitles = {
      locker = "Lični ormarić",
      storage = "Skladište",
      trunk = "Skladište vozila",
      ["trunk-props"] = "Oprema za vozila",
      search = "Pretražiti",
      garage = "Garaža",
      vehshop = "Prodavnica vozila",
      management = "Upravljanje",
      shop = "Velproda",
      ["impound-storage"] = "Skladište za oduzeta vozila",
      refunds = "Vraćanje novca"
    },
    menu = {
      goToVehicleShop = "Idi u prodavnicu vozila",
      backToGarage = "Nazad u garažu"
    },
    radial = {
      empty = "Trenutno nema dostupnih radnji.",
      errors = {
        generic = "Radnja nije dostupna."
      },
      title = "Radnje tokom dežurstva",
      hint = "Izabrati radnju za obavljanje.",
      pressKey = "Pritisnite {key}",
      actions = {
        billing = {
          label = "Izdati račun",
          description = "Izdaj račun najbližoj osobi.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Računanje nije dostupno.",
            notOnDuty = "Uključi se u dežurstvo da bi izdavao račune.",
            notAuthorized = "Nemate ovlašćenje za izdavanje računa.",
            noPatients = "Nema osoba u blizini za računanje."
          }
        },
        panic = {
          label = "Dugme za paniku",
          description = "Pokrenite alarm za paniku za vašu trenutnu lokaciju.",
          states = {
            disabled = "Dugme za paniku nije dostupno.",
            notOnDuty = "Uključi se u dežurstvo da koristiš dugme za paniku.",
            notAuthorized = "Nemate ovlašćenje za korišćenje dugmeta za paniku."
          }
        },
        tablet = {
          label = "Otvoriti tablet",
          description = "Otvoriti interfejs tableta.",
          states = {
            notOnDuty = "Иди на дежурство да користиш таблет.",
            notAuthorized = "Немаш овлашћење да користиш таблет.",
            missingItem = "Потребан ти је таблет за ово."
          }
        },
        removeProp = {
          label = "Уклонити предмет",
          description = "Уклонити блиски постављени предмет.",
          states = {
            noNearby = "Нема блиских предмета за уклањање.",
            failed = "Неуспех у уклањању предмета."
          }
        },
        carryPatient = {
          label = "Несујте особу",
          description = "Несујте најближу особу у sigurnост.",
          dropLabel = "Оставити особу",
          dropDescription = "Освободити особу коју носите.",
          badge = {
            distance = "{distance} м"
          },
          states = {
            disabled = "Носити је недоступно.",
            beingCarried = "Већ вас носе.",
            inVehicle = "Изађите из возила прво.",
            selfIncapacitated = "Нисте стабилни довољно да носите некога.",
            noPatients = "Нема блиских особа за ношење.",
            tooFar = "Приближите се пре ношења особе."
          }
        },
        playerSearch = {
          label = "Тражити особу",
          description = "Тражити најближу особу.",
          badge = {
            distance = "{distance} м"
          },
          states = {
            disabled = "Трзање играча није доступно.",
            notOnDuty = "Иди на дежурство да тражиш људе.",
            notAuthorized = "Немаш овлашћење за тражење људи.",
            noPlayers = "Нема блиских особа за тражње.",
            tooFar = "Приближите се пре тражења.",
            inVehicle = "{'text': 'Izaći iz vozila prvi.'}"
          }
        },
        handcuff = {
          label = "{'text': 'Rizičiti osobu'}",
          description = "{'text': 'Rizičiti najbližu osobu.'}",
          badge = {
            distance = "{'text': '{distance} m'}"
          },
          states = {
            disabled = "{'text': 'Rizičenje je nedostupno.'}",
            notOnDuty = "{'text': 'Idite na dužnost da biste koristili lisice.'}",
            inVehicle = "{'text': 'Izaći iz vozila prvi.'}",
            targetInVehicle = "{'text': 'Uklonite osobu iz vozila prvo.'}",
            noPlayers = "{'text': 'Nema bliskih osoba za rizičenje.'}",
            tooFar = "{'text': 'Približite se pre rizičenja.'}",
            missingItem = "{'text': 'Potrebne su vam lisice za ovo.'}",
            alreadyCuffed = "{'text': 'Ta osoba je već rizičena.'}"
          }
        },
        unhandcuff = {
          label = "{'text': 'Ukloni lisice'}",
          description = "{'text': 'Uklonite lisice s najbliže osobe.'}",
          badge = {
            distance = "{'text': '{distance} m'}"
          },
          states = {
            disabled = "{'text': 'Oslobađanje lisica je nedostupno.'}",
            notOnDuty = "{'text': 'Idite na dužnost da biste uklonili lisice.'}",
            inVehicle = "{'text': 'Izaći iz vozila prvi.'}",
            targetInVehicle = "{'text': 'Uklonite osobu iz vozila prvo.'}",
            noPlayers = "{'text': 'Nema bliskih osoba za uklanjanje lisica.'}",
            tooFar = "{'text': 'Približite se pre uklanjanja lisica.'}",
            notCuffed = "{'text': 'Ta osoba nema lisice.'}"
          }
        },
        wheelClamp = {
          label = "{'text': ' Blokada točka'}",
          description = "{'text': 'Osigurajte najbliži vozilo zakucavanjem točka.'}",
          states = {
            disabled = "{'text': 'Zakucavanje točka je nedostupno.'}",
            notOnDuty = "Otići na dužnost za blokiranje vozila.",
            inVehicle = "Prvo izaći iz vozila.",
            noVehicle = "Nema vozila u blizini.",
            tooFarVehicle = "Približiti se vozilu.",
            noWheel = "Približiti se točku na točku.",
            tooFar = "Približiti se točku na točku."
          }
        },
        wheelClampRemove = {
          label = "Ukloniti bravu",
          description = "Ukloniti bravu sa točka na točku.",
          states = {
            disabled = "Zaglavljivanje točka nije dostupno.",
            notOnDuty = "Otići na dužnost za uklanjanje brava.",
            inVehicle = "Prvo izaći iz vozila.",
            noClamp = "Nema brava u blizini.",
            tooFar = "Približiti se bravi točka na točku."
          }
        },
        jail = {
          label = "Poslati u zatvor",
          description = "Zadržati najbližeg igrača na dogovorenom mestu zatvora.",
          states = {
            notAuthorized = "Nemate ovlašćenje za slanje igrača u zatvor.",
            notOnDuty = "Otići na dužnost za korišćenje ove radnje.",
            noPlayers = "Nema osoba u blizini u dometu.",
            noJails = "Nema konfigurisanih zatvorskih mesta.",
            spawnNotSet = "Prvo konfigurisati mesto za zatvor.",
            invalidTarget = "Nije moguće pronaći tu osobu.",
            failed = "Nije moguće izvršiti tu radnju."
          }
        }
      }
    },
    shop = {
      shoppingCart = "Korpa za kupovinu",
      purchase = "Kupiti",
      balance = "Dostupna sredstva",
      catalog = "Katalognoski pretraživač dobavljača",
      empty = "Nema dostupnih zaliha na ovoj lokaciji.",
      emptyCart = "Vaša korpa je prazna.",
      insufficientFunds = "Nema dovoljno sredstava za ovu kupovinu.",
      limitReached = "Dostiže se limit ({limit}).",
      errors = {
        invalidStation = "Nevažeća stanica.",
        emptyBasket = "Korpa je prazna.",
        unknown = "Nepoznata greška.",
        purchase = "Kupovina korpe nije uspela."
      }
    },
    garage = {
      states = {
        stored = "Spreman",
        parked = "U upotrebi"
      },
      title = "Garaža",
      empty = "Nema dostupnih vožnih vozila.",
      emptyAir = "Nema dostupnih helikoptera na ovom tlu.",
      ownedTitle = "Vlastita flota",
      shopTitle = "Prodavnica vozila",
      shopBalance = "Sredstva frakcije",
      shopEmpty = "Nema dostupnih vozila za kupovinu na ovoj lokaciji.",
      shopEmptyAir = "Nema dostupnih helikoptera za kupovinu na ovom tlu.",
      emptyFleet = "Još nisu kupljena vozila za flotnu kolonu.",
      noAccess = "Nema pristupa",
      confirmSellTitle = "Potvrdi prodaju",
      confirmSellConfirm = "Prodaj",
      confirmSellCancel = "Otkaži",
      confirmSellMessage = "Prodati {name} za {price}?",
      confirmPurchaseTitle = "Potvrdi kupovinu",
      confirmPurchaseConfirm = "Kupi",
      confirmPurchaseCancel = "Otkaži",
      confirmPurchaseMessage = "Kupiti {name} za {price}?",
      purchaseSuccessTitle = "Vozilo kupljeno",
      purchaseSuccessMessage = "{name} dodato u flotu.",
      defaultVehicleName = "Vozilo",
      stats = {
        topSpeed = "Maksimalna brzina",
        acceleration = "Akceleracija",
        braking = "Kočenje",
        traction = "Trakcija"
      },
      actions = {
        parkOut = "Izlazak iz parkirališta",
        buyVehicle = "Kupovina vozila",
        openTrunk = "Otvoriti prtljažnik",
        editStretcher = "Urediti nosila",
        sellVehicle = "Prodaj vozilo",
        changePlate = "Promeni tablicu"
      },
      placeholders = {
        selectVehicle = "Обезбедити преглед аутомобила.",
        statsLoading = "Учитати информације о аутомобилу..."
      },
      errors = {
        loadVehicles = "Неуспело учитавање гаражних возила.",
        loadStats = "Неуспело учитавање статистика возила.",
        parkOut = "Неуспешно паркирање аутомобила.",
        unavailable = "Гаража недоступна.",
        vehicleUnavailable = "Vozilo nije dostupno.",
        purchase = "Пкупита аутомобила није успела.",
        openTrunk = "Неуспешно отварање стругара.",
        noAccess = "Немате приступ овом аутомобилу.",
        stretcherEditor = "Немогућност отварања уредника за стругаре.",
        stretcherPermission = "Само највиши ранг може уређивати прилоге за стругаре.",
        sellVehicle = "Продаја возила није успела.",
        editorUnavailable = "Urednik nije dostupan.",
        changePlate = "Promena tablice nije uspela."
      },
      changePlateTitle = "Promeni registarsku tablicu",
      changePlateButton = "Primeni",
      plateEditor = {
        button = "Uredi tablicu",
        title = "Uredi tablicu",
        hint = "Promeni tablicu ovog vozila.",
        save = "Sačuvaj tablicu",
        errors = {
          empty = "Unesite tablicu.",
          invalid = "Tablica je nevažeća.",
          update = "Ažuriranje tablice nije uspelo."
        }
      },
      status = {
        parkedBy = "Poslednje izvadio {name}",
        unknownDriver = "Nepoznato"
      }
    },
    duty = {
      fields = {
        grade = "Ранг",
        location = "Станица",
        name = "Име",
        badge = "Знак"
      },
      instructions = {
        drag = "Пренети своју радну карту на сензор за управљање сменом.",
        dragCard = "Пренети радну карту на сензор за почетак смене."
      },
      screen = {
        welcome = "Добродошли {name}",
        goodbye = "Смена је завршена. Чувајте се, {name}.",
        ready = "Дозвољен приступ смени.",
        completed = "Смена успешно окончана.",
        idleTitle = "Чека се скенирање",
        totalHours = "Укупно сати",
        shiftDuration = "Трајање смене",
        currentTime = "Тренутно време: {time}",
        defaultStation = "Примарна станица",
        devPrompt = "Учитајте тест податке за приказ радног терминала у прегледачу.",
        loadMock = "Учитај тест податке",
        loading = "Учитавање..."
      },
      toasts = {
        failed = "Није могуће ажурирати статус дужности."
      },
      errors = {
        unavailable = "Дужност терминал недоступна."
      },
      title = "Терминал смене"
    },
    storage = {
      inventory = "Инвентар",
      storage = "Складиште",
      locker = "Локација за слагатије",
      trunk = "Трактор аутомобила",
      trunkProps = "Положаји аутомобила",
      openPropMenu = "Положај",
      search = "Претрага",
      items = "Предмети",
      weapons = "Оружје",
      transferTitle = "Трансфер",
      transferButton = "Трансфер",
      capacityUnlimited = "Неконтролисана capacidade",
      errors = {
        trunkFull = "Трактор је пун.",
        searchReadOnly = "Можете само уклањати предмете особи.",
        invalidTransfer = "Трансфер није успео.",
        invalidAmount = "Неважећа количина.",
        notEnoughItems = "Нема довољно предмета.",
        inventoryFull = "Недовољно простора у инвентарском простору.",
        storageFull = "Поштарина је пуна.",
        lockerFull = "Складиште је пуно.",
        restrictedItem = "Немате приступ овом предмету.",
        invalidProp = "Неуспело одабирање пропа."
      },
      officerInventory = "Инвентар особља",
      loadout = "Опрема за руковање",
      armory = "Арсенал",
      armoryTitle = "Опрема за наоружање",
      storageTitle = "Безбедно складиште",
      storageSubtitle = "Само овлашћени службеници",
      emptyItems = "Нема расположивих предмета.",
      emptyWeapons = "Нема расположивих оружја.",
      emptyProps = "Нема расположивих пропа.",
      searchItems = "Предмети",
      searchWeapons = "Оружја",
      lockerUnlocking = "Очекује се откључавање сандука...",
      restrictedPill = "Ограничено",
      restrictedTooltip = "Немате приступ овом предмету.",
      capacityLabel = "{iskorišćeno}/{kapacitet}",
      propPlacement = {
        title = "Постављање пропа",
        place = "Постави ({key})",
        cancel = "Откази ({key})"
      }
    },
    creator = {
      title = "Умјесто тога",
      description = "Конфигуриши уносе.",
      selectJob = "Изаберите категорију посла.",
      empty = "Ниједан {entryLabelPlural} није конфигурисан још увек.",
      keyboardHint = "Користите стрелице за навигацију по листи и акцијама.",
      placementHelp = "Стрелице померају, PageUp/PageDown висина, Q/E ротација, Enter поставља, Backspace отказује.",
      editTitle = "Маркер",
      editSubtitle = "Користите дугме за мапу да бисте сачували ваше тренутне координате.",
      editKeyboardHint = "Користите стрелице за одабир маркера, лево/desно за одабир Поставити/Обрисати, Enter да га покренете, Backspace за враћање.",
      missingEntry = "Није пронађен унос.",
      actions = {
        add = "Додај {label}",
        newEntry = "Нови {entryLabel}"
      },
      status = {
        set = "Постави",
        unset = "Обриши"
      },
      modals = {
        createTitle = "Креирај {entryLabel}",
        createButton = "Креирај {entryLabel}",
        renameTitle = "Пензионисање {entryLabel}",
        renameButton = "Сачувај име",
        deleteTitle = "Обриши {entryLabel}",
        deleteMessage = "Да ли јесте да желите уклонити {name}?",
        deleteConfirmLabel = "Обриши",
        deleteCancelLabel = "Откажи"
      }
    },
    management = {
      noAccess = "Немате приступ ниједном алату за управљање.",
      refunds = {
        description = "Прегледај смртне случајеве од данас и јуче и врати уклоњене ставке.",
        refreshButton = "Освежи",
        updatedAt = "Ажурирано {time}",
        errors = {
          loadFailed = "Грешка у учитавању повратака новца."
        }
      },
      dashboard = {
        sidebarTitle = "Карта",
        menuTitle = "Преглед",
        onlineMembers = "Online članovi",
        funds = "Sredstva",
        onDuty = "Na dužnosti",
        offDuty = "Van dužnosti",
        mostActive = "Najaktivniji"
      },
      finance = {
        sidebarTitle = "Tok novca",
        menuTitle = "Finansni pregled",
        expenseCategories = "Kategorije troškova",
        revenueCategories = "Kategorije prihoda",
        kpis = {
          revenue = "Prihodi",
          expenses = "Troškovi",
          profit = "Dobit"
        },
        cashFlow = "Trend toka novca",
        lastUpdated = "Ažurirano {time}",
        emptyStates = {
          timeline = "U ovom periodu nisu zabeležene transakcije.",
          categories = "Još uvek nema podataka o kategorijama."
        },
        categories = {
          deposits = "Depoziti",
          withdrawals = "Isplate",
          supplies = "Zalihe",
          vehicles = "Vozila",
          salaries = "Plate",
          bonuses = "Bonusi"
        },
        errors = {
          load = "Nije moguće učitati finansijsku snimku."
        }
      },
      transactions = {
        sidebarTitle = "Sredstva",
        menuTitle = "Upravljanje sredstvima",
        currentBalance = "Trenutno stanje",
        withdrawButton = "Podigni",
        depositButton = "Uplata",
        recentTransactions = "Nedavne transakcije",
        columnNames = {
          timestamp = "Vreme",
          name = "Ime",
          action = "Akcija",
          content = "Iznos"
        },
        actions = {
          deposited = "Uplaćeni novac",
          withdrawn = "Virinut novac",
          supplies_purchased = "Kupljene zalihe",
          vehicle_purchased = "Kupljena vozila",
          vehicle_sold = "Prodata vozila",
          salary_paid = "Isplaćena plata",
          bonus_paid = "Isplaćen bonus"
        },
        errors = {
          load = "Nije moguće učitati transakcije.",
          failed = "Neuspešno završiti transakciju."
        }
      },
      billingSpecs = {
        sidebarTitle = "Predlošci fakturisanja",
        menuTitle = "Razlozi fakturisanja",
        description = "Podesite razloge koje osoblje može odabrati prilikom fakturisanja i definisati njihove Podrazumevane cene.",
        reasonColumn = "Razlog",
        priceColumn = "Cena",
        actionsColumn = "Akcije",
        reasonLabel = "Razlog fakturisanja",
        reasonPlaceholder = "npr. Odgovor na patrolu",
        amountLabel = "Podrazumevana cena",
        emptyState = "Još uvek nema dodatih razloga fakturisanja.",
        addButton = "Dodaj",
        addFirstButton = "Креирати свој први разлог",
        deleteButton = "Уклони",
        saveButton = "Сачувати",
        reasonRequired = "Унесите разлог за чување овог реда.",
        saveSuccess = "Детаљи о наплати су ажурирани.",
        saveError = "Немогуће сачувати детаљи о наплати.",
        loadError = "Немогуће учитати детаље о наплати.",
        updatedAt = "Ажурирано у {time}"
      },
      members = {
        sidebarTitle = "Чланови",
        menuTitle = "Састав",
        inviteTitle = "Позови у фракцију",
        inviteSubtitle = "Изабери играча и додели му улазни ранг.",
        selectPlayer = "Изаберите играча",
        selectRank = "Изаберите ранга",
        sendInvite = "Позови",
        columnNames = {
          name = "Име",
          rank = "Ранг",
          last_online = "Последњи пут онлине",
          total_work_time = "Време рада (х)",
          actions_done = "Изведене акције",
          actions = "Акције"
        },
        bonus = {
          title = "Постави бонус",
          confirmButton = "Исплати бонус",
          actionLabel = "Бонус",
          invalidAmount = "Унесите важећу износ бонуса.",
          failed = "Неуспешно плаћање бонуса.",
          unexpectedError = "Изненада грешка при плаћању бонуса."
        },
        errors = {
          load = "Neuspešno dohvatiti članove.",
          loadUnexpected = "Neočekivana greška prilikom dohvaćanja članova.",
          invite = "Neuspešno poslati pozivnicu.",
          inviteUnexpected = "Neočekivana greška prilikom slanja pozivnice."
        }
      },
      roles = {
        sidebarTitle = "Радне улоге",
        menuTitle = "Улоге",
        createRoleButton = "Креирај улогу",
        columnNames = {
          grade = "Степен",
          label = "Назив улоге",
          salary = "Плата",
          salaryInterval = "Интервал (мин)",
          actions = "Акције"
        },
        editMenu = {
          title = "Измени улогу",
          createTitle = "Креирај улогу",
          createSaveButton = "Креирај",
          newRoleBreadcrumb = "Нова улога",
          unnamedRole = "Безимена улога",
          gradeMeta = "Ранг {grade}",
          backButton = "Назад",
          saveButton = "Сачувај",
          general = "Генерално",
          permissions = "Дозволе",
          salary = "Плата",
          salaryDescription = "Постави плату за ову улогу.",
          salaryInterval = "Плаћање интервала",
          salaryIntervalDescription = "Изаберите колико често ова улога добија плату (у минутима рада).",
          roleName = "Назив улоге",
          roleNameDescription = "Поставите назив улоге за ову улогу.",
          highestRoleInfo = "Ово је највиши ранг и аутоматски има приступ свим дозволама."
        },
        unsavedChanges = {
          title = "Izmene koje nisu sačuvane.",
          message = "Imate izmene koje nisu sačuvane za ovu ulogu. Napustiti bez čuvanja i odbaciti izmene?",
          confirm = "Napustiti bez sačuvavanja izmene.",
          cancel = "Nastaviti uređivanje."
        },
        permissionsEmpty = "Нема пронађених дозвола.",
        permissionEntries = {
          viewLogs = {
            label = "Погледајте дневнике",
            description = "Дозволи читање дневника трансакција посла и активности."
          },
          manageRoles = {
            label = "Управљајте улогама",
            description = "Дозволи креирање, измену, премештање и брисање степеника."
          },
          manageMembers = {
            label = "Управљајте члановима",
            description = "Omogućiti promoviranje, degradiranje, otpuštanje ili isplatu bonusa."
          },
          manageWarehouse = {
            label = "Pristupiti skladištu",
            description = "Omogućiti interakciju sa zajedničkim inventarom skladišta."
          },
          manageMoney = {
            label = "Upravljati sredstvima",
            description = "Omogućiti depozit ili podizanje novca zajednice."
          },
          editOutfits = {
            label = "Uređivati odjevne kombinacije",
            description = "Omogućiti ažuriranje spremljenih unosa garderobe."
          },
          createOutfits = {
            label = "Stvoriti odjevne kombinacije",
            description = "Omogućiti stvaranje novih unosa garderobe."
          },
          deleteOutfits = {
            label = "Izbrisati odjevne kombinacije",
            description = "Omogućiti uklanjanje spremljenih unosa garderobe."
          },
          purchaseSupplies = {
            label = "Naručiti zalihe",
            description = "Omogućiti naručivanje opreme od veleprodajnog dobavljača koristeći sredstava frakcije."
          },
          purchaseVehicles = {
            label = "Kupovina vozila",
            description = "Omogućiti kupovinu novih vozačkih vozila koristeći sredstva frakcije."
          },
          garageVehicles = {
            label = "Ograničenja garažnih vozila",
            description = "Odaberite koja vozačka vozila ove uloge ne mogu pristupiti u garaži."
          },
          tabletApps = {
            label = "Ograničenja tablet aplikacija",
            description = "Odaberite koje tablet aplikacije ove uloge ne mogu pristupiti."
          },
          all = {
            label = "Puno pristupanje",
            description = "Dodjeljuje sve dozvole bez obzira na ostale opcije."
          }
        },
        permissionOptions = {
          storageHint = "Dodajte predmete koje ne možete ukloniti s ovom ulogom.",
          storageItemsTitle = "Ograničeni predmeti",
          storageWeaponsTitle = "Ograničene oružje",
          allowedWeaponsTitle = "Dopustiti oružje",
          weaponHint = "Dodajte oružje kojima ova uloga može pristupiti.",
          vehicleHint = "Odaberite vozila kojima ova uloga ne može pristupiti.",
          appHint = "Odaberite tablet aplikacije kojima ova uloga ne može pristupiti.",
          itemPlaceholder = "Upišite za dodavanje predmeta",
          weaponPlaceholder = "Upišite za dodavanje oružja",
          weaponSelectPlaceholder = "Odaberite oružje",
          vehiclePlaceholder = "Odaberite vozilo",
          appPlaceholder = "Odaberite tablet aplikaciju",
          addButton = "Dodaj",
          emptyVehicles = "Nema dostupnih vozila.",
          emptyApps = "Nema dostupnih tablet aplikacija.",
          errors = {
            empty = "Molimo unesite vrijednost.",
            duplicate = "Opcija je već dodana.",
            itemMissing = "Predmet ne postoji.",
            vehicleMissing = "Odaberite vozilo.",
            appMissing = "Odaberite tablet aplikaciju.",
            weaponMissing = "Oružje ne postoji.",
            weaponSelectMissing = "Odaberite oružje."
          }
        },
        errors = {
          save = "Neuspešno sačuvati ulogu.",
          saveUnexpected = "Neočekivana greška prilikom čuvanja uloge.",
          permissionsLoad = "Neuspešno učitavanje dozvola.",
          permissionsUnexpected = "Neočekivana greška prilikom učitavanja dozvola."
        }
      },
      logs = {
        sidebarTitle = "Dnevnici",
        menuTitle = "Dnevnici",
        errors = {
          load = "Neuspešno učitavanje logova."
        },
        columnNames = {
          timestamp = "Vremenska oznaka",
          name = "Ime",
          action = "Akcija",
          content = "Sadržaj"
        },
        actions = {
          stored = "Predmet pohranjen",
          removed = "Предмет уклоњен",
          deposited = "Новчаник депонован",
          withdrawn = "Новчаник повучен",
          outfit_created = "Позадина креирана",
          outfit_updated = "Позадина ажурирана",
          outfit_deleted = "Позадина избрисана",
          permissions_updated = "Доставе дозволе",
          invite_sent = "Позив послат",
          invite_accepted = "Позив прихваћен",
          invite_declined = "Позив одбијен",
          bonus_paid = "Бонус платит",
          member_promoted = "Члан повишен",
          member_demoted = "Члан смањен",
          member_fired = "Члан отпуштен",
          supplies_purchased = "Рефузиране залихе",
          vehicle_purchased = "Аутомобил купљен",
          vehicle_sold = "Аутомобил продат",
          salary_paid = "Isplaćena plata"
        }
      },
      dialogs = {
        deleteOutfit = {
          title = "Обрисати позадину",
          message = "Да ли заиста желите да избришете \"{name}\"?",
          confirm = "Обрисати позадину",
          cancel = "Отказати"
        }
      }
    },
    cloakroom = {
      title = "Garderoba",
      civilianClothes = "Civilne odeće",
      newOutfit = "Nova kombinacija",
      edit = {
        save = "Sačuvati",
        rotateAlt = "Rotirati",
        outfitNameTitle = "Naziv kombinacije",
        saveOutfit = "sačuvati odevnu kombinaciju"
      }
    },
    tablet = {
      apps = {
        management = "Мени шефа",
        patients = "Пацијенти",
        citizens = "Građani",
        offences = "Prekršaji",
        cases = "Slučajevi",
        social_work = "Socijalni rad",
        vehicles = "Vozila",
        weapons = "Оружје",
        prison = "Zatvor",
        warrants = "Nalozi",
        bolos = "BOLO-i",
        conditions = "Стања",
        reports = "Извештаји",
        camera = "Камера",
        gallery = "Галерија",
        map = "Мапа",
        chat = "Чет",
        calendar = "Калedar",
        calculator = "Калкулатор",
        settings = "Подешавања"
      }
    },
    common = {
      close = "Затворити",
      unknownError = "Nepoznata greška.",
      unexpectedError = "Došlo je do neočekivane greške.",
      time = {
        now = "Тренутно"
      },
      pagination = {
        prev = "Претходно",
        next = "Следеће",
        page = "Страница {current} од {total}"
      },
      gallery = {
        title = "Галерија",
        subtitle = "Изаберите фотографију или видео.",
        loading = "Утоваривање галерије...",
        empty = "Нема доступних ставки у галерији.",
        photoAlt = "Медији у галерији"
      },
      back = "Назад",
      confirm = {
        unsavedTitle = "Несачуване измене",
        unsavedMessage = "Одбацити промене или их сачувати пре напуштања?",
        unsavedDiscard = "Одбацити промене",
        unsavedSave = "Сачувати промене"
      }
    },
    reports = {
      unknown = "Непознато"
    },
    publicForms = {
      complaint = {
        fields = {
          fullName = "Пуано име",
          phone = "Број телефона",
          incidentDate = "Datum incidenta",
          incidentTime = "Vreme incidenta",
          location = "Lokacija incidenta",
          officerName = "Ime osoblja",
          badgeNumber = "Broj značke",
          description = "Detalji žalbe",
          witnesses = "Svedoci",
          desiredOutcome = "Željeno rešenje",
          email = "E-mail adresa",
          address = "Adresa stanovanja",
          signature = "Potpis"
        },
        title = "Građanska žalba",
        subtitle = "Prijaviti ponašanje osoblja ili zabrinutosti u odeljenju.",
        placeholders = {
          fullName = "Unesite svoje puno pravno ime",
          phone = "###-###-####",
          email = "ime@email.com",
          address = "Ulica, grad, država",
          incidentDate = "MM/DD/GGGBBB",
          incidentTime = "HH:MM",
          location = "Gde se dogodilo?",
          officerName = "Ime osoblja ili odeljenje",
          badgeNumber = "Broj značke ako je poznat",
          description = "Detaljno opišite šta se desilo...",
          witnesses = "Popis svedoka ili drugih strana",
          desiredOutcome = "Koji ishod tražite?",
          signature = "Ukucajte svoje puno ime"
        }
      },
      application = {
        fields = {
          fullName = "Puno ime",
          dateOfBirth = "Datum rođenja",
          phone = "Broj telefona",
          experience = "Relevantno iskustvo",
          availability = "Dostupnost",
          whyJoin = "Zašto želite da se pridružite?",
          email = "E-mail adresa",
          address = "Adresa stanovanja",
          education = "Obrazovanje",
          certifications = "Sertifikati",
          references = "Reference",
          signature = "Potpis"
        },
        title = "Prijava za posao",
        subtitle = "Prijavite se za pridruživanje odeljenju.",
        placeholders = {
          fullName = "Unesite svoje puno pravno ime",
          dateOfBirth = "MM/DD/GGGBBB",
          phone = "###-###-####",
          email = "ime@email.com",
          address = "Ulica, grad, država",
          education = "Srednja škola, akademija ili fakultet",
          experience = "Rad u zakonodavnoj, zaštitnoj ili uslužnoj ulozi",
          certifications = "Prva pomoć, oružje ili srodna obuka",
          availability = "Poželjene smene ili datum početka.",
          whyJoin = "Recite nam zašto želite da radite ovde...",
          references = "Ime i kontakt podaci",
          signature = "Otvoriti vaše puno ime"
        }
      },
      title = "Javni obrasci",
      subtitle = "Prijaviti žalbu ili prijavu za posao.",
      stationLabel = "Stanica",
      dateLabel = "Datum",
      timeLabel = "Vreme",
      stamp = {
        label = "PD",
        complaint = "CMP",
        application = "APP"
      },
      tabs = {
        complaint = "Obrazac žalbe",
        application = "Prijava za posao",
        myForms = "Moje prijave"
      },
      myForms = {
        title = "Moje prijave",
        empty = "Još niste podneli nijedan obrazac.",
        back = "Nazad",
        notesTitle = "Odgovori",
        notesEmpty = "Još nema odgovora.",
        statusNew = "Na čekanju",
        statusReviewed = "Pregledano",
        statusArchived = "Arhivirano"
      },
      actions = {
        submit = "Pošaljite obrazac",
        clear = "Obrisati polja",
        close = "Zatvoriti"
      },
      status = {
        submitting = "Slanje...",
        success = "Obrazac uspešno poslat.",
        error = "Nije moguće poslati obrazac."
      },
      errors = {
        required = "Molimo vas da popunite obavezna polja."
      }
    },
    tabletForms = {
      title = "Inbox obrazaca",
      eyebrow = "Javni Obrasci",
      listed = "pregledano",
      filters = {
        label = "Vrsta",
        all = "Svi obrasci",
        complaint = "Žalbe",
        application = "Prijave"
      },
      search = {
        placeholder = "Pretražiti po imenu, stanici ili ID-u"
      },
      status = {
        new = "Novi",
        reviewed = "Pregledano",
        archived = "Arhivirano"
      },
      state = {
        empty = "Ne postoji odgovarajući obrazac prema trenutnim filtrima.",
        loading = "Učitavanje obrazaca...",
        saving = "Čuvanje..."
      },
      errors = {
        load = "Nije moguće učitati obrasce.",
        update = "Nije moguće ažurirati status obrasca."
      },
      detail = {
        complaintTitle = "Detalji žalbe",
        applicationTitle = "Detalji prijave"
      },
      actions = {
        refresh = "Osvežiti",
        markReviewed = "Označiti kao pregledano",
        archive = "Arhivirati",
        back = "Vratiti se na listu"
      },
      notifications = {
        timeNow = "Sad",
        complaintType = "Žalba",
        applicationType = "Prijava",
        app = "Obrasci",
        title = "Novi javni obrazac",
        body = "{type} od {name} ({station})"
      },
      fields = {
        type = "Vrsta obrasca",
        id = "ID obrasca",
        station = "Stanica",
        submitted = "Поднети",
        status = "Статус",
        contact = "Контакт"
      },
      notes = {
        title = "Белешке",
        loading = "Учитавање белешки...",
        empty = "Још нема белешки.",
        placeholder = "Напишите белешку...",
        visibleBadge = "Видљиво за грађане",
        visibleToCitizen = "Видљиво за грађане",
        submit = "Додај белешку"
      }
    },
    gallery = {
      eyebrow = "Галерија доказа",
      title = "Ролна камера",
      filters = {
        all = "Све",
        camera = "Камера",
        speedcam = "Системи за брзу камеру",
        cctv = "ЦЦТВ",
        mugshot = "Мушкаратки"
      },
      labels = {
        count = "{count} фотографија",
        sort = "Најновије први",
        photoAlt = "Фотографија у галерији",
        photoFullAlt = "Пунија фотографија",
        takenBy = "Узето од",
        captured = "Заустављено",
        unknownTime = "Непознато време",
        unknownTakenBy = "Непознато"
      },
      state = {
        loading = "Учитавање снимака...",
        emptyTitle = "Још нема фотографија.",
        emptySubtitle = "Ваши последњи снимци камере ће се приказати овде."
      },
      errors = {
        load = "Немогуће учитати галерију.",
        delete = "Немогуће избрисати фотографију."
      },
      confirm = {
        deleteTitle = "Избрисати фотографију",
        deleteMessage = "Избрисати ову фотографију? Ово се не може откаЈати.",
        deleteConfirm = "Избрисати",
        deleteCancel = "Отказати"
      },
      mock = {
        caption = "РАДЕЋА НАПОМЕНА"
      }
    },
    camera = {
      help = {
        focused = "Притисните Space за омогућавање кретања.",
        blurred = "Притисните Space да бисте поново користили таблет."
      },
      mode = {
        photo = "Фотографија",
        video = "Видео",
        switchPhoto = "Променити у режим фотографије",
        switchVideo = "Променити у режим видеа"
      },
      capture = {
        photo = "Узети фотографију"
      },
      queue = {
        title = "Ред",
        empty = "Још нема пријава.",
        kind = {
          photo = "Додавање фотографије",
          video = "Додавање видеа"
        },
        status = {
          loading = "Учитавање...",
          success = "Сачувано",
          error = "Није успело"
        }
      },
      preview = {
        lastShot = "Последњи снимак",
        lastCapture = "Последњи снимак"
      },
      record = {
        start = "Започети снимање",
        stop = "Завршити снимање",
        live = "РЕЦ",
        saving = "Чување видеа...",
        name = "Камера снимак",
        description = "Таблет снимање",
        errors = {
          config = "Učitati konfiguraciju nedostaje.",
          upload = "Učitavanje nije uspjelo.",
          save = "Ne mogu da sačuvam video.",
          unsupported = "Snimanje nije podržano.",
          empty = "Još nema snimljenog videa.",
          busy = "Snimanje je zauzeto.",
          notRecording = "Snimanje je već zaustavljeno."
        }
      },
      errors = {
        timeout = "Učitavanje je isteklo.",
        capture = "Nepredviđeni greška prilikom uzimanja fotografije.",
        upload = "Učitavanje nije uspelo."
      }
    },
    cctv = {
      eyebrow = "Nadzorni mreža",
      title = "CCTV",
      listed = "spisak",
      actions = {
        refresh = "Osveži"
      },
      search = {
        placeholder = "Pretraži kamere po imenu, ID-ju ili lokaciji"
      },
      filters = {
        all = "Sve kamere",
        bodycam = "Kameri na telu",
        dashcam = "Dash kamera",
        cctv = "CCTV kamere",
        speedcam = "Kamere za brzinu"
      },
      types = {
        bodycam = "Kamera na telu",
        dashcam = "Dash kamera",
        speedcam = "Kamera za brzinu",
        cctv = "CCTV kamera"
      },
      status = {
        online = "Na mreži",
        maintenance = "Održavanje",
        offline = "Nedostupno"
      },
      live = {
        active = "Uživo aktivno",
        maintenance = "Feed je pauziran radi održavanja",
        offline = "Signal je izgubljen",
        placeholderTitle = "Feed nije dostupan",
        placeholderSubtitle = "Izaberite osobu sa podrškom za kameru na telu.",
        speedcamPlaceholderTitle = "Kamera za brzinu offline",
        speedcamPlaceholderSubtitle = "Popravite ili zamenite uređaj da biste obnovili feed."
      },
      labels = {
        speedcamLocation = "Ulica uz puta",
        onDuty = "Na dužnosti",
        durability = "Izdržljivost"
      },
      state = {
        loading = "Učitavanje kamera...",
        empty = "Nema kamera koje odgovaraju trenutnim filterima.",
        select = "Izaberite kameru da biste videli njen feed."
      },
      controls = {
        tiltUp = "Nagni se na gore",
        panLeft = "Skreni levo",
        panRight = "Skreni desno",
        tiltDown = "Nagni se na dole"
      },
      capture = {
        name = "Video-nadzor - {label}",
        description = "{location} ({id})",
        saved = "Sačuvano u galeriji.",
        error = "Ne mogu da uhvatim sliku.",
        action = "Uhvati",
        loading = "Uhvatanje..."
      },
      record = {
        name = "CCTV klip - {label}",
        description = "{location} ({id})",
        save = "Sačuvaj poslednjih {minutes} min",
        saving = "Čuvanje...",
        requested = "Zahtev za čuvanje poslat.",
        saved = "Video sačuvan u galeriji.",
        errors = {
          config = "Nedostaje konfiguracija za prijenos.",
          upload = "Prijenos nije uspeo.",
          save = "Nije moguće sačuvati video.",
          unsupported = "Snimanje nije podržano.",
          empty = "Još nema dostupnog bafera.",
          request = "Nije moguće zatražiti video zapis sa kamere.",
          timeout = "Vreme za čuvanje bodycam-a je isteklo.",
          busy = "Snimanje je zauzeto.",
          notRecording = "Snimanje je već zaustavljeno."
        }
      },
      waypoint = {
        set = "Tačka postavljena.",
        missing = "Lokacija nije dostupna."
      },
      errors = {
        load = "Nije moguće učitati kamere."
      }
    },
    chat = {
      targets = {
        allUnits = "Razgovor svih jedinica",
        centralDispatch = "Centralni dispečing"
      },
      header = {
        eyebrowRoom = "Službena kanal za osoblje",
        eyebrowPrivate = "Privatna linija",
        metaRoom = "Soba",
        metaDirect = "Direktno",
        metaStaff = "Osoblje"
      },
      sidebar = {
        eyebrow = "Komunikacije",
        title = "Mreža osoblja",
        groupTitle = "Grupni razgovor",
        allUnits = "Sve jedinice",
        staffTitle = "Osoblje",
        loading = "Učitavanje osoblja...",
        empty = "Nema dostupnog osoblja."
      },
      staff = {
        unknownMember = "Nepoznati član osoblja",
        onDuty = "Na dužnosti",
        offDuty = "Van dužnosti",
        grade = "Razred {level}",
        fallback = "Osoblje"
      },
      composer = {
        placeholderRoom = "Napisati izveštaj o odeljenu...",
        placeholderDirect = "Poruka {name}...",
        pendingAlt = "Na čekanju podela"
      },
      messages = {
        avatarAlt = "Avatar {name}",
        avatarFallback = "Avatar osoblja",
        unknownAuthor = "Nepoznato",
        sharedEvidenceAlt = "Dokaz podeljen",
        tapToExpand = "Tapnite za proširenje"
      },
      preview = {
        ready = "Mediji spremni za slanje"
      },
      profile = {
        action = "Podesiti profilnu fotografiju",
        galleryTitle = "Podesiti profilnu fotografiju",
        gallerySubtitle = "Izabrati fotografiju za vašu timsku ikonu.",
        photoAlt = "Profilna fotografija",
        selfPhotoAlt = "Profilna fotografija",
        error = "Nije moguće ažurirati profilnu fotografiju."
      },
      actions = {
        remove = "ukloniti",
        send = "slati"
      },
      state = {
        syncing = "sinhronizacija poruka...",
        emptyRoom = "Još nema ćaskanja.",
        emptyPrivate = "Još nema privatnih poruka.",
        emptyRoomHint = "Budite prvi koji će se prijaviti sa jedinicom.",
        emptyPrivateHint = "Započnite direktnu komunikaciju sa ovim članom tima."
      },
      errors = {
        load = "Nije moguće učitati istoriju čavrljanja.",
        send = "Nije moguće poslati poruku.",
        members = "Nije moguće učitati osoblje."
      }
    },
    bossMenu = {
      header = {
        eyebrow = "Meni šefa",
        title = "Upravljanje",
        balanceLabel = "Saldo"
      },
      state = {
        loading = "Učitavanje podataka o upravljanju..."
      }
    },
    tabletSettings = {
      header = {
        eyebrow = "Postavke tableta",
        title = "Personalizacija",
        modeLabel = "Način",
        modeLight = "Svetlo",
        modeDark = "Tamno"
      },
      appearance = {
        title = "Izgled",
        description = "Prebacite interfejs između svetlog i tamnog režima.",
        light = "Svetlo",
        dark = "Tamno"
      },
      wallpaper = {
        title = "Tapeta",
        description = "Koristite podrazumevanu pozadinu, izaberite iz galerije ili dodajte sopstvenu link.",
        labels = {
          default = "Podrazumevana pozadina",
          gallery = "Fotografija iz galerije",
          url = "Prilagođeni URL"
        },
        useDefault = "Koristi podrazumevanu",
        chooseGallery = "Izaberite iz galerije",
        customUrlLabel = "Prilagođeni URL slike",
        customUrlPlaceholder = "https://example.com/wallpaper.jpg",
        apply = "Primeni",
        hint = "Najbolji rezultati sa slikama 1920x1080 ili većim rezolucijama."
      }
    },
    calendar = {
      weekdays = {
        mon = "Pon",
        tue = "Uto",
        wed = "Sri",
        thu = "Čet",
        fri = "Pet",
        sat = "Sub",
        sun = "Ned"
      },
      selectedDateFallback = "Izaberite datum",
      header = {
        eyebrow = "Zajednički kalendar",
        title = "Raspored osoblja",
        metaPrimary = "Vidljivo svim članovima tima",
        metaSecondary = "Svi mogu dodavati unose",
        hint = "Dodirnite dan za dodavanje smene ili događaja"
      },
      actions = {
        dayEntries = "Unosi za dan",
        addEntry = "Dodaj unos"
      },
      today = "Danas",
      more = "+{count} више",
      modal = {
        addEntry = {
          eyebrow = "додати унос",
          titleLabel = "Наслов",
          titlePlaceholder = "Премјестити извјештај, обуку, патролу",
          datetimeLabel = "Датум и време",
          colorLabel = "Боја",
          clear = "Обриши",
          submit = "Додај у календар"
        },
        dayEntries = {
          eyebrow = "Радни уноси",
          empty = "Још нема уноса. Додајте извештај или патролу за дељење са јединицом."
        }
      }
    },
    calculator = {
      header = {
        eyebrow = "Инструменти поља",
        title = "Калкулатор",
        modeLabel = "Мод"
      },
      keys = {
        clearAll = "АЦ",
        clearEntry = "ЦЕ"
      },
      mode = {
        standard = "Стандард"
      },
      status = {
        resetRequired = "Потребно ресетовање",
        ready = "Спремно"
      },
      errors = {
        error = "Грешка"
      }
    },
    tabletHome = {
      status = {
        defaultDate = "Понедељак, 01. јануар"
      },
      calendar = {
        eventToday = "Догађај данас",
        eventTomorrow = "Догађај сутра",
        allDay = "Цео дан",
        timeAt = " у {time}"
      },
      chat = {
        messageFrom = "Порука од {name}",
        newMessage = "Нова порука",
        authorFallback = "Радно",
        messageBody = "{author}: {message}",
        sentPhoto = "{author} је послао фотографију.",
        sentMessage = "{author} је послао поруку."
      },
      notifications = {
        title = "Обавештења",
        clearAll = "Обриши све",
        empty = "Све потписано."
      }
    },
    map = {
      eyebrow = "Мапа радног стола",
      title = "Греда Сан Андреас",
      markerLabel = "Маркер",
      markerTypes = {
        label = "Листа маркера",
        dispatch = "Диспач",
        officers = "Људи у радном тиму",
        speedcams = "Авто-камере",
        vehicles = "Возила",
        trackers = "Трагачи"
      },
      markerList = {
        listed = "написано",
        officersTitle = "Радна листа особља",
        speedcamsTitle = "Листа брзинских камера",
        vehiclesTitle = "Табла за возила",
        trackersTitle = "Табла трагачa",
        officersEmpty = "Нема радних тима на дужности.",
        speedcamsEmpty = "Нема доступних брзинских камера.",
        trackersEmpty = "Нема онлајн трагача.",
        vehiclesEmpty = "Nema vozila na mreži."
      },
      dispatch = {
        title = "Tabla za razduženje",
        empty = "Trenutno nema razduženja.",
        status = {
          active = "Aktivno",
          accepted = "Prihvaćeno",
          done = "Obavljeno"
        },
        panelTitle = "Detalji razduženja",
        statusLabel = "Stanje",
        acceptedBy = "Prihvaćeno od",
        doneBy = "Završeno od",
        coords = "Koordinate",
        actions = {
          accept = "Prihvatiti",
          done = "Označiti kao obavljeno",
          delete = "Obrisati"
        },
        unknown = "Nepoznato"
      },
      status = {
        available = "Dostupno",
        busy = "Zauzeto",
        pursuit = "U potrazi",
        offDuty = "Van dužnosti"
      },
      vehicle = {
        status = {
          active = "Aktivno",
          offline = "Isključeno"
        }
      },
      tracker = {
        status = {
          active = "Aktivno",
          offline = "Neaktivan"
        }
      },
      speedcam = {
        status = {
          online = "Na mreži",
          maintenance = "Održavanje",
          offline = "Neaktivan"
        }
      },
      officerPanel = {
        title = "Detalji osoblja",
        callsign = "Pozivni kod {id}",
        rank = "Rang",
        health = "Zdravstveno stanje",
        coords = "Koordinate",
        lastUpdateUnknown = "Upravo sad"
      },
      speedcamPanel = {
        title = "Detalji merne kamere",
        limit = "Ograničenje",
        tolerance = "Tolerancija",
        health = "Zdravlje",
        coords = "Koordinate"
      },
      vehiclePanel = {
        title = "Detalji vozila",
        plate = "Tablica {plate}",
        netId = "Mrežni ID",
        health = "Zdravstveno stanje",
        coords = "Koordinate"
      },
      trackerPanel = {
        title = "Detalji tragaca",
        plate = "Tablica {plate}",
        attachedBy = "Učvršćeno od",
        attachedAt = "Učvršćeno",
        netId = "Mrežni ID",
        status = "Stanje",
        coords = "Koordinate"
      },
      actions = {
        openCctv = "Otvoreni CCTV",
        setWaypoint = "Postavi tačku"
      },
      waypoint = {
        set = "Tačka postavljena.",
        missing = "Lokacija nije dostupna."
      },
      signalLost = "Signal izgubljen",
      styles = {
        atlas = "Atlas",
        roads = "Ceste",
        satellite = "Satelit"
      },
      missing = {
        title = "Nedostaje slika mape",
        body = "Postavite slike mape u frontend/public/img."
      },
      details = {
        title = "Detalji",
        empty = "Izaberite marker da biste videli detalje."
      },
      zones = {
        title = "Zone isključivanja",
        untitled = "Zona bez naziva",
        hint = "Kliknite na mapu da dodate tačke. Minimalno 3.",
        pointCount = "{count} tačke",
        empty = "Još uvek nema zona isključivanja.",
        actions = {
          toggle = "Zone",
          new = "Nova zona",
          cancel = "Otkaži",
          save = "Sačuvaj zonu",
          undo = "Poništi",
          clear = "Očisti",
          delete = "Obriši"
        },
        modal = {
          title = "Ime zone isključivanja",
          confirm = "Sačuvaj zonu"
        },
        errors = {
          points = "Dodajte najmanje 3 tačke.",
          nameRequired = "Unesite ime zone.",
          saveFailed = "Nije moguće sačuvati zonu isključivanja.",
          deleteFailed = "Nije moguće obrisati zonu isključivanja."
        }
      },
      monitorZones = {
        title = "Zone monitora gleža",
        untitled = "Zona bez naziva",
        hint = "Kliknite na mapu da dodate tačke. Minimalno 3.",
        pointCount = "{count} tačke",
        empty = "Još uvek nema zona monitora.",
        mode = {
          allow = "Dozvoljena zona",
          exclude = "Ograničena zona"
        },
        actions = {
          allow = "Dozvoljena zona",
          exclude = "Ograničena zona",
          cancel = "Otkaži",
          save = "Sačuvaj zonu",
          undo = "Poništi",
          clear = "Očisti",
          delete = "Obriši"
        },
        modal = {
          title = "Ime zone monitora",
          confirm = "Sačuvaj zonu"
        },
        errors = {
          points = "Dodajte najmanje 3 tačke.",
          nameRequired = "Unesite ime zone.",
          noMonitor = "Izaberite gležnjačar za nadzor.",
          saveFailed = "Nije moguće sačuvati zonu monitora.",
          deleteFailed = "Nije moguće obrisati zonu monitora."
        }
      },
      panic = {
        panelTitle = "Detalji panike",
        triggeredBy = "Pokrenuto od strane",
        createdAt = "Pokrenuto",
        coords = "Koordinate"
      },
      dev = {
        officerName = "Zaposleni Avery Lane",
        callsign = "LIN-23",
        rank = "Poručnik",
        unit = "Centralna patrola",
        speedcamName = "Del Perro radar za brzinu",
        vehicleName = "Jednica 12",
        trackerName = "Sledilac ALPHA",
        trackerOfficer = "Zaposleni Ruiz",
        dispatchTitle = "Oštećen radar za brzinu",
        dispatchMessage = "Del Perro jedinica zahteva održavanje.",
        panicOfficer = "Zaposleni Sinclair",
        panicLocation = "Misija Redovni"
      }
    },
    panicNotification = {
      badge = "Panika",
      title = "Upozorenje za paniku",
      subtitle = "{name} je pritisnuo dugme za paniku.",
      callsign = "Pozivni znak {id}",
      locationLabel = "Lokacija",
      locationUnknown = "Nepoznata lokacija",
      hint = "Pritisnite {key} da biste postavili tačku na karti u igri."
    },
    incidentNotification = {
      panic = {
        title = "Alarm panike",
        subtitle = "{name} je pritisnulo dugme panike."
      },
      dispatch = {
        title = "Dispečersko upozorenje",
        subtitle = "{name} je podelio novi dispečerski zadatak."
      },
      ping = {
        title = "Ping lokacije",
        subtitle = "{name} je podelio ping uživo lokacije."
      },
      actions = {
        openMap = {
          key = "M",
          label = "Videti u Tablet Map App"
        },
        setWaypoint = {
          key = "G",
          label = "Postaviti putanju"
        },
        dismiss = {
          key = "Backspace",
          label = "Zatvoriti obaveštenje"
        }
      }
    },
    employeeGpsJammer = {
      title = "GPS ometač",
      disabled = "GPS ometanje nije dostupno.",
      success = "GPS signal zaposlenog je prekinut.",
      failed = "Nije moguće prekinuti GPS signal.",
      targetJammed = "Vaš GPS signal tokom dežurstva se ometa.",
      errors = {
        disabled = "GPS ometanje nije dostupno.",
        no_players = "Nema osoba u blizini.",
        too_far = "Priđite bliže pre korišćenja GPS ometača.",
        invalid_target = "Nije moguće pronaći tu osobu.",
        not_on_duty = "Ova osoba nema aktivan GPS signal tokom dežurstva.",
        protected_job = "Ovaj GPS signal zaposlenog je zaštićen.",
        missing_item = "Potreban vam je GPS ometač za ovo.",
        cooldown = "Sačekajte trenutak pre ponovnog korišćenja GPS ometača.",
        failed = "Nije moguće prekinuti GPS signal.",
      },
    },
    gradeChange = {
      promotedTitle = "Povlastica",
      demotedTitle = "Smanjenje",
      unchangedTitle = "Poredak ažuriran",
      previousLabel = "Prethodni rang",
      newLabel = "Sadašnji rang",
      unknownLabel = "Nepridruženi rang",
      levelFallback = "Смертна оцена {level}"
    },
    bonusNotification = {
      title = "Додела бонуса",
      subtitle = "Од {name}",
      amountLabel = "Бонус",
      unknownManager = "Менаџмент"
    },
    wheelClamp = {
      attached = "Клизачок је причвршћен"
    },
    search = {
      previewTitle = "Истражује {name}",
      previewSubtitle = "Снимање имовине за оружје и злоупотребе...",
      previewCancel = "Притисните X за отказивање",
      unknownTarget = "Непознато"
    },
    heliCamHud = {
      title = "Контроле камере хелијума",
      actions = {
        toggleCam = "Прекинути камеру",
        vision = "Прекинути виђење",
        spotlight = "Режим радарске светлости",
        lockTarget = "Закључај циљ",
        display = "Прекинути приказ",
        takePhoto = "Заснимити фотографију",
        rappel = "Спуштање",
        brightness = "Осветљење",
        radius = "Радијус"
      }
    },
    jailHud = {
      title = "Преостало време",
      trashLabel = "Контејнер за смеће",
      trashFull = "Пут пуне кесе",
      trashDropoff = "Доставити до контејнера за смеће"
    },
    jailJobs = {
      title = "Радни задатак у затвору",
      subtitle = "Izabrati zadatak za ispunjenje vremena.",
      actions = {
        cleaning = "Očistiti",
        gardening = "Gajiti baštu",
        carry_goods = "Nošenje robe"
      },
      currentJob = "Trenutni posao:",
      stop = "Prekinuti posao",
      close = "Zatvoriti",
      contraband = {
        title = "Kundak",
        message = "Pronašli ste {item}. Da li želite rizikovati i zadržati ga, ili ga baciti?",
        keep = "Zadržati",
        toss = "Baciti"
      },
      boxInspect = {
        title = "Pregledaj kutiju",
        message = "Unutra ste našli {item}. {description}",
        take = "Uzeti",
        leave = "Ostaviti unutra",
        close = "Zatvoriti"
      }
    },
    socialWork = {
      eyebrow = "Usluge zajednice",
      title = "Socijalni rad",
      listed = "detaljno",
      search = {
        placeholder = "Pretraži po imenu ili ID-u"
      },
      filters = {
        all = "Svi",
        label = "Status",
        placeholder = "Status"
      },
      actions = {
        refresh = "Osveži",
        back = "Nazad na listu"
      },
      state = {
        loading = "Učitavanje usluga zajednice...",
        empty = "Nema usluga zajednice koje se poklapaju sa trenutnim filterima."
      },
      status = {
        active = "Aktivan",
        overdue = "Prekoračen",
        completed = "Završeno",
        imprisoned = "Zatvoren u zatvor"
      },
      labels = {
        remainingShort = "preostalo",
        imprison = "Zatvor",
        imprisonNotice = "Rok prošao. Potreban je zatvor.",
        noDeadline = "Nema roka",
        expired = "Isteklo"
      },
      sections = {
        summary = "Rezime usluge",
        summarySubtitle = "Pregled dodeljenih zadataka."
      },
      fields = {
        name = "Ime",
        status = "Status",
        remaining = "Preostali zadaci",
        completed = "Završeni zadaci",
        total = "Ukupno zadataka",
        assigned = "Dodeljeno",
        deadline = "Rok",
        timeLeft = "Preostalo vremena",
        assignedBy = "Dodeljeno od",
        unknown = "Nepoznato"
      },
      assign = {
        title = "Dodeliti usluge zajednice",
        subtitle = "Pošaljite susednog igrača na zadatke socijalnog rada.",
        playerLabel = "Играч",
        playerPlaceholder = "Izabrati igrača",
        taskLabel = "Zadaci",
        taskPlaceholder = "Broj zadataka",
        deadlineLabel = "Vremensko ograničenje (minut)",
        deadlinePlaceholder = "Opcionalno",
        submit = "Dodeliti",
        success = "Društvena služba dodeljena.",
        error = "Ne mogu da dodelim društvenu službu."
      },
      errors = {
        load = "Ne mogu da učitam društvenu službu."
      },
      date = {
        unknown = "Nepoznato"
      },
      jobs = {
        title = "Društvena služba",
        subtitle = "Izaberite zadatak za završetak vaše rečenice.",
        currentJob = "Trenutni zadatak:",
        stop = "Zaustavi zadatak",
        actions = {
          cleaning = "Čišćenje",
          carry_goods = "Nošenje stvari"
        }
      },
      hud = {
        title = "Društvena služba",
        remaining = "Preostalih zadataka",
        completed = "Završeni zadaci",
        deadline = "Preostalo vreme",
        expired = "Isteklo",
        trashLabel = "Otpad",
        trashFull = "Pun ranac",
        trashDropoff = "Dostavi do kontejnera"
      }
    },
    socialWorkCreator = {
      title = "Kreator društvenog rada",
      description = "Podesiti lokacije društvenih službi u gradu.",
      empty = "Još nema konfigurisanih lokacija društvenog rada.",
      keyboardHint = "Koristite strelice za navigaciju kroz listu i akcije.",
      editTitle = "Oznake društvenog rada",
      editSubtitle = "Koristite dugme za tačku na mapi za čuvanje trenutnih koordinata.",
      editKeyboardHint = "Koristite strelice za odabir oznake, levo/desno za izabrati Postavi/Obriši, Enter za pokretanje, Backspace za nazad.",
      missingEntry = "Nije pronađena lokacija društvenog rada.",
      actions = {
        newSite = "Nova lokacija"
      },
      status = {
        set = "Postavi",
        unset = "Obriši"
      },
      markers = {
        social_work_job_npc = "NPC poslova",
        social_work_dumpster = "Kante za smeće",
        social_work_box_dropoff = "Donošenje stvari na odlaganje"
      },
      modals = {
        createTitle = "Kreiraj lokaciju",
        createButton = "Kreiraj lokaciju",
        renameTitle = "Preimenuj lokaciju",
        renameButton = "Sačuvaj ime",
        deleteTitle = "Obriši lokaciju",
        deleteMessage = "Da li zaista želite da uklonite {name}?",
        deleteConfirmLabel = "Obriši",
        deleteCancelLabel = "Otkaži"
      }
    },
    impoundCreator = {
      title = "Kreator oduzetišta",
      description = "Podesiti lokacije i tačke za pojavljivanje oduzetišta.",
      empty = "Još nema konfigurisanih oduzetišta.",
      keyboardHint = "Koristite strelice za navigaciju kroz listu i radnje.",
      editTitle = "Oznake za zatar",
      editSubtitle = "Koristite dugme za komentar na mapi da biste sačuvali trenutne koordinate.",
      editKeyboardHint = "Koristite strelice za odabir oznake, levo/desno za izbor Postavi/Obriši/Izbrisi, Enter za izvršavanje, Backspace za povratak. Pređite pored liste da biste stigli do dugmadi za dodavanje.",
      missingEntry = "Lopta za zatar nije pronađena.",
      actions = {
        newLot = "Nova lopta",
        add = {
          impound_delivery = "Dodaj odlagalište",
          impound_spawn = "Dodaj mesto za spawn"
        }
      },
      status = {
        set = "Postavi",
        unset = "Ukloni"
      },
      markers = {
        impound_lot = "Lopta za zatar",
        impound_spawn = "Spawn za zatar",
        impound_delivery = "Odlagalište za zatar"
      },
      modals = {
        createTitle = "Kreirajte lopti",
        createButton = "Kreirajte lopti",
        renameTitle = "Preimenujte lopti",
        renameButton = "Sačuvaj naziv",
        deleteTitle = "Obrišite lopti",
        deleteMessage = "Da li zaista želite da uklonite {name}?",
        deleteConfirmLabel = "Obriši",
        deleteCancelLabel = "Otkaži"
      }
    },
    impoundStorage = {
      title = "Skladište za zatar",
      subtitle = "Naruči parkirane automobile da budu isporučeni u odlagalište.",
      empty = "Nema parkiranih vozila za ovo odlagalište.",
      emptyAll = "Nema zatarenih vozila pronađenih.",
      unknownModel = "Nepoznat",
      unknownLot = "Nepoznat",
      sections = {
        impounds = "Aktivne oduzimanju",
        stored = "Skladištena vozila"
      },
      columns = {
        plate = "Registarska oznaka",
        model = "Model",
        stored = "Skladišteno",
        lot = "Lokacija",
        status = "Stanje",
        fee = "Naknada za skladištenje"
      },
      actions = {
        deliver = "Poručiti isporuku",
        allowPickup = "Dozvoli preuzimanje",
        seize = "Označiti kao zaplenjeno",
        seized = "Zaplenjeno",
        close = "Zatvoriti",
        refresh = "Osvježiti"
      },
      status = {
        pickup = "Dozvoljeno preuzimanje",
        seized = "Zaplenjeno"
      },
      time = {
        days = "{count} dan/a"
      },
      errors = {
        load = "Nije moguće učitati skladištena vozila.",
        deliver = "Nije moguće naručiti isporuku.",
        seized = "Ovaj vozilo je zaplenjeno zbog istrage.",
        update = "Nije moguće ažurirati status oduzima."
      }
    },
    impoundDecision = {
      title = "Odluka o oduzimanju",
      message = "Odlučiti da li {vehicle} može biti preuzeto ili zaplenjeno zbog istrage.",
      vehicleFallback = "ovisi vozilo",
      allowPickup = "Dozvoli preuzimanje",
      seize = "Zaposliti na ispitivanje"
    },
    jailCreator = {
      title = "Kreator zatvora",
      description = "Postavite tačke za spawn zatvora i upravljajte lokacijama.",
      empty = "Još nema konfigurisanih zatvora.",
      keyboardHint = "Koristite strelice za navigaciju kroz listu i radnje.",
      editTitle = "Oznake zatvora",
      editSubtitle = "Koristite dugme za mapu za skladištenje trenutnih koordinata.",
      editKeyboardHint = "Koristite strelice za odabir oznake, levo/desno za Odredi/Očisti/Obriši, Enter za izvršenje, Backspace za povratak. Pomaknite se pored liste da biste došli do dugmadi za Dodavanje.",
      missingEntry = "Zatvor nije pronađen.",
      actions = {
        newJail = "Novi zatvor"
      },
      modals = {
        createTitle = "Kreirajte zatvor",
        createButton = "Kreirajte zatvor",
        renameTitle = "Preimenuj zatvor",
        renameButton = "Sačuvaj ime",
        deleteTitle = "Obrišite zatvor",
        deleteMessage = "Da li zaista želite da uklonite {name}?",
        deleteConfirmLabel = "Obriši",
        deleteCancelLabel = "Otkaži"
      }
    },
    jailInmates = {
      title = "Preprodaja zatvorenika",
      close = "Zatvori",
      trade = "Provedi razmenu",
      requiredLabel = "Dajete",
      rewardLabel = "Dobijate",
      acceptedLabel = "{'text': 'Prihvatiti'}",
      contrabandLabel = "{'text': 'Konzalna roba'}",
      npc = {
        alcoholic = "{'text': 'Celačka pijanica'}",
        drugDealer = "{'text': 'Preprodavac u praonici'}",
        doctor = "{'text': 'Lekar u zatvoru'}",
        canteen = "{'text': 'Kuhar u kantini'}"
      },
      dialogs = {
        alcoholic = {
          one = "{'text': 'Jednom sam zamenio svoj desert za mop. Najbolji dan u životu.'}",
          two = "{'text': 'Da postoji bar u ovom mestu, bio bih zaposleni meseca.'}",
          three = "{'text': 'Imate li nešto što miriše na čiste podove i loše odluke?'}",
          four = "{'text': 'Zovem ga zatvorski kolonjom. Vi ga zovete alkohol za čišćenje.'}"
        },
        drugDealer = {
          one = "{'text': 'Imate li nešto začinjeno od smeća? Plaćam u dimovima.'}",
          two = "{'text': 'Tiho, čuvari misle da sam u klubu knjiga.'}",
          three = "{'text': 'Donesi mi zabranjene stvari i učiniću da tvoj dan bude dimljiv.'}",
          four = "{'text': 'Smeće skriva blago. Ja sam procenitelj blaga.'}"
        },
        doctor = {
          one = "{'text': 'Stani. Biće brzo.'}",
          two = "{'text': 'Danas bez naplate. Samo ostani na putu.'}",
          three = "{'text': 'Izgledaš umorno. Dopusti mi da te zaliječim.'}",
          four = "{'text': 'Radno vreme klinike nikada ne završava ovde.'}"
        },
        canteen = {
          one = "{'text': 'Danas je novi tanjir. Formiraj red i kreni dalje.'}",
          two = "{'text': 'Želiš li vrući obrok ili predavanje?'}",
          three = "{'text': 'Dobar ponašanje dobija drugi tanjir. Uglavnom.'}",
          four = "{'text': 'Video sam gore od toga.'}"
        }
      },
      doctor = {
        costLabel = "{'text': 'Cena'}",
        rewardLabel = "{'text': 'Lečenje'}",
        actionLabel = "{'text': 'Dobiti lečenje'}",
        costValue = "Бесплатно",
        rewardValue = "Потпуни третман"
      },
      canteen = {
        costLabel = "Цена",
        rewardLabel = "Оброк",
        actionLabel = "Захтев за оброк",
        costValue = "Бесплатно",
        rewardValue = "Пакет хране"
      },
      items = {
        cleaning_alcohol = "Чишћење алкохола",
        cigarettes = "Цигарете",
        coke = "Кока-кола",
        weed = "Мајмунче",
        burger = "Љуљашка",
        water = "Вода"
      }
    },
    invites = {
      title = "Покана за посао",
      description = "Придружите се {job} као {role}?",
      invitedBy = "Позван од {name}",
      expires = "Ова понуда истиче ускоро.",
      accept = "Прихватити",
      decline = "Одбити",
      errors = {
        missing = "Позив незамислив.",
        failed = "Грешка у одговору на позив."
      }
    },
    stationCreator = {
      title = "Создавац станице",
      description = "Конфигуриши позиције маркера станице.",
      empty = "Још нема конфигурација станица.",
      keyboardHint = "Користите ↑/↓ за избор, ←/→ за прелазак између радњи, Enter за потврду, Backspace за затварање.",
      editTitle = "Маркери станица",
      editSubtitle = "Користите тастер за бодље мапе да бисте снимљили тренутне координате.",
      editKeyboardHint = "Користите ↑/↓ за одабир маркера, ←/→ за бирање Постави/Обриши/Избриши, Enter за покретање, Backspace за повратак.",
      sections = {
        markers = "Маркери",
        zone = "Зона затвора"
      },
      zone = {
        subtitle = "Додајте тачке зоне како бисте одредили границу затвора.",
        hint = "Користите тастер за бодље мапе да бисте додали тачке. Уклоните тачке коришћењем иконице смећа.",
        empty = "Још нема тачака зоне.",
        pointLabel = "Тачка зоне {index}",
        actions = {
          add = "Додајте тачку зоне",
          update = "Ажурирај",
          clear = "Обриши зону"
        }
      },
      missingStation = "Станица није пронађена.",
      actions = {
        newStation = "Нова станица",
        editJobBlip = "Уреди ознаку посла",
        newJail = "Нова затворска зона",
        add = {
          wardrobe = "Додајте маркер гардеробе",
          garage_vehicle_menu = "Додајте интеракцију гараже возила",
          garage_vehicle_spawn = "Додајте спаун гараже возила",
          garage_vehicle_park = "Додајте паркирање гараже возила",
          garage_helicopter_menu = "Додајте интеракцију хелипада",
          garage_helicopter_spawn = "Додајте спаун хелипада",
          garage_helicopter_park = "Додајте паркирање хелипада",
          garage_boat_menu = "Dodati interakciju na pristaništu",
          garage_boat_spawn = "Dodati tačku pojavljivanja na pristaništu",
          garage_boat_park = "Dodati parking na pristaništu",
          boss_menu = "Додајте маркер за менаџера",
          wholesale_shop = "Додајте маркер велепродајне радње",
          duty_terminal = "Додајте маркер за термину задатка",
          public_forms = "Dodati kioske za javne obrasce",
          jail_solitary_cell = "Dodati ćeliju za samotnjak"
        }
      },
      status = {
        set = "Postaviti",
        unset = "Ukloniti"
      },
      markers = {
        position = "Pozicija stanice",
        storage = "Skladište",
        locker = "Sef",
        wardrobe = "Garderoba",
        duty_terminal = "Terminal za dužnost",
        public_forms = "Kiosk za javne obrasce",
        boss_menu = "Meni šefa",
        garage_vehicle_menu = "Interakcija sa garažom vozila",
        garage_vehicle_spawn = "Spawn vozila u garaži",
        garage_vehicle_park = "Parkiranje vozila u garaži",
        garage_helicopter_menu = "Interakcija sa helipadom",
        garage_helicopter_spawn = "Spawn helikoptera na helipad-u",
        garage_helicopter_park = "Parkiranje helikoptera na helipad-u",
        garage_boat_menu = "Interagovati na pristaništu",
        garage_boat_spawn = "Pojaviti se na pristaništu",
        garage_boat_park = "Parkirati na pristaništu",
        wholesale_shop = "Velika prodavnica",
        jail_spawn = "Spawn za zatvor",
        jail_release = "Mesto za otpuštanje",
        jail_menu = "Terminal za zatvor",
        jail_job_npc = "NPC za posao u zatvoru",
        jail_inmate_alcoholic = "Zatvorenik: Alkoholik",
        jail_inmate_drugdealer = "Zatvorenik: Diler drogue",
        jail_inmate_doctor = "Zatvorenik: Doktor",
        jail_canteen_cook = "Kuhar u kantini",
        jail_dumpster = "Jail kanta za đubre",
        jail_box_dropoff = "Prebacivanje na odlagalište",
        jail_electric_box = "Električni ormar",
        jail_fence_cut = "Tačka presecanja žice",
        jail_fence_exit = "Izlaz sa žice",
        jail_solitary_cell = "Ćelija za samotnjak",
        jail_confiscated_return = "Oduzeti predmeti"
      },
      modals = {
        createTitle = "Kreirati stanicu",
        createButton = "Kreirati stanicu",
        renameTitle = "Preimenovati stanicu",
        renameButton = "Sačuvati ime",
        deleteTitle = "Obrisati stanicu",
        deleteMessage = "Da li zaista želite da uklonite {name}?",
        deleteConfirmLabel = "Obrisati",
        deleteCancelLabel = "Otkaži",
        jobBlipTitle = "Oznaka posla: {job}",
        jobBlipMessage = "Podesi oznaku stanice za ovaj posao. Onemogući ako ovaj posao ne treba da ima oznaku stanice.",
        jobBlipSave = "Sačuvaj oznaku",
        jobBlipReset = "Resetuj",
        jobBlipInvalidNumber = "Nevažeća vrednost za {field}."
      },
      blip = {
        enabled = "Prikaži oznaku",
        useStationName = "Dodaj naziv stanice",
        shortRange = "Kratki domet",
        name = "Naziv",
        sprite = "Ikona",
        color = "Boja",
        scale = "Veličina",
        display = "Prikaz"
      }
    },
    jailAssign = {
      title = "Poslati u zatvor",
      selectPlayer = "Izabrati igrača",
      selectPlayerPlaceholder = "Izabrati igrača",
      selectJail = "Izabrati zatvor",
      selectJailPlaceholder = "Izabrati lokaciju zatvora",
      solitaryLabel = "Samotnjak",
      solitaryUnavailable = "Nema konfigurisanih ćelija za samoću u ovom zatvoru.",
      durationLabel = "Trajanje (meseci)",
      monthHint = "1 mesec = {minutes} minuta",
      cancelButton = "Otkaži",
      assignButton = "Клопити у затвор",
      assigning = "Покушати у затвор...",
      noPlayers = "Немају блиских играча унутар {range} м.",
      noJails = "Још увек није конфигурисана ни једна затворска јединица. Прво користите ствараоца затвора.",
      spawnMissing = "Овај затвор нема постављено место спавања.",
      jailStatusReady = "Спаво спремно",
      jailStatusMissing = "Нема постављеног спавења",
      success = "Играчу је послате у затвор на {months} месеци.",
      errors = {
        invalid_target = "Изаберите блиског играча и затвор.",
        spawn_not_set = "Овај затвор нема постављено место спавања.",
        solitary_unavailable = "Нема конфигурисаних јединица за самоћу у овом затвору.",
        failed = "Неуспешно послати играча у затвор."
      }
    },
    bolos = {
      eyebrow = "БОЛО Одбора",
      title = "БОЛО-и",
      listed = "написан",
      unknown = "непознато",
      search = {
        placeholder = "Тражи БОЛО по називу, ид-у, типу или тагу"
      },
      actions = {
        refresh = "освежи",
        manageTypes = "Менаџер типова",
        new = "Нови БОЛО",
        back = "Назад на листу",
        add = "Додај",
        addPhoto = "Додај фотографију",
        remove = "Уклони"
      },
      state = {
        loading = "Учитавање БОЛО-а...",
        empty = "Нема БОЛО-а који одговарају тренутним филтерима.",
        saving = "Складиштити...",
        noTags = "Нема додељених тагова.",
        noReports = "Још нема повезаних извештаја."
      },
      detail = {
        summary = "Сажетак БОЛО-а",
        untitled = "Без назива БОЛО"
      },
      fields = {
        title = "Назив БОЛО-а",
        id = "БОЛО ИД",
        type = "Тип",
        status = "Статус",
        priority = "Приоритет",
        created = "Настало",
        updated = "Последње ажурирање"
      },
      placeholders = {
        title = "Назив БОЛО-а",
        id = "Аутоматски генерисано ако је празно",
        type = "Изаберите тип",
        description = "Додај опис...",
        tag = "Додај таг",
        reportSelect = "Изаберите извештај"
      },
      sections = {
        description = "Опис",
        descriptionSubtitle = "Заснијате детаље и инструкције.",
        tags = "Тагови",
        tagsSubtitle = "Додајте брзе идентификатори за БОЛО.",
        reports = "Повезани извештаји",
        reportsSubtitle = "Прикачите сродне мапе извештаја.",
        gallery = "Galerija",
        gallerySubtitle = "Pripojite slike iz galerije na BOLO."
      },
      gallery = {
        title = "Izabrati fotografiju",
        subtitle = "Odaberite slik iz galerije za pridruživanje BOLO-u.",
        loading = "Učitavanje galerije...",
        empty = "Nema dostupnih slika u galeriji.",
        photoAlt = "Slika iz galerije"
      },
      typesModal = {
        title = "Tipovi BOLO",
        subtitle = "Dodajte ili uklonite tipove BOLO-a za ovaj uređaj.",
        placeholder = "Dodaj tip BOLO",
        empty = "Nema konfigurisanih tipova BOLO-a."
      },
      types = {
        person = "Osoba",
        vehicle = "Vozilo",
        property = "Nekretnina",
        missing = "Nestao",
        other = "Ostalo"
      },
      status = {
        active = "Aktivno",
        located = "Pronađeno",
        closed = "Zatvoreno",
        cancelled = "Otkazano"
      },
      priority = {
        low = "Nisko",
        medium = "Srednje",
        high = "Visoko",
        critical = "Kritično"
      },
      errors = {
        load = "Nemoguće učitati BOLO-e.",
        save = "Nemoguće sačuvati BOLO.",
        titleRequired = "Unesite naslov BOLO pre spremanja.",
        typeRequired = "Odaberite tip BOLO pre spremanja.",
        gallery = "Nemoguće učitati galeriju."
      }
    },
    warrants = {
      eyebrow = "Varantni trezor",
      title = "Zahtevi",
      listed = "navedeno",
      unknown = "Nepoznato",
      search = {
        placeholder = "Pretražite zahteve po naslovu, ID-u, tipu ili oznaci"
      },
      actions = {
        refresh = "Osvježi",
        manageTypes = "Upravljanje tipovima",
        new = "Novi zahtev",
        back = "Nazad na listu",
        add = "Dodaj",
        addPhoto = "Dodaj fotografiju",
        remove = "Ukloni"
      },
      state = {
        loading = "Učitavanje zahteva...",
        empty = "Nema zahteva koji odgovaraju trenutnim filtrima.",
        saving = "Spremanje...",
        noTags = "Nema dodeljenih oznaka.",
        noReports = "Još nema povezanih izveštaja.",
        noOffences = "Još nema povezanih krivičnih dela."
      },
      detail = {
        summary = "Sažetak zahteva",
        untitled = "Zahtev bez naslova"
      },
      fields = {
        title = "Naslov zahteva",
        id = "ID naloga",
        type = "Vrsta",
        status = "Status",
        priority = "Prioritet",
        created = "Kreirano",
        updated = "Poslednje ažuriranje"
      },
      placeholders = {
        title = "Naslov naloga",
        id = "Automatski generisano ako je prazno",
        type = "Izabrati vrstu",
        description = "Dodaj opis...",
        tag = "Dodaj oznaku",
        reportSelect = "Izabrati izveštaj",
        offenceSelect = "Izabrati prekršaj"
      },
      sections = {
        description = "Opis",
        descriptionSubtitle = "Zabeležite sažetak i uputstva.",
        tags = "Oznake",
        tagsSubtitle = "Prikažite brze identifikatore za nalog",
        reports = "Povezani izveštaji",
        reportsSubtitle = "Prikažite povezane datoteke izveštaja",
        offences = "Prekršaji",
        offencesSubtitle = "Povežite prekršaje sa nalogom",
        gallery = "Galerija",
        gallerySubtitle = "Prikažite slike galerije koje je potrebno priložiti uz nalog"
      },
      gallery = {
        title = "Izabrati fotografiju",
        subtitle = "Izaberite sliku galerije za prilaženje nalogu",
        loading = "Učitavanje galerije...",
        empty = "Nema dostupnih fotografija galerije",
        photoAlt = "Fotografija galerije"
      },
      typesModal = {
        title = "Vrste naloga",
        subtitle = "Dodajte ili uklonite vrste naloga za ovaj uređaj",
        placeholder = "Dodaj vrstu naloga",
        empty = "Nije konfigurirana nijedna vrsta naloga"
      },
      types = {
        arrest = "Hapšenje",
        search = "Pretražiti",
        bench = "Klupa",
        probation = "Uslovi parolije"
      },
      status = {
        active = "Aktivan",
        served = "Dostavljeno",
        expired = "Isteklo",
        cancelled = "Otkazano"
      },
      priority = {
        low = "Niska",
        medium = "Srednja",
        high = "Visoka",
        critical = "Kritično"
      },
      errors = {
        load = "Nije moguće učitati naloge",
        save = "Nije moguće sačuvati nalog",
        titleRequired = "Unesite naslov naloga pre čuvanja",
        typeRequired = "Izaberite vrstu naloga pre čuvanja",
        gallery = "Nije moguće učitati galeriju"
      }
    },
    prison = {
      eyebrow = "Zapisnik o pritvoru",
      title = "Zatvor",
      listed = "na listi",
      search = {
        placeholder = "Pretražiti po imenu ili ID-u"
      },
      filters = {
        all = "Sve",
        label = "Status",
        placeholder = "Status"
      },
      actions = {
        refresh = "Osvežiti",
        back = "Nazad na listu",
        saveDuration = "Sačuvaj trajanje",
        minusMinutes = "-15 min",
        minusSmall = "-5 min",
        plusSmall = "+5 min",
        plusMinutes = "+15 min",
        saveNotes = "Sačuvaj beleške",
        saveWarrant = "Poveži mandat",
        addOffence = "Dodaj prekršaj",
        setSolitary = "Pošalji u samicu",
        setGeneral = "Povratak u opštu populaciju"
      },
      state = {
        loading = "Učitavanje zatvorenika...",
        empty = "Nijedan zatvorenik ne odgovara trenutnim filtrima.",
        saving = "Čuvanje...",
        noOffences = "Još uvek nema povezanih prekršaja."
      },
      labels = {
        mugshot = "Fotelja za lice na fotografiji"
      },
      detail = {
        summary = "Rezime zatvorenika"
      },
      fields = {
        booked = "Uzeto u evidenciju",
        remaining = "Preostalo vreme",
        identifier = "Identifikator",
        unknown = "Nepoznato",
        remainingMinutes = "Preostale minute",
        warrant = "Mandat",
        offences = "Prekršaji",
        housing = "Smeštaj"
      },
      sections = {
        duration = "Trajanje kazne",
        durationSubtitle = "Prilagoditi preostalo vreme u minutima.",
        notes = "Beleške",
        notesSubtitle = "Zapišite zapažanja za ovu kaznu.",
        links = "Povezane potvrde i prekršaji",
        linksSubtitle = "Prikači mandat i prekršaje povezane sa ovim boravkom.",
        housing = "Smeštaj",
        housingSubtitle = "Prebaci između samice i opšte populacije."
      },
      placeholders = {
        note = "Dodaj beleške...",
        warrant = "Izaberite mandat",
        offence = "Izaberite prekršaj"
      },
      status = {
        in_prison = "U zatvoru",
        breaked_out = "Pobegao",
        released = "Slobodno pušten"
      },
      solitary = {
        active = "Samica",
        inactive = "Opšta populacija",
        badge = "Samica"
      },
      duration = {
        minutesOnly = "{minutes}m preostalo",
        full = "{hours}h {minutes}m preostalo"
      },
      linked = {
        warrantFallback = "Žig"
      },
      date = {
        unknown = "Nepoznato"
      },
      errors = {
        load = "Nije moguće učitati zatvorenike.",
        duration = "Nije moguće ažurirati trajanje.",
        note = "Nije moguće sačuvati belešku.",
        links = "Nije moguće ažurirati linkove.",
        solitary = "Nije moguće ažurirati solitary confinement.",
        solitary_unavailable = "Nije konfigurirano solitary cells za ovu zatvor."
      }
    },
    billing = {
      title = "Izraditi račun",
      subtitle = "Naplatiti usluge u blizini građanima.",
      selectLabel = "Izabrati osobu",
      selectPlaceholder = "Izaberite osobu",
      noPlayers = "Nema osoba u blizini unutar {range} m.",
      amountLabel = "Iznos računa",
      reasonLabel = "Razlog (kratko)",
      reasonPlaceholder = "Primer: Patrole usluga",
      presetsLabel = "Prekršaji",
      presetSearchPlaceholder = "Pretražiti prekršaj ili kaznu",
      presetNoMatches = "Nema prekršaja koji odgovaraju vašoj pretrazi.",
      presetReasonHeader = "Prekršaj",
      presetAmountHeader = "Kazna",
      presetCustomAmount = "Prilagođeno",
      paperDefaultCategory = "Obaveštenje o parkiranoj prekršaju",
      ticketReceiptTitle = "Obaveštenje o kazni",
      ticketReceiptSubtitle = "Zabeleženo u",
      ticketReceiptCitizenLabel = "Građanin",
      ticketReceiptOfficerLabel = "Osoblje izdavanja",
      ticketReceiptReasonLabel = "Sažetak optužbe",
      ticketReceiptAmountLabel = "Ukupna kazna",
      ticketReceiptAcknowledge = "Potvrdi",
      cancelButton = "Otkaži",
      submitButton = "Izbaci račun",
      submitting = "Slanje...",
      success = "Račun uspešno izdat.",
      paperTicketNumber = "Broj karte",
      paperDate = "Datum",
      paperTime = "Vreme",
      paperCitizenLabel = "Građanin",
      paperOfficerLabel = "Osoblje",
      paperViolationLabel = "Prekršaj",
      paperNotice = "Plaćanje je hitno. Neplaćanje može rezultirati zapljenom.",
      paperSignatureLabel = "Potpis osoblja",
      paperTotalFine = "Ukupna kazna",
      errors = {
        failed = "Nije moguće izdati račun.",
        invalid_target = "Osoba nedostupna.",
        empty_reason = "Navedite kratak razlog.",
        too_far = "Osoba se previše udaljila.",
        not_authorized = "Niste ovlašćeni za izdavanje računa.",
        not_on_duty = "Morate biti na dužnosti za izdavanje računa.",
        amount_out_of_range = "Iznos računa je izvan dozvoljenog raspona.",
        insufficient_funds = "Osoba ne može da priušti ovu naknadu.",
        player_unavailable = "Osoba nedostupna.",
        disabled = "Sistem za naplatu je onemogućen."
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
        title = "Funkcije",
        subtitle = "Ukljuci ili iskljuci funkcije resursa za sve konfigurisane poslove.",
        instantTuning = { label = "instantTuning", description = "" },
        partsDelivery = { label = "Dostava delova", description = "Ukljuci narudzbine delova za radionicu i zone dostave." },
        carryItems = { label = "Fizicko rukovanje delovima", description = "Zahteva da se dostavljeni delovi prenesu kroz radionicu." },
        nitro = { label = "nitro", description = "" },
        antiLag = { label = "antiLag", description = "" },
        twoStep = { label = "twoStep", description = "" },
        wheelDamage = { label = "Ostecenje tockova", description = "Ukljuci realisticna ostecenja tockova i popravke." },
        customHandling = { label = "customHandling", description = "" },
        mileageHud = { label = "HUD kilometraze", description = "Prikazi kilometrazu vozila tokom voznje." },
        workshopLift = { label = "Dizalica radionice", description = "Ukljuci upotrebljive tacke dizalice u radionicama." }
      },
globalSettings = { title = "Global settings", notice = "These values apply to all configured jobs. Saving them from this job updates the behavior globally." },
      tuning = { globalTitle = "Global pricing settings", globalBadge = "Global", globalNotice = "These values apply to all configured jobs. Saving them from this job updates pricing behavior globally.",
        nitroAccess = "Pristup nitrou za ovaj posao",
        nitroAccessHelp = "Zamenite globalnu nitro funkciju za ovaj mehaničarski posao.",
        nitroAccessInherit = "Koristi globalno nitro podešavanje",
        nitroAccessEnabled = "Omogući nitro za ovaj posao",
        nitroAccessDisabled = "Onemogući nitro za ovaj posao",
      },
      fields = { allowedJobs = "Allowed jobs", animationDict = "Animation dict", animationName = "Animation name", blip = "Blip", bone = "Bone", category = "Category", color = "Job color", consumeItems = "Consume items", cost = "Cost", distance = "Distance", enabled = "Enabled", garageType = "Garage type", heading = "Heading", item = "Item", jobName = "Job name", label = "Label", marker = "Marker", mechanicOnly = "Mechanic", name = "Name", offsetX = "Offset X", offsetY = "Offset Y", offsetZ = "Offset Z", offDutyEnabled = "Off-duty enabled", offDutyJob = "Off-duty job", ped = "Ped", pedModel = "Ped model", price = "Price", prop = "Prop", requiredItems = "Required items", scenario = "Scenario", sprite = "Sprite", stage = "Stage", transport = "Transport", trunkCapacity = "Trunk capacity", type = "Type", value = "Value", x = "X", y = "Y", z = "Z",
        minGrade = "Min rang",
        livery = "Livreja",
        fuelType = "Vrsta goriva",
        primaryColor = "Primarna boja",
        secondaryColor = "Sekundarna boja",
        pearlescentColor = "Sedefasta boja",
        wheelColor = "Boja točkova",
        extras = "Dodaci",
        extraId = "ID dodatka",
        propCounts = "Ograničenja propova",
        count = "Ograničenje",
        properties = "Svojstva vozila",
        property = "Svojstvo",
      },
      placeholders = { allowedJobs = "mechanic, tuner", itemName = "Item name", jobName = "job name", label = "Label", model = "Model", vehicleName = "Name",
        liveryIndex = "e.g. 0",
        paintIndex = "0-160",
        propCounts = "{ \"prop_model\": 4 }",
        properties = "{ \"windowTint\": 1 }",
      },
      fuelTypes = {
        default = "Podrazumevano (regularno)",
        regular = "Regularno",
        plus = "Plus",
        premium = "Premium",
        diesel = "Dizel",
      },
      descriptions = { color = "Color used by Sky Jobs menus, blips, and job UI accents.", jobName = "Framework job name registered for this job.", offDutyEnabled = "Enable an off-duty counterpart for this job.", offDutyJob = "Job name used when this employee goes off duty." },
      messages = { empty = "No jobs configured yet.", featuresSaved = "Features saved.", invalidJson = "Correct invalid JSON fields before saving.", loading = "Loading jobs...", nameExists = "A job with this job name already exists.", noTuningOptions = "No options configured in this category.", saved = "Settings saved.", saveFailed = "Unable to save changes." },
      locations = { addSubtitle = "Choose which point type to place.", addTitle = "Add location point", deleteFailed = "Unable to delete location.", deleteSaved = "Location removed. Save settings to apply it.", emptySubtitle = "This configurator has no registered location definitions.", emptyTitle = "No locations configured.", garageMenu = "Menu", garagePark = "Park", garageSpawn = "Spawn", placeFailed = "Unable to place location.", placementHint = "Press Enter to place and Backspace to cancel.", placementSaved = "Location updated. Save settings to apply it.", placementTitle = "Placement mode", teleported = "Teleported to location.", teleportFailed = "Unable to teleport to location.", unset = "Not set" },
      carryItems = { missingProp = "Enter a prop model before opening placement.", placementFailed = "Unable to edit attach placement.", placementSaved = "Attach placement updated. Save settings to apply it.", selectItem = "Select delivery item" },
      extensions = { invalidJson = "Neispravan JSON. Ispravi sintaksu pre cuvanja.", jsonObjectRequired = "Vrednost mora biti JSON objekat.", partsDeliveryShop = "Prodavnica dostave delova", tuningCostProfile = { label = "Cene tuninga", description = "Konfigurisi troskove performansi, izgleda, tockova i specijalnih opcija za ovaj posao." } },
garageTypes = { boat = "Boat", helicopter = "Helicopter", vehicle = "Vehicle" },
      colorPopup = { title = "Job color" },
      dialogs = { delete = { cancel = "Cancel", confirm = "Delete", message = "Delete {name}?", title = "Delete job" } },
      screenPosition = { preview = "HUD" },
      interactions = { title = "Interactions", empty = "No interactions configured.", addMarkerSetting = "Add marker setting", noPedSelected = "No ped selected", headers = { interaction = "Interaction", key = "Key", marker = "Marker", blip = "Blip", npc = "NPC" }, tabs = { behavior = "Behavior", marker = "Marker", blip = "Blip", npc = "NPC" }, status = { on = "On", off = "Off" }, fields = { unique = "Unique", forceMarkerInteraction = "Force marker interaction", interactionDistance = "Interaction distance", placementModel = "Placement model" }, help = { unique = "Limits the interaction type to one configured point for a location when enabled.", forceMarkerInteraction = "Forces marker-style interaction handling even when target/NPC interaction support is available.", interactionDistance = "Maximum distance from the point where the player can use the interaction.", placementModel = "Object model shown while placing this interaction in the creator." } },
      assetPicker = { search = "Search", allCategories = "All categories", itemCount = "{count} items", markerTitle = "Marker type", markerSubtitle = "Choose a DrawMarker type.", blipTitle = "Blip sprite", blipSubtitle = "Choose a map blip sprite.", pedTitle = "Ped model", pedSubtitle = "Choose a FiveM ped model.", chooseMarker = "Choose marker", chooseBlip = "Choose blip", choosePed = "Choose ped" },
      markerFields = { posX = "Position X", posY = "Position Y", posZ = "Position Z", dirX = "Direction X", dirY = "Direction Y", dirZ = "Direction Z", rotX = "Rotation X", rotY = "Rotation Y", rotZ = "Rotation Z", scaleX = "Scale X", scaleY = "Scale Y", scaleZ = "Scale Z", red = "Red", green = "Green", blue = "Blue", alpha = "Alpha", bobUpAndDown = "Bob up/down", faceCamera = "Face camera", rotationOrder = "Rotation order", rotate = "Rotate", textureDict = "Texture dict", textureName = "Texture name", drawOnEnts = "Draw on entities" },
      instantTuning = { title = "Instant Tuning", defaultLabel = "Default label", defaultLabelHelp = "Text shown at instant tuning points.", interactionDistanceHelp = "Default distance from which a point can be used.", priceMultiplier = "Price multiplier", priceMultiplierHelp = "Multiplier applied to instant tuning prices.", forceMarkerHelp = "Forces marker-style interaction handling even when target support is available.", mechanicOnlyHelp = "Restricts every instant tuning point to configured mechanic jobs.", allowedJobsHelp = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", emptyLocations = "No instant tuning locations configured.", emptyLocationsHelp = "Add a location, then use Set to capture your current position." }
  ,

      configs = { sky_mechanicjob = { title = "Mehanicarski poslovi", subtitle = "Konfigurisi mehanicarske poslove, prodavnice, vozila i lokacije radionica." } },
      settingSections = { general = "Opste", partsTheft = "Kradja delova", vehicleCare = "Odrzavanje vozila", wear = "Trosenje", wheelDamage = "Ostecenje tockova", mileageHud = "HUD kilometraze", instantTuning = "Instant Tuning", carryItems = "Nosivi delovi" },
      settingFields = { key = "Kljuc", label = "Labela", name = "Ime itema", amount = "Kolicina", price = "Cena", item = "Item", repair = "Popravi kitom", classId = "ID klase", multiplier = "Mnozilac", kilometersToZero = "Kilometri do nule", removeAfterUse = "Potrosi item", flow = "Tok instalacije", transport = "Transport", prop = "Prop", bone = "Bone", x = "X", y = "Y", z = "Z", rx = "Rot X", ry = "Rot Y", rz = "Rot Z", category = "Kategorija" },
      settings = {
        primaryColor = { label = "Primarna boja", description = "Main mechanic configurator color and default job color fallback. Use a hex value such as #EDC001." },
        orderInstallNonMinigameDurationMs = { label = "Jednostavno trajanje instalacije", description = "Milliseconds used for order install steps that do not run a minigame." },
        tuningWorkshopRequireForInstall = { label = "Zahtevaj radionicu za instalaciju", description = "Require tuning order installs to start and complete near a self-service tuning point." },
        tuningWorkshopRequireForRemoval = { label = "Zahtevaj radionicu za skidanje", description = "Require tuning removals to start and complete near a self-service tuning point." },
        tuningWorkshopDistance = { label = "Potrebna udaljenost radionice", description = "Maximum distance from a self-service tuning point for required install or removal actions." },
        addRevenueToSociety = { label = "Uplati prihod u society", description = "Deposit paid tuning order money into the tuning job society account." },
        publicUsersSeePrices = { label = "Javni korisnici vide cene", description = "Show regular tuning prices to non-mechanic public users." },
        fallbackVehicleValue = { label = "Podrazumevana vrednost vozila", description = "Value used when no vehicle price can be resolved." },
        priceType = { label = "Tip cene", description = "Percentage calculates each tuning cost from the vehicle price. Fixed uses the entered money amount.", options = { percentage = "Procenat", fixed = "Fiksno" } },
        freeVehicles = { label = "Besplatna tuning vozila", description = "Vehicle spawn models that receive free tuning orders.", itemLabel = "Vehicle model" },
        partsTheftItem = { label = "Alat za kradju", description = "Inventory item used to steal wheels and catalytic converters." },
        partsTheftRemoveItemAfterUse = { label = "Potrosi alat za kradju", description = "Remove the theft tool item after a successful theft action." },
        partsTheftStolenWheelItem = { label = "Ukraden tocak", description = "Inventory item awarded when wheels are stolen." },
        partsTheftCatalyticConverterItem = { label = "Katalizator", description = "Inventory item awarded when a catalytic converter is stolen." },
        partsTheftDealerAccount = { label = "Dealer payout account", description = "Account used for stolen parts dealer payouts, such as money or bank." },
        partsTheftDealerSellDistance = { label = "Dealer sell distance", description = "Maximum distance from the dealer to sell stolen parts." },
        partsTheftDispatchEnabled = { label = "Posalji policijski dispatch", description = "Create a police dispatch when a wheel or catalytic converter is stolen." },
        partsTheftDispatchJobs = { label = "Dispatch jobs", description = "Job names that receive parts theft dispatches.", itemLabel = "Job name" },
        partsTheftDispatchTitle = { label = "Dispatch title", description = "Title shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchMessage = { label = "Dispatch message", description = "Message shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchCooldownSeconds = { label = "Dispatch cooldown", description = "Seconds before the same vehicle part can create another dispatch." },
        partsTheftDealerItems = { label = "Dealer items", description = "Stolen items the dealer will buy and their payout values.", itemLabel = "Dealer item" },
        vehicleCareWashItem = { label = "Item za pranje", description = "Inventory item used to wash a vehicle." },
        vehicleCareWashRemoveAfterUse = { label = "Potrosi item za pranje", description = "Remove the wash item after use." },
        vehicleCareWaxItem = { label = "Item za vosak", description = "Inventory item used to wax a vehicle." },
        vehicleCareWaxRemoveAfterUse = { label = "Potrosi item za vosak", description = "Remove the wax item after use." },
        vehicleCareWaxCleanKilometers = { label = "Wax clean kilometers", description = "Distance a waxed vehicle stays clean." },
        vehicleCareRepairItem = { label = "Item za popravku", description = "Inventory item used by the vehicle repair action." },
        vehicleCareRepairRemoveAfterUse = { label = "Potrosi item za popravku", description = "Remove the repair item after use." },
        vehicleCareRepairDurationMs = { label = "Trajanje popravke", description = "Repair progress duration in milliseconds." },
        vehicleCareRepairMaxDistance = { label = "Repair max distance", description = "Maximum distance from the vehicle while repairing." },
        vehicleCareRepairVehicleDamage = { label = "Fix vehicle damage", description = "Repair normal GTA vehicle damage when using the repair action." },
        vehicleCareRepairFixRealisticWheelDamage = { label = "Fix realistic wheel damage", description = "Also reset realistic wheel damage when using the repair action." },
        vehicleCareRepairWearParts = { label = "Repair kit restored parts", description = "Choose which wear and service parts the repair item restores. Disable fluids here if oil, coolant, brake fluid, or transmission fluid should require the diagnostics repair flow.", itemLabel = "Wear part" },
        wearParts = { label = "Delovi trosenja", description = "Vehicle wear parts, their lifetime distance, required repair item, item consumption, and install flow.", itemLabel = "Wear part", fields = { flow = { options = { wheel = "Wheel", performance = "Performance", underbody_neon = "Underbody / lift", oil_change = "Oil change", fluid_refill = "Fluid refill", catalytic_converter = "Catalytic converter", hood_install = "Hood install" } } } },
        wheelDamageDefaultMultiplier = { label = "Podrazumevani mnozilac", description = "Base wheel damage multiplier." },
        wheelDamageOffroadWheelsMultiplier = { label = "Off-road wheel multiplier", description = "Multiplier used when the vehicle has off-road wheels." },
        wheelDamageVehicleClassMultipliers = { label = "Vehicle class multipliers", description = "Damage multipliers per GTA vehicle class.", itemLabel = "Vehicle class" },
        mileageHudDigits = { label = "Cifre", description = "Number of digits shown in the mileage HUD." },
        mileageHudPosition = { label = "Pozicija", description = "Drag the mileage HUD preview to the desired screen position." },
        partsDeliveryTimeSeconds = { label = "Vreme dostave", description = "Seconds between ordering parts and the delivery becoming ready." },
        partsDeliveryTimerHudEnabled = { label = "Show delivery timer", description = "Show a small in-game timer HUD after a parts order is placed." },
        partsDeliveryTimerHudPosition = { label = "Timer position", description = "Drag the parts delivery timer HUD preview to the desired screen position." },
        partsDeliveryOwnCard = { label = "Own card payment", description = "Allow players to pay parts delivery orders with their own money." },
        partsDeliveryCompanyCard = { label = "Company card payment", description = "Allow parts delivery orders to use company funds." },
        partsDeliveryOpenDurationMs = { label = "Open duration", description = "Milliseconds required to unpack a ready parts delivery." },
        instantTuningInteractionDistance = { label = "Distanca interakcije", description = "Default distance for using instant tuning points." },
        instantTuningForceMarkerInteraction = { label = "Force marker interaction", description = "Use marker-style E interaction even when target support is enabled." },
        instantTuningMechanicOnly = { label = "Samo mehanicari", description = "Restrict all instant tuning locations to configured mechanic jobs." },
        instantTuningAllowedJobs = { label = "Dozvoljeni poslovi", description = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", itemLabel = "Job name" },
        instantTuningPriceMultiplier = { label = "Mnozilac cene", description = "Multiplier applied to instant tuning prices." },
        instantTuningLabel = { label = "Podrazumevana labela", description = "Default text shown at instant tuning points." },
        instantTuningMarkerEnabled = { label = "Marker enabled", description = "Draw a world marker at instant tuning locations." },
        instantTuningMarkerType = { label = "Marker type", description = "GTA marker type used for instant tuning locations." },
        instantTuningBlipEnabled = { label = "Blip enabled", description = "Show map blips for instant tuning locations." },
        instantTuningBlipName = { label = "Blip name", description = "Map blip name." },
        instantTuningBlipSprite = { label = "Blip sprite", description = "GTA blip sprite id." },
        instantTuningBlipColor = { label = "Blip color", description = "GTA blip color id." },
        instantTuningLocations = { label = "Lokacije", description = "Instant tuning points. Use 0 distance to inherit the default interaction distance.", itemLabel = "Locations" },
        carryItems = { label = "Nosivi delovi", description = "Delivered parts that should become physical carried props.", itemLabel = "Carry item", fields = { transport = { options = { hand = "Ruka", forklift = "Viljuskar", engine_lift = "Dizalica motora" } } } }
      },
      settingValues = {
        tyres = "Tyres", brake_pads = "Brake Pads", suspension = "Suspension", spark_plugs = "Spark Plugs", engine_oil = "Engine Oil", coolant = "Coolant", brake_fluid = "Brake Fluid", transmission_fluid = "Transmission Fluid", clutch = "Clutch", air_filter = "Air Filter", traction_battery = "Traction Battery", inverter = "Power Inverter", catalytic_converter = "Catalytic Converter",
        vehicleClass_0 = "Compacts", vehicleClass_1 = "Sedans", vehicleClass_2 = "SUVs", vehicleClass_3 = "Coupes", vehicleClass_4 = "Muscle", vehicleClass_5 = "Sports Classics", vehicleClass_6 = "Sports", vehicleClass_7 = "Super", vehicleClass_8 = "Motorcycles", vehicleClass_9 = "Off-road", vehicleClass_10 = "Industrial", vehicleClass_11 = "Utility", vehicleClass_12 = "Vans", vehicleClass_13 = "Cycles", vehicleClass_14 = "Boats", vehicleClass_15 = "Helicopters", vehicleClass_16 = "Planes", vehicleClass_17 = "Service", vehicleClass_18 = "Emergency", vehicleClass_19 = "Military", vehicleClass_20 = "Commercial", vehicleClass_21 = "Trains", vehicleClass_22 = "Open Wheel"
      }
  },
    jobConfigurator = {
      actions = {
        backToScripts = "Skripte"
      },
      selector = {
        title = "Konfigurator poslova",
        subtitle = "Izaberite koju skriptu posla želite da konfigurišete.",
        description = "Izaberite resurs koji želite da konfigurišete.",
        loading = "Učitavanje konfiguratora...",
        comingSoon = "Uskoro",
        emptyTitle = "Nema dostupnih skripti za konfigurisanje.",
        emptySubtitle = "Nemate dozvolu ni za jedan registrovani konfigurator poslova.",
        unavailable = "Nije registrovano"
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
