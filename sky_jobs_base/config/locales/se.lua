if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/config/locales/se.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

-- Swedish translation
Locales["se"] = {
  WardrobeHelpNotify = "Öppna garderob",
  WardrobeTitle = "Garderob",
  WardrobeCivilianMissing = "Inga civila kläder sparade ännu.",
  WardrobeCivilianRestored = "Civila kläder laddade.",
  WardrobeUnsupportedFramework = "Garderoben fungerar inte med det valda frameworket ({framework}).",
  WardrobeMissingSkinchanger = "Garderoben kraver att skinchanger ar startat pa ESX.",
  WardrobeMissingEsxSkin = "Garderoben kraver att esx_skin ar startat pa ESX.",
  WardrobeMissingQbClothing = "Garderoben kraver att qb-clothing ar startat pa {framework}.",
  WardrobeMissing17Movement = "Garderoben kraver att 17mov_CharacterSystem ar startat.",
  WardrobeMissingQsAppearance = "Garderoben kraver att qs-appearance ar startat.",
  WardrobeMissingAk47Clothing = "Garderoben kraver att ak47_clothing ar startat.",
  WardrobeMissingAk47QbClothing = "Garderoben kraver att ak47_qb_clothing ar startat.",
  WardrobeMissingTgiannClothing = "Garderoben kraver att tgiann-clothing ar startat.",
  WardrobeMissingNfSkin = "Garderoben kraver att nf-skin ar startat.",
  WardrobeMissingBlAppearance = "Garderoben kraver att bl_appearance ar startat.",
  WardrobeMissingIzzyAppearance = "Garderoben kraver att izzy-appearance ar startat.",
  WardrobeMissingCodemAppearance = "Garderoben kraver att codem-appearance ar startat.",
  WardrobeMissingHexClothing = "Garderoben kraver att hex_clothing ar startat.",
  WardrobeMissingIllenium = "Garderoben kraver att illenium-appearance ar startat.",
  WardrobeCustomUnavailable = "Den konfigurerade anpassade garderobsintegrationen ar inte tillganglig.",
  WardrobeDisabled = "Garderoben ar inaktiverad i configen.",
  WardrobeMissingRcoreClothing = "Garderoben kräver att rcore_clothing är startat.",
  WardrobeUnknownJob = "Garderobjobbet är inte tillgängligt.",
  GarageHelpNotify = "Öppna garage",
  GarageTitle = "Garage",
  HelicopterGarageHelpNotify = "Öppna helikopterplatta",
  BoatGarageHelpNotify = "Öppna hamn",
  GarageParkHelpNotify = "Parkera fordonet",
  HelicopterGarageParkHelpNotify = "Parkera helikoptern",
  BoatGarageParkHelpNotify = "Parkera båten",
  GarageParkDriverRequired = "Du måste sitta i förarsätet för att parkera.",
  GarageParkInvalidVehicle = "Detta fordon kan inte parkeras här.",
  GarageParkFailedNotify = "Kunde inte parkera fordonet.",
  GarageSpawnBlockedNotify = "Utfarten är blockerad.",
  StorageHelpNotify = "Öppna förråd",
  LockerHelpNotify = "Öppna skåp",
  TrunkTitle = "Bagasjelucka",
  TrunkHelpNotify = "Öppna bagageluckan",
  TrunkPropRemoveHelp = "Ta bort utplacerat objekt",
  TrunkUnavailable = "Går inte att komma åt bagageluckan.",
  BossMenuHelpNotify = "Öppna hantering",
  Payroll = {
    title = "Löneutbetalning",
    paid = "Lön utbetald: {amount}",
    insufficient = "Företagskontot saknar täckning för din lön.",
  },
  PublicFormsTitle = "Offentliga formulär",
  PublicFormsHelpNotify = "Fyll i offentliga formulär",
  PublicFormsUnavailable = "Kiosken för offentliga formulär är ur funktion.",
  WholesaleShopTitle = "Grossist",
  WholesaleShopHelpNotify = "Öppna grossistbutik",
  WholesaleShopUnavailable = "Denna plats har ingen konfigurerad grossist.",
  NoPermission = "Du har inte tillåtelse att använda detta kommando.",
  CameraUploadFailed = "Uppladdning av bild misslyckades.",
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
    Title = "Panik",
    Sent = "Panikknapp aktiverad.",
    NotOnDuty = "Du måste vara i tjänst för att använda panikknappen.",
    Cooldown = "Panikknappen laddar om. Vänta {seconds}s.",
    MappingDescription = "Utlös paniklarm",
    WaypointSet = "Vägpunkt satt till panikplatsen.",
    WaypointMissing = "Ingen aktiv panikplats hittades.",
    LocationUnknown = "Okänd plats",
    MissingItem = "Du behöver {item} för att använda panikknappen.",
  },
  Ping = {
    Title = "Ping",
    Sent = "Platsping delad.",
    NotOnDuty = "Du måste vara i tjänst för att skicka en ping.",
    Cooldown = "Ping-funktionen laddar om. Vänta {seconds}s.",
    MappingDescription = "Utlös platsping",
    LocationUnknown = "Okänd plats",
    MissingItem = "Du behöver {item} för att skicka en ping.",
  },
  HeliCam = {
    Title = "Helikopterkamera",
    CamEnabled = "Helikopterkamera aktiverad.",
    CamDisabled = "Helikopterkamera inaktiverad.",
    NotAuthorized = "Du är inte behörig att använda helikopterkameran.",
    NotOnDuty = "Du måste vara i tjänst för att använda helikopterkameran.",
    TooLow = "Helikoptern flyger för lågt för att aktivera kameran.",
    TargetLocked = "Mål låst.",
    TargetReleased = "Mållås frigjort.",
    TargetLost = "Mål förlorat.",
    RappelDenied = "Du kan inte fira ner dig från detta säte.",
    RappelStarted = "Firning påbörjad.",
    PhotoSaved = "Flygbild sparad i galleriet.",
    PhotoFailed = "Kunde inte spara flygbilden.",
    Spotlight = {
      ForwardOn = "Sökarljus på.",
      ForwardOff = "Sökarljus av.",
      TrackingOn = "Följande strålkastare aktiverad.",
      TrackingOff = "Följande strålkastare avstängd.",
      ManualOn = "Manuell strålkastare aktiverad.",
      ManualOff = "Manuell strålkastare avstängd.",
      Brightness = "Strålkastarens ljusstyrka: {value}",
      Radius = "Strålkastarens radie: {value}"
    }
  },
  InteractionLabels = {
    job_garage              = "Jobbgarage",
    garage_vehicle_spawn    = "Fordonsspawnpunkt",
    garage_vehicle_park     = "Fordonsparkering",
    garage_helicopter_menu  = "Helikoptergarage",
    garage_helicopter_spawn = "Helikopterspawnpunkt",
    garage_helicopter_park  = "Helikopterparkering",
    garage_boat_menu        = "Båtbrygga",
    garage_boat_spawn       = "Båtspawnpunkt",
    garage_boat_park        = "Båtparkering",
    boss_menu               = "Chefsmeny",
    duty_terminal           = "Tjänsteterminal",
    wardrobe                = "Garderob",
    storage                 = "Förråd",
    locker                  = "Personligt skåp",
    wholesale_shop          = "Grossist",
    public_forms            = "Offentliga formulär",
    jail_terminal           = "Fängelseterminal",
    jail_jobs               = "Fängelsejobb",
    jail_job_npc            = "Fängelsejobb",
    jail_inmate_alcoholic   = "Fånge: Alkoholist",
    jail_inmate_drugdealer  = "Fånge: Langare",
    jail_inmate_codelist    = "Fånge: Informatör",
    jail_inmate_wirecutter  = "Fånge: Verktygsbudbärare",
    jail_inmate_doctor      = "Fängelseläkare",
    jail_canteen_cook       = "Matsalskock",
    jail_confiscated_return = "Beslagtagna föremål",
    jail_electric_box       = "Elskåp",
    jail_fence_cut          = "Klippningspunkt i stängsel",
  },
  Nui = {
    IntlLocale = "sv-SE",
    currency = "SEK",
    menuTitles = {
      locker = "Personligt Skåp",
      storage = "Förråd",
      trunk = "Fordonets Förråd",
      ["trunk-props"] = "Fordonsrekvisita",
      search = "Sök",
      garage = "Garage",
      vehshop = "Fordonsbutik",
      management = "Hantering",
      shop = "Grossist",
      ["impound-storage"] = "Beslagtaget Förråd",
      refunds = "Återbetalningar"
    },
    menu = {
      goToVehicleShop = "Gå till Fordonsbutik",
      backToGarage = "Tillbaka till Garage"
    },
    radial = {
      empty = "Inga åtgärder tillgängliga just nu.",
      errors = {
        generic = "Åtgärden är inte tillgänglig."
      },
      title = "Tjänsteåtgärder",
      hint = "Välj en åtgärd att utföra.",
      pressKey = "Tryck på {key}",
      actions = {
        billing = {
          label = "Skicka faktura",
          description = "Skicka en faktura till närmaste person.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Fakturering är inte tillgänglig.",
            notOnDuty = "Gå i tjänst för att skicka fakturor.",
            notAuthorized = "Du är inte behörig att skicka fakturor.",
            noPatients = "Inga personer i närheten att fakturera."
          }
        },
        panic = {
          label = "Panikknapp",
          description = "Utlös ett paniklarm för din nuvarande plats.",
          states = {
            disabled = "Panikknappen är inte tillgänglig.",
            notOnDuty = "Gå i tjänst för att använda panikknappen.",
            notAuthorized = "Du är inte behörig att använda panikknappen."
          }
        },
        tablet = {
          label = "Öppna surfplatta",
          description = "Öppna surfplattans gränssnitt.",
          states = {
            missingItem = "Du behöver en surfplatta för det här.",
            notOnDuty = "Gå i tjänst för att använda surfplattan.",
            notAuthorized = "Du är inte behörig att använda surfplattan."
          }
        },
        removeProp = {
          label = "Ta bort objekt",
          description = "Ta bort ett utplacerat objekt i närheten.",
          states = {
            noNearby = "Inget objekt i närheten.",
            failed = "Misslyckades med att ta bort objektet."
          }
        },
        carryPatient = {
          label = "Bär person",
          description = "Bär den närmaste personen till säkerhet.",
          dropLabel = "Släpp person",
          dropDescription = "Släpp personen du bär på.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Bärande är inte tillgängligt.",
            beingCarried = "Du blir redan buren.",
            inVehicle = "Gå ut ur fordonet först.",
            selfIncapacitated = "Du är inte tillräckligt stabil för att bära någon.",
            noPatients = "Ingen person i närheten att bära.",
            tooFar = "Gå närmare innan du bär någon."
          }
        },
        playerSearch = {
          label = "Sök igenom person",
          description = "Visitera närmaste person.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Visitering är inte tillgänglig.",
            notOnDuty = "Gå i tjänst för att visitera folk.",
            notAuthorized = "Du är inte behörig att visitera folk.",
            noPlayers = "Ingen person i närheten att visitera.",
            tooFar = "Gå närmare innan du visiterar.",
            inVehicle = "Gå ut ur fordonet först."
          }
        },
        handcuff = {
          label = "Handfängsla person",
          description = "Sätt handfängsel på närmaste person.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Handfängsel är inte tillgängligt.",
            notOnDuty = "Gå i tjänst för att använda handfängsel.",
            inVehicle = "Gå ut ur fordonet först.",
            targetInVehicle = "Ta ut personen ur fordonet först.",
            noPlayers = "Ingen person i närheten att fängsla.",
            tooFar = "Gå närmare innan du fängslar.",
            missingItem = "Du behöver handfängsel för att göra detta.",
            alreadyCuffed = "Den personen är redan fängslad."
          }
        },
        unhandcuff = {
          label = "Ta bort handfängsel",
          description = "Ta bort handfängsel från närmaste person.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Upplåsning av handfängsel är inte tillgängligt.",
            notOnDuty = "Gå i tjänst för att ta bort handfängsel.",
            inVehicle = "Gå ut ur fordonet först.",
            targetInVehicle = "Ta ut personen ur fordonet först.",
            noPlayers = "Ingen person i närheten att låsa upp.",
            tooFar = "Gå närmare innan du låser upp handfängsel.",
            notCuffed = "Den personen är inte fängslad."
          }
        },
        wheelClamp = {
          label = "Hjulboja",
          description = "Säkra närmaste fordon genom att sätta en hjulboja.",
          states = {
            disabled = "Hjulboja är inte tillgängligt.",
            notOnDuty = "Gå i tjänst för att använda hjulbojor.",
            inVehicle = "Gå ut ur fordonet först.",
            noVehicle = "Inget fordon i närheten.",
            tooFarVehicle = "Gå närmare fordonet.",
            noWheel = "Gå närmare ett hjul.",
            tooFar = "Gå närmare ett hjul."
          }
        },
        wheelClampRemove = {
          label = "Ta bort hjulboja",
          description = "Ta bort hjulbojan från fordonet.",
          states = {
            disabled = "Hjulboja är inte tillgängligt.",
            notOnDuty = "Gå i tjänst för att ta bort hjulbojor.",
            inVehicle = "Gå ut ur fordonet först.",
            noClamp = "Ingen hjulboja i närheten.",
            tooFar = "Gå närmare hjulbojan."
          }
        },
        jail = {
          label = "Skicka till fängelse",
          description = "Fängsla närmaste spelare på en konfigurerad plats.",
          states = {
            notAuthorized = "Du är inte behörig att skicka spelare till fängelse.",
            notOnDuty = "Gå i tjänst för att använda denna åtgärd.",
            noPlayers = "Inga spelare inom räckhåll.",
            noJails = "Inga fängelseplatser konfigurerade.",
            spawnNotSet = "Konfigurera en fängelseplats först.",
            invalidTarget = "Kunde inte hitta personen.",
            failed = "Kunde inte utföra åtgärden."
          }
        }
      }
    },
    shop = {
      shoppingCart = "Kundvagn",
      purchase = "Köp",
      balance = "Tillgängliga medel",
      catalog = "Leverantörskatalog",
      empty = "Inga varor tillgängliga på denna plats.",
      emptyCart = "Din varukorg är tom.",
      insufficientFunds = "Inte tillräckligt med pengar för detta köp.",
      limitReached = "Gräns nådd ({limit}).",
      errors = {
        invalidStation = "Ogiltig station.",
        emptyBasket = "Varukorgen är tom.",
        unknown = "Okänt fel.",
        purchase = "Köp av varukorg misslyckades."
      }
    },
    garage = {
      states = {
        stored = "Redo",
        parked = "I bruk"
      },
      title = "Garage",
      empty = "Inga tjänstefordon tillgängliga.",
      emptyAir = "Inga helikoptrar tillgängliga på denna platta.",
      ownedTitle = "Ägd vagnpark",
      shopTitle = "Fordonsbutik",
      shopBalance = "Organisationsmedel",
      shopEmpty = "Inga fordon tillgängliga för köp på denna plats.",
      shopEmptyAir = "Inga helikoptrar tillgängliga för köp på denna platta.",
      emptyFleet = "Inga fordon har köpts in ännu.",
      noAccess = "Ingen tillgång",
      confirmSellTitle = "Bekräfta försäljning",
      confirmSellConfirm = "Sälj",
      confirmSellCancel = "Avbryt",
      confirmSellMessage = "Sälj {name} för {price}?",
      confirmPurchaseTitle = "Bekräfta köp",
      confirmPurchaseConfirm = "Köp",
      confirmPurchaseCancel = "Avbryt",
      confirmPurchaseMessage = "Köp {name} för {price}?",
      purchaseSuccessTitle = "Fordon köpt",
      purchaseSuccessMessage = "{name} tillagt till vagnparken.",
      defaultVehicleName = "Fordon",
      stats = {
        topSpeed = "Topphastighet",
        acceleration = "Acceleration",
        braking = "Bromsning",
        traction = "Grepp"
      },
      actions = {
        parkOut = "Ta ut fordon",
        buyVehicle = "Köp fordon",
        openTrunk = "Öppna bagagelucka",
        editStretcher = "Redigera bår",
        sellVehicle = "Sälj fordon",
        changePlate = "Byt skylt"
      },
      placeholders = {
        selectVehicle = "Välj ett fordon för att se detaljer.",
        statsLoading = "Laddar fordonsinformation..."
      },
      errors = {
        loadVehicles = "Misslyckades med att ladda garagefordon.",
        loadStats = "Misslyckades med att ladda fordonsstatistik.",
        parkOut = "Misslyckades med att ta ut fordonet.",
        unavailable = "Garaget är inte tillgängligt.",
        vehicleUnavailable = "Fordonet är inte tillgängligt.",
        purchase = "Fordonsköp misslyckades.",
        openTrunk = "Misslyckades med att öppna bagageluckan.",
        noAccess = "Ingen tillgång till detta fordon.",
        stretcherEditor = "Kunde inte öppna bår-redigeraren.",
        stretcherPermission = "Endast högsta rang kan redigera bår-tillbehör.",
        sellVehicle = "Misslyckades med att sälja fordonet.",
        editorUnavailable = "Redigeraren är inte tillgänglig.",
        changePlate = "Kunde inte byta skylt."
      },
      changePlateTitle = "Byt registreringsskylt",
      changePlateButton = "Tillämpa",
      plateEditor = {
        button = "Redigera skylt",
        title = "Redigera skylt",
        hint = "Ändra skylten för detta fordon.",
        save = "Spara skylt",
        errors = {
          empty = "Ange en skylt.",
          invalid = "Skylten är ogiltig.",
          update = "Kunde inte uppdatera skylten."
        }
      },
      status = {
        parkedBy = "Senast tagen ut av {name}",
        unknownDriver = "Okänd"
      }
    },
    duty = {
      fields = {
        grade = "Rang",
        location = "Station",
        name = "Namn",
        badge = "Tjänstenummer"
      },
      instructions = {
        drag = "Dra ditt anställdkort till sensorn för att hantera ditt arbetspass.",
        dragCard = "Dra kortet till sensorn för att påbörja ditt pass."
      },
      screen = {
        welcome = "Välkommen {name}",
        goodbye = "Passet avslutades. Ha det bra, {name}.",
        ready = "Passbehörighet beviljad.",
        completed = "Passet avslutades framgångsrikt.",
        idleTitle = "Väntar på skanning",
        totalHours = "Totalt antal timmar",
        shiftDuration = "Passtid",
        currentTime = "Nuvarande tid: {time}",
        defaultStation = "Huvudterminal",
        devPrompt = "Ladda testdata för att förhandsgranska terminalen.",
        loadMock = "Ladda testdata",
        loading = "Laddar..."
      },
      toasts = {
        failed = "Kunde inte uppdatera tjänstestatus."
      },
      errors = {
        unavailable = "Tjänsteterminalen är inte tillgänglig."
      },
      title = "Arbetspassterminal"
    },
    storage = {
      inventory = "Inventarie",
      storage = "Förråd",
      locker = "Skåp",
      trunk = "Fordonets Bagagelucka",
      trunkProps = "Fordonsrekvisita",
      openPropMenu = "Objekt",
      search = "Sök",
      items = "Föremål",
      weapons = "Vapen",
      transferTitle = "Överför",
      transferButton = "Överför",
      capacityUnlimited = "Obegränsad kapacitet",
      errors = {
        trunkFull = "Bagageluckan är full.",
        searchReadOnly = "Du kan endast ta föremål från personen.",
        invalidTransfer = "Överföring misslyckades.",
        invalidAmount = "Ogiltigt antal.",
        notEnoughItems = "Inte tillräckligt med föremål.",
        inventoryFull = "Inte tillräckligt med utrymme i inventariet.",
        storageFull = "Förrådet är fullt.",
        lockerFull = "Skåpet är fullt.",
        restrictedItem = "Du har inte tillgång till detta föremål.",
        invalidProp = "Misslyckades med att välja objekt."
      },
      officerInventory = "Personalinventarie",
      loadout = "Utrustning",
      armory = "Vapenförråd",
      armoryTitle = "Utrustningsförråd",
      storageTitle = "Säkert Förråd",
      storageSubtitle = "Endast behörig personal",
      emptyItems = "Inga föremål tillgängliga.",
      emptyWeapons = "Inga vapen tillgängliga.",
      emptyProps = "Ingen rekvisita tillgänglig.",
      searchItems = "Föremål",
      searchWeapons = "Vapen",
      lockerUnlocking = "Låser upp skåp...",
      restrictedPill = "Begränsad",
      restrictedTooltip = "Du har inte tillgång till detta föremål.",
      capacityLabel = "{used}/{capacity}",
      propPlacement = {
        title = "Objektsplacering",
        place = "Placera ({key})",
        cancel = "Avbryt ({key})"
      }
    },
    creator = {
      title = "Skapare",
      description = "Konfigurera inlägg.",
      selectJob = "Välj en jobbkategori.",
      empty = "Inga {entryLabelPlural} konfigurerade ännu.",
      keyboardHint = "Använd piltangenterna för att navigera i listan.",
      placementHelp = "Piltangenter flyttar, PageUp/PageDown justerar höjd, Q/E roterar, Enter placerar, Backspace avbryter.",
      editTitle = "Markörer",
      editSubtitle = "Använd kartknappen för att spara dina koordinater.",
      editKeyboardHint = "Piltangenter för markör, Enter för att köra, Backspace för tillbaka.",
      missingEntry = "Inlägget hittades inte.",
      actions = {
        add = "Lägg till {label}",
        newEntry = "Ny {entryLabel}"
      },
      status = {
        set = "Satt",
        unset = "Ej satt"
      },
      modals = {
        createTitle = "Skapa {entryLabel}",
        createButton = "Skapa {entryLabel}",
        renameTitle = "Byt namn på {entryLabel}",
        renameButton = "Spara namn",
        deleteTitle = "Ta bort {entryLabel}",
        deleteMessage = "Vill du verkligen ta bort {name}?",
        deleteConfirmLabel = "Ta bort",
        deleteCancelLabel = "Avbryt"
      }
    },
    management = {
      noAccess = "Du har inte tillgång till några hanteringsverktyg.",
      refunds = {
        description = "Granska dödsfall från idag och igår och återbetala föremål.",
        refreshButton = "Uppdatera",
        updatedAt = "Uppdaterad {time}",
        errors = {
          loadFailed = "Misslyckades med att ladda återbetalningar."
        }
      },
      dashboard = {
        sidebarTitle = "Kontrollpanel",
        menuTitle = "Översikt",
        onlineMembers = "Medlemmar Online",
        funds = "Medel",
        onDuty = "I Tjänst",
        offDuty = "Ej i Tjänst",
        mostActive = "Mest Aktiva"
      },
      finance = {
        sidebarTitle = "Kassaflöde",
        menuTitle = "Finansiell Översikt",
        expenseCategories = "Utgiftskategorier",
        revenueCategories = "Inkomstkategorier",
        kpis = {
          revenue = "Inkomst",
          expenses = "Utgifter",
          profit = "Vinst"
        },
        cashFlow = "Kassaflödestrend",
        lastUpdated = "Uppdaterad {time}",
        emptyStates = {
          timeline = "Inga transaktioner registrerade under denna period.",
          categories = "Ingen kategoridata ännu."
        },
        categories = {
          deposits = "Insättningar",
          withdrawals = "Uttag",
          supplies = "Material",
          vehicles = "Fordon",
          salaries = "Löner",
          bonuses = "Bonusar"
        },
        errors = {
          load = "Kunde inte ladda finansiell överblick."
        }
      },
      transactions = {
        sidebarTitle = "Ekonomi",
        menuTitle = "Ekonomihantering",
        currentBalance = "Nuvarande Saldo",
        withdrawButton = "Ta ut",
        depositButton = "Sätt in",
        recentTransactions = "Senaste Transaktioner",
        columnNames = {
          timestamp = "Tidsstämpel",
          name = "Namn",
          action = "Åtgärd",
          content = "Belopp"
        },
        actions = {
          deposited = "Pengar Insatta",
          withdrawn = "Pengar Uttagna",
          supplies_purchased = "Material Inköpt",
          vehicle_purchased = "Fordon Inköpt",
          vehicle_sold = "Fordon Sålt",
          salary_paid = "Lön Utbetald",
          bonus_paid = "Bonus Utbetald"
        },
        errors = {
          load = "Kunde inte ladda transaktioner.",
          failed = "Transaktionen misslyckades."
        }
      },
      billingSpecs = {
        sidebarTitle = "Faktureringsmallar",
        menuTitle = "Faktureringsorsaker",
        description = "Konfigurera orsaker för fakturering och deras standardpriser.",
        reasonColumn = "Orsak",
        priceColumn = "Pris",
        actionsColumn = "Åtgärder",
        reasonLabel = "Faktureringsorsak",
        reasonPlaceholder = "t.ex. Patrullinsats",
        amountLabel = "Standardpris",
        emptyState = "Inga orsaker tillagda ännu.",
        addButton = "Lägg till",
        addFirstButton = "Skapa din första orsak",
        deleteButton = "Ta bort",
        saveButton = "Spara",
        reasonRequired = "Ange en orsak för att spara denna rad.",
        saveSuccess = "Faktureringsinställningar uppdaterade.",
        saveError = "Kunde inte spara inställningar.",
        loadError = "Kunde inte ladda inställningar.",
        updatedAt = "Uppdaterad {time}"
      },
      members = {
        sidebarTitle = "Medlemmar",
        menuTitle = "Medlemslista",
        inviteTitle = "Bjud in till fraktion",
        inviteSubtitle = "Välj en spelare och tilldela en ingångsrang.",
        selectPlayer = "Välj spelare",
        selectRank = "Välj rang",
        sendInvite = "Bjud in",
        columnNames = {
          name = "Namn",
          rank = "Rang",
          last_online = "Senast Online",
          total_work_time = "Arbetstid (h)",
          actions_done = "Utförda Åtgärder",
          actions = "Åtgärder"
        },
        bonus = {
          title = "Betala ut bonus",
          confirmButton = "Betala bonus",
          actionLabel = "Bonus",
          invalidAmount = "Ange ett giltigt bonusbelopp.",
          failed = "Misslyckades med att betala bonus.",
          unexpectedError = "Oväntat fel vid bonusbetalning."
        },
        errors = {
          load = "Misslyckades med att hämta medlemmar.",
          loadUnexpected = "Oväntat fel vid hämtning av medlemmar.",
          invite = "Misslyckades med att skicka inbjudan.",
          inviteUnexpected = "Oväntat fel vid inbjudan."
        }
      },
      roles = {
        sidebarTitle = "Roller",
        menuTitle = "Roller",
        createRoleButton = "Skapa roll",
        columnNames = {
          grade = "Nivå",
          label = "Rollnamn",
          salary = "Lön",
          salaryInterval = "Intervall (min)",
          actions = "Åtgärder"
        },
        editMenu = {
          title = "Redigera Roll",
          createTitle = "Skapa roll",
          createSaveButton = "Skapa",
          newRoleBreadcrumb = "Ny roll",
          unnamedRole = "Namnlös roll",
          gradeMeta = "Nivå {grade}",
          backButton = "Gå tillbaka",
          saveButton = "Spara",
          general = "Allmänt",
          permissions = "Behörigheter",
          salary = "Lön",
          salaryDescription = "Ställ in lön för denna roll.",
          salaryInterval = "Utbetalningsintervall",
          salaryIntervalDescription = "Välj hur ofta lönen betalas ut (i arbetsminuter).",
          roleName = "Rollnamn",
          roleNameDescription = "Ange namnet för denna roll.",
          highestRoleInfo = "Detta är den högsta rangen och har automatiskt alla behörigheter."
        },
        unsavedChanges = {
          title = "Osparade ändringar",
          message = "Du har osparade ändringar för denna roll. Vill du lämna och förkasta dem?",
          confirm = "Lämna utan att spara",
          cancel = "Fortsätt redigera"
        },
        permissionsEmpty = "Inga behörigheter hittades.",
        permissionEntries = {
          viewLogs = {
            label = "Visa loggar",
            description = "Tillåter att läsa transaktions- och aktivitetsloggar."
          },
          manageRoles = {
            label = "Hantera roller",
            description = "Tillåter att skapa, redigera, flytta och ta bort rangnivåer."
          },
          manageMembers = {
            label = "Hantera medlemmar",
            description = "Tillåter befordran, degradering, avsked eller bonusbetalningar."
          },
          manageWarehouse = {
            label = "Tillgång till förråd",
            description = "Tillåter interaktion med det delade förrådet."
          },
          manageMoney = {
            label = "Hantera medel",
            description = "Tillåter insättning och uttag av organisationspengar."
          },
          editOutfits = {
            label = "Redigera outfits",
            description = "Tillåter uppdatering av sparade garderobsinlägg."
          },
          createOutfits = {
            label = "Skapa outfits",
            description = "Tillåter skapande av nya garderobsinlägg."
          },
          deleteOutfits = {
            label = "Ta bort outfits",
            description = "Tillåter borttagning av sparade garderobsinlägg."
          },
          purchaseSupplies = {
            label = "Beställ material",
            description = "Tillåter beställning av utrustning från grossist med organisationsmedel."
          },
          purchaseVehicles = {
            label = "Köp fordon",
            description = "Tillåter inköp av nya tjänstefordon med organisationsmedel."
          },
          garageVehicles = {
            label = "Fordonsbegränsningar",
            description = "Välj vilka fordon denna roll INTE kan använda i garaget."
          },
          tabletApps = {
            label = "App-begränsningar",
            description = "Välj vilka appar på surfplattan denna roll inte kan använda."
          },
          all = {
            label = "Full tillgång",
            description = "Beviljar alla behörigheter oavsett andra inställningar."
          }
        },
        permissionOptions = {
          storageHint = "Lägg till föremål som inte kan tas ut av denna roll.",
          storageItemsTitle = "Begränsade föremål",
          storageWeaponsTitle = "Begränsade vapen",
          allowedWeaponsTitle = "Tillåtna vapen",
          weaponHint = "Lägg till vapen som denna roll har tillgång till.",
          vehicleHint = "Välj fordon som denna roll inte har tillgång till.",
          appHint = "Välj appar som denna roll inte har tillgång till.",
          itemPlaceholder = "Skriv för att lägga till föremål",
          weaponPlaceholder = "Skriv för att lägga till vapen",
          weaponSelectPlaceholder = "Välj ett vapen",
          vehiclePlaceholder = "Välj ett fordon",
          appPlaceholder = "Välj en app",
          addButton = "Lägg till",
          emptyVehicles = "Inga fordon tillgängliga.",
          emptyApps = "Inga appar tillgängliga.",
          errors = {
            empty = "Ange ett värde.",
            duplicate = "Alternativet har redan lagts till.",
            itemMissing = "Föremålet existerar inte.",
            vehicleMissing = "Välj ett fordon.",
            appMissing = "Välj en app.",
            weaponMissing = "Vapnet existerar inte.",
            weaponSelectMissing = "Välj ett vapen."
          }
        },
        errors = {
          save = "Misslyckades med att spara roll.",
          saveUnexpected = "Oväntat fel vid sparande av roll.",
          permissionsLoad = "Misslyckades med att hämta behörigheter.",
          permissionsUnexpected = "Oväntat fel vid hämtning av behörigheter."
        }
      },
      logs = {
        sidebarTitle = "Loggar",
        menuTitle = "Loggar",
        errors = {
          load = "Misslyckades med att ladda loggar."
        },
        columnNames = {
          timestamp = "Tidsstämpel",
          name = "Namn",
          action = "Åtgärd",
          content = "Innehåll"
        },
        actions = {
          stored = "Föremål Inlagt",
          removed = "Föremål Uttaget",
          deposited = "Pengar Insatta",
          withdrawn = "Pengar Uttagna",
          outfit_created = "Outfit Skapad",
          outfit_updated = "Outfit Uppdaterad",
          outfit_deleted = "Outfit Borttagen",
          permissions_updated = "Behörigheter Uppdaterade",
          invite_sent = "Inbjudan Skickad",
          invite_accepted = "Inbjudan Accepterad",
          invite_declined = "Inbjudan Avböjd",
          bonus_paid = "Bonus Utbetald",
          member_promoted = "Medlem Befordrad",
          member_demoted = "Medlem Degraderad",
          member_fired = "Medlem Avskedad",
          supplies_purchased = "Material Inköpt",
          vehicle_purchased = "Fordon Inköpt",
          vehicle_sold = "Fordon Sålt",
          salary_paid = "Lön Utbetald"
        }
      },
      dialogs = {
        deleteOutfit = {
          title = "Ta bort Outfit",
          message = "Vill du verkligen ta bort \"{name}\"?",
          confirm = "Ta bort Outfit",
          cancel = "Avbryt"
        }
      }
    },
    cloakroom = {
      title = "Garderob",
      civilianClothes = "Civila kläder",
      newOutfit = "Ny outfit",
      edit = {
        save = "Spara",
        rotateAlt = "Rotera",
        outfitNameTitle = "Outfit-namn",
        saveOutfit = "Spara outfit"
      }
    },
    ----
    tablet = {
      apps = {
        management = "Chefsmeny",
        patients = "Patienter",
        citizens = "Medborgare",
        offences = "Brott",
        cases = "Ärenden",
        social_work = "Socialtjänst",
        vehicles = "Fordon",
        weapons = "Vapen",
        prison = "Fängelse",
        warrants = "Efterlysningar",
        bolos = "Efterlysta fordon",
        conditions = "Villkor",
        reports = "Rapporter",
        camera = "Kamera",
        gallery = "Galleri",
        map = "Karta",
        chat = "Chatt",
        calendar = "Kalender",
        calculator = "Miniräknare",
        settings = "Inställningar"
      }
    },
    common = {
      close = "Stäng",
      unknownError = "Okänt fel.",
      unexpectedError = "Ett oväntat fel uppstod.",
      time = {
        now = "Nu"
      },
      pagination = {
        prev = "Föregående",
        next = "Nästa",
        page = "Sida {current} av {total}"
      },
      gallery = {
        title = "Galleri",
        subtitle = "Välj ett foto eller en video.",
        loading = "Laddar galleri...",
        empty = "Inga objekt tillgängliga i galleriet.",
        photoAlt = "Gallerimedia"
      },
      back = "Tillbaka",
      confirm = {
        unsavedTitle = "Osparade ändringar",
        unsavedMessage = "Vill du kasta ändringarna eller spara dem innan du lämnar?",
        unsavedDiscard = "Kasta ändringar",
        unsavedSave = "Spara ändringar"
      }
    },
    reports = {
      unknown = "Okänd"
    },
    publicForms = {
      complaint = {
        fields = {
          fullName = "Fullständigt namn",
          phone = "Telefonnummer",
          incidentDate = "Händelsedatum",
          incidentTime = "Händelsetid",
          location = "Händelseplats",
          officerName = "Personalens namn",
          badgeNumber = "Tjänstenummer",
          description = "Detaljer om klagomålet",
          witnesses = "Vittnen",
          desiredOutcome = "Önskad lösning",
          email = "E-postadress",
          address = "Hemadress",
          signature = "Signatur"
        },
        title = "Medborgarklagomål",
        subtitle = "Rapportera personalens uppförande eller bekymmer.",
        placeholders = {
          fullName = "Ange ditt fullständiga namn",
          phone = "###-###-####",
          email = "namn@epost.com",
          address = "Gatuadress, stad, postnummer",
          incidentDate = "ÅÅÅÅ-MM-DD",
          incidentTime = "TT:MM",
          location = "Var hände det?",
          officerName = "Personalens namn eller enhet",
          badgeNumber = "Tjänstenummer om känt",
          description = "Beskriv vad som hände i detalj...",
          witnesses = "Lista vittnen eller andra parter",
          desiredOutcome = "Vilket resultat önskar du?",
          signature = "Skriv ditt fullständiga namn"
        }
      },
      application = {
        fields = {
          fullName = "Fullständigt namn",
          dateOfBirth = "Födelsedatum",
          phone = "Telefonnummer",
          experience = "Relevant erfarenhet",
          availability = "Tillgänglighet",
          whyJoin = "Varför vill du gå med?",
          email = "E-postadress",
          address = "Hemadress",
          education = "Utbildning",
          certifications = "Certifieringar",
          references = "Referenser",
          signature = "Signatur"
        },
        title = "Jobbansökan",
        subtitle = "Ansök om att gå med i avdelningen.",
        placeholders = {
          fullName = "Ange ditt fullständiga namn",
          dateOfBirth = "ÅÅÅÅ-MM-DD",
          phone = "###-###-####",
          email = "namn@epost.com",
          address = "Gatuadress, stad, postnummer",
          education = "Gymnasium, akademi eller högskola",
          experience = "Rättsväsende, säkerhet eller serviceyrken",
          certifications = "Första hjälpen, vapenlicens eller liknande",
          availability = "Föredragna skift eller startdatum",
          whyJoin = "Berätta varför du vill arbeta här...",
          references = "Namn och kontaktinformation",
          signature = "Skriv ditt fullständiga namn"
        }
      },
      title = "Offentliga formulär",
      subtitle = "Skicka in ett klagomål eller en jobbansökan.",
      stationLabel = "Station",
      dateLabel = "Datum",
      timeLabel = "Tid",
      stamp = {
        label = "PD",
        complaint = "KLAG",
        application = "ANS"
      },
      tabs = {
        complaint = "Klagomålsformulär",
        application = "Jobbansökan",
        myForms = "Mina inskickade ärenden"
      },
      myForms = {
        title = "Mina inskickade ärenden",
        empty = "Du har inte skickat in några formulär ännu.",
        back = "Tillbaka",
        notesTitle = "Svar",
        notesEmpty = "Inga svar ännu.",
        statusNew = "Väntande",
        statusReviewed = "Granskad",
        statusArchived = "Arkiverad"
      },
      actions = {
        submit = "Skicka in formulär",
        clear = "Rensa fält",
        close = "Stäng"
      },
      status = {
        submitting = "Skickar in...",
        success = "Formuläret skickades framgångsrikt.",
        error = "Kunde inte skicka in formuläret."
      },
      errors = {
        required = "Vänligen fyll i de obligatoriska fälten."
      }
    },
    tabletForms = {
      title = "Inkorg för formulär",
      eyebrow = "Offentliga Formulär",
      listed = "listade",
      filters = {
        label = "Typ",
        all = "Alla formulär",
        complaint = "Klagomål",
        application = "Ansökningar"
      },
      search = {
        placeholder = "Sök på namn, station eller ID"
      },
      status = {
        new = "Ny",
        reviewed = "Granskad",
        archived = "Arkiverad"
      },
      state = {
        empty = "Inga formulär matchar filtren.",
        loading = "Laddar formulär...",
        saving = "Sparar..."
      },
      errors = {
        load = "Kunde inte ladda formulär.",
        update = "Kunde inte uppdatera formulärstatus."
      },
      detail = {
        complaintTitle = "Detaljer om klagomål",
        applicationTitle = "Detaljer om ansökan"
      },
      actions = {
        refresh = "Uppdatera",
        markReviewed = "Markera som granskad",
        archive = "Arkivera",
        back = "Tillbaka till listan"
      },
      notifications = {
        timeNow = "Nu",
        complaintType = "Klagomål",
        applicationType = "Ansökan",
        app = "Formulär",
        title = "Nytt offentligt formulär",
        body = "{type} från {name} ({station})"
      },
      fields = {
        type = "Formulärtyp",
        id = "Formulär ID",
        station = "Station",
        submitted = "Inskickat",
        status = "Status",
        contact = "Kontakt"
      },
      notes = {
        title = "Anteckningar",
        loading = "Laddar anteckningar...",
        empty = "Inga anteckningar ännu.",
        placeholder = "Skriv en anteckning...",
        visibleBadge = "Synlig för medborgare",
        visibleToCitizen = "Synlig för medborgaren",
        submit = "Lägg till anteckning"
      }
    },
    gallery = {
      eyebrow = "Bevisgalleri",
      title = "Kamerarulle",
      filters = {
        all = "Alla",
        camera = "Kamera",
        speedcam = "Fartkameror",
        cctv = "Övervakning",
        mugshot = "Mugshots"
      },
      labels = {
        count = "{count} foton",
        sort = "Nyaste först",
        photoAlt = "Gallerifoto",
        photoFullAlt = "Foto i full storlek",
        takenBy = "Taget av",
        captured = "Fångad",
        unknownTime = "Okänd tid",
        unknownTakenBy = "Okänd"
      },
      state = {
        loading = "Laddar bilder...",
        emptyTitle = "Inga foton ännu.",
        emptySubtitle = "Dina senaste kamerabilder kommer att visas här."
      },
      errors = {
        load = "Kunde inte ladda galleriet.",
        delete = "Kunde inte radera fotot."
      },
      confirm = {
        deleteTitle = "Radera foto",
        deleteMessage = "Vill du radera detta foto? Detta kan inte ångras.",
        deleteConfirm = "Radera",
        deleteCancel = "Avbryt"
      },
      mock = {
        caption = "UTVECKLAR-BILD"
      }
    },
    camera = {
      help = {
        focused = "Tryck Mellanslag för att aktivera rörelse.",
        blurred = "Tryck Mellanslag för att använda surfplattan igen."
      },
      mode = {
        photo = "Foto",
        video = "Video",
        switchPhoto = "Byt till fotoläge",
        switchVideo = "Byt till videoläge"
      },
      capture = {
        photo = "Ta foto"
      },
      queue = {
        title = "Kö",
        empty = "Inga uppladdningar ännu.",
        kind = {
          photo = "Fotouppladdning",
          video = "Videouppladdning"
        },
        status = {
          loading = "Laddar upp...",
          success = "Sparad",
          error = "Misslyckades"
        }
      },
      preview = {
        lastShot = "Senaste bild",
        lastCapture = "Senaste tagning"
      },
      record = {
        start = "Starta inspelning",
        stop = "Stoppa inspelning",
        live = "REC",
        saving = "Sparar video...",
        name = "Kameraklipp",
        description = "Inspelning från surfplatta",
        errors = {
          config = "Uppladdningskonfiguration saknas.",
          upload = "Uppladdning misslyckades.",
          save = "Kunde inte spara video.",
          unsupported = "Inspelning stöds ej.",
          empty = "Ingen video inspelad ännu.",
          busy = "Inspelning pågår.",
          notRecording = "Inspelningen är redan stoppad."
        }
      },
      errors = {
        timeout = "Uppladdningen tog för lång tid.",
        capture = "Oväntat fel vid fotografering.",
        upload = "Uppladdning misslyckades."
      }
    },
    -----
    cctv = {
      eyebrow = "Övervakningsnätverk",
      title = "CCTV",
      listed = "listade",
      actions = {
        refresh = "Uppdatera"
      },
      search = {
        placeholder = "Sök kameror efter namn, ID eller plats"
      },
      filters = {
        all = "Alla kameror",
        bodycam = "Bodycams",
        dashcam = "Dashcams",
        cctv = "CCTV-kameror",
        speedcam = "Fartkameror"
      },
      types = {
        bodycam = "Bodycam",
        dashcam = "Dashcam",
        speedcam = "Fartkamera",
        cctv = "CCTV-kamera"
      },
      status = {
        online = "Online",
        maintenance = "Underhåll",
        offline = "Offline"
      },
      live = {
        active = "Live-feed aktiv",
        maintenance = "Sändning pausad för underhåll",
        offline = "Signal förlorad",
        placeholderTitle = "Sändning otillgänglig",
        placeholderSubtitle = "Välj en personalmedlem med aktiv bodycam.",
        speedcamPlaceholderTitle = "Fartkamera offline",
        speedcamPlaceholderSubtitle = "Reparera eller byt ut enheten för att återställa sändningen."
      },
      labels = {
        speedcamLocation = "Vägkant",
        onDuty = "I tjänst",
        durability = "Hållbarhet"
      },
      state = {
        loading = "Laddar kameror...",
        empty = "Inga kameror matchar de nuvarande filtren.",
        select = "Välj bir kamera för att se sändningen."
      },
      controls = {
        tiltUp = "Vinkla upp",
        panLeft = "Panorera vänster",
        panRight = "Panorera höger",
        tiltDown = "Vinkla ned"
      },
      capture = {
        name = "CCTV - {label}",
        description = "{location} ({id})",
        saved = "Sparad i galleriet.",
        error = "Kunde inte ta bild.",
        action = "Ta bild",
        loading = "Tar bild..."
      },
      record = {
        name = "CCTV-klipp - {label}",
        description = "{location} ({id})",
        save = "Spara senaste {minutes} min",
        saving = "Sparar...",
        requested = "Begäran om att spara skickad.",
        saved = "Video sparad i galleriet.",
        errors = {
          config = "Uppladdningskonfiguration saknas.",
          upload = "Uppladdning misslyckades.",
          save = "Kunde inte spara video.",
          unsupported = "Inspelning stöds ej.",
          empty = "Ingen buffert tillgänglig ännu.",
          request = "Kunde inte begära bodycam-video.",
          timeout = "Begäran om att spara bodycam tog för lång tid.",
          busy = "Inspelning pågår.",
          notRecording = "Inspelningen är redan stoppad."
        }
      },
      waypoint = {
        set = "Vägpunkt satt.",
        missing = "Ingen plats tillgänglig."
      },
      errors = {
        load = "Kunde inte ladda kameror."
      }
    },
    chat = {
      targets = {
        allUnits = "Chatt för alla enheter",
        centralDispatch = "Centralledning"
      },
      header = {
        eyebrowRoom = "Personalkanal",
        eyebrowPrivate = "Privat linje",
        metaRoom = "Rum",
        metaDirect = "Direkt",
        metaStaff = "Personal"
      },
      sidebar = {
        eyebrow = "Kommunikation",
        title = "Personalnätverk",
        groupTitle = "Gruppchatt",
        allUnits = "Alla enheter",
        staffTitle = "Personal",
        loading = "Laddar personal...",
        empty = "Ingen personal tillgänglig."
      },
      staff = {
        unknownMember = "Okänd personalmedlem",
        onDuty = "I tjänst",
        offDuty = "Ej i tjänst",
        grade = "Nivå {level}",
        fallback = "Personal"
      },
      composer = {
        placeholderRoom = "Skriv en enhetsuppdatering...",
        placeholderDirect = "Skicka meddelande till {name}...",
        pendingAlt = "Väntar på delning"
      },
      messages = {
        avatarAlt = "Avatar för {name}",
        avatarFallback = "Personalavatar",
        unknownAuthor = "Okänd",
        sharedEvidenceAlt = "Delat bevis",
        tapToExpand = "Tryck för att förstora"
      },
      preview = {
        ready = "Media redo att skickas"
      },
      profile = {
        action = "Ställ in profilbild",
        galleryTitle = "Välj profilbild",
        gallerySubtitle = "Välj ett foto för din avatar.",
        photoAlt = "Profilbild",
        selfPhotoAlt = "Profilbild",
        error = "Kunde inte uppdatera profilbild."
      },
      actions = {
        remove = "Ta bort",
        send = "Skicka"
      },
      state = {
        syncing = "Synkroniserar meddelanden...",
        emptyRoom = "Ingen aktivitet ännu.",
        emptyPrivate = "Inga privata meddelanden ännu.",
        emptyRoomHint = "Var den första att checka in med enheten.",
        emptyPrivateHint = "Starta en direktlinje med denna personalmedlem."
      },
      errors = {
        load = "Kunde ikke ladda chatthistorik.",
        send = "Kunde inte skicka meddelande.",
        members = "Kunde inte ladda personal."
      }
    },
    bossMenu = {
      header = {
        eyebrow = "Chefskontroll",
        title = "Hantering",
        balanceLabel = "Saldo"
      },
      state = {
        loading = "Laddar hanteringsdata..."
      }
    },
    tabletSettings = {
      header = {
        eyebrow = "Tablettinställningar",
        title = "Personalisering",
        modeLabel = "Läge",
        modeLight = "Ljust",
        modeDark = "Mörkt"
      },
      appearance = {
        title = "Utseende",
        description = "Växla gränssnittet mellan ljust och mörkt läge.",
        light = "Ljust",
        dark = "Mörkt"
      },
      wallpaper = {
        title = "Bakgrundsbild",
        description = "Använd standardbakgrunden, välj från galleriet eller lägg till en egen länk.",
        labels = {
          default = "Standardbakgrund",
          gallery = "Galleri-foto",
          url = "Anpassad URL"
        },
        useDefault = "Använd standard",
        chooseGallery = "Välj från galleri",
        customUrlLabel = "Anpassad bild-URL",
        customUrlPlaceholder = "https://exempel.se/bild.jpg",
        apply = "Verkställ",
        hint = "Bäst resultat med bilder i 1920x1080 eller högre."
      }
    },
    calendar = {
      weekdays = {
        mon = "Mån",
        tue = "Tis",
        wed = "Ons",
        thu = "Tor",
        fri = "Fre",
        sat = "Lör",
        sun = "Sön"
      },
      selectedDateFallback = "Välj ett datum",
      header = {
        eyebrow = "Delad kalender",
        title = "Personalschema",
        metaPrimary = "Synlig för all personal",
        metaSecondary = "Alla kan lägga till inlägg",
        hint = "Tryck på en dag för att lägga till ett pass eller event"
      },
      actions = {
        dayEntries = "Dagens händelser",
        addEntry = "Lägg till händelse"
      },
      today = "Idag",
      more = "+{count} till",
      modal = {
        addEntry = {
          eyebrow = "Lägg till händelse",
          titleLabel = "Titel",
          titlePlaceholder = "Genomgång, träning, patrull",
          datetimeLabel = "Datum & tid",
          colorLabel = "Färg",
          clear = "Rensa",
          submit = "Lägg till i kalendern"
        },
        dayEntries = {
          eyebrow = "Dagens händelser",
          empty = "Inga händelser ännu. Lägg till en genomgång eller patrull för att dela med enheten."
        }
      }
    },
    calculator = {
      header = {
        eyebrow = "Fältverktyg",
        title = "Miniräknare",
        modeLabel = "Läge"
      },
      keys = {
        clearAll = "AC",
        clearEntry = "CE"
      },
      mode = {
        standard = "Standard"
      },
      status = {
        resetRequired = "Återställning krävs",
        ready = "Redo"
      },
      errors = {
        error = "Fel"
      }
    },
    tabletHome = {
      status = {
        defaultDate = "Måndag, 1 jan"
      },
      calendar = {
        eventToday = "Händelse idag",
        eventTomorrow = "Händelse imorgon",
        allDay = "Hela dagen",
        timeAt = " kl. {time}"
      },
      chat = {
        messageFrom = "Meddelande från {name}",
        newMessage = "Nytt meddelande",
        authorFallback = "Personal",
        messageBody = "{author}: {message}",
        sentPhoto = "{author} skickade ett foto.",
        sentMessage = "{author} skickade ett meddelande."
      },
      notifications = {
        title = "Notiser",
        clearAll = "Rensa alla",
        empty = "Du är helt uppdaterad."
      }
    },
    map = {
      eyebrow = "Kartcentral",
      title = "San Andreas-rutnät",
      markerLabel = "Markör",
      markerTypes = {
        label = "Markörlista",
        dispatch = "Larm",
        officers = "Personal",
        speedcams = "Fartkameror",
        vehicles = "Fordon",
        trackers = "Trackers"
      },
      markerList = {
        listed = "listade",
        officersTitle = "Personallista",
        speedcamsTitle = "Fartkameror",
        vehiclesTitle = "Fordonslista",
        trackersTitle = "Trackerlista",
        officersEmpty = "Ingen personal i tjänst.",
        speedcamsEmpty = "Inga fartkameror tillgängliga.",
        trackersEmpty = "Inga trackers online.",
        vehiclesEmpty = "Inga fordon online."
      },
      dispatch = {
        title = "Larmcentral",
        empty = "Inga aktiva larm just nu.",
        status = {
          active = "Aktiv",
          accepted = "Accepterad",
          done = "Klar"
        },
        panelTitle = "Larmdetaljer",
        statusLabel = "Status",
        acceptedBy = "Accepterad av",
        doneBy = "Slutförd av",
        coords = "Koordinater",
        actions = {
          accept = "Acceptera",
          done = "Markera som klar",
          delete = "Radera"
        },
        unknown = "Okänd"
      },
      status = {
        available = "Tillgänglig",
        busy = "Upptagen",
        pursuit = "I förföljande",
        offDuty = "Ej i tjänst"
      },
      vehicle = {
        status = {
          active = "Aktiv",
          offline = "Offline"
        }
      },
      tracker = {
        status = {
          active = "Aktiv",
          offline = "Offline"
        }
      },
      speedcam = {
        status = {
          online = "Online",
          maintenance = "Underhåll",
          offline = "Offline"
        }
      },
      officerPanel = {
        title = "Personaluppgifter",
        callsign = "Anropsnummer {id}",
        rank = "Rang",
        health = "Hälsa",
        coords = "Koordinater",
        lastUpdateUnknown = "Just nu"
      },
      speedcamPanel = {
        title = "Fartkamerauppgifter",
        limit = "Gräns",
        tolerance = "Tolerans",
        health = "Hälsa",
        coords = "Koordinater"
      },
      vehiclePanel = {
        title = "Fordonsuppgifter",
        plate = "Registreringsnummer {plate}",
        netId = "Nät-ID",
        health = "Hälsa",
        coords = "Koordinater"
      },
      trackerPanel = {
        title = "Tracker-detaljer",
        plate = "Registreringsnummer {plate}",
        attachedBy = "Fäst av",
        attachedAt = "Fäst den",
        netId = "Nät-ID",
        status = "Status",
        coords = "Koordinater"
      },
      actions = {
        openCctv = "Öppna CCTV",
        setWaypoint = "Sätt vägpunkt"
      },
      waypoint = {
        set = "Vägpunkt satt.",
        missing = "Ingen plats tillgänglig."
      },
      styles = {
        atlas = "Atlas",
        roads = "Vägar",
        satellite = "Satellit"
      },
      missing = {
        title = "Kartbild saknas",
        body = "Placera kartbilderna i frontend/public/img."
      },
      signalLost = "Signal förlorad",
      details = {
        title = "Detaljer",
        empty = "Välj en markör för att se detaljer."
      },
      zones = {
        title = "Exkluderingszoner",
        untitled = "Namnlös zon",
        hint = "Klicka på kartan för att lägga till punkter. Minst 3.",
        pointCount = "{count} punkter",
        empty = "Inga exkluderingszoner ännu.",
        actions = {
          toggle = "Zoner",
          new = "Ny zon",
          cancel = "Avbryt",
          save = "Spara zon",
          undo = "Ångra",
          clear = "Rensa",
          delete = "Radera"
        },
        modal = {
          title = "Namnge exkluderingszon",
          confirm = "Spara zon"
        },
        errors = {
          points = "Lägg till minst 3 punkter.",
          nameRequired = "Ange ett namn på zonen.",
          saveFailed = "Kunde inte spara exkluderingszonen.",
          deleteFailed = "Kunde inte radera exkluderingszonen."
        }
      },
      monitorZones = {
        title = "Fotbojezoner",
        untitled = "Namnlös zon",
        hint = "Klicka på kartan för att lägga till punkter. Minst 3.",
        pointCount = "{count} punkter",
        empty = "Inga fotbojezoner ännu.",
        mode = {
          allow = "Tillåten zon",
          exclude = "Begränsad zon"
        },
        actions = {
          allow = "Tillåten zon",
          exclude = "Begränsad zon",
          cancel = "Avbryt",
          save = "Spara zon",
          undo = "Ångra",
          clear = "Rensa",
          delete = "Radera"
        },
        modal = {
          title = "Namnge fotbojezon",
          confirm = "Spara zon"
        },
        errors = {
          points = "Lägg till minst 3 punkter.",
          nameRequired = "Ange ett namn på zonen.",
          noMonitor = "Välj en fotboja.",
          saveFailed = "Kunde inte spara fotbojezonen.",
          deleteFailed = "Kunde inte radera fotbojezonen."
        }
      },
      panic = {
        panelTitle = "Panikdetaljer",
        triggeredBy = "Utlöst av",
        createdAt = "Utlöst den",
        coords = "Koordinater"
      },
      dev = {
        officerName = "Personal Avery Lane",
        callsign = "LIN-23",
        rank = "Sergeant",
        unit = "Central Patrol",
        speedcamName = "Del Perro Fartkamera",
        vehicleName = "Enhet 12",
        trackerName = "Tracker ALPHA",
        trackerOfficer = "Personal Ruiz",
        dispatchTitle = "Fartkamera skadad",
        dispatchMessage = "Enheten i Del Perro behöver underhåll.",
        panicOfficer = "Personal Sinclair",
        panicLocation = "Mission Row"
      }
    },
    ----
    panicNotification = {
      badge = "Panik",
      title = "Paniklarm",
      subtitle = "{name} tryckte på panikknappen.",
      callsign = "Anropsnummer {id}",
      locationLabel = "Plats",
      locationUnknown = "Okänd plats",
      hint = "Tryck på {key} för att sätta en vägpunkt på kartan."
    },
    incidentNotification = {
      panic = {
        title = "Paniklarm",
        subtitle = "{name} tryckte på panikknappen."
      },
      dispatch = {
        title = "Larmnotis",
        subtitle = "{name} delade ett nytt larm."
      },
      ping = {
        title = "Platsping",
        subtitle = "{name} delade en live-position."
      },
      actions = {
        openMap = {
          key = "M",
          label = "Visa i surfplattans karta"
        },
        setWaypoint = {
          key = "G",
          label = "Sätt vägpunkt"
        },
        dismiss = {
          key = "Backspace",
          label = "Avfärda"
        }
      }
    },
    employeeGpsJammer = {
      title = "GPS-störare",
      disabled = "GPS-störning är inte tillgänglig.",
      success = "Anställds GPS-signal störd.",
      failed = "Kunde inte störa GPS-signalen.",
      targetJammed = "Din tjänste-GPS-signal störs.",
      errors = {
        disabled = "GPS-störning är inte tillgänglig.",
        no_players = "Ingen person i närheten.",
        too_far = "Gå närmare innan du använder GPS-störaren.",
        invalid_target = "Kunde inte hitta den personen.",
        not_on_duty = "Ingen aktiv tjänste-GPS-signal hittades på den personen.",
        protected_job = "Den anställdes GPS-signal är skyddad.",
        missing_item = "Du behöver en GPS-störare för att göra detta.",
        cooldown = "Vänta ett ögonblick innan du använder GPS-störaren igen.",
        failed = "Kunde inte störa GPS-signalen.",
      },
    },
    gradeChange = {
      promotedTitle = "Befordran",
      demotedTitle = "Degradering",
      unchangedTitle = "Rang uppdaterad",
      previousLabel = "Tidigare rang",
      newLabel = "Nuvarande rang",
      unknownLabel = "Ej tilldelad rang",
      levelFallback = "Nivå {level}"
    },
    bonusNotification = {
      title = "Bonus utbetald",
      subtitle = "Från {name}",
      amountLabel = "Bonus",
      unknownManager = "Ledningen"
    },
    wheelClamp = {
      attached = "En hjulboja är monterad"
    },
    search = {
      previewTitle = "Visiterar {name}",
      previewSubtitle = "Letar efter vapen och kontraband...",
      previewCancel = "Tryck på X för att avbryta",
      unknownTarget = "Okänd"
    },
    heliCamHud = {
      title = "Kontroller för helikopterkamera",
      actions = {
        toggleCam = "Växla kamera",
        vision = "Växla mörkerseende",
        spotlight = "Strålkastarläge",
        lockTarget = "Lås mål",
        display = "Växla display",
        takePhoto = "Ta foto",
        rappel = "Firning",
        brightness = "Ljusstyrka",
        radius = "Radie"
      }
    },
    jailHud = {
      title = "Återstående tid",
      trashLabel = "Sopor",
      trashFull = "Säcken är full",
      trashDropoff = "Lämna vid soptunnan"
    },
    jailJobs = {
      title = "Arbetsuppgifter i fängelset",
      subtitle = "Välj en uppgift för att få tiden att gå.",
      actions = {
        cleaning = "Städning",
        gardening = "Trädgårdsarbete",
        carry_goods = "Bära gods"
      },
      currentJob = "Nuvarande arbete:",
      stop = "Avbryt arbete",
      close = "Stäng",
      contraband = {
        title = "Kontraband",
        message = "Du hittade {item}. Tar du risken och behåller det, eller kastar du det?",
        keep = "Behåll",
        toss = "Kasta"
      },
      boxInspect = {
        title = "Inspektera låda",
        message = "Inuti hittar du {item}. {beskrivning}",
        take = "Ta det",
        leave = "Lämna det",
        close = "Stäng"
      }
    },
    socialWork = {
      eyebrow = "Samhällstjänst",
      title = "Socialt arbete",
      listed = "listade",
      search = {
        placeholder = "Sök på namn eller ID"
      },
      filters = {
        all = "Alla",
        label = "Status",
        placeholder = "Status"
      },
      actions = {
        refresh = "Uppdatera",
        back = "Tillbaka till listan"
      },
      state = {
        loading = "Laddar samhällstjänst...",
        empty = "Ingen samhällstjänst matchar filtren."
      },
      status = {
        active = "Aktiv",
        overdue = "Försenad",
        completed = "Slutförd",
        imprisoned = "Fängslad"
      },
      labels = {
        remainingShort = "kvar",
        imprison = "Fängsla",
        imprisonNotice = "Tidsgränsen har passerats. Fängslande krävs.",
        noDeadline = "Ingen tidsgräns",
        expired = "Utgått"
      },
      sections = {
        summary = "Sammanfattning av tjänst",
        summarySubtitle = "Översikt över tilldelade uppgifter."
      },
      fields = {
        name = "Namn",
        status = "Status",
        remaining = "Återstående uppgifter",
        completed = "Slutförda uppgifter",
        total = "Totalt antal uppgifter",
        assigned = "Tilldelad",
        deadline = "Tidsgräns",
        timeLeft = "Tid kvar",
        assignedBy = "Tilldelad av",
        unknown = "Okänd"
      },
      assign = {
        title = "Tilldela samhällstjänst",
        subtitle = "Skicka en närliggande spelare till samhällstjänst.",
        playerLabel = "Spelare",
        playerPlaceholder = "Välj spelare",
        taskLabel = "Uppgifter",
        taskPlaceholder = "Antal uppgifter",
        deadlineLabel = "Tidsgräns (minuter)",
        deadlinePlaceholder = "Valfritt",
        submit = "Tilldela",
        success = "Samhällstjänst har tilldelats.",
        error = "Kunde inte tilldela samhällstjänst."
      },
      errors = {
        load = "Kunde inte ladda samhällstjänst."
      },
      date = {
        unknown = "Okänd"
      },
      jobs = {
        title = "Samhällstjänst",
        subtitle = "Välj en uppgift för att avtjäna ditt straff.",
        currentJob = "Nuvarande uppgift:",
        stop = "Avbryt uppgift",
        actions = {
          cleaning = "Städning",
          carry_goods = "Bära gods"
        }
      },
      hud = {
        title = "Samhällstjänst",
        remaining = "Uppgifter kvar",
        completed = "Uppgifter slutförda",
        deadline = "Tid kvar",
        expired = "Utgått",
        trashLabel = "Sopor",
        trashFull = "Säcken är full",
        trashDropoff = "Lämna vid soptunnan"
      }
    },
    socialWorkCreator = {
      title = "Skapare för samhällstjänst",
      description = "Konfigurera platser för samhällstjänst runt om i staden.",
      empty = "Inga platser för samhällstjänst konfigurerade ännu.",
      keyboardHint = "Använd piltangenterna för att navigera.",
      editTitle = "Markörer för samhällstjänst",
      editSubtitle = "Använd kartnålen för att spara dina koordinater.",
      editKeyboardHint = "Piltangenter för markör, Vänster/Höger för Sätt/Rensa, Enter för att utföra, Backspace för tillbaka.",
      missingEntry = "Platsen för samhällstjänst hittades inte.",
      actions = {
        newSite = "Ny plats"
      },
      status = {
        set = "Satt",
        unset = "Ej satt"
      },
      markers = {
        social_work_job_npc = "Jobb-NPC",
        social_work_dumpster = "Soptunna",
        social_work_box_dropoff = "Inlämning av gods"
      },
      modals = {
        createTitle = "Skapa plats",
        createButton = "Skapa plats",
        renameTitle = "Byt namn på plats",
        renameButton = "Spara namn",
        deleteTitle = "Ta bort plats",
        deleteMessage = "Vill du verkligen ta bort {name}?",
        deleteConfirmLabel = "Ta bort",
        deleteCancelLabel = "Avbryt"
      }
    },
    impoundCreator = {
      title = "Yediemin-skapare",
      description = "Konfigurera platser och spawn-punkter för yediemin-upplag.",
      empty = "Inga upplag konfigurerade ännu.",
      keyboardHint = "Använd piltangenterna för att navigera.",
      editTitle = "Yediemin-markörer",
      editSubtitle = "Använd kartnålen för att spara dina koordinater.",
      editKeyboardHint = "Piltangenter för markör, Vänster/Höger för Sätt/Rensa/Ta bort, Enter för att utföra, Backspace för tillbaka.",
      missingEntry = "Upplaget hittades inte.",
      actions = {
        newLot = "Nytt upplag",
        add = {
          impound_delivery = "Lägg till inlämning",
          impound_spawn = "Lägg till spawn"
        }
      },
      status = {
        set = "Satt",
        unset = "Ej satt"
      },
      markers = {
        impound_lot = "Yediemin-upplag",
        impound_spawn = "Yediemin-spawn",
        impound_delivery = "Yediemin-inlämning"
      },
      modals = {
        createTitle = "Skapa upplag",
        createButton = "Skapa upplag",
        renameTitle = "Byt namn på upplag",
        renameButton = "Spara namn",
        deleteTitle = "Ta bort upplag",
        deleteMessage = "Vill du verkligen ta bort {name}?",
        deleteConfirmLabel = "Ta bort",
        deleteCancelLabel = "Avbryt"
      }
    },
    impoundStorage = {
      title = "Yediemin-förråd",
      subtitle = "Beställ leverans av lagrade fordon till upplaget.",
      empty = "Inga lagrade fordon för detta upplag.",
      emptyAll = "Inga beslagtagna fordon hittades.",
      unknownModel = "Okänd",
      unknownLot = "Okänd",
      sections = {
        impounds = "Aktiva beslag",
        stored = "Lagrade fordon"
      },
      columns = {
        plate = "Reg.nummer",
        model = "Modell",
        stored = "Lagrad",
        lot = "Upplag",
        status = "Status",
        fee = "Lagringsavgift"
      },
      actions = {
        deliver = "Beställ leverans",
        allowPickup = "Tillåt upphämtning",
        seize = "Markera som beslagtagen",
        seized = "Beslagtagen",
        close = "Stäng",
        refresh = "Uppdatera"
      },
      status = {
        pickup = "Upphämtning tillåten",
        seized = "Beslagtagen"
      },
      time = {
        days = "{count} dag(ar)"
      },
      errors = {
        load = "Kunde inte ladda lagrade fordon.",
        deliver = "Kunde inte beställa leverans.",
        seized = "Detta fordon är beslagtaget för utredning.",
        update = "Kunde inte uppdatera yediemin-status."
      }
    },
    impoundDecision = {
      title = "Yediemin-beslut",
      message = "Avgör om {vehicle} kan hämtas ut eller ska beslagtas för utredning.",
      vehicleFallback = "detta fordon",
      allowPickup = "Tillåt upphämtning",
      seize = "Beslagta för utredning"
    },
    jailCreator = {
      title = "Hapishane-skapare",
      description = "Placera spawn-punkter för fängelset och hantera platser.",
      empty = "Inga fängelser konfigurerade ännu.",
      keyboardHint = "Använd piltangenterna för att navigera.",
      editTitle = "Fängelsemarkörer",
      editSubtitle = "Använd kartnålen för att spara dina koordinater.",
      editKeyboardHint = "Piltangenter för markör, Vänster/Höger för Sätt/Rensa/Ta bort, Enter för att utföra, Backspace för tillbaka.",
      missingEntry = "Fängelset hittades inte.",
      actions = {
        newJail = "Nytt fängelse"
      },
      modals = {
        createTitle = "Skapa fängelse",
        createButton = "Skapa fängelse",
        renameTitle = "Byt namn på fängelse",
        renameButton = "Spara namn",
        deleteTitle = "Ta bort fängelse",
        deleteMessage = "Vill du verkligen ta bort {name}?",
        deleteConfirmLabel = "Ta bort",
        deleteCancelLabel = "Avbryt"
      }
    },
    --
    jailInmates = {
      title = "Fångutbyte",
      close = "Stäng",
      trade = "Genomför byte",
      requiredLabel = "Du ger",
      rewardLabel = "Du får",
      acceptedLabel = "Accepterar",
      contrabandLabel = "Kontraband",
      npc = {
        alcoholic = "Cellblocks-fyllot",
        drugDealer = "Tvättrums-langaren",
        doctor = "Fängelseläkare",
        canteen = "Matsalskock"
      },
      dialogs = {
        alcoholic = {
          one = "Jag bytte min efterrätt mot en mopp en gång. Bästa dagen i mitt liv.",
          two = "Om det här stället hade en bar skulle jag vara månadens anställd.",
          three = "Har du något som luktar nystädade golv och dåliga beslut?",
          four = "Jag kallar det fängelse-parfym. Du kallar det rengöringssprit."
        },
        drugDealer = {
          one = "Har du hittat något skoj i soporna? Jag betalar i cigg.",
          two = "Sänk rösten, vakterna tror att jag driver en bokklubb.",
          three = "Ge mig kontraband så ska jag göra din dag rökbar.",
          four = "Soporna döljer skatter. Jag är skattmasen."
        },
        doctor = {
          one = "Sitt still. Det här går snabbt.",
          two = "Ingen avgift idag. Håll dig bara borta från trubbel.",
          three = "Du ser hängig ut. Låt mig lappa ihop dig.",
          four = "Klinikens öppettider tar aldrig slut här inne."
        },
        canteen = {
          one = "Färska brickor idag. Ställ upp på led och rör på er.",
          two = "Vill du ha en varm måltid eller en föreläsning?",
          three = "Gott uppförande ger påfyllning. Oftast.",
          four = "Jag har sett värre aptit än din."
        }
      },
      doctor = {
        costLabel = "Kostnad",
        rewardLabel = "Behandling",
        actionLabel = "Få behandling",
        costValue = "Gratis",
        rewardValue = "Fullständig behandling"
      },
      canteen = {
        costLabel = "Kostnad",
        rewardLabel = "Måltid",
        actionLabel = "Hämta måltid",
        costValue = "Gratis",
        rewardValue = "Matpaket"
      },
      items = {
        cleaning_alcohol = "Rengöringssprit",
        cigarettes = "Cigaretter",
        coke = "Kola",
        weed = "Gräs",
        burger = "Burgare",
        water = "Vatten"
      }
    },
    invites = {
      title = "Jobbinbjudan",
      description = "Gå med i {job} som {role}?",
      invitedBy = "Inbjuden av {name}",
      expires = "Detta erbjudande löper ut snart.",
      accept = "Acceptera",
      decline = "Neka",
      errors = {
        missing = "Inbjudan är inte tillgänglig.",
        failed = "Misslyckades med att svara på inbjudan."
      }
    },
    stationCreator = {
      title = "Stationsskapare",
      description = "Konfigurera positioner för stationsmarkörer.",
      empty = "Inga stationer konfigurerade ännu.",
      keyboardHint = "Använd ↑/↓ för val, ←/→ för åtgärder, Enter för att bekräfta, Backspace stänger.",
      editTitle = "Stationsmarkörer",
      editSubtitle = "Använd kartnålen för att spara dina nuvarande koordinater.",
      editKeyboardHint = "↑/↓ för markör, ←/→ för Sätt/Rensa/Ta bort, Enter för att köra, Backspace för tillbaka.",
      sections = {
        markers = "Markörer",
        zone = "Fängelseområde"
      },
      zone = {
        subtitle = "Lägg till zoner för att definiera fängelsets gränser.",
        hint = "Använd kartnålen för att lägga till punkter. Ta bort punkter med soptunnan.",
        empty = "Inga zonpunkter ännu.",
        pointLabel = "Zonpunkt {index}",
        actions = {
          add = "Lägg till zonpunkt",
          update = "Uppdatera",
          clear = "Rensa zon"
        }
      },
      missingStation = "Stationen hittades inte.",
      actions = {
        editJobBlip = "Redigera jobb-blip",
        newStation = "Ny station",
        newJail = "Nytt fängelse",
        add = {
          wardrobe = "Lägg till garderob",
          garage_vehicle_menu = "Lägg till fordonsgarage",
          garage_vehicle_spawn = "Lägg till fordonsspawn",
          garage_vehicle_park = "Lägg till parkering",
          garage_helicopter_menu = "Lägg till helikopterplatta",
          garage_helicopter_spawn = "Lägg till helikopterspawn",
          garage_helicopter_park = "Lägg till helikopterparkering",
          garage_boat_menu = "Lägg till hamninteraktion",
          garage_boat_spawn = "Lägg till båtspawn",
          garage_boat_park = "Lägg till båtparkering",
          boss_menu = "Lägg till chefsmeny",
          wholesale_shop = "Lägg till grossistbutik",
          duty_terminal = "Lägg till tjänsteterminal",
          public_forms = "Lägg till kiosk för formulär",
          jail_solitary_cell = "Lägg till isoleringscell"
        }
      },
      status = {
        set = "Satt",
        unset = "Ej satt"
      },
      markers = {
        position = "Stationsposition",
        storage = "Förråd",
        locker = "Skåp",
        wardrobe = "Garderob",
        duty_terminal = "Tjänsteterminal",
        public_forms = "Kiosk för formulär",
        boss_menu = "Chefsmeny",
        garage_vehicle_menu = "Fordonsgarage",
        garage_vehicle_spawn = "Fordonsspawn",
        garage_vehicle_park = "Fordonsparkering",
        garage_helicopter_menu = "Helikopterplatta",
        garage_helicopter_spawn = "Helikopterspawn",
        garage_helicopter_park = "Helikopterparkering",
        garage_boat_menu = "Hamninteraktion",
        garage_boat_spawn = "Båtspawn",
        garage_boat_park = "Båtparkering",
        wholesale_shop = "Grossistbutik",
        jail_spawn = "Fängelse-spawn",
        jail_release = "Frisläppningspunkt",
        jail_menu = "Fängelseterminal",
        jail_job_npc = "Fängelsejobb-NPC",
        jail_inmate_alcoholic = "Fånge: Alkoholist",
        jail_inmate_drugdealer = "Fånge: Langare",
        jail_inmate_doctor = "Fånge: Läkare",
        jail_canteen_cook = "Matsalskock",
        jail_dumpster = "Fängelse-container",
        jail_box_dropoff = "Inlämningspunkt",
        jail_electric_box = "Elskåp",
        jail_fence_cut = "Hål i stängsel",
        jail_fence_exit = "Stängselutgång",
        jail_solitary_cell = "Isoleringscell",
        jail_confiscated_return = "Beslagtagna föremål",
      },
      modals = {
        createTitle = "Skapa station",
        createButton = "Skapa station",
        renameTitle = "Byt namn på station",
        renameButton = "Spara namn",
        deleteTitle = "Ta bort station",
        deleteMessage = "Vill du verkligen ta bort {name}?",
        deleteConfirmLabel = "Ta bort",
        deleteCancelLabel = "Avbryt",
        jobBlipTitle = "Jobb-blip: {job}",
        jobBlipMessage = "Konfigurera stationsblip för det här specifika jobbet. Inaktivera om jobbet inte ska ha någon stationsblip.",
        jobBlipSave = "Spara blip",
        jobBlipReset = "Återställ",
        jobBlipInvalidNumber = "Ogiltigt värde för {field}."
      },
      blip = {
        enabled = "Visa blip",
        useStationName = "Lägg till stationsnamn",
        shortRange = "Kort räckvidd",
        name = "Etikett",
        sprite = "Sprite",
        color = "Färg",
        scale = "Skala",
        display = "Visning"
      }
    },
    jailAssign = {
      title = "Skicka till fängelse",
      selectPlayer = "Välj spelare",
      selectPlayerPlaceholder = "Välj spelare",
      selectJail = "Välj fängelse",
      selectJailPlaceholder = "Välj fängelseplats",
      solitaryLabel = "Isoleringscell",
      solitaryUnavailable = "Inga isoleringsceller konfigurerade för detta fängelse.",
      durationLabel = "Varaktighet (månader)",
      monthHint = "1 månad = {minutes} minuter",
      cancelButton = "Avbryt",
      assignButton = "Skicka till fängelse",
      assigning = "Skickar till fängelse...",
      noPlayers = "Inga spelare i närheten inom {range} m.",
      noJails = "Inga fängelser konfigurerade. Använd fängelseskaparen först.",
      spawnMissing = "Detta fängelse har ingen spawn-punkt.",
      jailStatusReady = "Spawn redo",
      jailStatusMissing = "Ingen spawn satt",
      success = "Spelare skickad till fängelse i {months} månader.",
      errors = {
        invalid_target = "Välj en spelare i närheten och ett fängelse.",
        spawn_not_set = "Detta fängelse har ingen spawn-punkt.",
        solitary_unavailable = "Inga isoleringsceller konfigurerade för detta fängelse.",
        failed = "Misslyckades med att skicka spelare till fängelse."
      }
    },
    bolos = {
      eyebrow = "BOLO-tavla",
      title = "Efterlysningar (BOLO)",
      listed = "listade",
      unknown = "Okänd",
      search = {
        placeholder = "Sök efterlysningar på titel, ID, typ eller tagg"
      },
      actions = {
        refresh = "Uppdatera",
        manageTypes = "Hantera typer",
        new = "Ny efterlysning",
        back = "Tillbaka till listan",
        add = "Lägg till",
        addPhoto = "Lägg till foto",
        remove = "Ta bort"
      },
      state = {
        loading = "Laddar efterlysningar...",
        empty = "Inga efterlysningar matchar filtren.",
        saving = "Sparar...",
        noTags = "Inga taggar tilldelade.",
        noReports = "Inga länkade rapporter ännu."
      },
      detail = {
        summary = "BOLO-sammanfattning",
        untitled = "Namnlös efterlysning"
      },
      fields = {
        title = "BOLO-titel",
        id = "BOLO ID",
        type = "Typ",
        status = "Status",
        priority = "Prioritet",
        created = "Skapad",
        updated = "Senaste uppdatering"
      },
      placeholders = {
        title = "Titel på efterlysning",
        id = "Genereras automatiskt om tomt",
        type = "Välj typ",
        description = "Lägg till en beskrivning...",
        tag = "Lägg till tagg",
        reportSelect = "Välj en rapport"
      },
      sections = {
        description = "Beskrivning",
        descriptionSubtitle = "Detaljer och instruktioner.",
        tags = "Taggar",
        tagsSubtitle = "Snabbidentifiering för efterlysningen.",
        reports = "Länkade rapporter",
        reportsSubtitle = "Bifoga relaterade rapportfiler.",
        gallery = "Galleri",
        gallerySubtitle = "Bifoga galleribilder till efterlysningen."
      },
      gallery = {
        title = "Välj ett foto",
        subtitle = "Välj en galleribild att bifoga till efterlysningen.",
        loading = "Laddar galleri...",
        empty = "Inga galleribilder tillgängliga.",
        photoAlt = "Gallerifoto"
      },
      typesModal = {
        title = "BOLO-typer",
        subtitle = "Lägg till eller ta bort BOLO-typer för denna enhet.",
        placeholder = "Lägg till BOLO-typ",
        empty = "Inga BOLO-typer konfigurerade."
      },
      types = {
        person = "Person",
        vehicle = "Fordon",
        property = "Egendom",
        missing = "Saknad person",
        other = "Övrigt"
      },
      status = {
        active = "Aktiv",
        located = "Hittad",
        closed = "Stängd",
        cancelled = "Avbruten"
      },
      priority = {
        low = "Låg",
        medium = "Medium",
        high = "Hög",
        critical = "Kritisk"
      },
      errors = {
        load = "Kunde inte ladda efterlysningar.",
        save = "Kunde inte spara efterlysning.",
        titleRequired = "Ange en titel innan du sparar.",
        typeRequired = "Välj en typ innan du sparar.",
        gallery = "Kunde inte ladda galleri."
      }
    },
    warrants = {
      eyebrow = "Orderarkiv",
      title = "Husrannskan & Arrest",
      listed = "listade",
      unknown = "Okänd",
      search = {
        placeholder = "Sök på titel, ID, typ eller tagg"
      },
      actions = {
        refresh = "Uppdatera",
        manageTypes = "Hantera typer",
        new = "Ny order",
        back = "Tillbaka till listan",
        add = "Lägg till",
        addPhoto = "Lägg till foto",
        remove = "Ta bort"
      },
      state = {
        loading = "Laddar ordrar...",
        empty = "Inga ordrar matchar filtren.",
        saving = "Sparar...",
        noTags = "Inga taggar tilldelade.",
        noReports = "Inga länkade rapporter ännu.",
        noOffences = "Inga länkade brott ännu."
      },
      detail = {
        summary = "Ordersammanfattning",
        untitled = "Namnlös order"
      },
      fields = {
        title = "Ordertitel",
        id = "Order ID",
        type = "Typ",
        status = "Status",
        priority = "Prioritet",
        created = "Skapad",
        updated = "Senaste uppdatering"
      },
      placeholders = {
        title = "Titel på order",
        id = "Genereras automatiskt om tomt",
        type = "Välj typ",
        description = "Lägg till en beskrivning...",
        tag = "Lägg till tagg",
        reportSelect = "Välj en rapport",
        offenceSelect = "Välj ett brott"
      },
      sections = {
        description = "Beskrivning",
        descriptionSubtitle = "Sammanfattning och instruktioner.",
        tags = "Taggar",
        tagsSubtitle = "Snabbidentifiering för ordern.",
        reports = "Länkade rapporter",
        reportsSubtitle = "Bifoga relaterade rapportfiler.",
        offences = "Brott",
        offencesSubtitle = "Länka brott kopplade till denna order.",
        gallery = "Galleri",
        gallerySubtitle = "Bifoga galleribilder till ordern."
      },
      gallery = {
        title = "Välj ett foto",
        subtitle = "Välj en galleribild att bifoga till ordern.",
        loading = "Laddar galleri...",
        empty = "Inga galleribilder tillgängliga.",
        photoAlt = "Gallerifoto"
      },
      typesModal = {
        title = "Ordertyper",
        subtitle = "Lägg till eller ta bort ordertyper för denna enhet.",
        placeholder = "Lägg till ordertyp",
        empty = "Inga ordertyper konfigurerade."
      },
      types = {
        arrest = "Arrestering",
        search = "Husrannskan",
        bench = "Domstolsorder",
        probation = "Skyddstillsyn"
      },
      status = {
        active = "Aktiv",
        served = "Verkställd",
        expired = "Utgången",
        cancelled = "Avbruten"
      },
      priority = {
        low = "Låg",
        medium = "Medium",
        high = "Hög",
        critical = "Kritisk"
      },
      errors = {
        load = "Kunde inte ladda ordrar.",
        save = "Kunde inte spara order.",
        titleRequired = "Ange en titel innan du sparar.",
        typeRequired = "Välj en typ innan du sparar.",
        gallery = "Kunde inte ladda galleri."
      }
    },
    ----
    prison = {
      eyebrow = "Häktningslogg",
      title = "Fängelse",
      listed = "listade",
      search = {
        placeholder = "Sök på namn eller ID"
      },
      filters = {
        all = "Alla",
        label = "Status",
        placeholder = "Status"
      },
      actions = {
        refresh = "Uppdatera",
        back = "Tillbaka till listan",
        saveDuration = "Spara tid",
        minusMinutes = "-15 min",
        minusSmall = "-5 min",
        plusSmall = "+5 min",
        plusMinutes = "+15 min",
        saveNotes = "Spara anteckningar",
        saveWarrant = "Länka order",
        addOffence = "Lägg till brott",
        setSolitary = "Skicka till isolering",
        setGeneral = "Återgå till allmänhet"
      },
      state = {
        loading = "Laddar fångar...",
        empty = "Inga fångar matchar filtren.",
        saving = "Sparar...",
        noOffences = "Inga länkade brott ännu."
      },
      labels = {
        mugshot = "Mugshot"
      },
      detail = {
        summary = "Fångsammanfattning"
      },
      fields = {
        booked = "Inskriven",
        remaining = "Återstående tid",
        identifier = "Identifierare",
        unknown = "Okänd",
        remainingMinutes = "Återstående minuter",
        warrant = "Order",
        offences = "Brott",
        housing = "Placering"
      },
      sections = {
        duration = "Strafftid",
        durationSubtitle = "Justera återstående tid i minuter.",
        notes = "Anteckningar",
        notesSubtitle = "Logga observationer för detta straff.",
        links = "Länkad order & brott",
        linksSubtitle = "Bifoga ordern och brotten kopplade till denna vistelse.",
        housing = "Placering",
        housingSubtitle = "Växla mellan isoleringscell och allmänhet."
      },
      placeholders = {
        note = "Lägg till anteckningar...",
        warrant = "Välj en order",
        offence = "Välj ett brott"
      },
      status = {
        in_prison = "I fängelse",
        breaked_out = "Rymt",
        released = "Frisläppt"
      },
      solitary = {
        active = "Isoleringscell",
        inactive = "Allmän population",
        badge = "Isolering"
      },
      duration = {
        minutesOnly = "{minutes}m kvar",
        full = "{hours}h {minutes}m kvar"
      },
      linked = {
        warrantFallback = "Order"
      },
      date = {
        unknown = "Okänd"
      },
      errors = {
        load = "Kunde inte ladda fångar.",
        duration = "Kunde inte uppdatera tiden.",
        note = "Kunde inte spara anteckningen.",
        links = "Kunde inte uppdatera länkarna.",
        solitary = "Kunde inte uppdatera isoleringscellen.",
        solitary_unavailable = "Inga isoleringsceller konfigurerade för detta fängelse."
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
        title = "Funktioner",
        subtitle = "Aktivera eller inaktivera resursfunktioner for alla konfigurerade jobb.",
        instantTuning = { label = "instantTuning", description = "" },
        partsDelivery = { label = "Del-leverans", description = "Aktivera verkstadens delbestallningar och leveransplatser." },
        carryItems = { label = "Fysisk delhantering", description = "Krav att levererade delar transporteras genom verkstaden." },
        nitro = { label = "nitro", description = "" },
        antiLag = { label = "antiLag", description = "" },
        twoStep = { label = "twoStep", description = "" },
        wheelDamage = { label = "Hjulskador", description = "Aktivera realistiska hjulskador och reparationer." },
        customHandling = { label = "customHandling", description = "" },
        mileageHud = { label = "Mil-HUD", description = "Visa fordonsmiltal under korning." },
        workshopLift = { label = "Verkstadslyft", description = "Aktivera anvandbara lyftpunkter i verkstader." }
      },
globalSettings = { title = "Global settings", notice = "These values apply to all configured jobs. Saving them from this job updates the behavior globally." },
      tuning = { globalTitle = "Global pricing settings", globalBadge = "Global", globalNotice = "These values apply to all configured jobs. Saving them from this job updates pricing behavior globally.", nitroAccess = "Nitrotillgång för detta jobb", nitroAccessHelp = "Åsidosätt den globala Nitro-funktionen för detta mekanikerjobb.", nitroAccessInherit = "Använd global Nitro-inställning", nitroAccessEnabled = "Aktivera Nitro för detta jobb", nitroAccessDisabled = "Inaktivera Nitro för detta jobb" },
      fields = { allowedJobs = "Allowed jobs", animationDict = "Animation dict", animationName = "Animation name", blip = "Blip", bone = "Bone", category = "Category", color = "Job color", consumeItems = "Consume items", cost = "Cost", distance = "Distance", enabled = "Enabled", garageType = "Garage type", heading = "Heading", item = "Item", jobName = "Job name", label = "Label", marker = "Marker", mechanicOnly = "Mechanic", name = "Name", offsetX = "Offset X", offsetY = "Offset Y", offsetZ = "Offset Z", offDutyEnabled = "Off-duty enabled", offDutyJob = "Off-duty job", ped = "Ped", pedModel = "Ped model", price = "Price", prop = "Prop", requiredItems = "Required items", scenario = "Scenario", sprite = "Sprite", stage = "Stage", transport = "Transport", trunkCapacity = "Trunk capacity", type = "Type", value = "Value", x = "X", y = "Y", z = "Z", minGrade = "Lägsta rang", livery = "Lackering", fuelType = "Bränsletyp", primaryColor = "Primärfärg", secondaryColor = "Sekundärfärg", pearlescentColor = "Pärlemofärg", wheelColor = "Hjulfärg", extras = "Extra tillbehör", extraId = "Extra-ID", propCounts = "Propbegränsningar", count = "Gräns", properties = "Fordonsegenskaper", property = "Egenskap" },
      placeholders = { allowedJobs = "mechanic, tuner", itemName = "Item name", jobName = "job name", label = "Label", model = "Model", vehicleName = "Name", liveryIndex = "e.g. 0", paintIndex = "0-160", propCounts = "{ \"prop_model\": 4 }", properties = "{ \"windowTint\": 1 }" },
      fuelTypes = {
        default = "Standard (vanlig)",
        regular = "Vanlig",
        plus = "Plus",
        premium = "Premium",
        diesel = "Diesel",
      },
      descriptions = { color = "Color used by Sky Jobs menus, blips, and job UI accents.", jobName = "Framework job name registered for this job.", offDutyEnabled = "Enable an off-duty counterpart for this job.", offDutyJob = "Job name used when this employee goes off duty." },
      messages = { empty = "No jobs configured yet.", featuresSaved = "Features saved.", invalidJson = "Correct invalid JSON fields before saving.", loading = "Loading jobs...", nameExists = "A job with this job name already exists.", noTuningOptions = "No options configured in this category.", saved = "Settings saved.", saveFailed = "Unable to save changes." },
      locations = { addSubtitle = "Choose which point type to place.", addTitle = "Add location point", deleteFailed = "Unable to delete location.", deleteSaved = "Location removed. Save settings to apply it.", emptySubtitle = "This configurator has no registered location definitions.", emptyTitle = "No locations configured.", garageMenu = "Menu", garagePark = "Park", garageSpawn = "Spawn", placeFailed = "Unable to place location.", placementHint = "Press Enter to place and Backspace to cancel.", placementSaved = "Location updated. Save settings to apply it.", placementTitle = "Placement mode", teleported = "Teleported to location.", teleportFailed = "Unable to teleport to location.", unset = "Not set" },
      carryItems = { missingProp = "Enter a prop model before opening placement.", placementFailed = "Unable to edit attach placement.", placementSaved = "Attach placement updated. Save settings to apply it.", selectItem = "Select delivery item" },
      extensions = { invalidJson = "Ogiltig JSON. Korrigera syntaxen innan du sparar.", jsonObjectRequired = "Vardet maste vara ett JSON-objekt.", partsDeliveryShop = "Del-leveransbutik", tuningCostProfile = { label = "Tuningpriser", description = "Konfigurera kostnader for prestanda, utseende, hjul och specialalternativ for detta jobb." } },
garageTypes = { boat = "Boat", helicopter = "Helicopter", vehicle = "Vehicle" },
      colorPopup = { title = "Job color" },
      dialogs = { delete = { cancel = "Cancel", confirm = "Delete", message = "Delete {name}?", title = "Delete job" } },
      screenPosition = { preview = "HUD" },
      interactions = { title = "Interactions", empty = "No interactions configured.", addMarkerSetting = "Add marker setting", noPedSelected = "No ped selected", headers = { interaction = "Interaction", key = "Key", marker = "Marker", blip = "Blip", npc = "NPC" }, tabs = { behavior = "Behavior", marker = "Marker", blip = "Blip", npc = "NPC" }, status = { on = "On", off = "Off" }, fields = { unique = "Unique", forceMarkerInteraction = "Force marker interaction", interactionDistance = "Interaction distance", placementModel = "Placement model" }, help = { unique = "Limits the interaction type to one configured point for a location when enabled.", forceMarkerInteraction = "Forces marker-style interaction handling even when target/NPC interaction support is available.", interactionDistance = "Maximum distance from the point where the player can use the interaction.", placementModel = "Object model shown while placing this interaction in the creator." } },
      assetPicker = { search = "Search", allCategories = "All categories", itemCount = "{count} items", markerTitle = "Marker type", markerSubtitle = "Choose a DrawMarker type.", blipTitle = "Blip sprite", blipSubtitle = "Choose a map blip sprite.", pedTitle = "Ped model", pedSubtitle = "Choose a FiveM ped model.", chooseMarker = "Choose marker", chooseBlip = "Choose blip", choosePed = "Choose ped" },
      markerFields = { posX = "Position X", posY = "Position Y", posZ = "Position Z", dirX = "Direction X", dirY = "Direction Y", dirZ = "Direction Z", rotX = "Rotation X", rotY = "Rotation Y", rotZ = "Rotation Z", scaleX = "Scale X", scaleY = "Scale Y", scaleZ = "Scale Z", red = "Red", green = "Green", blue = "Blue", alpha = "Alpha", bobUpAndDown = "Bob up/down", faceCamera = "Face camera", rotationOrder = "Rotation order", rotate = "Rotate", textureDict = "Texture dict", textureName = "Texture name", drawOnEnts = "Draw on entities" },
      instantTuning = { title = "Instant Tuning", defaultLabel = "Default label", defaultLabelHelp = "Text shown at instant tuning points.", interactionDistanceHelp = "Default distance from which a point can be used.", priceMultiplier = "Price multiplier", priceMultiplierHelp = "Multiplier applied to instant tuning prices.", forceMarkerHelp = "Forces marker-style interaction handling even when target support is available.", mechanicOnlyHelp = "Restricts every instant tuning point to configured mechanic jobs.", allowedJobsHelp = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", emptyLocations = "No instant tuning locations configured.", emptyLocationsHelp = "Add a location, then use Set to capture your current position." }
  ,

      configs = { sky_mechanicjob = { title = "Mekanikjobb", subtitle = "Konfigurera mekanikjobb, butiker, fordon och verkstadsplatser." } },
      settingSections = { general = "Allmant", partsTheft = "Delsstold", vehicleCare = "Fordonsvard", wear = "Slitage", wheelDamage = "Hjulskador", mileageHud = "Mil-HUD", instantTuning = "Instant Tuning", carryItems = "Barbara delar" },
      settingFields = { key = "Nyckel", label = "Etikett", name = "Itemnamn", amount = "Antal", price = "Pris", item = "Item", repair = "Reparera med kit", classId = "Klass-ID", multiplier = "Multiplikator", kilometersToZero = "Kilometer till noll", removeAfterUse = "Forbruka item", flow = "Installationsflode", transport = "Transport", prop = "Prop", bone = "Bone", x = "X", y = "Y", z = "Z", rx = "Rot X", ry = "Rot Y", rz = "Rot Z", category = "Kategori" },
      settings = {
        primaryColor = { label = "Primarfarg", description = "Main mechanic configurator color and default job color fallback. Use a hex value such as #EDC001." },
        orderInstallNonMinigameDurationMs = { label = "Enkel installationstid", description = "Milliseconds used for order install steps that do not run a minigame." },
        tuningWorkshopRequireForInstall = { label = "Krav verkstad for installation", description = "Require tuning order installs to start and complete near a self-service tuning point." },
        tuningWorkshopRequireForRemoval = { label = "Krav verkstad for borttagning", description = "Require tuning removals to start and complete near a self-service tuning point." },
        tuningWorkshopDistance = { label = "Kravavstand verkstad", description = "Maximum distance from a self-service tuning point for required install or removal actions." },
        addRevenueToSociety = { label = "Satt in intakter i society", description = "Deposit paid tuning order money into the tuning job society account." },
        publicUsersSeePrices = { label = "Publika anvandare ser priser", description = "Show regular tuning prices to non-mechanic public users." },
        fallbackVehicleValue = { label = "Standard fordonsvarde", description = "Value used when no vehicle price can be resolved." },
        priceType = { label = "Pristyp", description = "Percentage calculates each tuning cost from the vehicle price. Fixed uses the entered money amount.", options = { percentage = "Procent", fixed = "Fast" } },
        freeVehicles = { label = "Gratis tuningfordon", description = "Vehicle spawn models that receive free tuning orders.", itemLabel = "Vehicle model" },
        partsTheftItem = { label = "Stoldverktyg", description = "Inventory item used to steal wheels and catalytic converters." },
        partsTheftRemoveItemAfterUse = { label = "Forbruka stoldverktyg", description = "Remove the theft tool item after a successful theft action." },
        partsTheftStolenWheelItem = { label = "Stulet hjul", description = "Inventory item awarded when wheels are stolen." },
        partsTheftCatalyticConverterItem = { label = "Katalysator", description = "Inventory item awarded when a catalytic converter is stolen." },
        partsTheftDealerAccount = { label = "Dealer payout account", description = "Account used for stolen parts dealer payouts, such as money or bank." },
        partsTheftDealerSellDistance = { label = "Dealer sell distance", description = "Maximum distance from the dealer to sell stolen parts." },
        partsTheftDispatchEnabled = { label = "Skicka polisdispatch", description = "Create a police dispatch when a wheel or catalytic converter is stolen." },
        partsTheftDispatchJobs = { label = "Dispatch jobs", description = "Job names that receive parts theft dispatches.", itemLabel = "Job name" },
        partsTheftDispatchTitle = { label = "Dispatch title", description = "Title shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchMessage = { label = "Dispatch message", description = "Message shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchCooldownSeconds = { label = "Dispatch cooldown", description = "Seconds before the same vehicle part can create another dispatch." },
        partsTheftDealerItems = { label = "Dealer items", description = "Stolen items the dealer will buy and their payout values.", itemLabel = "Dealer item" },
        vehicleCareWashItem = { label = "Tvatt-item", description = "Inventory item used to wash a vehicle." },
        vehicleCareWashRemoveAfterUse = { label = "Forbruka tvatt-item", description = "Remove the wash item after use." },
        vehicleCareWaxItem = { label = "Vax-item", description = "Inventory item used to wax a vehicle." },
        vehicleCareWaxRemoveAfterUse = { label = "Forbruka vax-item", description = "Remove the wax item after use." },
        vehicleCareWaxCleanKilometers = { label = "Wax clean kilometers", description = "Distance a waxed vehicle stays clean." },
        vehicleCareRepairItem = { label = "Reparations-item", description = "Inventory item used by the vehicle repair action." },
        vehicleCareRepairRemoveAfterUse = { label = "Forbruka reparations-item", description = "Remove the repair item after use." },
        vehicleCareRepairDurationMs = { label = "Reparationstid", description = "Repair progress duration in milliseconds." },
        vehicleCareRepairMaxDistance = { label = "Repair max distance", description = "Maximum distance from the vehicle while repairing." },
        vehicleCareRepairVehicleDamage = { label = "Fix vehicle damage", description = "Repair normal GTA vehicle damage when using the repair action." },
        vehicleCareRepairFixRealisticWheelDamage = { label = "Fix realistic wheel damage", description = "Also reset realistic wheel damage when using the repair action." },
        vehicleCareRepairWearParts = { label = "Repair kit restored parts", description = "Choose which wear and service parts the repair item restores. Disable fluids here if oil, coolant, brake fluid, or transmission fluid should require the diagnostics repair flow.", itemLabel = "Wear part" },
        wearParts = { label = "Slitagedelar", description = "Vehicle wear parts, their lifetime distance, required repair item, item consumption, and install flow.", itemLabel = "Wear part", fields = { flow = { options = { wheel = "Wheel", performance = "Performance", underbody_neon = "Underbody / lift", oil_change = "Oil change", fluid_refill = "Fluid refill", catalytic_converter = "Catalytic converter", hood_install = "Hood install" } } } },
        wheelDamageDefaultMultiplier = { label = "Standardmultiplikator", description = "Base wheel damage multiplier." },
        wheelDamageOffroadWheelsMultiplier = { label = "Off-road wheel multiplier", description = "Multiplier used when the vehicle has off-road wheels." },
        wheelDamageVehicleClassMultipliers = { label = "Vehicle class multipliers", description = "Damage multipliers per GTA vehicle class.", itemLabel = "Vehicle class" },
        mileageHudDigits = { label = "Siffror", description = "Number of digits shown in the mileage HUD." },
        mileageHudPosition = { label = "Position", description = "Drag the mileage HUD preview to the desired screen position." },
        partsDeliveryTimeSeconds = { label = "Leveranstid", description = "Seconds between ordering parts and the delivery becoming ready." },
        partsDeliveryTimerHudEnabled = { label = "Show delivery timer", description = "Show a small in-game timer HUD after a parts order is placed." },
        partsDeliveryTimerHudPosition = { label = "Timer position", description = "Drag the parts delivery timer HUD preview to the desired screen position." },
        partsDeliveryOwnCard = { label = "Own card payment", description = "Allow players to pay parts delivery orders with their own money." },
        partsDeliveryCompanyCard = { label = "Company card payment", description = "Allow parts delivery orders to use company funds." },
        partsDeliveryOpenDurationMs = { label = "Open duration", description = "Milliseconds required to unpack a ready parts delivery." },
        instantTuningInteractionDistance = { label = "Interaktionsavstand", description = "Default distance for using instant tuning points." },
        instantTuningForceMarkerInteraction = { label = "Force marker interaction", description = "Use marker-style E interaction even when target support is enabled." },
        instantTuningMechanicOnly = { label = "Endast mekaniker", description = "Restrict all instant tuning locations to configured mechanic jobs." },
        instantTuningAllowedJobs = { label = "Tillatna jobb", description = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", itemLabel = "Job name" },
        instantTuningPriceMultiplier = { label = "Prismultiplikator", description = "Multiplier applied to instant tuning prices." },
        instantTuningLabel = { label = "Standardetikett", description = "Default text shown at instant tuning points." },
        instantTuningMarkerEnabled = { label = "Marker enabled", description = "Draw a world marker at instant tuning locations." },
        instantTuningMarkerType = { label = "Marker type", description = "GTA marker type used for instant tuning locations." },
        instantTuningBlipEnabled = { label = "Blip enabled", description = "Show map blips for instant tuning locations." },
        instantTuningBlipName = { label = "Blip name", description = "Map blip name." },
        instantTuningBlipSprite = { label = "Blip sprite", description = "GTA blip sprite id." },
        instantTuningBlipColor = { label = "Blip color", description = "GTA blip color id." },
        instantTuningLocations = { label = "Platser", description = "Instant tuning points. Use 0 distance to inherit the default interaction distance.", itemLabel = "Locations" },
        carryItems = { label = "Barbara delar", description = "Delivered parts that should become physical carried props.", itemLabel = "Carry item", fields = { transport = { options = { hand = "Hand", forklift = "Gaffeltruck", engine_lift = "Motorlyft" } } } }
      },
      settingValues = {
        tyres = "Tyres", brake_pads = "Brake Pads", suspension = "Suspension", spark_plugs = "Spark Plugs", engine_oil = "Engine Oil", coolant = "Coolant", brake_fluid = "Brake Fluid", transmission_fluid = "Transmission Fluid", clutch = "Clutch", air_filter = "Air Filter", traction_battery = "Traction Battery", inverter = "Power Inverter", catalytic_converter = "Catalytic Converter",
        vehicleClass_0 = "Compacts", vehicleClass_1 = "Sedans", vehicleClass_2 = "SUVs", vehicleClass_3 = "Coupes", vehicleClass_4 = "Muscle", vehicleClass_5 = "Sports Classics", vehicleClass_6 = "Sports", vehicleClass_7 = "Super", vehicleClass_8 = "Motorcycles", vehicleClass_9 = "Off-road", vehicleClass_10 = "Industrial", vehicleClass_11 = "Utility", vehicleClass_12 = "Vans", vehicleClass_13 = "Cycles", vehicleClass_14 = "Boats", vehicleClass_15 = "Helicopters", vehicleClass_16 = "Planes", vehicleClass_17 = "Service", vehicleClass_18 = "Emergency", vehicleClass_19 = "Military", vehicleClass_20 = "Commercial", vehicleClass_21 = "Trains", vehicleClass_22 = "Open Wheel"
      }
  },
    jobConfigurator = {
      actions = {
        backToScripts = "Skript"
      },
      selector = {
        title = "Jobbkonfigurator",
        subtitle = "Välj vilket jobbskript du vill konfigurera.",
        description = "Välj resursen du vill konfigurera.",
        loading = "Laddar konfiguratorer...",
        comingSoon = "Kommer snart",
        emptyTitle = "Inga konfigurerbara skript tillgängliga.",
        emptySubtitle = "Du har inte behörighet till någon registrerad jobbkonfigurator.",
        unavailable = "Inte registrerad"
      }
    },
    billing = {
      title = "Utfärda faktura",
      subtitle = "Debitera medborgare för tjänster.",
      selectLabel = "Välj person",
      selectPlaceholder = "Välj person",
      noPlayers = "Inga personer i närheten inom {range} m.",
      amountLabel = "Fakturabelopp",
      reasonLabel = "Orsak (kort)",
      reasonPlaceholder = "Exempel: Patrullering",
      presetsLabel = "Brott",
      presetSearchPlaceholder = "Sök brott eller böter",
      presetNoMatches = "Inga brott matchar din sökning.",
      presetReasonHeader = "Brott",
      presetAmountHeader = "Böter",
      presetCustomAmount = "Anpassad",
      paperDefaultCategory = "Anmälan om parkeringsöverträdelse",
      ticketReceiptTitle = "Böteslapp",
      ticketReceiptSubtitle = "Registrerad vid",
      ticketReceiptCitizenLabel = "Medborgare",
      ticketReceiptOfficerLabel = "Utfärdande personal",
      ticketReceiptReasonLabel = "Sammanfattning av anklagelse",
      ticketReceiptAmountLabel = "Totala böter",
      ticketReceiptAcknowledge = "Bekräfta",
      cancelButton = "Avbryt",
      submitButton = "Utfärda faktura",
      submitting = "Skickar...",
      success = "Faktura utfärdad.",
      paperTicketNumber = "Bötesnr",
      paperDate = "Datum",
      paperTime = "Tid",
      paperCitizenLabel = "Medborgare",
      paperOfficerLabel = "Personal",
      paperViolationLabel = "Överträdelse",
      paperNotice = "Betalning krävs omedelbart. Underlåtenhet att betala kan leda till beslagtagande.",
      paperSignatureLabel = "Personalens signatur",
      paperTotalFine = "Totala böter",
      errors = {
        failed = "Kunde inte utfärda faktura.",
        invalid_target = "Personen är inte tillgänglig.",
        empty_reason = "Ange en kort orsak.",
        too_far = "Personen rörde sig för långt bort.",
        not_authorized = "Du är inte behörig att utfärda fakturor.",
        not_on_duty = "Du måste vara i tjänst för att utfärda fakturor.",
        amount_out_of_range = "Beloppet är utanför det tillåtna intervallet.",
        insufficient_funds = "Personen har inte råd med denna debitering.",
        player_unavailable = "Personen är inte tillgänglig.",
        disabled = "Faktureringssystemet är inaktiverat."
      }
    },
  }
}
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
