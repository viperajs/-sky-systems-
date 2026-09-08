if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/config/locales/fi.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

-- Finnish translation
Locales["fi"] = {
  WardrobeHelpNotify = "Avaa vaatekaappi",
  WardrobeTitle = "Vaatekaappi",
  WardrobeCivilianMissing = "Siviiliasua ei ole vielä tallennettu.",
  WardrobeCivilianRestored = "Siviiliasu ladattu.",
  WardrobeUnsupportedFramework = "Vaatekaappi ei toimi valitulla frameworkilla ({framework}).",
  WardrobeMissingSkinchanger = "Vaatekaappi vaatii, etta skinchanger on kaynnissa ESX:ssa.",
  WardrobeMissingEsxSkin = "Vaatekaappi vaatii, etta esx_skin on kaynnissa ESX:ssa.",
  WardrobeMissingQbClothing = "Vaatekaappi vaatii, etta qb-clothing on kaynnissa frameworkilla {framework}.",
  WardrobeMissing17Movement = "Vaatekaappi vaatii, etta 17mov_CharacterSystem on kaynnissa.",
  WardrobeMissingQsAppearance = "Vaatekaappi vaatii, etta qs-appearance on kaynnissa.",
  WardrobeMissingAk47Clothing = "Vaatekaappi vaatii, etta ak47_clothing on kaynnissa.",
  WardrobeMissingAk47QbClothing = "Vaatekaappi vaatii, etta ak47_qb_clothing on kaynnissa.",
  WardrobeMissingTgiannClothing = "Vaatekaappi vaatii, etta tgiann-clothing on kaynnissa.",
  WardrobeMissingNfSkin = "Vaatekaappi vaatii, etta nf-skin on kaynnissa.",
  WardrobeMissingBlAppearance = "Vaatekaappi vaatii, etta bl_appearance on kaynnissa.",
  WardrobeMissingIzzyAppearance = "Vaatekaappi vaatii, etta izzy-appearance on kaynnissa.",
  WardrobeMissingCodemAppearance = "Vaatekaappi vaatii, etta codem-appearance on kaynnissa.",
  WardrobeMissingHexClothing = "Vaatekaappi vaatii, etta hex_clothing on kaynnissa.",
  WardrobeMissingIllenium = "Vaatekaappi vaatii, etta illenium-appearance on kaynnissa.",
  WardrobeCustomUnavailable = "Maaritetty mukautettu vaatekaappi-integraatio ei ole saatavilla.",
  WardrobeDisabled = "Vaatekaappi on poistettu kaytosta configissa.",
  WardrobeMissingRcoreClothing = "Vaatekaappi vaatii, etta rcore_clothing on kaynnissa.",
  WardrobeUnknownJob = "Vaatekaapin työ ei ole käytettävissä.",
  GarageHelpNotify = "Avaa talli",
  GarageTitle = "Autotalli",
  HelicopterGarageHelpNotify = "Avaa helikopterikenttä",
  BoatGarageHelpNotify = "Avaa laituri",
  GarageParkHelpNotify = "Pysäköi ajoneuvo",
  HelicopterGarageParkHelpNotify = "Pysäköi helikopteri",
  BoatGarageParkHelpNotify = "Pysäköi vene",
  GarageParkDriverRequired = "Sinun on oltava kuljettajan paikalla pysäköidäksesi.",
  GarageParkInvalidVehicle = "Tätä ajoneuvoa ei voi pysäköidä tähän.",
  GarageParkFailedNotify = "Ajoneuvoa ei voitu pysäköidä.",
  GarageSpawnBlockedNotify = "Spawnauspiste on estetty.",
  StorageHelpNotify = "Avaa varasto",
  LockerHelpNotify = "Avaa kaappi",
  TrunkTitle = "Takakontti",
  TrunkHelpNotify = "Avaa tavaratila",
  TrunkPropRemoveHelp = "Poista asetettu esine",
  TrunkUnavailable = "Tavaratilaan ei saada yhteyttä.",
  BossMenuHelpNotify = "Avaa hallinta",
  Payroll = {
    title = "Palkka",
    paid = "Palkka maksettu: {amount}",
    insufficient = "Yrityksen tilillä ei ole tarpeeksi varoja palkkasi maksamiseen.",
  },
  PublicFormsTitle = "Julkiset lomakkeet",
  PublicFormsHelpNotify = "Täytä julkisia lomakkeita",
  PublicFormsUnavailable = "Lomakekioski ei ole käytettävissä.",
  WholesaleShopTitle = "Tukkukauppa",
  WholesaleShopHelpNotify = "Avaa tukkukauppa",
  WholesaleShopUnavailable = "Tässä sijainnissa ei ole tukkutoimittajaa.",
  NoPermission = "Sinulla ei ole oikeuksia käyttää tätä komentoa.",
  CameraUploadFailed = "Kameran lähetys epäonnistui.",
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
    Title = "Hätäpainike",
    Sent = "Hätäkutsu lähetetty.",
    NotOnDuty = "Sinun on oltava työvuorossa käyttääksesi hätäpainiketta.",
    Cooldown = "Hätäpainike on jäähtymässä. Odota {seconds}s.",
    MappingDescription = "Laukaise hätähälytys",
    WaypointSet = "Reittipiste asetettu hätäkutsun sijaintiin.",
    WaypointMissing = "Ei aktiivista hätäkutsun sijaintia.",
    LocationUnknown = "Tuntematon sijainti",
    MissingItem = "Tarvitset {item} käyttääksesi hätäpainiketta.",
  },
  Ping = {
    Title = "Pingi",
    Sent = "Sijainti jaettu.",
    NotOnDuty = "Sinun on oltava työvuorossa lähettääksesi pingin.",
    Cooldown = "Ping on jäähtymässä. Odota {seconds}s.",
    MappingDescription = "Lähetä sijaintimerkki",
    LocationUnknown = "Tuntematon sijainti",
    MissingItem = "Tarvitset {item} lähettääksesi pingin.",
  },
  HeliCam = {
    Title = "Helikopterikamera",
    CamEnabled = "Kamera käytössä.",
    CamDisabled = "Kamera poistettu käytöstä.",
    NotAuthorized = "Sinulla ei ole oikeutta käyttää kameraa.",
    NotOnDuty = "Sinun on oltava työvuorossa käyttääksesi kameraa.",
    TooLow = "Helikopteri on liian matalalla kameran aktivoimiseksi.",
    TargetLocked = "Kohde lukittu.",
    TargetReleased = "Kohteen lukitus vapautettu.",
    TargetLost = "Kohde menetetty.",
    RappelDenied = "Et voi laskeutua köydellä tästä istuimesta.",
    RappelStarted = "Köysilaskeutuminen aloitettu.",
    PhotoSaved = "Kuva tallennettu galleriaan.",
    PhotoFailed = "Kuvan tallentaminen epäonnistui.",
    Spotlight = {
      ForwardOn = "Etsintävalo päällä.",
      ForwardOff = "Etsintävalo pois päältä.",
      TrackingOn = "Seuraava valonheitin käytössä.",
      TrackingOff = "Seuraava valonheitin pois päältä.",
      ManualOn = "Manuaalinen valonheitin käytössä.",
      ManualOff = "Manuaalinen valonheitin pois päältä.",
      Brightness = "Valon kirkkaus: {value}",
      Radius = "Valon säde: {value}"
    }
  },
  InteractionLabels = {
    job_garage              = "Työajoneuvotalli",
    garage_vehicle_spawn    = "Ajoneuvon spawn-piste",
    garage_vehicle_park     = "Ajoneuvon pysäköinti",
    garage_helicopter_menu  = "Helikopterihalli",
    garage_helicopter_spawn = "Helikopterin spawn-piste",
    garage_helicopter_park  = "Helikopterin pysäköinti",
    garage_boat_menu        = "Venesatama",
    garage_boat_spawn       = "Veneen spawn-piste",
    garage_boat_park        = "Veneen kiinnitys",
    boss_menu               = "Hallinta",
    duty_terminal           = "Työvuoropääte",
    wardrobe                = "Pukuhuone",
    storage                 = "Varasto",
    locker                  = "Kaappi",
    wholesale_shop          = "Tukkukauppa",
    public_forms            = "Julkiset lomakkeet",
    jail_terminal           = "Vankilaterminaali",
    jail_jobs               = "Vankilan työtehtävät",
    jail_job_npc            = "Vankilan työtehtävät",
    jail_inmate_alcoholic   = "Vanki: Alkoholisti",
    jail_inmate_drugdealer  = "Vanki: Huumekauppias",
    jail_inmate_codelist    = "Vanki: Ilmiantaja",
    jail_inmate_wirecutter  = "Vanki: Työkalujen välittäjä",
    jail_inmate_doctor      = "Vankilalääkäri",
    jail_canteen_cook       = "Ruokalan kokki",
    jail_confiscated_return = "Takavarikoidut tavarat",
    jail_electric_box       = "Sähkökotelo",
    jail_fence_cut          = "Aidan katkaisupiste",
  },
  Nui = {
    IntlLocale = "fi-FI",
    currency = "€",
    menuTitles = {
      locker = "Henkilökohtainen kaappi",
      storage = "Varasto",
      trunk = "Ajoneuvon tavaratila",
      ["trunk-props"] = "Ajoneuvon varusteet",
      search = "Etsi",
      garage = "Talli",
      vehshop = "Autokauppa",
      management = "Hallinta",
      shop = "Tukkukauppa",
      ["impound-storage"] = "Pysäköinninvalvonnan varasto",
      refunds = "Hyvitykset"
    },
    menu = {
      goToVehicleShop = "Siirry autokauppaan",
      backToGarage = "Takaisin talliin"
    },
    radial = {
      empty = "Ei toimintoja saatavilla.",
      errors = {
        generic = "Toiminto ei ole käytettävissä."
      },
      title = "Työvuoron toiminnot",
      hint = "Valitse toiminto.",
      pressKey = "Paina {key}",
      actions = {
        billing = {
          label = "Luo lasku",
          description = "Luo lasku lähimmälle henkilölle.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Laskutus ei ole käytettävissä.",
            notOnDuty = "Kirjaudu työvuoroon lähettääksesi laskuja.",
            notAuthorized = "Sinulla ei ole oikeutta lähettää laskuja.",
            noPatients = "Ei lähistöllä olevia henkilöitä laskutettavaksi."
          }
        },
        panic = {
          label = "Hätäpainike",
          description = "Laukaise hätähälytys nykyiselle sijainnillesi.",
          states = {
            disabled = "Hätäpainike ei ole käytettävissä.",
            notOnDuty = "Kirjaudu työvuoroon käyttääksesi hätäpainiketta.",
            notAuthorized = "Sinulla ei ole oikeutta käyttää hätäpainiketta."
          }
        },
        tablet = {
          label = "Avaa tabletti",
          description = "Avaa tablet-käyttöliittymä.",
          states = {
            notOnDuty = "Kirjaudu työvuoroon käyttääksesi tablettia.",
            notAuthorized = "Sinulla ei ole oikeutta käyttää tablettia.",
            missingItem = "Tarvitset tabletin tähän."
          }
        },
        removeProp = {
          label = "Poista esine",
          description = "Poista lähistölle asetettu esine.",
          states = {
            noNearby = "Ei asetettuja esineitä lähistöllä.",
            failed = "Esineen poistaminen epäonnistui."
          }
        },
        carryPatient = {
          label = "Kanna henkilöä",
          description = "Kanna lähin henkilö turvaan.",
          dropLabel = "Laske henkilö",
          dropDescription = "Vapauta kantamasi henkilö.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Kantaminen ei ole käytettävissä.",
            beingCarried = "Sinua kannetaan jo.",
            inVehicle = "Poistu ajoneuvosta ensin.",
            selfIncapacitated = "Et ole tarpeeksi vakaassa kunnossa kantaaksesi ketään.",
            noPatients = "Ei lähistöllä olevia henkilöitä kannettavaksi.",
            tooFar = "Siirry lähemmäs ennen kantamista."
          }
        },
        playerSearch = {
          label = "Etsi henkilö",
          description = "Suorita haku lähimmälle henkilölle.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Henkilön haku ei ole käytettävissä.",
            notOnDuty = "Kirjaudu työvuoroon hakeaksesi ihmisiä.",
            notAuthorized = "Sinulla ei ole oikeutta hakea ihmisiä.",
            noPlayers = "Ei lähistöllä olevia henkilöitä haettavaksi.",
            tooFar = "Siirry lähemmäs ennen hakua.",
            inVehicle = "Poistu ajoneuvosta ensin."
          }
        },
        handcuff = {
          label = "Raudoita henkilö",
          description = "Laita raudat lähimmälle henkilölle.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Raudoitus ei ole käytettävissä.",
            notOnDuty = "Kirjaudu työvuoroon käyttääksesi rautoja.",
            inVehicle = "Poistu ajoneuvosta ensin.",
            targetInVehicle = "Poista henkilö ajoneuvosta ensin.",
            noPlayers = "Ei lähistöllä olevia henkilöitä raudoitettavaksi.",
            tooFar = "Siirry lähemmäs ennen raudoitusta.",
            missingItem = "Tarvitset käsiraudat tehdäksesi tämän.",
            alreadyCuffed = "Tämä henkilö on jo raudoissa."
          }
        },
        unhandcuff = {
          label = "Poista raudat",
          description = "Poista raudat lähimmältä henkilöltä.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Rautojen poisto ei ole käytettävissä.",
            notOnDuty = "Kirjaudu työvuoroon poistaaksesi rautoja.",
            inVehicle = "Poistu ajoneuvosta ensin.",
            targetInVehicle = "Poista henkilö ajoneuvosta ensin.",
            noPlayers = "Ei lähistöllä olevia henkilöitä rautojen poistoon.",
            tooFar = "Siirry lähemmäs ennen rautojen poistoa.",
            notCuffed = "Tämä henkilö ei ole raudoissa."
          }
        },
        wheelClamp = {
          label = "Rengaslukko",
          description = "Lukitse lähin ajoneuvo rengaslukolla.",
          states = {
            disabled = "Rengaslukitus ei ole käytettävissä.",
            notOnDuty = "Kirjaudu työvuoroon lukitaksesi ajoneuvoja.",
            inVehicle = "Poistu ajoneuvosta ensin.",
            noVehicle = "Ei ajoneuvoa lähistöllä.",
            tooFarVehicle = "Siirry lähemmäs ajoneuvoa.",
            noWheel = "Siirry lähemmäs rengasta.",
            tooFar = "Siirry lähemmäs rengasta."
          }
        },
        wheelClampRemove = {
          label = "Poista rengaslukko",
          description = "Poista rengaslukko ajoneuvosta.",
          states = {
            disabled = "Rengaslukitus ei ole käytettävissä.",
            notOnDuty = "Kirjaudu työvuoroon poistaaksesi lukkoja.",
            inVehicle = "Poistu ajoneuvosta ensin.",
            noClamp = "Ei rengaslukkoa lähistöllä.",
            tooFar = "Siirry lähemmäs rengaslukkoa."
          }
        },
        jail = {
          label = "Lähetä vankilaan",
          description = "Pidätä lähin pelaaja määritettyyn vankilaan.",
          states = {
            notAuthorized = "Sinulla ei ole oikeutta lähettää pelaajia vankilaan.",
            notOnDuty = "Kirjaudu työvuoroon käyttääksesi tätä toimintoa.",
            noPlayers = "Ei henkilöitä kantaman sisällä.",
            noJails = "Vankilasijainteja ei ole määritetty.",
            spawnNotSet = "Määritä vankilan aloituspiste ensin.",
            invalidTarget = "Henkilöä ei löydy.",
            failed = "Toiminto epäonnistui."
          }
        }
      }
    },
    shop = {
      shoppingCart = "Ostoskori",
      purchase = "Osta",
      balance = "Käytettävissä olevat varat",
      catalog = "Toimittajan kuvasto",
      empty = "Tässä sijainnissa ei ole tarvikkeita saatavilla.",
      emptyCart = "Korisi on tyhjä.",
      insufficientFunds = "Varat eivät riitä ostokseen.",
      limitReached = "Raja saavutettu ({limit}).",
      errors = {
        invalidStation = "Virheellinen asema.",
        emptyBasket = "Kori on tyhjä.",
        unknown = "Tuntematon virhe.",
        purchase = "Korin osto epäonnistui."
      }
    },
    garage = {
      states = {
        stored = "Valmiina",
        parked = "Käytössä"
      },
      title = "Talli",
      empty = "Ei kalustoa saatavilla.",
      emptyAir = "Ei helikoptereita saatavilla tällä kentällä.",
      ownedTitle = "Omistettu kalusto",
      shopTitle = "Autokauppa",
      shopBalance = "Ryhmittymän varat",
      shopEmpty = "Ei ajoneuvoja ostettavissa tästä sijainnista.",
      shopEmptyAir = "Ei helikoptereita ostettavissa tältä kentältä.",
      emptyFleet = "Kalustoa ei ole vielä ostettu.",
      noAccess = "Ei pääsyä",
      confirmSellTitle = "Vahvistaa myynti",
      confirmSellConfirm = "Myydä",
      confirmSellCancel = "peruuttaa",
      confirmSellMessage = "myydä {name} hintaan {price}?",
      confirmPurchaseTitle = "Vahvista osto",
      confirmPurchaseConfirm = "Osta",
      confirmPurchaseCancel = "Peruuta",
      confirmPurchaseMessage = "Osta {name} hintaan {price}?",
      purchaseSuccessTitle = "Ajoneuvo ostettu",
      purchaseSuccessMessage = "{name} lisätty kalustoon.",
      defaultVehicleName = "Ajoneuvo",
      stats = {
        topSpeed = "Huippunopeus",
        acceleration = "Kiihtyvyys",
        braking = "Jarrutus",
        traction = "Pito"
      },
      actions = {
        parkOut = "Ota käyttöön",
        buyVehicle = "Osta ajoneuvo",
        openTrunk = "Avaa tavaratila",
        editStretcher = "Muokkaa paareja",
        sellVehicle = "myydä ajoneuvo",
        changePlate = "Vaihda rekisterikilpi"
      },
      placeholders = {
        selectVehicle = "Valitse ajoneuvo nähdäksesi tiedot.",
        statsLoading = "Ladataan ajoneuvon tietoja..."
      },
      errors = {
        loadVehicles = "Tallin ajoneuvojen lataaminen epäonnistui.",
        loadStats = "Ajoneuvon tietojen lataaminen epäonnistui.",
        parkOut = "Ajoneuvon käyttöönotto epäonnistui.",
        unavailable = "Talli ei ole käytettävissä.",
        vehicleUnavailable = "Ajoneuvo ei ole saatavilla.",
        purchase = "Ajoneuvon osto epäonnistui.",
        openTrunk = "Tavaratilan avaaminen epäonnistui.",
        noAccess = "Sinulla ei ole pääsyä tähän ajoneuvoon.",
        stretcherEditor = "Paarimuokkaimen avaaminen epäonnistui.",
        stretcherPermission = "Vain korkein arvo voi muokata paarien lisäosia.",
        sellVehicle = "Ajoneuvon myynti epäonnistui.",
        editorUnavailable = "Muokkausohjelma ei ole käytettävissä.",
        changePlate = "Rekisterikilven vaihto epäonnistui."
      },
      changePlateTitle = "Vaihda rekisterikilpi",
      changePlateButton = "Käytä",
      plateEditor = {
        button = "Muokkaa kilpeä",
        title = "Muokkaa kilpeä",
        hint = "Vaihda tämän ajoneuvon rekisterikilpi.",
        save = "Tallenna kilpi",
        errors = {
          empty = "Anna rekisterikilpi.",
          invalid = "Rekisterikilpi on virheellinen.",
          update = "Rekisterikilven päivitys epäonnistui."
        }
      },
      status = {
        parkedBy = "Edellisen käyttäjä: {name}",
        unknownDriver = "Tuntematon"
      }
    },
    duty = {
      fields = {
        grade = "Arvo",
        location = "Asema",
        name = "Nimi",
        badge = "Virkamerkki"
      },
      instructions = {
        drag = "Vedä työntekijäkorttisi sensorin päälle hallinnoidaksesi vuoroasi.",
        dragCard = "Vedä työntekijäkortti sensorin päälle aloittaaksesi vuoron."
      },
      screen = {
        welcome = "Tervetuloa {name}",
        goodbye = "Vuoro päättynyt. Pidä huolta itsestäsi, {name}.",
        ready = "Vuoro aloitettu.",
        completed = "Vuoro päättyi onnistuneesti.",
        idleTitle = "Odotetaan skannausta",
        totalHours = "Tunteja yhteensä",
        shiftDuration = "Vuoron kesto",
        currentTime = "Nykyinen aika: {time}",
        defaultStation = "Pääterminali",
        devPrompt = "Lataa testiaineisto esikatsellaksesi terminaalia selaimessa.",
        loadMock = "Lataa testiaineisto",
        loading = "Ladataan..."
      },
      toasts = {
        failed = "Työvuoron tilan päivitys epäonnistui."
      },
      errors = {
        unavailable = "Työvuoroterminaali ei ole käytettävissä."
      },
      title = "Vuoroterminaali"
    },
    storage = {
      inventory = "Reppu",
      storage = "Varasto",
      locker = "Kaappi",
      trunk = "Ajoneuvon tavaratila",
      trunkProps = "Ajoneuvon varusteet",
      openPropMenu = "Varusteet",
      search = "Etsi",
      items = "Tavarat",
      weapons = "Aseet",
      transferTitle = "Siirto",
      transferButton = "Siirrä",
      capacityUnlimited = "Rajoittamaton kapasiteetti",
      errors = {
        trunkFull = "Tavaratila on täynnä.",
        searchReadOnly = "Voit vain poistaa tavaroita henkilöltä.",
        invalidTransfer = "Siirto epäonnistui.",
        invalidAmount = "Virheellinen määrä.",
        notEnoughItems = "Ei tarpeeksi tavaroita.",
        inventoryFull = "Ei tarpeeksi tilaa repussa.",
        storageFull = "Varasto on täynnä.",
        lockerFull = "Kaappi on täynnä.",
        restrictedItem = "Sinulla ei ole pääsyä tähän tavaraan.",
        invalidProp = "Varusteen valinta epäonnistui."
      },
      officerInventory = "Henkilökunnan tavarat",
      loadout = "Varustus",
      armory = "Asevarasto",
      armoryTitle = "Varustevarasto",
      storageTitle = "Suojattu varasto",
      storageSubtitle = "Vain valtuutetulle henkilökunnalle",
      emptyItems = "Ei tavaroita saatavilla.",
      emptyWeapons = "Ei aseita saatavilla.",
      emptyProps = "Ei varusteita saatavilla.",
      searchItems = "Tavarat",
      searchWeapons = "Aseet",
      lockerUnlocking = "Avataan kaappia...",
      restrictedPill = "Rajoitettu",
      restrictedTooltip = "Sinulla ei ole pääsyä tähän tavaraan.",
      capacityLabel = "{used}/{capacity}",
      propPlacement = {
        title = "Varusteen asettaminen",
        place = "Aseta ({key})",
        cancel = "Peruuta ({key})"
      }
    },
    creator = {
      title = "Luoja",
      description = "Määritä merkinnät.",
      selectJob = "Valitse työluokka.",
      empty = "Ei vielä määritettyjä {entryLabelPlural}.",
      keyboardHint = "Käytä nuolinäppäimiä listassa ja toiminnoissa liikkumiseen.",
      placementHelp = "Nuolet liikuttavat, PageUp/PageDown korkeus, Q/E pyörittävät, Enter sijoittaa, Backspace peruu.",
      editTitle = "Markerit",
      editSubtitle = "Käytä karttaneulaa tallentaaksesi nykyiset koordinaattisi.",
      editKeyboardHint = "Nuolinäppäimet: valitse markkeri, vasen/oikea: Aseta/Tyhjennä, Enter: suorita, Backspace: takaisin.",
      missingEntry = "Merkintää ei löytynyt.",
      actions = {
        add = "Lisää {label}",
        newEntry = "Uusi {entryLabel}"
      },
      status = {
        set = "Asetettu",
        unset = "Asettamatta"
      },
      modals = {
        createTitle = "Luo {entryLabel}",
        createButton = "Luo {entryLabel}",
        renameTitle = "Nimeä uudelleen {entryLabel}",
        renameButton = "Tallenna nimi",
        deleteTitle = "Poista {entryLabel}",
        deleteMessage = "Haluatko varmasti poistaa kohteen {name}?",
        deleteConfirmLabel = "Poista",
        deleteCancelLabel = "Peruuta"
      }
    },
    management = {
      noAccess = "Sinulla ei ole pääsyä hallintatyökaluihin.",
      refunds = {
        description = "Tarkista tämän päivän ja eilisen kuolemat ja hyvitä poistetut tavarat.",
        refreshButton = "Päivitä",
        updatedAt = "Päivitetty {time}",
        errors = {
          loadFailed = "Hyvitysten lataaminen epäonnistui."
        }
      },
      dashboard = {
        sidebarTitle = "Hallintapaneeli",
        menuTitle = "Yleiskatsaus",
        onlineMembers = "Jäseniä paikalla",
        funds = "Varat",
        onDuty = "Vuorossa",
        offDuty = "Vapaalla",
        mostActive = "Aktiivisimmat"
      },
      finance = {
        sidebarTitle = "Rahavirta",
        menuTitle = "Talouden yleiskatsaus",
        expenseCategories = "Menoluokat",
        revenueCategories = "Tuloluokat",
        kpis = {
          revenue = "Tulot",
          expenses = "Menot",
          profit = "Voitto"
        },
        cashFlow = "Rahavirran kehitys",
        lastUpdated = "Päivitetty {time}",
        emptyStates = {
          timeline = "Ei tapahtumia tällä ajanjaksolla.",
          categories = "Ei kategoriatietoja vielä."
        },
        categories = {
          deposits = "Talletukset",
          withdrawals = "Nostot",
          supplies = "Tarvikkeet",
          vehicles = "Ajoneuvot",
          salaries = "Palkat",
          bonuses = "Bonukset"
        },
        errors = {
          load = "Talouden tilannekatsauksen lataaminen epäonnistui."
        }
      },
      transactions = {
        sidebarTitle = "Varat",
        menuTitle = "Varojen hallinta",
        currentBalance = "Nykyinen saldo",
        withdrawButton = "Nosta",
        depositButton = "Talleta",
        recentTransactions = "Viimeisimmät tapahtumat",
        columnNames = {
          timestamp = "Aikaleima",
          name = "Nimi",
          action = "Toiminto",
          content = "Määrä"
        },
        actions = {
          deposited = "Rahaa talletettu",
          withdrawn = "Rahaa nostettu",
          supplies_purchased = "Tarvikkeita ostettu",
          vehicle_purchased = "Ajoneuvo ostettu",
          vehicle_sold = "Ajoneuvo myyty",
          salary_paid = "Palkka maksettu",
          bonus_paid = "Bonus maksettu"
        },
        errors = {
          load = "Tapahtumien lataaminen epäonnistui.",
          failed = "Tapahtuma epäonnistui."
        }
      },
      billingSpecs = {
        sidebarTitle = "Laskutusasetukset",
        menuTitle = "Laskun syyt",
        description = "Määritä syyt, joita henkilökunta voi valita laskuttaessaan, ja niiden oletushinnat.",
        reasonColumn = "Syy",
        priceColumn = "Hinta",
        actionsColumn = "Toiminnot",
        reasonLabel = "Laskun syy",
        reasonPlaceholder = "esim. Partiovaste",
        amountLabel = "Oletushinta",
        emptyState = "Ei laskun syitä lisätty vielä.",
        addButton = "Lisää",
        addFirstButton = "Luo ensimmäinen syy",
        deleteButton = "Poista",
        saveButton = "Tallenna",
        reasonRequired = "Anna syy tallentaaksesi rivin.",
        saveSuccess = "Laskutusasetukset päivitetty.",
        saveError = "Laskutusasetusten tallentaminen epäonnistui.",
        loadError = "Laskutusasetusten lataaminen epäonnistui.",
        updatedAt = "Päivitetty {time}"
      },
      members = {
        sidebarTitle = "Jäsenet",
        menuTitle = "Nimiluettelo",
        inviteTitle = "Kutsu ryhmittymään",
        inviteSubtitle = "Valitse pelaaja ja anna hänelle aloitusarvo.",
        selectPlayer = "Valitse pelaaja",
        selectRank = "Valitse arvo",
        sendInvite = "Kutsu",
        columnNames = {
          name = "Nimi",
          rank = "Arvo",
          last_online = "Viimeksi paikalla",
          total_work_time = "Työaika (h)",
          actions_done = "Toiminnot suoritettu",
          actions = "Toiminnot"
        },
        bonus = {
          title = "Maksa bonus",
          confirmButton = "Maksa bonus",
          actionLabel = "Bonus",
          invalidAmount = "Anna kelvollinen bonussumma.",
          failed = "Bonuksen maksu epäonnistui.",
          unexpectedError = "Odottamaton virhe bonusta maksettaessa."
        },
        errors = {
          load = "Jäsenten hakeminen epäonnistui.",
          loadUnexpected = "Jäsentietojen hakeminen epäonnistui odottamattoman virheen vuoksi.",
          invite = "Kutsun lähettäminen epäonnistui.",
          inviteUnexpected = "Kutsun aikana ilmeni odottamaton virhe."
        }
      },
      roles = {
        sidebarTitle = "Roolit",
        menuTitle = "Roolit",
        createRoleButton = "Luo rooli",
        columnNames = {
          grade = "Taso",
          label = "Roolin nimi",
          salary = "Palkka",
          salaryInterval = "Väli (min)",
          actions = "Toiminnot"
        },
        editMenu = {
          title = "Muokkaa roolia",
          createTitle = "Luo rooli",
          createSaveButton = "Luo",
          newRoleBreadcrumb = "Uusi rooli",
          unnamedRole = "Nimetön rooli",
          gradeMeta = "Taso {grade}",
          backButton = "Takaisin",
          saveButton = "Tallenna",
          general = "Yleiset",
          permissions = "Oikeudet",
          salary = "Palkka",
          salaryDescription = "Aseta tämän roolin palkka.",
          salaryInterval = "Maksuväli",
          salaryIntervalDescription = "Valitse kuinka usein rooli saa palkan (työminuuteissa).",
          roleName = "Roolin nimi",
          roleNameDescription = "Aseta roolin nimi.",
          highestRoleInfo = "Tämä on korkein arvo ja sillä on automaattisesti kaikki oikeudet."
        },
        unsavedChanges = {
          title = "Tallentamattomat muutokset.",
          message = "Tällä roolilla on tallentamattomia muutoksia. Poistu silti ja hylkää muutokset?",
          confirm = "Poistu tallentamatta",
          cancel = "Jatka muokkaamista"
        },
        permissionsEmpty = "Oikeuksia ei löytynyt.",
        permissionEntries = {
          viewLogs = {
            label = "Tarkastele lokeja",
            description = "Sallii työ- ja tapahtumalokien lukemisen."
          },
          manageRoles = {
            label = "Hallitse rooleja",
            description = "Sallii arvojen luomisen, muokkaamisen, siirtämisen ja poistamisen."
          },
          manageMembers = {
            label = "Hallitse jäseniä",
            description = "Sallii ylentämisen, alentamisen, erottamisen ja bonusten maksamisen."
          },
          manageWarehouse = {
            label = "Pääsy varastoon",
            description = "Sallii jaetun varaston käytön."
          },
          manageMoney = {
            label = "Hallitse varoja",
            description = "Sallii ryhmittymän rahojen tallettamisen ja nostamisen."
          },
          editOutfits = {
            label = "Muokkaa asuja",
            description = "Sallii tallennettujen asujen päivittämisen."
          },
          createOutfits = {
            label = "Luo asuja",
            description = "Sallii uusien asujen luomisen."
          },
          deleteOutfits = {
            label = "Poista asuja",
            description = "Sallii tallennettujen asujen poistamisen."
          },
          purchaseSupplies = {
            label = "Tilaa tarvikkeita",
            description = "Sallii varusteiden tilaamisen tukkutoimittajalta ryhmittymän varoilla."
          },
          purchaseVehicles = {
            label = "Osta ajoneuvoja",
            description = "Sallii uusien kaluston ajoneuvojen ostamisen ryhmittymän varoilla."
          },
          garageVehicles = {
            label = "Tallin ajoneuvorajoitukset",
            description = "Valitse mitä ajoneuvoja tämä rooli ei voi käyttää tallissa."
          },
          tabletApps = {
            label = "Tablettisovellusten rajoitukset",
            description = "Valitse mitä sovelluksia tämä rooli ei voi käyttää tabletissa."
          },
          all = {
            label = "Täydet oikeudet",
            description = "Myöntää kaikki oikeudet muista valinnoista riippumatta."
          }
        },
        permissionOptions = {
          storageHint = "Lisää tavarat, joita tämä rooli ei voi poistaa.",
          storageItemsTitle = "Rajoitetut tavarat",
          storageWeaponsTitle = "Rajoitetut aseet",
          allowedWeaponsTitle = "Sallitut aseet",
          weaponHint = "Lisää aseet, joihin tällä roolilla on pääsy.",
          vehicleHint = "Valitse ajoneuvot, joihin tällä roolilla ei ole pääsyä.",
          appHint = "Valitse sovellukset, joihin tällä roolilla ei ole pääsyä.",
          itemPlaceholder = "Kirjoita lisätäksesi tavara",
          weaponPlaceholder = "Kirjoita lisätäksesi ase",
          weaponSelectPlaceholder = "Valitse ase",
          vehiclePlaceholder = "Valitse ajoneuvo",
          appPlaceholder = "Valitse sovellus",
          addButton = "Lisää",
          emptyVehicles = "Ei ajoneuvoja saatavilla.",
          emptyApps = "Ei sovelluksia saatavilla.",
          errors = {
            empty = "Anna arvo.",
            duplicate = "Vaihtoehto on jo lisätty.",
            itemMissing = "Tavaraa ei ole olemassa.",
            vehicleMissing = "Valitse ajoneuvo.",
            appMissing = "Valitse sovellus.",
            weaponMissing = "Asetta ei ole olemassa.",
            weaponSelectMissing = "Valitse ase."
          }
        },
        errors = {
          save = "Rolin tallentaminen epäonnistui.",
          saveUnexpected = "Rolin tallentamisen yhteydessä tapahtunut odottamaton virhe.",
          permissionsLoad = "Käyttöoikeuksien hakeminen epäonnistui.",
          permissionsUnexpected = "Oikeuksien hakemisen yhteydessä tapahtunut odottamaton virhe."
        }
      },
      logs = {
        sidebarTitle = "Lokit",
        menuTitle = "Lokit",
        errors = {
          load = "Lokien lataaminen epäonnistui."
        },
        columnNames = {
          timestamp = "Aikaleima",
          name = "Nimi",
          action = "Toiminto",
          content = "Sisältö"
        },
        actions = {
          stored = "Tavara varastoitu",
          removed = "Tavara poistettu",
          deposited = "Rahaa talletettu",
          withdrawn = "Rahaa nostettu",
          outfit_created = "Asu luotu",
          outfit_updated = "Asu päivitetty",
          outfit_deleted = "Asu poistettu",
          permissions_updated = "Oikeudet päivitetty",
          invite_sent = "Kutsu lähetetty",
          invite_accepted = "Kutsu hyväksytty",
          invite_declined = "Kutsu hylätty",
          bonus_paid = "Bonus maksettu",
          member_promoted = "Jäsen ylennetty",
          member_demoted = "Jäsen alennettu",
          member_fired = "Jäsen erotettu",
          supplies_purchased = "Tarvikkeita ostettu",
          vehicle_purchased = "Ajoneuvo ostettu",
          vehicle_sold = "Ajoneuvo myyty",
          salary_paid = "Palkka maksettu"
        }
      },
      dialogs = {
        deleteOutfit = {
          title = "Poista asu",
          message = "Haluatko varmasti poistaa asun \"{name}\"?",
          confirm = "Poista asu",
          cancel = "Peruuta"
        }
      }
    },
    cloakroom = {
      title = "Pukuhuone",
      civilianClothes = "Siviilivaatteet",
      newOutfit = "Uusi asu",
      edit = {
        save = "Tallentaa",
        rotateAlt = "Kiertää",
        outfitNameTitle = "Asukokonaisuuden nimi",
        saveOutfit = "Tallenna asukokonaisuus"
      }
    },
    tablet = {
      apps = {
        management = "Pomo-valikko",
        patients = "Potilaat",
        citizens = "Kansalaiset",
        offences = "Rikokset",
        cases = "Tapaukset",
        social_work = "Sosiaalityö",
        vehicles = "Ajoneuvot",
        weapons = "Aseet",
        prison = "Vankila",
        warrants = "Vangitsemiskäskyt",
        bolos = "BOLOt",
        conditions = "Tilat",
        reports = "Raportit",
        camera = "Kamera",
        gallery = "Galleria",
        map = "Kartta",
        chat = "keskustella",
        calendar = "Kalenteri",
        calculator = "Laskin",
        settings = "Asetukset"
      }
    },
    common = {
      close = "Sulje",
      unknownError = "Tuntematon virhe.",
      unexpectedError = "Odottamaton virhe tapahtui.",
      time = {
        now = "Nyt"
      },
      pagination = {
        prev = "Edellinen",
        next = "Seuraava",
        page = "Sivu {current} / {total}"
      },
      gallery = {
        title = "Galleria",
        subtitle = "Valitse kuva tai video.",
        loading = "Ladataan galleriaa...",
        empty = "Galleriassa ei ole kohteita.",
        photoAlt = "Galleriamedia"
      },
      back = "Palaa",
      confirm = {
        unsavedTitle = "Tallentamattomia muutoksia",
        unsavedMessage = "Haluatko hylätä muutokset vai tallentaa ne ennen poistumista?",
        unsavedDiscard = "Hylkää muutokset",
        unsavedSave = "Tallenna muutokset"
      }
    },
    reports = {
      unknown = "Tuntematon"
    },
    publicForms = {
      complaint = {
        fields = {
          fullName = "Koko nimi",
          phone = "Puhelinnumero",
          incidentDate = "Tapahtumapäivä",
          incidentTime = "Tapahtuma-aika",
          location = "Tapahtumapaikka",
          officerName = "Henkilökunnan nimi",
          badgeNumber = "Virkamerkin numero",
          description = "Valituksen tiedot",
          witnesses = "Todistajat",
          desiredOutcome = "Toivottu ratkaisu",
          email = "Sähköpostiosoite",
          address = "Kotiosoite",
          signature = "Allekirjoitus"
        },
        title = "Kansalaisvalitus",
        subtitle = "Raportoi henkilökunnan käytöksestä tai viraston toiminnasta.",
        placeholders = {
          fullName = "Kirjoita virallinen nimesi",
          phone = "###-###-####",
          email = "nimi@email.fi",
          address = "Katuosoite, kaupunki",
          incidentDate = "PP.KK.VVVV",
          incidentTime = "HH:MM",
          location = "Missä se tapahtui?",
          officerName = "Henkilön nimi tai yksikkö",
          badgeNumber = "Virkamerkin numero, jos tiedossa",
          description = "Kuvaile tapahtuma yksityiskohtaisesti...",
          witnesses = "Luettele todistajat tai muut osapuolet",
          desiredOutcome = "Mitä toivot ratkaisuksi?",
          signature = "Kirjoita koko nimesi"
        }
      },
      application = {
        fields = {
          fullName = "Koko nimi",
          dateOfBirth = "Syntymäaika",
          phone = "Puhelinnumero",
          experience = "Asiaankuuluva kokemus",
          availability = "Käytettävyys",
          whyJoin = "Miksi haluat liittyä?",
          email = "Sähköpostiosoite",
          address = "Kotiosoite",
          education = "Koulutus",
          certifications = "Sertifikaatit",
          references = "Suosittelijat",
          signature = "Allekirjoitus"
        },
        title = "Työhakemus",
        subtitle = "Hae mukaan osastolle.",
        placeholders = {
          fullName = "Kirjoita virallinen nimesi",
          dateOfBirth = "PP.KK.VVVV",
          phone = "###-###-####",
          email = "nimi@email.fi",
          address = "Katuosoite, kaupunki",
          education = "Lukio, akatemia tai korkeakoulu",
          experience = "Lainvalvonta, vartiointi tai palvelualat",
          certifications = "Ensiapu, aseet tai vastaava koulutus",
          availability = "Toivotut vuorot tai aloituspäivä",
          whyJoin = "Kerro, miksi haluat työskennellä täällä...",
          references = "Nimet ja yhteystiedot",
          signature = "Kirjoita koko nimesi"
        }
      },
      title = "Julkiset lomakkeet",
      subtitle = "Jätä valitus tai työhakemus.",
      stationLabel = "Asema",
      dateLabel = "Päivämäärä",
      timeLabel = "Aika",
      stamp = {
        label = "PD",
        complaint = "VAL",
        application = "HAK"
      },
      tabs = {
        complaint = "Valituslomake",
        application = "Työhakemus",
        myForms = "Omat lähetykset"
      },
      myForms = {
        title = "Omat lähetykset",
        empty = "Et ole vielä lähettänyt lomakkeita.",
        back = "Takaisin",
        notesTitle = "Vastaukset",
        notesEmpty = "Ei vastauksia vielä.",
        statusNew = "Odottaa",
        statusReviewed = "Tarkistettu",
        statusArchived = "Arkistoitu"
      },
      actions = {
        submit = "Lähetä lomake",
        clear = "Tyhjennä kentät",
        close = "Sulje"
      },
      status = {
        submitting = "Lähetetään...",
        success = "Lomake lähetetty onnistuneesti.",
        error = "Lomakkeen lähettäminen epäonnistui."
      },
      errors = {
        required = "Täytä pakolliset kentät."
      }
    },
    tabletForms = {
      title = "Lomakkeet",
      eyebrow = "Julkiset lomakkeet",
      listed = "listattu",
      filters = {
        label = "Tyyppi",
        all = "Kaikki lomakkeet",
        complaint = "Valitukset",
        application = "Hakemukset"
      },
      search = {
        placeholder = "Etsi nimellä, asemalla tai id:llä"
      },
      status = {
        new = "Uusi",
        reviewed = "Tarkistettu",
        archived = "Arkistoitu"
      },
      state = {
        empty = "Ei lomakkeita valituilla suodattimilla.",
        loading = "Ladataan lomakkeita...",
        saving = "Tallennetaan..."
      },
      errors = {
        load = "Lomakkeiden lataaminen epäonnistui.",
        update = "Lomakkeen tilan päivitys epäonnistui."
      },
      detail = {
        complaintTitle = "Valituksen tiedot",
        applicationTitle = "Hakemuksen tiedot"
      },
      actions = {
        refresh = "Päivitä",
        markReviewed = "Merkitse tarkistetuksi",
        archive = "Arkistoi",
        back = "Takaisin listaan"
      },
      notifications = {
        timeNow = "Nyt",
        complaintType = "Valitus",
        applicationType = "Hakemus",
        app = "Lomakkeet",
        title = "Uusi julkinen lomake",
        body = "{type} lähettäjältä {name} ({station})"
      },
      fields = {
        type = "Lomaketyyppi",
        id = "Lomakkeen ID",
        station = "Asema",
        submitted = "Lähetetty",
        status = "Tila",
        contact = "Yhteystiedot"
      },
      notes = {
        title = "Muistiinpanot",
        loading = "Ladataan muistiinpanoja...",
        empty = "Ei muistiinpanoja vielä.",
        placeholder = "Kirjoita muistiinpano...",
        visibleBadge = "Kansalaiselle näkyvä",
        visibleToCitizen = "Näkyy kansalaiselle",
        submit = "Lisää muistiinpano"
      }
    },
    gallery = {
      eyebrow = "Todisteet",
      title = "Kuvat",
      filters = {
        all = "Kaikki",
        camera = "Kamera",
        speedcam = "Nopeuskamerat",
        cctv = "Valvontakamerat",
        mugshot = "Pidätyskuvat"
      },
      labels = {
        count = "{count} kuvaa",
        sort = "Uusin ensin",
        photoAlt = "Galleriakuva",
        photoFullAlt = "Täysikokoinen kuva",
        takenBy = "Kuvaaja",
        captured = "Taltioitu",
        unknownTime = "Tuntematon aika",
        unknownTakenBy = "Tuntematon"
      },
      state = {
        loading = "Ladataan kuvia...",
        emptyTitle = "Ei kuvia vielä.",
        emptySubtitle = "Viimeisimmät otoksesi ilmestyvät tänne."
      },
      errors = {
        load = "Gallerian lataaminen epäonnistui.",
        delete = "Kuvan poistaminen epäonnistui."
      },
      confirm = {
        deleteTitle = "Poista kuva",
        deleteMessage = "Poistetaanko tämä kuva? Tätä ei voi perua.",
        deleteConfirm = "Poista",
        deleteCancel = "Peruuta"
      },
      mock = {
        caption = "TESTIKUVA"
      }
    },
    camera = {
      help = {
        focused = "Paina Space salliaksesi liikkumisen.",
        blurred = "Paina Space käyttääksesi tablettia uudelleen."
      },
      mode = {
        photo = "Kuva",
        video = "Video",
        switchPhoto = "Vaihda valokuvatilaan",
        switchVideo = "Vaihda videotilaan"
      },
      capture = {
        photo = "Ota kuva"
      },
      queue = {
        title = "Jono",
        empty = "Ei vielä yhtään latausta.",
        kind = {
          photo = "Kuvan lataus",
          video = "Videon lataus"
        },
        status = {
          loading = "Ladataan...",
          success = "Tallennettu",
          error = "Epäonnistunut"
        }
      },
      preview = {
        lastShot = "Viimeisin otos",
        lastCapture = "Viimeisin tallenne"
      },
      record = {
        start = "Aloita tallennus",
        stop = "Lopeta tallennus",
        live = "Nauhoittaa",
        saving = "Videon tallentaminen",
        name = "Kamerapätkä",
        description = "Tabletin nauhoittaminen",
        errors = {
          config = "Latausasetusten puuttuminen",
          upload = "Latauksen epäonnistuminen",
          save = "Videon tallentamisen epäonnistuminen",
          unsupported = "Tallennus ei ole tuettu",
          empty = "Videota ei ole vielä tallennettu",
          busy = "Nauhoitus on käynnissä",
          notRecording = "Tallennus on jo pysäytetty."
        }
      },
      errors = {
        timeout = "Lähetys aikakatkaistiin.",
        capture = "Kuvan ottamisen aikana ilmeni odottamaton virhe.",
        upload = "Lähetys epäonnistui."
      }
    },
    cctv = {
      eyebrow = "Valvontaverkko",
      title = "Valvontakamera",
      listed = "Listattu",
      actions = {
        refresh = "päivittää"
      },
      search = {
        placeholder = "Etsi kameroita nimen, tunnuksen tai sijainnin perusteella."
      },
      filters = {
        all = "Kaikki kamerat",
        bodycam = "kehokamerat",
        dashcam = "kojelautakamerat",
        cctv = "valvontakamerat",
        speedcam = "nopeuskamerat"
      },
      types = {
        bodycam = "kehokamera",
        dashcam = "kojelautakamera",
        speedcam = "nopeuskamera",
        cctv = "valvontakamera"
      },
      status = {
        online = "Yhteydessä",
        maintenance = "Huolto",
        offline = "Poissa käytöstä"
      },
      live = {
        active = "Live-lähetys aktiivinen",
        maintenance = "Lähetys keskeytetty huollon vuoksi",
        offline = "Signaali katkennut",
        placeholderTitle = "Lähetys ei ole käytettävissä",
        placeholderSubtitle = "Valitse kehokameralla varustettu työntekijä",
        speedcamPlaceholderTitle = "Nopeuskamera pois käytöstä",
        speedcamPlaceholderSubtitle = "Korjata tai vaihtaa laitteen, jotta lähetys palautuu"
      },
      labels = {
        speedcamLocation = "Tienvarsi",
        onDuty = "Työvuorossa",
        durability = "Kestävyys"
      },
      state = {
        loading = "Ladataan kameroita...",
        empty = "Kamerat eivät täsmää nykyisiin suodattimiin.",
        select = "Valitse kamera nähdäksesi sen videovirran."
      },
      controls = {
        tiltUp = "Kallistua ylöspäin",
        panLeft = "Kääntää vasemmalle",
        panRight = "Kääntää oikealle",
        tiltDown = "Kallistua alaspäin"
      },
      capture = {
        name = "CCTV - {label}",
        description = "{location} ({id})",
        saved = "Tallentaa galleriaan.",
        error = "Kuvan kaappaaminen epäonnistui.",
        action = "Kaapata",
        loading = "Kuvan kaappaaminen..."
      },
      record = {
        name = "CCTV-klippi - {label}",
        description = "{location} ({id})",
        save = "Tallenna viimeiset {minutes} min.",
        saving = "Tallentaminen...",
        requested = "Tallennuspyyntö lähetetty.",
        saved = "Video tallennettu galleriaan.",
        errors = {
          config = "Latausasetukset puuttuvat.",
          upload = "Lataus epäonnistui.",
          save = "Videon tallentaminen epäonnistui.",
          unsupported = "Tallennus ei ole tuettu.",
          empty = "Puskuri ei ole vielä käytettävissä.",
          request = "Kehonkameran videon hakeminen epäonnistui.",
          timeout = "Kehonkameran tallennus aikakatkaistiin.",
          busy = "Tallennus on varattu.",
          notRecording = "Tallennus on jo pysäytetty."
        }
      },
      waypoint = {
        set = "Reittipiste asetettu.",
        missing = "Sijaintia ei ole saatavilla."
      },
      errors = {
        load = "Kamerat eivät lataudu."
      }
    },
    chat = {
      targets = {
        allUnits = "Chatata kaikkien yksiköiden kanssa",
        centralDispatch = "Keskuslähetys"
      },
      header = {
        eyebrowRoom = "Henkilöstökanava",
        eyebrowPrivate = "Yksityislinja",
        metaRoom = "Huone",
        metaDirect = "Suora",
        metaStaff = "Henkilöstö"
      },
      sidebar = {
        eyebrow = "Viestintä",
        title = "Henkilöstöverkosto",
        groupTitle = "Ryhmäkeskustelu",
        allUnits = "Kaikki yksiköt",
        staffTitle = "Henkilökunta",
        loading = "Ladataan henkilöstöä...",
        empty = "Ei saatavilla olevaa henkilökuntaa."
      },
      staff = {
        unknownMember = "Tuntematon työntekijä",
        onDuty = "Työssä",
        offDuty = "Poissa töistä",
        grade = "Aste {level}",
        fallback = "Henkilökunta"
      },
      composer = {
        placeholderRoom = "Kirjoita yksikön päivitys...",
        placeholderDirect = "Viesti {name}...",
        pendingAlt = "Odottaa jakoa"
      },
      messages = {
        avatarAlt = "Käyttäjän {name} avatar",
        avatarFallback = "Henkilökunnan avatar",
        unknownAuthor = "Tuntematon",
        sharedEvidenceAlt = "Jaettu todiste",
        tapToExpand = "Napauta laajentaaksesi"
      },
      preview = {
        ready = "Media valmis lähetettäväksi"
      },
      profile = {
        action = "Aseta profiilikuva",
        galleryTitle = "Aseta profiilikuva",
        gallerySubtitle = "Valita kuvan tiimin profiilikuvaksi.",
        photoAlt = "Profiilikuva.",
        selfPhotoAlt = "Profiilikuva.",
        error = "Profiilikuvaa ei voi päivittää."
      },
      actions = {
        remove = "Poistaa.",
        send = "Lähettää."
      },
      state = {
        syncing = "Viestien synkronointi...",
        emptyRoom = "Ei vielä keskustelijoita.",
        emptyPrivate = "Ei vielä yksityisviestejä.",
        emptyRoomHint = "Ensimmäisenä ottaa yhteyttä yksikköön.",
        emptyPrivateHint = "Aloittaa suoran keskustelun tämän työntekijän kanssa."
      },
      errors = {
        load = "Chat-historian lataamisen epäonnistuminen.",
        send = "Viestin lähettämisen epäonnistuminen.",
        members = "Henkilöstön lataamisen epäonnistuminen."
      }
    },
    bossMenu = {
      header = {
        eyebrow = "Esimiehen valikko",
        title = "Johtaminen",
        balanceLabel = "Saldo"
      },
      state = {
        loading = "Hallintotietojen lataaminen..."
      }
    },
    tabletSettings = {
      header = {
        eyebrow = "Tablettiasetukset",
        title = "Personalisointi.",
        modeLabel = "Tila",
        modeLight = "Vaalea",
        modeDark = "Tumma"
      },
      appearance = {
        title = "Ulkoasu",
        description = "vaihtaa käyttöliittymän ulkoasua vaalean ja tumman välillä.",
        light = "Vaalea",
        dark = "Tumma"
      },
      wallpaper = {
        title = "Taustakuva",
        description = "käyttää oletusta taustakuvasta, valita galleriasta tai lisätä oma linkkisi.",
        labels = {
          default = "Oletus taustakuva",
          gallery = "Galleria-kuva",
          url = "Mukautettu URL-osoite"
        },
        useDefault = "Käyttää oletusarvoa",
        chooseGallery = "Valita gallerian kuvista",
        customUrlLabel = "Mukautettu kuvan URL-osoite",
        customUrlPlaceholder = "https://example.com/wallpaper.jpg",
        apply = "Käyttää",
        hint = "Parhaat tulokset 1920x1080 tai suuremmilla kuvilla."
      }
    },
    calendar = {
      weekdays = {
        mon = "Ma",
        tue = "Ti",
        wed = "Ke",
        thu = "To",
        fri = "Pe",
        sat = "La",
        sun = "Su"
      },
      selectedDateFallback = "valita päivämäärä",
      header = {
        eyebrow = "Yhteinen kalenteri",
        title = "Henkilöstön aikataulu",
        metaPrimary = "Näkyvissä kaikille henkilöstölle",
        metaSecondary = "Kaikki voivat lisätä merkintöjä",
        hint = "Napauta päivää lisätäksesi vuoron tai tapahtuman."
      },
      actions = {
        dayEntries = "Päivän merkinnät",
        addEntry = "Lisätä merkintä"
      },
      today = "Tänään",
      more = "+{count} lisää",
      modal = {
        addEntry = {
          eyebrow = "Lisätä merkintä",
          titleLabel = "Otsikko",
          titlePlaceholder = "Vuoropalaveri, koulutus, partio",
          datetimeLabel = "Päivä ja aika",
          colorLabel = "Väri",
          clear = "Tyhjentää",
          submit = "Lisätä kalenteriin"
        },
        dayEntries = {
          eyebrow = "Päivämerkinnät",
          empty = "Ei vielä merkintöjä. Lisää tiedotustilaisuus tai partio jaettavaksi yksikön kanssa."
        }
      }
    },
    calculator = {
      header = {
        eyebrow = "Kenttätyökalut",
        title = "Laskin",
        modeLabel = "Tila"
      },
      keys = {
        clearAll = "AC",
        clearEntry = "CE"
      },
      mode = {
        standard = "Perus"
      },
      status = {
        resetRequired = "Nollaus vaadittu",
        ready = "Valmis"
      },
      errors = {
        error = "Virhe"
      }
    },
    tabletHome = {
      status = {
        defaultDate = "Maanantai, 1. tammikuuta"
      },
      calendar = {
        eventToday = "Tapahtuma tänään",
        eventTomorrow = "Tapahtuma huomenna",
        allDay = "Koko päivän",
        timeAt = " klo {time}"
      },
      chat = {
        messageFrom = "Viesti {name}ilta",
        newMessage = "Uusi viesti",
        authorFallback = "Henkilöstö",
        messageBody = "{author}: {message}",
        sentPhoto = "{author} lähettää kuvan.",
        sentMessage = "{author} lähettää viestin."
      },
      notifications = {
        title = "Ilmoitukset",
        clearAll = "Tyhjentää kaikki",
        empty = "Ei uusia ilmoituksia."
      }
    },
    map = {
      eyebrow = "Karttapöytä",
      title = "San Andreas-ruudukko",
      markerLabel = "Merkki",
      markerTypes = {
        label = "Karttamerkkien luettelo",
        dispatch = "Lähetys",
        officers = "Henkilökunta",
        speedcams = "Nopeusvalvontakameroita",
        vehicles = "Ajoneuvot",
        trackers = "Seurantalaiteet"
      },
      markerList = {
        listed = "Listattu",
        officersTitle = "Henkilökunnan vuorolista",
        speedcamsTitle = "Nopeusvalvontakameroiden taulu",
        vehiclesTitle = "Ajoneuvojen taulu",
        trackersTitle = "Seurantataulu",
        officersEmpty = "Ei henkilöstöä vuorossa.",
        speedcamsEmpty = "Ei nopeusvalvontakameroita saatavilla.",
        trackersEmpty = "Ei seurantalaitteita verkossa.",
        vehiclesEmpty = "Ei ajoneuvoja verkossa."
      },
      dispatch = {
        title = "Lähetys-taulu.",
        empty = "Tällä hetkellä ei lähetyksiä.",
        status = {
          active = "Aktiivinen",
          accepted = "Hyväksytty",
          done = "Suoritettu"
        },
        panelTitle = "Lähetyksen tiedot",
        statusLabel = "Tila",
        acceptedBy = "Hyväksynyt",
        doneBy = "Suoritettu",
        coords = "Koordinaatit",
        actions = {
          accept = "hyväksyä",
          done = "merkitä valmiiksi",
          delete = "poistaa"
        },
        unknown = "Tuntematon"
      },
      status = {
        available = "Saatavilla",
        busy = "olla kiireinen",
        pursuit = "olla jahtaamassa",
        offDuty = "olla vapaalla"
      },
      vehicle = {
        status = {
          active = "olla aktiivinen",
          offline = "olla pois käytöstä"
        }
      },
      tracker = {
        status = {
          active = "olla aktiivinen",
          offline = "olla pois käytöstä"
        }
      },
      speedcam = {
        status = {
          online = "olla online",
          maintenance = "olla huollossa",
          offline = "olla pois käytöstä"
        }
      },
      officerPanel = {
        title = "Henkilökunnan tiedot",
        callsign = "Kutsunimi {id}",
        rank = "Arvo",
        health = "Terveys",
        coords = "Koordinaatit",
        lastUpdateUnknown = "Juuri nyt"
      },
      speedcamPanel = {
        title = "Nopeusvalvontakameran tiedot",
        limit = "Nopeusrajoitus",
        tolerance = "Sallittu poikkeama",
        health = "Terveys",
        coords = "Koordinaatit"
      },
      vehiclePanel = {
        title = "Ajoneuvon tiedot",
        plate = "Rekisterikilpi {plate}",
        netId = "Verkko-ID",
        health = "Terveys",
        coords = "Koordinaatit"
      },
      trackerPanel = {
        title = "Seurantalaiteen tiedot",
        plate = "Rekisterikilpi {plate}",
        attachedBy = "Kiinnittänyt",
        attachedAt = "Liitetty",
        netId = "Verkon tunnus",
        status = "Tila",
        coords = "Koordinaatit"
      },
      actions = {
        openCctv = "avata CCTV",
        setWaypoint = "Aseta reittipiste"
      },
      waypoint = {
        set = "Reittipiste asetettu.",
        missing = "Sijaintia ei ole saatavilla."
      },
      styles = {
        atlas = "Kartasto",
        roads = "Tiet",
        satellite = "Satelliitti"
      },
      missing = {
        title = "Karttakuva puuttuu",
        body = "asettaa karttakuvat kansioon frontend/public/img."
      },
      signalLost = "Signaali katkennut",
      details = {
        title = "Yksityiskohdat",
        empty = "Merkkiä valita nähdäksesi yksityiskohdat"
      },
      zones = {
        title = "Poissulkualueet",
        untitled = "Nimeämätön alue",
        hint = "Klikata karttaa lisätäksesi pisteitä. Vähintään 3",
        pointCount = "{count} pistettä",
        empty = "Ei vielä poissuljettuja alueita",
        actions = {
          toggle = "Alueet",
          new = "Uusi alue",
          cancel = "Peruuttaa",
          save = "Tallentaa alue",
          undo = "kumota",
          clear = "tyhjentää",
          delete = "poistaa"
        },
        modal = {
          title = "nimetä poissulkualue",
          confirm = "tallentaa alue"
        },
        errors = {
          points = "lisätä vähintään kolme pistettä",
          nameRequired = "syöttää vyöhykkeen nimi",
          saveFailed = "poissulkualueen tallentamisen epäonnistuminen",
          deleteFailed = "poissulkualueen poistamisen epäonnistuminen"
        }
      },
      monitorZones = {
        title = "nilkan seurantalaitteen vyöhykkeet",
        untitled = "Nimetön vyöhyke",
        hint = "Napsauta karttaa lisätäksesi pisteitä. Vähintään kolme pistettä.",
        pointCount = "{count} pistettä",
        empty = "Ei valvontavyöhykkeitä vielä.",
        mode = {
          allow = "Sallittu vyöhyke",
          exclude = "Rajoitettu vyöhyke"
        },
        actions = {
          allow = "Sallittu vyöhyke",
          exclude = "Rajoitettu vyöhyke",
          cancel = "Peruuta",
          save = "Tallenna vyöhyke",
          undo = "kumota",
          clear = "tyhjentää",
          delete = "poistaa"
        },
        modal = {
          title = "nimetä valvontavyöhyke",
          confirm = "tallentaa vyöhyke"
        },
        errors = {
          points = "lisätä vähintään kolme pistettä.",
          nameRequired = "syöttää vyöhykkeen nimi",
          noMonitor = "valita nilkan seurantalaitteen",
          saveFailed = "valvontavyöhykkeen tallentamisen epäonnistuminen",
          deleteFailed = "valvontavyöhykkeen poistamisen epäonnistuminen"
        }
      },
      panic = {
        panelTitle = "Paniikin tiedot",
        triggeredBy = "Laukaisun syy",
        createdAt = "Laukaistu",
        coords = "Koordinaatit"
      },
      dev = {
        officerName = "Henkilö Avery Lane",
        callsign = "LIN-23",
        rank = "Kersantti",
        unit = "Keskipartio",
        speedcamName = "Del Perro nopeuskamera",
        vehicleName = "Yksikkö 12",
        trackerName = "Tracker ALPHA",
        trackerOfficer = "Ruizin henkilöstö",
        dispatchTitle = "Nopeuskameran vaurio",
        dispatchMessage = "Del Perro-yksikkö tarvitsee huoltoa.",
        panicOfficer = "Sinclairin henkilöstö",
        panicLocation = "Mission Row"
      }
    },
    panicNotification = {
      badge = "Paniikki",
      title = "Paniikkihälytys",
      subtitle = "{name} painoi paniikkinappia.",
      callsign = "Kutsumanimi {id}",
      locationLabel = "Sijainti",
      locationUnknown = "Tuntematon sijainti",
      hint = "Paina {key} asettaaksesi reittipisteen pelin karttaan."
    },
    incidentNotification = {
      panic = {
        title = "Paniikkihälytys",
        subtitle = "{name} painoi paniikkipainiketta."
      },
      dispatch = {
        title = "Lähetysilmoitus",
        subtitle = "{name} on jakanut uuden lähetyksen."
      },
      ping = {
        title = "Sijaintiping",
        subtitle = "{name} on jakanut reaaliaikaisen sijaintipingin."
      },
      actions = {
        openMap = {
          key = "M",
          label = "Nähdä Tablet Map -sovelluksessa"
        },
        setWaypoint = {
          key = "G",
          label = "Asettaa välietappi"
        },
        dismiss = {
          key = "Backspace",
          label = "Poistaa"
        }
      }
    },
    gradeChange = {
      promotedTitle = "Ylennys",
      demotedTitle = "Alentaminen",
      unchangedTitle = "Taso päivitetty",
      previousLabel = "Edellinen taso",
      newLabel = "Nykyinen taso",
      unknownLabel = "Ei määritetty taso",
      levelFallback = "Taso {level}"
    },
    employeeGpsJammer = {
      title = "GPS-häirintälaite",
      disabled = "GPS-häirintä ei ole käytettävissä.",
      success = "Työntekijän GPS-signaali häiritty.",
      failed = "GPS-signaalin häirintä epäonnistui.",
      targetJammed = "Työvuoro-GPS-signaaliasi häiritään.",
      errors = {
        disabled = "GPS-häirintä ei ole käytettävissä.",
        no_players = "Lähistöllä ei ole ketään.",
        too_far = "Siirry lähemmäs ennen GPS-häirintälaitteen käyttöä.",
        invalid_target = "Henkilöä ei löydy.",
        not_on_duty = "Tällä henkilöllä ei ole aktiivista työvuoro-GPS-signaalia.",
        protected_job = "Tämä työntekijän GPS-signaali on suojattu.",
        missing_item = "Tarvitset GPS-häirintälaitteen tähän.",
        cooldown = "Odota hetki ennen GPS-häirintälaitteen käyttämistä uudelleen.",
        failed = "GPS-signaalin häirintä epäonnistui.",
      },
    },
    bonusNotification = {
      title = "Bonuksen myöntäminen",
      subtitle = "Mistä: {name}",
      amountLabel = "Palkkio",
      unknownManager = "Johto"
    },
    wheelClamp = {
      attached = "Kiinnitetty pyörälukko"
    },
    search = {
      previewTitle = "Etsitään {name}",
      previewSubtitle = "Tarkastellaan omaisuutta aseiden ja kiellettyjen esineiden varalta...",
      previewCancel = "Paina X peruuttaa",
      unknownTarget = "Tuntematon"
    },
    heliCamHud = {
      title = "Heli Cam -ohjaus",
      actions = {
        toggleCam = "vaihtaa kameraa",
        vision = "kytkeä visio päälle",
        spotlight = "valokeilamuoto",
        lockTarget = "lukita kohde",
        display = "kytkeä näyttö päälle",
        takePhoto = "ottaa kuva",
        rappel = "laskeutua köydellä",
        brightness = "kirkkaus",
        radius = "Säde"
      }
    },
    jailHud = {
      title = "Aikaa jäljellä",
      trashLabel = "Roska",
      trashFull = "Kassi täynnä",
      trashDropoff = "Toimita roskikseen"
    },
    jailJobs = {
      title = "Vankilan työtehtävät",
      subtitle = "Valitse tehtävä ajanviettoon",
      actions = {
        cleaning = "Siivous",
        gardening = "Puutarhanhoito",
        carry_goods = "Tavaroiden kantaminen"
      },
      currentJob = "Nykyinen työ:",
      stop = "Lopeta työ",
      close = "Sulje",
      contraband = {
        title = "Salakuljetus",
        message = "Löysit {item}. Oletko valmis ottamaan riskin ja pitämään sen, vai heitätkö sen pois?",
        keep = "Pidä",
        toss = "Heitä pois"
      },
      boxInspect = {
        title = "Tarkista laatikko",
        message = "Sisällä löydät {item}. {description}",
        take = "Ota se",
        leave = "Jättää sen sisälle",
        close = "Sulkea"
      }
    },
    socialWork = {
      eyebrow = "Kuntapalvelu",
      title = "Sosiaalityö",
      listed = "Listattu",
      search = {
        placeholder = "Etsi nimellä tai tunnuksella"
      },
      filters = {
        all = "Kaikki",
        label = "Tila",
        placeholder = "Tila"
      },
      actions = {
        refresh = "Päivittää",
        back = "Palata luetteloon"
      },
      state = {
        loading = "Ladataan yhteisöpalvelua...",
        empty = "Yhteisöpalveluja ei löytynyt nykyisillä suodattimilla."
      },
      status = {
        active = "Aktiivinen",
        overdue = "Erääntynyt",
        completed = "Suoritettu",
        imprisoned = "Vangittu"
      },
      labels = {
        remainingShort = "Jäljellä",
        imprison = "Vankilaan tuomita",
        imprisonNotice = "Määräaika umpeutui. Vankeus edellytetään.",
        noDeadline = "Ei määräaikaa",
        expired = "Vanhentunut"
      },
      sections = {
        summary = "Palvelun yhteenveto",
        summarySubtitle = "Annettujen tehtävien yleiskatsaus"
      },
      fields = {
        name = "Nimi",
        status = "Tila",
        remaining = "Jäljellä olevat tehtävät",
        completed = "Valmiit tehtävät",
        total = "Tehtävien kokonaismäärä",
        assigned = "Vastuuhenkilö",
        deadline = "Määräaika",
        timeLeft = "Aikaa jäljellä",
        assignedBy = "Määrittäjä",
        unknown = "Tuntematon"
      },
      assign = {
        title = "Määritellä kuntapalvelustehtävä",
        subtitle = "Lähetä lähistöllä oleva pelaaja sosiaalityön tehtäviin.",
        playerLabel = "Pelaaja",
        playerPlaceholder = "Valitse pelaaja",
        taskLabel = "Tehtävät",
        taskPlaceholder = "Tehtävien määrä",
        deadlineLabel = "Aikaraja (minuuttia)",
        deadlinePlaceholder = "Valinnainen",
        submit = "Määritä",
        success = "Yhteisöpalvelu on määrätty.",
        error = "Yhteisöpalvelun määrittäminen epäonnistui."
      },
      errors = {
        load = "Yhteisöpalvelun lataaminen epäonnistui."
      },
      date = {
        unknown = "Tuntematon"
      },
      jobs = {
        title = "Yhteisöpalvelu",
        subtitle = "Valitse tehtävä suorittaaksesi tuomiosi.",
        currentJob = "Nykyinen tehtävä:",
        stop = "Lopettaa tehtävä",
        actions = {
          cleaning = "Siivota",
          carry_goods = "Kantaa tavaroita"
        }
      },
      hud = {
        title = "Yhteisöpalvelutyö",
        remaining = "Jäljellä olevat tehtävät",
        completed = "Suoritetut tehtävät",
        deadline = "Jäljellä oleva aika",
        expired = "Vanhentunut",
        trashLabel = "Roska",
        trashFull = "Kassi täynnä",
        trashDropoff = "Toimittaa roskikseen"
      }
    },
    socialWorkCreator = {
      title = "Sosiaalityön luominen",
      description = "Määritellä yhteisöpalvelukohteet ympäri kaupunkia",
      empty = "Ei vielä määriteltyjä yhteisöpalvelukohteita",
      keyboardHint = "Käyttää nuolinäppäimiä luettelon ja toimintojen selaamiseen",
      editTitle = "Sosiaalityön merkit",
      editSubtitle = "Tallentaa nykyiset koordinaatit karttamerkin napilla",
      editKeyboardHint = "Käyttää nuolinäppäimiä merkin valitsemiseen, vasenta tai oikeaa valita Aseta tai Poista, Enter suorittaa sen, Backspace palauttaa",
      missingEntry = "Sosiaalityön kohdetta ei löytynyt",
      actions = {
        newSite = "Uusi kohde"
      },
      status = {
        set = "asettaa",
        unset = "poistaa"
      },
      markers = {
        social_work_job_npc = "työ-NPC",
        social_work_dumpster = "roskis",
        social_work_box_dropoff = "kantaa toimituspaikkaan"
      },
      modals = {
        createTitle = "luoda sivusto",
        createButton = "luoda sivusto",
        renameTitle = "nimetä sivusto",
        renameButton = "tallentaa nimen",
        deleteTitle = "poistaa sivuston",
        deleteMessage = "Haluatko todella poistaa {name}?",
        deleteConfirmLabel = "Poistaa",
        deleteCancelLabel = "Peruuttaa"
      }
    },
    impoundCreator = {
      title = "Takavarikointialueen luominen",
      description = "Takavarikointialueiden sijaintien ja spawnauspisteiden määrittäminen",
      empty = "Ei takavarikointialueita vielä määritetty.",
      keyboardHint = "Nuolinäppäinten käyttämisen avulla selata listaa ja toimintoja.",
      editTitle = "Takavarikointimerkit",
      editSubtitle = "Kartan pin-napin käyttämisen avulla tallentaa nykyiset koordinaatit.",
      editKeyboardHint = "Nuolinäppäinten käyttämisen avulla valita merkki, vasen- tai oikean näppäimen avulla valita Aseta/Tyhennä/Poista, Enter suorittaa sen, Backspace palauttaa takaisin. Siirtyä listan ohi päästäksesi Lisää-painikkeisiin.",
      missingEntry = "takavarikointialue ei löytynyt.",
      actions = {
        newLot = "uusi takavarikointialue.",
        add = {
          impound_delivery = "lisätä palautuspiste.",
          impound_spawn = "lisätä spawn-piste."
        }
      },
      status = {
        set = "asettaa.",
        unset = "poistaa asetuksen."
      },
      markers = {
        impound_lot = "takavarikointialue.",
        impound_spawn = "ilmestymispiste.",
        impound_delivery = "toimituspiste."
      },
      modals = {
        createTitle = "luoda takavarikointialue.",
        createButton = "Luo varastopaikka",
        renameTitle = "Nimeä varastopaikka uudelleen",
        renameButton = "Tallenna nimi",
        deleteTitle = "Poista varastopaikka",
        deleteMessage = "Haluatko varmasti poistaa {name}?",
        deleteConfirmLabel = "Poista",
        deleteCancelLabel = "Peruuta"
      }
    },
    impoundStorage = {
      title = "Pidätysvarasto",
      subtitle = "Tilata varastoidut ajoneuvot toimitettavaksi varastopaikalle.",
      empty = "Tällä varastopaikalla ei ole varastoituneita ajoneuvoja.",
      emptyAll = "Ei takavarikoituja ajoneuvoja löytynyt.",
      unknownModel = "Tuntematon",
      unknownLot = "Tuntematon",
      sections = {
        impounds = "Aktiiviset takavarikot",
        stored = "Varastoidut ajoneuvot"
      },
      columns = {
        plate = "Rekisterikilpi",
        model = "Malli",
        stored = "Tallennettu",
        lot = "Piha",
        status = "Tila",
        fee = "Varastointimaksu"
      },
      actions = {
        deliver = "toimituksen tilaaminen",
        allowPickup = "noutamisen salliminen",
        seize = "takavarikoiduksi merkitseminen",
        seized = "takavarikoitu",
        close = "Sulkea",
        refresh = "päivittää"
      },
      status = {
        pickup = "Nouto sallittu",
        seized = "Takavarikoitu"
      },
      time = {
        days = "{count} päivää"
      },
      errors = {
        load = "Tallennettujen ajoneuvojen lataamisen epäonnistuminen",
        deliver = "Toimituksen tilaamisen epäonnistuminen",
        seized = "Tämä ajoneuvo on takavarikoitu tutkintaa varten",
        update = "Takavarikon tilan päivittämisen epäonnistuminen"
      }
    },
    impoundDecision = {
      title = "Takavarikon päätös",
      message = "Päättää, voiko {vehicle} noutaa tai takavarikoida tutkintaa varten",
      vehicleFallback = "Tämä ajoneuvo",
      allowPickup = "Sallia nouto",
      seize = "Takavarikoida tutkintaa varten"
    },
    jailCreator = {
      title = "Vankilan luoja",
      description = "Asettaa vankilan spawn-pisteet ja hallita sijainteja.",
      empty = "Ei vielä määritettyjä vankiloita.",
      keyboardHint = "Käyttää nuolinäppäimiä listan ja toimintojen navigointiin.",
      editTitle = "Vankilamerkit",
      editSubtitle = "Käyttää karttapainiketta nykyisten koordinaattien tallentamiseen.",
      editKeyboardHint = "Käyttää nuolinäppäimiä merkin valitsemiseen, vasen/oikea valitsemaan Aseta/Tyhennä/Poista, Enter suorittaa sen, Backspace palaa takaisin. Siirry listan ohi päästäksesi Lisää-painikkeisiin.",
      missingEntry = "Vankilaa ei löytynyt.",
      actions = {
        newJail = "Uusi vankila"
      },
      modals = {
        createTitle = "Luo vankila",
        createButton = "Luo vankila",
        renameTitle = "Nimeä vankila uudelleen",
        renameButton = "Tallenna nimi",
        deleteTitle = "Poista vankila",
        deleteMessage = "Haluatko todella poistaa {name}?",
        deleteConfirmLabel = "Poista",
        deleteCancelLabel = "Peruuta"
      }
    },
    jailInmates = {
      title = "Vankien vaihto",
      close = "Sulje",
      trade = "Tee kauppa",
      requiredLabel = "Sinä annat",
      rewardLabel = "saada",
      acceptedLabel = "hyväksyä",
      contrabandLabel = "salakuljetetut tavarat",
      npc = {
        alcoholic = "osaston juoppo",
        drugDealer = "pyykkihuoneen kauppias",
        doctor = "vankilalääkäri",
        canteen = "kanttiin kokki"
      },
      dialogs = {
        alcoholic = {
          one = "Kerran vaihdoin jälkiruokani moppiin. Elämäni paras päivä.",
          two = "Jos täällä olisi baari, olisin kuukauden työntekijä.",
          three = "Onko sinulla mitään, joka haisee puhtaille lattioille ja huonoille päätöksille?",
          four = "Kutsua sitä vankilatuoksuksi. Kutsua sitä puhdistusalkoholiksi."
        },
        drugDealer = {
          one = "Löytääkö mitään tulista roskiksesta? Maksaa savukkeilla.",
          two = "Puhua hiljaa. Vahtijat luulevat minun olevan kirjakerho.",
          three = "Tuoda minulle salakuljetettua tavaraa, ja tehdä päivästäsi savukkeiksi.",
          four = "Roska kätkee aarteita. Olen aarteiden arvioija."
        },
        doctor = {
          one = "Pysy paikoillasi. Tämä on nopea.",
          two = "Ei veloitusta tänään. Pysy poissa vaikeuksista.",
          three = "Näytät karulta. Anna minun parantaa sinut.",
          four = "Klinikan aukioloajat eivät lopu täällä."
        },
        canteen = {
          one = "Tänään tuore tarjotin. Jonotkaa ja pysykää liikkeessä.",
          two = "Haluta lämpimän aterian vai luennon?",
          three = "Hyvä käytös saa toisen annoksen. Enimmäkseen.",
          four = "Olen nähnyt pahempaa ruokahalua."
        }
      },
      doctor = {
        costLabel = "Hinta",
        rewardLabel = "Hoito",
        actionLabel = "Hakea hoitoa",
        costValue = "Ilmainen",
        rewardValue = "Kokonaishoito"
      },
      canteen = {
        costLabel = "Hinta",
        rewardLabel = "Ateria",
        actionLabel = "ottaa ateriaa",
        costValue = "Ilmainen",
        rewardValue = "Ruokapaketti"
      },
      items = {
        cleaning_alcohol = "Desinfiointialkoholi",
        cigarettes = "Savukkeet",
        coke = "Kola",
        weed = "Kannabis",
        burger = "Hampurilainen",
        water = "Vesi"
      }
    },
    invites = {
      title = "Työtarjous",
      description = "Liittyä {job} tehtävään roolissa {role}??",
      invitedBy = "Kutsuttu {name}",
      expires = "Tämä tarjous vanhenee pian.",
      accept = "Hyväksyä",
      decline = "Kieltäytyä",
      errors = {
        missing = "Kutsu ei ole käytettävissä.",
        failed = "Kutsuun vastaaminen epäonnistui."
      }
    },
    stationCreator = {
      title = "Aseman luoja",
      description = "Määritä aseman merkkien sijainnit.",
      empty = "Ei asemia ole vielä määritelty.",
      keyboardHint = "Valitse ylös-/alas-nuolilla, vaihda toimintoja vasemman/oikean nuolinäppäimen avulla, vahvista Enterillä, sulje Backspacellä.",
      editTitle = "Aseman merkit",
      editSubtitle = "Käytä kartan pin -painiketta tallentaaksesi nykyiset koordinaatit.",
      editKeyboardHint = "Käytä ylös-/alas-nuolia valitaksesi merkin, vasemman/oikean nuolinäppäimen avulla valitse Aseta/Tyhennä/Poista, suorita Enterillä, Backspace vie takaisin.",
      sections = {
        markers = "Merkit",
        zone = "Vankila-alue"
      },
      zone = {
        subtitle = "Lisää vyöhykkeen pisteitä määrittämään vankilan rajan.",
        hint = "Lisää pisteitä kartan pin -painikkeella. Poista pisteet roskakorin kuvakkeella.",
        empty = "Vankila-alueelle ei ole vielä pisteitä.",
        pointLabel = "Aluepiste {index}",
        actions = {
          add = "lisätä aluepistettä",
          update = "päivittää",
          clear = "tyhjentää alue"
        }
      },
      missingStation = "asema ei löytynyt",
      actions = {
        newStation = "luoda uuden aseman",
        editJobBlip = "Muokkaa työmerkkiä",
        newJail = "luoda uuden vankilan",
        add = {
          wardrobe = "lisätä vaatekaapin merkki",
          garage_vehicle_menu = "lisätä ajoneuvovaraston vuorovaikutus",
          garage_vehicle_spawn = "lisätä ajoneuvovaraston spawn",
          garage_vehicle_park = "lisätä ajoneuvovaraston pysäköinti",
          garage_helicopter_menu = "Lisätä helikopterikentän vuorovaikutus",
          garage_helicopter_spawn = "Lisätä helikopterikentän spawnaus",
          garage_helicopter_park = "Lisätä helikopterikentän pysäköinti",
          garage_boat_menu = "Lisätä laiturin vuorovaikutus",
          garage_boat_spawn = "Lisätä laiturin spawnaus",
          garage_boat_park = "Lisätä laiturin pysäköinti",
          boss_menu = "Lisätä pomon karttamerkki",
          wholesale_shop = "Lisätä tukkukaupan karttamerkki",
          duty_terminal = "Lisätä päivystys-terminaali karttamerkki",
          public_forms = "Lisätä julkisten lomakkeiden kioski",
          jail_solitary_cell = "lisätä eristyssolu"
        }
      },
      status = {
        set = "asettaa",
        unset = "poistaa asetuksen"
      },
      markers = {
        position = "aseman sijainti",
        storage = "varasto",
        locker = "lokero",
        wardrobe = "vaatekaappi",
        duty_terminal = "velvollisuuspääte",
        public_forms = "julkisten lomakkeiden kioski",
        boss_menu = "pomon valikko",
        garage_vehicle_menu = "vuorovaikuttaa ajoneuvovaraston kanssa",
        garage_vehicle_spawn = "luoda ajoneuvovaraston",
        garage_vehicle_park = "ajoneuvovaraston pysäköinti",
        garage_helicopter_menu = "vuorovaikuttaa helikopterikentän kanssa",
        garage_helicopter_spawn = "luoda helikopterikenttä",
        garage_helicopter_park = "helikopterikentän pysäköinti",
        garage_boat_menu = "vuorovaikuttaa laiturin kanssa",
        garage_boat_spawn = "laiturin luominen",
        garage_boat_park = "laiturin pysäköinti",
        wholesale_shop = "tukkukauppa",
        jail_spawn = "Vankilan spawnaus",
        jail_release = "Vapautuspiste",
        jail_menu = "Vankilaterminaali",
        jail_job_npc = "Vankilan työ-NPC",
        jail_inmate_alcoholic = "Vanki: Alkoholisti",
        jail_inmate_drugdealer = "Vanki: Huumekauppias",
        jail_inmate_doctor = "Vanki: Lääkäri",
        jail_canteen_cook = "Ruokalan kokki",
        jail_confiscated_return = "Takavarikoidut tavarat",
        jail_dumpster = "Vankilan roskasäiliö",
        jail_box_dropoff = "Toimituspiste",
        jail_electric_box = "Sähkökaappi",
        jail_fence_cut = "aidan katkaisupiste",
        jail_fence_exit = "aitojen uloskäynti",
        jail_solitary_cell = "eristyshuone"
      },
      modals = {
        createTitle = "Luo asema",
        createButton = "Luo asema",
        renameTitle = "Nimeä asema uudelleen",
        renameButton = "Tallenna nimi",
        deleteTitle = "Poista asema",
        deleteMessage = "Haluatko varmasti poistaa {name}?",
        deleteConfirmLabel = "poistaa",
        deleteCancelLabel = "peruuttaa",
        jobBlipTitle = "Työmerkki: {job}",
        jobBlipMessage = "Säädä asemamerkki tälle työlle. Poista käytöstä, jos tällä työllä ei tule olla asemamerkkiä.",
        jobBlipSave = "Tallenna merkki",
        jobBlipReset = "Nollaa",
        jobBlipInvalidNumber = "Virheellinen arvo kentälle {field}."
      },
      blip = {
        enabled = "Näytä merkki",
        useStationName = "Liitä aseman nimi",
        shortRange = "Lyhyt kantama",
        name = "Nimike",
        sprite = "Kuvake",
        color = "Väri",
        scale = "Koko",
        display = "Näyttötila"
      }
    },
    jailAssign = {
      title = "lähettää vankilaan",
      selectPlayer = "valita pelaaja",
      selectPlayerPlaceholder = "valita pelaaja",
      selectJail = "valita vankila",
      selectJailPlaceholder = "valita vankilan sijainti",
      solitaryLabel = "eristys",
      solitaryUnavailable = "Tälle vankilalle ei ole määritelty eristyssoluja.",
      durationLabel = "Kesto (kuukausia)",
      monthHint = "1 kuukausi = {minutes} minuuttia",
      cancelButton = "Peruuta",
      assignButton = "Lähetä vankilaan",
      assigning = "Lähettää vankilaan...",
      noPlayers = "Ei pelaajia {range} metrin säteellä.",
      noJails = "Vankiloita ei ole vielä määritetty. Käytä ensin vankiloiden luojaa.",
      spawnMissing = "Tähän vankilaan ei ole asetettu spawn-pistettä.",
      jailStatusReady = "Spawn valmis.",
      jailStatusMissing = "Spawn puuttuu.",
      success = "Pelaaja lähetetty vankilaan {months} kuukauden ajaksi.",
      errors = {
        invalid_target = "Valita lähin pelaaja ja vankila.",
        spawn_not_set = "Tässä vankilassa ei ole spawn-pistettä.",
        solitary_unavailable = "Tässä vankilassa ei ole yksittäissoluja.",
        failed = "Pelaajan vieminen vankilaan epäonnistui."
      }
    },
    bolos = {
      eyebrow = "BOLO-taulu",
      title = "BOLOt",
      listed = "listattu",
      unknown = "Tuntematon",
      search = {
        placeholder = "Etsi BOLOja otsikon, tunnisteen, tyypin tai tagin mukaan."
      },
      actions = {
        refresh = "Päivitä",
        manageTypes = "hallinnoida tyyppejä",
        new = "luoda BOLO",
        back = "palata takaisin listalle",
        add = "lisätä",
        addPhoto = "lisätä valokuva",
        remove = "poistaa"
      },
      state = {
        loading = "Ladataan BOLOja...",
        empty = "Nykyisten suodattimien kanssa ei löytynyt BOLOja.",
        saving = "Tallennetaan...",
        noTags = "Tunnisteita ei ole määritetty.",
        noReports = "Ei vielä liitettyjä raportteja."
      },
      detail = {
        summary = "BOLO-yhteenveto",
        untitled = "Nimetön BOLO"
      },
      fields = {
        title = "BOLO-otsikko",
        id = "BOLO-tunnus",
        type = "Tyyppi",
        status = "Tila",
        priority = "Prioriteetti",
        created = "Luotu",
        updated = "Viimeisin päivitys"
      },
      placeholders = {
        title = "BOLO-otsikko",
        id = "Automaattisesti luotu, jos tyhjä",
        type = "Valita tyyppi",
        description = "Lisätä kuvausta...",
        tag = "Lisätä tunniste",
        reportSelect = "Valita raportti"
      },
      sections = {
        description = "Kuvaus",
        descriptionSubtitle = "Tallentaa yksityiskohdat ja ohjeet.",
        tags = "Tunnisteet",
        tagsSubtitle = "Lisätä nopeita tunnisteita BOLO:lle.",
        reports = "Raporttien linkittäminen",
        reportsSubtitle = "Liittää liittyviä raporttitiedostoja",
        gallery = "Galleria",
        gallerySubtitle = "Liittää gallerian kuvat BOLOon"
      },
      gallery = {
        title = "Valita valokuva",
        subtitle = "Valita gallerian kuva liitettäväksi BOLOon",
        loading = "Ladataan galleria...",
        empty = "Galleria-kuvia ei ole saatavilla.",
        photoAlt = "Galleria-kuva"
      },
      typesModal = {
        title = "BOLO-tyypit",
        subtitle = "Lisätä tai poistaa tämän laitteen BOLO-tyyppejä.",
        placeholder = "Lisätä BOLO-tyyppi",
        empty = "Määritettyjä BOLO-tyyppejä ei ole."
      },
      types = {
        person = "Henkilö",
        vehicle = "Ajoneuvo",
        property = "Omaisuus",
        missing = "Kadonnut",
        other = "Muu"
      },
      status = {
        active = "Aktiivinen",
        located = "Sijainnissa",
        closed = "Suljettu",
        cancelled = "Peruutettu"
      },
      priority = {
        low = "Alhainen",
        medium = "Keskitasoinen",
        high = "Korkea",
        critical = "Kriittinen"
      },
      errors = {
        load = "BOLOjen lataaminen epäonnistui.",
        save = "BOLO:n tallennus epäonnistui.",
        titleRequired = "Syötä BOLO-otsikko ennen tallentamista.",
        typeRequired = "Valitse BOLO-tyyppi ennen tallentamista.",
        gallery = "Gallerian lataaminen epäonnistui."
      }
    },
    warrants = {
      eyebrow = "Lupien arkisto",
      title = "Luvat",
      listed = "Lueteltu",
      unknown = "Tuntematon",
      search = {
        placeholder = "Etsi lupia otsikon, id:n, tyypin tai tunnisteen mukaan"
      },
      actions = {
        refresh = "Päivitä",
        manageTypes = "Hallitse tyyppejä",
        new = "Uusi lupa",
        back = "Takaisin luetteloon",
        add = "lisätä",
        addPhoto = "lisätä valokuva",
        remove = "poistaa"
      },
      state = {
        loading = "ladataan etsintäluvat...",
        empty = "Ei löydy nykyisten suodattimien mukaisia etsintäluvia.",
        saving = "Tallennetaan...",
        noTags = "Tagit eivät ole määritetty.",
        noReports = "Ei vielä linkitettyjä raportteja.",
        noOffences = "Ei vielä rikkeitä liitetty."
      },
      detail = {
        summary = "Etsintäluvan yhteenveto",
        untitled = "Nimetön warrantti"
      },
      fields = {
        title = "Warrantin otsikko",
        id = "Warrantin tunnus",
        type = "Tyyppi",
        status = "Tila",
        priority = "Prioriteetti",
        created = "Luotu",
        updated = "Viimeisin päivitys"
      },
      placeholders = {
        title = "Warrantin otsikko",
        id = "Automaattisesti luotu, jos jätetään tyhjäksi",
        type = "valita tyyppi",
        description = "lisätä kuvaus...",
        tag = "lisätä tunniste",
        reportSelect = "valita raportti",
        offenceSelect = "valita rikos"
      },
      sections = {
        description = "kuvaus",
        descriptionSubtitle = "kirjata yhteenveto ja ohjeet.",
        tags = "tunnisteet",
        tagsSubtitle = "liittää nopeita tunnisteita varmenteeseen",
        reports = "linkittää raportteja",
        reportsSubtitle = "Liittää liittyvät raporttitiedostot",
        offences = "Rikokset",
        offencesSubtitle = "Liittää tähän määräykseen liittyvät rikokset",
        gallery = "Galleria",
        gallerySubtitle = "Liittää gallerian kuvia määräykseen"
      },
      gallery = {
        title = "Valita valokuva",
        subtitle = "Valita määräykseen liitettävä gallerian kuva",
        loading = "Ladata galleria",
        empty = "Galleria-kuvia ei ole saatavilla",
        photoAlt = "Galleria-kuva"
      },
      typesModal = {
        title = "Määräysten tyypit",
        subtitle = "Lisätä tai poistaa tämän laitteen määräysten tyyppejä.",
        placeholder = "Lisätä määräysten tyyppiä",
        empty = "Määräysten tyyppejä ei ole määritetty."
      },
      types = {
        arrest = "Pidätysmääräys",
        search = "Hae",
        bench = "Käräjäoikeuden määräys",
        probation = "Ehdollinen valvonta"
      },
      status = {
        active = "Aktiivinen",
        served = "Toimitettu",
        expired = "Vanhentunut",
        cancelled = "Peruutettu"
      },
      priority = {
        low = "Matala",
        medium = "Keskitaso",
        high = "Korkea",
        critical = "Kriittinen"
      },
      errors = {
        load = "Takuiden lataaminen epäonnistui.",
        save = "Warrantin tallentaminen epäonnistui.",
        titleRequired = "Syötä warrant-otsikko ennen tallentamista.",
        typeRequired = "Valitse warrant-tyyppi ennen tallentamista.",
        gallery = "Galleriaa ei voi ladata."
      }
    },
    prison = {
      eyebrow = "Pidätysloki.",
      title = "Vankila.",
      listed = "Lueteltu.",
      search = {
        placeholder = "Nimen tai tunnisteen mukaan etsiminen."
      },
      filters = {
        all = "Kaikki.",
        label = "Tila.",
        placeholder = "Tila."
      },
      actions = {
        refresh = "Päivittää.",
        back = "Palata luetteloon.",
        saveDuration = "tallentaa kestoa",
        minusMinutes = "-15 min",
        minusSmall = "-5 min",
        plusSmall = "+5 min",
        plusMinutes = "+15 min",
        saveNotes = "tallentaa muistiinpanoja",
        saveWarrant = "liittää määräys",
        addOffence = "lisätä rikkomus",
        setSolitary = "siirtää eristyksiin",
        setGeneral = "palata yleiseen"
      },
      state = {
        loading = "Ladata vangit...",
        empty = "Nykyisillä suodattimilla ei löydy vankeja.",
        saving = "Tallennetaan...",
        noOffences = "Rikkomuksia ei vielä liitetty."
      },
      labels = {
        mugshot = "Kasvokuva"
      },
      detail = {
        summary = "Vangin yhteenveto"
      },
      fields = {
        booked = "Kirjata",
        remaining = "Jäljellä oleva aika",
        identifier = "Tunniste",
        unknown = "Tuntematon",
        remainingMinutes = "Jäljellä olevat minuutit",
        warrant = "Pidätysmääräys",
        offences = "Rikokset",
        housing = "Asuminen"
      },
      sections = {
        duration = "Rangaistuksen kesto",
        durationSubtitle = "säätä jäljellä olevaa aikaa minuuteissa",
        notes = "Muistiinpanot",
        notesSubtitle = "Kirjaa havainnot tästä tuomiosta",
        links = "Liitetty pidätysmääräys ja rikokset",
        linksSubtitle = "Liittää tämän oleskeluun liittyvät pidätysmääräys ja rikokset",
        housing = "Asuminen",
        housingSubtitle = "Vaihtaa eristyksen ja yleisen osaston välillä."
      },
      placeholders = {
        note = "Lisätä muistiinpanoja...",
        warrant = "Valita pidätysmääräys",
        offence = "Valita rikos"
      },
      status = {
        in_prison = "Vankilassa",
        breaked_out = "Karkuun päässyt",
        released = "Vapautettu"
      },
      solitary = {
        active = "Eristysselli",
        inactive = "Yleinen osasto",
        badge = "Eristyksessä"
      },
      duration = {
        minutesOnly = "{minutes}m jäljellä",
        full = "{hours}h {minutes}m jäljellä"
      },
      linked = {
        warrantFallback = "Pidätysmääräys"
      },
      date = {
        unknown = "Tuntematon"
      },
      errors = {
        load = "Vankeja ei voida ladata.",
        duration = "Kestoa ei voida päivittää.",
        note = "Muistiinpanoa ei voida tallentaa.",
        links = "Linkkejä ei voida päivittää.",
        solitary = "Eristyksen tilaa ei voida päivittää.",
        solitary_unavailable = "Tässä vankilassa ei ole määriteltyjä yksinäishuoneita."
      }
    },
    billing = {
      title = "Laskun laatiminen",
      subtitle = "Veloittaa lähialueen asukkaita palveluista.",
      selectLabel = "Valita henkilö",
      selectPlaceholder = "Valita henkilö",
      noPlayers = "Ei lähistöllä ole henkilöitä {range} m säteellä.",
      amountLabel = "Laskun summa",
      reasonLabel = "Syy (lyhyt)",
      reasonPlaceholder = "Esimerkki: Partiointipalvelu.",
      presetsLabel = "Rikkomukset",
      presetSearchPlaceholder = "etsiä rikkomusta tai sakkoa",
      presetNoMatches = "hakusi ei vastaa rikkomuksia.",
      presetReasonHeader = "rikkomus",
      presetAmountHeader = "sakko",
      presetCustomAmount = "mukauttaa",
      paperDefaultCategory = "Pysäköintirikkomuksen ilmoitus",
      ticketReceiptTitle = "Kutsuilmoitus",
      ticketReceiptSubtitle = "Tallennettu",
      ticketReceiptCitizenLabel = "Kansalainen",
      ticketReceiptOfficerLabel = "Kutsun antajat",
      ticketReceiptReasonLabel = "laskun yhteenveto",
      ticketReceiptAmountLabel = "sakon loppusumma",
      ticketReceiptAcknowledge = "hyväksyä",
      cancelButton = "peruuttaa",
      submitButton = "laskun laatiminen",
      submitting = "lähettäminen",
      success = "lasku on lähetetty onnistuneesti",
      paperTicketNumber = "lipun numero",
      paperDate = "päivämäärä",
      paperTime = "aika",
      paperCitizenLabel = "Kansalainen",
      paperOfficerLabel = "Henkilökunta",
      paperViolationLabel = "Rikkomus",
      paperNotice = "Maksu erääntyy välittömästi. Maksun maksamatta jättäminen voi johtaa takavarikkoon.",
      paperSignatureLabel = "Henkilökunnan allekirjoitus",
      paperTotalFine = "Kokonaissakko",
      errors = {
        failed = "Laskun laatiminen epäonnistui.",
        invalid_target = "Henkilö ei ole saatavilla.",
        empty_reason = "Anna lyhyt syy.",
        too_far = "Henkilö siirtyi liian kauas.",
        not_authorized = "Et ole oikeutettu laatimaan laskuja.",
        not_on_duty = "Laskujen laatimiseksi sinun on oltava työvuorossa.",
        amount_out_of_range = "Laskun summa on sallitujen rajojen ulkopuolella.",
        insufficient_funds = "Henkilöllä ei ole varaa tähän veloitukseen.",
        player_unavailable = "Henkilö ei ole saatavilla.",
        disabled = "Laskutusjärjestelmä on pois käytöstä."
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
        title = "Ominaisuudet",
        subtitle = "Ota resurssin ominaisuuksia kayttoon tai pois kaikille maaritetyille tyopaikoille.",
        instantTuning = { label = "instantTuning", description = "" },
        partsDelivery = { label = "Osien toimitus", description = "Ota korjaamon osatilaukset ja toimitusalueet kayttoon." },
        carryItems = { label = "Fyysinen osien kasittely", description = "Vaadi toimitettujen osien kuljetus korjaamon lapi." },
        nitro = { label = "nitro", description = "" },
        antiLag = { label = "antiLag", description = "" },
        twoStep = { label = "twoStep", description = "" },
        wheelDamage = { label = "Renkaiden vauriot", description = "Ota realistiset rengasvauriot ja korjaukset kayttoon." },
        customHandling = { label = "customHandling", description = "" },
        mileageHud = { label = "Kilometri-HUD", description = "Nayta ajoneuvon kilometrit ajon aikana." },
        workshopLift = { label = "Korjaamon nostin", description = "Ota korjaamoiden kaytettavat nostinpisteet kayttoon." }
      },
globalSettings = { title = "Global settings", notice = "These values apply to all configured jobs. Saving them from this job updates the behavior globally." },
      tuning = { globalTitle = "Global pricing settings", globalBadge = "Global", globalNotice = "These values apply to all configured jobs. Saving them from this job updates pricing behavior globally.",
        nitroAccess = "Nitro-käyttöoikeus tälle työlle",
        nitroAccessHelp = "Ohita globaali Nitro-asetus tälle mekaanikkotyölle.",
        nitroAccessInherit = "Käytä globaalia Nitro-asetusta",
        nitroAccessEnabled = "Ota Nitro käyttöön tälle työlle",
        nitroAccessDisabled = "Poista Nitro käytöstä tälle työlle",
      },
      fields = { allowedJobs = "Allowed jobs", animationDict = "Animation dict", animationName = "Animation name", blip = "Blip", bone = "Bone", category = "Category", color = "Job color", consumeItems = "Consume items", cost = "Cost", distance = "Distance", enabled = "Enabled", garageType = "Garage type", heading = "Heading", item = "Item", jobName = "Job name", label = "Label", marker = "Marker", mechanicOnly = "Mechanic", name = "Name", offsetX = "Offset X", offsetY = "Offset Y", offsetZ = "Offset Z", offDutyEnabled = "Off-duty enabled", offDutyJob = "Off-duty job", ped = "Ped", pedModel = "Ped model", price = "Price", prop = "Prop", requiredItems = "Required items", scenario = "Scenario", sprite = "Sprite", stage = "Stage", transport = "Transport", trunkCapacity = "Trunk capacity", type = "Type", value = "Value", x = "X", y = "Y", z = "Z",
        minGrade = "Vähimmäisarvo",
        livery = "Väritys",
        fuelType = "Polttoainetyyppi",
        primaryColor = "Pääväri",
        secondaryColor = "Toissijainen väri",
        pearlescentColor = "Helmiäisväri",
        wheelColor = "Renkaan väri",
        extras = "Lisävarusteet",
        extraId = "Lisävarusteen tunnus",
        propCounts = "Propien rajoitukset",
        count = "Raja",
        properties = "Ajoneuvon ominaisuudet",
        property = "Ominaisuus",
      },
      placeholders = { allowedJobs = "mechanic, tuner", itemName = "Item name", jobName = "job name", label = "Label", model = "Model", vehicleName = "Name",
        liveryIndex = "e.g. 0",
        paintIndex = "0-160",
        propCounts = "{ \"prop_model\": 4 }",
        properties = "{ \"windowTint\": 1 }",
      },
      fuelTypes = {
        default = "Oletus (tavallinen)",
        regular = "Tavallinen",
        plus = "Plus",
        premium = "Premium",
        diesel = "Diesel",
      },
      descriptions = { color = "Color used by Sky Jobs menus, blips, and job UI accents.", jobName = "Framework job name registered for this job.", offDutyEnabled = "Enable an off-duty counterpart for this job.", offDutyJob = "Job name used when this employee goes off duty." },
      messages = { empty = "No jobs configured yet.", featuresSaved = "Features saved.", invalidJson = "Correct invalid JSON fields before saving.", loading = "Loading jobs...", nameExists = "A job with this job name already exists.", noTuningOptions = "No options configured in this category.", saved = "Settings saved.", saveFailed = "Unable to save changes." },
      locations = { addSubtitle = "Choose which point type to place.", addTitle = "Add location point", deleteFailed = "Unable to delete location.", deleteSaved = "Location removed. Save settings to apply it.", emptySubtitle = "This configurator has no registered location definitions.", emptyTitle = "No locations configured.", garageMenu = "Menu", garagePark = "Park", garageSpawn = "Spawn", placeFailed = "Unable to place location.", placementHint = "Press Enter to place and Backspace to cancel.", placementSaved = "Location updated. Save settings to apply it.", placementTitle = "Placement mode", teleported = "Teleported to location.", teleportFailed = "Unable to teleport to location.", unset = "Not set" },
      carryItems = { missingProp = "Enter a prop model before opening placement.", placementFailed = "Unable to edit attach placement.", placementSaved = "Attach placement updated. Save settings to apply it.", selectItem = "Select delivery item" },
      extensions = { invalidJson = "Virheellinen JSON. Korjaa syntaksi ennen tallennusta.", jsonObjectRequired = "Arvon taytyy olla JSON-objekti.", partsDeliveryShop = "Osatoimituskauppa", tuningCostProfile = { label = "Tuning-hinnat", description = "Maarita taman tyopaikan performance-, ulkoasu-, vanne- ja erikoisoptioiden kustannukset." } },
garageTypes = { boat = "Boat", helicopter = "Helicopter", vehicle = "Vehicle" },
      colorPopup = { title = "Job color" },
      dialogs = { delete = { cancel = "Cancel", confirm = "Delete", message = "Delete {name}?", title = "Delete job" } },
      screenPosition = { preview = "HUD" },
      interactions = { title = "Interactions", empty = "No interactions configured.", addMarkerSetting = "Add marker setting", noPedSelected = "No ped selected", headers = { interaction = "Interaction", key = "Key", marker = "Marker", blip = "Blip", npc = "NPC" }, tabs = { behavior = "Behavior", marker = "Marker", blip = "Blip", npc = "NPC" }, status = { on = "On", off = "Off" }, fields = { unique = "Unique", forceMarkerInteraction = "Force marker interaction", interactionDistance = "Interaction distance", placementModel = "Placement model" }, help = { unique = "Limits the interaction type to one configured point for a location when enabled.", forceMarkerInteraction = "Forces marker-style interaction handling even when target/NPC interaction support is available.", interactionDistance = "Maximum distance from the point where the player can use the interaction.", placementModel = "Object model shown while placing this interaction in the creator." } },
      assetPicker = { search = "Search", allCategories = "All categories", itemCount = "{count} items", markerTitle = "Marker type", markerSubtitle = "Choose a DrawMarker type.", blipTitle = "Blip sprite", blipSubtitle = "Choose a map blip sprite.", pedTitle = "Ped model", pedSubtitle = "Choose a FiveM ped model.", chooseMarker = "Choose marker", chooseBlip = "Choose blip", choosePed = "Choose ped" },
      markerFields = { posX = "Position X", posY = "Position Y", posZ = "Position Z", dirX = "Direction X", dirY = "Direction Y", dirZ = "Direction Z", rotX = "Rotation X", rotY = "Rotation Y", rotZ = "Rotation Z", scaleX = "Scale X", scaleY = "Scale Y", scaleZ = "Scale Z", red = "Red", green = "Green", blue = "Blue", alpha = "Alpha", bobUpAndDown = "Bob up/down", faceCamera = "Face camera", rotationOrder = "Rotation order", rotate = "Rotate", textureDict = "Texture dict", textureName = "Texture name", drawOnEnts = "Draw on entities" },
      instantTuning = { title = "Instant Tuning", defaultLabel = "Default label", defaultLabelHelp = "Text shown at instant tuning points.", interactionDistanceHelp = "Default distance from which a point can be used.", priceMultiplier = "Price multiplier", priceMultiplierHelp = "Multiplier applied to instant tuning prices.", forceMarkerHelp = "Forces marker-style interaction handling even when target support is available.", mechanicOnlyHelp = "Restricts every instant tuning point to configured mechanic jobs.", allowedJobsHelp = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", emptyLocations = "No instant tuning locations configured.", emptyLocationsHelp = "Add a location, then use Set to capture your current position." }
  ,

      configs = { sky_mechanicjob = { title = "Mekaanikkotyot", subtitle = "Maarita mekaanikkotyot, kaupat, ajoneuvot ja korjaamosijainnit." } },
      settingSections = { general = "Yleinen", partsTheft = "Osien varkaus", vehicleCare = "Ajoneuvon hoito", wear = "Kuluminen", wheelDamage = "Rengasvauriot", mileageHud = "Kilometri-HUD", instantTuning = "Instant Tuning", carryItems = "Kannettavat osat" },
      settingFields = { key = "Avain", label = "Nimi", name = "Itemin nimi", amount = "Maara", price = "Hinta", item = "Item", repair = "Korjaa kitilla", classId = "Luokka-ID", multiplier = "Kerroin", kilometersToZero = "Kilometrit nollaan", removeAfterUse = "Kuluta item", flow = "Asennusvaihe", transport = "Kuljetus", prop = "Prop", bone = "Bone", x = "X", y = "Y", z = "Z", rx = "Rot X", ry = "Rot Y", rz = "Rot Z", category = "Kategoria" },
      settings = {
        primaryColor = { label = "Paavari", description = "Main mechanic configurator color and default job color fallback. Use a hex value such as #EDC001." },
        orderInstallNonMinigameDurationMs = { label = "Yksinkertainen asennusaika", description = "Milliseconds used for order install steps that do not run a minigame." },
        tuningWorkshopRequireForInstall = { label = "Vaadi korjaamo asennukseen", description = "Require tuning order installs to start and complete near a self-service tuning point." },
        tuningWorkshopRequireForRemoval = { label = "Vaadi korjaamo poistoon", description = "Require tuning removals to start and complete near a self-service tuning point." },
        tuningWorkshopDistance = { label = "Korjaamon vaadittu etaisyys", description = "Maximum distance from a self-service tuning point for required install or removal actions." },
        addRevenueToSociety = { label = "Talleta tulot yhteisolle", description = "Deposit paid tuning order money into the tuning job society account." },
        publicUsersSeePrices = { label = "Julkiset kayttajat nakevat hinnat", description = "Show regular tuning prices to non-mechanic public users." },
        fallbackVehicleValue = { label = "Ajoneuvon oletusarvo", description = "Value used when no vehicle price can be resolved." },
        priceType = { label = "Hintatyyppi", description = "Percentage calculates each tuning cost from the vehicle price. Fixed uses the entered money amount.", options = { percentage = "Prosentti", fixed = "Kiintea" } },
        freeVehicles = { label = "Ilmaiset tuning-ajoneuvot", description = "Vehicle spawn models that receive free tuning orders.", itemLabel = "Vehicle model" },
        partsTheftItem = { label = "Varkaustyokalu", description = "Inventory item used to steal wheels and catalytic converters." },
        partsTheftRemoveItemAfterUse = { label = "Kuluta varkaustyokalu", description = "Remove the theft tool item after a successful theft action." },
        partsTheftStolenWheelItem = { label = "Varastettu rengas", description = "Inventory item awarded when wheels are stolen." },
        partsTheftCatalyticConverterItem = { label = "Katalysaattori", description = "Inventory item awarded when a catalytic converter is stolen." },
        partsTheftDealerAccount = { label = "Dealer payout account", description = "Account used for stolen parts dealer payouts, such as money or bank." },
        partsTheftDealerSellDistance = { label = "Dealer sell distance", description = "Maximum distance from the dealer to sell stolen parts." },
        partsTheftDispatchEnabled = { label = "Laheta poliisihalytys", description = "Create a police dispatch when a wheel or catalytic converter is stolen." },
        partsTheftDispatchJobs = { label = "Dispatch jobs", description = "Job names that receive parts theft dispatches.", itemLabel = "Job name" },
        partsTheftDispatchTitle = { label = "Dispatch title", description = "Title shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchMessage = { label = "Dispatch message", description = "Message shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchCooldownSeconds = { label = "Dispatch cooldown", description = "Seconds before the same vehicle part can create another dispatch." },
        partsTheftDealerItems = { label = "Dealer items", description = "Stolen items the dealer will buy and their payout values.", itemLabel = "Dealer item" },
        vehicleCareWashItem = { label = "Pesu-item", description = "Inventory item used to wash a vehicle." },
        vehicleCareWashRemoveAfterUse = { label = "Kuluta pesu-item", description = "Remove the wash item after use." },
        vehicleCareWaxItem = { label = "Vaha-item", description = "Inventory item used to wax a vehicle." },
        vehicleCareWaxRemoveAfterUse = { label = "Kuluta vaha-item", description = "Remove the wax item after use." },
        vehicleCareWaxCleanKilometers = { label = "Wax clean kilometers", description = "Distance a waxed vehicle stays clean." },
        vehicleCareRepairItem = { label = "Korjaus-item", description = "Inventory item used by the vehicle repair action." },
        vehicleCareRepairRemoveAfterUse = { label = "Kuluta korjaus-item", description = "Remove the repair item after use." },
        vehicleCareRepairDurationMs = { label = "Korjausaika", description = "Repair progress duration in milliseconds." },
        vehicleCareRepairMaxDistance = { label = "Repair max distance", description = "Maximum distance from the vehicle while repairing." },
        vehicleCareRepairVehicleDamage = { label = "Fix vehicle damage", description = "Repair normal GTA vehicle damage when using the repair action." },
        vehicleCareRepairFixRealisticWheelDamage = { label = "Fix realistic wheel damage", description = "Also reset realistic wheel damage when using the repair action." },
        vehicleCareRepairWearParts = { label = "Repair kit restored parts", description = "Choose which wear and service parts the repair item restores. Disable fluids here if oil, coolant, brake fluid, or transmission fluid should require the diagnostics repair flow.", itemLabel = "Wear part" },
        wearParts = { label = "Kuluvat osat", description = "Vehicle wear parts, their lifetime distance, required repair item, item consumption, and install flow.", itemLabel = "Wear part", fields = { flow = { options = { wheel = "Wheel", performance = "Performance", underbody_neon = "Underbody / lift", oil_change = "Oil change", fluid_refill = "Fluid refill", catalytic_converter = "Catalytic converter", hood_install = "Hood install" } } } },
        wheelDamageDefaultMultiplier = { label = "Oletuskerroin", description = "Base wheel damage multiplier." },
        wheelDamageOffroadWheelsMultiplier = { label = "Off-road wheel multiplier", description = "Multiplier used when the vehicle has off-road wheels." },
        wheelDamageVehicleClassMultipliers = { label = "Vehicle class multipliers", description = "Damage multipliers per GTA vehicle class.", itemLabel = "Vehicle class" },
        mileageHudDigits = { label = "Numerot", description = "Number of digits shown in the mileage HUD." },
        mileageHudPosition = { label = "Sijainti", description = "Drag the mileage HUD preview to the desired screen position." },
        partsDeliveryTimeSeconds = { label = "Toimitusaika", description = "Seconds between ordering parts and the delivery becoming ready." },
        partsDeliveryTimerHudEnabled = { label = "Show delivery timer", description = "Show a small in-game timer HUD after a parts order is placed." },
        partsDeliveryTimerHudPosition = { label = "Timer position", description = "Drag the parts delivery timer HUD preview to the desired screen position." },
        partsDeliveryOwnCard = { label = "Own card payment", description = "Allow players to pay parts delivery orders with their own money." },
        partsDeliveryCompanyCard = { label = "Company card payment", description = "Allow parts delivery orders to use company funds." },
        partsDeliveryOpenDurationMs = { label = "Open duration", description = "Milliseconds required to unpack a ready parts delivery." },
        instantTuningInteractionDistance = { label = "Interaktioetaisyys", description = "Default distance for using instant tuning points." },
        instantTuningForceMarkerInteraction = { label = "Force marker interaction", description = "Use marker-style E interaction even when target support is enabled." },
        instantTuningMechanicOnly = { label = "Vain mekaanikot", description = "Restrict all instant tuning locations to configured mechanic jobs." },
        instantTuningAllowedJobs = { label = "Sallitut tyot", description = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", itemLabel = "Job name" },
        instantTuningPriceMultiplier = { label = "Hintakerroin", description = "Multiplier applied to instant tuning prices." },
        instantTuningLabel = { label = "Oletusnimi", description = "Default text shown at instant tuning points." },
        instantTuningMarkerEnabled = { label = "Marker enabled", description = "Draw a world marker at instant tuning locations." },
        instantTuningMarkerType = { label = "Marker type", description = "GTA marker type used for instant tuning locations." },
        instantTuningBlipEnabled = { label = "Blip enabled", description = "Show map blips for instant tuning locations." },
        instantTuningBlipName = { label = "Blip name", description = "Map blip name." },
        instantTuningBlipSprite = { label = "Blip sprite", description = "GTA blip sprite id." },
        instantTuningBlipColor = { label = "Blip color", description = "GTA blip color id." },
        instantTuningLocations = { label = "Sijainnit", description = "Instant tuning points. Use 0 distance to inherit the default interaction distance.", itemLabel = "Locations" },
        carryItems = { label = "Kannettavat osat", description = "Delivered parts that should become physical carried props.", itemLabel = "Carry item", fields = { transport = { options = { hand = "Kasi", forklift = "Trukki", engine_lift = "Moottorinostin" } } } }
      },
      settingValues = {
        tyres = "Tyres", brake_pads = "Brake Pads", suspension = "Suspension", spark_plugs = "Spark Plugs", engine_oil = "Engine Oil", coolant = "Coolant", brake_fluid = "Brake Fluid", transmission_fluid = "Transmission Fluid", clutch = "Clutch", air_filter = "Air Filter", traction_battery = "Traction Battery", inverter = "Power Inverter", catalytic_converter = "Catalytic Converter",
        vehicleClass_0 = "Compacts", vehicleClass_1 = "Sedans", vehicleClass_2 = "SUVs", vehicleClass_3 = "Coupes", vehicleClass_4 = "Muscle", vehicleClass_5 = "Sports Classics", vehicleClass_6 = "Sports", vehicleClass_7 = "Super", vehicleClass_8 = "Motorcycles", vehicleClass_9 = "Off-road", vehicleClass_10 = "Industrial", vehicleClass_11 = "Utility", vehicleClass_12 = "Vans", vehicleClass_13 = "Cycles", vehicleClass_14 = "Boats", vehicleClass_15 = "Helicopters", vehicleClass_16 = "Planes", vehicleClass_17 = "Service", vehicleClass_18 = "Emergency", vehicleClass_19 = "Military", vehicleClass_20 = "Commercial", vehicleClass_21 = "Trains", vehicleClass_22 = "Open Wheel"
      }
  },
    jobConfigurator = {
      actions = {
        backToScripts = "Skriptit"
      },
      selector = {
        title = "Töiden määritys",
        subtitle = "Valitse mikä työskripti haluat määrittää.",
        description = "Valitse resurssi, jonka haluat määrittää.",
        loading = "Ladataan määritystyökaluja...",
        comingSoon = "Tulossa pian",
        emptyTitle = "Ei määritettäviä skriptejä saatavilla.",
        emptySubtitle = "Sinulla ei ole oikeutta mihinkään rekisteröityyn työn määritystyökaluun.",
        unavailable = "Ei rekisteröity"
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
