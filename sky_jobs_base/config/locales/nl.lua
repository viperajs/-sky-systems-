if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/config/locales/nl.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

-- Dutch translation
Locales["nl"] = {
  WardrobeHelpNotify = "Kledingkast openen",
  WardrobeTitle = "Kledingkast",
  WardrobeCivilianMissing = "Nog geen burgeroutfit opgeslagen.",
  WardrobeCivilianRestored = "Burgeroutfit geladen.",
  WardrobeUnsupportedFramework = "De kledingkast werkt niet met het geselecteerde framework ({framework}).",
  WardrobeMissingSkinchanger = "De kledingkast vereist dat skinchanger is gestart op ESX.",
  WardrobeMissingEsxSkin = "De kledingkast vereist dat esx_skin is gestart op ESX.",
  WardrobeMissingQbClothing = "De kledingkast vereist dat qb-clothing is gestart op {framework}.",
  WardrobeMissing17Movement = "De kledingkast vereist dat 17mov_CharacterSystem is gestart.",
  WardrobeMissingQsAppearance = "De kledingkast vereist dat qs-appearance is gestart.",
  WardrobeMissingAk47Clothing = "De kledingkast vereist dat ak47_clothing is gestart.",
  WardrobeMissingAk47QbClothing = "De kledingkast vereist dat ak47_qb_clothing is gestart.",
  WardrobeMissingTgiannClothing = "De kledingkast vereist dat tgiann-clothing is gestart.",
  WardrobeMissingNfSkin = "De kledingkast vereist dat nf-skin is gestart.",
  WardrobeMissingBlAppearance = "De kledingkast vereist dat bl_appearance is gestart.",
  WardrobeMissingIzzyAppearance = "De kledingkast vereist dat izzy-appearance is gestart.",
  WardrobeMissingCodemAppearance = "De kledingkast vereist dat codem-appearance is gestart.",
  WardrobeMissingHexClothing = "De kledingkast vereist dat hex_clothing is gestart.",
  WardrobeMissingIllenium = "De kledingkast vereist dat illenium-appearance is gestart.",
  WardrobeCustomUnavailable = "De geconfigureerde aangepaste kledingkast-integratie is niet beschikbaar.",
  WardrobeDisabled = "De kledingkast is uitgeschakeld in de configuratie.",
  WardrobeMissingRcoreClothing = "De kledingkast vereist dat rcore_clothing is gestart.",
  WardrobeUnknownJob = "Kledingkastbaan is niet beschikbaar.",
  GarageHelpNotify = "Garage openen",
  GarageTitle = "Garage",
  HelicopterGarageHelpNotify = "Open Helikopterplatform",
  BoatGarageHelpNotify = "Dok openen",
  GarageParkHelpNotify = "Parkeer de wagen",
  HelicopterGarageParkHelpNotify = "Parkeer de helikopter",
  BoatGarageParkHelpNotify = "Boot parkeren",
  GarageParkDriverRequired = "Je moet in de bestuurdersstoel zitten om te parkeren.",
  GarageParkInvalidVehicle = "Deze wagen kan hier niet worden geparkeerd.",
  GarageParkFailedNotify = "Het is niet mogelijk om de wagen te parkeren.",
  GarageSpawnBlockedNotify = "Spawnpunt is geblokkeerd.",
  StorageHelpNotify = "Toegang tot opslag",
  LockerHelpNotify = "Kluis openen",
  TrunkTitle = "Kofferbak",
  TrunkHelpNotify = "Toegang tot de kofferbak",
  TrunkPropRemoveHelp = "Geplaatst voorwerp verwijderen",
  TrunkUnavailable = "Toegang tot deze kofferbak is niet mogelijk.",
  BossMenuHelpNotify = "Beheer openen",
  Payroll = {
    title = "Loonstrook",
    paid = "Salaris ontvangen: {amount}",
    insufficient = "Niet genoeg geld in de bedrijfskas voor je salaris.",
  },
  PublicFormsTitle = "Publieke formulieren",
  PublicFormsHelpNotify = "Vul openbare formulieren in",
  PublicFormsUnavailable = "Kiosk voor openbare formulieren niet beschikbaar.",
  WholesaleShopTitle = "Groothandel",
  WholesaleShopHelpNotify = "Open Groothandelwinkel",
  WholesaleShopUnavailable = "Deze locatie heeft geen groothandel leverancier geconfigureerd.",
  NoPermission = "Je hebt geen toestemming om dit commando te gebruiken.",
  CameraUploadFailed = "Camera-upload mislukt.",
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
    Title = "Paniek",
    Sent = "Paniekknop geactiveerd.",
    NotOnDuty = "Je moet in dienst zijn om de paniekknop te gebruiken.",
    Cooldown = "Paniekknop is aan het afkoelen. Wacht {seconds}s.",
    MappingDescription = "Paniekmelding activeren",
    WaypointSet = "Waypoint gezet naar panieklocatie.",
    WaypointMissing = "Geen actieve panieklocatie.",
    LocationUnknown = "Onbekende locatie",
    MissingItem = "Je hebt {item} nodig om de paniekknop te gebruiken.",
  },
  Ping = {
    Title = "Pingen",
    Sent = "Locatieping gedeeld.",
    NotOnDuty = "Je moet in dienst zijn om een ping te sturen.",
    Cooldown = "Ping is aan het afkoelen. Wacht {seconds}s.",
    MappingDescription = "Locatieping versturen",
    LocationUnknown = "Onbekende locatie",
    MissingItem = "Je hebt {item} nodig om een ping te sturen.",
  },
  HeliCam = {
    Title = "Heli camera",
    CamEnabled = "Heli camera geactiveerd.",
    CamDisabled = "Heli camera uitgeschakeld.",
    NotAuthorized = "Je bent niet gemachtigd om de heli camera te gebruiken.",
    NotOnDuty = "Je moet in dienst zijn om de heli camera te gebruiken.",
    TooLow = "Helikopter is te laag om de camera te activeren.",
    TargetLocked = "Doel vergrendeld.",
    TargetReleased = "Doelvergrendeling vrijgegeven.",
    TargetLost = "Doel verloren.",
    RappelDenied = "Je kunt niet abseilen vanaf deze stoel.",
    RappelStarted = "Abseilen gestart.",
    PhotoSaved = "Heli foto opgeslagen in de galerij.",
    PhotoFailed = "Heli foto kon niet worden opgeslagen.",
    Spotlight = {
      ForwardOn = "Zoeklicht aan.",
      ForwardOff = "Zoeklicht uit.",
      TrackingOn = "Volgzoeklicht geactiveerd.",
      TrackingOff = "Volgzoeklicht uit.",
      ManualOn = "Handmatig zoeklicht geactiveerd.",
      ManualOff = "Handmatig zoeklicht uit.",
      Brightness = "Zoeklicht helderheid: {value}",
      Radius = "Zoeklicht radius: {value}"
    }
  },
  InteractionLabels = {
    job_garage              = "Werkgarage",
    garage_vehicle_spawn    = "Voertuig spawnpunt",
    garage_vehicle_park     = "Voertuig parkeren",
    garage_helicopter_menu  = "Helikopterhangar",
    garage_helicopter_spawn = "Helikopter spawnpunt",
    garage_helicopter_park  = "Helikopter parkeren",
    garage_boat_menu        = "Aanlegsteiger",
    garage_boat_spawn       = "Boot spawnpunt",
    garage_boat_park        = "Boot aanmeren",
    boss_menu               = "Beheer",
    duty_terminal           = "Dienstterminal",
    wardrobe                = "Kleedkamer",
    storage                 = "Opslag",
    locker                  = "Locker",
    wholesale_shop          = "Groothandel",
    public_forms            = "Openbare formulieren",
    jail_terminal           = "Gevangenisterminal",
    jail_jobs               = "Gevangenistaken",
    jail_job_npc            = "Gevangenistaken",
    jail_inmate_alcoholic   = "Gevangene: Alcoholist",
    jail_inmate_drugdealer  = "Gevangene: Drugdealer",
    jail_inmate_codelist    = "Gevangene: Informant",
    jail_inmate_wirecutter  = "Gevangene: Gereedschapsdrager",
    jail_inmate_doctor      = "Gevangenisarts",
    jail_canteen_cook       = "Kantinekok",
    jail_confiscated_return = "In beslag genomen voorwerpen",
    jail_electric_box       = "Elektriciteitskast",
    jail_fence_cut          = "Hekknippunt",
  },
  Nui = {
    IntlLocale = "nl-NL",
    currency = "$",
    menuTitles = {
      locker = "Persoonlijke locker",
      storage = "Opslag",
      trunk = "Voertuigopslag",
      ["trunk-props"] = "Voertuigprops",
      search = "Zoeken",
      garage = "Garage",
      vehshop = "Voertuigwinkel",
      management = "Beheer",
      shop = "Groothandel",
      ["impound-storage"] = "Inbeslagname opslag",
      refunds = "Teruggaven"
    },
    menu = {
      goToVehicleShop = "Ga naar Voertuigwinkel",
      backToGarage = "Terug naar Garage"
    },
    radial = {
      empty = "Geen acties beschikbaar op dit moment.",
      errors = {
        generic = "Actie niet beschikbaar."
      },
      title = "Dienstacties",
      hint = "Selecteer een actie om uit te voeren.",
      pressKey = "Druk op {key}",
      actions = {
        billing = {
          label = "Factureer",
          description = "Maak een rekening aan voor de dichtstbijzijnde persoon.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Facturering is niet beschikbaar.",
            notOnDuty = "Ga op kantoor werken om facturen uit te geven.",
            notAuthorized = "Je bent niet bevoegd om facturen uit te geven.",
            noPatients = "Geen nabijgelegen personen om te factureren."
          }
        },
        panic = {
          label = "Paniekknop",
          description = "Activeer een paniekmelding voor je huidige locatie.",
          states = {
            disabled = "Paniekknop is niet beschikbaar.",
            notOnDuty = "Ga op dienst om de paniekknop te gebruiken.",
            notAuthorized = "Je bent niet bevoegd om de paniekknop te gebruiken."
          }
        },
        tablet = {
          label = "tablet openen",
          description = "Open de tabletinterface.",
          states = {
            notOnDuty = "Ga op dienst om de tablet te gebruiken.",
            notAuthorized = "U bent niet gemachtigd om de tablet te gebruiken.",
            missingItem = "Je hebt hiervoor een tablet nodig."
          }
        },
        removeProp = {
          label = "Verwijder voorwerp",
          description = "Verwijder een nabij geplaatst voorwerp.",
          states = {
            noNearby = "Geen geplaatst voorwerp in de buurt.",
            failed = "Verwijderen van voorwerp mislukt."
          }
        },
        carryPatient = {
          label = "Draag persoon",
          description = "Draag de dichtstbijzijnde persoon naar veiligheid.",
          dropLabel = "Laat persoon los",
          dropDescription = "Laat de persoon los die je vasthoudt.",
          badge = {
            distance = "{afstand} m"
          },
          states = {
            disabled = "Draagt niet mogelijk.",
            beingCarried = "Je wordt al gedragen.",
            inVehicle = "Verlaat eerst het voertuig.",
            selfIncapacitated = "Je bent niet stabiel genoeg om iemand te dragen.",
            noPatients = "Geen personen in de buurt om te dragen.",
            tooFar = "Naderbij komen voordat je iemand draagt."
          }
        },
        playerSearch = {
          label = "Zoek persoon",
          description = "Zoek de dichtstbijzijnde persoon.",
          badge = {
            distance = "{afstand} m"
          },
          states = {
            disabled = "Zoeken door speler niet mogelijk.",
            notOnDuty = "Ga op dienst om mensen te zoeken.",
            notAuthorized = "Je bent niet gemachtigd om mensen te zoeken.",
            noPlayers = "Geen personen in de buurt om te zoeken.",
            tooFar = "Naderbij komen voordat je gaat zoeken.",
            inVehicle = "Verlaat eerst het voertuig."
          }
        },
        handcuff = {
          label = "Geboeid persoon",
          description = "Geboeid de dichtstbijzijnde persoon.",
          badge = {
            distance = "{afstand} m"
          },
          states = {
            disabled = "Geboeid maken niet mogelijk.",
            notOnDuty = "Ga op dienst om boeien te gebruiken.",
            inVehicle = "Verlaat eerst het voertuig.",
            targetInVehicle = "Verwijder de persoon uit het voertuig voordat je boeit.",
            noPlayers = "Geen personen in de buurt om te boeien.",
            tooFar = "Naderbij komen voordat je boeit.",
            missingItem = "Je hebt boeien nodig om dit te doen.",
            alreadyCuffed = "Die persoon is al geboeid."
          }
        },
        unhandcuff = {
          label = "Verwijder boeien",
          description = "Verwijder boeien van de dichtstbijzijnde persoon.",
          badge = {
            distance = "{afstand} m"
          },
          states = {
            disabled = "Onbeugelen niet mogelijk.",
            notOnDuty = "Ga op dienst om boeien te verwijderen.",
            inVehicle = "Verlaat eerst het voertuig.",
            targetInVehicle = "Verwijder de persoon uit het voertuig eerst.",
            noPlayers = "Geen personen in de buurt om te onbeugelen.",
            tooFar = "Naderbij komen voordat je onbeugelt.",
            notCuffed = "Die persoon is niet geboeid."
          }
        },
        wheelClamp = {
          label = "Wielklem",
          description = "Beveilig het dichtstbijzijnde voertuig door een wiel vast te klemmen.",
          states = {
            disabled = "Wielklemmen niet mogelijk.",
            notOnDuty = "Ga op dienst om voertuigen te klemmen.",
            inVehicle = "Verlaat eerst het voertuig.",
            noVehicle = "Geen voertuig in de buurt.",
            tooFarVehicle = "Loop dichter naar het voertuig.",
            noWheel = "Loop dichter naar een wiel.",
            tooFar = "Loop dichter naar een wiel."
          }
        },
        wheelClampRemove = {
          label = "Verwijder de klem",
          description = "Verwijder de wielklem van het voertuig.",
          states = {
            disabled = "Wheelklemmen is niet beschikbaar.",
            notOnDuty = "Ga op dienst om klemmen te verwijderen.",
            inVehicle = "Verlaat eerst het voertuig.",
            noClamp = "Geen wielklem in de buurt.",
            tooFar = "Loop dichter naar de wielklem."
          }
        },
        jail = {
          label = "Naar de gevangenis sturen",
          description = "Houd de dichtstbijzijnde speler vast op een geconfigureerde gevangenislocatie.",
          states = {
            notAuthorized = "Je bent niet gemachtigd om spelers naar de gevangenis te sturen.",
            notOnDuty = "Ga op dienst om deze actie te gebruiken.",
            noPlayers = "Geen personen in de buurt binnen bereik.",
            noJails = "Geen gevangenislocaties geconfigureerd.",
            spawnNotSet = "Configureer eerst een gevangenisspawn.",
            invalidTarget = "Kan die persoon niet vinden.",
            failed = "Kan die actie niet uitvoeren."
          }
        }
      }
    },
    shop = {
      shoppingCart = "Winkelwagen",
      purchase = "Aankopen",
      balance = "Beschikbaar budget",
      catalog = "Leverancierskatalogus",
      empty = "Geen voorraden beschikbaar op deze locatie.",
      emptyCart = "Je winkelmandje is leeg.",
      insufficientFunds = "Niet genoeg geld voor deze aankoop.",
      limitReached = "Limiet bereikt ({limit}).",
      errors = {
        invalidStation = "Ongeldige station.",
        emptyBasket = "Winkelmand leeg.",
        unknown = "Onbekende fout.",
        purchase = "Aankoop in winkelmandje mislukt."
      }
    },
    garage = {
      states = {
        stored = "Klaar",
        parked = "In gebruik"
      },
      title = "Garage",
      empty = "Geen vlootvoertuigen beschikbaar.",
      emptyAir = "Geen helikopters beschikbaar op dit platform.",
      ownedTitle = "Eigen vloot",
      shopTitle = "Voertuigwinkel",
      shopBalance = "Factiefonds",
      shopEmpty = "Geen voertuigen te koop op deze locatie.",
      shopEmptyAir = "Geen helikopters te koop op dit platform.",
      emptyFleet = "Nog geen vlootvoertuigen gekocht.",
      noAccess = "Geen toegang",
      confirmSellTitle = "Verkoop bevestigen",
      confirmSellConfirm = "Verkopen",
      confirmSellCancel = "Annuleren",
      confirmSellMessage = "{name} verkopen voor {price}?",
      confirmPurchaseTitle = "Aankoop bevestigen",
      confirmPurchaseConfirm = "Aanschaffen",
      confirmPurchaseCancel = "Annuleren",
      confirmPurchaseMessage = "{name} aanschaffen voor {price}?",
      purchaseSuccessTitle = "Voertuig aangeschaft",
      purchaseSuccessMessage = "{name} toegevoegd aan de vloot.",
      defaultVehicleName = "Voertuig",
      stats = {
        topSpeed = "Top snelheid",
        acceleration = "Acceleratie",
        braking = "Remmen",
        traction = "Tractie"
      },
      actions = {
        parkOut = "Parkeer Buiten",
        buyVehicle = "Voertuig kopen",
        openTrunk = "Open kofferbak",
        editStretcher = "Verander brancard",
        sellVehicle = "Voertuig verkopen",
        changePlate = "Kenteken wijzigen"
      },
      placeholders = {
        selectVehicle = "Selecteer een voertuig om details te bekijken.",
        statsLoading = "Laden van voertuiggegevens..."
      },
      errors = {
        loadVehicles = "Laden van garagevoertuigen mislukt.",
        loadStats = "Laden van voertuigstatistieken mislukt.",
        parkOut = "Parkeer uit voertuig is mislukt.",
        unavailable = "Garage niet beschikbaar.",
        vehicleUnavailable = "Voertuig niet beschikbaar.",
        purchase = "Aankoop van voertuig is mislukt.",
        openTrunk = "Openen kofferbak is mislukt.",
        noAccess = "Geen toegang tot dit voertuig.",
        stretcherEditor = "Stretarreditor kan niet worden geopend.",
        stretcherPermission = "Alleen de hoogste rang kan stretcherbevestigingen bewerken.",
        sellVehicle = "Voertuig verkopen mislukt.",
        editorUnavailable = "Editor niet beschikbaar.",
        changePlate = "Wijzigen van kenteken mislukt."
      },
      changePlateTitle = "Kenteken wijzigen",
      changePlateButton = "Toepassen",
      plateEditor = {
        button = "Kenteken bewerken",
        title = "Kenteken bewerken",
        hint = "Wijzig het kenteken van dit voertuig.",
        save = "Kenteken opslaan",
        errors = {
          empty = "Voer een kenteken in.",
          invalid = "Kenteken is ongeldig.",
          update = "Bijwerken van kenteken mislukt."
        }
      },
      status = {
        parkedBy = "Laatst uitgehaald door {name}",
        unknownDriver = "Onbekend"
      }
    },
    duty = {
      fields = {
        grade = "Rang",
        location = "Station",
        name = "Naam",
        badge = "Badge"
      },
      instructions = {
        drag = "Sleep uw werknemerskaart op de sensor om je dienst te beheren.",
        dragCard = "Sleep de werknemerskaart op de sensor om je dienst te starten."
      },
      screen = {
        welcome = "Welkom {name}",
        goodbye = "Dienst beëindigd. Zorg goed voor jezelf, {name}.",
        ready = "Diensttoegang verleend.",
        completed = "Dienst succesvol beëindigd.",
        idleTitle = "Wacht op scan",
        totalHours = "Totaal uren",
        shiftDuration = "Dienstduur",
        currentTime = "Huidige tijd: {time}",
        defaultStation = "Primaire terminal",
        devPrompt = "Laad mock gegevens om de dienstterminal in de browser te bekijken.",
        loadMock = "Laad mock gegevens",
        loading = "Laden..."
      },
      toasts = {
        failed = "Dienststatus bijwerken niet mogelijk."
      },
      errors = {
        unavailable = "Dienstterminal niet beschikbaar."
      },
      title = "Dienstterminal"
    },
    storage = {
      inventory = "Voorraad",
      storage = "Opslag",
      locker = "Kluis",
      trunk = "Voertuigkoffer",
      trunkProps = "Voertuigaccessoires",
      openPropMenu = "Accessoires",
      search = "Zoeken",
      items = "Items",
      weapons = "Wapens",
      transferTitle = "Overdragen",
      transferButton = "Overbrengen",
      capacityUnlimited = "Onbeperkte capaciteit",
      errors = {
        trunkFull = "Kofferbak zit vol.",
        searchReadOnly = "Je kunt alleen items van de persoon verwijderen.",
        invalidTransfer = "Overdracht is mislukt.",
        invalidAmount = "Ongeldig bedrag.",
        notEnoughItems = "Niet genoeg items.",
        inventoryFull = "Niet genoeg opslagruimte.",
        storageFull = "Opslag is vol.",
        lockerFull = "Locker is vol.",
        restrictedItem = "U heeft geen toegang tot dit item.",
        invalidProp = "Fout bij het selecteren van prop."
      },
      officerInventory = "Personeelsinventaris",
      loadout = "Uitrusting",
      armory = "Wapenopslag",
      armoryTitle = "Uitrustingsmagazijn",
      storageTitle = "Veilig opslagruimtes",
      storageSubtitle = "Alleen gemachtigd personeel",
      emptyItems = "Geen items beschikbaar.",
      emptyWeapons = "Geen wapens beschikbaar.",
      emptyProps = "Geen props beschikbaar.",
      searchItems = "Items",
      searchWeapons = "Wapens",
      lockerUnlocking = "Locker wordt geopend...",
      restrictedPill = "Beperkt",
      restrictedTooltip = "U heeft geen toegang tot dit item.",
      capacityLabel = "{used}/{capacity}",
      propPlacement = {
        title = "Voorwerpplaatsing",
        place = "Plaatsen ({key})",
        cancel = "Annuleren ({key})"
      }
    },
    creator = {
      title = "Maker",
      description = "Configureer invoer.",
      selectJob = "Selecteer een functiecategorie.",
      empty = "Nog geen {entryLabelPlural} geconfigureerd.",
      keyboardHint = "Gebruik de pijltjestoetsen om door de lijst en acties te navigeren.",
      placementHelp = "Pijlen bewegen, PageUp/PageDown hoogte, Q/E draaien, Enter plaatsen, Backspace annuleren.",
      editTitle = "Markeringen",
      editSubtitle = "Gebruik de kaartpen knop om je huidige coördinaten op te slaan.",
      editKeyboardHint = "Gebruik de pijltjestoetsen om een marker te kiezen, links/rechts voor Instellen/Wissen, Enter om uit te voeren, Backspace om terug te gaan.",
      missingEntry = "Invoer niet gevonden.",
      actions = {
        add = "Toevoegen {label}",
        newEntry = "Nieuwe {entryLabel}"
      },
      status = {
        set = "Instellen",
        unset = "Wissen"
      },
      modals = {
        createTitle = "Maak {entryLabel}",
        createButton = "Maak {entryLabel}",
        renameTitle = "Hernoemen {entryLabel}",
        renameButton = "Opslaan naam",
        deleteTitle = "Verwijderen {entryLabel}",
        deleteMessage = "Wil je {name} echt verwijderen?",
        deleteConfirmLabel = "Verwijderen",
        deleteCancelLabel = "Annuleren"
      }
    },
    management = {
      noAccess = "U heeft geen toegang tot managementtools.",
      refunds = {
        description = "Bekijk sterfgevallen van vandaag en gisteren en vergoed verwijderde items.",
        refreshButton = "Vernieuwen",
        updatedAt = "Bijgewerkt {time}",
        errors = {
          loadFailed = "Laden van refunds mislukt."
        }
      },
      dashboard = {
        sidebarTitle = "Dashboard",
        menuTitle = "Overzicht",
        onlineMembers = "Online Leden",
        funds = "Fondsen",
        onDuty = "Aan Het Dienst",
        offDuty = "Niet In Dienst",
        mostActive = "Meest Actief"
      },
      finance = {
        sidebarTitle = "Kasstroom",
        menuTitle = "Financieel Overzicht",
        expenseCategories = "Uitgaven Categorieën",
        revenueCategories = "Inkomsten Categorieën",
        kpis = {
          revenue = "Inkomsten",
          expenses = "Uitgaven",
          profit = "Winst"
        },
        cashFlow = "Kasstroomtrend",
        lastUpdated = "Bijgewerkt {time}",
        emptyStates = {
          timeline = "Geen transacties geregistreerd in deze periode.",
          categories = "Nog geen categoriegegevens."
        },
        categories = {
          deposits = "Stortingen",
          withdrawals = "Opnames",
          supplies = "Benodigdheden",
          vehicles = "Voertuigen",
          salaries = "Salarissen",
          bonuses = "Bonussen"
        },
        errors = {
          load = "Kan financiële momentopname niet laden."
        }
      },
      transactions = {
        sidebarTitle = "Fondsen",
        menuTitle = "Fondsenbeheer",
        currentBalance = "Huidig Saldo",
        withdrawButton = "Opnemen",
        depositButton = "Storten",
        recentTransactions = "Recente Transacties",
        columnNames = {
          timestamp = "Tijdstempel",
          name = "Naam",
          action = "Actie",
          content = "Bedrag"
        },
        actions = {
          deposited = "Geld Gestort",
          withdrawn = "Geld Opgenomen",
          supplies_purchased = "Benodigdheden Aangeschaft",
          vehicle_purchased = "Voertuig Aangekocht",
          vehicle_sold = "Voertuig Verkocht",
          salary_paid = "Salaris Betaald",
          bonus_paid = "Bonus Betaald"
        },
        errors = {
          load = "Kan transacties niet laden.",
          failed = "Transactie mislukt."
        }
      },
      billingSpecs = {
        sidebarTitle = "Factureringsvoorinstellingen",
        menuTitle = "Factureringsredenen",
        description = "Configureer de redenen die het personeel kan selecteren tijdens het factureren en definieer hun standaardprijzen.",
        reasonColumn = "Reden",
        priceColumn = "Prijs",
        actionsColumn = "Acties",
        reasonLabel = "Factureringsreden",
        reasonPlaceholder = "bijv. Patrouillerespons",
        amountLabel = "Standaardprijs",
        emptyState = "Nog geen factureringsredenen toegevoegd.",
        addButton = "Toevoegen",
        addFirstButton = "Maak je eerste reden aan",
        deleteButton = "Verwijderen",
        saveButton = "Opslaan",
        reasonRequired = "Voer een reden in om deze rij op te slaan.",
        saveSuccess = "Facturatiespecificaties bijgewerkt.",
        saveError = "Kan facturatiespecificaties niet opslaan.",
        loadError = "Kan facturatiespecificaties niet laden.",
        updatedAt = "Binnenkort bijgewerkt op {time}"
      },
      members = {
        sidebarTitle = "Leden",
        menuTitle = "Rooster",
        inviteTitle = "Uitnodigen voor factie",
        inviteSubtitle = "Selecteer een speler en wijs een instaprang toe.",
        selectPlayer = "Selecteer speler",
        selectRank = "Selecteer rang",
        sendInvite = "Uitnodigen",
        columnNames = {
          name = "Naam",
          rank = "Rang",
          last_online = "Laatst online",
          total_work_time = "Werk tijd (u)",
          actions_done = "Voltooide acties",
          actions = "Acties"
        },
        bonus = {
          title = "Bonus uitgeven",
          confirmButton = "Bonus betalen",
          actionLabel = "Bonus",
          invalidAmount = "Voer een geldig bonusbedrag in.",
          failed = "Betaling van bonus mislukt.",
          unexpectedError = "Onverwachte fout bij betaling van bonus."
        },
        errors = {
          load = "Leden ophalen mislukt.",
          loadUnexpected = "Onverwachte fout bij het ophalen van leden.",
          invite = "Fout bij het verzenden van uitnodiging.",
          inviteUnexpected = "Onverwachte fout tijdens het verzenden van de uitnodiging."
        }
      },
      roles = {
        sidebarTitle = "Rollen",
        menuTitle = "Rollen",
        createRoleButton = "Rol aanmaken",
        columnNames = {
          grade = "Graad",
          label = "Rolnaam",
          salary = "Salaris",
          salaryInterval = "Interval (min.)",
          actions = "Acties"
        },
        editMenu = {
          title = "Rol bewerken",
          createTitle = "Rol aanmaken",
          createSaveButton = "Aanmaken",
          newRoleBreadcrumb = "Nieuwe rol",
          unnamedRole = "Naamloze rol",
          gradeMeta = "Rang {grade}",
          backButton = "Ga terug",
          saveButton = "Opslaan",
          general = "Algemeen",
          permissions = "Machtigingen",
          salary = "Salaris",
          salaryDescription = "Stel het salaris voor deze rol in.",
          salaryInterval = "Uitbetalingsinterval",
          salaryIntervalDescription = "Kies hoe vaak deze rol salaris ontvangt (in minuten werk).",
          roleName = "Rolnaam",
          roleNameDescription = "Stel de rolnaam voor deze rol in.",
          highestRoleInfo = "Dit is de hoogste rang en heeft automatisch toegang tot alle machtigingen."
        },
        unsavedChanges = {
          title = "Onopgeslagen wijzigingen",
          message = "U hebt onopgeslagen wijzigingen voor deze rol. Toch verlaten en deze wijzigingen verwijderen?",
          confirm = "Verlaten zonder op te slaan",
          cancel = "Blijf bewerken"
        },
        permissionsEmpty = "Geen machtigingen gevonden.",
        permissionEntries = {
          viewLogs = {
            label = "Bekijk logs",
            description = "Maakt het lezen van de werktransactie- en activiteitslogs mogelijk."
          },
          manageRoles = {
            label = "Beheer rollen",
            description = "Maakt het aanmaken, bewerken, verplaatsen en verwijderen van graden mogelijk."
          },
          manageMembers = {
            label = "Beheer leden",
            description = "Toestaan promotie, degradatie, ontslag of bonussen betalen."
          },
          manageWarehouse = {
            label = "Toegang tot opslagruimte",
            description = "Mogelijkheid om te communiceren met de gedeelde opslagvoorraden."
          },
          manageMoney = {
            label = "Financieel beheer",
            description = "Storten of opnemen van fonds van de organisatie."
          },
          editOutfits = {
            label = "Verwerken outfits",
            description = "Bijwerken van opgeslagen garderobe-items."
          },
          createOutfits = {
            label = "Ontwerp outfits",
            description = "Nieuw ontwerp voor garderobe-items maken."
          },
          deleteOutfits = {
            label = "Verwijder outfits",
            description = "Opgeslagen garderobe-items verwijderen."
          },
          purchaseSupplies = {
            label = "Bestel benodigdheden",
            description = "Bestellen van uitrusting via groothandelaar met fonds van de factie."
          },
          purchaseVehicles = {
            label = "Koop voertuigen",
            description = "Nieuwe vlootvoertuigen aanschaffen met factiefonds."
          },
          garageVehicles = {
            label = "Beperkingen voor garagevoertuigen",
            description = "Selecteer welke vlootvoertuigen deze rol niet kan gebruiken in de garage."
          },
          tabletApps = {
            label = "Beperkingen voor tablet-apps",
            description = "Kies welke tablet-apps deze rol niet kan gebruiken."
          },
          all = {
            label = "Volledige toegang",
            description = "Geeft alle toestemmingen, ongeacht andere schakelaars."
          }
        },
        permissionOptions = {
          storageHint = "Items toevoegen die niet verwijderd kunnen worden met deze rol.",
          storageItemsTitle = "Beperkte items",
          storageWeaponsTitle = "Beperkte wapens",
          allowedWeaponsTitle = "Toegestane wapens",
          weaponHint = "Wapens toevoegen die deze rol kan gebruiken.",
          vehicleHint = "Selecteer voertuigen die deze rol niet kan gebruiken.",
          appHint = "Selecteer tablet-apps die deze rol niet kan gebruiken.",
          itemPlaceholder = "Typ om een item toe te voegen",
          weaponPlaceholder = "Typ om een wapen toe te voegen",
          weaponSelectPlaceholder = "Selecteer een wapen",
          vehiclePlaceholder = "Selecteer een voertuig",
          appPlaceholder = "Selecteer een tablet-app",
          addButton = "Toevoegen",
          emptyVehicles = "Geen voertuigen beschikbaar.",
          emptyApps = "Geen tablet-apps beschikbaar.",
          errors = {
            empty = "Voer een waarde in.",
            duplicate = "Optie al toegevoegd.",
            itemMissing = "Item bestaat niet.",
            vehicleMissing = "Selecteer een voertuig.",
            appMissing = "Selecteer een tablet-app.",
            weaponMissing = "Wapen bestaat niet.",
            weaponSelectMissing = "Selecteer een wapen."
          }
        },
        errors = {
          save = "Fout bij het opslaan van de rol.",
          saveUnexpected = "Onverwachte fout bij het opslaan van rol.",
          permissionsLoad = "Fout bij het ophalen van machtigingen.",
          permissionsUnexpected = "Onverwachte fout bij het ophalen van machtigingen."
        }
      },
      logs = {
        sidebarTitle = "Logboeken",
        menuTitle = "Logboeken",
        errors = {
          load = "Fout bij het laden van logboeken."
        },
        columnNames = {
          timestamp = "Tijdstempel",
          name = "Naam",
          action = "Actie",
          content = "Inhoud"
        },
        actions = {
          stored = "Item opgeslagen",
          removed = "Item Verwijderd",
          deposited = "Geld gestort",
          withdrawn = "Geld opgenomen",
          outfit_created = "Outfit gemaakt",
          outfit_updated = "Outfit bijgewerkt",
          outfit_deleted = "Outfit verwijderd",
          permissions_updated = "Machtigingen bijgewerkt",
          invite_sent = "Uitnodiging verzonden",
          invite_accepted = "Uitnodiging geaccepteerd",
          invite_declined = "Uitnodiging geweigerd",
          bonus_paid = "Bonus uitbetaald",
          member_promoted = "Lid gepromoveerd",
          member_demoted = "Lid gedegradeerd",
          member_fired = "Lid ontslagen",
          supplies_purchased = "Benodigdheden gekocht",
          vehicle_purchased = "Voertuig gekocht",
          vehicle_sold = "Voertuig verkocht",
          salary_paid = "Salaris Betaald"
        }
      },
      dialogs = {
        deleteOutfit = {
          title = "Outfit verwijderen",
          message = "Wil je echt verwijderen \"{name}\"?",
          confirm = "Outfit verwijderen",
          cancel = "Annuleren"
        }
      }
    },
    cloakroom = {
      title = "Kleedkamer",
      civilianClothes = "Burgerkleding",
      newOutfit = "Nieuwe outfit",
      edit = {
        save = "Opslaan",
        rotateAlt = "Draaien",
        outfitNameTitle = "Outfitnaam",
        saveOutfit = "Outfit opslaan"
      }
    },
    tablet = {
      apps = {
        management = "Baasje menu",
        patients = "Patiënten",
        citizens = "Burgers",
        offences = "Overtredingen",
        cases = "Zaken",
        social_work = "Maatschappelijk werk",
        vehicles = "Voertuigen",
        weapons = "Wapens",
        prison = "Gevangenis",
        warrants = "Arrestatiebevelen",
        bolos = "BOLO's",
        conditions = "Condities",
        reports = "Rapporten",
        camera = "Camera",
        gallery = "Galerij",
        map = "Kaart",
        chat = "chatten",
        calendar = "Kalender",
        calculator = "Rekenmachine",
        settings = "Instellingen"
      }
    },
    common = {
      close = "Sluiten",
      unknownError = "onbekende fout.",
      unexpectedError = "onverwachte fout opgetreden.",
      time = {
        now = "Nu"
      },
      pagination = {
        prev = "Vorige",
        next = "Volgende",
        page = "Pagina {current} van {total}"
      },
      gallery = {
        title = "Galerij",
        subtitle = "Selecteer een foto of video.",
        loading = "Laden galerij...",
        empty = "Geen galerij-items beschikbaar.",
        photoAlt = "Galerij media"
      },
      back = "Terug",
      confirm = {
        unsavedTitle = "Niet opgeslagen wijzigingen",
        unsavedMessage = "Verwerp wijzigingen of sla ze op voordat je vertrekt?",
        unsavedDiscard = "Wijzigingen verwerpen",
        unsavedSave = "Wijzigingen opslaan"
      }
    },
    reports = {
      unknown = "Onbekend"
    },
    publicForms = {
      complaint = {
        fields = {
          fullName = "Volledige naam",
          phone = "Telefoonnummer",
          incidentDate = "Datum van het incident",
          incidentTime = "Tijd van het incident",
          location = "Locatie van het incident",
          officerName = "Naam van het personeel",
          badgeNumber = "Badge nummer",
          description = "Klachten details",
          witnesses = "Getuigen",
          desiredOutcome = "Gewenste oplossing",
          email = "E-mailadres",
          address = "Thuisadres",
          signature = "Handtekening"
        },
        title = "Burgerklacht",
        subtitle = "Rapporteer personeelshandelingen of concerns binnen de afdeling.",
        placeholders = {
          fullName = "Vul je volledige wettelijke naam in",
          phone = "###-###-####",
          email = "naam@email.com",
          address = "Straatnaam, stad, staat",
          incidentDate = "MM/DD/JJJJ",
          incidentTime = "UU:MM",
          location = "Waar gebeurde het?",
          officerName = "Naam of eenheid van het personeel",
          badgeNumber = "Badge nummer indien bekend",
          description = "Beschrijf wat er gebeurde in detail...",
          witnesses = "Som getuigen of andere partijen op",
          desiredOutcome = "Welke uitkomst vraag je?",
          signature = "Typ je volledige naam"
        }
      },
      application = {
        fields = {
          fullName = "Volledige naam",
          dateOfBirth = "Geboortedatum",
          phone = "Telefoonnummer",
          experience = "Relevante ervaring",
          availability = "Beschikbaarheid",
          whyJoin = "Waarom wil je meewerken?",
          email = "E-mailadres",
          address = "Thuisadres",
          education = "Opleiding",
          certifications = "Certificeringen",
          references = "Referenties",
          signature = "Handtekening"
        },
        title = "Sollicitatie",
        subtitle = "Solliciteer om lid te worden van de afdeling.",
        placeholders = {
          fullName = "Vul je volledige wettelijke naam in",
          dateOfBirth = "MM/DD/JJJJ",
          phone = "###-###-####",
          email = "naam@email.com",
          address = "Straatadres, stad, staat",
          education = "Hogeschool, academie of college",
          experience = "Wetshandhaving, beveiliging of servicefuncties",
          certifications = "Eerste hulp, vuurwapen, of gerelateerde trainingen",
          availability = "Voorkeursshift of startdatum",
          whyJoin = "Vertel ons waarom je hier wilt werken...",
          references = "namen en contactgegevens",
          signature = "Typ je volledige naam"
        }
      },
      title = "Openbare formulieren",
      subtitle = "Dien een klacht of sollicitatie in.",
      stationLabel = "station",
      dateLabel = "Datum",
      timeLabel = "Tijd",
      stamp = {
        label = "PD",
        complaint = "CMP",
        application = "APP"
      },
      tabs = {
        complaint = "Klachtformulier",
        application = "Sollicitatie",
        myForms = "Mijn inzendingen"
      },
      myForms = {
        title = "Mijn inzendingen",
        empty = "Je hebt nog geen formulieren ingediend.",
        back = "Terug",
        notesTitle = "Reacties",
        notesEmpty = "Nog geen reacties.",
        statusNew = "In afwachting",
        statusReviewed = "Beoordeeld",
        statusArchived = "Gearchiveerd"
      },
      actions = {
        submit = "Verzend formulier",
        clear = "Velden wissen",
        close = "Sluiten"
      },
      status = {
        submitting = "Verzenden...",
        success = "Formulier succesvol ingediend.",
        error = "Niet mogelijk om het formulier in te dienen."
      },
      errors = {
        required = "Vul de verplichte velden in."
      }
    },
    tabletForms = {
      title = "Formulier Inbox",
      eyebrow = "Openbare formulieren",
      listed = "geselecteerd",
      filters = {
        label = "Soort",
        all = "Alle formulieren",
        complaint = "Klachten",
        application = "Aanvragen"
      },
      search = {
        placeholder = "Zoeken op naam, station of id"
      },
      status = {
        new = "Nieuw",
        reviewed = "Geverifieerd",
        archived = "Gearchiveerd"
      },
      state = {
        empty = "Geen formulieren vinden die voldoen aan de huidige filters.",
        loading = "Formulieren laden...",
        saving = "Aan het opslaan..."
      },
      errors = {
        load = "Niet mogelijk om formulieren te laden.",
        update = "Niet mogelijk om de status van het formulier bij te werken."
      },
      detail = {
        complaintTitle = "Details van de klacht",
        applicationTitle = "Details van de aanvraag"
      },
      actions = {
        refresh = "Verversen",
        markReviewed = "Geverifieerd markeren",
        archive = "Archiveren",
        back = "Terug naar lijst"
      },
      notifications = {
        timeNow = "Nu",
        complaintType = "Klacht",
        applicationType = "Aanvraag",
        app = "Formulieren",
        title = "Nieuw openbaar formulier",
        body = "{type} van {name} ({station})"
      },
      fields = {
        type = "Soort formulier",
        id = "Formulier ID",
        station = "Station",
        submitted = "Indienen",
        status = "Status",
        contact = "Contact"
      },
      notes = {
        title = "Notities",
        loading = "Notities laden...",
        empty = "Nog geen notities.",
        placeholder = "Schrijf een notitie...",
        visibleBadge = "Zichtbaar voor burger",
        visibleToCitizen = "Zichtbaar voor burger",
        submit = "Notitie toevoegen"
      }
    },
    gallery = {
      eyebrow = "Bewijsgalerij",
      title = "Camera Rol",
      filters = {
        all = "Alles",
        camera = "Camera",
        speedcam = "Snelheidscamera's",
        cctv = "CCTV",
        mugshot = "Gezichtsfoto's"
      },
      labels = {
        count = "{count} foto's",
        sort = "Nieuwste eerst",
        photoAlt = "Galerij foto",
        photoFullAlt = "Volledige grootte foto",
        takenBy = "Gemaakt door",
        captured = "Gepubliceerd",
        unknownTime = "Onbekende tijd",
        unknownTakenBy = "Onbekend"
      },
      state = {
        loading = "Laden vastleggingen...",
        emptyTitle = "Nog geen foto's.",
        emptySubtitle = "Je laatste camerashots verschijnen hier."
      },
      errors = {
        load = "Kan galerij niet laden.",
        delete = "Kan foto niet verwijderen."
      },
      confirm = {
        deleteTitle = "Verwijder foto",
        deleteMessage = "Verwijder deze foto? Dit kan niet worden teruggedraaid.",
        deleteConfirm = "Verwijderen",
        deleteCancel = "Annuleren"
      },
      mock = {
        caption = "DEV CAPTURE"
      }
    },
    camera = {
      help = {
        focused = "Druk op Space om beweging mogelijk te maken.",
        blurred = "Druk op Space om de tablet opnieuw te gebruiken."
      },
      mode = {
        photo = "Foto",
        video = "Video",
        switchPhoto = "Overschakelen naar foto modus",
        switchVideo = "Overschakelen naar video modus"
      },
      capture = {
        photo = "Maak foto"
      },
      queue = {
        title = "Wachtrij",
        empty = "Nog geen uploads.",
        kind = {
          photo = "Foto uploaden",
          video = "Video uploaden"
        },
        status = {
          loading = "Bezig met uploaden...",
          success = "Opgeslagen",
          error = "Mislukt"
        }
      },
      preview = {
        lastShot = "Laatste shot",
        lastCapture = "Laatste opname"
      },
      record = {
        start = "Opnemen starten",
        stop = "Opname stoppen",
        live = "REC",
        saving = "Video wordt opgeslagen...",
        name = "Camera clip",
        description = "Tablet opname",
        errors = {
          config = "Upload config ontbreekt.",
          upload = "Uploaden mislukt.",
          save = "Video niet kunnen opslaan.",
          unsupported = "Registratie niet ondersteund.",
          empty = "Nog geen video vastgelegd.",
          busy = "Registratie is bezig.",
          notRecording = "Registratie reeds gestopt."
        }
      },
      errors = {
        timeout = "Upload tijdoverschreden.",
        capture = "Onverwachte fout bij het maken van een foto.",
        upload = "Uploaden mislukt."
      }
    },
    cctv = {
      eyebrow = "Bewakingsnetwerk",
      title = "CCTV",
      listed = "genoemd",
      actions = {
        refresh = "Vernieuwen"
      },
      search = {
        placeholder = "Zoek camera's op naam, ID of locatie"
      },
      filters = {
        all = "Alle cams",
        bodycam = "Bodycams",
        dashcam = "Dashcams",
        cctv = "CCTV-camera's",
        speedcam = "Snelheidscams"
      },
      types = {
        bodycam = "Bodycam",
        dashcam = "Dashcam",
        speedcam = "Snelheidscam",
        cctv = "CCTV-camera"
      },
      status = {
        online = "Online",
        maintenance = "Onderhoud",
        offline = "Offline"
      },
      live = {
        active = "Live feed actief",
        maintenance = "Feed gepauzeerd voor onderhoud",
        offline = "Signaal verloren",
        placeholderTitle = "Feed niet beschikbaar",
        placeholderSubtitle = "Selecteer een stafflid met bodycam.",
        speedcamPlaceholderTitle = "Snelheidscamera offline",
        speedcamPlaceholderSubtitle = "Repareer of vervang het apparaat om de feed te herstellen."
      },
      labels = {
        speedcamLocation = "Randweg",
        onDuty = "In dienst",
        durability = "Duurzaamheid"
      },
      state = {
        loading = "Camera's worden geladen...",
        empty = "Geen camera's die overeenkomen met de huidige filters.",
        select = "Selecteer een camera om de feed te bekijken."
      },
      controls = {
        tiltUp = "Kantel omhoog",
        panLeft = "Draai links",
        panRight = "Draai rechts",
        tiltDown = "Kantel omlaag"
      },
      capture = {
        name = "CCTV - {label}",
        description = "{locatie} ({id})",
        saved = "Opgeslagen in galerij.",
        error = "Kan afbeelding niet vastleggen.",
        action = "Vastleggen",
        loading = "Bezig met vastleggen..."
      },
      record = {
        name = "CCTV Clip - {label}",
        description = "{location} ({id})",
        save = "Opslaan de laatste {minutes} min",
        saving = "Bezig met opslaan...",
        requested = "Opslaan aanvraag verzonden.",
        saved = "Video opgeslagen in galerij.",
        errors = {
          config = "Uploadconfig ontbreekt.",
          upload = "Upload mislukt.",
          save = "Kan video niet opslaan.",
          unsupported = "Opnemen niet ondersteund.",
          empty = "Nog geen buffer beschikbaar.",
          request = "Kan bodycam-video niet aanvragen.",
          timeout = "Opslaan van bodycam timeout.",
          busy = "Opname is bezig.",
          notRecording = "Opname al gestopt."
        }
      },
      waypoint = {
        set = "Waypoint gezet.",
        missing = "Geen locatie beschikbaar."
      },
      errors = {
        load = "Kan camera's niet laden."
      }
    },
    chat = {
      targets = {
        allUnits = "Alle Units Chat",
        centralDispatch = "Centraal Dispatch"
      },
      header = {
        eyebrowRoom = "Personeelskanaal",
        eyebrowPrivate = "Prive Lijn",
        metaRoom = "Kamer",
        metaDirect = "Direct",
        metaStaff = "Personeel"
      },
      sidebar = {
        eyebrow = "Communicatie",
        title = "Personeelsnetzwerk",
        groupTitle = "Groepschat",
        allUnits = "Alle Units",
        staffTitle = "Personeel",
        loading = "Laden van personeel...",
        empty = "Geen personeel beschikbaar."
      },
      staff = {
        unknownMember = "Onbekende personeelslid",
        onDuty = "Aan dienst",
        offDuty = "Officier",
        grade = "Graad {level}",
        fallback = "Personeel"
      },
      composer = {
        placeholderRoom = "Schrijf een eenheid update...",
        placeholderDirect = "Bericht {name}...",
        pendingAlt = "In afwachting van delen"
      },
      messages = {
        avatarAlt = "Avatar van {name}",
        avatarFallback = "Personeelsavatar",
        unknownAuthor = "Onbekend",
        sharedEvidenceAlt = "Gedeeld bewijsstuk",
        tapToExpand = "Tik om uit te klappen"
      },
      preview = {
        ready = "Media klaar om te verzenden"
      },
      profile = {
        action = "Stel profielfoto in",
        galleryTitle = "Stel profielfoto in",
        gallerySubtitle = "Kies een foto voor je teamavatar.",
        photoAlt = "Profielfoto",
        selfPhotoAlt = "Profielfoto",
        error = "Kan profielfoto niet bijwerken."
      },
      actions = {
        remove = "Verwijderen",
        send = "Verzenden"
      },
      state = {
        syncing = "Berichten synchroniseren...",
        emptyRoom = "Nog geen chatter.",
        emptyPrivate = "Nog geen privéberichten.",
        emptyRoomHint = "Wees de eerste om in te checken bij de eenheid.",
        emptyPrivateHint = "Start een directe lijn met dit personeelslid."
      },
      errors = {
        load = "Kan chatgeschiedenis niet laden.",
        send = "Bericht niet kunnen verzenden.",
        members = "Kan personeel niet laden."
      }
    },
    bossMenu = {
      header = {
        eyebrow = "Baardmenu",
        title = "Beheer",
        balanceLabel = "Balans"
      },
      state = {
        loading = "Beheer data laden..."
      }
    },
    tabletSettings = {
      header = {
        eyebrow = "Tabletinstellingen",
        title = "Personalisatie",
        modeLabel = "Modus",
        modeLight = "Licht",
        modeDark = "Donker"
      },
      appearance = {
        title = "Uiterlijk",
        description = "Schakel de interface tussen licht en donker over.",
        light = "Licht",
        dark = "Donker"
      },
      wallpaper = {
        title = "Achtergrond",
        description = "Gebruik de standaard achtergrond, kies uit galerij, of voeg je eigen link toe.",
        labels = {
          default = "Standaard achtergrond",
          gallery = "Galerijfoto",
          url = "Aangepaste URL"
        },
        useDefault = "Gebruik standaard",
        chooseGallery = "Kies uit galerij",
        customUrlLabel = "Aangepaste afbeeldings-URL",
        customUrlPlaceholder = "https://example.com/wallpaper.jpg",
        apply = "Toepassen",
        hint = "Beste resultaten met 1920x1080 of hogere afbeeldingen."
      }
    },
    calendar = {
      weekdays = {
        mon = "Ma",
        tue = "Di",
        wed = "Wo",
        thu = "Do",
        fri = "Vr",
        sat = "Za",
        sun = "Zo"
      },
      selectedDateFallback = "Selecteer een datum",
      header = {
        eyebrow = "Gedeelde kalender",
        title = "Personeelsrooster",
        metaPrimary = "Zichtbaar voor alle medewerkers",
        metaSecondary = "Iedereen kan items toevoegen",
        hint = "Tik een dag aan om een shift of evenement toe te voegen"
      },
      actions = {
        dayEntries = "Dagrecords",
        addEntry = "Item toevoegen"
      },
      today = "Vandaag",
      more = "+{count} meer",
      modal = {
        addEntry = {
          eyebrow = "Voeg invoer toe",
          titleLabel = "Titel",
          titlePlaceholder = "Dienstinzending, training, patrouille",
          datetimeLabel = "Datum & tijd",
          colorLabel = "Kleur",
          clear = "Wissen",
          submit = "Aan kalender toevoegen"
        },
        dayEntries = {
          eyebrow = "Dagverslagen",
          empty = "Nog geen invoer. Voeg een briefing of patrouille toe om te delen met de eenheid."
        }
      }
    },
    calculator = {
      header = {
        eyebrow = "Veldgereedschap",
        title = "Rekenmachine",
        modeLabel = "Modus"
      },
      keys = {
        clearAll = "Uitgeschakeld",
        clearEntry = "CE"
      },
      mode = {
        standard = "Standaard"
      },
      status = {
        resetRequired = "Herstart vereist",
        ready = "Klaar"
      },
      errors = {
        error = "Fout"
      }
    },
    tabletHome = {
      status = {
        defaultDate = "Maandag, 01 jan"
      },
      calendar = {
        eventToday = "Evenement vandaag",
        eventTomorrow = "Evenement morgen",
        allDay = "Heel de dag",
        timeAt = " om {time}"
      },
      chat = {
        messageFrom = "Bericht van {name}",
        newMessage = "Nieuw bericht",
        authorFallback = "Personeelslid",
        messageBody = "{author}: {message}",
        sentPhoto = "{author} heeft een foto gestuurd.",
        sentMessage = "{author} heeft een bericht gestuurd."
      },
      notifications = {
        title = "Meldingen",
        clearAll = "Alles wissen",
        empty = "Alles bijgewerkt."
      }
    },
    map = {
      eyebrow = "Kaartbureau",
      title = "San Andreas Grid",
      markerLabel = "Marker",
      markerTypes = {
        label = "Marker lijst",
        dispatch = "Dispatch",
        officers = "Personeelsleden",
        speedcams = "Snelheids camera's",
        vehicles = "Voertuigen",
        trackers = "Trackers tonen"
      },
      markerList = {
        listed = "getoond",
        officersTitle = "Personeelslijst",
        speedcamsTitle = "Snelheids camera bord",
        vehiclesTitle = "Voertuig bord",
        trackersTitle = "Tracker bord",
        officersEmpty = "Geen personeel in dienst.",
        speedcamsEmpty = "Geen snelheids camera's beschikbaar.",
        trackersEmpty = "Geen trackers online.",
        vehiclesEmpty = "Geen voertuigen online."
      },
      dispatch = {
        title = "Dispatchbord",
        empty = "Geen dispatches op dit moment.",
        status = {
          active = "Actief",
          accepted = "Geaccepteerd",
          done = "Voltooid"
        },
        panelTitle = "Dispatchgegevens",
        statusLabel = "Status tonen",
        acceptedBy = "Geaccepteerd door",
        doneBy = "Voltooid door",
        coords = "Coördinaten",
        actions = {
          accept = "Acceptëren",
          done = "Markeer als voltooid",
          delete = "Verwijderen"
        },
        unknown = "Onbekend"
      },
      status = {
        available = "Beschikbaar",
        busy = "Bezig",
        pursuit = "Achtervolging",
        offDuty = "Niet in dienst"
      },
      vehicle = {
        status = {
          active = "Actief",
          offline = "Offline"
        }
      },
      tracker = {
        status = {
          active = "Actief",
          offline = "Offline"
        }
      },
      speedcam = {
        status = {
          online = "Online",
          maintenance = "Onderhoud",
          offline = "Offline"
        }
      },
      officerPanel = {
        title = "Personeelsgegevens",
        callsign = "Roepnaam {id}",
        rank = "Rang",
        health = "Gezondheid",
        coords = "Coördinaten",
        lastUpdateUnknown = "Zojuist"
      },
      speedcamPanel = {
        title = "Snelheidscameragegevens",
        limit = "Limiet",
        tolerance = "Tolerantie",
        health = "Gezondheid",
        coords = "Coördinaten"
      },
      vehiclePanel = {
        title = "Voertuidgegevens",
        plate = "Kenteken {plate}",
        netId = "Net-ID",
        health = "Gezondheid",
        coords = "Coördinaten"
      },
      trackerPanel = {
        title = "Trackergegevens",
        plate = "Kenteken {plate}",
        attachedBy = "Bevestigd door",
        attachedAt = "Bevestigd",
        netId = "Net-ID",
        status = "Status tonen",
        coords = "Coördinaten"
      },
      actions = {
        openCctv = "CCTV openen",
        setWaypoint = "Waypoint instellen"
      },
      waypoint = {
        set = "Waypoint ingesteld.",
        missing = "Geen locatie beschikbaar."
      },
      styles = {
        atlas = "Atlas",
        roads = "wegenlijnen",
        satellite = "Satelliet"
      },
      missing = {
        title = "Kaartafbeelding ontbreekt",
        body = "Plaats de kaartafbeeldingen in frontend/public/img."
      },
      signalLost = "Signaal verloren",
      details = {
        title = "Details weergeven",
        empty = "Selecteer een markering om details te bekijken."
      },
      zones = {
        title = "Uitsluitingszones",
        untitled = "Naamloze zone",
        hint = "Klik op de kaart om punten toe te voegen. Minimaal 3.",
        pointCount = "{count} punten",
        empty = "Nog geen afsluitingszones.",
        actions = {
          toggle = "Zones tonen",
          new = "Nieuwe zone",
          cancel = "Annuleren",
          save = "Zone opslaan",
          undo = "Ongedaan maken",
          clear = "wissen",
          delete = "Verwijderen"
        },
        modal = {
          title = "Naam afsluitingszone",
          confirm = "Zone opslaan"
        },
        errors = {
          points = "Voeg minimaal 3 punten toe.",
          nameRequired = "Voer een zone naam in.",
          saveFailed = "Kan de afsluitingszone niet opslaan.",
          deleteFailed = "Kan de afsluitingszone niet verwijderen."
        }
      },
      monitorZones = {
        title = "Enkelbandzones",
        untitled = "Naamloze zone",
        hint = "Klik op de kaart om punten toe te voegen. Minimaal 3.",
        pointCount = "{count} punten",
        empty = "Nog geen monitorzones.",
        mode = {
          allow = "Toegestane zone",
          exclude = "Beperkte zone"
        },
        actions = {
          allow = "Toegestane zone",
          exclude = "Beperkte zone",
          cancel = "Annuleren",
          save = "Zone opslaan",
          undo = "Ongedaan maken",
          clear = "wissen",
          delete = "Verwijderen"
        },
        modal = {
          title = "Naam monitorzone",
          confirm = "Zone opslaan"
        },
        errors = {
          points = "Voeg minimaal 3 punten toe.",
          nameRequired = "Voer een zone naam in.",
          noMonitor = "Selecteer een enkelband.",
          saveFailed = "Kan de monitorzone niet opslaan.",
          deleteFailed = "Kan de monitorzone niet verwijderen."
        }
      },
      panic = {
        panelTitle = "Paniekdetails",
        triggeredBy = "Getriggerd door",
        createdAt = "Getriggerd",
        coords = "Coördinaten"
      },
      dev = {
        officerName = "Personeel Avery Lane",
        callsign = "LIN-23",
        rank = "Sergeant",
        unit = "Central Patrouille",
        speedcamName = "Del Perro Snelheidscamera",
        vehicleName = "Eenheid 12",
        trackerName = "Tracker ALPHA",
        trackerOfficer = "Personeel Ruiz",
        dispatchTitle = "Snelheidscamera beschadigd",
        dispatchMessage = "Del Perro eenheid heeft onderhoud nodig.",
        panicOfficer = "Personeel Sinclair",
        panicLocation = "Mission Row"
      }
    },
    panicNotification = {
      badge = "Paniek",
      title = "Alarm bij paniek",
      subtitle = "{name} heeft op de panicknop gedrukt.",
      callsign = "Roepnaam {id}",
      locationLabel = "Locatie",
      locationUnknown = "Onbekende locatie",
      hint = "Druk op {key} om een waypoint op de ingame kaart te zetten."
    },
    incidentNotification = {
      panic = {
        title = "Paniekalarm",
        subtitle = "{name} heeft op de paniekknop gedrukt."
      },
      dispatch = {
        title = "Dispatchmelding",
        subtitle = "{name} heeft een nieuw dispatch gedeeld."
      },
      ping = {
        title = "Locatie-ping",
        subtitle = "{name} heeft een live locatie-ping gedeeld."
      },
      actions = {
        openMap = {
          key = "M",
          label = "In Tablet Map App bekijken"
        },
        setWaypoint = {
          key = "G",
          label = "Waypoint instellen"
        },
        dismiss = {
          key = "Backspace",
          label = "Sluiten"
        }
      }
    },
    gradeChange = {
      promotedTitle = "Promotie",
      demotedTitle = "Degradatie",
      unchangedTitle = "Rang bijgewerkt",
      previousLabel = "Vorige rang",
      newLabel = "Huidige rang",
      unknownLabel = "Niet toegewezen rang",
      levelFallback = "Gradatie {level}"
    },
    employeeGpsJammer = {
      title = "GPS-stoorzender",
      disabled = "GPS-storing is niet beschikbaar.",
      success = "GPS-signaal van medewerker verstoord.",
      failed = "Kan het GPS-signaal niet verstoren.",
      targetJammed = "Uw dienst-GPS-signaal wordt verstoord.",
      errors = {
        disabled = "GPS-storing is niet beschikbaar.",
        no_players = "Geen persoon in de buurt.",
        too_far = "Kom dichterbij voordat je de GPS-stoorzender gebruikt.",
        invalid_target = "Kan die persoon niet vinden.",
        not_on_duty = "Geen actief dienst-GPS-signaal gevonden op deze persoon.",
        protected_job = "Dit medewerkers-GPS-signaal is beschermd.",
        missing_item = "Je hebt een GPS-stoorzender nodig om dit te doen.",
        cooldown = "Wacht even voordat je de GPS-stoorzender opnieuw gebruikt.",
        failed = "Kan het GPS-signaal niet verstoren.",
      },
    },
    bonusNotification = {
      title = "Bonus toegekend",
      subtitle = "Van {name}",
      amountLabel = "Bonus",
      unknownManager = "Beheer"
    },
    wheelClamp = {
      attached = "Een wielklem is bevestigd"
    },
    search = {
      previewTitle = "Zoeken naar {name}",
      previewSubtitle = "Bezig met scannen van spullen op wapens en smokkelwaar...",
      previewCancel = "Druk op X om te annuleren",
      unknownTarget = "Onbekend"
    },
    heliCamHud = {
      title = "Heli Cam-besturing",
      actions = {
        toggleCam = "Schakel cam in/uit",
        vision = "Schakel visie in/uit",
        spotlight = "Lichtmodus",
        lockTarget = "Target vergrendelen",
        display = "Schakel scherm in/uit",
        takePhoto = "Maak foto",
        rappel = "Trek je omhoog",
        brightness = "Helderheid",
        radius = "Straal"
      }
    },
    jailHud = {
      title = "Tijd remaining",
      trashLabel = "Afval",
      trashFull = "Tasche vol",
      trashDropoff = "Lever bij container"
    },
    jailJobs = {
      title = "Gevangenisstraf taken",
      subtitle = "Kiezen om een taak te passeren.",
      actions = {
        cleaning = "Schoonmaken",
        gardening = "Tuinieren",
        carry_goods = "Goederen dragen"
      },
      currentJob = "Huidige baan:",
      stop = "Stop baan",
      close = "Sluiten",
      contraband = {
        title = "Contrabande",
        message = "Je hebt {item} gevonden. Neem je het risico en hou je het, of gooi je het weg?",
        keep = "Hou",
        toss = "Gooi"
      },
      boxInspect = {
        title = "Inspecteer doos",
        message = "In de doos vind je {item}. {description}",
        take = "Neem het",
        leave = "Laat het erin",
        close = "Sluiten"
      }
    },
    socialWork = {
      eyebrow = "Gemeenschapsdienst",
      title = "Maatschappelijk werk",
      listed = "geplaatst",
      search = {
        placeholder = "Zoek op naam of id"
      },
      filters = {
        all = "Alle",
        label = "Status",
        placeholder = "Status"
      },
      actions = {
        refresh = "Vernieuwen",
        back = "Terug naar lijst"
      },
      state = {
        loading = "Gemeenschapsdienst laden...",
        empty = "Geen gemeenschapsdients matches de huidige filters."
      },
      status = {
        active = "Actief",
        overdue = "Verlopen",
        completed = "Voltooid",
        imprisoned = "Gevangengezet"
      },
      labels = {
        remainingShort = "over",
        imprison = "Gevangenschap",
        imprisonNotice = "Deadline verstreken. Gevangenisstraf vereist.",
        noDeadline = "Geen deadline",
        expired = "Verleden"
      },
      sections = {
        summary = "Dienst samenvatting",
        summarySubtitle = "Overzicht van de toegewezen taken."
      },
      fields = {
        name = "Naam",
        status = "Status",
        remaining = "Overgebleven taken",
        completed = "Voltooide taken",
        total = "Totaal taken",
        assigned = "Toegewezen",
        deadline = "Einddatum",
        timeLeft = "Resterende tijd",
        assignedBy = "Toegewezen door",
        unknown = "Onbekend"
      },
      assign = {
        title = "Gemeenschapsdienst toewijzen",
        subtitle = "Een nabije speler naar maatschappelijke taken sturen.",
        playerLabel = "Speler",
        playerPlaceholder = "Kies speler",
        taskLabel = "Taken",
        taskPlaceholder = "Taak aantal",
        deadlineLabel = "Tijdslimiet (minuten)",
        deadlinePlaceholder = "Optioneel",
        submit = "Toewijzen",
        success = "Gemeenschapsdienst toegewezen.",
        error = "Kan gemeenschapsdienst niet toewijzen."
      },
      errors = {
        load = "Gemeenschapsdienst niet kunnen laden."
      },
      date = {
        unknown = "Onbekend"
      },
      jobs = {
        title = "Gemeenschapsdienst",
        subtitle = "Kies een taak om je zin te voltooien.",
        currentJob = "Huidige taak:",
        stop = "Stop taak",
        actions = {
          cleaning = "Schoonmaken",
          carry_goods = "Goederen dragen"
        }
      },
      hud = {
        title = "Gemeenschapsdienst",
        remaining = "Resterende taken",
        completed = "Voltooide taken",
        deadline = "Overgebleven tijd",
        expired = "Verlopen",
        trashLabel = "Afval",
        trashFull = "Tas vol",
        trashDropoff = "Lever bij container"
      }
    },
    socialWorkCreator = {
      title = "Maatschappelijk werk maker",
      description = "Configureer gemeenschapsdienstlocaties in de stad.",
      empty = "Nog geen sociale werkplekken geconfigureerd.",
      keyboardHint = "Gebruik pijltjestoetsen om door de lijst en acties te navigeren.",
      editTitle = "Sociale werkmarkeringen",
      editSubtitle = "Gebruik de kaartpin-knop om je huidige coördinaten op te slaan.",
      editKeyboardHint = "Gebruik pijltjestoetsen om een marker te kiezen, links/rechts om Set/Clear te kiezen, Enter om uit te voeren, Backspace om terug te gaan.",
      missingEntry = "Sociale werklocatie niet gevonden.",
      actions = {
        newSite = "Nieuwe locatie"
      },
      status = {
        set = "Instellen",
        unset = "Verwijderen"
      },
      markers = {
        social_work_job_npc = "NPC-baan",
        social_work_dumpster = "Container",
        social_work_box_dropoff = "Drop-off dragen"
      },
      modals = {
        createTitle = "Maak locatie aan",
        createButton = "Maak locatie aan",
        renameTitle = "Hernoem locatie",
        renameButton = "Opslaan naam",
        deleteTitle = "Verwijder locatie",
        deleteMessage = "Wil je {name} echt verwijderen?",
        deleteConfirmLabel = "Verwijderen",
        deleteCancelLabel = "Annuleren"
      }
    },
    impoundCreator = {
      title = "Impound maker",
      description = "Configureer wrakplaatsenlocaties en spawn-punten.",
      empty = "Nog geen wrakplaatsen geconfigureerd.",
      keyboardHint = "Gebruik pijltoetsen om door de lijst en acties te navigeren.",
      editTitle = "Zolenmarkeringen",
      editSubtitle = "Gebruik de knop met de kaartpin om je huidige coördinaten op te slaan.",
      editKeyboardHint = "Gebruik pijltoetsen om een markering te kiezen, links/rechts om Set/Verwijder/Verwijder te kiezen, Enter om uit te voeren, Backspace gaat terug. Ga voorbij de lijst om de Toevoegknoppen te bereiken.",
      missingEntry = "Zolenplaats niet gevonden.",
      actions = {
        newLot = "Nieuwe plaats",
        add = {
          impound_delivery = "Voeg afleveringspunt toe",
          impound_spawn = "Voeg spawn toe"
        }
      },
      status = {
        set = "Instellen",
        unset = "Dubbelzinnen verwijderd voor consistentie"
      },
      markers = {
        impound_lot = "Zolenplaats",
        impound_spawn = "Zolenspawn",
        impound_delivery = "Zolenaflevering"
      },
      modals = {
        createTitle = "Maak een plaats",
        createButton = "Maak een plaats aan",
        renameTitle = "Hernoem plaats",
        renameButton = "Sla naam op",
        deleteTitle = "Verwijder plaats",
        deleteMessage = "Wil je {name} echt verwijderen?",
        deleteConfirmLabel = "Verwijderen",
        deleteCancelLabel = "Annuleren"
      }
    },
    impoundStorage = {
      title = "Zolenopslag",
      subtitle = "Bestel opgeslagen voertuigen naar de locatie te brengen.",
      empty = "Geen opgeslagen voertuigen voor deze locatie.",
      emptyAll = "Geen inbeslaggenomen voertuigen gevonden.",
      unknownModel = "Onbekend",
      unknownLot = "Onbekend",
      sections = {
        impounds = "Actieve inbeslagname",
        stored = "Opgeslagen voertuigen"
      },
      columns = {
        plate = "Kenteken",
        model = "Model",
        stored = "Opgeslagen",
        lot = "Locatie",
        status = "Status",
        fee = "Opslagkosten"
      },
      actions = {
        deliver = "Bestel levering",
        allowPickup = "Pickup toestaan",
        seize = "In beslag genomen markering",
        seized = "In beslag genomen",
        close = "Sluiten",
        refresh = "Vernieuwen"
      },
      status = {
        pickup = "Pickup toegestaan",
        seized = "In beslag genomen"
      },
      time = {
        days = "{count} dag(en)"
      },
      errors = {
        load = "Niet mogelijk om opgeslagen voertuigen te laden.",
        deliver = "Niet mogelijk om levering te bestellen.",
        seized = "Deze voertuig is in beslag genomen voor onderzoek.",
        update = "Niet mogelijk om de status van de inbeslagname bij te werken."
      }
    },
    impoundDecision = {
      title = "Inbeslagname beslissing",
      message = "Beslis of {vehicle} opgehaald kan worden of in beslag genomen voor onderzoek.",
      vehicleFallback = "dit voertuig",
      allowPickup = "Allower ophalen",
      seize = "Inbeslag nemen voor onderzoek"
    },
    jailCreator = {
      title = "gevangenismaker",
      description = "Plaats gevangenisspunten en beheer locaties.",
      empty = "Nog geen gevangenissen geconfigureerd.",
      keyboardHint = "Gebruik pijltjestoetsen om door de lijst en acties te navigeren.",
      editTitle = "Gevangenismarkeringen",
      editSubtitle = "Gebruik de knop van de kaartpin om je huidige coördinaten op te slaan.",
      editKeyboardHint = "Gebruik pijltjestoetsen om een marker te kiezen, links/rechts om Set/Verwijder/Wissen te kiezen, Enter om uit te voeren, Backspace om terug te gaan. Ga voorbij de lijst om knoppen Toevoegen te bereiken.",
      missingEntry = "Gevangene niet gevonden.",
      actions = {
        newJail = "Nieuwe gevangenis"
      },
      modals = {
        createTitle = "Maak gevangenis aan",
        createButton = "Maak gevangenis aan",
        renameTitle = "Hernoem gevangenis",
        renameButton = "Opslaan naam",
        deleteTitle = "Gevangene verwijderen",
        deleteMessage = "Wil je echt {name} verwijderen?",
        deleteConfirmLabel = "Verwijderen",
        deleteCancelLabel = "Annuleren"
      }
    },
    jailInmates = {
      title = "Gevangentrade",
      close = "Sluiten",
      trade = "Voer handel uit",
      requiredLabel = "Jij geeft",
      rewardLabel = "Jij krijgt",
      acceptedLabel = "Accepteert",
      contrabandLabel = "Contrabande",
      npc = {
        alcoholic = "Celblokken borrelaar",
        drugDealer = "Wasruimte handelaar",
        doctor = "Gevangeniszuster",
        canteen = "Cafetariakok"
      },
      dialogs = {
        alcoholic = {
          one = "Ik heb ooit mijn dessert geruild voor een dweil. Beste dag van mijn leven.",
          two = "Als er hier een bar was, zou ik werknemer van de maand zijn.",
          three = "Heb je iets dat ruikt naar schone vloeren en slechte beslissingen?",
          four = "Ik noem het gevangeniscologne. Jij noemt het schoonmaakalcohol."
        },
        drugDealer = {
          one = "Heb je iets pittigs uit de prullenbak? Ik betaal met sigaretten.",
          two = "Houd je stem laag, de bewakers denken dat ik een boekenclub ben.",
          three = "Breng me contrabande en ik maak je dag rookbaar.",
          four = "De prullenbak verbergt schatten. Ik ben de schattaxateur."
        },
        doctor = {
          one = "Blijf stilzitten. Dit duurt maar even.",
          two = "Geen kosten vandaag. Blijf gewoon uit de problemen.",
          three = "Je ziet er ruw uit. Laat me je weer in orde maken.",
          four = "Cliänicetijden eindigen hier nooit."
        },
        canteen = {
          one = "Verse dienblad vandaag. Ga op de rij en blijf bewegen.",
          two = "Wil je een warme maaltijd of een lezing?",
          three = "Goed gedrag krijgt een tweede portie. Voorzichtig.",
          four = "Ik heb erger eetlust gezien."
        }
      },
      doctor = {
        costLabel = "Kosten",
        rewardLabel = "Behandeling",
        actionLabel = "Behandel je",
        costValue = "Gratis",
        rewardValue = "Volledige behandeling"
      },
      canteen = {
        costLabel = "Kosten",
        rewardLabel = "Maaltijd",
        actionLabel = "Maaltijd claimen",
        costValue = "Gratis",
        rewardValue = "Voedselpakket"
      },
      items = {
        cleaning_alcohol = "Reinigingsalcohol",
        cigarettes = "Sigaretten",
        coke = "Cola",
        weed = "Hasj",
        burger = "Hamburger",
        water = "Water"
      }
    },
    invites = {
      title = "Ban suggestion",
      description = "Neem deel aan {job} als {role}?",
      invitedBy = "Uitgenodigd door {name}",
      expires = "Deze aanbieding verloopt binnenkort.",
      accept = "Accepteer",
      decline = "Weiger",
      errors = {
        missing = "Uitnodiging niet beschikbaar.",
        failed = "Fout bij het beantwoorden van de uitnodiging."
      }
    },
    stationCreator = {
      title = "Stationsmaker",
      description = "Configureer stationsmarkeerposities.",
      empty = "Nog geen stations geconfigureerd.",
      keyboardHint = "Gebruik ↑/↓ om te selecteren, ←/→ om acties te wisselen, Enter om te bevestigen, Backspace om te sluiten.",
      editTitle = "Stationsmarkeringen",
      editSubtitle = "Gebruik de pindotoets op de kaart om je huidige coördinaten op te slaan.",
      editKeyboardHint = "Gebruik ↑/↓ om een marker te kiezen, ←/→ om Set/Wissen/Delete te kiezen, Enter om uit te voeren, Backspace om terug te gaan.",
      sections = {
        markers = "Markeringen",
        zone = "Gevangeniszone"
      },
      zone = {
        subtitle = "Voeg zonepunten toe om de gevangenismuur te definiëren.",
        hint = "Gebruik de pindotoets op de kaart om punten toe te voegen. Verwijder punten met het prullenbakpictogram.",
        empty = "Nog geen zonepunten.",
        pointLabel = "Zonepunt {index}",
        actions = {
          add = "Voeg zonepunt toe",
          update = "Bijwerken",
          clear = "Maak zone leeg"
        }
      },
      missingStation = "Station niet gevonden.",
      actions = {
        newStation = "Nieuw station",
        editJobBlip = "Job-blip bewerken",
        newJail = "Nieuwe gevangenis",
        add = {
          wardrobe = "Voeg garderobemarkering toe",
          garage_vehicle_menu = "Voeg interactie toe met voertuigen in de garage",
          garage_vehicle_spawn = "Voeg spawn toe voor voertuigen in de garage",
          garage_vehicle_park = "Voeg parkeren toe voor voertuigen in de garage",
          garage_helicopter_menu = "Voeg helipad-interactie toe",
          garage_helicopter_spawn = "Voeg spawn toe voor helipad",
          garage_helicopter_park = "Voeg parkeren toe voor helipad",
          garage_boat_menu = "Dok-interactie toevoegen",
          garage_boat_spawn = "Dok-spawn toevoegen",
          garage_boat_park = "Dok-parkeren toevoegen",
          boss_menu = "Voeg bazenmenu-markering toe",
          wholesale_shop = "Voeg groothandelswinkel-markering toe",
          duty_terminal = "Voeg diensten terminal-markering toe",
          public_forms = "Een openbaar formulierkiosk toevoegen",
          jail_solitary_cell = "Eénzame cel toevoegen"
        }
      },
      status = {
        set = "Instellen",
        unset = "Afstellen"
      },
      markers = {
        position = "Stationpositie",
        storage = "Opslag",
        locker = "Lockerkast",
        wardrobe = "Kledingkast",
        duty_terminal = "Dienstterminal",
        public_forms = "Openbaar formulierkiosk",
        boss_menu = "Baasje menu",
        garage_vehicle_menu = "Voertuiggarage interactie",
        garage_vehicle_spawn = "Voertuiggarage spawning",
        garage_vehicle_park = "Voertuiggarage parkeren",
        garage_helicopter_menu = "Heli-platform interactie",
        garage_helicopter_spawn = "Heli-platform spawning",
        garage_helicopter_park = "Heli-platform parkeren",
        garage_boat_menu = "Dok-interactie",
        garage_boat_spawn = "Dok-spawn",
        garage_boat_park = "Dok-parkeren",
        wholesale_shop = "Groothandel winkel",
        jail_spawn = "Gevangenspawn",
        jail_release = "Vrijlatingspunt",
        jail_menu = "Gevangenisterminal",
        jail_job_npc = "Gevangene baan NPC",
        jail_inmate_alcoholic = "Gevangene: Alcoholist",
        jail_inmate_drugdealer = "Gevangene: Drugdealer",
        jail_inmate_doctor = "Gevangene: Arts",
        jail_canteen_cook = "Kantine kok",
        jail_dumpster = "Gevangenis afvalcontainer",
        jail_box_dropoff = "Draag afleverpunt",
        jail_electric_box = "Elektriciteitskast",
        jail_fence_cut = "Afsluitpunt voor hek",
        jail_fence_exit = "Hek uitgang",
        jail_solitary_cell = "Eenzaam cel",
        jail_confiscated_return = "In beslag genomen voorwerpen"
      },
      modals = {
        createTitle = "Maak station aan",
        createButton = "Maak station aan",
        renameTitle = "Hernoem station",
        renameButton = "Opslaan naam",
        deleteTitle = "Verwijder station",
        deleteMessage = "Wil je {name} echt verwijderen?",
        deleteConfirmLabel = "Verwijderen",
        deleteCancelLabel = "Annuleren",
        jobBlipTitle = "Job-blip: {job}",
        jobBlipMessage = "Configureer de stationsblip voor deze specifieke baan. Schakel uit als deze baan geen stationsblip moet hebben.",
        jobBlipSave = "Blip opslaan",
        jobBlipReset = "Resetten",
        jobBlipInvalidNumber = "Ongeldige waarde voor {field}."
      },
      blip = {
        enabled = "Blip tonen",
        useStationName = "Stationsnaam toevoegen",
        shortRange = "Korte afstand",
        name = "Label",
        sprite = "Sprite",
        color = "Kleur",
        scale = "Grootte",
        display = "Weergave"
      }
    },
    jailAssign = {
      title = "Naar de gevangenis sturen",
      selectPlayer = "Selecteer speler",
      selectPlayerPlaceholder = "Kies speler",
      selectJail = "Selecteer gevangenis",
      selectJailPlaceholder = "Kies gevangenislocatie",
      solitaryLabel = "Eenzaam beleid",
      solitaryUnavailable = "Geen eenzame cellen geconfigureerd voor deze gevangenis.",
      durationLabel = "Duur (maanden)",
      monthHint = "1 maand = {minutes} minuten",
      cancelButton = "Annuleren",
      assignButton = "Send naar de gevangenis",
      assigning = "Naar de gevangenis sturen...",
      noPlayers = "Geen nabijgelegen spelers binnen {range} m.",
      noJails = "Nog geen gevangenissen geconfigureerd. Gebruik eerst de gevangenisaanmaker.",
      spawnMissing = "Deze gevangenis heeft geen spawn ingesteld.",
      jailStatusReady = "Spawn gereed",
      jailStatusMissing = "Geen spawn ingesteld",
      success = "Speler voor {months} maanden naar de gevangenis gestuurd.",
      errors = {
        invalid_target = "Selecteer een nabijgelegen speler en een gevangenis.",
        spawn_not_set = "Deze gevangenis heeft geen spawn ingesteld.",
        solitary_unavailable = "Geen solitaircellen geconfigureerd voor deze gevangenis.",
        failed = "Het is niet gelukt om de speler naar de gevangenis te sturen."
      }
    },
    bolos = {
      eyebrow = "BOLO-bord",
      title = "BOLO's",
      listed = "vermeld",
      unknown = "Onbekend",
      search = {
        placeholder = "Zoek BOLO's op titel, id, type of tag"
      },
      actions = {
        refresh = "Vernieuwen",
        manageTypes = "Types beheren",
        new = "Nieuwe BOLO",
        back = "Terug naar lijst",
        add = "Toevoegen",
        addPhoto = "Foto toevoegen",
        remove = "Verwijderen"
      },
      state = {
        loading = "BOLO's laden...",
        empty = "Geen BOLO's die overeenkomen met de huidige filters.",
        saving = "Opslaan...",
        noTags = "Geen tags toegewezen.",
        noReports = "Nog geen gekoppelde rapporten."
      },
      detail = {
        summary = "BOLO Samenvatting",
        untitled = "Ongesteld BOLO"
      },
      fields = {
        title = "BOLO titel",
        id = "BOLO-ID",
        type = "Type",
        status = "Status",
        priority = "Prioriteit",
        created = "Aangemaakt",
        updated = "Laatste update"
      },
      placeholders = {
        title = "BOLO titel",
        id = "Automatisch gegenereerd indien leeg",
        type = "Type selecteren",
        description = "Beschrijving toevoegen...",
        tag = "Tag toevoegen",
        reportSelect = "Rapport selecteren"
      },
      sections = {
        description = "Omschrijving",
        descriptionSubtitle = "Details en instructies vastleggen.",
        tags = "Tags",
        tagsSubtitle = "Voeg snelle identificaties toe voor de BOLO.",
        reports = "Gekoppelde rapporten",
        reportsSubtitle = "Voeg gerelateerde rapportbestanden toe.",
        gallery = "Galerij",
        gallerySubtitle = "Gallery-afbeeldingen toevoegen aan de BOLO."
      },
      gallery = {
        title = "Selecteer een foto",
        subtitle = "Kies een galerijafbeelding om toe te voegen aan de BOLO.",
        loading = "Laden van galerij...",
        empty = "Geen galerijfoto's beschikbaar.",
        photoAlt = "Galerijfoto"
      },
      typesModal = {
        title = "BOLO-types",
        subtitle = "Voeg toe of verwijder BOLO-types voor dit apparaat.",
        placeholder = "BOLO-type toevoegen",
        empty = "Geen BOLO-types geconfigureerd."
      },
      types = {
        person = "Persoon",
        vehicle = "Voertuig",
        property = "Eigendom",
        missing = " Vermist",
        other = "Overig"
      },
      status = {
        active = "Actief",
        located = "Gevonden",
        closed = "Gesloten",
        cancelled = "Geannuleerd"
      },
      priority = {
        low = "Laag",
        medium = "Gemiddeld",
        high = "Hoog",
        critical = "Kritisch"
      },
      errors = {
        load = "Niet mogelijk om BOLO's te laden.",
        save = "Niet mogelijk om BOLO op te slaan.",
        titleRequired = "Voer een BOLO-titel in voordat u opslaat.",
        typeRequired = "Selecteer een BOLO-type voordat u opslaat.",
        gallery = "Niet mogelijk om galerij te laden."
      }
    },
    warrants = {
      eyebrow = "Warrantkluis",
      title = "Juridische stukken",
      listed = "genoemd",
      unknown = "Onbekend",
      search = {
        placeholder = "Zoek warrants op titel, id, type of tag"
      },
      actions = {
        refresh = "Vernieuwen",
        manageTypes = "Types beheren",
        new = "Nieuw warrant",
        back = "Terug naar lijst",
        add = "Toevoegen",
        addPhoto = "Foto toevoegen",
        remove = "Verwijderen"
      },
      state = {
        loading = "Warrants laden...",
        empty = "Geen warrants die overeenkomen met de huidige filters.",
        saving = "Bezig met opslaan...",
        noTags = "Geen tags toegekend.",
        noReports = "Nog geen gekoppelde rapporten.",
        noOffences = "Nog geen gekoppelde overtredingen."
      },
      detail = {
        summary = "Samenvatting van warrant",
        untitled = "Ongespeelde warrant"
      },
      fields = {
        title = "Warrant-titel",
        id = "Bevelnummer",
        type = "Type",
        status = "Status",
        priority = "Prioriteit",
        created = "Aangemaakt",
        updated = "Laatste update"
      },
      placeholders = {
        title = "Warrant titel",
        id = "Wordt automatisch gegenereerd als leeg",
        type = "Selecteer type",
        description = "Voeg een beschrijving toe...",
        tag = "Voeg tag toe",
        reportSelect = "Selecteer een rapport",
        offenceSelect = "Selecteer een overtreding"
      },
      sections = {
        description = "Omschrijving",
        descriptionSubtitle = "Vang de samenvatting en instructies vast.",
        tags = "Tags",
        tagsSubtitle = "Voeg snelle identificatiemiddelen toe voor de warrant.",
        reports = "Linked rapporten",
        reportsSubtitle = "Voeg gerelateerde rapportbestanden toe.",
        offences = "Overtredingen",
        offencesSubtitle = "Koppel overtredingen aan deze warrant.",
        gallery = "Galerij",
        gallerySubtitle = "Voeg galerijafbeeldingen toe aan de warrant."
      },
      gallery = {
        title = "Selecteer een foto",
        subtitle = "Kies een galerijafbeelding om aan de warrant toe te voegen.",
        loading = "Laden van galerij...",
        empty = "Geen galerijfoto's beschikbaar.",
        photoAlt = "Galerijfoto"
      },
      typesModal = {
        title = "Beveltypen",
        subtitle = "Voeg warrant types toe of verwijder ze voor dit apparaat.",
        placeholder = "Voeg warrant type toe",
        empty = "Geen warrant types geconfigureerd."
      },
      types = {
        arrest = "Aanhouding",
        search = "Zoeken",
        bench = "Bank",
        probation = "Voorwaardelijk vrijlaten"
      },
      status = {
        active = "Actief",
        served = "Uitgedeeld",
        expired = "Verlopen",
        cancelled = "Geannuleerd"
      },
      priority = {
        low = "Laag",
        medium = "Gemiddeld",
        high = "Hoog",
        critical = "Kritiek"
      },
      errors = {
        load = "Niet in staat om warrants te laden.",
        save = "Niet in staat om warrant op te slaan.",
        titleRequired = "Voer een warrant titel in voordat u opslaat.",
        typeRequired = "Selecteer een warrant type voordat u opslaat.",
        gallery = "Kan galerij niet laden."
      }
    },
    prison = {
      eyebrow = "Detentie-log",
      title = "Gevangenis",
      listed = "vermeld",
      search = {
        placeholder = "Zoeken op naam of id"
      },
      filters = {
        all = "Alles",
        label = "Status",
        placeholder = "Status"
      },
      actions = {
        refresh = "Verversen",
        back = "Terug naar lijst",
        saveDuration = "Opslaan duur",
        minusMinutes = "-15 min",
        minusSmall = "-5 min",
        plusSmall = "+5 min",
        plusMinutes = "+15 min",
        saveNotes = "Notities opslaan",
        saveWarrant = "Warrant koppelen",
        addOffence = "Misdaad toevoegen",
        setSolitary = "Naar solitair sturen",
        setGeneral = "Terug naar algemeen"
      },
      state = {
        loading = "Prisoners laden...",
        empty = "Geen gevangenen gevonden die aan de huidige filters voldoen.",
        saving = "Bezig met opslaan...",
        noOffences = "Nog geen misdrijven gekoppeld."
      },
      labels = {
        mugshot = "Pasfoto"
      },
      detail = {
        summary = "Gedetineerden overzicht"
      },
      fields = {
        booked = "Geboekt",
        remaining = "Resterende tijd",
        identifier = "Identificatie",
        unknown = "Onbekend",
        remainingMinutes = "Resterende minuten",
        warrant = "Getuigeverklaring",
        offences = "Misdrijven",
        housing = "Woonruimte"
      },
      sections = {
        duration = "Vastgestelde duur",
        durationSubtitle = "Pas resterende tijd aan in minuten.",
        notes = "Notities",
        notesSubtitle = "Observaties loggen voor deze straf.",
        links = "Gekoppelde getuigeverklaring & misdrijven",
        linksSubtitle = "Voeg de getuigeverklaring en misdrijven toe die aan dit verblijf gekoppeld zijn.",
        housing = "Woonruimte",
        housingSubtitle = "Schakel tussen solitair en algemene bevolking."
      },
      placeholders = {
        note = "Notities toevoegen...",
        warrant = "Selecteer een getuigeverklaring",
        offence = "Selecteer een misdrijf"
      },
      status = {
        in_prison = "In de gevangenis",
        breaked_out = "Uitgebroken",
        released = "Vrijgelaten"
      },
      solitary = {
        active = "Solitair gevangenschap",
        inactive = "Algemene bevolking",
        badge = "Solitair"
      },
      duration = {
        minutesOnly = "{minutes}m over",
        full = "{hours}h {minutes}m overhouden"
      },
      linked = {
        warrantFallback = "Gewaarborg"
      },
      date = {
        unknown = "Onbekend"
      },
      errors = {
        load = "Niet mogelijk om gevangenen te laden.",
        duration = "Niet mogelijk om duur te updaten.",
        note = "Niet mogelijk om aantekening op te slaan.",
        links = "Niet mogelijk om links te updaten.",
        solitary = "Niet mogelijk om individueel te isoleren.",
        solitary_unavailable = "Geen afzonderlijke cellen geconfigureerd voor deze gevangenis."
      }
    },
    billing = {
      title = "Verzend rekening",
      subtitle = "Rekening sturen naar nabijgelegen burgers voor diensten.",
      selectLabel = "Selecteer persoon",
      selectPlaceholder = "Kies persoon",
      noPlayers = "Geen personen in de buurt binnen {range} m.",
      amountLabel = "Rekeningbedrag",
      reasonLabel = "Reden (kort)",
      reasonPlaceholder = "Voorbeeld: Patrouilleservice",
      presetsLabel = "Overtredingen",
      presetSearchPlaceholder = "Zoek overtreding of boete",
      presetNoMatches = "Geen overtredingen gevonden die aan je zoekopdracht voldoen.",
      presetReasonHeader = "Overtreding",
      presetAmountHeader = "Boete",
      presetCustomAmount = "Aangepast",
      paperDefaultCategory = "Kennisgeving van parkeer overtreding",
      ticketReceiptTitle = "Proces-verbaal",
      ticketReceiptSubtitle = "Gepubliceerd op",
      ticketReceiptCitizenLabel = "Burger",
      ticketReceiptOfficerLabel = "Personeelslid dat het uitlegt",
      ticketReceiptReasonLabel = "Samenvatting van de beschuldiging",
      ticketReceiptAmountLabel = "Totale boete",
      ticketReceiptAcknowledge = "Erkenning",
      cancelButton = "Annuleren",
      submitButton = "Rekening uitschrijven",
      submitting = "Bezig met verzenden...",
      success = "Rekening succesvol uitgeschreven.",
      paperTicketNumber = "Ticketnummer",
      paperDate = "Datum",
      paperTime = "Tijdstip",
      paperCitizenLabel = "Burger",
      paperOfficerLabel = "Personeelslid",
      paperViolationLabel = "Overtreding",
      paperNotice = "Betaling vereist onmiddellijk. Niet betalen kan leiden tot inbeslagname.",
      paperSignatureLabel = "Personeels ondertekening",
      paperTotalFine = "Totale boete",
      errors = {
        failed = "Kan geen rekening uitschrijven.",
        invalid_target = "Persoon niet beschikbaar.",
        empty_reason = "Geef een korte reden.",
        too_far = "Persoon verplaatst zich te ver weg.",
        not_authorized = "U bent niet bevoegd om rekeningen uit te schrijven.",
        not_on_duty = "U moet in dienst zijn om rekeningen uit te schrijven.",
        amount_out_of_range = "{'key': 'amount_out_of_range', 'text': 'Factuurbedrag buiten het toegestane bereik.'}",
        insufficient_funds = "{'key': 'insufficient_funds', 'text': 'Persoon kan deze kosten niet betalen.'}",
        player_unavailable = "{'key': 'player_unavailable', 'text': 'Persoon niet beschikbaar.'}",
        disabled = "{'key': 'disabled', 'text': 'Factureringssysteem uitgeschakeld.'}"
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
        title = "Functies",
        subtitle = "Schakel resourcefuncties in of uit voor alle geconfigureerde jobs.",
        instantTuning = { label = "instantTuning", description = "" },
        partsDelivery = { label = "Onderdelenlevering", description = "Schakel werkplaatsbestellingen en leverzones in." },
        carryItems = { label = "Fysieke onderdelenafhandeling", description = "Vereis dat geleverde onderdelen door de werkplaats worden vervoerd." },
        nitro = { label = "nitro", description = "" },
        antiLag = { label = "antiLag", description = "" },
        twoStep = { label = "twoStep", description = "" },
        wheelDamage = { label = "Wielschade", description = "Schakel realistische wielschade en reparaties in." },
        customHandling = { label = "customHandling", description = "" },
        mileageHud = { label = "Kilometer-HUD", description = "Toon kilometerinformatie tijdens het rijden." },
        workshopLift = { label = "Werkplaatsbrug", description = "Schakel bruikbare brugpunten in werkplaatsen in." }
      },
globalSettings = { title = "Global settings", notice = "These values apply to all configured jobs. Saving them from this job updates the behavior globally." },
      tuning = { globalTitle = "Global pricing settings", globalBadge = "Global", globalNotice = "These values apply to all configured jobs. Saving them from this job updates pricing behavior globally.", nitroAccess = "Nitrotogang voor deze job", nitroAccessHelp = "Overschrijf de globale Nitro-functie voor deze monteurbaan.", nitroAccessInherit = "Gebruik globale Nitro-instelling", nitroAccessEnabled = "Nitro inschakelen voor deze job", nitroAccessDisabled = "Nitro uitschakelen voor deze job" },
      fields = { allowedJobs = "Allowed jobs", animationDict = "Animation dict", animationName = "Animation name", blip = "Blip", bone = "Bone", category = "Category", color = "Job color", consumeItems = "Consume items", cost = "Cost", distance = "Distance", enabled = "Enabled", garageType = "Garage type", heading = "Heading", item = "Item", jobName = "Job name", label = "Label", marker = "Marker", mechanicOnly = "Mechanic", name = "Name", offsetX = "Offset X", offsetY = "Offset Y", offsetZ = "Offset Z", offDutyEnabled = "Off-duty enabled", offDutyJob = "Off-duty job", ped = "Ped", pedModel = "Ped model", price = "Price", prop = "Prop", requiredItems = "Required items", scenario = "Scenario", sprite = "Sprite", stage = "Stage", transport = "Transport", trunkCapacity = "Trunk capacity", type = "Type", value = "Value", x = "X", y = "Y", z = "Z", minGrade = "Min rang", livery = "Livrei", fuelType = "Brandstoftype", primaryColor = "Primaire kleur", secondaryColor = "Secundaire kleur", pearlescentColor = "Parelmoerkleur", wheelColor = "Wielkleur", extras = "Extra's", extraId = "Extra-ID", propCounts = "Prop-limieten", count = "Limiet", properties = "Voertuigeigenschappen", property = "Eigenschap" },
      placeholders = { allowedJobs = "mechanic, tuner", itemName = "Item name", jobName = "job name", label = "Label", model = "Model", vehicleName = "Name", liveryIndex = "e.g. 0", paintIndex = "0-160", propCounts = "{ \"prop_model\": 4 }", properties = "{ \"windowTint\": 1 }" },
      fuelTypes = {
        default = "Standaard (normaal)",
        regular = "Normaal",
        plus = "Plus",
        premium = "Premium",
        diesel = "Diesel",
      },
      descriptions = { color = "Color used by Sky Jobs menus, blips, and job UI accents.", jobName = "Framework job name registered for this job.", offDutyEnabled = "Enable an off-duty counterpart for this job.", offDutyJob = "Job name used when this employee goes off duty." },
      messages = { empty = "No jobs configured yet.", featuresSaved = "Features saved.", invalidJson = "Correct invalid JSON fields before saving.", loading = "Loading jobs...", nameExists = "A job with this job name already exists.", noTuningOptions = "No options configured in this category.", saved = "Settings saved.", saveFailed = "Unable to save changes." },
      locations = { addSubtitle = "Choose which point type to place.", addTitle = "Add location point", deleteFailed = "Unable to delete location.", deleteSaved = "Location removed. Save settings to apply it.", emptySubtitle = "This configurator has no registered location definitions.", emptyTitle = "No locations configured.", garageMenu = "Menu", garagePark = "Park", garageSpawn = "Spawn", placeFailed = "Unable to place location.", placementHint = "Press Enter to place and Backspace to cancel.", placementSaved = "Location updated. Save settings to apply it.", placementTitle = "Placement mode", teleported = "Teleported to location.", teleportFailed = "Unable to teleport to location.", unset = "Not set" },
      carryItems = { missingProp = "Enter a prop model before opening placement.", placementFailed = "Unable to edit attach placement.", placementSaved = "Attach placement updated. Save settings to apply it.", selectItem = "Select delivery item" },
      extensions = { invalidJson = "Ongeldige JSON. Corrigeer de syntax voor het opslaan.", jsonObjectRequired = "De waarde moet een JSON-object zijn.", partsDeliveryShop = "Onderdelenlevering winkel", tuningCostProfile = { label = "Tuningprijzen", description = "Configureer kosten voor performance, uiterlijk, wielen en speciale opties voor deze job." } },
garageTypes = { boat = "Boat", helicopter = "Helicopter", vehicle = "Vehicle" },
      colorPopup = { title = "Job color" },
      dialogs = { delete = { cancel = "Cancel", confirm = "Delete", message = "Delete {name}?", title = "Delete job" } },
      screenPosition = { preview = "HUD" },
      interactions = { title = "Interactions", empty = "No interactions configured.", addMarkerSetting = "Add marker setting", noPedSelected = "No ped selected", headers = { interaction = "Interaction", key = "Key", marker = "Marker", blip = "Blip", npc = "NPC" }, tabs = { behavior = "Behavior", marker = "Marker", blip = "Blip", npc = "NPC" }, status = { on = "On", off = "Off" }, fields = { unique = "Unique", forceMarkerInteraction = "Force marker interaction", interactionDistance = "Interaction distance", placementModel = "Placement model" }, help = { unique = "Limits the interaction type to one configured point for a location when enabled.", forceMarkerInteraction = "Forces marker-style interaction handling even when target/NPC interaction support is available.", interactionDistance = "Maximum distance from the point where the player can use the interaction.", placementModel = "Object model shown while placing this interaction in the creator." } },
      assetPicker = { search = "Search", allCategories = "All categories", itemCount = "{count} items", markerTitle = "Marker type", markerSubtitle = "Choose a DrawMarker type.", blipTitle = "Blip sprite", blipSubtitle = "Choose a map blip sprite.", pedTitle = "Ped model", pedSubtitle = "Choose a FiveM ped model.", chooseMarker = "Choose marker", chooseBlip = "Choose blip", choosePed = "Choose ped" },
      markerFields = { posX = "Position X", posY = "Position Y", posZ = "Position Z", dirX = "Direction X", dirY = "Direction Y", dirZ = "Direction Z", rotX = "Rotation X", rotY = "Rotation Y", rotZ = "Rotation Z", scaleX = "Scale X", scaleY = "Scale Y", scaleZ = "Scale Z", red = "Red", green = "Green", blue = "Blue", alpha = "Alpha", bobUpAndDown = "Bob up/down", faceCamera = "Face camera", rotationOrder = "Rotation order", rotate = "Rotate", textureDict = "Texture dict", textureName = "Texture name", drawOnEnts = "Draw on entities" },
      instantTuning = { title = "Instant Tuning", defaultLabel = "Default label", defaultLabelHelp = "Text shown at instant tuning points.", interactionDistanceHelp = "Default distance from which a point can be used.", priceMultiplier = "Price multiplier", priceMultiplierHelp = "Multiplier applied to instant tuning prices.", forceMarkerHelp = "Forces marker-style interaction handling even when target support is available.", mechanicOnlyHelp = "Restricts every instant tuning point to configured mechanic jobs.", allowedJobsHelp = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", emptyLocations = "No instant tuning locations configured.", emptyLocationsHelp = "Add a location, then use Set to capture your current position." }
  ,

      configs = { sky_mechanicjob = { title = "Monteur-jobs", subtitle = "Configureer monteur-jobs, winkels, voertuigen en werkplaatslocaties." } },
      settingSections = { general = "Algemeen", partsTheft = "Onderdelendiefstal", vehicleCare = "Voertuigonderhoud", wear = "Slijtage", wheelDamage = "Wielschade", mileageHud = "Kilometer-HUD", instantTuning = "Instant Tuning", carryItems = "Draagbare onderdelen" },
      settingFields = { key = "Sleutel", label = "Label", name = "Itemnaam", amount = "Aantal", price = "Prijs", item = "Item", repair = "Repareer met kit", classId = "Klasse-ID", multiplier = "Vermenigvuldiger", kilometersToZero = "Kilometers tot nul", removeAfterUse = "Item verbruiken", flow = "Installatiestap", transport = "Transport", prop = "Prop", bone = "Bone", x = "X", y = "Y", z = "Z", rx = "Rot X", ry = "Rot Y", rz = "Rot Z", category = "Categorie" },
      settings = {
        primaryColor = { label = "Primaire kleur", description = "Main mechanic configurator color and default job color fallback. Use a hex value such as #EDC001." },
        orderInstallNonMinigameDurationMs = { label = "Eenvoudige installatieduur", description = "Milliseconds used for order install steps that do not run a minigame." },
        tuningWorkshopRequireForInstall = { label = "Werkplaats vereist voor installatie", description = "Require tuning order installs to start and complete near a self-service tuning point." },
        tuningWorkshopRequireForRemoval = { label = "Werkplaats vereist voor verwijderen", description = "Require tuning removals to start and complete near a self-service tuning point." },
        tuningWorkshopDistance = { label = "Vereiste werkplaatsafstand", description = "Maximum distance from a self-service tuning point for required install or removal actions." },
        addRevenueToSociety = { label = "Inkomsten naar society storten", description = "Deposit paid tuning order money into the tuning job society account." },
        publicUsersSeePrices = { label = "Publiek ziet prijzen", description = "Show regular tuning prices to non-mechanic public users." },
        fallbackVehicleValue = { label = "Standaard voertuigwaarde", description = "Value used when no vehicle price can be resolved." },
        priceType = { label = "Prijstype", description = "Percentage calculates each tuning cost from the vehicle price. Fixed uses the entered money amount.", options = { percentage = "Percentage", fixed = "Vast" } },
        freeVehicles = { label = "Gratis tuning voertuigen", description = "Vehicle spawn models that receive free tuning orders.", itemLabel = "Vehicle model" },
        partsTheftItem = { label = "Diefstalgereedschap", description = "Inventory item used to steal wheels and catalytic converters." },
        partsTheftRemoveItemAfterUse = { label = "Diefstaltool verbruiken", description = "Remove the theft tool item after a successful theft action." },
        partsTheftStolenWheelItem = { label = "Gestolen wiel", description = "Inventory item awarded when wheels are stolen." },
        partsTheftCatalyticConverterItem = { label = "Katalysator", description = "Inventory item awarded when a catalytic converter is stolen." },
        partsTheftDealerAccount = { label = "Dealer payout account", description = "Account used for stolen parts dealer payouts, such as money or bank." },
        partsTheftDealerSellDistance = { label = "Dealer sell distance", description = "Maximum distance from the dealer to sell stolen parts." },
        partsTheftDispatchEnabled = { label = "Politie-dispatch sturen", description = "Create a police dispatch when a wheel or catalytic converter is stolen." },
        partsTheftDispatchJobs = { label = "Dispatch jobs", description = "Job names that receive parts theft dispatches.", itemLabel = "Job name" },
        partsTheftDispatchTitle = { label = "Dispatch title", description = "Title shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchMessage = { label = "Dispatch message", description = "Message shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchCooldownSeconds = { label = "Dispatch cooldown", description = "Seconds before the same vehicle part can create another dispatch." },
        partsTheftDealerItems = { label = "Dealer items", description = "Stolen items the dealer will buy and their payout values.", itemLabel = "Dealer item" },
        vehicleCareWashItem = { label = "Was-item", description = "Inventory item used to wash a vehicle." },
        vehicleCareWashRemoveAfterUse = { label = "Was-item verbruiken", description = "Remove the wash item after use." },
        vehicleCareWaxItem = { label = "Wax-item", description = "Inventory item used to wax a vehicle." },
        vehicleCareWaxRemoveAfterUse = { label = "Wax-item verbruiken", description = "Remove the wax item after use." },
        vehicleCareWaxCleanKilometers = { label = "Wax clean kilometers", description = "Distance a waxed vehicle stays clean." },
        vehicleCareRepairItem = { label = "Reparatie-item", description = "Inventory item used by the vehicle repair action." },
        vehicleCareRepairRemoveAfterUse = { label = "Reparatie-item verbruiken", description = "Remove the repair item after use." },
        vehicleCareRepairDurationMs = { label = "Reparatieduur", description = "Repair progress duration in milliseconds." },
        vehicleCareRepairMaxDistance = { label = "Repair max distance", description = "Maximum distance from the vehicle while repairing." },
        vehicleCareRepairVehicleDamage = { label = "Fix vehicle damage", description = "Repair normal GTA vehicle damage when using the repair action." },
        vehicleCareRepairFixRealisticWheelDamage = { label = "Fix realistic wheel damage", description = "Also reset realistic wheel damage when using the repair action." },
        vehicleCareRepairWearParts = { label = "Repair kit restored parts", description = "Choose which wear and service parts the repair item restores. Disable fluids here if oil, coolant, brake fluid, or transmission fluid should require the diagnostics repair flow.", itemLabel = "Wear part" },
        wearParts = { label = "Slijtageonderdelen", description = "Vehicle wear parts, their lifetime distance, required repair item, item consumption, and install flow.", itemLabel = "Wear part", fields = { flow = { options = { wheel = "Wheel", performance = "Performance", underbody_neon = "Underbody / lift", oil_change = "Oil change", fluid_refill = "Fluid refill", catalytic_converter = "Catalytic converter", hood_install = "Hood install" } } } },
        wheelDamageDefaultMultiplier = { label = "Standaard vermenigvuldiger", description = "Base wheel damage multiplier." },
        wheelDamageOffroadWheelsMultiplier = { label = "Off-road wheel multiplier", description = "Multiplier used when the vehicle has off-road wheels." },
        wheelDamageVehicleClassMultipliers = { label = "Vehicle class multipliers", description = "Damage multipliers per GTA vehicle class.", itemLabel = "Vehicle class" },
        mileageHudDigits = { label = "Cijfers", description = "Number of digits shown in the mileage HUD." },
        mileageHudPosition = { label = "Positie", description = "Drag the mileage HUD preview to the desired screen position." },
        partsDeliveryTimeSeconds = { label = "Levertijd", description = "Seconds between ordering parts and the delivery becoming ready." },
        partsDeliveryTimerHudEnabled = { label = "Show delivery timer", description = "Show a small in-game timer HUD after a parts order is placed." },
        partsDeliveryTimerHudPosition = { label = "Timer position", description = "Drag the parts delivery timer HUD preview to the desired screen position." },
        partsDeliveryOwnCard = { label = "Own card payment", description = "Allow players to pay parts delivery orders with their own money." },
        partsDeliveryCompanyCard = { label = "Company card payment", description = "Allow parts delivery orders to use company funds." },
        partsDeliveryOpenDurationMs = { label = "Open duration", description = "Milliseconds required to unpack a ready parts delivery." },
        instantTuningInteractionDistance = { label = "Interactieafstand", description = "Default distance for using instant tuning points." },
        instantTuningForceMarkerInteraction = { label = "Force marker interaction", description = "Use marker-style E interaction even when target support is enabled." },
        instantTuningMechanicOnly = { label = "Alleen monteurs", description = "Restrict all instant tuning locations to configured mechanic jobs." },
        instantTuningAllowedJobs = { label = "Toegestane jobs", description = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", itemLabel = "Job name" },
        instantTuningPriceMultiplier = { label = "Prijsvermenigvuldiger", description = "Multiplier applied to instant tuning prices." },
        instantTuningLabel = { label = "Standaard label", description = "Default text shown at instant tuning points." },
        instantTuningMarkerEnabled = { label = "Marker enabled", description = "Draw a world marker at instant tuning locations." },
        instantTuningMarkerType = { label = "Marker type", description = "GTA marker type used for instant tuning locations." },
        instantTuningBlipEnabled = { label = "Blip enabled", description = "Show map blips for instant tuning locations." },
        instantTuningBlipName = { label = "Blip name", description = "Map blip name." },
        instantTuningBlipSprite = { label = "Blip sprite", description = "GTA blip sprite id." },
        instantTuningBlipColor = { label = "Blip color", description = "GTA blip color id." },
        instantTuningLocations = { label = "Locaties", description = "Instant tuning points. Use 0 distance to inherit the default interaction distance.", itemLabel = "Locations" },
        carryItems = { label = "Draagbare onderdelen", description = "Delivered parts that should become physical carried props.", itemLabel = "Carry item", fields = { transport = { options = { hand = "Hand", forklift = "Heftruck", engine_lift = "Motortakel" } } } }
      },
      settingValues = {
        tyres = "Tyres", brake_pads = "Brake Pads", suspension = "Suspension", spark_plugs = "Spark Plugs", engine_oil = "Engine Oil", coolant = "Coolant", brake_fluid = "Brake Fluid", transmission_fluid = "Transmission Fluid", clutch = "Clutch", air_filter = "Air Filter", traction_battery = "Traction Battery", inverter = "Power Inverter", catalytic_converter = "Catalytic Converter",
        vehicleClass_0 = "Compacts", vehicleClass_1 = "Sedans", vehicleClass_2 = "SUVs", vehicleClass_3 = "Coupes", vehicleClass_4 = "Muscle", vehicleClass_5 = "Sports Classics", vehicleClass_6 = "Sports", vehicleClass_7 = "Super", vehicleClass_8 = "Motorcycles", vehicleClass_9 = "Off-road", vehicleClass_10 = "Industrial", vehicleClass_11 = "Utility", vehicleClass_12 = "Vans", vehicleClass_13 = "Cycles", vehicleClass_14 = "Boats", vehicleClass_15 = "Helicopters", vehicleClass_16 = "Planes", vehicleClass_17 = "Service", vehicleClass_18 = "Emergency", vehicleClass_19 = "Military", vehicleClass_20 = "Commercial", vehicleClass_21 = "Trains", vehicleClass_22 = "Open Wheel"
      }
  },
    jobConfigurator = {
      actions = {
        backToScripts = "Scripts"
      },
      selector = {
        title = "Banen Configurator",
        subtitle = "Kies welk baanscript je wilt configureren.",
        description = "Selecteer de resource die je wilt configureren.",
        loading = "Configurators laden...",
        comingSoon = "Binnenkort",
        emptyTitle = "Geen configureerbare scripts beschikbaar.",
        emptySubtitle = "Je hebt geen toestemming voor enige geregistreerde baanconfigurator.",
        unavailable = "Niet geregistreerd"
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
