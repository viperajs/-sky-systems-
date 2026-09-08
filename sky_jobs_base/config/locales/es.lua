if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/config/locales/es.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

-- Spanish translation
Locales["es"] = {
  WardrobeHelpNotify = "Abrir vestuario",
  WardrobeTitle = "Armario",
  WardrobeCivilianMissing = "Aún no hay atuendo civil almacenado.",
  WardrobeCivilianRestored = "Atuendo civil cargado.",
  WardrobeUnsupportedFramework = "El armario no funciona con el framework seleccionado ({framework}).",
  WardrobeMissingSkinchanger = "El armario requiere que skinchanger este iniciado en ESX.",
  WardrobeMissingEsxSkin = "El armario requiere que esx_skin este iniciado en ESX.",
  WardrobeMissingQbClothing = "El armario requiere que qb-clothing este iniciado en {framework}.",
  WardrobeMissing17Movement = "El armario requiere que 17mov_CharacterSystem este iniciado.",
  WardrobeMissingQsAppearance = "El armario requiere que qs-appearance este iniciado.",
  WardrobeMissingAk47Clothing = "El armario requiere que ak47_clothing este iniciado.",
  WardrobeMissingAk47QbClothing = "El armario requiere que ak47_qb_clothing este iniciado.",
  WardrobeMissingTgiannClothing = "El armario requiere que tgiann-clothing este iniciado.",
  WardrobeMissingNfSkin = "El armario requiere que nf-skin este iniciado.",
  WardrobeMissingBlAppearance = "El armario requiere que bl_appearance este iniciado.",
  WardrobeMissingIzzyAppearance = "El armario requiere que izzy-appearance este iniciado.",
  WardrobeMissingCodemAppearance = "El armario requiere que codem-appearance este iniciado.",
  WardrobeMissingHexClothing = "El armario requiere que hex_clothing este iniciado.",
  WardrobeMissingIllenium = "El armario requiere que illenium-appearance este iniciado.",
  WardrobeCustomUnavailable = "La integracion personalizada del armario configurada no esta disponible.",
  WardrobeDisabled = "El armario esta desactivado en la configuracion.",
  WardrobeMissingRcoreClothing = "El armario requiere que rcore_clothing este iniciado.",
  WardrobeUnknownJob = "El trabajo del armario no está disponible.",
  GarageHelpNotify = "Abrir garaje",
  GarageTitle = "Garaje",
  HelicopterGarageHelpNotify = "Abrir helipuerto",
  BoatGarageHelpNotify = "Abrir muelle",
  GarageParkHelpNotify = "Estacionar el vehículo",
  HelicopterGarageParkHelpNotify = "Estacionar el helicóptero",
  BoatGarageParkHelpNotify = "Aparcar el barco",
  GarageParkDriverRequired = "Necesitas estar en el asiento del conductor para estacionar.",
  GarageParkInvalidVehicle = "Este vehículo no puede ser estacionado aquí.",
  GarageParkFailedNotify = "No se pudo estacionar el vehículo.",
  GarageSpawnBlockedNotify = "El punto de aparición está bloqueado.",
  StorageHelpNotify = "Acceder al almacenamiento",
  LockerHelpNotify = "Abrir taquilla",
  TrunkTitle = "Maletero",
  TrunkHelpNotify = "Acceder al maletero",
  TrunkPropRemoveHelp = "Eliminar prop colocado",
  TrunkUnavailable = "No se puede acceder a este maletero.",
  BossMenuHelpNotify = "Abrir gestión",
  Payroll = {
    title = "Nómina",
    paid = "Salario recibido: {amount}",
    insufficient = "No hay suficiente dinero en la caja de la empresa para tu salario.",
  },
  PublicFormsTitle = "Formularios públicos",
  PublicFormsHelpNotify = "Completar formularios públicos",
  PublicFormsUnavailable = "El quiosco de formularios públicos no está disponible.",
  WholesaleShopTitle = "Mayorista",
  WholesaleShopHelpNotify = "Abrir tienda al por mayor",
  WholesaleShopUnavailable = "Esta ubicación no tiene un proveedor de venta al por mayor configurado.",
  NoPermission = "No tienes permiso para usar este comando.",
  CameraUploadFailed = "Error al subir la cámara.",
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
    Title = "Pánico",
    Sent = "Botón de pánico activado.",
    NotOnDuty = "Debes estar de servicio para usar el botón de pánico.",
    Cooldown = "El botón de pánico está en enfriamiento. Espera {seconds}s.",
    MappingDescription = "Activar alerta de pánico",
    WaypointSet = "Punto de ruta marcado en la ubicación del pánico.",
    WaypointMissing = "No hay una ubicación de pánico activa.",
    LocationUnknown = "Ubicación desconocida",
    MissingItem = "Necesitas {item} para usar el botón de pánico.",
  },
  Ping = {
    Title = "Ping",
    Sent = "Ubicación compartida.",
    NotOnDuty = "Debes estar de servicio para enviar un ping.",
    Cooldown = "El ping está en enfriamiento. Espera {seconds}s.",
    MappingDescription = "Activar marcador de ubicación",
    LocationUnknown = "Ubicación desconocida",
    MissingItem = "Necesitas {item} para enviar un ping.",
  },
  HeliCam = {
    Title = "Cámara Heli",
    CamEnabled = "Cámara heli activada.",
    CamDisabled = "Cámara heli desactivada.",
    NotAuthorized = "No estás autorizado para usar la cámara heli.",
    NotOnDuty = "Debes estar de servicio para usar la cámara heli.",
    TooLow = "El helicóptero está demasiado bajo para activar la cámara.",
    TargetLocked = "Objetivo fijado.",
    TargetReleased = "Bloqueo del objetivo liberado.",
    TargetLost = "Objetivo perdido.",
    RappelDenied = "No puedes rapelar desde este asiento.",
    RappelStarted = "Rapel iniciado.",
    PhotoSaved = "Foto heli guardada en la galería.",
    PhotoFailed = "No se pudo guardar la foto heli.",
    Spotlight = {
      ForwardOn = "Foco encendido.",
      ForwardOff = "Foco apagado.",
      TrackingOn = "Foco de seguimiento activado.",
      TrackingOff = "Foco de seguimiento desactivado.",
      ManualOn = "Foco manual activado.",
      ManualOff = "Foco manual desactivado.",
      Brightness = "Brillo del foco: {value}",
      Radius = "Radio del foco: {value}"
    }
  },
  InteractionLabels = {
    job_garage              = "Cochera del trabajo",
    garage_vehicle_spawn    = "Punto de aparicion de vehiculo",
    garage_vehicle_park     = "Estacionamiento de vehiculo",
    garage_helicopter_menu  = "Hangar de helicoptero",
    garage_helicopter_spawn = "Punto de aparicion de helicoptero",
    garage_helicopter_park  = "Estacionamiento de helicoptero",
    garage_boat_menu        = "Muelle",
    garage_boat_spawn       = "Punto de aparicion de barco",
    garage_boat_park        = "Amarre de barco",
    boss_menu               = "Administracion",
    duty_terminal           = "Terminal de servicio",
    wardrobe                = "Vestuario",
    storage                 = "Almacen",
    locker                  = "Taquilla",
    wholesale_shop          = "Mayorista",
    public_forms            = "Formularios publicos",
    jail_terminal           = "Terminal de la cárcel",
    jail_jobs               = "Trabajos de la cárcel",
    jail_job_npc            = "Trabajos de la cárcel",
    jail_inmate_alcoholic   = "Recluso: Alcohólico",
    jail_inmate_drugdealer  = "Recluso: Traficante de drogas",
    jail_inmate_codelist    = "Recluso: Informante",
    jail_inmate_wirecutter  = "Recluso: Transportador de herramientas",
    jail_inmate_doctor      = "Médico de la cárcel",
    jail_canteen_cook       = "Cocinero de la cantina",
    jail_confiscated_return = "Objetos confiscados",
    jail_electric_box       = "Caja eléctrica",
    jail_fence_cut          = "Punto de corte de la cerca",
  },
  Nui = {
    IntlLocale = "es-ES",
    currency = "€",
    menuTitles = {
      locker = "Taquilla personal",
      storage = "Almacenamiento",
      trunk = "Almacenamiento de vehículos",
      ["trunk-props"] = "Props de vehículo",
      search = "Buscar",
      garage = "Garaje",
      vehshop = "Tienda de vehículos",
      management = "Gestión",
      shop = "Mayorista",
      ["impound-storage"] = "Almacenamiento de remolques",
      refunds = "Reembolsos"
    },
    menu = {
      goToVehicleShop = "Ir a la tienda de vehículos",
      backToGarage = "Volver al garaje"
    },
    radial = {
      empty = "No hay acciones disponibles en este momento.",
      errors = {
        generic = "Acción no disponible."
      },
      title = "Acciones de servicio",
      hint = "Selecciona una acción para realizar.",
      pressKey = "Presiona {key}",
      actions = {
        billing = {
          label = "Emitir factura",
          description = "Emitir factura a la persona más cercana.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "La facturación no está disponible.",
            notOnDuty = "Ve de servicio para emitir facturas.",
            notAuthorized = "No estás autorizado para emitir facturas.",
            noPatients = "No hay personas cercanas a facturar."
          }
        },
        panic = {
          label = "Botón de pánico",
          description = "Activa una alerta de pánico para tu ubicación actual.",
          states = {
            disabled = "El botón de pánico no está disponible.",
            notOnDuty = "Ve de servicio para usar el botón de pánico.",
            notAuthorized = "No estás autorizado para usar el botón de pánico.",
          }
        },
        tablet = {
          label = "Abrir tablet",
          description = "Abrir la interfaz de la tablet.",
          states = {
            notOnDuty = "Ponerse en servicio para usar la tableta.",
            notAuthorized = "No estás autorizado para usar la tableta.",
            missingItem = "Necesitas una tablet para esto."
          }
        },
        removeProp = {
          label = "Eliminar prop",
          description = "Eliminar un objeto cercano colocado.",
          states = {
            noNearby = "No hay objeto colocado cerca.",
            failed = "Error al eliminar el objeto."
          }
        },
        carryPatient = {
          label = "Transportar persona",
          description = "Transporta a la persona más cercana a un lugar seguro.",
          dropLabel = "Soltar persona",
          dropDescription = "Libera a la persona que estás transportando.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "La carga está deshabilitada.",
            beingCarried = "Ya estás siendo transportado.",
            inVehicle = "Sal del vehículo primero.",
            selfIncapacitated = "No estás lo suficientemente estable para transportar a alguien.",
            noPatients = "No hay personas cercanas para transportar.",
            tooFar = "Acércate más antes de transportar a alguien."
          }
        },
        playerSearch = {
          label = "Buscar persona",
          description = "Buscar a la persona más cercana.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "La búsqueda de jugadores no está disponible.",
            notOnDuty = "Ponerse en servicio para buscar personas.",
            notAuthorized = "No estás autorizado para buscar personas.",
            noPlayers = "No hay personas cercanas para buscar.",
            tooFar = "Acércate más antes de buscar.",
            inVehicle = "Sal del vehículo primero."
          }
        },
        handcuff = {
          label = "Esposar persona",
          description = "Esposa a la persona más cercana.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "El uso de esposas no está disponible.",
            notOnDuty = "Ponerse en servicio para usar esposas.",
            inVehicle = "Sal del vehículo primero.",
            targetInVehicle = "Quita a la persona del vehículo primero.",
            noPlayers = "No hay personas cercanas para esposar.",
            tooFar = "Acércate más antes de esposar.",
            missingItem = "Necesitas esposas para hacer esto.",
            alreadyCuffed = "Esa persona ya está esposada."
          }
        },
        unhandcuff = {
          label = "Quitar esposas",
          description = "Quitar esposas de la persona más cercana.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Quitar esposas no está disponible.",
            notOnDuty = "Ponerse en servicio para quitar esposas.",
            inVehicle = "Sal del vehículo primero.",
            targetInVehicle = "Quita a la persona del vehículo primero.",
            noPlayers = "No hay personas cercanas para quitarles las esposas.",
            tooFar = "Acércate más antes de quitar las esposas.",
            notCuffed = "Esa persona no está esposada."
          }
        },
        wheelClamp = {
          label = "Colocar cepo",
          description = "Coloca un cepo al vehículo más cercano.",
          states = {
            disabled = "Los cepos no están disponibles.",
            notOnDuty = "Ir en servicio para inmovilizar vehículos.",
            inVehicle = "Salir primero del vehículo.",
            noVehicle = "No hay vehículo cercano.",
            tooFarVehicle = "Acércate más al vehículo.",
            noWheel = "Acércate más a una rueda.",
            tooFar = "Acércate más a una rueda."
          }
        },
        wheelClampRemove = {
          label = "Retirar cepo",
          description = "Retira el cepo de la rueda del vehículo.",
          states = {
            disabled = "El bloqueo de rueda no está disponible.",
            notOnDuty = "Ir en servicio para quitar pinzas.",
            inVehicle = "Salir primero del vehículo.",
            noClamp = "No hay pinza de rueda cercana.",
            tooFar = "Acércate más a la pinza de rueda."
          }
        },
        jail = {
          label = "Enviar a prisión",
          description = "Detener al jugador más cercano en una cárcel configurada.",
          states = {
            notAuthorized = "No estás autorizado para enviar jugadores a la cárcel.",
            notOnDuty = "Ir en servicio para usar esta acción.",
            noPlayers = "No hay personas cercanas dentro del rango.",
            noJails = "No hay cárceles configuradas.",
            spawnNotSet = "Configura primero un punto de reclusión.",
            invalidTarget = "No se puede localizar a esa persona.",
            failed = "No se puede realizar esa acción."
          }
        }
      }
    },
    shop = {
      shoppingCart = "Carrito de compras",
      purchase = "Comprar",
      balance = "Fondos disponibles",
      catalog = "Catálogo de proveedores",
      empty = "No hay suministros disponibles en esta ubicación.",
      emptyCart = "Tu carrito está vacío.",
      insufficientFunds = "Fondos insuficientes para esta compra.",
      limitReached = "Límite alcanzado ({limit}).",
      errors = {
        invalidStation = "Estación inválida.",
        emptyBasket = "Cesta vacía.",
        unknown = "Error desconocido.",
        purchase = "Fallo al comprar la cesta."
      }
    },
    garage = {
      states = {
        stored = "Listo",
        parked = "En uso"
      },
      title = "Garaje",
      empty = "No hay vehículos de flota disponibles.",
      emptyAir = "No hay helicópteros disponibles en esta plataforma.",
      ownedTitle = "Flota propia",
      shopTitle = "Tienda de vehículos",
      shopBalance = "Fondos de facción",
      shopEmpty = "No hay vehículos disponibles para comprar en esta ubicación.",
      shopEmptyAir = "No hay helicópteros disponibles para comprar en esta plataforma.",
      emptyFleet = "Aún no se ha comprado ninguna flota.",
      noAccess = "Sin acceso",
      confirmSellTitle = "Confirmar venta",
      confirmSellConfirm = "Vender",
      confirmSellCancel = "Cancelar",
      confirmSellMessage = "¿Vender {name} por {price}?",
      confirmPurchaseTitle = "Confirmar compra",
      confirmPurchaseConfirm = "Comprar",
      confirmPurchaseCancel = "Cancelar",
      confirmPurchaseMessage = "¿Comprar {name} por {price}?",
      purchaseSuccessTitle = "Vehículo comprado",
      purchaseSuccessMessage = "{name} añadido a la flota.",
      defaultVehicleName = "Vehículo",
      stats = {
        topSpeed = "Velocidad máxima",
        acceleration = "Aceleración",
        braking = "Frenado",
        traction = "Tracción"
      },
      actions = {
        parkOut = "Estacionar fuera",
        buyVehicle = "Comprar vehículo",
        openTrunk = "Abrir maletero",
        editStretcher = "Editar camilla",
        sellVehicle = "Vender vehículo",
        changePlate = "Cambiar matrícula"
      },
      placeholders = {
        selectVehicle = "Seleccionar un vehículo para ver detalles.",
        statsLoading = "Cargando información del vehículo..."
      },
      errors = {
        loadVehicles = "No se pudo cargar los vehículos de la cochera.",
        loadStats = "No se pudieron cargar las estadísticas del vehículo.",
        parkOut = "No se pudo aparcar el vehículo.",
        unavailable = "Cochera no disponible.",
        vehicleUnavailable = "Vehículo no disponible.",
        purchase = "Error al comprar el vehículo.",
        openTrunk = "No se pudo abrir el maletero.",
        noAccess = "No tienes acceso a este vehículo.",
        stretcherEditor = "No se puede abrir el editor de camillas.",
        stretcherPermission = "Solo el rango más alto puede editar los accesorios de camillas.",
        sellVehicle = "Error al vender el vehículo.",
        editorUnavailable = "Editor no disponible.",
        changePlate = "No se pudo cambiar la matrícula."
      },
      changePlateTitle = "Cambiar matrícula",
      changePlateButton = "Aplicar",
      plateEditor = {
        button = "Editar matrícula",
        title = "Editar matrícula",
        hint = "Cambia la matrícula de este vehículo.",
        save = "Guardar matrícula",
        errors = {
          empty = "Introduce una matrícula.",
          invalid = "La matrícula no es válida.",
          update = "No se pudo actualizar la matrícula."
        }
      },
      status = {
        parkedBy = "Última salida por {name}",
        unknownDriver = "Desconocido"
      }
    },
    duty = {
      fields = {
        grade = "Rango",
        location = "Estación",
        name = "Nombre",
        badge = "Insignia"
      },
      instructions = {
        drag = "Arrastra tu tarjeta de empleado al sensor para gestionar tu turno.",
        dragCard = "Arrastra la tarjeta del empleado al sensor para comenzar tu turno."
      },
      screen = {
        welcome = "Bienvenido {name}",
        goodbye = "Turno finalizado. Cuídate, {name}.",
        ready = "Acceso al turno concedido.",
        completed = "El turno terminó con éxito.",
        idleTitle = "Esperando escaneo",
        totalHours = "Total de horas",
        shiftDuration = "Duración del turno",
        currentTime = "Hora actual: {time}",
        defaultStation = "Terminal principal",
        devPrompt = "Cargar datos simulados para previsualizar la terminal de servicio en el navegador.",
        loadMock = "Cargar datos simulados",
        loading = "Cargando..."
      },
      toasts = {
        failed = "No se pudo actualizar el estado del turno."
      },
      errors = {
        unavailable = "Terminal de servicio no disponible."
      },
      title = "Terminal de turno"
    },
    storage = {
      inventory = "Inventario",
      storage = "Almacenamiento",
      locker = "Taquilla",
      trunk = "Maletero del vehículo",
      trunkProps = "Accesorios del vehículo",
      openPropMenu = "Accesorios",
      search = "Buscar",
      items = "Artículos",
      weapons = "Armas",
      transferTitle = "Transferir",
      transferButton = "Transferir",
      capacityUnlimited = "Capacidad ilimitada",
      errors = {
        trunkFull = "El maletero está lleno.",
        searchReadOnly = "Solo puedes quitar artículos de la persona.",
        invalidTransfer = "Error en la transferencia.",
        invalidAmount = "Cantidad inválida.",
        notEnoughItems = "No hay suficientes artículos.",
        inventoryFull = "No hay suficiente espacio en inventario.",
        storageFull = "El almacenamiento está lleno.",
        lockerFull = "La taquilla está llena.",
        restrictedItem = "No tienes acceso a este elemento.",
        invalidProp = "No se pudo seleccionar la propiedad."
      },
      officerInventory = "Inventario del personal",
      loadout = "Equipamiento",
      armory = "Armería",
      armoryTitle = "Armería de equipo",
      storageTitle = "Almacenamiento seguro",
      storageSubtitle = "Solo personal autorizado",
      emptyItems = "No hay elementos disponibles.",
      emptyWeapons = "No hay armas disponibles.",
      emptyProps = "No hay props disponibles.",
      searchItems = "Elementos",
      searchWeapons = "Armas",
      lockerUnlocking = "Desbloqueando taquilla...",
      restrictedPill = "Restringido",
      restrictedTooltip = "No tienes acceso a este elemento.",
      capacityLabel = "{used}/{capacity}",
      propPlacement = {
        title = "Colocación de props",
        place = "Colocar ({key})",
        cancel = "Cancelar ({key})"
      }
    },
    creator = {
      title = "Creador",
      description = "Configurar entradas.",
      selectJob = "Selecciona una categoría de trabajo.",
      empty = "Aún no se han configurado {entryLabelPlural}.",
      keyboardHint = "Usa las flechas para navegar por la lista y acciones.",
      placementHelp = "Flechas mover, RePág/AvPág altura, Q/E rotar, Intro colocar, Retroceso cancelar.",
      editTitle = "Marcadores",
      editSubtitle = "Usa el botón de alfiler para almacenar tus coordenadas actuales.",
      editKeyboardHint = "Usa las flechas para elegir un marcador, izquierda/derecha para seleccionar Establecer/Borrar, Enter para ejecutarlo, Retroceso para volver.",
      missingEntry = "Entrada no encontrada.",
      actions = {
        add = "Agregar {label}",
        newEntry = "Nueva {entryLabel}"
      },
      status = {
        set = "Establecer",
        unset = "Eliminar conexión"
      },
      modals = {
        createTitle = "Crear {entryLabel}",
        createButton = "Crear {entryLabel}",
        renameTitle = "Renombrar {entryLabel}",
        renameButton = "Guardar nombre",
        deleteTitle = "Eliminar {entryLabel}",
        deleteMessage = "¿Realmente quieres eliminar {name}?",
        deleteConfirmLabel = "Eliminar",
        deleteCancelLabel = "Cancelar"
      }
    },
    management = {
      noAccess = "No tienes acceso a ninguna herramienta de gestión.",
      refunds = {
        description = "Revisa las muertes de hoy y ayer y reembolsa los elementos eliminados.",
        refreshButton = "Actualizar",
        updatedAt = "Actualizado {time}",
        errors = {
          loadFailed = "No se pudo cargar los reembolsos."
        }
      },
      dashboard = {
        sidebarTitle = "Tablero",
        menuTitle = "Resumen",
        onlineMembers = "Miembros en línea",
        funds = "Fondos",
        onDuty = "En servicio",
        offDuty = "Fuera de servicio",
        mostActive = "Más activo"
      },
      finance = {
        sidebarTitle = "Flujo de efectivo",
        menuTitle = "Resumen financiero",
        expenseCategories = "Categorías de gastos",
        revenueCategories = "Categorías de ingresos",
        kpis = {
          revenue = "Ingresos",
          expenses = "Gastos",
          profit = "Beneficio"
        },
        cashFlow = "Tendencia del flujo de efectivo",
        lastUpdated = "Actualizado {time}",
        emptyStates = {
          timeline = "No hay transacciones registradas en este período.",
          categories = "Aún no hay datos de categorías."
        },
        categories = {
          deposits = "Depósitos",
          withdrawals = "Retiradas",
          supplies = "Suministros",
          vehicles = "Vehículos",
          salaries = "Salarios",
          bonuses = "Bonificaciones"
        },
        errors = {
          load = "No se puede cargar la instantánea de finanzas."
        }
      },
      transactions = {
        sidebarTitle = "Fondos",
        menuTitle = "Gestión de fondos",
        currentBalance = "Saldo actual",
        withdrawButton = "Retirar",
        depositButton = "Depositar",
        recentTransactions = "Transacciones recientes",
        columnNames = {
          timestamp = "Marca de tiempo",
          name = "Nombre",
          action = "Acción",
          content = "Cantidad"
        },
        actions = {
          deposited = "Dinero depositado",
          withdrawn = "Dinero retirado",
          supplies_purchased = "Suministros comprados",
          vehicle_purchased = "Vehículo comprado",
          vehicle_sold = "Vehículo vendido",
          salary_paid = "Salario pagado",
          bonus_paid = "Bonificación pagada"
        },
        errors = {
          load = "No se pueden cargar las transacciones.",
          failed = "Fallar la transacción."
        }
      },
      billingSpecs = {
        sidebarTitle = "Preajustes de facturación",
        menuTitle = "Razones de facturación",
        description = "Configurar las razones que el personal puede seleccionar al facturar y definir sus precios predeterminados.",
        reasonColumn = "Razón",
        priceColumn = "Precio",
        actionsColumn = "Acciones",
        reasonLabel = "Razón de facturación",
        reasonPlaceholder = "ej. Respuesta a patrullaje",
        amountLabel = "Precio predeterminado",
        emptyState = "Aún no hay razones de facturación añadidas.",
        addButton = "Agregar",
        addFirstButton = "Crear tu primera razón",
        deleteButton = "Eliminar",
        saveButton = "Guardar",
        reasonRequired = "Ingrese una razón para guardar esta fila.",
        saveSuccess = "Especificaciones de facturación actualizadas.",
        saveError = "No se pudo guardar las especificaciones de facturación.",
        loadError = "No se pudo cargar las especificaciones de facturación.",
        updatedAt = "Actualizado en {time}"
      },
      members = {
        sidebarTitle = "Miembros",
        menuTitle = "Listado",
        inviteTitle = "Invitar a la facción",
        inviteSubtitle = "Selecciona un jugador y asígnale un rango de entrada.",
        selectPlayer = "Seleccionar jugador",
        selectRank = "Seleccionar rango",
        sendInvite = "Invitar",
        columnNames = {
          name = "Nombre",
          rank = "Rango",
          last_online = "Última conexión",
          total_work_time = "Tiempo de trabajo (h)",
          actions_done = "Acciones completadas",
          actions = "Acciones"
        },
        bonus = {
          title = "Emitir bonificación",
          confirmButton = "Pagar bonificación",
          actionLabel = "Bonificación",
          invalidAmount = "Ingrese una cantidad válida de bonificación.",
          failed = "Error al pagar la bonificación.",
          unexpectedError = "Error inesperado al pagar la bonificación."
        },
        errors = {
          load = "Fallar al obtener miembros.",
          loadUnexpected = "Error inesperado al obtener miembros.",
          invite = "Fallar al enviar la invitación.",
          inviteUnexpected = "Error inesperado al invitar."
        }
      },
      roles = {
        sidebarTitle = "Roles",
        menuTitle = "Roles",
        createRoleButton = "Crear rol",
        columnNames = {
          grade = "Grado",
          label = "Nombre del rol",
          salary = "Salario",
          salaryInterval = "Intervalo (min)",
          actions = "Acciones"
        },
        editMenu = {
          title = "Editar rol",
          createTitle = "Crear rol",
          createSaveButton = "Crear",
          newRoleBreadcrumb = "Nuevo rol",
          unnamedRole = "Rol sin nombre",
          gradeMeta = "Grado {grade}",
          backButton = "Regresar",
          saveButton = "Guardar",
          general = "General",
          permissions = "Permisos",
          salary = "Salario",
          salaryDescription = "Establecer el salario para este rol.",
          salaryInterval = "Intervalo de pago",
          salaryIntervalDescription = "Elija con qué frecuencia recibe salario este rol (en minutos de trabajo).",
          roleName = "Nombre del rol",
          roleNameDescription = "Establecer el nombre del rol para este rol.",
          highestRoleInfo = "Este es el rango más alto y automáticamente tiene acceso a todos los permisos."
        },
        unsavedChanges = {
          title = "Cambios no guardados",
          message = "Tienes cambios sin guardar para este rol. ¿Salir de todos modos y descartarlos?",
          confirm = "Salir sin guardar",
          cancel = "Seguir editando"
        },
        permissionsEmpty = "Permisos no encontrados.",
        permissionEntries = {
          viewLogs = {
            label = "Ver registros",
            description = "Permite leer los registros de transacciones laborales y actividades."
          },
          manageRoles = {
            label = "Gestionar roles",
            description = "Permite crear, editar, mover y eliminar grados."
          },
          manageMembers = {
            label = "Gestionar miembros",
            description = "Permitir promover, degradar, despedir o pagar bonificaciones."
          },
          manageWarehouse = {
            label = "Acceder al almacenamiento",
            description = "Permitir interactuar con el inventario de almacenamiento compartido."
          },
          manageMoney = {
            label = "Gestionar fondos",
            description = "Permitir depositar o retirar dinero de la sociedad."
          },
          editOutfits = {
            label = "Editar atuendos",
            description = "Permitir actualizar entradas de vestuario guardadas."
          },
          createOutfits = {
            label = "Crear atuendos",
            description = "Permitir crear nuevas entradas de vestuario."
          },
          deleteOutfits = {
            label = "Eliminar atuendos",
            description = "Permitir eliminar entradas de vestuario guardadas."
          },
          purchaseSupplies = {
            label = "Ordenar suministros",
            description = "Permitir ordenar equipo al proveedor mayorista usando fondos de la facción."
          },
          purchaseVehicles = {
            label = "Comprar vehículos",
            description = "Permitir comprar nuevos vehículos de la flota usando fondos de la facción."
          },
          garageVehicles = {
            label = "Restricciones de vehículos en garaje",
            description = "Seleccionar qué vehículos de la flota este rol no puede acceder en el garaje."
          },
          tabletApps = {
            label = "Restricciones de aplicaciones en la tablet",
            description = "Seleccionar qué aplicaciones de la tablet este rol no puede acceder."
          },
          all = {
            label = "Acceso completo",
            description = "Concede todos los permisos independientemente de otros toggles."
          }
        },
        permissionOptions = {
          storageHint = "Agregar elementos que no puedan ser removidos con este rol.",
          storageItemsTitle = "elementos restringidos",
          storageWeaponsTitle = "armas restringidas",
          allowedWeaponsTitle = "armas permitidas",
          weaponHint = "Agregar armas a las que este rol puede acceder.",
          vehicleHint = "Seleccionar vehículos a los que este rol no puede acceder.",
          appHint = "Seleccionar aplicaciones de la tablet que este rol no puede acceder.",
          itemPlaceholder = "Escribir para agregar un elemento",
          weaponPlaceholder = "Escribir para agregar un arma",
          weaponSelectPlaceholder = "Seleccionar un arma",
          vehiclePlaceholder = "Seleccionar un vehículo",
          appPlaceholder = "Seleccionar una aplicación de la tablet",
          addButton = "Agregar",
          emptyVehicles = "No hay vehículos disponibles.",
          emptyApps = "No hay aplicaciones de la tablet disponibles.",
          errors = {
            empty = "Por favor, ingrese un valor.",
            duplicate = "Opción ya agregada.",
            itemMissing = "El elemento no existe.",
            vehicleMissing = "Seleccionar un vehículo.",
            appMissing = "Seleccionar una aplicación de la tablet.",
            weaponMissing = "El arma no existe.",
            weaponSelectMissing = "Seleccionar un arma."
          }
        },
        errors = {
          save = "Error al guardar el rol.",
          saveUnexpected = "Error inesperado al guardar el rol.",
          permissionsLoad = "Error al obtener permisos.",
          permissionsUnexpected = "Error inesperado al obtener permisos."
        }
      },
      logs = {
        sidebarTitle = "Registros",
        menuTitle = "Registros",
        errors = {
          load = "Error al cargar los registros."
        },
        columnNames = {
          timestamp = "Marca de tiempo",
          name = "Nombre",
          action = "Acción",
          content = "Contenido"
        },
        actions = {
          stored = "Elemento almacenado",
          removed = "Elemento eliminado",
          deposited = "Dinero depositado",
          withdrawn = "Dinero retirado",
          outfit_created = "Vestuario creado",
          outfit_updated = "Vestuario actualizado",
          outfit_deleted = "Vestuario eliminado",
          permissions_updated = "Permisos actualizados",
          invite_sent = "Invitación enviada",
          invite_accepted = "Invitación aceptada",
          invite_declined = "Invitación rechazada",
          bonus_paid = "Bono pagado",
          member_promoted = "Miembro promovido",
          member_demoted = "Miembro degradado",
          member_fired = "Miembro despedido",
          supplies_purchased = "Suministros comprados",
          vehicle_purchased = "Vehículo comprado",
          vehicle_sold = "Vehículo vendido",
          salary_paid = "Salario pagado"
        }
      },
      dialogs = {
        deleteOutfit = {
          title = "Eliminar vestuario",
          message = "¿Realmente quieres eliminar \"{name}\"?",
          confirm = "Eliminar vestuario",
          cancel = "Cancelar"
        }
      }
    },
    cloakroom = {
      title = "Vestuario",
      civilianClothes = "Ropa civil",
      newOutfit = "Nuevo atuendo",
      edit = {
        save = "Guardar",
        rotateAlt = "Rotar",
        outfitNameTitle = "Nombre del atuendo",
        saveOutfit = "Guardar atuendo"
      }
    },
    tablet = {
      apps = {
        management = "Menú del jefe",
        patients = "Pacientes",
        citizens = "Ciudadanos",
        offences = "Delitos",
        cases = "Casos",
        social_work = "Trabajo social",
        vehicles = "Vehículos",
        weapons = "Armas",
        prison = "Prisión",
        warrants = "Órdenes de arresto",
        bolos = "BOLOS",
        conditions = "Condiciones",
        reports = "Informes",
        camera = "Cámara",
        gallery = "Galería",
        map = "Mapa",
        chat = "Chat",
        calendar = "Calendario",
        calculator = "Calculadora",
        settings = "Configuraciones"
      }
    },
    common = {
      close = "Cerrar",
      unknownError = "Error desconocido.",
      unexpectedError = "Se produjo un error inesperado.",
      time = {
        now = "Ahora"
      },
      pagination = {
        prev = "Anterior",
        next = "Siguiente",
        page = "Página {current} de {total}"
      },
      gallery = {
        title = "Galería",
        subtitle = "Selecciona una foto o video.",
        loading = "Cargando galería...",
        empty = "No hay elementos disponibles en la galería.",
        photoAlt = "Medios de la galería"
      },
      back = "Regresar",
      confirm = {
        unsavedTitle = "Cambios no guardados",
        unsavedMessage = "¿Descartar cambios o guardarlos antes de salir?",
        unsavedDiscard = "Descartar cambios",
        unsavedSave = "Guardar cambios"
      }
    },
    reports = {
      unknown = "Desconocido"
    },
    publicForms = {
      complaint = {
        fields = {
          fullName = "Nombre completo",
          phone = "Número de teléfono",
          incidentDate = "Fecha del incidente",
          incidentTime = "Hora del incidente",
          location = "Lugar del incidente",
          officerName = "Nombre del personal",
          badgeNumber = "Número de placa",
          description = "Detalles de la queja",
          witnesses = "Testigos",
          desiredOutcome = "Resolución solicitada",
          email = "Dirección de correo electrónico",
          address = "Dirección del hogar",
          signature = "Firma"
        },
        title = "Queja ciudadana",
        subtitle = "Reportar conducta del personal o inquietudes del departamento.",
        placeholders = {
          fullName = "Ingresa tu nombre completo legal",
          phone = "###-###-####",
          email = "nombre@ejemplo.com",
          address = "Dirección, ciudad, estado",
          incidentDate = "DD/MM/AAAA",
          incidentTime = "HH:MM",
          location = "¿Dónde ocurrió?",
          officerName = "Nombre del personal o unidad",
          badgeNumber = "Número de placa si se conoce",
          description = "Describe lo ocurrido en detalle...",
          witnesses = "Lista a los testigos o partes involucradas",
          desiredOutcome = "¿Qué resultado estás solicitando?",
          signature = "Escribe tu nombre completo"
        }
      },
      application = {
        fields = {
          fullName = "Nombre completo",
          dateOfBirth = "Fecha de nacimiento",
          phone = "Número de teléfono",
          experience = "Experiencia relevante",
          availability = "Disponibilidad",
          whyJoin = "¿Por qué quieres unirte?",
          email = "Dirección de correo electrónico",
          address = "Dirección del hogar",
          education = "Educación",
          certifications = "Certificaciones",
          references = "Referencias",
          signature = "Firma"
        },
        title = "Solicitud de empleo",
        subtitle = "Solicitar ingreso al departamento.",
        placeholders = {
          fullName = "Ingresa tu nombre completo legal",
          dateOfBirth = "DD/MM/AAAA",
          phone = "###-###-####",
          email = "nombre@ejemplo.com",
          address = "Dirección, ciudad, estado",
          education = "Escuela secundaria, academia o universidad",
          experience = "Roles en aplicación de la ley, seguridad o servicios",
          certifications = "Primeros auxilios, armas de fuego o formación relacionada",
          availability = "Turnos preferidos o fecha de inicio",
          whyJoin = "Cuéntanos por qué quieres trabajar aquí...",
          references = "Nombres y datos de contacto",
          signature = "Escribir su nombre completo"
        }
      },
      title = "Formularios públicos",
      subtitle = "Enviar una queja o una solicitud de empleo.",
      stationLabel = "Estación",
      dateLabel = "Fecha",
      timeLabel = "Hora",
      stamp = {
        label = "P. D.",
        complaint = "Queja",
        application = "Solicitud"
      },
      tabs = {
        complaint = "Formulario de queja",
        application = "Solicitud de empleo",
        myForms = "Mis solicitudes"
      },
      myForms = {
        title = "Mis solicitudes",
        empty = "Aún no has enviado ningún formulario.",
        back = "Volver",
        notesTitle = "Respuestas",
        notesEmpty = "Aún no hay respuestas.",
        statusNew = "Pendiente",
        statusReviewed = "Revisado",
        statusArchived = "Archivado"
      },
      actions = {
        submit = "Enviar formulario",
        clear = "Borrar campos",
        close = "Cerrar"
      },
      status = {
        submitting = "Enviando...",
        success = "Formulario enviado con éxito.",
        error = "No se pudo enviar el formulario."
      },
      errors = {
        required = "Por favor, complete los campos requeridos."
      }
    },
    tabletForms = {
      title = "Bandeja de entrada del formulario",
      eyebrow = "Formularios públicos",
      listed = "listado",
      filters = {
        label = "Tipo",
        all = "Todos los formularios",
        complaint = "Quejas",
        application = "Aplicaciones"
      },
      search = {
        placeholder = "Buscar por nombre, estación o ID"
      },
      status = {
        new = "Nuevo",
        reviewed = "Revisado",
        archived = "Archivado"
      },
      state = {
        empty = "No hay formularios que coincidan con los filtros actuales.",
        loading = "Cargando formularios...",
        saving = "Guardando..."
      },
      errors = {
        load = "No se pudieron cargar los formularios.",
        update = "No se pudo actualizar el estado del formulario."
      },
      detail = {
        complaintTitle = "Detalles de la denuncia",
        applicationTitle = "Detalles de la solicitud"
      },
      actions = {
        refresh = "Actualizar",
        markReviewed = "Marcar como revisado",
        archive = "archivar",
        back = "Volver a la lista"
      },
      notifications = {
        timeNow = "Ahora",
        complaintType = "Denuncia",
        applicationType = "Solicitud",
        app = "Formularios",
        title = "Nuevo formulario público",
        body = "{type} de {name} ({station})"
      },
      fields = {
        type = "Tipo de formulario",
        id = "ID del formulario",
        station = "Estación",
        submitted = "Enviar",
        status = "Estado",
        contact = "Contacto"
      },
      notes = {
        title = "Notas",
        loading = "Cargando notas...",
        empty = "Aún no hay notas.",
        placeholder = "Escribe una nota...",
        visibleBadge = "Visible para el ciudadano",
        visibleToCitizen = "Visible para el ciudadano",
        submit = "Agregar nota"
      }
    },
    gallery = {
      eyebrow = "Galería de evidencia",
      title = "Carrete de fotos",
      filters = {
        all = "Todo",
        camera = "Cámara",
        speedcam = "Cámaras de velocidad",
        cctv = "Vigilancia CCTV",
        mugshot = "Fotos de ficha policial"
      },
      labels = {
        count = "{count} fotos",
        sort = "Nuevos primero",
        photoAlt = "Foto de galería",
        photoFullAlt = "Foto de tamaño completo",
        takenBy = "Tomado por",
        captured = "Capturado",
        unknownTime = "Tiempo desconocido",
        unknownTakenBy = "Desconocido"
      },
      state = {
        loading = "Cargando capturas...",
        emptyTitle = "Aún no hay fotos.",
        emptySubtitle = "Tus últimas fotos de la cámara aparecerán aquí."
      },
      errors = {
        load = "No se pudo cargar la galería.",
        delete = "No se pudo eliminar la foto."
      },
      confirm = {
        deleteTitle = "Eliminar foto",
        deleteMessage = "¿Eliminar esta foto? Esto no se puede deshacer.",
        deleteConfirm = "Eliminar",
        deleteCancel = "Cancelar"
      },
      mock = {
        caption = "CAPTURA DEV"
      }
    },
    camera = {
      help = {
        focused = "Presiona Espacio para habilitar movimiento.",
        blurred = "Presiona Espacio para usar de nuevo la tableta."
      },
      mode = {
        photo = "Foto",
        video = "Video",
        switchPhoto = "Cambiar a modo foto",
        switchVideo = "Cambiar a modo video"
      },
      capture = {
        photo = "Tomar foto"
      },
      queue = {
        title = "Cola",
        empty = "Aún no hay cargas.",
        kind = {
          photo = "Subida de foto",
          video = "Subida de video"
        },
        status = {
          loading = "Subiendo...",
          success = "Guardado",
          error = "Error"
        }
      },
      preview = {
        lastShot = "Última toma",
        lastCapture = "Última captura"
      },
      record = {
        start = "Iniciar grabación",
        stop = "Detener grabación",
        live = "REC",
        saving = "Guardando video...",
        name = "Clip de cámara",
        description = "Grabación en tableta",
        errors = {
          config = "Subir configuración faltante.",
          upload = "La carga falló.",
          save = "No se puede guardar el video.",
          unsupported = "Grabación no soportada.",
          empty = "Todavía no se ha capturado ningún video.",
          busy = "La grabación está ocupada.",
          notRecording = "La grabación ya fue detenida."
        }
      },
      errors = {
        timeout = "La carga agotó el tiempo límite.",
        capture = "Error inesperado al tomar una foto.",
        upload = "La carga falló."
      }
    },
    cctv = {
      eyebrow = "Red de vigilancia",
      title = "CCTV",
      listed = "Listado",
      actions = {
        refresh = "Actualizar"
      },
      search = {
        placeholder = "Buscar cámaras por nombre, id o ubicación"
      },
      filters = {
        all = "Todos los cámaras",
        bodycam = "Cámaras de cuerpo",
        dashcam = "Cámaras de tablero",
        cctv = "Cámaras CCTV",
        speedcam = "Cámaras de velocidad"
      },
      types = {
        bodycam = "Cámara de cuerpo",
        dashcam = "Cámara de tablero",
        speedcam = "Cámara de velocidad",
        cctv = "Cámara CCTV"
      },
      status = {
        online = "En línea",
        maintenance = "Mantenimiento",
        offline = "Fuera de línea"
      },
      live = {
        active = "Transmisión en vivo activa",
        maintenance = "Transmisión detenida por mantenimiento",
        offline = "Se perdió la señal",
        placeholderTitle = "Transmisión no disponible",
        placeholderSubtitle = "Seleccionar un miembro del personal con cámara corporal.",
        speedcamPlaceholderTitle = "Cámara de velocidad fuera de línea",
        speedcamPlaceholderSubtitle = "Reparar o reemplazar la unidad para restaurar la transmisión."
      },
      labels = {
        speedcamLocation = "Acera de camino",
        onDuty = "En servicio",
        durability = "Durabilidad"
      },
      state = {
        loading = "Cargando cámaras...",
        empty = "No hay cámaras que coincidan con los filtros actuales.",
        select = "Seleccionar una cámara para ver su transmisión."
      },
      controls = {
        tiltUp = "Inclinar hacia arriba",
        panLeft = "Mover a la izquierda",
        panRight = "Mover a la derecha",
        tiltDown = "Inclinar hacia abajo"
      },
      capture = {
        name = "CCTV - {label}",
        description = "{location} ({id})",
        saved = "Guardado en la galería.",
        error = "No se pudo capturar la imagen.",
        action = "Capturar",
        loading = "Capturando..."
      },
      record = {
        name = "Clip de CCTV - {label}",
        description = "{location} ({id})",
        save = "Guardar los últimos {minutes} min",
        saving = "Guardando...",
        requested = "Solicitud de guardado enviada.",
        saved = "Video guardado en la galería.",
        errors = {
          config = "Falta configuración de carga.",
          upload = "Error en la carga.",
          save = "No se puede guardar el video.",
          unsupported = "Grabación no soportada.",
          empty = "Aún no hay búfer disponible.",
          request = "No se puede solicitar el video de la bodycam.",
          timeout = "El guardado de la bodycam agotó el tiempo de espera.",
          busy = "La grabación está ocupada.",
          notRecording = "La grabación ya fue detenida."
        }
      },
      waypoint = {
        set = "Punto establecido.",
        missing = "No hay ubicación disponible."
      },
      errors = {
        load = "No se pueden cargar las cámaras."
      }
    },
    chat = {
      targets = {
        allUnits = "Chat de Todas las Unidades",
        centralDispatch = "Despacho Central"
      },
      header = {
        eyebrowRoom = "Canal del Personal",
        eyebrowPrivate = "Línea Privada",
        metaRoom = "Habitación",
        metaDirect = "Directo",
        metaStaff = "Personal"
      },
      sidebar = {
        eyebrow = "Comunicaciones",
        title = "Red del Personal",
        groupTitle = "Chat grupal",
        allUnits = "Todas las Unidades",
        staffTitle = "Personal",
        loading = "Cargando personal...",
        empty = "No hay personal disponible."
      },
      staff = {
        unknownMember = "Miembro del personal desconocido",
        onDuty = "En servicio",
        offDuty = "Fuera de servicio",
        grade = "Grado {level}",
        fallback = "Personal"
      },
      composer = {
        placeholderRoom = "Escribir una actualización de la unidad...",
        placeholderDirect = "Mensaje {name}...",
        pendingAlt = "Compartiendo pendiente"
      },
      messages = {
        avatarAlt = "Avatar de {name}",
        avatarFallback = "Avatar del personal",
        unknownAuthor = "Desconocido",
        sharedEvidenceAlt = "Evidencia compartida",
        tapToExpand = "Toca para ampliar"
      },
      preview = {
        ready = "Medios listos para enviar"
      },
      profile = {
        action = "Establecer foto de perfil",
        galleryTitle = "Establecer foto de perfil",
        gallerySubtitle = "Elige una foto para el avatar de tu equipo.",
        photoAlt = "Foto de perfil",
        selfPhotoAlt = "Foto de perfil",
        error = "No se puede actualizar la foto de perfil."
      },
      actions = {
        remove = "Eliminar",
        send = "Enviar"
      },
      state = {
        syncing = "Sincronizando mensajes...",
        emptyRoom = "No hay conversación todavía.",
        emptyPrivate = "No hay mensajes privados todavía.",
        emptyRoomHint = "Sé el primero en registrarte con la unidad.",
        emptyPrivateHint = "Iniciar una línea directa con este miembro del personal."
      },
      errors = {
        load = "No se puede cargar el historial del chat.",
        send = "No se puede enviar el mensaje.",
        members = "No se puede cargar el personal."
      }
    },
    bossMenu = {
      header = {
        eyebrow = "Menú del jefe",
        title = "Gestión",
        balanceLabel = "Saldo"
      },
      state = {
        loading = "Cargando datos de gestión..."
      }
    },
    tabletSettings = {
      header = {
        eyebrow = "Configuraciones de la tableta",
        title = "Personalización",
        modeLabel = "Modo",
        modeLight = "Claro",
        modeDark = "Oscuro"
      },
      appearance = {
        title = "Apariencia",
        description = "Cambiar la interfaz entre claro y oscuro.",
        light = "Claro",
        dark = "Oscuro"
      },
      wallpaper = {
        title = "Fondo de pantalla",
        description = "Usar el fondo predeterminado, escoger en la galería o añadir tu propio enlace.",
        labels = {
          default = "Fondo de pantalla predeterminado",
          gallery = "Foto de la galería",
          url = "URL personalizada"
        },
        useDefault = "Usar predeterminado",
        chooseGallery = "Elegir de la galería",
        customUrlLabel = "URL de imagen personalizada",
        customUrlPlaceholder = "https://example.com/wallpaper.jpg",
        apply = "Aplicar",
        hint = "Mejores resultados con imágenes de 1920x1080 o superior."
      }
    },
    calendar = {
      weekdays = {
        mon = "Lun",
        tue = "Mar",
        wed = "Mié",
        thu = "Jue",
        fri = "Vie",
        sat = "Sáb",
        sun = "Dom"
      },
      selectedDateFallback = "Seleccionar una fecha",
      header = {
        eyebrow = "Calendario compartido",
        title = "Horario del personal",
        metaPrimary = "Visible para todo el personal",
        metaSecondary = "Todos pueden añadir entradas",
        hint = "Toca un día para añadir un turno o evento"
      },
      actions = {
        dayEntries = "Entradas del día",
        addEntry = "Agregar entrada"
      },
      today = "Hoy",
      more = "+{count} más",
      modal = {
        addEntry = {
          eyebrow = "Agregar entrada",
          titleLabel = "Título",
          titlePlaceholder = "Resumen de turno, entrenamiento, patrulla",
          datetimeLabel = "Fecha y hora",
          colorLabel = "Color",
          clear = "Borrar",
          submit = "Agregar al calendario"
        },
        dayEntries = {
          eyebrow = "Entradas del día",
          empty = "Aún no hay entradas. Agrega una reunión o patrulla para compartir con la unidad."
        }
      }
    },
    calculator = {
      header = {
        eyebrow = "Herramientas de campo",
        title = "Calculadora",
        modeLabel = "Modo"
      },
      keys = {
        clearAll = "Borrar todo",
        clearEntry = "C en C"
      },
      mode = {
        standard = "Estándar"
      },
      status = {
        resetRequired = "Se requiere reinicio",
        ready = " Listo"
      },
      errors = {
        error = "Error"
      }
    },
    tabletHome = {
      status = {
        defaultDate = "lunes, 01 de ene."
      },
      calendar = {
        eventToday = "Evento hoy",
        eventTomorrow = "Evento mañana",
        allDay = "Todo el día",
        timeAt = " a {time}"
      },
      chat = {
        messageFrom = "Mensaje de {name}",
        newMessage = "Nuevo mensaje",
        authorFallback = "Personal",
        messageBody = "{author}: {message}",
        sentPhoto = "{author} envió una foto.",
        sentMessage = "{author} envió un mensaje."
      },
      notifications = {
        title = "Notificaciones",
        clearAll = "Borrar todo",
        empty = "Todo actualizado."
      }
    },
    map = {
      eyebrow = "Mesa de mapas",
      title = "Cuadrícula de San Andreas",
      markerLabel = "Marcador",
      markerTypes = {
        label = "Lista de marcadores",
        dispatch = "Despacho",
        officers = "Personal",
        speedcams = "Cámaras de velocidad",
        vehicles = "Vehículos",
        trackers = "Rastreadores"
      },
      markerList = {
        listed = "listado",
        officersTitle = "Lista del personal",
        speedcamsTitle = "Tablero de Cámaras de velocidad",
        vehiclesTitle = "Tablero de vehículos",
        trackersTitle = "Tablero de rastreadores",
        officersEmpty = "No hay personal en servicio.",
        speedcamsEmpty = "No hay cámaras de velocidad disponibles.",
        trackersEmpty = "No hay rastreadores en línea.",
        vehiclesEmpty = "No hay vehículos en línea."
      },
      dispatch = {
        title = "Tablero de Despacho",
        empty = "No hay despachos en este momento.",
        status = {
          active = "Activo",
          accepted = "Aceptado",
          done = "Realizado"
        },
        panelTitle = "Detalles del Despacho",
        statusLabel = "Estado",
        acceptedBy = "Aceptado por",
        doneBy = "Completado por",
        coords = "Coordenadas",
        actions = {
          accept = "Aceptar",
          done = "Marcar como terminado",
          delete = "Eliminar"
        },
        unknown = "Desconocido"
      },
      status = {
        available = "Disponible",
        busy = " ocupado",
        pursuit = "En persecución",
        offDuty = "Fuera de servicio"
      },
      vehicle = {
        status = {
          active = "Activo",
          offline = "Desconectado"
        }
      },
      tracker = {
        status = {
          active = "Activo",
          offline = "Desconectado"
        }
      },
      speedcam = {
        status = {
          online = "En línea",
          maintenance = "Mantenimiento",
          offline = "Desconectado"
        }
      },
      officerPanel = {
        title = "Detalles del Personal",
        callsign = "Indicativo {id}",
        rank = "Rango",
        health = "Salud",
        coords = "Coordenadas",
        lastUpdateUnknown = "Justo ahora"
      },
      speedcamPanel = {
        title = "Detalles de Cámaras de Velocidad",
        limit = "Límite",
        tolerance = "Tolerancia",
        health = "Salud",
        coords = "Coordenadas"
      },
      vehiclePanel = {
        title = "Detalles del Vehículo",
        plate = "Placa {plate}",
        netId = "ID de Red",
        health = "Salud",
        coords = "Coordenadas"
      },
      trackerPanel = {
        title = "Detalles del Rastreador",
        plate = "Placa {plate}",
        attachedBy = "Adjuntado por",
        attachedAt = "Adjuntado",
        netId = "ID de Red",
        status = "Estado",
        coords = "Coordenadas"
      },
      actions = {
        openCctv = "Abrir CCTV",
        setWaypoint = "Establecer punto"
      },
      waypoint = {
        set = "Punto establecido.",
        missing = "No hay ubicación disponible."
      },
      styles = {
        atlas = "Atlas",
        roads = "Carreteras",
        satellite = "Satélite"
      },
      missing = {
        title = "Falta la imagen del mapa",
        body = "Coloca las imágenes del mapa en frontend/public/img."
      },
      signalLost = "Señal perdida",
      details = {
        title = "Detalles",
        empty = "Selecciona un marcador para ver detalles."
      },
      zones = {
        title = "Zonas de exclusión",
        untitled = "Zona sin título",
        hint = "Haz clic en el mapa para agregar puntos. Mínimo 3.",
        pointCount = "{count} puntos",
        empty = "Aún no hay zonas de exclusión.",
        actions = {
          toggle = "Zonas",
          new = "Nueva zona",
          cancel = "Cancelar",
          save = "Guardar zona",
          undo = "Deshacer",
          clear = "Borrar",
          delete = "Eliminar"
        },
        modal = {
          title = "Nombre de la zona de exclusión",
          confirm = "Guardar zona"
        },
        errors = {
          points = "Agrega al menos 3 puntos.",
          nameRequired = "Ingresa un nombre para la zona.",
          saveFailed = "No se pudo guardar la zona de exclusión.",
          deleteFailed = "No se pudo eliminar la zona de exclusión."
        }
      },
      monitorZones = {
        title = "Zonas de monitor de tobillo",
        untitled = "Zona sin título",
        hint = "Haz clic en el mapa para agregar puntos. Mínimo 3.",
        pointCount = "{count} puntos",
        empty = "Aún no hay zonas de monitor.",
        mode = {
          allow = "Zona permitida",
          exclude = "Zona restringida"
        },
        actions = {
          allow = "Zona permitida",
          exclude = "Zona restringida",
          cancel = "Cancelar",
          save = "Guardar zona",
          undo = "Deshacer",
          clear = "Borrar",
          delete = "Eliminar"
        },
        modal = {
          title = "Nombre de la zona de monitoreo",
          confirm = "Guardar zona"
        },
        errors = {
          points = "Agrega al menos 3 puntos.",
          nameRequired = "Ingresa un nombre para la zona.",
          noMonitor = "Selecciona un monitor de tobillo.",
          saveFailed = "No se pudo guardar la zona de monitoreo.",
          deleteFailed = "No se pudo eliminar la zona de monitoreo."
        }
      },
      panic = {
        panelTitle = "Detalles de pánico",
        triggeredBy = "Activado por",
        createdAt = "Activado",
        coords = "Coordenadas"
      },
      dev = {
        officerName = "Personal Avery Lane",
        callsign = "LIN-23",
        rank = "Sargento",
        unit = "Patrulla Central",
        speedcamName = "Cámara de velocidad Del Perro",
        vehicleName = "Unidad 12",
        trackerName = "Localizador ALPHA",
        trackerOfficer = "Personal Ruiz",
        dispatchTitle = "Cámara de velocidad dañada",
        dispatchMessage = "La unidad de Del Perro necesita mantenimiento.",
        panicOfficer = "Personal Sinclair",
        panicLocation = "Misión Row"
      }
    },
    panicNotification = {
      badge = "Pánico",
      title = "Alerta de pánico",
      subtitle = "{name} presionó el botón de pánico.",
      callsign = "Llamada {id}",
      locationLabel = "Ubicación",
      locationUnknown = "Ubicación desconocida",
      hint = "Presione {key} para establecer un punto en el mapa del juego."
    },
    incidentNotification = {
      panic = {
        title = "Alerta de pánico",
        subtitle = "{name} pulsó el botón de pánico."
      },
      dispatch = {
        title = "Alerta de despacho",
        subtitle = "{name} compartió un nuevo despacho."
      },
      ping = {
        title = "Ping de ubicación",
        subtitle = "{name} compartió un ping de ubicación en tiempo real."
      },
      actions = {
        openMap = {
          key = "M",
          label = "Ver en la aplicación de mapas de la tableta"
        },
        setWaypoint = {
          key = "G",
          label = "Establecer punto de ruta"
        },
        dismiss = {
          key = "Retroceder",
          label = "Descartar"
        }
      }
    },
    gradeChange = {
      promotedTitle = "Promoción",
      demotedTitle = "Rebaja",
      unchangedTitle = "Rango actualizado",
      previousLabel = "Rango anterior",
      newLabel = "Rango actual",
      unknownLabel = "Rango no asignado",
      levelFallback = "Grado {level}"
    },
    employeeGpsJammer = {
      title = "Bloqueador de GPS",
      disabled = "El bloqueo de GPS no está disponible.",
      success = "Señal GPS del empleado interrumpida.",
      failed = "No se pudo interrumpir la señal GPS.",
      targetJammed = "Tu señal GPS de servicio está siendo bloqueada.",
      errors = {
        disabled = "El bloqueo de GPS no está disponible.",
        no_players = "No hay ninguna persona cerca.",
        too_far = "Acércate más antes de usar el bloqueador de GPS.",
        invalid_target = "No se puede localizar a esa persona.",
        not_on_duty = "No se encontró ninguna señal GPS de servicio activa en esta persona.",
        protected_job = "La señal GPS de este empleado está protegida.",
        missing_item = "Necesitas un bloqueador de GPS para hacer esto.",
        cooldown = "Espera un momento antes de volver a usar el bloqueador de GPS.",
        failed = "No se pudo interrumpir la señal GPS.",
      },
    },
    bonusNotification = {
      title = "Bonificación otorgada",
      subtitle = "De {name}",
      amountLabel = "Bonificación",
      unknownManager = "Gestión"
    },
    wheelClamp = {
      attached = "Se ha colocado una pinza de rueda"
    },
    search = {
      previewTitle = "Buscando {name}",
      previewSubtitle = "Escaneando pertenencias en busca de armas y contrabando...",
      previewCancel = "Presione X para cancelar",
      unknownTarget = "Desconocido"
    },
    heliCamHud = {
      title = "Controles de cámara de helicóptero",
      actions = {
        toggleCam = "Alternar cámara",
        vision = "Alternar visión",
        spotlight = "Modo reflector",
        lockTarget = "Bloquear objetivo",
        display = "Alternar pantalla",
        takePhoto = "Tomar foto",
        rappel = "Rapelar",
        brightness = "Brillo",
        radius = "Radio"
      }
    },
    jailHud = {
      title = "Tiempo restante",
      trashLabel = "Basura",
      trashFull = "Bolsa llena",
      trashDropoff = "Entregar al contenedor de basura"
    },
    jailJobs = {
      title = "Asignaciones de trabajo en la cárcel",
      subtitle = "Elegir una tarea para pasar el tiempo.",
      actions = {
        cleaning = "Limpiar",
        gardening = "Jardinería",
        carry_goods = "Cargar mercancía"
      },
      currentJob = "Trabajo actual:",
      stop = "Detener trabajo",
      close = "Cerrar",
      contraband = {
        title = "Contrabando",
        message = "Has encontrado {item}. ¿Tomas el riesgo y lo guardas o lo arrojas?",
        keep = "Mantener",
        toss = "Tirar"
      },
      boxInspect = {
        title = "Inspeccionar caja",
        message = "Dentro encuentras {item}. {description}",
        take = "Tomarlo",
        leave = "Dejarlo dentro",
        close = "Cerrar"
      }
    },
    socialWork = {
      eyebrow = "Servicio comunitario",
      title = "Trabajo social",
      listed = "listado",
      search = {
        placeholder = "Buscar por nombre o ID"
      },
      filters = {
        all = "Todo",
        label = "Estado",
        placeholder = "Estado"
      },
      actions = {
        refresh = "Actualizar",
        back = "Volver a la lista"
      },
      state = {
        loading = "Cargando servicio comunitario...",
        empty = "No hay servicios comunitarios que coincidan con los filtros actuales."
      },
      status = {
        active = "Activo",
        overdue = "Atrasado",
        completed = "Completado",
        imprisoned = "En prisión"
      },
      labels = {
        remainingShort = "quedan",
        imprison = "Prisionar",
        imprisonNotice = "La fecha límite ha pasado. Se requiere prisión.",
        noDeadline = "Sin fecha límite",
        expired = "Caducado"
      },
      sections = {
        summary = "Resumen del servicio",
        summarySubtitle = "Descripción general de las tareas asignadas."
      },
      fields = {
        name = "Nombre",
        status = "Estado",
        remaining = "Tareas restantes",
        completed = "Tareas completadas",
        total = "Total de tareas",
        assigned = "Asignado",
        deadline = "Fecha límite",
        timeLeft = "Tiempo restante",
        assignedBy = "Asignado por",
        unknown = "Desconocido"
      },
      assign = {
        title = "Asignar servicio comunitario",
        subtitle = "Enviar a un jugador cercano a tareas de trabajo social.",
        playerLabel = "Jugador",
        playerPlaceholder = "Elegir jugador",
        taskLabel = "Tareas",
        taskPlaceholder = "Contador de tareas",
        deadlineLabel = "Límite de tiempo (minutos)",
        deadlinePlaceholder = "Opcional",
        submit = "Asignar",
        success = "Servicio comunitario asignado.",
        error = "No se pudo asignar el servicio comunitario."
      },
      errors = {
        load = "No se pudo cargar el servicio comunitario."
      },
      date = {
        unknown = "Desconocido"
      },
      jobs = {
        title = "Servicio comunitario",
        subtitle = "Elegir una tarea para completar la oración.",
        currentJob = "Tarea actual:",
        stop = "Detener tarea",
        actions = {
          cleaning = "Limpieza",
          carry_goods = "Cargar objetos"
        }
      },
      hud = {
        title = "Servicio comunitario",
        remaining = "Tareas restantes",
        completed = "Tareas completadas",
        deadline = "Tiempo restante",
        expired = "Caducado",
        trashLabel = "Basura",
        trashFull = "Bolsa llena",
        trashDropoff = "Entregar a la basura"
      }
    },
    socialWorkCreator = {
      title = "Creador de Trabajo Social",
      description = "Configurar sitios de servicio comunitario en la ciudad.",
      empty = "Aún no hay sitios de trabajo social configurados.",
      keyboardHint = "Use las teclas de flecha para navegar por la lista y acciones.",
      editTitle = "Marcadores de trabajo social",
      editSubtitle = "Use el botón de pin en el mapa para guardar sus coordenadas actuales.",
      editKeyboardHint = "Use las flechas para seleccionar un marcador, izquierda/derecha para elegir Guardar/Limpiar, Enter para ejecutarlo, Backspace para regresar.",
      missingEntry = "Sitio de trabajo social no encontrado.",
      actions = {
        newSite = "Nuevo sitio"
      },
      status = {
        set = "Establecer",
        unset = "Borrar"
      },
      markers = {
        social_work_job_npc = "NPC de trabajo",
        social_work_dumpster = "Contenedor de basura",
        social_work_box_dropoff = "Entrega de carga"
      },
      modals = {
        createTitle = "Crear sitio",
        createButton = "Crear sitio",
        renameTitle = "Renombrar sitio",
        renameButton = "Guardar nombre",
        deleteTitle = "Eliminar sitio",
        deleteMessage = "¿Realmente deseas eliminar {name}?",
        deleteConfirmLabel = "Eliminar",
        deleteCancelLabel = "Cancelar"
      }
    },
    impoundCreator = {
      title = "Creador de Incautaciones",
      description = "Configurar ubicaciones de patios de incautación y puntos de aparición.",
      empty = "Aún no hay patios de incautación configurados.",
      keyboardHint = "Usar las flechas para navegar por la lista y acciones.",
      editTitle = "Marcas de depósito de vehículos",
      editSubtitle = "Usar el botón de pin de mapa para guardar tus coordenadas actuales.",
      editKeyboardHint = "Usar las flechas para elegir un marcador, izquierda/derecha para escoger Establecer/Eliminar/Borrar, Enter para ejecutarlo, Backspace para volver. Pasa por la lista para llegar a los botones Agregar.",
      missingEntry = "Depósito no encontrado.",
      actions = {
        newLot = "Nuevo depósito",
        add = {
          impound_delivery = "Agregar entrega",
          impound_spawn = "Agregar spawn"
        }
      },
      status = {
        set = "Establecer",
        unset = "Eliminar"
      },
      markers = {
        impound_lot = "Depósito de vehículos",
        impound_spawn = "Spawn de depósito",
        impound_delivery = "Entrega de depósito"
      },
      modals = {
        createTitle = "Crear depósito",
        createButton = "Crear depósito",
        renameTitle = "Renombrar depósito",
        renameButton = "Guardar nombre",
        deleteTitle = "Eliminar depósito",
        deleteMessage = "¿Realmente deseas eliminar {name}?",
        deleteConfirmLabel = "Eliminar",
        deleteCancelLabel = "Cancelar"
      }
    },
    impoundStorage = {
      title = "Almacenamiento de vehículos",
      subtitle = "Ordenar vehículos almacenados para ser entregados al depósito.",
      empty = "No hay vehículos almacenados en este depósito.",
      emptyAll = "No se encontraron vehículos decomisados.",
      unknownModel = "Desconocido",
      unknownLot = "Desconocido",
      sections = {
        impounds = "Depósitos activos",
        stored = "Vehículos almacenados"
      },
      columns = {
        plate = "Placa",
        model = "Modelo",
        stored = "Almacenado",
        lot = "Depósito",
        status = "Estado",
        fee = "Tarifa de almacenamiento"
      },
      actions = {
        deliver = "Ordenar entrega",
        allowPickup = "Permitir recogida",
        seize = "Marcar como decomisado",
        seized = "Decomisado",
        close = "Cerrar",
        refresh = "Actualizar"
      },
      status = {
        pickup = "Recolección permitida",
        seized = "Decomisado"
      },
      time = {
        days = "{count} día(s)"
      },
      errors = {
        load = "No se pudieron cargar los vehículos almacenados.",
        deliver = "No se pudo ordenar la entrega.",
        seized = "Este vehículo está decomisado por investigación.",
        update = "No se pudo actualizar el estado del depósito."
      }
    },
    impoundDecision = {
      title = "Decisión de depósito",
      message = "Decidir si {vehicle} puede ser recogido o decomisado para investigación.",
      vehicleFallback = "permitir la recogida",
      allowPickup = "Acelerar la recaudación",
      seize = "Incautar para investigación"
    },
    jailCreator = {
      title = "Creador de cárcel",
      description = "Colocar puntos de generación de cárceles y administrar ubicaciones.",
      empty = "Aún no hay cárceles configuradas.",
      keyboardHint = "Usar las teclas de flecha para navegar por la lista y acciones.",
      editTitle = "Marcadores de cárcel",
      editSubtitle = "Usar el botón de pin del mapa para almacenar tus coordenadas actuales.",
      editKeyboardHint = "Usar las flechas para seleccionar un marcador, izquierda/derecha para elegir Establecer/Borrar/Eliminar, Enter para ejecutarlo, Retroceso para volver. Pasa más allá de la lista para alcanzar los botones Agregar.",
      missingEntry = "No se encontró la cárcel.",
      actions = {
        newJail = "Nueva cárcel"
      },
      modals = {
        createTitle = "Crear cárcel",
        createButton = "Crear cárcel",
        renameTitle = "Renombrar cárcel",
        renameButton = "Guardar nombre",
        deleteTitle = "Eliminar cárcel",
        deleteMessage = "¿Realmente quieres eliminar {name}?",
        deleteConfirmLabel = "Eliminar",
        deleteCancelLabel = "Cancelar"
      }
    },
    jailInmates = {
      title = "Comercio de reos",
      close = "Cerrar",
      trade = "Realizar comercio",
      requiredLabel = "Tú das",
      rewardLabel = "Recibes",
      acceptedLabel = "Acepta",
      contrabandLabel = "Contrabando",
      npc = {
        alcoholic = "Borracho del bloque de celdas",
        drugDealer = "Vendedor de la lavandería",
        doctor = "Médico de la prisión",
        canteen = "Cocinero de la cantina"
      },
      dialogs = {
        alcoholic = {
          one = "Una vez cambié mi postre por un trapeador. El mejor día de mi vida.",
          two = "Si este lugar tuviera un bar, sería empleado del mes.",
          three = "¿Tienes algo que huela a pisos limpios y malas decisiones?",
          four = "Lo llamo colonia de prisión. Tú lo llamas alcohol limpiador."
        },
        drugDealer = {
          one = "¿Tienes algo picante de la basura? Pago con cigarrillos.",
          two = "Baja la voz, los guardias piensan que soy un club de lectura.",
          three = "Tráeme contrabando y haré que tu día sea fumable.",
          four = "La basura esconde tesoros. Soy el tasador de tesoros."
        },
        doctor = {
          one = "Mantente quieto. Esto será rápido.",
          two = "Hoy no hay cobro. Solo mantente fuera de problemas.",
          three = "Pareces hecho polvo. Déjame arreglarte.",
          four = "El horario de la clínica nunca termina aquí."
        },
        canteen = {
          one = "Bandeja fresca hoy. Forma una fila y sigue adelante.",
          two = "¿Quieres una comida caliente o una charla?",
          three = "El buen comportamiento obtiene segundos. Mayormente.",
          four = "He visto peores apetitos."
        }
      },
      doctor = {
        costLabel = "Costo",
        rewardLabel = "Tratamiento",
        actionLabel = "Obtener tratamiento",
        costValue = "Libre",
        rewardValue = "Tratamiento completo"
      },
      canteen = {
        costLabel = "Costo",
        rewardLabel = "Comida",
        actionLabel = "Reclamar comida",
        costValue = "Gratis",
        rewardValue = "Paquete de comida"
      },
      items = {
        cleaning_alcohol = "Alcohol de limpieza",
        cigarettes = "Cigarros",
        coke = "Coca-Cola",
        weed = "Marihuana",
        burger = "Hamburguesa",
        water = "Agua"
      }
    },
    invites = {
      title = "Oferta de trabajo",
      description = "¿Unirse a {job} como {role}?",
      invitedBy = "Invitado por {name}",
      expires = "Esta oferta expira pronto.",
      accept = "Aceptar",
      decline = "Rechazar",
      errors = {
        missing = "Invitación no disponible.",
        failed = "Error al responder la invitación."
      }
    },
    stationCreator = {
      title = "Creador de estaciones",
      description = "Configurar posiciones de marcadores de estaciones.",
      empty = "Aún no hay estaciones configuradas.",
      keyboardHint = "Usar ↑/↓ para seleccionar, ←/→ para cambiar acciones, Enter para confirmar, Backspace para cerrar.",
      editTitle = "Marcadores de estaciones",
      editSubtitle = "Usar el botón de pin de mapa para guardar tus coordenadas actuales.",
      editKeyboardHint = "Usar ↑/↓ para elegir un marcador, ←/→ para elegir Establecer/Limpiar/Eliminar, Enter para ejecutarlo, Backspace para volver.",
      sections = {
        markers = "Marcadores",
        zone = "Zona de cárcel"
      },
      zone = {
        subtitle = "Agregar puntos de zona para definir los límites de la cárcel.",
        hint = "Usar el botón de pin de mapa para añadir puntos. Eliminar puntos con el icono de papelera.",
        empty = "Aún no hay puntos de zona.",
        pointLabel = "Punto de zona {index}",
        actions = {
          add = "Agregar punto de zona",
          update = "Actualizar",
          clear = "Borrar zona"
        }
      },
      missingStation = "Estación no encontrada.",
      actions = {
        newStation = "Nueva estación",
        editJobBlip = "Editar marcador del trabajo",
        newJail = "Nueva cárcel",
        add = {
          wardrobe = "Agregar marcador de vestuario",
          garage_vehicle_menu = "Agregar interacción a garaje de vehículos",
          garage_vehicle_spawn = "Agregar aparición en garaje de vehículos",
          garage_vehicle_park = "Agregar estacionamiento en garaje de vehículos",
          garage_helicopter_menu = "Agregar interacción a helipuerto",
          garage_helicopter_spawn = "Agregar aparición en helipuerto",
          garage_helicopter_park = "Agregar estacionamiento en helipuerto",
          garage_boat_menu = "Agregar interacción en el muelle",
          garage_boat_spawn = "Agregar aparición en el muelle",
          garage_boat_park = "Agregar estacionamiento en el muelle",
          boss_menu = "Agregar marcador de menú de jefe",
          wholesale_shop = "Agregar marcador de tienda mayorista",
          duty_terminal = "Agregar marcador de terminal de servicio",
          public_forms = "Agregar quiosco de formularios públicos",
          jail_solitary_cell = "Agregar celda de aislamiento"
        }
      },
      status = {
        set = "Configurar",
        unset = "Eliminar"
      },
      markers = {
        position = "Ubicación de la estación",
        storage = "Almacenamiento",
        locker = "Armario con cerradura",
        wardrobe = "Armario",
        duty_terminal = "Terminal de servicio",
        public_forms = "Quiosco de formularios públicos",
        boss_menu = "Menú del jefe",
        garage_vehicle_menu = "Interacción con garaje de vehículos",
        garage_vehicle_spawn = "Generar vehículo en garaje",
        garage_vehicle_park = "Estacionar en garaje",
        garage_helicopter_menu = "Interacción con helipuerto",
        garage_helicopter_spawn = "Generar en helipuerto",
        garage_helicopter_park = "Estacionar en helipuerto",
        garage_boat_menu = "Interaccionar en el muelle",
        garage_boat_spawn = "Aparición en el muelle",
        garage_boat_park = "Estacionamiento en el muelle",
        wholesale_shop = "Tienda mayorista",
        jail_spawn = "Generar en cárcel",
        jail_release = "Punto de liberación",
        jail_menu = "Terminal de cárcel",
        jail_job_npc = "NPC de trabajo en la cárcel",
        jail_inmate_alcoholic = "Recluso: Alcohólico",
        jail_inmate_drugdealer = "Recluso: Traficante de drogas",
        jail_inmate_doctor = "Recluso: Médico",
        jail_canteen_cook = "Cocinero de la cantina",
        jail_dumpster = "Contenedor de basura de la cárcel",
        jail_box_dropoff = "Entrega de objetos",
        jail_electric_box = "Caja eléctrica",
        jail_fence_cut = "Punto de corte de la cerca",
        jail_fence_exit = "Salida de la cerca",
        jail_solitary_cell = "Celda de aislamiento",
        jail_confiscated_return = "Objetos confiscados"
      },
      modals = {
        createTitle = "Crear estación",
        createButton = "Crear estación",
        renameTitle = "Renombrar estación",
        renameButton = "Guardar nombre",
        deleteTitle = "Eliminar estación",
        deleteMessage = "¿Realmente deseas eliminar {name}?",
        deleteConfirmLabel = "Eliminar",
        deleteCancelLabel = "Cancelar",
        jobBlipTitle = "Marcador de trabajo: {job}",
        jobBlipMessage = "Configura el marcador de la estación para este trabajo. Desactívalo si este trabajo no debe tener marcador.",
        jobBlipSave = "Guardar marcador",
        jobBlipReset = "Restablecer",
        jobBlipInvalidNumber = "Valor inválido para {field}."
      },
      blip = {
        enabled = "Mostrar marcador",
        useStationName = "Añadir nombre de estación",
        shortRange = "Corto alcance",
        name = "Etiqueta",
        sprite = "Icono",
        color = "Color",
        scale = "Tamaño",
        display = "Visualización"
      }
    },
    jailAssign = {
      title = "Enviar a la cárcel",
      selectPlayer = "Seleccionar jugador",
      selectPlayerPlaceholder = "Elegir jugador",
      selectJail = "Seleccionar cárcel",
      selectJailPlaceholder = "Elegir ubicación de la cárcel",
      solitaryLabel = "Aislamiento",
      solitaryUnavailable = "No hay celdas de aislamiento configuradas para esta cárcel.",
      durationLabel = "Duración (meses)",
      monthHint = "1 mes = {minutes} minutos",
      cancelButton = "Cancelar",
      assignButton = "Enviar a la cárcel",
      assigning = "Enviando a la cárcel...",
      noPlayers = "No hay jugadores cercanos dentro de {range} m.",
      noJails = "Aún no hay cárceles configuradas. Usa primero el creador de cárceles.",
      spawnMissing = "Esta cárcel no tiene spawn establecido.",
      jailStatusReady = "Spawn listo",
      jailStatusMissing = "No hay spawn establecido",
      success = "Jugador enviado a la cárcel por {months} meses.",
      errors = {
        invalid_target = "Selecciona un jugador cercano y una cárcel.",
        spawn_not_set = "Esta cárcel no tiene spawn establecido.",
        solitary_unavailable = "No hay celdas de aislamiento configuradas para esta cárcel.",
        failed = "No se pudo enviar al jugador a la cárcel."
      }
    },
    bolos = {
      eyebrow = "Tablero BOLO",
      title = "BOLOs",
      listed = "listado",
      unknown = "Desconocido",
      search = {
        placeholder = "Buscar BOLOs por título, id, tipo o etiqueta"
      },
      actions = {
        refresh = "Actualizar",
        manageTypes = "Gestionar tipos",
        new = "Nuevo BOLO",
        back = "Volver a la lista",
        add = "Agregar",
        addPhoto = "Agregar foto",
        remove = "Eliminar"
      },
      state = {
        loading = "Cargando BOLOs...",
        empty = "No hay BOLOs que coincidan con los filtros actuales.",
        saving = "Guardando...",
        noTags = "No hay etiquetas asignadas.",
        noReports = "Aún no hay informes vinculados."
      },
      detail = {
        summary = "Resumen BOLO",
        untitled = "BOLO sin título"
      },
      fields = {
        title = "Título del BOLO",
        id = "ID del BOLO",
        type = "Tipo",
        status = "Estado",
        priority = "Prioridad",
        created = "Creado",
        updated = "Última actualización"
      },
      placeholders = {
        title = "Título del BOLO",
        id = "Generado automáticamente si está en blanco",
        type = "Seleccionar tipo",
        description = "Agregar una descripción...",
        tag = "Agregar etiqueta",
        reportSelect = "Seleccionar un informe"
      },
      sections = {
        description = "Descripción",
        descriptionSubtitle = "Captura detalles e instrucciones.",
        tags = "Etiquetas",
        tagsSubtitle = "Adjuntar identificadores rápidos para el BOLO.",
        reports = "Informes vinculados",
        reportsSubtitle = "Adjuntar archivos de informes relacionados.",
        gallery = "Galería",
        gallerySubtitle = "Adjuntar imágenes de la galería al BOLO."
      },
      gallery = {
        title = "Seleccionar una foto",
        subtitle = "Elegir una imagen de la galería para adjuntar al BOLO.",
        loading = "Cargando galería...",
        empty = "No hay fotos de galería disponibles.",
        photoAlt = "Foto de la galería"
      },
      typesModal = {
        title = "Tipos de BOLO",
        subtitle = "Agregar o eliminar tipos de BOLO para este dispositivo.",
        placeholder = "Agregar tipo de BOLO",
        empty = "No hay tipos de BOLO configurados."
      },
      types = {
        person = "Persona",
        vehicle = "Vehículo",
        property = "Propiedad",
        missing = "Desaparecido",
        other = "Otro"
      },
      status = {
        active = "Activo",
        located = "Localizado",
        closed = "Cerrado",
        cancelled = "Cancelado"
      },
      priority = {
        low = "Bajo",
        medium = "Medio",
        high = "Alto",
        critical = "Crítico"
      },
      errors = {
        load = "No se pueden cargar los BOLO.",
        save = "No se puede guardar el BOLO.",
        titleRequired = "Ingresar un título de BOLO antes de guardar.",
        typeRequired = "Seleccionar un tipo de BOLO antes de guardar.",
        gallery = "No se puede cargar la galería."
      }
    },
    warrants = {
      eyebrow = "Pared de órdenes",
      title = "Ordenes de arresto",
      listed = "listado",
      unknown = "Desconocido",
      search = {
        placeholder = "Buscar órdenes de arresto por título, id, tipo o etiqueta"
      },
      actions = {
        refresh = "Actualizar",
        manageTypes = "Gestionar tipos",
        new = "Nueva orden de arresto",
        back = "Volver a la lista",
        add = "Agregar",
        addPhoto = "Agregar foto",
        remove = "Eliminar"
      },
      state = {
        loading = "Cargando órdenes de arresto...",
        empty = "No hay órdenes que coincidan con los filtros actuales.",
        saving = "Guardando...",
        noTags = "No hay etiquetas asignadas.",
        noReports = "Aún no hay informes vinculados.",
        noOffences = "Aún no hay delitos vinculados."
      },
      detail = {
        summary = "Resumen de la orden de arresto",
        untitled = "Orden sin título"
      },
      fields = {
        title = "Título de la orden",
        id = "ID de orden de detención",
        type = "Tipo",
        status = "Estado",
        priority = "Prioridad",
        created = "Creado",
        updated = "Última actualización"
      },
      placeholders = {
        title = "Título de orden de detención",
        id = "Generado automáticamente si está en blanco",
        type = "Seleccionar tipo",
        description = "Agregar una descripción...",
        tag = "Agregar etiqueta",
        reportSelect = "Seleccionar un informe",
        offenceSelect = "Seleccionar un delito"
      },
      sections = {
        description = "Descripción",
        descriptionSubtitle = "Capturar el resumen e instrucciones.",
        tags = "Etiquetas",
        tagsSubtitle = "Adjuntar identificadores rápidos para la orden de detención.",
        reports = "Informes vinculados",
        reportsSubtitle = "Adjuntar archivos de informes relacionados.",
        offences = "Delitos",
        offencesSubtitle = "Vincular delitos relacionados con esta orden.",
        gallery = "Galería",
        gallerySubtitle = "Adjuntar imágenes de la galería a la orden."
      },
      gallery = {
        title = "Seleccionar una foto",
        subtitle = "Elegir una imagen de la galería para adjuntar a la orden.",
        loading = "Cargando galería...",
        empty = "No hay fotos de galería disponibles.",
        photoAlt = "Foto de la galería"
      },
      typesModal = {
        title = "Tipos de órdenes de detención",
        subtitle = "Agregar o quitar tipos de órdenes para este dispositivo.",
        placeholder = "Agregar tipo de orden",
        empty = "No hay tipos de órdenes configurados."
      },
      types = {
        arrest = "Detener",
        search = "Buscar",
        bench = "Banca",
        probation = "Libertad condicional"
      },
      status = {
        active = "Activo",
        served = "Servido",
        expired = "Expirado",
        cancelled = "Cancelado"
      },
      priority = {
        low = "Bajo",
        medium = "Medio",
        high = "Alto",
        critical = "Crítico"
      },
      errors = {
        load = "No se pudo cargar las órdenes de detención.",
        save = "No se pudo guardar la orden.",
        titleRequired = "Ingrese un título de orden antes de guardar.",
        typeRequired = "Seleccione un tipo de orden antes de guardar.",
        gallery = "No se pudo cargar la galería."
      }
    },
    prison = {
      eyebrow = "Registro de detenciones",
      title = "Prisión",
      listed = "listado",
      search = {
        placeholder = "Buscar por nombre o id"
      },
      filters = {
        all = "Todos",
        label = "Estado",
        placeholder = "Estado"
      },
      actions = {
        refresh = "Actualizar",
        back = "Volver a la lista",
        saveDuration = "Guardar duración",
        minusMinutes = "Restar 15 minutos",
        minusSmall = "Restar 5 minutos",
        plusSmall = "Sumar 5 minutos",
        plusMinutes = "Sumar 15 minutos",
        saveNotes = "Guardar notas",
        saveWarrant = "Vincular orden de arresto",
        addOffence = "Agregar delito",
        setSolitary = "Enviar a aislamiento",
        setGeneral = "Regresar a general"
      },
      state = {
        loading = "Cargando prisioneros...",
        empty = "No hay prisioneros que coincidan con los filtros actuales.",
        saving = "Guardando...",
        noOffences = "Aún no hay delitos vinculados."
      },
      labels = {
        mugshot = "Foto de ficha policial"
      },
      detail = {
        summary = "Resumen del prisionero"
      },
      fields = {
        booked = "Reservado",
        remaining = "Tiempo restante",
        identifier = "Identificador",
        unknown = "Desconocido",
        remainingMinutes = "Minutos restantes",
        warrant = "Orden de arresto",
        offences = "Delitos",
        housing = "Alojamiento"
      },
      sections = {
        duration = "Duración de la condena",
        durationSubtitle = "Ajustar tiempo restante en minutos.",
        notes = "Notas",
        notesSubtitle = "Registrar observaciones para esta sentencia.",
        links = "Orden de arresto y delitos vinculados",
        linksSubtitle = "Adjuntar la orden de arresto y delitos relacionados con esta estancia.",
        housing = "Alojamiento",
        housingSubtitle = "Alternar entre aislamiento y población general."
      },
      placeholders = {
        note = "Agregar notas...",
        warrant = "Seleccionar una orden de arresto",
        offence = "Seleccionar un delito"
      },
      status = {
        in_prison = "En prisión",
        breaked_out = "Escapado",
        released = "Liberado gratuitamente"
      },
      solitary = {
        active = "Confinamiento en aislamiento",
        inactive = "Población general",
        badge = "Aislamiento"
      },
      duration = {
        minutesOnly = "{minutes}m restante",
        full = "{hours}h {minutes}m restantes"
      },
      linked = {
        warrantFallback = "Emitir multa"
      },
      date = {
        unknown = "Desconocido"
      },
      errors = {
        load = "No se pueden cargar los prisioneros.",
        duration = "No se puede actualizar la duración.",
        note = "No se puede guardar la nota.",
        links = "No se pueden actualizar los enlaces.",
        solitary = "No se puede actualizar el aislamiento.",
        solitary_unavailable = "No hay celdas de aislamiento configuradas para esta cárcel."
      }
    },
    workshopConfig = {
      header = {
        title = "Job Configurator"
      },
            sidebar = {
        features = "Funciones",
        entries = "Jobs",
        interactions = "Interacciones"
      },
      sections = {
        general = "General",
        shop = "Tienda",
        props = "Props",
        vehicles = "Vehiculos",
        locations = "Ubicaciones"
      },
      features = {
        title = "Funciones",
        subtitle = "Activa o desactiva funciones del recurso para todos los jobs configurados.",
        instantTuning = { label = "instantTuning", description = "" },
        partsDelivery = { label = "Entrega de piezas", description = "Activa pedidos de piezas del taller y zonas de entrega." },
        carryItems = { label = "Manipulacion fisica de piezas", description = "Requiere transportar piezas entregadas por el taller." },
        nitro = { label = "nitro", description = "" },
        antiLag = { label = "antiLag", description = "" },
        twoStep = { label = "twoStep", description = "" },
        wheelDamage = { label = "Dano de ruedas", description = "Activa dano realista de ruedas y reparaciones." },
        customHandling = { label = "customHandling", description = "" },
        mileageHud = { label = "HUD de kilometraje", description = "Muestra informacion de kilometraje al conducir." },
        workshopLift = { label = "Elevador de taller", description = "Activa puntos de elevador utilizables en talleres." }
      },
actions = {
        add = "Add",
        addItem = "Add item",
        addPart = "Add part",
        addProp = "Add prop",
        addVehicle = "Add vehicle",
        apply = "Apply",
        back = "Back",
        cancel = "Cancel",
        close = "Close",
        done = "Done",
        edit = "Edit",
        newEntry = "New job",
        pickColor = "Pick",
        reset = "Reset",
        save = "Save",
        set = "Set",
        teleport = "Teleport",
        unset = "Unset"
      },
      editor = {
        editTitle = "Edit job",
        newTitle = "New job"
      },
      overview = {
        subtitle = "Select a job to edit or create a new one from the last saved settings.",
        emptySubtitle = "Create the first job to start moving this config into the database.",
        counts = "{shop} shop / {vehicles} vehicles / {props} props"
      },
      globalSettings = {
        title = "Global settings",
        notice = "These values apply to all configured jobs. Saving them from this job updates the behavior globally."
      },
      tuning = {
        globalTitle = "Global pricing settings",
        globalBadge = "Global",
        globalNotice = "These values apply to all configured jobs. Saving them from this job updates pricing behavior globally.",
        nitroAccess = "Acceso a nitro para este trabajo",
        nitroAccessHelp = "Anular la configuración global de Nitro para este trabajo de mecánico.",
        nitroAccessInherit = "Usar configuración global de Nitro",
        nitroAccessEnabled = "Activar Nitro para este trabajo",
        nitroAccessDisabled = "Desactivar Nitro para este trabajo",
      },
      fields = {
        allowedJobs = "Allowed jobs",
        animationDict = "Animation dict",
        animationName = "Animation name",
        blip = "Blip",
        bone = "Bone",
        category = "Category",
        color = "Job color",
        consumeItems = "Consumir items",
        cost = "Cost",
        distance = "Distance",
        enabled = "Enabled",
        garageType = "Garage type",
        heading = "Heading",
        item = "Item",
        jobName = "Job name",
        label = "Label",
        marker = "Marker",
        mechanicOnly = "Mechanic",
        name = "Name",
        offsetX = "Offset X",
        offsetY = "Offset Y",
        offsetZ = "Offset Z",
        offDutyEnabled = "Off-duty enabled",
        offDutyJob = "Off-duty job",
        ped = "Ped",
        pedModel = "Ped model",
        price = "Price",
        prop = "Prop",
        requiredItems = "Required items",
        scenario = "Scenario",
        sprite = "Sprite",
        stage = "Stage",
        transport = "Transport",
        trunkCapacity = "Trunk capacity",
        type = "Type",
        value = "Value",
        x = "X",
        y = "Y",
        z = "Z",
        minGrade = "Rango mínimo",
        livery = "Librea",
        fuelType = "Tipo de combustible",
        primaryColor = "Color principal",
        secondaryColor = "Color secundario",
        pearlescentColor = "Color perlado",
        wheelColor = "Color de ruedas",
        extras = "Extras",
        extraId = "ID de extra",
        propCounts = "Límites de props",
        count = "Límite",
        properties = "Propiedades del vehículo",
        property = "Propiedad",
      },
      placeholders = {
        allowedJobs = "mechanic, tuner",
        itemName = "Item name",
        jobName = "job name",
        label = "Label",
        model = "Model",
        vehicleName = "Name",
        liveryIndex = "e.g. 0",
        paintIndex = "0-160",
        propCounts = "{ \"prop_model\": 4 }",
        properties = "{ \"windowTint\": 1 }",
      },
      fuelTypes = {
        default = "Predeterminado (regular)",
        regular = "Regular",
        plus = "Plus",
        premium = "Premium",
        diesel = "Diésel",
      },
      descriptions = {
        color = "Color used by Sky Jobs menus, blips, and job UI accents.",
        jobName = "Framework job name registered for this job.",
        offDutyEnabled = "Enable an off-duty counterpart for this job.",
        offDutyJob = "Job name used when this employee goes off duty."
      },
      messages = {
        empty = "No jobs configured yet.",
        featuresSaved = "Features saved.",
        invalidJson = "Correct invalid JSON fields before saving.",
        loading = "Loading jobs...",
        nameExists = "A job with this job name already exists.",
        noTuningOptions = "No options configured in this category.",
        saved = "Settings saved.",
        saveFailed = "Unable to save changes."
      },
      locations = {
        addSubtitle = "Choose which point type to place.",
        addTitle = "Add location point",
        deleteFailed = "Unable to delete location.",
        deleteSaved = "Location removed. Save settings to apply it.",
        emptySubtitle = "This configurator has no registered location definitions.",
        emptyTitle = "No locations configured.",
        garageMenu = "Menu",
        garagePark = "Park",
        garageSpawn = "Spawn",
        placeFailed = "Unable to place location.",
        placementHint = "Press Enter to place and Backspace to cancel.",
        placementSaved = "Location updated. Save settings to apply it.",
        placementTitle = "Placement mode",
        teleported = "Teleported to location.",
        teleportFailed = "Unable to teleport to location.",
        unset = "Not set"
      },
      carryItems = {
        missingProp = "Enter a prop model before opening placement.",
        placementFailed = "Unable to edit attach placement.",
        placementSaved = "Attach placement updated. Save settings to apply it.",
        selectItem = "Select delivery item"
      },
      extensions = { invalidJson = "JSON no valido. Corrige la sintaxis antes de guardar.", jsonObjectRequired = "El valor debe ser un objeto JSON.", partsDeliveryShop = "Tienda de entrega de piezas", tuningCostProfile = { label = "Precios de tuning", description = "Configura costes de rendimiento, estetica, ruedas y opciones especiales para este job." } },
garageTypes = {
        boat = "Boat",
        helicopter = "Helicopter",
        vehicle = "Vehicle"
      },
      colorPopup = {
        title = "Job color"
      },
      dialogs = {
        delete = {
          cancel = "Cancel",
          confirm = "Delete",
          message = "Delete {name}?",
          title = "Delete job"
        }
      },
      screenPosition = {
        preview = "HUD"
      },
      interactions = {
        title = "Interactions",
        empty = "No interactions configured.",
        addMarkerSetting = "Add marker setting",
        noPedSelected = "No ped selected",
        headers = { interaction = "Interaction", key = "Key", marker = "Marker", blip = "Blip", npc = "NPC" },
        tabs = { behavior = "Behavior", marker = "Marker", blip = "Blip", npc = "NPC" },
        status = { on = "On", off = "Off" },
        fields = { unique = "Unique", forceMarkerInteraction = "Force marker interaction", interactionDistance = "Interaction distance", placementModel = "Placement model" },
        help = {
          unique = "Limits the interaction type to one configured point for a location when enabled.",
          forceMarkerInteraction = "Forces marker-style interaction handling even when target/NPC interaction support is available.",
          interactionDistance = "Maximum distance from the point where the player can use the interaction.",
          placementModel = "Object model shown while placing this interaction in the creator."
        }
      },
      assetPicker = {
        search = "Search",
        allCategories = "All categories",
        itemCount = "{count} items",
        markerTitle = "Marker type",
        markerSubtitle = "Choose a DrawMarker type.",
        blipTitle = "Blip sprite",
        blipSubtitle = "Choose a map blip sprite.",
        pedTitle = "Ped model",
        pedSubtitle = "Choose a FiveM ped model.",
        chooseMarker = "Choose marker",
        chooseBlip = "Choose blip",
        choosePed = "Choose ped"
      },
      markerFields = {
        posX = "Position X",
        posY = "Position Y",
        posZ = "Position Z",
        dirX = "Direction X",
        dirY = "Direction Y",
        dirZ = "Direction Z",
        rotX = "Rotation X",
        rotY = "Rotation Y",
        rotZ = "Rotation Z",
        scaleX = "Scale X",
        scaleY = "Scale Y",
        scaleZ = "Scale Z",
        red = "Red",
        green = "Green",
        blue = "Blue",
        alpha = "Alpha",
        bobUpAndDown = "Bob up/down",
        faceCamera = "Face camera",
        rotationOrder = "Rotation order",
        rotate = "Rotate",
        textureDict = "Texture dict",
        textureName = "Texture name",
        drawOnEnts = "Draw on entities"
      },
      instantTuning = {
        title = "Instant Tuning",
        defaultLabel = "Default label",
        defaultLabelHelp = "Text shown at instant tuning points.",
        interactionDistanceHelp = "Default distance from which a point can be used.",
        priceMultiplier = "Price multiplier",
        priceMultiplierHelp = "Multiplier applied to instant tuning prices.",
        forceMarkerHelp = "Forces marker-style interaction handling even when target support is available.",
        mechanicOnlyHelp = "Restricts every instant tuning point to configured mechanic jobs.",
        allowedJobsHelp = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.",
        emptyLocations = "No instant tuning locations configured.",
        emptyLocationsHelp = "Add a location, then use Set to capture your current position."
      }
  ,

      configs = { sky_mechanicjob = { title = "Trabajos de mecanico", subtitle = "Configura trabajos de mecanico, tiendas, vehiculos y ubicaciones de taller." } },
      settingSections = { general = "General", partsTheft = "Robo de piezas", vehicleCare = "Cuidado del vehiculo", wear = "Desgaste", wheelDamage = "Dano de ruedas", mileageHud = "HUD de kilometraje", instantTuning = "Instant Tuning", carryItems = "Piezas transportables" },
      settingFields = { key = "Clave", label = "Etiqueta", name = "Nombre del item", amount = "Cantidad", price = "Precio", item = "Item", repair = "Reparar con kit", classId = "ID de clase", multiplier = "Multiplicador", kilometersToZero = "Kilometros hasta cero", removeAfterUse = "Consumir item", flow = "Flujo de instalacion", transport = "Transporte", prop = "Prop", bone = "Bone", x = "X", y = "Y", z = "Z", rx = "Rot X", ry = "Rot Y", rz = "Rot Z", category = "Categoria" },
      settings = {
        primaryColor = { label = "Color principal", description = "Main mechanic configurator color and default job color fallback. Use a hex value such as #EDC001." },
        orderInstallNonMinigameDurationMs = { label = "Duracion simple de instalacion", description = "Milliseconds used for order install steps that do not run a minigame." },
        tuningWorkshopRequireForInstall = { label = "Requerir taller para instalar", description = "Require tuning order installs to start and complete near a self-service tuning point." },
        tuningWorkshopRequireForRemoval = { label = "Requerir taller para retirar", description = "Require tuning removals to start and complete near a self-service tuning point." },
        tuningWorkshopDistance = { label = "Distancia requerida del taller", description = "Maximum distance from a self-service tuning point for required install or removal actions." },
        addRevenueToSociety = { label = "Depositar ingresos en sociedad", description = "Deposit paid tuning order money into the tuning job society account." },
        publicUsersSeePrices = { label = "Precios visibles al publico", description = "Show regular tuning prices to non-mechanic public users." },
        fallbackVehicleValue = { label = "Valor de vehiculo por defecto", description = "Value used when no vehicle price can be resolved." },
        priceType = { label = "Tipo de precio", description = "Percentage calculates each tuning cost from the vehicle price. Fixed uses the entered money amount.", options = { percentage = "Porcentaje", fixed = "Fijo" } },
        freeVehicles = { label = "Vehiculos con tuning gratis", description = "Vehicle spawn models that receive free tuning orders.", itemLabel = "Vehicle model" },
        partsTheftItem = { label = "Herramienta de robo", description = "Inventory item used to steal wheels and catalytic converters." },
        partsTheftRemoveItemAfterUse = { label = "Consumir herramienta de robo", description = "Remove the theft tool item after a successful theft action." },
        partsTheftStolenWheelItem = { label = "Rueda robada", description = "Inventory item awarded when wheels are stolen." },
        partsTheftCatalyticConverterItem = { label = "Catalizador", description = "Inventory item awarded when a catalytic converter is stolen." },
        partsTheftDealerAccount = { label = "Dealer payout account", description = "Account used for stolen parts dealer payouts, such as money or bank." },
        partsTheftDealerSellDistance = { label = "Dealer sell distance", description = "Maximum distance from the dealer to sell stolen parts." },
        partsTheftDispatchEnabled = { label = "Enviar dispatch policial", description = "Create a police dispatch when a wheel or catalytic converter is stolen." },
        partsTheftDispatchJobs = { label = "Dispatch jobs", description = "Job names that receive parts theft dispatches.", itemLabel = "Job name" },
        partsTheftDispatchTitle = { label = "Dispatch title", description = "Title shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchMessage = { label = "Dispatch message", description = "Message shown on the dispatch alert. Supports {plate}, {part}, and {type}." },
        partsTheftDispatchCooldownSeconds = { label = "Dispatch cooldown", description = "Seconds before the same vehicle part can create another dispatch." },
        partsTheftDealerItems = { label = "Dealer items", description = "Stolen items the dealer will buy and their payout values.", itemLabel = "Dealer item" },
        vehicleCareWashItem = { label = "Item de lavado", description = "Inventory item used to wash a vehicle." },
        vehicleCareWashRemoveAfterUse = { label = "Consumir item de lavado", description = "Remove the wash item after use." },
        vehicleCareWaxItem = { label = "Item de cera", description = "Inventory item used to wax a vehicle." },
        vehicleCareWaxRemoveAfterUse = { label = "Consumir item de cera", description = "Remove the wax item after use." },
        vehicleCareWaxCleanKilometers = { label = "Wax clean kilometers", description = "Distance a waxed vehicle stays clean." },
        vehicleCareRepairItem = { label = "Item de reparacion", description = "Inventory item used by the vehicle repair action." },
        vehicleCareRepairRemoveAfterUse = { label = "Consumir item de reparacion", description = "Remove the repair item after use." },
        vehicleCareRepairDurationMs = { label = "Duracion de reparacion", description = "Repair progress duration in milliseconds." },
        vehicleCareRepairMaxDistance = { label = "Repair max distance", description = "Maximum distance from the vehicle while repairing." },
        vehicleCareRepairVehicleDamage = { label = "Fix vehicle damage", description = "Repair normal GTA vehicle damage when using the repair action." },
        vehicleCareRepairFixRealisticWheelDamage = { label = "Fix realistic wheel damage", description = "Also reset realistic wheel damage when using the repair action." },
        vehicleCareRepairWearParts = { label = "Repair kit restored parts", description = "Choose which wear and service parts the repair item restores. Disable fluids here if oil, coolant, brake fluid, or transmission fluid should require the diagnostics repair flow.", itemLabel = "Wear part" },
        wearParts = { label = "Piezas de desgaste", description = "Vehicle wear parts, their lifetime distance, required repair item, item consumption, and install flow.", itemLabel = "Wear part", fields = { flow = { options = { wheel = "Wheel", performance = "Performance", underbody_neon = "Underbody / lift", oil_change = "Oil change", fluid_refill = "Fluid refill", catalytic_converter = "Catalytic converter", hood_install = "Hood install" } } } },
        wheelDamageDefaultMultiplier = { label = "Multiplicador por defecto", description = "Base wheel damage multiplier." },
        wheelDamageOffroadWheelsMultiplier = { label = "Off-road wheel multiplier", description = "Multiplier used when the vehicle has off-road wheels." },
        wheelDamageVehicleClassMultipliers = { label = "Vehicle class multipliers", description = "Damage multipliers per GTA vehicle class.", itemLabel = "Vehicle class" },
        mileageHudDigits = { label = "Digitos", description = "Number of digits shown in the mileage HUD." },
        mileageHudPosition = { label = "Posicion", description = "Drag the mileage HUD preview to the desired screen position." },
        partsDeliveryTimeSeconds = { label = "Tiempo de entrega", description = "Seconds between ordering parts and the delivery becoming ready." },
        partsDeliveryTimerHudEnabled = { label = "Show delivery timer", description = "Show a small in-game timer HUD after a parts order is placed." },
        partsDeliveryTimerHudPosition = { label = "Timer position", description = "Drag the parts delivery timer HUD preview to the desired screen position." },
        partsDeliveryOwnCard = { label = "Own card payment", description = "Allow players to pay parts delivery orders with their own money." },
        partsDeliveryCompanyCard = { label = "Company card payment", description = "Allow parts delivery orders to use company funds." },
        partsDeliveryOpenDurationMs = { label = "Open duration", description = "Milliseconds required to unpack a ready parts delivery." },
        instantTuningInteractionDistance = { label = "Distancia de interaccion", description = "Default distance for using instant tuning points." },
        instantTuningForceMarkerInteraction = { label = "Force marker interaction", description = "Use marker-style E interaction even when target support is enabled." },
        instantTuningMechanicOnly = { label = "Solo mecanicos", description = "Restrict all instant tuning locations to configured mechanic jobs." },
        instantTuningAllowedJobs = { label = "Jobs permitidos", description = "Optional global allow-list. Leave empty to allow everyone unless mechanic-only is enabled.", itemLabel = "Job name" },
        instantTuningPriceMultiplier = { label = "Multiplicador de precio", description = "Multiplier applied to instant tuning prices." },
        instantTuningLabel = { label = "Etiqueta por defecto", description = "Default text shown at instant tuning points." },
        instantTuningMarkerEnabled = { label = "Marker enabled", description = "Draw a world marker at instant tuning locations." },
        instantTuningMarkerType = { label = "Marker type", description = "GTA marker type used for instant tuning locations." },
        instantTuningBlipEnabled = { label = "Blip enabled", description = "Show map blips for instant tuning locations." },
        instantTuningBlipName = { label = "Blip name", description = "Map blip name." },
        instantTuningBlipSprite = { label = "Blip sprite", description = "GTA blip sprite id." },
        instantTuningBlipColor = { label = "Blip color", description = "GTA blip color id." },
        instantTuningLocations = { label = "Ubicaciones", description = "Instant tuning points. Use 0 distance to inherit the default interaction distance.", itemLabel = "Locations" },
        carryItems = { label = "Piezas transportables", description = "Delivered parts that should become physical carried props.", itemLabel = "Carry item", fields = { transport = { options = { hand = "Mano", forklift = "Montacargas", engine_lift = "Grua de motor" } } } }
      },
      settingValues = {
        tyres = "Neumaticos", brake_pads = "Pastillas de freno", suspension = "Suspension", spark_plugs = "Spark Plugs", engine_oil = "Aceite de motor", coolant = "Refrigerante", brake_fluid = "Liquido de frenos", transmission_fluid = "Liquido de transmision", clutch = "Embrague", air_filter = "Filtro de aire", traction_battery = "Bateria de traccion", inverter = "Power Inverter", catalytic_converter = "Catalizador",
        vehicleClass_0 = "Compacts", vehicleClass_1 = "Sedans", vehicleClass_2 = "SUVs", vehicleClass_3 = "Coupes", vehicleClass_4 = "Muscle", vehicleClass_5 = "Sports Classics", vehicleClass_6 = "Sports", vehicleClass_7 = "Super", vehicleClass_8 = "Motorcycles", vehicleClass_9 = "Off-road", vehicleClass_10 = "Industrial", vehicleClass_11 = "Utility", vehicleClass_12 = "Vans", vehicleClass_13 = "Cycles", vehicleClass_14 = "Boats", vehicleClass_15 = "Helicopters", vehicleClass_16 = "Planes", vehicleClass_17 = "Service", vehicleClass_18 = "Emergency", vehicleClass_19 = "Military", vehicleClass_20 = "Commercial", vehicleClass_21 = "Trains", vehicleClass_22 = "Open Wheel"
      }
  },
    jobConfigurator = {
      actions = {
        backToScripts = "Scripts"
      },
      selector = {
        title = "Seleccionar script de trabajo",
        subtitle = "Elige que script de trabajo quieres configurar.",
        description = "Elige el recurso que quieres configurar.",
        loading = "Cargando configuradores...",
        comingSoon = "Proximamente",
        emptyTitle = "No hay scripts configurables disponibles.",
        emptySubtitle = "No tienes permiso para ningun configurador de trabajo registrado.",
        unavailable = "No registrado"
      }
    },
    billing = {
      title = "Emitir factura",
      subtitle = "Cobrar a los ciudadanos cercanos por servicios.",
      selectLabel = "Seleccionar persona",
      selectPlaceholder = "Elegir persona",
      noPlayers = "No hay personas cercanas dentro de {range} m.",
      amountLabel = "Monto de la multa",
      reasonLabel = "Razón (corta)",
      reasonPlaceholder = "Ejemplo: Servicio de patrulla",
      presetsLabel = "Faltas",
      presetSearchPlaceholder = "Buscar delito o multa",
      presetNoMatches = "No hay delitos que coincidan con tu búsqueda.",
      presetReasonHeader = "Delito",
      presetAmountHeader = "Multa",
      presetCustomAmount = "Personalizado",
      paperDefaultCategory = "Aviso de infracción de estacionamiento",
      ticketReceiptTitle = "Aviso de citación",
      ticketReceiptSubtitle = "Registrado en",
      ticketReceiptCitizenLabel = "Ciudadano",
      ticketReceiptOfficerLabel = "Personal emisor",
      ticketReceiptReasonLabel = "Resumen de cargos",
      ticketReceiptAmountLabel = "Multa total",
      ticketReceiptAcknowledge = "Reconocer",
      cancelButton = "Cancelar",
      submitButton = "Emitir factura",
      submitting = "Enviando...",
      success = "Factura emitida con éxito.",
      paperTicketNumber = "Número de ticket",
      paperDate = "Fecha",
      paperTime = "Hora",
      paperCitizenLabel = "Ciudadano",
      paperOfficerLabel = "Personal",
      paperViolationLabel = "Infracción",
      paperNotice = "Pago inmediato requerido. La no realización del pago puede resultar en la confiscación.",
      paperSignatureLabel = "Firma del personal",
      paperTotalFine = "Multa total",
      errors = {
        failed = "No se puede emitir la factura.",
        invalid_target = "Persona no disponible.",
        empty_reason = "Proveer una razón breve.",
        too_far = "La persona se alejó demasiado.",
        not_authorized = "No tienes autorización para emitir facturas.",
        not_on_duty = "Debes estar en turno para emitir facturas.",
        amount_out_of_range = "Cantidad de la factura fuera del rango permitido.",
        insufficient_funds = "La persona no puede pagar este cargo.",
        player_unavailable = "Persona no disponible.",
        disabled = "Sistema de facturación deshabilitado."
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
