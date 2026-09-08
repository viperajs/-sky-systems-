if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/config/locales/fr.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

-- French translation
Locales["fr"] = {
  WardrobeHelpNotify = "Ouvrir la garde-robe",
  WardrobeTitle = "Garde-robe",
  WardrobeCivilianMissing = "Aucune tenue civile stockée pour le moment.",
  WardrobeCivilianRestored = "Tenue civile chargée.",
  WardrobeUnsupportedFramework = "La garde-robe ne fonctionne pas avec le framework selectionne ({framework}).",
  WardrobeMissingSkinchanger = "La garde-robe necessite que skinchanger soit lance sur ESX.",
  WardrobeMissingEsxSkin = "La garde-robe necessite que esx_skin soit lance sur ESX.",
  WardrobeMissingQbClothing = "La garde-robe necessite que qb-clothing soit lance sur {framework}.",
  WardrobeMissing17Movement = "La garde-robe necessite que 17mov_CharacterSystem soit lance.",
  WardrobeMissingQsAppearance = "La garde-robe necessite que qs-appearance soit lance.",
  WardrobeMissingAk47Clothing = "La garde-robe necessite que ak47_clothing soit lance.",
  WardrobeMissingAk47QbClothing = "La garde-robe necessite que ak47_qb_clothing soit lance.",
  WardrobeMissingTgiannClothing = "La garde-robe necessite que tgiann-clothing soit lance.",
  WardrobeMissingNfSkin = "La garde-robe necessite que nf-skin soit lance.",
  WardrobeMissingBlAppearance = "La garde-robe necessite que bl_appearance soit lance.",
  WardrobeMissingIzzyAppearance = "La garde-robe necessite que izzy-appearance soit lance.",
  WardrobeMissingCodemAppearance = "La garde-robe necessite que codem-appearance soit lance.",
  WardrobeMissingHexClothing = "La garde-robe necessite que hex_clothing soit lance.",
  WardrobeMissingIllenium = "La garde-robe necessite que illenium-appearance soit lance.",
  WardrobeCustomUnavailable = "L'integration personnalisee de la garde-robe configuree n'est pas disponible.",
  WardrobeDisabled = "La garde-robe est desactivee dans la configuration.",
  WardrobeMissingRcoreClothing = "La garde-robe necessite que rcore_clothing soit lance.",
  WardrobeUnknownJob = "Le metier de la garde-robe n'est pas disponible.",
  GarageHelpNotify = "Ouvrir le garage",
  GarageTitle = "Garage",
  HelicopterGarageHelpNotify = "Ouvrir l'helipad",
  BoatGarageHelpNotify = "Ouvrir le quai",
  GarageParkHelpNotify = "Garez le véhicule",
  HelicopterGarageParkHelpNotify = "Garez l'hélicoptère",
  BoatGarageParkHelpNotify = "Stationner le bateau",
  GarageParkDriverRequired = "Vous devez être au siège conducteur pour garer.",
  GarageParkInvalidVehicle = "Ce véhicule ne peut pas être garé ici.",
  GarageParkFailedNotify = "Impossible de garer le véhicule.",
  GarageSpawnBlockedNotify = "Le point d'apparition est bloqué.",
  StorageHelpNotify = "Accéder au stockage",
  LockerHelpNotify = "Ouvrir le casier",
  TrunkTitle = "Coffre",
  TrunkHelpNotify = "Accéder au coffre",
  TrunkPropRemoveHelp = "Retirer le prop placé",
  TrunkUnavailable = "Impossible d'accéder à ce coffre.",
  BossMenuHelpNotify = "Ouvrir la gestion",
  Payroll = {
    title = "Fiche de paie",
    paid = "Salaire reçu : {amount}",
    insufficient = "Pas assez d'argent dans la caisse de l'entreprise pour ton salaire.",
  },
  PublicFormsTitle = "Formulaires publics",
  PublicFormsHelpNotify = "Remplir les formulaires publics",
  PublicFormsUnavailable = "Bornes de formulaires publics non disponibles.",
  WholesaleShopTitle = "Vente en gros",
  WholesaleShopHelpNotify = "Ouvrir la boutique de gros",
  WholesaleShopUnavailable = "Ce lieu ne dispose pas de fournisseur de gros configuré.",
  NoPermission = "Vous n'avez pas la permission d'utiliser cette commande.",
  CameraUploadFailed = "Échec du téléversement de la caméra.",
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
    Title = "Panique",
    Sent = "Bouton panique active.",
    NotOnDuty = "Vous devez etre en service pour utiliser le bouton panique.",
    Cooldown = "Le bouton panique est en rechargement. Attendez {seconds}s.",
    MappingDescription = "Déclencher l'alerte panique",
    WaypointSet = "Point GPS defini sur la position panique.",
    WaypointMissing = "Aucune position panique active.",
    LocationUnknown = "Position inconnue",
    MissingItem = "Vous avez besoin de {item} pour utiliser le bouton panique."
  },
  Ping = {
    Title = "Ping",
    Sent = "Position partagee.",
    NotOnDuty = "Vous devez etre en service pour envoyer un ping.",
    Cooldown = "Le ping est en rechargement. Attendez {seconds}s.",
    MappingDescription = "Marquer la position",
    LocationUnknown = "Position inconnue",
    MissingItem = "Vous avez besoin de {item} pour envoyer un ping."
  },
  HeliCam = {
    Title = "Camera heli",
    CamEnabled = "Camera heli activee.",
    CamDisabled = "Camera heli desactivee.",
    NotAuthorized = "Vous n etes pas autorise a utiliser la camera heli.",
    NotOnDuty = "Vous devez etre en service pour utiliser la camera heli.",
    TooLow = "L helicoptere est trop bas pour activer la camera.",
    TargetLocked = "Cible verrouillee.",
    TargetReleased = "Verrouillage de la cible relâché.",
    TargetLost = "Cible perdue.",
    RappelDenied = "Vous ne pouvez pas descendre en rappel depuis ce siege.",
    RappelStarted = "Descente en rappel lancee.",
    PhotoSaved = "Photo heli enregistree dans la galerie.",
    PhotoFailed = "Impossible d enregistrer la photo heli.",
    Spotlight = {
      ForwardOn = "Projecteur allume.",
      ForwardOff = "Projecteur eteint.",
      TrackingOn = "Projecteur de suivi active.",
      TrackingOff = "Projecteur de suivi desactive.",
      ManualOn = "Projecteur manuel active.",
      ManualOff = "Projecteur manuel desactive.",
      Brightness = "Luminosite du projecteur: {value}",
      Radius = "Rayon du projecteur: {value}"
    }
  },
  InteractionLabels = {
    job_garage              = "Garage de service",
    garage_vehicle_spawn    = "Point d'apparition du vehicule",
    garage_vehicle_park     = "Stationnement vehicule",
    garage_helicopter_menu  = "Hangar helicoptere",
    garage_helicopter_spawn = "Point d'apparition helicoptere",
    garage_helicopter_park  = "Stationnement helicoptere",
    garage_boat_menu        = "Ponton",
    garage_boat_spawn       = "Point d'apparition bateau",
    garage_boat_park        = "Amarrage bateau",
    boss_menu               = "Gestion",
    duty_terminal           = "Terminal de service",
    wardrobe                = "Vestiaire",
    storage                 = "Stockage",
    locker                  = "Casier",
    wholesale_shop          = "Grossiste",
    public_forms            = "Formulaires publics",
    jail_terminal           = "Terminal de prison",
    jail_jobs               = "Travaux en prison",
    jail_job_npc            = "Travaux en prison",
    jail_inmate_alcoholic   = "Détenu : Alcoolique",
    jail_inmate_drugdealer  = "Détenu : Dealer de drogue",
    jail_inmate_codelist    = "Détenu : Informateur",
    jail_inmate_wirecutter  = "Détenu : Passeur d'outils",
    jail_inmate_doctor      = "Médecin de la prison",
    jail_canteen_cook       = "Cuisinier de la cantine",
    jail_confiscated_return = "Objets confisqués",
    jail_electric_box       = "Boîte électrique",
    jail_fence_cut          = "Point de découpe de la clôture",
  },
  Nui = {
    IntlLocale = "fr-FR",
    currency = "€",
    menuTitles = {
      locker = "Casier personnel",
      storage = "Stockage",
      trunk = "Stockage de véhicule",
      ["trunk-props"] = "Propriétés du véhicule",
      search = "Rechercher",
      garage = "Garage",
      vehshop = "Magasin de véhicules",
      management = "Gestion",
      shop = "Gros",
      ["impound-storage"] = "Stockage de fourrière",
      refunds = "Remboursements"
    },
    menu = {
      goToVehicleShop = "Aller au magasin de véhicules",
      backToGarage = "Retour au garage"
    },
    radial = {
      empty = "Aucune action disponible pour le moment.",
      errors = {
        generic = "Action indisponible."
      },
      title = "Actions de service",
      hint = "Sélectionnez une action à effectuer.",
      pressKey = "Appuyez sur {key}",
      actions = {
        billing = {
          label = "Émettre une facture",
          description = "Émettre une facture à la personne la plus proche.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Paiement non disponible.",
            notOnDuty = "Passez en service pour émettre des factures.",
            notAuthorized = "Vous n'êtes pas autorisé à émettre des factures.",
            noPatients = "Aucune personne à proximité pour facturer."
          }
        },
        panic = {
          label = "Bouton de panique",
          description = "Déclencher une alerte de panique pour votre position actuelle.",
          states = {
            disabled = "Le bouton de panique est indisponible.",
            notOnDuty = "Passez en service pour utiliser le bouton de panique.",
            notAuthorized = "Vous n'êtes pas autorisé à utiliser le bouton de panique."
          }
        },
        tablet = {
          label = "Ouvrir la tablette",
          description = "Ouvrir l'interface de la tablette.",
          states = {
            notOnDuty = "Passer en service pour utiliser la tablette.",
            notAuthorized = "Vous n'êtes pas autorisé à utiliser la tablette.",
            missingItem = "Vous avez besoin d'une tablette pour cela."
          }
        },
        removeProp = {
          label = "Retirer le prop",
          description = "Retirer un prop placé à proximité.",
          states = {
            noNearby = "Aucun prop placé à proximité.",
            failed = "Échec de la suppression du prop."
          }
        },
        carryPatient = {
          label = "Transporter la personne",
          description = "Transporter la personne la plus proche en sécurité.",
          dropLabel = "Laisser tomber la personne",
          dropDescription = "Libérer la personne que vous portez.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Le portage n'est pas disponible.",
            beingCarried = "Vous êtes déjà porté.",
            inVehicle = "Quitter d'abord le véhicule.",
            selfIncapacitated = "Vous n'êtes pas assez stable pour porter quelqu'un.",
            noPatients = "Aucune personne à proximité à transporter.",
            tooFar = "Approchez-vous avant de porter quelqu'un."
          }
        },
        playerSearch = {
          label = "Chercher une personne",
          description = "Chercher la personne la plus proche.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "La recherche de joueur n'est pas disponible.",
            notOnDuty = "Passer en service pour rechercher des personnes.",
            notAuthorized = "Vous n'êtes pas autorisé à rechercher des personnes.",
            noPlayers = "Aucune personne à proximité à rechercher.",
            tooFar = "Approchez-vous avant de rechercher.",
            inVehicle = "Quitter d'abord le véhicule."
          }
        },
        handcuff = {
          label = "Menotter une personne",
          description = "Menotter la personne la plus proche.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "La pose de menottes n'est pas disponible.",
            notOnDuty = "Passer en service pour utiliser les menottes.",
            inVehicle = "Quitter d'abord le véhicule.",
            targetInVehicle = "Retirer la personne du véhicule en premier.",
            noPlayers = "Aucune personne à proximité à menotter.",
            tooFar = "Approchez-vous avant de menotter.",
            missingItem = "Vous avez besoin de menottes pour faire cela.",
            alreadyCuffed = "Cette personne est déjà menottée."
          }
        },
        unhandcuff = {
          label = "Retirer les menottes",
          description = "Retirer les menottes de la personne la plus proche.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Retirer les menottes n'est pas disponible.",
            notOnDuty = "Passer en service pour retirer les menottes.",
            inVehicle = "Quitter d'abord le véhicule.",
            targetInVehicle = "Retirer la personne du véhicule en premier.",
            noPlayers = "Aucune personne à proximité pour retirer les menottes.",
            tooFar = "Approchez-vous avant de retirer les menottes.",
            notCuffed = "Cette personne n'est pas menottée."
          }
        },
        wheelClamp = {
          label = "Clé de roue",
          description = "Verrouiller le véhicule le plus proche en bloquant une roue.",
          states = {
            disabled = "La fixation de la roue n'est pas disponible.",
            notOnDuty = "Passer en service pour clore les véhicules.",
            inVehicle = "Sortir d'abord du véhicule.",
            noVehicle = "Aucun véhicule à proximité.",
            tooFarVehicle = "Rapprochez-vous du véhicule.",
            noWheel = "Approchez-vous d'une roue.",
            tooFar = "Approchez-vous d'une roue."
          }
        },
        wheelClampRemove = {
          label = "Enlever le dispositif",
          description = "Retirer le dispositif de la roue du véhicule.",
          states = {
            disabled = "Le cloquage des roues est indisponible.",
            notOnDuty = "Passer en service pour retirer les dispositifs.",
            inVehicle = "Sortir d'abord du véhicule.",
            noClamp = "Aucun dispositif de roue à proximité.",
            tooFar = "Rapprochez-vous du dispositif de la roue."
          }
        },
        jail = {
          label = "Envoyer en prison",
          description = "Détention du joueur le plus proche à un emplacement de prison configuré.",
          states = {
            notAuthorized = "Vous n'êtes pas autorisé à envoyer des joueurs en prison.",
            notOnDuty = "Passer en service pour utiliser cette action.",
            noPlayers = "Aucune personne à proximité dans la portée.",
            noJails = "Aucun emplacement de prison configuré.",
            spawnNotSet = "Configurer d'abord un point d'apparition de la prison.",
            invalidTarget = "Impossible de localiser cette personne.",
            failed = "Impossible d'effectuer cette action."
          }
        }
      }
    },
    shop = {
      shoppingCart = "Panier d'achats",
      purchase = "Acheter",
      balance = "Fonds disponibles",
      catalog = "Catalogue du fournisseur",
      empty = "Aucune fourniture disponible à cet emplacement.",
      emptyCart = "Votre panier est vide.",
      insufficientFunds = "Fonds insuffisants pour cet achat.",
      limitReached = "Limite atteinte ({limit}).",
      errors = {
        invalidStation = "Station invalide.",
        emptyBasket = "Panier vide.",
        unknown = "Erreur inconnue.",
        purchase = "Échec de l'achat du panier."
      }
    },
    garage = {
      states = {
        stored = "Prêt",
        parked = "En cours d'utilisation"
      },
      title = "Garage",
      empty = "Aucun véhicule de flotte disponible.",
      emptyAir = "Aucun hélicoptère disponible sur cette plateforme.",
      ownedTitle = " flotte possédée ",
      shopTitle = "Magasin véhicules",
      shopBalance = "Fonds de faction",
      shopEmpty = "Aucun véhicule à acheter à cet emplacement.",
      shopEmptyAir = "Aucun hélicoptère à acheter sur cette plateforme.",
      emptyFleet = "Aucun véhicule de flotte n'a encore été acheté.",
      noAccess = "Accès refusé",
      confirmSellTitle = "Confirmer la vente",
      confirmSellConfirm = "Vendre",
      confirmSellCancel = "Annuler",
      confirmSellMessage = "Vendre {name} pour {price} ?",
      confirmPurchaseTitle = "Confirmer l'achat",
      confirmPurchaseConfirm = "Acheter",
      confirmPurchaseCancel = "Annuler",
      confirmPurchaseMessage = "Acheter {name} pour {price} ?",
      purchaseSuccessTitle = "Véhicule acheté",
      purchaseSuccessMessage = "{name} ajouté à la flotte.",
      defaultVehicleName = "Véhicule",
      stats = {
        topSpeed = "Vitesse maximale",
        acceleration = "Accélération",
        braking = "Freinage",
        traction = "Traction"
      },
      actions = {
        parkOut = "Sortie du stationnement",
        buyVehicle = "Acheter un véhicule",
        openTrunk = "Ouvrir le coffre",
        editStretcher = "Modifier le brancard",
        sellVehicle = "Vendre le véhicule",
        changePlate = "Changer la plaque"
      },
      placeholders = {
        selectVehicle = "Sélectionner un véhicule pour voir les détails.",
        statsLoading = "Chargement des informations du véhicule..."
      },
      errors = {
        loadVehicles = "Échec du chargement des véhicules du garage.",
        loadStats = "Échec du chargement des statistiques du véhicule.",
        parkOut = "Échec de la sortie du véhicule.",
        unavailable = "Garage inaccessible.",
        vehicleUnavailable = "Véhicule indisponible.",
        purchase = "Échec de l'achat du véhicule.",
        openTrunk = "Échec de l'ouverture du coffre.",
        noAccess = "Accès refusé à ce véhicule.",
        stretcherEditor = "Impossible d'ouvrir l'éditeur de civière.",
        stretcherPermission = "Seul le grade le plus élevé peut modifier les attachements de la civière.",
        sellVehicle = "Échec de la vente du véhicule.",
        editorUnavailable = "Éditeur indisponible.",
        changePlate = "Échec du changement de plaque."
      },
      changePlateTitle = "Changer la plaque d'immatriculation",
      changePlateButton = "Appliquer",
      plateEditor = {
        button = "Modifier la plaque",
        title = "Modifier la plaque",
        hint = "Changez la plaque de ce véhicule.",
        save = "Enregistrer la plaque",
        errors = {
          empty = "Entrez une plaque.",
          invalid = "La plaque est invalide.",
          update = "Échec de la mise à jour de la plaque."
        }
      },
      status = {
        parkedBy = "Dernière sortie par {name}",
        unknownDriver = "Inconnu"
      }
    },
    duty = {
      fields = {
        grade = "Grade",
        location = "Station",
        name = "Nom",
        badge = "Insigne"
      },
      instructions = {
        drag = "Faites glisser votre carte employé sur le capteur pour gérer votre poste.",
        dragCard = "Faites glisser la carte employé sur le capteur pour commencer votre poste."
      },
      screen = {
        welcome = "Bienvenue {name}",
        goodbye = "Poste terminé. Prenez soin de vous, {name}.",
        ready = "Accès au poste accordé.",
        completed = "Poste terminé avec succès.",
        idleTitle = "En attente de scan",
        totalHours = "Total d'heures",
        shiftDuration = "Durée du poste",
        currentTime = "Heure actuelle : {time}",
        defaultStation = "Terminal principal",
        devPrompt = "Charger des données fictives pour prévisualiser le terminal de service dans le navigateur.",
        loadMock = "Charger des données fictives",
        loading = "Chargement..."
      },
      toasts = {
        failed = "Impossible de mettre à jour le statut du service."
      },
      errors = {
        unavailable = "Terminal de service inaccessible."
      },
      title = "Terminal de poste"
    },
    storage = {
      inventory = "Inventaire",
      storage = "Stockage",
      locker = "Casier",
      trunk = " Coffre du véhicule",
      trunkProps = "Accessoires du véhicule",
      openPropMenu = "Accessoires",
      search = "Rechercher",
      items = "Articles",
      weapons = "Armes",
      transferTitle = "Transférer",
      transferButton = "Transférer",
      capacityUnlimited = "Capacité illimitée",
      errors = {
        trunkFull = "Le coffre est plein.",
        searchReadOnly = "Vous ne pouvez supprimer des articles que de la personne.",
        invalidTransfer = "Échec du transfert.",
        invalidAmount = "Montant invalide.",
        notEnoughItems = "Pas assez d'articles.",
        inventoryFull = "Espace d'inventaire insuffisant.",
        storageFull = "Voulez-vous rendre le stockage plein.",
        lockerFull = "Voulez-vous rendre le casier plein.",
        restrictedItem = "Voulez-vous accéder à cet objet.",
        invalidProp = "Échec de la sélection du brinquant."
      },
      officerInventory = "Inventaire du personnel",
      loadout = "Charge utile",
      armory = "Armurerie",
      armoryTitle = "Armurerie de l'équipement",
      storageTitle = "Stockage sécurisé",
      storageSubtitle = "Personnes autorisées uniquement",
      emptyItems = "Aucun article disponible.",
      emptyWeapons = "Aucune arme disponible.",
      emptyProps = "Aucun accessoire disponible.",
      searchItems = "Articles",
      searchWeapons = "Armes",
      lockerUnlocking = "Déverrouillage du casier...",
      restrictedPill = "Restreint",
      restrictedTooltip = "Vous n'avez pas accès à cet objet.",
      capacityLabel = "{utilisé}/{capacité}",
      propPlacement = {
        title = "Placement d'accessoire",
        place = "Placer ({key})",
        cancel = "Annuler ({key})"
      }
    },
    creator = {
      title = "Créateur",
      description = "Configurer les entrées.",
      selectJob = "Sélectionnez une catégorie d'emploi.",
      empty = "Aucune {entryLabelPlural} configurée pour le moment.",
      keyboardHint = "Utilisez les touches fléchées pour naviguer dans la liste et les actions.",
      placementHelp = "Flèches déplacent, PageUp/PageDown hauteur, Q/E rotation, Entrée pose, Retour arrière annule.",
      editTitle = "Marqueurs",
      editSubtitle = "Utilisez le bouton épingle pour stocker vos coordonnées actuelles.",
      editKeyboardHint = "Utilisez les touches fléchées pour choisir un marqueur, gauche/droite pour définir/effacer, Entrée pour l'exécuter, Backspace pour revenir.",
      missingEntry = "Entrée introuvable.",
      actions = {
        add = "Ajouter {label}",
        newEntry = "Nouvelle {entryLabel}"
      },
      status = {
        set = "Définir",
        unset = "Supprimer le paramètre"
      },
      modals = {
        createTitle = "Créer {entryLabel}",
        createButton = "Créer {entryLabel}",
        renameTitle = "Renommer {entryLabel}",
        renameButton = "Enregistrer le nom",
        deleteTitle = "Supprimer {entryLabel}",
        deleteMessage = "Voulez-vous vraiment supprimer {name} ?",
        deleteConfirmLabel = "Supprimer",
        deleteCancelLabel = "Annuler"
      }
    },
    management = {
      noAccess = "Vous n'avez accès à aucun outil de gestion.",
      refunds = {
        description = "Revoir les décès d'aujourd'hui et d'hier et rembourser les objets retirés.",
        refreshButton = "Rafraîchir",
        updatedAt = "Mis à jour {time}",
        errors = {
          loadFailed = "Échec du chargement des remboursements."
        }
      },
      dashboard = {
        sidebarTitle = "Tableau de bord",
        menuTitle = "Aperçu",
        onlineMembers = "Membres en ligne",
        funds = "Fonds",
        onDuty = "En service",
        offDuty = "Hors service",
        mostActive = "Les plus actifs"
      },
      finance = {
        sidebarTitle = "Flux de trésorerie",
        menuTitle = "Aperçu financier",
        expenseCategories = "Catégories de dépenses",
        revenueCategories = "Catégories de revenus",
        kpis = {
          revenue = "Revenu",
          expenses = "Dépenses",
          profit = "Bénéfice"
        },
        cashFlow = "Tendance du flux de trésorerie",
        lastUpdated = "Mis à jour {time}",
        emptyStates = {
          timeline = "Aucune transaction enregistrée dans cette période.",
          categories = "Pas encore de données de catégorie."
        },
        categories = {
          deposits = "Dépôts",
          withdrawals = "Retraits",
          supplies = "Fournitures",
          vehicles = "Véhicules",
          salaries = "Salaires",
          bonuses = "Primes"
        },
        errors = {
          load = "Impossible de charger l'aperçu financier."
        }
      },
      transactions = {
        sidebarTitle = "Fonds",
        menuTitle = "Gestion des fonds",
        currentBalance = "Solde actuel",
        withdrawButton = "Retirer",
        depositButton = " Déposer",
        recentTransactions = "Transactions récentes",
        columnNames = {
          timestamp = "Horodatage",
          name = "Nom",
          action = "Action",
          content = "Montant"
        },
        actions = {
          deposited = "Argent déposé",
          withdrawn = "Argent retiré",
          supplies_purchased = "Fournitures achetées",
          vehicle_purchased = "Véhicule acheté",
          vehicle_sold = "Véhicule vendu",
          salary_paid = "Salaire payé",
          bonus_paid = "Prime payée"
        },
        errors = {
          load = "Impossible de charger les transactions.",
          failed = "Échec de la transaction."
        }
      },
      billingSpecs = {
        sidebarTitle = "Préréglages de facturation",
        menuTitle = "Motifs de facturation",
        description = "Configurer les motifs que le personnel peut sélectionner lors de la facturation et définir leurs prix par défaut.",
        reasonColumn = "Raison",
        priceColumn = "Prix",
        actionsColumn = "Actions",
        reasonLabel = "Raison de facturation",
        reasonPlaceholder = "ex. réponse à une patrouille",
        amountLabel = "Prix par défaut",
        emptyState = "Aucune raison de facturation ajoutée pour le moment.",
        addButton = "Ajouter",
        addFirstButton = "Créer votre première raison",
        deleteButton = "Supprimer",
        saveButton = "Enregistrer",
        reasonRequired = "Saisissez une raison pour enregistrer cette ligne.",
        saveSuccess = "Spécifications de facturation mises à jour.",
        saveError = "Impossible d'enregistrer les spécifications de facturation.",
        loadError = "Impossible de charger les spécifications de facturation.",
        updatedAt = "Mis à jour à {time}"
      },
      members = {
        sidebarTitle = "Membres",
        menuTitle = "Liste",
        inviteTitle = "Inviter dans la faction",
        inviteSubtitle = "Sélectionnez un joueur et attribuez-lui un rang d'entrée.",
        selectPlayer = "Sélectionner un joueur",
        selectRank = "Sélectionner un rang",
        sendInvite = "Inviter",
        columnNames = {
          name = "Nom",
          rank = "Rang",
          last_online = "Dernière connexion",
          total_work_time = "Temps de travail (h)",
          actions_done = "Actions terminées",
          actions = "Actions"
        },
        bonus = {
          title = "Attribuer une prime",
          confirmButton = "Donner une prime",
          actionLabel = "Prime",
          invalidAmount = "Saisissez un montant de prime valide.",
          failed = "Échec du paiement de la prime.",
          unexpectedError = "Erreur inattendue lors du paiement de la prime."
        },
        errors = {
          load = "Échec de la récupération des membres.",
          loadUnexpected = "Erreur inattendue lors de la récupération des membres.",
          invite = "Échec de l'envoi de l'invitation.",
          inviteUnexpected = "Erreur inattendue lors de l'invitation."
        }
      },
      roles = {
        sidebarTitle = "Rôles",
        menuTitle = "Rôles",
        createRoleButton = "Créer un rôle",
        columnNames = {
          grade = "Grade",
          label = "Nom du rôle",
          salary = "Salaire",
          salaryInterval = "Intervalle (min)",
          actions = "Actions"
        },
        editMenu = {
          title = "Modifier le rôle",
          createTitle = "Créer un rôle",
          createSaveButton = "Créer",
          newRoleBreadcrumb = "Nouveau rôle",
          unnamedRole = "Rôle sans nom",
          gradeMeta = "Grade {grade}",
          backButton = "Retour",
          saveButton = "Enregistrer",
          general = "Général",
          permissions = "Autorisations",
          salary = "Salaire",
          salaryDescription = "Définir le salaire pour ce rôle.",
          salaryInterval = "Intervalle de paiement",
          salaryIntervalDescription = "Choisissez la fréquence de paiement de ce rôle (en minutes de travail).",
          roleName = "Nom du rôle",
          roleNameDescription = "Définir le nom du rôle.",
          highestRoleInfo = "C'est le rang le plus élevé et dispose automatiquement de toutes les permissions."
        },
        unsavedChanges = {
          title = "Modifications non enregistrées",
          message = "Vous avez des modifications non enregistrées pour ce rôle. Quitter quand même et les abandonner ?",
          confirm = "Quitter sans enregistrer",
          cancel = "Continuer à modifier"
        },
        permissionsEmpty = "Aucune permission trouvée.",
        permissionEntries = {
          viewLogs = {
            label = "Voir les logs",
            description = "Permet de lire les logs des transactions et activités liées au travail."
          },
          manageRoles = {
            label = "Gérer les rôles",
            description = "Permet de créer, modifier, déplacer et supprimer des grades."
          },
          manageMembers = {
            label = "Gérer les membres",
            description = "Permettre de promouvoir, rétrograder, licencier ou payer des bonus."
          },
          manageWarehouse = {
            label = "Accéder au stockage",
            description = "Permet d'interagir avec l'inventaire de stockage partagé."
          },
          manageMoney = {
            label = "Gérer les fonds",
            description = "Permet de déposer ou de retirer de l'argent de la société."
          },
          editOutfits = {
            label = "Modifier les tenues",
            description = "Permet de mettre à jour les entrées de garde-robe enregistrées."
          },
          createOutfits = {
            label = "Créer des tenues",
            description = "Permet de créer de nouvelles entrées de garde-robe."
          },
          deleteOutfits = {
            label = "Supprimer des tenues",
            description = "Permet de supprimer les entrées de garde-robe enregistrées."
          },
          purchaseSupplies = {
            label = "Commander des fournitures",
            description = "Permet de commander du matériel auprès du fournisseur en gros en utilisant les fonds de la faction."
          },
          purchaseVehicles = {
            label = "Acheter des véhicules",
            description = "Permet d'acheter de nouveaux véhicules de flotte en utilisant les fonds de la faction."
          },
          garageVehicles = {
            label = "Restrictions sur les véhicules du garage",
            description = "Sélectionnez les véhicules de la flotte auxquels ce rôle ne peut pas accéder dans le garage."
          },
          tabletApps = {
            label = "Restrictions sur l'application de la tablette",
            description = "Sélectionnez les applications de la tablette auxquelles ce rôle ne peut pas accéder."
          },
          all = {
            label = "Accès complet",
            description = "Accorde toutes les permissions indépendamment des autres commutateurs."
          }
        },
        permissionOptions = {
          storageHint = "Ajouter des items qui ne peuvent pas être supprimés avec ce rôle.",
          storageItemsTitle = "Articles restreints",
          storageWeaponsTitle = "Armes restreintes",
          allowedWeaponsTitle = "Armes autorisées",
          weaponHint = "Ajouter des armes auxquelles ce rôle peut accéder.",
          vehicleHint = "Sélectionner les véhicules auxquels ce rôle ne peut pas accéder.",
          appHint = "Sélectionner les applications de la tablette auxquelles ce rôle ne peut pas accéder.",
          itemPlaceholder = "Tapez pour ajouter un item",
          weaponPlaceholder = "Tapez pour ajouter une arme",
          weaponSelectPlaceholder = "Sélectionnez une arme",
          vehiclePlaceholder = "Sélectionnez un véhicule",
          appPlaceholder = "Sélectionnez une application de la tablette",
          addButton = "Ajouter",
          emptyVehicles = "Aucun véhicule disponible.",
          emptyApps = "Aucune application de la tablette disponible.",
          errors = {
            empty = "Veuillez entrer une valeur.",
            duplicate = "Option déjà ajoutée.",
            itemMissing = "L'item n'existe pas.",
            vehicleMissing = "Sélectionnez un véhicule.",
            appMissing = "Sélectionnez une application de la tablette.",
            weaponMissing = "L'arme n'existe pas.",
            weaponSelectMissing = "Sélectionnez une arme."
          }
        },
        errors = {
          save = "Échouer à enregistrer le rôle.",
          saveUnexpected = "Erreur inattendue lors de l'enregistrement du rôle.",
          permissionsLoad = "Échouer à récupérer les autorisations.",
          permissionsUnexpected = "Erreur inattendue lors de la récupération des autorisations."
        }
      },
      logs = {
        sidebarTitle = "Journaux",
        menuTitle = "Journaux",
        errors = {
          load = "Échouer à charger les journaux."
        },
        columnNames = {
          timestamp = "Horodatage",
          name = "Nom",
          action = "Action",
          content = "Contenu"
        },
        actions = {
          stored = "Item stocké",
          removed = "Item supprimé",
          deposited = "Argent déposé",
          withdrawn = "Argent retiré",
          outfit_created = "Tenue créée",
          outfit_updated = "Tenue mise à jour",
          outfit_deleted = "Tenue supprimée",
          permissions_updated = "Autorisations mises à jour",
          invite_sent = "Invitation envoyée",
          invite_accepted = "Invitation acceptée",
          invite_declined = "Invitation refusée",
          bonus_paid = "Prime payée",
          member_promoted = "Membre promu",
          member_demoted = "Membre rétrogradé",
          member_fired = "Membre licencié",
          supplies_purchased = "Fournitures achetées",
          vehicle_purchased = "Véhicule acheté",
          vehicle_sold = "Véhicule vendu",
          salary_paid = "Salaire payé"
        }
      },
      dialogs = {
        deleteOutfit = {
          title = "Supprimer la tenue",
          message = "Voulez-vous vraiment supprimer \"{name}\"?",
          confirm = "Supprimer la tenue",
          cancel = "Annuler"
        }
      }
    },
    cloakroom = {
      title = "Vestiaire",
      civilianClothes = "Vêtements civils.",
      newOutfit = "Nouvelle tenue.",
      edit = {
        save = "Enregistrer",
        rotateAlt = "Tourner",
        outfitNameTitle = "Nom de la tenue",
        saveOutfit = "Enregistrer la tenue"
      }
    },
    tablet = {
      apps = {
        management = "Menu principal",
        patients = "Patients",
        citizens = "Citoyens",
        offences = "Infractions",
        cases = "Dossiers",
        social_work = "Travail social",
        vehicles = "Véhicules",
        weapons = "Armes",
        prison = "Prison",
        warrants = "Mandats",
        bolos = "BOLOs",
        conditions = "Conditions",
        reports = "Rapports",
        camera = "Caméra",
        gallery = "Galerie",
        map = "Carte",
        chat = "Chat",
        calendar = "Calendrier",
        calculator = "Calculatrice",
        settings = "Paramètres"
      }
    },
    common = {
      close = "Fermer",
      unknownError = "Erreur inconnue.",
      unexpectedError = "Une erreur inattendue est survenue.",
      time = {
        now = "Maintenant"
      },
      pagination = {
        prev = "Préc",
        next = "Suiv",
        page = "Page {current} sur {total}"
      },
      gallery = {
        title = "Galerie",
        subtitle = "Sélectionner une photo ou une vidéo.",
        loading = "Chargement de la galerie...",
        empty = "Aucun élément de galerie disponible.",
        photoAlt = "Média de la galerie"
      },
      back = "Retour",
      confirm = {
        unsavedTitle = "Modifications non sauvegardées",
        unsavedMessage = "Annuler les modifications ou les enregistrer avant de quitter?",
        unsavedDiscard = "Ignorer les modifications",
        unsavedSave = "Enregistrer les modifications"
      }
    },
    reports = {
      unknown = "Inconnu"
    },
    publicForms = {
      complaint = {
        fields = {
          fullName = "Nom complet",
          phone = "Numéro de téléphone",
          incidentDate = "Date de l'incident",
          incidentTime = "Heure de l'incident",
          location = "Lieu de l'incident",
          officerName = "Nom du personnel",
          badgeNumber = "Numéro de badge",
          description = "Détails de la plainte",
          witnesses = "Témoins",
          desiredOutcome = "Résolution demandée",
          email = "Adresse e-mail",
          address = "Adresse domicile",
          signature = "Signature"
        },
        title = "Plainte citoyenne",
        subtitle = "Signaler le comportement du personnel ou les préoccupations du département.",
        placeholders = {
          fullName = "Entrez votre nom légal complet",
          phone = "###-###-####",
          email = "name@email.com",
          address = "Adresse, ville, état",
          incidentDate = "JJ/MM/AAAA",
          incidentTime = "HH:MM",
          location = "Où cela s'est-il produit ?",
          officerName = "Nom ou unité du personnel",
          badgeNumber = "Numéro de badge si connu",
          description = "Décrire en détail ce qui s'est passé...",
          witnesses = "Lister les témoins ou autres parties",
          desiredOutcome = "Quel résultat demandez-vous ?",
          signature = "Tapez votre nom complet"
        }
      },
      application = {
        fields = {
          fullName = "Nom complet",
          dateOfBirth = "Date de naissance",
          phone = "Numéro de téléphone",
          experience = "Expérience pertinente",
          availability = "Disponibilité",
          whyJoin = "Pourquoi souhaitez-vous rejoindre ?",
          email = "Adresse e-mail",
          address = "Adresse domicile",
          education = "Éducation",
          certifications = "Certifications",
          references = "Références",
          signature = "Signature"
        },
        title = "Candidature à un emploi",
        subtitle = "Postuler pour rejoindre le département.",
        placeholders = {
          fullName = "Entrez votre nom légal complet",
          dateOfBirth = "JJ/MM/AAAA",
          phone = "###-###-####",
          email = "name@email.com",
          address = "Adresse, ville, état",
          education = "École secondaire, académie ou université",
          experience = "Rôles dans l'application de la loi, la sécurité ou le service",
          certifications = "Formation en premiers soins, armes à feu ou formation connexes",
          availability = "Ateliers ou date de début préférés",
          whyJoin = "Dites-nous pourquoi vous souhaitez travailler ici...",
          references = "Noms et coordonnées",
          signature = "Saisir votre nom complet"
        }
      },
      title = "Formulaires publics",
      subtitle = "Soumettre une plainte ou une demande d'emploi.",
      stationLabel = "Station",
      dateLabel = "Date",
      timeLabel = "Heure",
      stamp = {
        label = "PD",
        complaint = "CMP",
        application = "APP"
      },
      tabs = {
        complaint = "Formulaire de plainte",
        application = "Demande d'emploi",
        myForms = "Mes soumissions"
      },
      myForms = {
        title = "Mes soumissions",
        empty = "Vous n'avez encore soumis aucun formulaire.",
        back = "Retour",
        notesTitle = "Réponses",
        notesEmpty = "Aucune réponse pour le moment.",
        statusNew = "En attente",
        statusReviewed = "Examiné",
        statusArchived = "Archivé"
      },
      actions = {
        submit = "Soumettre le formulaire",
        clear = "Effacer les champs",
        close = "Fermer"
      },
      status = {
        submitting = "Soumission en cours...",
        success = "Formulaire soumis avec succès.",
        error = "Impossible de soumettre le formulaire."
      },
      errors = {
        required = "Veuillez remplir les champs obligatoires."
      }
    },
    tabletForms = {
      title = "Boîte de réception du formulaire",
      eyebrow = "Formulaires publics",
      listed = "listé",
      filters = {
        label = "Type",
        all = "Tous les formulaires",
        complaint = "Plaintes",
        application = "Demandes"
      },
      search = {
        placeholder = "Rechercher par nom, station ou identifiant"
      },
      status = {
        new = "Nouveau",
        reviewed = "Vérifié",
        archived = "Archivé"
      },
      state = {
        empty = "Aucun formulaire ne correspond aux filtres actuels.",
        loading = "Chargement des formulaires...",
        saving = "Sauvegarde en cours..."
      },
      errors = {
        load = "Impossible de charger les formulaires.",
        update = "Impossible de mettre à jour le statut du formulaire."
      },
      detail = {
        complaintTitle = "Détails de la plainte",
        applicationTitle = "Détails de la demande"
      },
      actions = {
        refresh = "Rafraîchir",
        markReviewed = "Marquer comme vérifié",
        archive = "Archiver",
        back = "Retour à la liste"
      },
      notifications = {
        timeNow = "Maintenant",
        complaintType = "Plainte",
        applicationType = "Demande",
        app = "Formulaires",
        title = "Nouveau formulaire public",
        body = "{type} de {name} ({station})"
      },
      fields = {
        type = "Type de formulaire",
        id = "ID du formulaire",
        station = "Station",
        submitted = "Soumis",
        status = "Statut",
        contact = "Contact"
      },
      notes = {
        title = "Remarques",
        loading = "Chargement des notes...",
        empty = "Aucune note pour le moment.",
        placeholder = "Écrire une note...",
        visibleBadge = "Visible par le citoyen",
        visibleToCitizen = "Visible par le citoyen",
        submit = "Ajouter une note"
      }
    },
    gallery = {
      eyebrow = "Galerie de preuves",
      title = "Album photo",
      filters = {
        all = "Tout",
        camera = "Appareil photo",
        speedcam = "Radars de vitesse",
        cctv = "Vidéosurveillance",
        mugshot = "Photos d'identité"
      },
      labels = {
        count = "{count} photos",
        sort = "Plus récent en premier",
        photoAlt = "Photo de la galerie",
        photoFullAlt = "Photo en taille réelle",
        takenBy = "Prise par",
        captured = "Capturé",
        unknownTime = "Heure inconnue",
        unknownTakenBy = "Inconnu"
      },
      state = {
        loading = "Chargement des captures...",
        emptyTitle = "Pas encore de photos.",
        emptySubtitle = "Vos dernières prises de vue apparaîtront ici."
      },
      errors = {
        load = "Impossible de charger la galerie.",
        delete = "Impossible de supprimer la photo."
      },
      confirm = {
        deleteTitle = "Supprimer la photo",
        deleteMessage = "Supprimer cette photo ? Cette action est irrécupérable.",
        deleteConfirm = "Supprimer",
        deleteCancel = "Annuler"
      },
      mock = {
        caption = "CAPTURE DEV"
      }
    },
    camera = {
      help = {
        focused = "Appuyez sur Espace pour activer le déplacement.",
        blurred = "Appuyez sur Espace pour utiliser à nouveau la tablette."
      },
      mode = {
        photo = "Photo",
        video = "Vidéo",
        switchPhoto = "Passer en mode photo",
        switchVideo = "Passer en mode vidéo"
      },
      capture = {
        photo = "Prendre une photo"
      },
      queue = {
        title = "File d'attente",
        empty = "Aucun téléchargement pour le moment.",
        kind = {
          photo = "Téléversement de la photo",
          video = "Téléversement de la vidéo"
        },
        status = {
          loading = "Chargement en cours...",
          success = "Enregistré",
          error = "Échec"
        }
      },
      preview = {
        lastShot = "Dernière prise",
        lastCapture = "Dernière capture"
      },
      record = {
        start = "Commencer l'enregistrement",
        stop = "Arrêter l'enregistrement",
        live = "ENREG",
        saving = "Sauvegarde de la vidéo...",
        name = "Groupe appareil photo",
        description = "Enregistrement sur la tablette",
        errors = {
          config = "Fichier de configuration manquant.",
          upload = "Échec du téléchargement.",
          save = "Impossible d'enregistrer la vidéo.",
          unsupported = "Enregistrement non supporté.",
          empty = "Aucune vidéo capturée pour le moment.",
          busy = "L'enregistrement est occupé.",
          notRecording = "L'enregistrement est déjà arrêté."
        }
      },
      errors = {
        timeout = "Le téléchargement a expiré.",
        capture = "Erreur inattendue lors de la prise de photo.",
        upload = "Échec du téléchargement."
      }
    },
    cctv = {
      eyebrow = "Réseau de surveillance",
      title = "Vidéosurveillance",
      listed = "listé",
      actions = {
        refresh = "Rafraîchir"
      },
      search = {
        placeholder = "Rechercher des caméras par nom, ID ou localisation"
      },
      filters = {
        all = "Toutes les caméras",
        bodycam = "Caméras corporelles",
        dashcam = "Dashcams",
        cctv = "Caméras CCTV",
        speedcam = "Caméras de vitesse"
      },
      types = {
        bodycam = "Caméra corporelle",
        dashcam = "Dashcam",
        speedcam = "Caméra de vitesse",
        cctv = "Caméra CCTV"
      },
      status = {
        online = "En ligne",
        maintenance = "Maintenance",
        offline = "Hors ligne"
      },
      live = {
        active = "Flux en direct actif",
        maintenance = "Flux en pause pour maintenance",
        offline = "Signal perdu",
        placeholderTitle = "Flux indisponible",
        placeholderSubtitle = "Sélectionnez un membre du personnel habilité à utiliser une caméra corporelle.",
        speedcamPlaceholderTitle = "Caméra de vitesse hors ligne",
        speedcamPlaceholderSubtitle = "Réparer ou remplacer l'unité pour restaurer le flux."
      },
      labels = {
        speedcamLocation = "Au bord de la route",
        onDuty = "En service",
        durability = "Durabilité"
      },
      state = {
        loading = "Chargement des caméras...",
        empty = "Aucune caméra ne correspond aux filtres actuels.",
        select = "Sélectionnez une caméra pour voir son flux."
      },
      controls = {
        tiltUp = "Incliner vers le haut",
        panLeft = "Tourner à gauche",
        panRight = "Tourner à droite",
        tiltDown = "Incliner vers le bas"
      },
      capture = {
        name = "Vidéosurveillance - {label}",
        description = "{location} ({id})",
        saved = "Enregistré dans la galerie.",
        error = "Impossible de capturer l'image.",
        action = "Capturer",
        loading = "Capture en cours..."
      },
      record = {
        name = "Clips CCTV - {label}",
        description = "{location} ({id})",
        save = "Enregistrer les {minutes} dernières min",
        saving = "Sauvegarde en cours...",
        requested = "Demande de sauvegarde envoyée.",
        saved = "Vidéo enregistrée dans la galerie.",
        errors = {
          config = "Configuration de téléchargement manquante.",
          upload = "Échec du téléchargement.",
          save = "Impossible d'enregistrer la vidéo.",
          unsupported = "Enregistrement non pris en charge.",
          empty = "Aucun buffer disponible pour le moment.",
          request = "Impossible de demander la vidéo de la bodycam.",
          timeout = "Délai d'attente de la sauvegarde de la bodycam dépassé.",
          busy = "L'enregistrement est en cours.",
          notRecording = "L'enregistrement est déjà arrêté."
        }
      },
      waypoint = {
        set = "Point défini.",
        missing = "Aucune position disponible."
      },
      errors = {
        load = "Impossible de charger les caméras."
      }
    },
    chat = {
      targets = {
        allUnits = "Chat de toutes les unités",
        centralDispatch = "Dispatch central"
      },
      header = {
        eyebrowRoom = "Chaîne du personnel",
        eyebrowPrivate = "Ligne privée",
        metaRoom = "Salle",
        metaDirect = "Direct",
        metaStaff = "Personnel"
      },
      sidebar = {
        eyebrow = "Communications",
        title = "Réseau du personnel",
        groupTitle = "Chat de groupe",
        allUnits = "Toutes les unités",
        staffTitle = "Personnel",
        loading = "Chargement du personnel...",
        empty = "Aucun personnel disponible."
      },
      staff = {
        unknownMember = "Membre du personnel inconnu",
        onDuty = "En service",
        offDuty = "Hors service",
        grade = "Niveau {level}",
        fallback = "Personnel"
      },
      composer = {
        placeholderRoom = "Écrire une mise à jour de l'unité...",
        placeholderDirect = "Message à {name}...",
        pendingAlt = "Partage en attente"
      },
      messages = {
        avatarAlt = "Avatar de {name}",
        avatarFallback = "Avatar du personnel",
        unknownAuthor = "Inconnu",
        sharedEvidenceAlt = "Preuve partagée",
        tapToExpand = "Appuyer pour étendre"
      },
      preview = {
        ready = "Média prêt à envoyer"
      },
      profile = {
        action = "Définir la photo de profil",
        galleryTitle = "Définir la photo de profil",
        gallerySubtitle = "Choisissez une photo pour l'avatar de votre équipe.",
        photoAlt = "Photo de profil",
        selfPhotoAlt = "Photo de profil",
        error = "Impossible de mettre à jour la photo de profil."
      },
      actions = {
        remove = "Supprimer",
        send = "Envoyer"
      },
      state = {
        syncing = "Synchronisation des messages...",
        emptyRoom = "Pas encore de bavardage.",
        emptyPrivate = "Pas encore de messages privés.",
        emptyRoomHint = "Soyez le premier à vérifier avec l'unité.",
        emptyPrivateHint = "Commencer une ligne directe avec ce membre du personnel."
      },
      errors = {
        load = "Impossible de charger l'historique du chat.",
        send = "Impossible d'envoyer le message.",
        members = "Impossible de charger le personnel."
      }
    },
    bossMenu = {
      header = {
        eyebrow = "Menu du patron",
        title = "Gestion",
        balanceLabel = "Solde"
      },
      state = {
        loading = "Chargement des données de gestion..."
      }
    },
    tabletSettings = {
      header = {
        eyebrow = "Paramètres de la tablette",
        title = "Personnalisation",
        modeLabel = "Mode",
        modeLight = "Clair",
        modeDark = "Sombre"
      },
      appearance = {
        title = "Apparence",
        description = "Basculer l'interface entre clair et sombre.",
        light = "Clair",
        dark = "Sombre"
      },
      wallpaper = {
        title = "Papier peint",
        description = "Utiliser le fond par défaut, choisir dans la galerie ou ajouter un lien personnalisé.",
        labels = {
          default = "Fond par défaut",
          gallery = "Photo de la galerie",
          url = "URL personnalisé"
        },
        useDefault = "Utiliser par défaut",
        chooseGallery = "Choisir dans la galerie",
        customUrlLabel = "URL d'image personnalisée",
        customUrlPlaceholder = "https://example.com/wallpaper.jpg",
        apply = "Appliquer",
        hint = "Meilleurs résultats avec des images de 1920x1080 ou plus."
      }
    },
    calendar = {
      weekdays = {
        mon = "Lun",
        tue = "Mar",
        wed = "Mer",
        thu = "Jeu",
        fri = "Ven",
        sat = "Sam",
        sun = "Dim"
      },
      selectedDateFallback = "Sélectionner une date",
      header = {
        eyebrow = "Calendrier partagé",
        title = "Planning du personnel",
        metaPrimary = "Visible à tout le personnel",
        metaSecondary = "Tout le monde peut ajouter des entrées",
        hint = "Appuyez sur un jour pour ajouter un quarts ou un événement"
      },
      actions = {
        dayEntries = "Entrées du jour",
        addEntry = "Ajouter une entrée"
      },
      today = "Aujourd'hui",
      more = "+{count} de plus",
      modal = {
        addEntry = {
          eyebrow = "Ajouter une entrée",
          titleLabel = "Titre",
          titlePlaceholder = "Briefing, formation, patrouille",
          datetimeLabel = "Date & heure",
          colorLabel = "Couleur",
          clear = "Effacer",
          submit = "Ajouter au calendrier"
        },
        dayEntries = {
          eyebrow = "Entrées quotidiennes",
          empty = "Pas encore d'entrées. Ajoutez un briefing ou une patrouille à partager avec l'unité."
        }
      }
    },
    calculator = {
      header = {
        eyebrow = "Outils de terrain",
        title = "Calculatrice",
        modeLabel = "Mode"
      },
      keys = {
        clearAll = "A.C.",
        clearEntry = "C.E."
      },
      mode = {
        standard = "Standard"
      },
      status = {
        resetRequired = "Réinitialisation requise",
        ready = "Prêt"
      },
      errors = {
        error = "Erreur"
      }
    },
    tabletHome = {
      status = {
        defaultDate = "Lundi, 01 janvier"
      },
      calendar = {
        eventToday = "Événement aujourd'hui",
        eventTomorrow = "Événement demain",
        allDay = "Toute la journée",
        timeAt = " à {time}"
      },
      chat = {
        messageFrom = "Message de {name}",
        newMessage = "Nouveau message",
        authorFallback = "Personnel",
        messageBody = "{author} : {message}",
        sentPhoto = "{author} a envoyé une photo.",
        sentMessage = "{author} a envoyé un message."
      },
      notifications = {
        title = "Notifications",
        clearAll = "Tout effacer",
        empty = "Tout rattrapé."
      }
    },
    map = {
      eyebrow = "Bureau de cartographie",
      title = "Grille de San Andreas",
      markerLabel = "Marqueur",
      markerTypes = {
        label = "Liste des marqueurs",
        dispatch = "Envoyer",
        officers = "Personnel",
        speedcams = "Radars de vitesse",
        vehicles = "Véhicules",
        trackers = "Traceurs"
      },
      markerList = {
        listed = "listé",
        officersTitle = "Annuaire du personnel",
        speedcamsTitle = "Tableau de radars de vitesse",
        vehiclesTitle = "Tableau de véhicules",
        trackersTitle = "Tableau de traceurs",
        officersEmpty = "Aucun personnel en service.",
        speedcamsEmpty = "Aucun radar de vitesse disponible.",
        trackersEmpty = "Aucun traceur en ligne.",
        vehiclesEmpty = "Aucun véhicule en ligne."
      },
      dispatch = {
        title = "Tableau d'expédition",
        empty = "Aucune expédition pour le moment.",
        status = {
          active = "Actif",
          accepted = "Accepté",
          done = "Terminé"
        },
        panelTitle = "Détails de l'expédition",
        statusLabel = "Statut",
        acceptedBy = "Accepté par",
        doneBy = "Terminée par",
        coords = "Coordonnées",
        actions = {
          accept = "Accepter",
          done = "Marquer comme terminé",
          delete = "Supprimer"
        },
        unknown = "Inconnu"
      },
      status = {
        available = "Disponible",
        busy = "Occupé",
        pursuit = "En poursuite",
        offDuty = "Hors service"
      },
      vehicle = {
        status = {
          active = "Actif",
          offline = "Hors ligne"
        }
      },
      tracker = {
        status = {
          active = "Actif",
          offline = "Hors ligne"
        }
      },
      speedcam = {
        status = {
          online = "En ligne",
          maintenance = "Entretien",
          offline = "Hors ligne"
        }
      },
      officerPanel = {
        title = "Détails du personnel",
        callsign = "Indicatif {id}",
        rank = "Rang",
        health = "Santé",
        coords = "Coordonnées",
        lastUpdateUnknown = "À l'instant"
      },
      speedcamPanel = {
        title = "Détails du radar de vitesse",
        limit = "Limite",
        tolerance = "Tolérance",
        health = "Santé",
        coords = "Coordonnées"
      },
      vehiclePanel = {
        title = "Détails du véhicule",
        plate = "Plaque {plate}",
        netId = "ID réseau",
        health = "Santé",
        coords = "Coordonnées"
      },
      trackerPanel = {
        title = "Détails du traceur",
        plate = "Plaque {plate}",
        attachedBy = "Attaché par",
        attachedAt = "Attaché",
        netId = "ID réseau",
        status = "Statut",
        coords = "Coordonnées"
      },
      actions = {
        openCctv = "Ouvrir CCTV",
        setWaypoint = "Définir un point"
      },
      waypoint = {
        set = "Point défini.",
        missing = "Aucune position disponible."
      },
      styles = {
        atlas = "Atlas",
        roads = "Routes",
        satellite = "Satellite"
      },
      signalLost = "Signal perdu",
      missing = {
        title = "Image de la carte manquante",
        body = "Placez les images de la carte dans frontend/public/img."
      },
      details = {
        title = "Détails",
        empty = "Sélectionner un marqueur pour voir les détails."
      },
      zones = {
        title = "Zones d'exclusion",
        untitled = "zone sans nom",
        hint = "Cliquez sur la carte pour ajouter des points. Minimum 3.",
        pointCount = "{count} points",
        empty = "Aucune zone d'exclusion pour le moment.",
        actions = {
          toggle = "Zones",
          new = "Nouvelle zone",
          cancel = "Annuler",
          save = "Enregistrer la zone",
          undo = "Annuler l'action",
          clear = "Effacer",
          delete = "Supprimer"
        },
        modal = {
          title = "Nommer la zone d'exclusion",
          confirm = "Enregistrer la zone"
        },
        errors = {
          points = "Ajouter au moins 3 points.",
          nameRequired = "Saisissez un nom de zone.",
          saveFailed = "Impossible d'enregistrer la zone d'exclusion.",
          deleteFailed = "Impossible de supprimer la zone d'exclusion."
        }
      },
      monitorZones = {
        title = "Zones de moniteur de cheville",
        untitled = "zone sans nom",
        hint = "Cliquez sur la carte pour ajouter des points. Minimum 3.",
        pointCount = "{count} points",
        empty = "Aucune zone de moniteur pour le moment.",
        mode = {
          allow = "Zone autorisée",
          exclude = "Zone restreinte"
        },
        actions = {
          allow = "Zone autorisée",
          exclude = "Zone restreinte",
          cancel = "Annuler",
          save = "Enregistrer la zone",
          undo = "Annuler l'action",
          clear = "Effacer",
          delete = "Supprimer"
        },
        modal = {
          title = "Nommer la zone de moniteur",
          confirm = "Enregistrer la zone"
        },
        errors = {
          points = "Ajouter au moins 3 points.",
          nameRequired = "Saisissez un nom de zone.",
          noMonitor = "Sélectionnez un moniteur de cheville.",
          saveFailed = "Impossible d'enregistrer la zone de moniteur.",
          deleteFailed = "Impossible de supprimer la zone de moniteur."
        }
      },
      panic = {
        panelTitle = "Détails de panique",
        triggeredBy = "Déclenché par",
        createdAt = "Déclenché",
        coords = "Coordonnées"
      },
      dev = {
        officerName = "Soumettre le personnel Avery Lane",
        callsign = "Appelation LIN-23",
        rank = "Sergent",
        unit = "Patrouille centrale",
        speedcamName = "Caméra de vitesse Del Perro",
        vehicleName = "Unité 12",
        trackerName = "Traceur ALPHA",
        trackerOfficer = "Personnel Ruiz",
        dispatchTitle = "Caméra de vitesse endommagée",
        dispatchMessage = "L'unité de Del Perro nécessite une maintenance.",
        panicOfficer = "Personnel Sinclair",
        panicLocation = "Mission Row"
      }
    },
    panicNotification = {
      badge = "Panique",
      title = "Alerte de panique",
      subtitle = "{name} a appuyé sur le bouton de panique.",
      callsign = "Indicatif {id}",
      locationLabel = "Emplacement",
      locationUnknown = "Emplacement inconnu",
      hint = "Appuyez sur {key} pour définir un point de repère sur la carte en jeu."
    },
    incidentNotification = {
      panic = {
        title = "Alerte de panique",
        subtitle = "{name} a appuyé sur le bouton d'alarme."
      },
      dispatch = {
        title = "Alerter l'envoi",
        subtitle = "Partager un nouvel envoi par {name}"
      },
      ping = {
        title = "Pinger la localisation",
        subtitle = "Partager un ping de localisation en direct par {name}"
      },
      actions = {
        openMap = {
          key = "M",
          label = "Voir dans l'application Carte tablette"
        },
        setWaypoint = {
          key = "G",
          label = "Définir le point"
        },
        dismiss = {
          key = "Retour arrière",
          label = "Fermer"
        }
      }
    },
    gradeChange = {
      promotedTitle = "Promotion",
      demotedTitle = "Décroissement de grade",
      unchangedTitle = "Grade mis à jour",
      previousLabel = " grade précédent",
      newLabel = " grade actuel",
      unknownLabel = " grade non attribué",
      levelFallback = "Niveau {level}"
    },
    employeeGpsJammer = {
      title = "Brouilleur GPS",
      disabled = "Le brouillage GPS est indisponible.",
      success = "Signal GPS de l'employé perturbé.",
      failed = "Impossible de perturber le signal GPS.",
      targetJammed = "Votre signal GPS de service est en train d'être perturbé.",
      errors = {
        disabled = "Le brouillage GPS est indisponible.",
        no_players = "Aucune personne à proximité.",
        too_far = "Rapprochez-vous avant d'utiliser le brouilleur GPS.",
        invalid_target = "Impossible de localiser cette personne.",
        not_on_duty = "Aucun signal GPS de service actif trouvé sur cette personne.",
        protected_job = "Ce signal GPS d'employé est protégé.",
        missing_item = "Vous avez besoin d'un brouilleur GPS pour faire cela.",
        cooldown = "Attendez un moment avant de réutiliser le brouilleur GPS.",
        failed = "Impossible de perturber le signal GPS.",
      },
    },
    bonusNotification = {
      title = "Prime attribuée",
      subtitle = "De {name}",
      amountLabel = "Prime",
      unknownManager = "Gestion"
    },
    wheelClamp = {
      attached = "Une pince de roue est attachée"
    },
    search = {
      previewTitle = "Recherche de {name}",
      previewSubtitle = "Analyse des effets personnels pour détecter des armes et des objets illicites...",
      previewCancel = "Appuyez sur X pour annuler",
      unknownTarget = "Inconnu"
    },
    heliCamHud = {
      title = "Contrôles de la caméra hélicoptère",
      actions = {
        toggleCam = "Basculer la caméra",
        vision = "Basculer la vision",
        spotlight = "Mode projecteur",
        lockTarget = "Verrouiller la cible",
        display = "Basculer l'affichage",
        takePhoto = "Prendre une photo",
        rappel = "Rappeler",
        brightness = "Luminosité",
        radius = "Rayon"
      }
    },
    jailHud = {
      title = "Temps restant",
      trashLabel = "Corbeille",
      trashFull = "Sac plein",
      trashDropoff = "Livrer au conteneur à décharge"
    },
    jailJobs = {
      title = "Assignments de travail en prison",
      subtitle = "Choisir une tâche pour passer le temps.",
      actions = {
        cleaning = "Nettoyage",
        gardening = "Jardinage",
        carry_goods = "Transporter des marchandises"
      },
      currentJob = "Emploi actuel :",
      stop = "Arrêter le travail",
      close = "Fermer",
      contraband = {
        title = "Contrebande",
        message = "Vous avez trouvé {item}. Prenez-vous le risque de le garder ou de le jeter ?",
        keep = "Garder",
        toss = "Jeter"
      },
      boxInspect = {
        title = "Inspecter la boîte",
        message = "À l'intérieur, vous trouvez {item}. {description}",
        take = "Prendre",
        leave = "Laisser à l'intérieur",
        close = "Fermer"
      }
    },
    socialWork = {
      eyebrow = "Service communautaire",
      title = "Travail social",
      listed = "listé",
      search = {
        placeholder = "Rechercher par nom ou id"
      },
      filters = {
        all = "Tout",
        label = "Statut",
        placeholder = "Statut"
      },
      actions = {
        refresh = "Rafraîchir",
        back = "Retour à la liste"
      },
      state = {
        loading = "Chargement du service communautaire...",
        empty = "Aucun service communautaire ne correspond aux filtres actuels."
      },
      status = {
        active = "Actif",
        overdue = "En retard",
        completed = "Terminé",
        imprisoned = "Emprisonné"
      },
      labels = {
        remainingShort = "restant",
        imprison = "Emprisonner",
        imprisonNotice = "Délai dépassé. Empêchement requis.",
        noDeadline = "Aucun délai",
        expired = "Expiré"
      },
      sections = {
        summary = "Résumé du service",
        summarySubtitle = "Aperçu des tâches assignées."
      },
      fields = {
        name = "Nom",
        status = "Statut",
        remaining = "Tâches restantes",
        completed = "Tâches terminées",
        total = "Total des tâches",
        assigned = "Assigné",
        deadline = "Date limite",
        timeLeft = "Temps restant",
        assignedBy = "Assigné par",
        unknown = "Inconnu"
      },
      assign = {
        title = "Attribuer un service communautaire",
        subtitle = "Envoyer un joueur à proximité pour des tâches de travail social.",
        playerLabel = "Joueur",
        playerPlaceholder = "Choisir un joueur",
        taskLabel = "Tâches",
        taskPlaceholder = "Nombre de tâches",
        deadlineLabel = "Limite de temps (minutes)",
        deadlinePlaceholder = "Optionnel",
        submit = "Affecter",
        success = "Service communautaire attribué.",
        error = "Impossible d'attribuer le service communautaire."
      },
      errors = {
        load = "Impossible de charger le service communautaire."
      },
      date = {
        unknown = "Inconnu"
      },
      jobs = {
        title = "Service communautaire",
        subtitle = "Choisir une tâche pour compléter votre phrase.",
        currentJob = "Tâche en cours :",
        stop = "Arrêter la tâche",
        actions = {
          cleaning = "Nettoyage",
          carry_goods = "Transporter des marchandises"
        }
      },
      hud = {
        title = "Service communautaire",
        remaining = "Tâches restantes",
        completed = "Tâches terminées",
        deadline = "Temps restant",
        expired = "Expiré",
        trashLabel = "Déchet",
        trashFull = "Sac plein",
        trashDropoff = "Remettre à la benne à ordures"
      }
    },
    socialWorkCreator = {
      title = "Créateur de service social",
      description = "Configurer les sites de service social dans la ville.",
      empty = "Aucun site de service social configuré pour le moment.",
      keyboardHint = "Utiliser les flèches pour naviguer dans la liste et les actions.",
      editTitle = "Marqueurs de travail social",
      editSubtitle = "Utiliser le bouton épingle pour enregistrer vos coordonnées actuelles.",
      editKeyboardHint = "Utiliser les flèches pour choisir un marqueur, gauche/droite pour choisir Mettre à jour/ Effacer, Entrée pour l'exécuter, Retour arrière pour revenir.",
      missingEntry = "Site de travail social introuvable.",
      actions = {
        newSite = "Nouveau site"
      },
      status = {
        set = "Définir",
        unset = "Effacer"
      },
      markers = {
        social_work_job_npc = "PNJ du travail",
        social_work_dumpster = "Benne à ordures",
        social_work_box_dropoff = "Remise à la livraison"
      },
      modals = {
        createTitle = "Créer un site",
        createButton = "Créer un site",
        renameTitle = "Renommer le site",
        renameButton = "Enregistrer le nom",
        deleteTitle = "Supprimer le site",
        deleteMessage = "Voulez-vous vraiment supprimer {name} ?",
        deleteConfirmLabel = "Supprimer",
        deleteCancelLabel = "Annuler"
      }
    },
    impoundCreator = {
      title = "Créateur d'immobilisations",
      description = "Configurer les emplacements et points de spawn des enclos.",
      empty = "Aucun enclos n'est encore configuré.",
      keyboardHint = "Utiliser les touches fléchées pour naviguer dans la liste et les actions.",
      editTitle = "Marqueurs d'immobilisation",
      editSubtitle = "Utilisez le bouton épingle du bouton pour stocker vos coordonnées actuelles.",
      editKeyboardHint = "Utilisez les touches fléchées pour choisir un marqueur, gauche/droite pour choisir Positionner/effacer/supprimer, Entrée pour l'exécuter, Backspace pour revenir. Passez au-delà de la liste pour atteindre les boutons Ajouter.",
      missingEntry = "Aucune zone d'immobilisation trouvée.",
      actions = {
        newLot = "Nouvelle zone",
        add = {
          impound_delivery = "Ajouter une livraison",
          impound_spawn = "Ajouter une apparition"
        }
      },
      status = {
        set = "Définir",
        unset = "Effacer"
      },
      markers = {
        impound_lot = "Zone d'immobilisation",
        impound_spawn = "Apparition d'immobilisation",
        impound_delivery = "Dépose d'immobilisation"
      },
      modals = {
        createTitle = "Créer une zone",
        createButton = "Créer une zone",
        renameTitle = "Renommer la zone",
        renameButton = "Enregistrer le nom",
        deleteTitle = "Supprimer la zone",
        deleteMessage = "Voulez-vous vraiment supprimer {name} ?",
        deleteConfirmLabel = "Supprimer",
        deleteCancelLabel = "Annuler"
      }
    },
    impoundStorage = {
      title = "Stockage d'immobilisation",
      subtitle = "Ordre de livraison des véhicules stockés à livrer à la zone.",
      empty = "Aucun véhicule stocké pour cette zone.",
      emptyAll = "Aucun véhicule immobilisé trouvé.",
      unknownModel = "Inconnu",
      unknownLot = "Inconnu",
      sections = {
        impounds = "Immobilisations actives",
        stored = "Véhicules stockés"
      },
      columns = {
        plate = "Plaque",
        model = "Modèle",
        stored = "Stocké",
        lot = "Zone",
        status = "Statut",
        fee = "Frais de stockage"
      },
      actions = {
        deliver = "Commander la livraison",
        allowPickup = "Autoriser la collecte",
        seize = "Marquer comme saisi",
        seized = "Saisi",
        close = "Fermer",
        refresh = "Actualiser"
      },
      status = {
        pickup = "Collecte autorisée",
        seized = "Saisi"
      },
      time = {
        days = "{count} jour(s)"
      },
      errors = {
        load = "Impossible de charger les véhicules stockés.",
        deliver = "Impossible de commander la livraison.",
        seized = "Ce véhicule est saisi pour enquête.",
        update = "Impossible de mettre à jour le statut d'immobilisation."
      }
    },
    impoundDecision = {
      title = "Décision d'immobilisation",
      message = "Décider si {vehicle} peut être récupéré ou saisi pour enquête.",
      vehicleFallback = "former le véhicule",
      allowPickup = "Permettre la prise en charge",
      seize = "Saisir pour enquête"
    },
    jailCreator = {
      title = "Créateur de prison",
      description = "Placer les points de spawn de prison et gérer les emplacements.",
      empty = "Aucune prison configurée pour le moment.",
      keyboardHint = "Utiliser les touches fléchées pour naviguer dans la liste et les actions.",
      editTitle = "Marqueurs de prison",
      editSubtitle = "Utilisez le bouton d'épingle de la carte pour stocker vos coordonnées actuelles.",
      editKeyboardHint = "Utilisez les touches fléchées pour choisir un marqueur, gauche/droite pour choisir Définir/Effacer/Supprimer, Entrée pour l'exécuter, Retour arrière pour revenir. Passez la liste pour atteindre les boutons Ajouter.",
      missingEntry = "Prison introuvable.",
      actions = {
        newJail = "Nouvelle prison"
      },
      modals = {
        createTitle = "Créer une prison",
        createButton = "Créer une prison",
        renameTitle = "Renommer la prison",
        renameButton = "Enregistrer le nom",
        deleteTitle = "Supprimer la prison",
        deleteMessage = "Voulez-vous vraiment supprimer {name} ?",
        deleteConfirmLabel = "Supprimer",
        deleteCancelLabel = "Annuler"
      }
    },
    jailInmates = {
      title = "Échange de détenus",
      close = "Fermer",
      trade = "Faire un échange",
      requiredLabel = "Vous donnez",
      rewardLabel = "Vous recevez",
      acceptedLabel = "Accepte",
      contrabandLabel = "Contrebandes",
      npc = {
        alcoholic = "Bouzeur du bloc cellulaire",
        drugDealer = "Vendeur de la laverie",
        doctor = "Médecin de la prison",
        canteen = "Cuisinier de la cantine"
      },
      dialogs = {
        alcoholic = {
          one = "J'ai échangé mon dessert contre une moppe une fois. Meilleur jour de ma vie.",
          two = "Si cet endroit avait un bar, je serais employé du mois.",
          three = "Tu as quelque chose qui sent comme des sols propres et de mauvaises décisions ?",
          four = "Je l'appelle le parfum de la prison. Tu l'appelles de l'alcool de nettoyage."
        },
        drugDealer = {
          one = "Tu as quelque chose de piquant dans la poubelle ? Je paye en cigarettes.",
          two = "Baisse ton ton, les gardes pensent que je suis dans un club de lecture.",
          three = "Amène-moi de la contrebande et je rendrai ta journée fumable.",
          four = "Les ordures cachent des trésors. Je suis l'évaluateur de trésors."
        },
        doctor = {
          one = "Reste immobile. Ce sera rapide.",
          two = "Pas de charge aujourd'hui. Reste simplement à l'écart des ennuis.",
          three = "Tu as l'air mal en point. Laisse-moi te soigner.",
          four = "Les heures de la clinique ne finissent jamais ici."
        },
        canteen = {
          one = "Plateau frais aujourd'hui. Faites la queue et continuez à avancer.",
          two = "Tu veux un repas chaud ou une conférence ?",
          three = "Un bon comportement obtient des seconds services. La plupart du temps.",
          four = "J'ai vu des appétits pires."
        }
      },
      doctor = {
        costLabel = "Coût",
        rewardLabel = "Traitement",
        actionLabel = "Obtenir un traitement",
        costValue = "Gratuit",
        rewardValue = "Traitement complet"
      },
      canteen = {
        costLabel = "Coût",
        rewardLabel = "Repas",
        actionLabel = "Réclamer le repas",
        costValue = "Gratuit",
        rewardValue = "Forfait alimentaire"
      },
      items = {
        cleaning_alcohol = "Alcool de nettoyage",
        cigarettes = "Cigarettes",
        coke = "Coca",
        weed = "Cannabis",
        burger = "Burger",
        water = "Eau"
      }
    },
    invites = {
      title = "Invitation à l'emploi",
      description = "Rejoindre {job} en tant que {role} ?",
      invitedBy = "Invité par {name}",
      expires = "Cette offre expire bientôt.",
      accept = "Accepter",
      decline = "Refuser",
      errors = {
        missing = "Invitation non disponible.",
        failed = "Échec de la réponse à l'invitation."
      }
    },
    stationCreator = {
      title = "Créateur de station",
      description = "Configurer les positions des marqueurs de station.",
      empty = "Aucune station configurée pour l'instant.",
      keyboardHint = "Utilisez ↑/↓ pour sélectionner, ←/→ pour changer d'action, Entrée pour confirmer, Backspace pour fermer.",
      editTitle = "Marqueurs de station",
      editSubtitle = "Utiliser le bouton épingle pour stocker vos coordonnées actuelles.",
      editKeyboardHint = "Utiliser ↑/↓ pour choisir un marqueur, ←/→ pour choisir Configurer/Supprimer/effacer, Entrée pour l'exécuter, Backspace pour revenir.",
      sections = {
        markers = "Marqueurs",
        zone = "Zone de prison"
      },
      zone = {
        subtitle = "Ajouter des points de zone pour définir la frontière de la prison.",
        hint = "Utilisez le bouton épingle pour ajouter des points. Supprimez les points avec l'icône poubelle.",
        empty = "Aucun point de zone pour l'instant.",
        pointLabel = "Point de zone {index}",
        actions = {
          add = "Ajouter un point de zone",
          update = "Mettre à jour",
          clear = "Effacer la zone"
        }
      },
      missingStation = "Station non trouvée.",
      actions = {
        newStation = "Nouvelle station",
        editJobBlip = "Modifier le blip métier",
        newJail = "Nouvelle prison",
        add = {
          wardrobe = "Ajouter un marqueur de placard",
          garage_vehicle_menu = "Ajouter une interaction au garage de véhicules",
          garage_vehicle_spawn = "Ajouter une apparition de garage de véhicules",
          garage_vehicle_park = "Ajouter un stationnement de garage de véhicules",
          garage_helicopter_menu = "Ajouter une interaction de porte d'héliport",
          garage_helicopter_spawn = "Ajouter une apparition d'héliport",
          garage_helicopter_park = "Ajouter un stationnement d'héliport",
          garage_boat_menu = "Ajouter une interaction sur le quai",
          garage_boat_spawn = "Ajouter une apparition sur le quai",
          garage_boat_park = "Ajouter un parking sur le quai",
          boss_menu = "Ajouter un marqueur de menu du chef",
          wholesale_shop = "Ajouter un marqueur de boutique en gros",
          duty_terminal = "Ajouter un marqueur de terminal de service",
          public_forms = "Ajouter un kiosque de formulaires publics",
          jail_solitary_cell = "Ajouter une cellule solitaire"
        }
      },
      status = {
        set = "Définir",
        unset = "Annuler"
      },
      markers = {
        position = "Position de la station",
        storage = "Stockage",
        locker = "Casier",
        wardrobe = "Armoire",
        duty_terminal = "Terminal de service",
        public_forms = "Kiosque de formulaires publics",
        boss_menu = "Menu du chef",
        garage_vehicle_menu = "Interaction avec le garage à véhicules",
        garage_vehicle_spawn = "Apparition du véhicule dans le garage",
        garage_vehicle_park = "Stationnement du véhicule dans le garage",
        garage_helicopter_menu = "Interaction avec l'hélipad",
        garage_helicopter_spawn = "Apparition sur l'hélipad",
        garage_helicopter_park = "Stationnement sur l'hélipad",
        garage_boat_menu = "Interaction sur le quai",
        garage_boat_spawn = "Apparition sur le quai",
        garage_boat_park = "Parking sur le quai",
        wholesale_shop = "Boutique en gros",
        jail_spawn = "Apparition en prison",
        jail_release = "Point de libération",
        jail_menu = "Terminal de prison",
        jail_job_npc = "PNJ du travail en prison",
        jail_inmate_alcoholic = "Incarcéré : Alcoolique",
        jail_inmate_drugdealer = "Incarcéré : Marchand de drogue",
        jail_inmate_doctor = "Incarcéré : Médecin",
        jail_canteen_cook = "Cuisinier de la cantine",
        jail_dumpster = "Conteneur à ordures de la prison",
        jail_box_dropoff = "Dépose de livraison",
        jail_electric_box = "Boîte électrique",
        jail_fence_cut = "Point de coupe de la clôture",
        jail_fence_exit = "Sortie de la clôture",
        jail_solitary_cell = "Cellule solitaire",
        jail_confiscated_return = "Objets confisqués"
      },
      modals = {
        createTitle = "Créer une station",
        createButton = "Créer une station",
        renameTitle = "Renommer la station",
        renameButton = "Enregistrer le nom",
        deleteTitle = "Supprimer la station",
        deleteMessage = "Voulez-vous vraiment supprimer {name} ?",
        deleteConfirmLabel = "Supprimer",
        deleteCancelLabel = "Annuler",
        jobBlipTitle = "Blip métier : {job}",
        jobBlipMessage = "Configurez le blip de la station pour ce métier. Désactivez-le si ce métier ne doit pas avoir de blip.",
        jobBlipSave = "Enregistrer le blip",
        jobBlipReset = "Réinitialiser",
        jobBlipInvalidNumber = "Valeur invalide pour {field}."
      },
      blip = {
        enabled = "Afficher le blip",
        useStationName = "Ajouter le nom de la station",
        shortRange = "Courte portée",
        name = "Libellé",
        sprite = "Icône",
        color = "Couleur",
        scale = "Taille",
        display = "Affichage"
      }
    },
    jailAssign = {
      title = "Envoyer en prison",
      selectPlayer = "Sélectionner un joueur",
      selectPlayerPlaceholder = "Choisir un joueur",
      selectJail = "Sélectionner une prison",
      selectJailPlaceholder = "Choisir un emplacement de prison",
      solitaryLabel = "Isolement cellulaire",
      solitaryUnavailable = "Aucune cellule solitaire configurée pour cette prison.",
      durationLabel = "Durée (en mois)",
      monthHint = "1 mois = {minutes} minutes",
      cancelButton = "Annuler",
      assignButton = "Envoyer en prison",
      assigning = "Envoi en cours...",
      noPlayers = "Aucun joueur à proximité dans {range} m.",
      noJails = "Aucune prison configurée pour l'instant. Utilisez d'abord le créateur de prisons.",
      spawnMissing = "Cette prison n'a pas de point d'apparition défini.",
      jailStatusReady = "Point d'apparition prêt",
      jailStatusMissing = "Aucun point d'apparition défini",
      success = "Joueur envoyé en prison pour {months} mois.",
      errors = {
        invalid_target = "Sélectionnez un joueur à proximité et une prison.",
        spawn_not_set = "Cette prison n'a pas de point d'apparition défini.",
        solitary_unavailable = "Aucune cellule de solitude configurée pour cette prison.",
        failed = "Échec de l'envoi du joueur en prison."
      }
    },
    bolos = {
      eyebrow = "Tableau BOLO",
      title = "BOLOs",
      listed = "listé",
      unknown = "Inconnu",
      search = {
        placeholder = "Rechercher les BOLO par titre, identifiant, type ou tag"
      },
      actions = {
        refresh = "Rafraîchir",
        manageTypes = "Gérer les types",
        new = "Nouveau BOLO",
        back = "Retour à la liste",
        add = "Ajouter",
        addPhoto = "Ajouter une photo",
        remove = "Supprimer"
      },
      state = {
        loading = "Chargement des BOLOs...",
        empty = "Aucun BOLO ne correspond aux filtres actuels.",
        saving = "Enregistrement...",
        noTags = "Aucun tag assigné.",
        noReports = "Aucun rapport lié pour le moment."
      },
      detail = {
        summary = "Résumé du BOLO",
        untitled = "BOLO sans titre"
      },
      fields = {
        title = "Titre du BOLO",
        id = "ID du BOLO",
        type = "Type",
        status = "Statut",
        priority = "Priorité",
        created = "Créé",
        updated = "Dernière mise à jour"
      },
      placeholders = {
        title = "Titre du BOLO",
        id = "Généré automatiquement si vide",
        type = "Sélectionner le type",
        description = "Ajouter une description...",
        tag = "Ajouter un tag",
        reportSelect = "Sélectionner un rapport"
      },
      sections = {
        description = "Description",
        descriptionSubtitle = "Capturer les détails et les instructions.",
        tags = "Étiquettes",
        tagsSubtitle = "Attacher des identifiants rapides pour le BOLO.",
        reports = "Rapports liés",
        reportsSubtitle = "Joindre des fichiers de rapport associés.",
        gallery = "Galerie",
        gallerySubtitle = "Attacher des images de la galerie au BOLO."
      },
      gallery = {
        title = "Sélectionner une photo",
        subtitle = "Choisissez une image de la galerie à attacher au BOLO.",
        loading = "Chargement de la galerie...",
        empty = "Aucune photo de la galerie disponible.",
        photoAlt = "Photo de la galerie"
      },
      typesModal = {
        title = "Types de BOLO",
        subtitle = "Ajouter ou supprimer des types de BOLO pour cet appareil.",
        placeholder = "Ajouter un type de BOLO",
        empty = "Aucun type de BOLO configuré."
      },
      types = {
        person = "Personne",
        vehicle = "Véhicule",
        property = "Propriété",
        missing = "Disparu",
        other = "Autre"
      },
      status = {
        active = "Actif",
        located = "Localisé",
        closed = "Fermé",
        cancelled = "Annulé"
      },
      priority = {
        low = "Faible",
        medium = "Moyen",
        high = "Élevé",
        critical = "Critique"
      },
      errors = {
        load = "Impossible de charger les BOLO.",
        save = "Impossible d'enregistrer le BOLO.",
        titleRequired = "Saisissez un titre pour le BOLO avant d'enregistrer.",
        typeRequired = "Sélectionnez un type de BOLO avant d'enregistrer.",
        gallery = "Impossible de charger la galerie."
      }
    },
    warrants = {
      eyebrow = "Coffre à mandats",
      title = "Mandats",
      listed = "listé",
      unknown = "Inconnu",
      search = {
        placeholder = "Rechercher des mandats par titre, id, type ou tag"
      },
      actions = {
        refresh = "Rafraîchir",
        manageTypes = "Gérer les types",
        new = "Nouveau mandat",
        back = "Retour à la liste",
        add = "Ajouter",
        addPhoto = "Ajouter une photo",
        remove = "Supprimer"
      },
      state = {
        loading = "Chargement des mandats...",
        empty = "Aucun mandat ne correspond aux filtres actuels.",
        saving = "Enregistrer...",
        noTags = "Aucune balise assignée.",
        noReports = "Aucun rapport lié pour le moment.",
        noOffences = "Aucune infraction liée pour le moment."
      },
      detail = {
        summary = "Résumé du mandat",
        untitled = "Mandat sans titre"
      },
      fields = {
        title = "Titre du mandat",
        id = "ID de mandat",
        type = "Type",
        status = "Statut",
        priority = "Priorité",
        created = "Créé",
        updated = "Dernière mise à jour"
      },
      placeholders = {
        title = "Titre du mandat",
        id = "Généré automatiquement si vide",
        type = "Sélectionner le type",
        description = "Ajouter une description...",
        tag = "Ajouter une étiquette",
        reportSelect = "Sélectionner un rapport",
        offenceSelect = "Sélectionner une infraction"
      },
      sections = {
        description = "Description",
        descriptionSubtitle = "Capturer le résumé et les instructions.",
        tags = "Étiquettes",
        tagsSubtitle = "Joindre des identifiants rapides pour le mandat.",
        reports = "Rapports liés",
        reportsSubtitle = "Joindre des fichiers de rapport associés.",
        offences = "Infractions",
        offencesSubtitle = "Lier les infractions liées à ce mandat.",
        gallery = "Galerie",
        gallerySubtitle = "Joindre des images de la galerie au mandat."
      },
      gallery = {
        title = "Sélectionner une photo",
        subtitle = "Choisir une image de la galerie à joindre au mandat.",
        loading = "Chargement de la galerie...",
        empty = "Aucune photo de la galerie disponible.",
        photoAlt = "Photo de la galerie"
      },
      typesModal = {
        title = "Types de mandat",
        subtitle = "Ajouter ou supprimer des types de mandat pour cet appareil.",
        placeholder = "Ajouter un type de mandat",
        empty = "Aucun type de mandat configuré."
      },
      types = {
        arrest = "Arrêt",
        search = "Rechercher",
        bench = "Banc",
        probation = "Libération conditionnelle"
      },
      status = {
        active = "Actif",
        served = "Servi",
        expired = "Expiré",
        cancelled = "Annulé"
      },
      priority = {
        low = "Faible",
        medium = "Moyen",
        high = "Élevé",
        critical = "Critique"
      },
      errors = {
        load = "Impossible de charger les mandats.",
        save = "Impossible d'enregistrer le mandat.",
        titleRequired = "Veuillez entrer un titre de mandat avant de sauvegarder.",
        typeRequired = "Veuillez sélectionner un type de mandat avant de sauvegarder.",
        gallery = "Impossible de charger la galerie."
      }
    },
    prison = {
      eyebrow = "Journal de détention",
      title = "Prison",
      listed = "listé",
      search = {
        placeholder = "Rechercher par nom ou ID"
      },
      filters = {
        all = "Tous",
        label = "Statut",
        placeholder = "Statut"
      },
      actions = {
        refresh = "Rafraîchir",
        back = "Retour à la liste",
        saveDuration = "Enregistrer la durée",
        minusMinutes = "-15 min",
        minusSmall = "-5 min",
        plusSmall = "+5 min",
        plusMinutes = "+15 min",
        saveNotes = "Enregistrer les notes",
        saveWarrant = "Lier un mandat",
        addOffence = "Ajouter une infraction",
        setSolitary = "Envoyer en isolement",
        setGeneral = "Retour à la population générale"
      },
      state = {
        loading = "Chargement des prisonniers...",
        empty = "Aucun prisonnier ne correspond aux filtres actuels.",
        saving = "Enregistrement...",
        noOffences = "Aucune infraction encore liée."
      },
      labels = {
        mugshot = "Photo d'identité"
      },
      detail = {
        summary = "Résumé du prisonnier"
      },
      fields = {
        booked = "Réservé",
        remaining = "Temps restant",
        identifier = "Identifiant",
        unknown = "Inconnu",
        remainingMinutes = "Minutes restantes",
        warrant = "Mandat",
        offences = "Infractions",
        housing = "Logement"
      },
      sections = {
        duration = "Durée de la peine",
        durationSubtitle = "Ajuster le temps restant en minutes.",
        notes = "Notes",
        notesSubtitle = "Consigner les observations pour cette peine.",
        links = "Mandat et infractions liés",
        linksSubtitle = "Joindre le mandat et les infractions liés à ce séjour.",
        housing = "Logement",
        housingSubtitle = "Passer de l'isolement à la population générale."
      },
      placeholders = {
        note = "Ajouter des notes...",
        warrant = "Sélectionner un mandat",
        offence = "Sélectionner une infraction"
      },
      status = {
        in_prison = "En prison",
        breaked_out = "Évadé",
        released = "Libéré gratuitement"
      },
      solitary = {
        active = "Isolement cellulaire",
        inactive = "Population générale",
        badge = "Isolement"
      },
      duration = {
        minutesOnly = "{minutes}m restantes",
        full = "{hours}h {minutes}m restant"
      },
      linked = {
        warrantFallback = "Mandat"
      },
      date = {
        unknown = "Inconnu"
      },
      errors = {
        load = "Impossible de charger les prisonniers.",
        duration = "Impossible de mettre à jour la durée.",
        note = "Impossible d'enregistrer la note.",
        links = "Impossible de mettre à jour les liens.",
        solitary = "Impossible de mettre à jour la réclusion solitaire.",
        solitary_unavailable = "Aucune cellule de réclusion configurée pour cette prison."
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
        title = "Fonctionnalites",
        subtitle = "Activez ou desactivez les fonctionnalites de la ressource pour tous les jobs configures.",
        instantTuning = { label = "instantTuning", description = "" },
        partsDelivery = { label = "Livraison de pieces", description = "Activer les commandes de pieces d atelier et les zones de livraison." },
        carryItems = { label = "Manutention physique des pieces", description = "Obliger le transport des pieces livrees dans l atelier." },
        nitro = { label = "nitro", description = "" },
        antiLag = { label = "antiLag", description = "" },
        twoStep = { label = "twoStep", description = "" },
        wheelDamage = { label = "Degats des roues", description = "Activer les degats realistes des roues et les reparations." },
        customHandling = { label = "customHandling", description = "" },
        mileageHud = { label = "HUD kilometrage", description = "Afficher le kilometrage du vehicule pendant la conduite." },
        workshopLift = { label = "Pont elevateur", description = "Activer les points de pont elevateur utilisables dans les ateliers." }
      },
globalSettings = { title = "Global settings", notice = "These values apply to all configured jobs. Saving them from this job updates the behavior globally." },
      tuning = { globalTitle = "Global pricing settings", globalBadge = "Global", globalNotice = "These values apply to all configured jobs. Saving them from this job updates pricing behavior globally.",
        nitroAccess = "Accès nitro pour ce métier",
        nitroAccessHelp = "Remplacer le paramètre global de la fonctionnalité Nitro pour ce métier de mécanicien.",
        nitroAccessInherit = "Utiliser le paramètre Nitro global",
        nitroAccessEnabled = "Activer le Nitro pour ce métier",
        nitroAccessDisabled = "Désactiver le Nitro pour ce métier",
      },
      fields = { allowedJobs = "Allowed jobs", animationDict = "Animation dict", animationName = "Animation name", blip = "Blip", bone = "Bone", category = "Category", color = "Job color", consumeItems = "Consume items", cost = "Cost", distance = "Distance", enabled = "Enabled", garageType = "Garage type", heading = "Heading", item = "Item", jobName = "Job name", label = "Label", marker = "Marker", mechanicOnly = "Mechanic", name = "Name", offsetX = "Offset X", offsetY = "Offset Y", offsetZ = "Offset Z", offDutyEnabled = "Off-duty enabled", offDutyJob = "Off-duty job", ped = "Ped", pedModel = "Ped model", price = "Price", prop = "Prop", requiredItems = "Required items", scenario = "Scenario", sprite = "Sprite", stage = "Stage", transport = "Transport", trunkCapacity = "Trunk capacity", type = "Type", value = "Value", x = "X", y = "Y", z = "Z",
        minGrade = "Grade minimum",
        livery = "Livrée",
        fuelType = "Type de carburant",
        primaryColor = "Couleur principale",
        secondaryColor = "Couleur secondaire",
        pearlescentColor = "Couleur nacrée",
        wheelColor = "Couleur des roues",
        extras = "Extras",
        extraId = "ID d'extra",
        propCounts = "Limites de props",
        count = "Limite",
        properties = "Propriétés du véhicule",
        property = "Propriété",
      },
      placeholders = { allowedJobs = "mechanic, tuner", itemName = "Item name", jobName = "job name", label = "Label", model = "Model", vehicleName = "Name",
        liveryIndex = "e.g. 0",
        paintIndex = "0-160",
        propCounts = "{ \"prop_model\": 4 }",
        properties = "{ \"windowTint\": 1 }",
      },
      fuelTypes = {
        default = "Par défaut (ordinaire)",
        regular = "Ordinaire",
        plus = "Plus",
        premium = "Premium",
        diesel = "Diesel",
      },
      descriptions = { color = "Color used by Sky Jobs menus, blips, and job UI accents.", jobName = "Framework job name registered for this job.", offDutyEnabled = "Enable an off-duty counterpart for this job.", offDutyJob = "Job name used when this employee goes off duty." },
      messages = { empty = "No jobs configured yet.", featuresSaved = "Features saved.", invalidJson = "Correct invalid JSON fields before saving.", loading = "Loading jobs...", nameExists = "A job with this job name already exists.", noTuningOptions = "No options configured in this category.", saved = "Settings saved.", saveFailed = "Unable to save changes." },
      locations = { addSubtitle = "Choose which point type to place.", addTitle = "Add location point", deleteFailed = "Unable to delete location.", deleteSaved = "Location removed. Save settings to apply it.", emptySubtitle = "This configurator has no registered location definitions.", emptyTitle = "No locations configured.", garageMenu = "Menu", garagePark = "Park", garageSpawn = "Spawn", placeFailed = "Unable to place location.", placementHint = "Press Enter to place and Backspace to cancel.", placementSaved = "Location updated. Save settings to apply it.", placementTitle = "Placement mode", teleported = "Teleported to location.", teleportFailed = "Unable to teleport to location.", unset = "Not set" },
      carryItems = { missingProp = "Enter a prop model before opening placement.", placementFailed = "Unable to edit attach placement.", placementSaved = "Attach placement updated. Save settings to apply it.", selectItem = "Select delivery item" },
      extensions = { invalidJson = "JSON invalide. Corrigez la syntaxe avant d enregistrer.", jsonObjectRequired = "La valeur doit etre un objet JSON.", partsDeliveryShop = "Boutique de livraison de pieces", tuningCostProfile = { label = "Prix de tuning", description = "Configurez les couts de performance, d apparence, de roues et d options speciales pour ce job." } },
garageTypes = { boat = "Boat", helicopter = "Helicopter", vehicle = "Vehicle" },
      colorPopup = { title = "Job color" },
      dialogs = { delete = { cancel = "Cancel", confirm = "Delete", message = "Delete {name}?", title = "Delete job" } },
      screenPosition = { preview = "HUD" },
      interactions = { title = "Interactions", empty = "No interactions configured.", addMarkerSetting = "Add marker setting", noPedSelected = "No ped selected", headers = { interaction = "Interaction", key = "Key", marker = "Marker", blip = "Blip", npc = "NPC" }, tabs = { behavior = "Behavior", marker = "Marker", blip = "Blip", npc = "NPC" }, status = { on = "On", off = "Off" }, fields = { unique = "Unique", forceMarkerInteraction = "Force marker interaction", interactionDistance = "Interaction distance", placementModel = "Placement model" }, help = { unique = "Limits the interaction type to one configured point for a location when enabled.", forceMarkerInteraction = "Forces marker-style interaction handling even when target/NPC interaction support is available.", interactionDistance = "Maximum distance from the point where the player can use the interaction.", placementModel = "Object model shown while placing this interaction in the creator." } },
      assetPicker = { search = "Search", allCategories = "All categories", itemCount = "{count} items", markerTitle = "Marker type", markerSubtitle = "Choose a DrawMarker type.", blipTitle = "Blip sprite", blipSubtitle = "Choose a map blip sprite.", pedTitle = "Ped model", pedSubtitle = "Choose a FiveM ped model.", chooseMarker = "Choose marker", chooseBlip = "Choose blip", choosePed = "Choose ped" },
      markerFields = { posX = "Position X", posY = "Position Y", posZ = "Position Z", dirX = "Direction X", dirY = "Direction Y", dirZ = "Direction Z", rotX = "Rotation X", rotY = "Rotation Y", rotZ = "Rotation Z", scaleX = "Scale X", scaleY = "Scale Y", scaleZ = "Scale Z", red = "Red", green = "Green", blue = "Blue", alpha = "Alpha", bobUpAndDown = "Bob up/down", faceCamera = "Face camera", rotationOrder = "Rotation order", rotate = "Rotate", textureDict = "Texture dict", textureName = "Texture name", drawOnEnts = "Draw on entities" },
      instantTuning = { title = "Instant Tuning", defaultLabel = "Default label", defaultLabelHelp = "Text shown at instant tuning points.", interactionDistanceHelp = "Default distance from which a point can be used.", priceMultiplier = "Price multiplier", priceMultiplierHelp = "Multiplier applied to instant tuning prices.", forceMarkerHelp = "Forces marker-style interaction handling even when target support is available.", mechanicOnlyHelp = "Restricts every instant tuning point to configured mechanic jobs.", allowedJobsHelp = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", emptyLocations = "No instant tuning locations configured.", emptyLocationsHelp = "Add a location, then use Set to capture your current position." }
  ,

      configs = { sky_mechanicjob = { title = "Jobs mecaniciens", subtitle = "Configurez les jobs mecaniciens, boutiques, vehicules et emplacements d atelier." } },
      settingSections = { general = "General", partsTheft = "Vol de pieces", vehicleCare = "Entretien vehicule", wear = "Usure", wheelDamage = "Degats des roues", mileageHud = "HUD kilometrage", instantTuning = "Instant Tuning", carryItems = "Pieces transportables" },
      settingFields = { key = "Cle", label = "Label", name = "Nom de l item", amount = "Quantite", price = "Prix", item = "Item", repair = "Reparer avec kit", classId = "ID de classe", multiplier = "Multiplicateur", kilometersToZero = "Kilometres jusqu a zero", removeAfterUse = "Consommer l item", flow = "Flux d installation", transport = "Transport", prop = "Prop", bone = "Bone", x = "X", y = "Y", z = "Z", rx = "Rot X", ry = "Rot Y", rz = "Rot Z", category = "Categorie" },
      settings = {
        primaryColor = { label = "Couleur principale", description = "Main mechanic configurator color and default job color fallback. Use a hex value such as #EDC001." },
        orderInstallNonMinigameDurationMs = { label = "Duree installation simple", description = "Milliseconds used for order install steps that do not run a minigame." },
        tuningWorkshopRequireForInstall = { label = "Atelier requis pour installer", description = "Require tuning order installs to start and complete near a self-service tuning point." },
        tuningWorkshopRequireForRemoval = { label = "Atelier requis pour retirer", description = "Require tuning removals to start and complete near a self-service tuning point." },
        tuningWorkshopDistance = { label = "Distance atelier requise", description = "Maximum distance from a self-service tuning point for required install or removal actions." },
        addRevenueToSociety = { label = "Verser revenus a la societe", description = "Deposit paid tuning order money into the tuning job society account." },
        publicUsersSeePrices = { label = "Prix visibles au public", description = "Show regular tuning prices to non-mechanic public users." },
        fallbackVehicleValue = { label = "Valeur vehicule par defaut", description = "Value used when no vehicle price can be resolved." },
        priceType = { label = "Type de prix", description = "Percentage calculates each tuning cost from the vehicle price. Fixed uses the entered money amount.", options = { percentage = "Pourcentage", fixed = "Fixe" } },
        freeVehicles = { label = "Vehicules tuning gratuits", description = "Vehicle spawn models that receive free tuning orders.", itemLabel = "Vehicle model" },
        partsTheftItem = { label = "Outil de vol", description = "Inventory item used to steal wheels and catalytic converters." },
        partsTheftRemoveItemAfterUse = { label = "Consommer outil de vol", description = "Remove the theft tool item after a successful theft action." },
        partsTheftStolenWheelItem = { label = "Roue volee", description = "Inventory item awarded when wheels are stolen." },
        partsTheftCatalyticConverterItem = { label = "Catalyseur", description = "Inventory item awarded when a catalytic converter is stolen." },
        partsTheftDealerAccount = { label = "Compte paiement receleur", description = "Account used for stolen parts dealer payouts, such as money or bank." },
        partsTheftDealerSellDistance = { label = "Distance de vente receleur", description = "Maximum distance from the dealer to sell stolen parts." },
        partsTheftDispatchEnabled = { label = "Envoyer dispatch police", description = "Create a police dispatch when a wheel or catalytic converter is stolen." },
        partsTheftDispatchJobs = { label = "Jobs dispatch", description = "Job names that receive parts theft dispatches.", itemLabel = "Job name" },
        partsTheftDispatchTitle = { label = "Titre dispatch", description = "Title shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchMessage = { label = "Message dispatch", description = "Message shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchCooldownSeconds = { label = "Cooldown dispatch", description = "Seconds before the same vehicle part can create another dispatch." },
        partsTheftDealerItems = { label = "Items receleur", description = "Stolen items the dealer will buy and their payout values.", itemLabel = "Dealer item" },
        vehicleCareWashItem = { label = "Item lavage", description = "Inventory item used to wash a vehicle." },
        vehicleCareWashRemoveAfterUse = { label = "Consommer item lavage", description = "Remove the wash item after use." },
        vehicleCareWaxItem = { label = "Item cire", description = "Inventory item used to wax a vehicle." },
        vehicleCareWaxRemoveAfterUse = { label = "Consommer item cire", description = "Remove the wax item after use." },
        vehicleCareWaxCleanKilometers = { label = "Kilometres propres avec cire", description = "Distance a waxed vehicle stays clean." },
        vehicleCareRepairItem = { label = "Item reparation", description = "Inventory item used by the vehicle repair action." },
        vehicleCareRepairRemoveAfterUse = { label = "Consommer item reparation", description = "Remove the repair item after use." },
        vehicleCareRepairDurationMs = { label = "Duree reparation", description = "Repair progress duration in milliseconds." },
        vehicleCareRepairMaxDistance = { label = "Distance max reparation", description = "Maximum distance from the vehicle while repairing." },
        vehicleCareRepairVehicleDamage = { label = "Reparer degats vehicule", description = "Repair normal GTA vehicle damage when using the repair action." },
        vehicleCareRepairFixRealisticWheelDamage = { label = "Reparer degats roues realistes", description = "Also reset realistic wheel damage when using the repair action." },
        vehicleCareRepairWearParts = { label = "Pieces restaurees par le kit", description = "Choose which wear and service parts the repair item restores. Disable fluids here if oil, coolant, brake fluid, or transmission fluid should require the diagnostics repair flow.", itemLabel = "Wear part" },
        wearParts = { label = "Pieces d usure", description = "Vehicle wear parts, their lifetime distance, required repair item, item consumption, and install flow.", itemLabel = "Wear part", fields = { flow = { options = { wheel = "Wheel", performance = "Performance", underbody_neon = "Underbody / lift", oil_change = "Oil change", fluid_refill = "Fluid refill", catalytic_converter = "Catalytic converter", hood_install = "Hood install" } } } },
        wheelDamageDefaultMultiplier = { label = "Multiplicateur par defaut", description = "Base wheel damage multiplier." },
        wheelDamageOffroadWheelsMultiplier = { label = "Multiplicateur roues off-road", description = "Multiplier used when the vehicle has off-road wheels." },
        wheelDamageVehicleClassMultipliers = { label = "Multiplicateurs par classe vehicule", description = "Damage multipliers per GTA vehicle class.", itemLabel = "Vehicle class" },
        mileageHudDigits = { label = "Chiffres", description = "Number of digits shown in the mileage HUD." },
        mileageHudPosition = { label = "Position", description = "Drag the mileage HUD preview to the desired screen position." },
        partsDeliveryTimeSeconds = { label = "Temps de livraison", description = "Seconds between ordering parts and the delivery becoming ready." },
        partsDeliveryTimerHudEnabled = { label = "Afficher timer livraison", description = "Show a small in-game timer HUD after a parts order is placed." },
        partsDeliveryTimerHudPosition = { label = "Position timer", description = "Drag the parts delivery timer HUD preview to the desired screen position." },
        partsDeliveryOwnCard = { label = "Paiement carte personnelle", description = "Allow players to pay parts delivery orders with their own money." },
        partsDeliveryCompanyCard = { label = "Paiement carte societe", description = "Allow parts delivery orders to use company funds." },
        partsDeliveryOpenDurationMs = { label = "Duree ouverture", description = "Milliseconds required to unpack a ready parts delivery." },
        instantTuningInteractionDistance = { label = "Distance interaction", description = "Default distance for using instant tuning points." },
        instantTuningForceMarkerInteraction = { label = "Forcer interaction marqueur", description = "Use marker-style E interaction even when target support is enabled." },
        instantTuningMechanicOnly = { label = "Mecaniciens seulement", description = "Restrict all instant tuning locations to configured mechanic jobs." },
        instantTuningAllowedJobs = { label = "Jobs autorises", description = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", itemLabel = "Job name" },
        instantTuningPriceMultiplier = { label = "Multiplicateur prix", description = "Multiplier applied to instant tuning prices." },
        instantTuningLabel = { label = "Label par defaut", description = "Default text shown at instant tuning points." },
        instantTuningMarkerEnabled = { label = "Marqueur active", description = "Draw a world marker at instant tuning locations." },
        instantTuningMarkerType = { label = "Type de marqueur", description = "GTA marker type used for instant tuning locations." },
        instantTuningBlipEnabled = { label = "Blip active", description = "Show map blips for instant tuning locations." },
        instantTuningBlipName = { label = "Nom blip", description = "Map blip name." },
        instantTuningBlipSprite = { label = "Sprite blip", description = "GTA blip sprite id." },
        instantTuningBlipColor = { label = "Couleur blip", description = "GTA blip color id." },
        instantTuningLocations = { label = "Emplacements", description = "Instant tuning points. Use 0 distance to inherit the default interaction distance.", itemLabel = "Locations" },
        carryItems = { label = "Pieces transportables", description = "Delivered parts that should become physical carried props.", itemLabel = "Carry item", fields = { transport = { options = { hand = "Main", forklift = "Chariot elevateur", engine_lift = "Chevre moteur" } } } }
      },
      settingValues = {
        tyres = "Pneus", brake_pads = "Plaquettes de frein", suspension = "Suspension", spark_plugs = "Bougies", engine_oil = "Huile moteur", coolant = "Liquide de refroidissement", brake_fluid = "Liquide de frein", transmission_fluid = "Liquide de transmission", clutch = "Embrayage", air_filter = "Filtre a air", traction_battery = "Batterie de traction", inverter = "Onduleur", catalytic_converter = "Catalyseur",
        vehicleClass_0 = "Compacts", vehicleClass_1 = "Sedans", vehicleClass_2 = "SUVs", vehicleClass_3 = "Coupes", vehicleClass_4 = "Muscle", vehicleClass_5 = "Classiques sportives", vehicleClass_6 = "Sports", vehicleClass_7 = "Super", vehicleClass_8 = "Motos", vehicleClass_9 = "Tout-terrain", vehicleClass_10 = "Industriels", vehicleClass_11 = "Utilitaires", vehicleClass_12 = "Vans", vehicleClass_13 = "Cycles", vehicleClass_14 = "Bateaux", vehicleClass_15 = "Helicopteres", vehicleClass_16 = "Avions", vehicleClass_17 = "Service", vehicleClass_18 = "Urgence", vehicleClass_19 = "Militaire", vehicleClass_20 = "Commercial", vehicleClass_21 = "Trains", vehicleClass_22 = "Monoplaces"
      }
  },
    jobConfigurator = {
      actions = {
        backToScripts = "Scripts"
      },
      selector = {
        title = "Configurateur de métiers",
        subtitle = "Choisissez le script de métier que vous souhaitez configurer.",
        description = "Sélectionnez la ressource que vous souhaitez configurer.",
        loading = "Chargement des configurateurs...",
        comingSoon = "Bientot",
        emptyTitle = "Aucun script configurable disponible.",
        emptySubtitle = "Vous n'avez accès à aucun configurateur de métier enregistré.",
        unavailable = "Non enregistré"
      }
    },
    billing = {
      title = "Émettre une facture",
      subtitle = "Facturer les citoyens à proximité pour des services.",
      selectLabel = "Sélectionner une personne",
      selectPlaceholder = "Choisir une personne",
      noPlayers = "Aucune personne à proximité dans {range} m.",
      amountLabel = "Montant de la facture",
      reasonLabel = "Raison (courte)",
      reasonPlaceholder = "Exemple : Service de patrouille",
      presetsLabel = "Infractions",
      presetSearchPlaceholder = "Rechercher une infraction ou une amende",
      presetNoMatches = "Aucune infraction ne correspond à votre recherche.",
      presetReasonHeader = "Infraction",
      presetAmountHeader = "Amende",
      presetCustomAmount = "Personnalisé",
      paperDefaultCategory = "Avis de violation de stationnement",
      ticketReceiptTitle = "Avis de citation",
      ticketReceiptSubtitle = "Enregistré à",
      ticketReceiptCitizenLabel = "Citoyen",
      ticketReceiptOfficerLabel = "Personnel émetteur",
      ticketReceiptReasonLabel = "Résumé de l'accusation",
      ticketReceiptAmountLabel = "Amende totale",
      ticketReceiptAcknowledge = "Reconnaître",
      cancelButton = "Annuler",
      submitButton = "Émettre une facture",
      submitting = "Envoi en cours...",
      success = "Facture émise avec succès.",
      paperTicketNumber = "Numéro de ticket",
      paperDate = "Date",
      paperTime = "Heure",
      paperCitizenLabel = "Citoyen",
      paperOfficerLabel = "Personnel",
      paperViolationLabel = "Infraction",
      paperNotice = "Paiement immédiat requis. En cas de non-paiement, vous risquez la mise en fourrière.",
      paperSignatureLabel = "Signature du personnel",
      paperTotalFine = "Amende totale",
      errors = {
        failed = "Impossible d'émettre la facture.",
        invalid_target = "Personne indisponible.",
        empty_reason = "Fournir une brève raison.",
        too_far = "Personne trop éloignée.",
        not_authorized = "Vous n'êtes pas autorisé à émettre des factures.",
        not_on_duty = "Vous devez être en service pour émettre des factures.",
        amount_out_of_range = "Montant de la facture en dehors de la plage autorisée.",
        insufficient_funds = "La personne ne peut pas payer cette charge.",
        player_unavailable = "Personne indisponible.",
        disabled = "Système de facturation désactivé."
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
