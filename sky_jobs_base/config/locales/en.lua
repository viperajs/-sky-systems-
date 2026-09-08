if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/config/locales/en.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

-- English translation
Locales["en"] = {
  WardrobeHelpNotify = "Open Wardrobe",
  WardrobeTitle = "Wardrobe",
  WardrobeCivilianMissing = "No civilian outfit stored yet.",
  WardrobeCivilianRestored = "Civilian outfit loaded.",
  WardrobeUnknownJob = "Wardrobe job is not available.",
  WardrobeUnsupportedFramework = "Wardrobe does not work with the selected framework ({framework}).",
  WardrobeMissingSkinchanger = "Wardrobe requires skinchanger to be started on ESX.",
  WardrobeMissingEsxSkin = "Wardrobe requires esx_skin to be started on ESX.",
  WardrobeMissingRcoreClothing = "Wardrobe requires rcore_clothing to be started.",
  WardrobeMissingQbClothing = "Wardrobe requires qb-clothing to be started on {framework}.",
  WardrobeMissing17Movement = "Wardrobe requires 17mov_CharacterSystem to be started.",
  WardrobeMissingQsAppearance = "Wardrobe requires qs-appearance to be started.",
  WardrobeMissingAk47Clothing = "Wardrobe requires ak47_clothing to be started.",
  WardrobeMissingAk47QbClothing = "Wardrobe requires ak47_qb_clothing to be started.",
  WardrobeMissingTgiannClothing = "Wardrobe requires tgiann-clothing to be started.",
  WardrobeMissingNfSkin = "Wardrobe requires nf-skin to be started.",
  WardrobeMissingBlAppearance = "Wardrobe requires bl_appearance to be started.",
  WardrobeMissingIzzyAppearance = "Wardrobe requires izzy-appearance to be started.",
  WardrobeMissingCodemAppearance = "Wardrobe requires codem-appearance to be started.",
  WardrobeMissingHexClothing = "Wardrobe requires hex_clothing to be started.",
  WardrobeMissingIllenium = "Wardrobe requires illenium-appearance to be started.",
  WardrobeCustomUnavailable = "The configured custom wardrobe integration is not available.",
  WardrobeDisabled = "Wardrobe is disabled in the config.",
  GarageHelpNotify = "Open Garage",
  GarageTitle = "Garage",
  HelicopterGarageHelpNotify = "Open Helipad",
  BoatGarageHelpNotify = "Open Dock",
  GarageParkHelpNotify = "Park the vehicle",
  HelicopterGarageParkHelpNotify = "Park the helicopter",
  BoatGarageParkHelpNotify = "Park the boat",
  GarageParkDriverRequired = "You need to be in the driver seat to park.",
  GarageParkInvalidVehicle = "This vehicle can't be parked here.",
  GarageParkFailedNotify = "Unable to park vehicle.",
  GarageSpawnBlockedNotify = "Spawn point is blocked.",
  StorageHelpNotify = "Access storage",
  LockerHelpNotify = "Open locker",
  TrunkTitle = "Trunk",
  TrunkHelpNotify = "Access the trunk",
  TrunkPropRemoveHelp = "Remove placed prop",
  TrunkUnavailable = "Unable to access this trunk.",
  BossMenuHelpNotify = "Open Management",
  Payroll = {
    title = "Payroll",
    paid = "Salary payment received: {amount}",
    insufficient = "Not enough funds in company account for your salary.",
  },
  PublicFormsTitle = "Public Forms",
  PublicFormsHelpNotify = "Fill out public forms",
  PublicFormsUnavailable = "Public forms kiosk unavailable.",
  WholesaleShopTitle = "Wholesale",
  WholesaleShopHelpNotify = "Open Wholesale Shop",
  WholesaleShopUnavailable = "This location has no wholesale supplier configured.",
  NoPermission = "You do not have permission to use this command.",
  CameraUploadFailed = "Camera upload failed.",
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
    Title = "Panic",
    Sent = "Panic button triggered.",
    NotOnDuty = "You must be on duty to use the panic button.",
    MissingItem = "You need {item} to use the panic button.",
    Cooldown = "Panic button is cooling down. Wait {seconds}s.",
    MappingDescription = "Trigger panic alert",
    WaypointSet = "Waypoint set to panic location.",
    WaypointMissing = "No active panic location.",
    LocationUnknown = "Unknown location"
  },
  Ping = {
    Title = "Ping",
    Sent = "Location ping shared.",
    NotOnDuty = "You must be on duty to send a ping.",
    MissingItem = "You need {item} to send a ping.",
    Cooldown = "Ping is cooling down. Wait {seconds}s.",
    MappingDescription = "Trigger location ping",
    LocationUnknown = "Unknown location"
  },
  HeliCam = {
    Title = "Heli Cam",
    CamEnabled = "Heli cam enabled.",
    CamDisabled = "Heli cam disabled.",
    NotAuthorized = "You are not authorized to use the heli cam.",
    NotOnDuty = "You must be on duty to use the heli cam.",
    TooLow = "Helicopter is too low to activate the camera.",
    TargetLocked = "Target locked.",
    TargetReleased = "Target lock released.",
    TargetLost = "Target lost.",
    RappelDenied = "You can't rappel from this seat.",
    RappelStarted = "Rappel initiated.",
    PhotoSaved = "Heli photo saved to the gallery.",
    PhotoFailed = "Unable to save heli photo.",
    Spotlight = {
      ForwardOn = "Searchlight on.",
      ForwardOff = "Searchlight off.",
      TrackingOn = "Tracking spotlight engaged.",
      TrackingOff = "Tracking spotlight off.",
      ManualOn = "Manual spotlight engaged.",
      ManualOff = "Manual spotlight off.",
      Brightness = "Spotlight brightness: {value}",
      Radius = "Spotlight radius: {value}"
    }
  },
  InteractionLabels = {
    job_garage              = "Job Garage",
    garage_vehicle_spawn    = "Vehicle Spawn Point",
    garage_vehicle_park     = "Vehicle Parking",
    garage_helicopter_menu  = "Helicopter Garage",
    garage_helicopter_spawn = "Helicopter Spawn Point",
    garage_helicopter_park  = "Helicopter Parking",
    garage_boat_menu        = "Boat Dock",
    garage_boat_spawn       = "Boat Spawn Point",
    garage_boat_park        = "Boat Parking",
    boss_menu               = "Boss Menu",
    duty_terminal           = "Duty Terminal",
    wardrobe                = "Wardrobe",
    storage                 = "Storage",
    locker                  = "Locker",
    wholesale_shop          = "Wholesale Shop",
    public_forms            = "Public Forms",
    jail_terminal           = "Jail Terminal",
    jail_jobs               = "Jail Jobs",
    jail_job_npc            = "Jail Jobs",
    jail_inmate_alcoholic   = "Inmate: Alcoholic",
    jail_inmate_drugdealer  = "Inmate: Drug Dealer",
    jail_inmate_codelist    = "Inmate: Informant",
    jail_inmate_wirecutter  = "Inmate: Tool Runner",
    jail_inmate_doctor      = "Jail Doctor",
    jail_canteen_cook       = "Canteen Cook",
    jail_confiscated_return = "Confiscated Items",
    jail_electric_box       = "Electrical Box",
    jail_fence_cut          = "Fence Cut Point",
  },
  Nui = {
    IntlLocale = "en-US",
    currency = "$",
    menuTitles = {
      locker = "Personal Locker",
      storage = "Storage",
      trunk = "Vehicle Storage",
      ["trunk-props"] = "Vehicle Props",
      search = "Search",
      garage = "Garage",
      vehshop = "Vehicle Shop",
      management = "Management",
      shop = "Wholesale",
      ["impound-storage"] = "Impound Storage",
      refunds = "Refunds"
    },
    menu = {
      goToVehicleShop = "Go to Vehicle Shop",
      backToGarage = "Back to Garage"
    },
    radial = {
      empty = "No actions available right now.",
      errors = {
        generic = "Action unavailable."
      },
      title = "Duty actions",
      hint = "Select an action to perform.",
      pressKey = "Press {key}",
      actions = {
        billing = {
          label = "Issue bill",
          description = "Issue a bill to the nearest person.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Billing is unavailable.",
            notOnDuty = "Go on duty to issue invoices.",
            notAuthorized = "You are not authorized to issue invoices.",
            noPatients = "No nearby persons to bill."
          }
        },
        panic = {
          label = "Panic button",
          description = "Trigger a panic alert for your current location.",
          states = {
            disabled = "Panic button is unavailable.",
            notOnDuty = "Go on duty to use the panic button.",
            notAuthorized = "You are not authorized to use the panic button."
          }
        },
        tablet = {
          label = "Open tablet",
          description = "Open the tablet interface.",
          states = {
            notOnDuty = "Go on duty to use the tablet.",
            notAuthorized = "You are not authorised to use the tablet.",
            missingItem = "You need a tablet to do this."
          }
        },
        removeProp = {
          label = "Remove prop",
          description = "Remove a nearby placed prop.",
          states = {
            noNearby = "No placed prop nearby.",
            failed = "Failed to remove prop."
          }
        },
        carryPatient = {
          label = "Carry person",
          description = "Carry the closest person to safety.",
          dropLabel = "Drop person",
          dropDescription = "Release the person you are carrying.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Carrying is unavailable.",
            beingCarried = "You are already being carried.",
            inVehicle = "Exit the vehicle first.",
            selfIncapacitated = "You are not stable enough to carry someone.",
            noPatients = "No nearby persons to carry.",
            tooFar = "Move closer before carrying someone."
          }
        },
        playerSearch = {
          label = "Search person",
          description = "Search the nearest person.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Player search is unavailable.",
            notOnDuty = "Go on duty to search people.",
            notAuthorized = "You are not authorized to search people.",
            noPlayers = "No nearby persons to search.",
            tooFar = "Move closer before searching.",
            inVehicle = "Exit the vehicle first."
          }
        },
        handcuff = {
          label = "Handcuff person",
          description = "Handcuff the nearest person.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Handcuffing is unavailable.",
            notOnDuty = "Go on duty to use handcuffs.",
            inVehicle = "Exit the vehicle first.",
            targetInVehicle = "Remove the person from the vehicle first.",
            noPlayers = "No nearby persons to cuff.",
            tooFar = "Move closer before handcuffing.",
            missingItem = "You need handcuffs to do this.",
            alreadyCuffed = "That person is already cuffed."
          }
        },
        unhandcuff = {
          label = "Remove cuffs",
          description = "Remove handcuffs from the nearest person.",
          badge = {
            distance = "{distance} m"
          },
          states = {
            disabled = "Uncuffing is unavailable.",
            notOnDuty = "Go on duty to remove handcuffs.",
            inVehicle = "Exit the vehicle first.",
            targetInVehicle = "Remove the person from the vehicle first.",
            noPlayers = "No nearby persons to uncuff.",
            tooFar = "Move closer before uncuffing.",
            notCuffed = "That person is not cuffed."
          }
        },
        wheelClamp = {
          label = "Wheel clamp",
          description = "Secure the nearest vehicle by clamping a wheel.",
          states = {
            disabled = "Wheel clamping is unavailable.",
            notOnDuty = "Go on duty to clamp vehicles.",
            inVehicle = "Exit the vehicle first.",
            noVehicle = "No vehicle nearby.",
            tooFarVehicle = "Move closer to the vehicle.",
            noWheel = "Move closer to a wheel.",
            tooFar = "Move closer to a wheel."
          }
        },
        wheelClampRemove = {
          label = "Remove clamp",
          description = "Remove the wheel clamp from the vehicle.",
          states = {
            disabled = "Wheel clamping is unavailable.",
            notOnDuty = "Go on duty to remove clamps.",
            inVehicle = "Exit the vehicle first.",
            noClamp = "No wheel clamp nearby.",
            tooFar = "Move closer to the wheel clamp."
          }
        },
        jail = {
          label = "Send to jail",
          description = "Detain the nearest player at a configured jail location.",
          states = {
            notAuthorized = "You are not authorised to send players to jail.",
            notOnDuty = "Go on duty to use this action.",
            noPlayers = "No nearby persons within range.",
            noJails = "No jail locations configured.",
            spawnNotSet = "Configure a jail spawn first.",
            invalidTarget = "Unable to locate that person.",
            failed = "Unable to perform that action."
          }
        }
      }
    },
    shop = {
      shoppingCart = "Shopping Cart",
      purchase = "Purchase",
      balance = "Available funds",
      catalog = "Supplier catalogue",
      empty = "No supplies available at this location.",
      emptyCart = "Your basket is empty.",
      insufficientFunds = "Not enough funds for this purchase.",
      limitReached = "Limit reached ({limit}).",
      errors = {
        invalidStation = "Invalid station.",
        emptyBasket = "Basket empty.",
        unknown = "Unknown error.",
        purchase = "Basket purchase failed."
      }
    },
    garage = {
      states = {
        stored = "Ready",
        parked = "In use"
      },
      title = "Garage",
      empty = "No fleet vehicles available.",
      emptyAir = "No helicopters available at this pad.",
      ownedTitle = "Owned Fleet",
      shopTitle = "Vehicle Shop",
      shopBalance = "Faction funds",
      shopEmpty = "No vehicles available for purchase at this location.",
      shopEmptyAir = "No helicopters available for purchase at this pad.",
      emptyFleet = "No fleet vehicles have been purchased yet.",
      noAccess = "No access",
      confirmSellTitle = "Confirm sale",
      confirmSellConfirm = "Sell",
      confirmSellCancel = "Cancel",
      confirmSellMessage = "Sell {name} for {price}?",
      confirmPurchaseTitle = "Confirm purchase",
      confirmPurchaseConfirm = "Purchase",
      confirmPurchaseCancel = "Cancel",
      confirmPurchaseMessage = "Purchase {name} for {price}?",
      purchaseSuccessTitle = "Vehicle purchased",
      purchaseSuccessMessage = "{name} added to the fleet.",
      defaultVehicleName = "Vehicle",
      stats = {
        topSpeed = "Top Speed",
        acceleration = "Acceleration",
        braking = "Braking",
        traction = "Traction"
      },
      actions = {
        parkOut = "Park Out",
        buyVehicle = "Purchase Vehicle",
        openTrunk = "Open Trunk",
        editStretcher = "Edit stretcher",
        sellVehicle = "Sell Vehicle",
        changePlate = "Change Plate"
      },
      placeholders = {
        selectVehicle = "Select a vehicle to view details.",
        statsLoading = "Loading vehicle information..."
      },
      errors = {
        loadVehicles = "Failed to load garage vehicles.",
        loadStats = "Failed to load vehicle stats.",
        parkOut = "Failed to park out vehicle.",
        unavailable = "Garage unavailable.",
        vehicleUnavailable = "Vehicle unavailable.",
        purchase = "Vehicle purchase failed.",
        openTrunk = "Failed to open trunk.",
        noAccess = "No access to this vehicle.",
        stretcherEditor = "Unable to open the stretcher editor.",
        stretcherPermission = "Only the highest rank can edit stretcher attachments.",
        sellVehicle = "Failed to sell vehicle.",
        editorUnavailable = "Editor unavailable.",
        changePlate = "Failed to change plate."
      },
      changePlateTitle = "Change License Plate",
      changePlateButton = "Apply",
      plateEditor = {
        button = "Edit plate",
        title = "Edit plate",
        hint = "Change the plate for this vehicle.",
        save = "Save plate",
        errors = {
          empty = "Enter a plate.",
          invalid = "Plate is invalid.",
          update = "Failed to update plate."
        }
      },
      status = {
        parkedBy = "Last taken out by {name}",
        unknownDriver = "Unknown"
      }
    },
    duty = {
      fields = {
        grade = "Rank",
        location = "Station",
        name = "Name",
        badge = "Badge"
      },
      instructions = {
        drag = "Drag your employee card onto the sensor to manage your shift.",
        dragCard = "Drag the employee card onto the sensor to start your shift."
      },
      screen = {
        welcome = "Welcome {name}",
        goodbye = "Shift ended. Take care, {name}.",
        ready = "Shift access granted.",
        completed = "Shift ended successfully.",
        idleTitle = "Awaiting scan",
        totalHours = "Total hours",
        shiftDuration = "Shift duration",
        currentTime = "Current time: {time}",
        defaultStation = "Primary Terminal",
        devPrompt = "Load mock data to preview the duty terminal in the browser.",
        loadMock = "Load mock data",
        loading = "Loading..."
      },
      toasts = {
        failed = "Unable to update duty status."
      },
      errors = {
        unavailable = "Duty terminal unavailable."
      },
      title = "Shift Terminal"
    },
    storage = {
      inventory = "Inventory",
      storage = "Storage",
      locker = "Locker",
      trunk = "Vehicle Trunk",
      trunkProps = "Vehicle Props",
      openPropMenu = "Props",
      search = "Search",
      items = "Items",
      weapons = "Weapons",
      transferTitle = "Transfer",
      transferButton = "Transfer",
      capacityUnlimited = "Unlimited capacity",
      errors = {
        trunkFull = "Trunk is full.",
        searchReadOnly = "You can only remove items from the person.",
        invalidTransfer = "Transfer failed.",
        invalidAmount = "Invalid amount.",
        notEnoughItems = "Not enough items.",
        inventoryFull = "Not enough inventory space.",
        storageFull = "Storage is full.",
        lockerFull = "Locker is full.",
        restrictedItem = "You do not have access to this item.",
        invalidProp = "Failed to select prop."
      },
      officerInventory = "Staff Inventory",
      loadout = "Loadout",
      armory = "Armory",
      armoryTitle = "Equipment Armory",
      storageTitle = "Secure Storage",
      storageSubtitle = "Authorized personnel only",
      emptyItems = "No items available.",
      emptyWeapons = "No weapons available.",
      emptyProps = "No props available.",
      searchItems = "Items",
      searchWeapons = "Weapons",
      lockerUnlocking = "Unlocking locker...",
      restrictedPill = "Restricted",
      restrictedTooltip = "You do not have access to this item.",
      capacityLabel = "{used}/{capacity}",
      propPlacement = {
        title = "Prop Placement",
        place = "Place ({key})",
        cancel = "Cancel ({key})"
      }
    },
    creator = {
      title = "Creator",
      description = "Configure entries.",
      selectJob = "Select a job category.",
      empty = "No {entryLabelPlural} configured yet.",
      keyboardHint = "Use arrow keys to navigate the list and actions.",
      placementHelp = "Arrows move, PageUp/PageDown height, Q/E rotate, Enter place, Backspace cancel.",
      editTitle = "Markers",
      editSubtitle = "Use the map pin button to store your current coordinates.",
      editKeyboardHint = "Use arrow keys to pick a marker, left/right to choose Set/Clear, Enter to run it, Backspace goes back.",
      missingEntry = "Entry not found.",
      actions = {
        add = "Add {label}",
        newEntry = "New {entryLabel}"
      },
      status = {
        set = "Set",
        unset = "Unset"
      },
      modals = {
        createTitle = "Create {entryLabel}",
        createButton = "Create {entryLabel}",
        renameTitle = "Rename {entryLabel}",
        renameButton = "Save name",
        deleteTitle = "Delete {entryLabel}",
        deleteMessage = "Do you really want to remove {name}?",
        deleteConfirmLabel = "Delete",
        deleteCancelLabel = "Cancel"
      }
    },
    management = {
      noAccess = "You do not have access to any management tools.",
      refunds = {
        description = "Review deaths from today and yesterday and refund removed items.",
        refreshButton = "Refresh",
        updatedAt = "Updated {time}",
        errors = {
          loadFailed = "Failed to load refunds."
        }
      },
      dashboard = {
        sidebarTitle = "Dashboard",
        menuTitle = "Overview",
        onlineMembers = "Online Members",
        funds = "Funds",
        onDuty = "On Duty",
        offDuty = "Off Duty",
        mostActive = "Most Active"
      },
      finance = {
        sidebarTitle = "Cash Flow",
        menuTitle = "Financial Overview",
        expenseCategories = "Expense Categories",
        revenueCategories = "Revenue Categories",
        kpis = {
          revenue = "Revenue",
          expenses = "Expenses",
          profit = "Profit"
        },
        cashFlow = "Cash flow trend",
        lastUpdated = "Updated {time}",
        emptyStates = {
          timeline = "No transactions recorded in this period.",
          categories = "No category data yet."
        },
        categories = {
          deposits = "Deposits",
          withdrawals = "Withdrawals",
          supplies = "Supplies",
          vehicles = "Vehicles",
          salaries = "Salaries",
          bonuses = "Bonuses"
        },
        errors = {
          load = "Unable to load finance snapshot."
        }
      },
      transactions = {
        sidebarTitle = "Funds",
        menuTitle = "Funds Management",
        currentBalance = "Current Balance",
        withdrawButton = "Withdraw",
        depositButton = "Deposit",
        recentTransactions = "Recent Transactions",
        columnNames = {
          timestamp = "Timestamp",
          name = "Name",
          action = "Action",
          content = "Amount"
        },
        actions = {
          deposited = "Money Deposited",
          withdrawn = "Money Withdrawn",
          supplies_purchased = "Supplies Purchased",
          vehicle_purchased = "Vehicle Purchased",
          vehicle_sold = "Vehicle Sold",
          salary_paid = "Salary Paid",
          bonus_paid = "Bonus Paid"
        },
        errors = {
          load = "Unable to load transactions.",
          failed = "Transaction failed."
        }
      },
      billingSpecs = {
        sidebarTitle = "Billing presets",
        menuTitle = "Billing reasons",
        description = "Configure the reasons staff can select while billing and define their default prices.",
        reasonColumn = "Reason",
        priceColumn = "Price",
        actionsColumn = "Actions",
        reasonLabel = "Billing reason",
        reasonPlaceholder = "e.g. Patrol response",
        amountLabel = "Default price",
        emptyState = "No billing reasons added yet.",
        addButton = "Add",
        addFirstButton = "Create your first reason",
        deleteButton = "Remove",
        saveButton = "Save",
        reasonRequired = "Enter a reason to save this row.",
        saveSuccess = "Billing specifications updated.",
        saveError = "Unable to save billing specifications.",
        loadError = "Unable to load billing specifications.",
        updatedAt = "Updated at {time}"
      },
      members = {
        sidebarTitle = "Members",
        menuTitle = "Members",
        inviteTitle = "Invite to faction",
        inviteSubtitle = "Select a player and assign an entry rank.",
        selectPlayer = "Select player",
        selectRank = "Select rank",
        sendInvite = "Invite",
        columnNames = {
          name = "Name",
          rank = "Rank",
          last_online = "Last Online",
          total_work_time = "Work Time (h)",
          actions_done = "Actions Completed",
          actions = "Actions"
        },
        bonus = {
          title = "Issue bonus",
          confirmButton = "Pay bonus",
          actionLabel = "Bonus",
          invalidAmount = "Enter a valid bonus amount.",
          failed = "Failed to pay bonus.",
          unexpectedError = "Unexpected error while paying bonus."
        },
        errors = {
          load = "Failed to fetch members.",
          loadUnexpected = "Unexpected error while fetching members.",
          invite = "Failed to send invite.",
          inviteUnexpected = "Unexpected error during invite."
        }
      },
      roles = {
        sidebarTitle = "Roles",
        menuTitle = "Roles",
        createRoleButton = "Create role",
        columnNames = {
          grade = "Grade",
          label = "Role Name",
          salary = "Salary",
          salaryInterval = "Interval (min)",
          actions = "Actions"
        },
        editMenu = {
          title = "Edit Role",
          createTitle = "Create Role",
          createSaveButton = "Create",
          newRoleBreadcrumb = "New role",
          unnamedRole = "Unnamed role",
          gradeMeta = "Grade {grade}",
          backButton = "Go back",
          saveButton = "Save",
          general = "General",
          permissions = "Permissions",
          salary = "Salary",
          salaryDescription = "Set the salary for this role.",
          salaryInterval = "Payout interval",
          salaryIntervalDescription = "Choose how often this role receives salary (in minutes of work).",
          roleName = "Role Name",
          roleNameDescription = "Set the role name for this role.",
          highestRoleInfo = "This is the highest rank and automatically has access to every permission."
        },
        unsavedChanges = {
          title = "Unsaved changes",
          message = "You have unsaved changes for this role. Leave anyway and discard them?",
          confirm = "Leave without saving",
          cancel = "Keep editing"
        },
        permissionsEmpty = "No permissions found.",
        permissionEntries = {
          viewLogs = {
            label = "View logs",
            description = "Allows reading the job transaction and activity logs."
          },
          manageRoles = {
            label = "Manage roles",
            description = "Allows creating, editing, moving, and deleting grades."
          },
          manageMembers = {
            label = "Manage members",
            description = "Allows promoting, demoting, firing, or paying bonuses."
          },
          manageWarehouse = {
            label = "Access storage",
            description = "Allows interacting with the shared storage inventory."
          },
          manageMoney = {
            label = "Manage funds",
            description = "Allows depositing or withdrawing society money."
          },
          editOutfits = {
            label = "Edit outfits",
            description = "Allows updating saved wardrobe entries."
          },
          createOutfits = {
            label = "Create outfits",
            description = "Allows creating new wardrobe entries."
          },
          deleteOutfits = {
            label = "Delete outfits",
            description = "Allows removing saved wardrobe entries."
          },
          purchaseSupplies = {
            label = "Order supplies",
            description = "Allows ordering equipment from the wholesale supplier using faction funds."
          },
          purchaseVehicles = {
            label = "Purchase vehicles",
            description = "Allows buying new fleet vehicles using faction funds."
          },
          garageVehicles = {
            label = "Garage vehicle restrictions",
            description = "Select which fleet vehicles this role cannot access in the garage."
          },
          tabletApps = {
            label = "Tablet app restrictions",
            description = "Select which tablet apps this role cannot access."
          },
          all = {
            label = "Full access",
            description = "Grants every permission regardless of other toggles."
          }
        },
        permissionOptions = {
          storageHint = "Add items that cannot be removed with this role.",
          storageItemsTitle = "Restricted items",
          storageWeaponsTitle = "Restricted weapons",
          allowedWeaponsTitle = "Allowed weapons",
          weaponHint = "Add weapons this role can access.",
          vehicleHint = "Select vehicles this role cannot access.",
          appHint = "Select tablet apps this role cannot access.",
          itemPlaceholder = "Type to add an item",
          weaponPlaceholder = "Type to add a weapon",
          weaponSelectPlaceholder = "Select a weapon",
          vehiclePlaceholder = "Select a vehicle",
          appPlaceholder = "Select a tablet app",
          addButton = "Add",
          emptyVehicles = "No vehicles available.",
          emptyApps = "No tablet apps available.",
          errors = {
            empty = "Please enter a value.",
            duplicate = "Option already added.",
            itemMissing = "Item does not exist.",
            vehicleMissing = "Select a vehicle.",
            appMissing = "Select a tablet app.",
            weaponMissing = "Weapon does not exist.",
            weaponSelectMissing = "Select a weapon."
          }
        },
        errors = {
          save = "Failed to save role.",
          saveUnexpected = "Unexpected error while saving role.",
          permissionsLoad = "Failed to fetch permissions.",
          permissionsUnexpected = "Unexpected error while fetching permissions."
        }
      },
      logs = {
        sidebarTitle = "Logs",
        menuTitle = "Logs",
        errors = {
          load = "Failed to load logs."
        },
        columnNames = {
          timestamp = "Timestamp",
          name = "Name",
          action = "Action",
          content = "Content"
        },
        actions = {
          stored = "Item Stored",
          removed = "Item Removed",
          deposited = "Money Deposited",
          withdrawn = "Money Withdrawn",
          outfit_created = "Outfit Created",
          outfit_updated = "Outfit Updated",
          outfit_deleted = "Outfit Deleted",
          permissions_updated = "Permissions Updated",
          invite_sent = "Invite Sent",
          invite_accepted = "Invite Accepted",
          invite_declined = "Invite Declined",
          bonus_paid = "Bonus Paid",
          member_promoted = "Member Promoted",
          member_demoted = "Member Demoted",
          member_fired = "Member Fired",
          supplies_purchased = "Supplies Purchased",
          vehicle_purchased = "Vehicle Purchased",
          vehicle_sold = "Vehicle Sold",
          salary_paid = "Salary Paid"
        }
      },
      dialogs = {
        deleteOutfit = {
          title = "Delete Outfit",
          message = "Do you really want to delete \"{name}\"?",
          confirm = "Delete Outfit",
          cancel = "Cancel"
        }
      }
    },
    cloakroom = {
      title = "Cloakroom",
      civilianClothes = "Civilian Clothes",
      newOutfit = "New Outfit",
      edit = {
        save = "Save",
        rotateAlt = "Rotate",
        outfitNameTitle = "Outfit Name",
        saveOutfit = "Save Outfit"
      }
    },
    tablet = {
      apps = {
        management = "Boss Menu",
        patients = "Patients",
        citizens = "Citizens",
        offences = "Offences",
        cases = "Cases",
        social_work = "Social work",
        vehicles = "Vehicles",
        weapons = "Weapons",
        prison = "Prison",
        warrants = "Warrants",
        bolos = "BOLOs",
        conditions = "Conditions",
        reports = "Reports",
        camera = "Camera",
        gallery = "Gallery",
        map = "Map",
        chat = "Chat",
        calendar = "Calendar",
        calculator = "Calculator",
        settings = "Settings"
      }
    },
    common = {
      close = "Close",
      unknownError = "Unknown error.",
      unexpectedError = "Unexpected error occurred.",
      time = {
        now = "Now"
      },
      pagination = {
        prev = "Prev",
        next = "Next",
        page = "Page {current} of {total}"
      },
      gallery = {
        title = "Gallery",
        subtitle = "Select a photo or video.",
        loading = "Loading gallery...",
        empty = "No gallery items available.",
        photoAlt = "Gallery media"
      },
      back = "Return",
      confirm = {
        unsavedTitle = "Unsaved changes",
        unsavedMessage = "Discard changes or save them before leaving?",
        unsavedDiscard = "Discard changes",
        unsavedSave = "Save changes"
      }
    },
    reports = {
      unknown = "Unknown"
    },
    publicForms = {
      complaint = {
        fields = {
          fullName = "Full name",
          phone = "Phone number",
          incidentDate = "Incident date",
          incidentTime = "Incident time",
          location = "Incident location",
          officerName = "Staff name",
          badgeNumber = "Badge number",
          description = "Complaint details",
          witnesses = "Witnesses",
          desiredOutcome = "Requested resolution",
          email = "Email address",
          address = "Home address",
          signature = "Signature"
        },
        title = "Citizen complaint",
        subtitle = "Report staff conduct or department concerns.",
        placeholders = {
          fullName = "Enter your full legal name",
          phone = "###-###-####",
          email = "name@email.com",
          address = "Street address, city, state",
          incidentDate = "MM/DD/YYYY",
          incidentTime = "HH:MM",
          location = "Where did it happen?",
          officerName = "Staff name or unit",
          badgeNumber = "Badge number if known",
          description = "Describe what happened in detail...",
          witnesses = "List witnesses or other parties",
          desiredOutcome = "What outcome are you requesting?",
          signature = "Type your full name"
        }
      },
      application = {
        fields = {
          fullName = "Full name",
          dateOfBirth = "Date of birth",
          phone = "Phone number",
          experience = "Relevant experience",
          availability = "Availability",
          whyJoin = "Why do you want to join?",
          email = "Email address",
          address = "Home address",
          education = "Education",
          certifications = "Certifications",
          references = "References",
          signature = "Signature"
        },
        title = "Job application",
        subtitle = "Apply to join the department.",
        placeholders = {
          fullName = "Enter your full legal name",
          dateOfBirth = "MM/DD/YYYY",
          phone = "###-###-####",
          email = "name@email.com",
          address = "Street address, city, state",
          education = "High school, academy, or college",
          experience = "Law enforcement, security, or service roles",
          certifications = "First aid, firearms, or related training",
          availability = "Preferred shifts or start date",
          whyJoin = "Tell us why you want to work here...",
          references = "Names and contact info",
          signature = "Type your full name"
        }
      },
      title = "Public forms",
      subtitle = "Submit a complaint or a job application.",
      stationLabel = "Station",
      dateLabel = "Date",
      timeLabel = "Time",
      stamp = {
        label = "PD",
        complaint = "CMP",
        application = "APP"
      },
      tabs = {
        complaint = "Complaint form",
        application = "Job application",
        myForms = "My submissions"
      },
      myForms = {
        title = "My submissions",
        empty = "You have not submitted any forms yet.",
        back = "Back",
        notesTitle = "Responses",
        notesEmpty = "No responses yet.",
        statusNew = "Pending",
        statusReviewed = "Reviewed",
        statusArchived = "Archived"
      },
      actions = {
        submit = "Submit form",
        clear = "Clear fields",
        close = "Close"
      },
      status = {
        submitting = "Submitting...",
        success = "Form submitted successfully.",
        error = "Unable to submit the form."
      },
      errors = {
        required = "Please complete the required fields."
      }
    },
    tabletForms = {
      title = "Form Inbox",
      eyebrow = "Public Forms",
      listed = "listed",
      filters = {
        label = "Type",
        all = "All forms",
        complaint = "Complaints",
        application = "Applications"
      },
      search = {
        placeholder = "Search by name, station, or id"
      },
      status = {
        new = "New",
        reviewed = "Reviewed",
        archived = "Archived"
      },
      state = {
        empty = "No forms match the current filters.",
        loading = "Loading forms...",
        saving = "Saving..."
      },
      errors = {
        load = "Unable to load forms.",
        update = "Unable to update form status."
      },
      detail = {
        complaintTitle = "Complaint details",
        applicationTitle = "Application details"
      },
      actions = {
        refresh = "Refresh",
        markReviewed = "Mark reviewed",
        archive = "Archive",
        back = "Back to list"
      },
      notifications = {
        timeNow = "Now",
        complaintType = "Complaint",
        applicationType = "Application",
        app = "Forms",
        title = "New public form",
        body = "{type} from {name} ({station})"
      },
      fields = {
        type = "Form type",
        id = "Form ID",
        station = "Station",
        submitted = "Submitted",
        status = "Status",
        contact = "Contact"
      },
      notes = {
        title = "Notes",
        loading = "Loading notes...",
        empty = "No notes yet.",
        placeholder = "Write a note...",
        visibleBadge = "Citizen visible",
        visibleToCitizen = "Visible to citizen",
        submit = "Add note"
      }
    },
    gallery = {
      eyebrow = "Evidence Gallery",
      title = "Camera Roll",
      filters = {
        all = "All",
        camera = "Camera",
        speedcam = "Speed Cams",
        cctv = "CCTV",
        mugshot = "Mugshots"
      },
      labels = {
        count = "{count} photos",
        sort = "Newest first",
        photoAlt = "Gallery photo",
        photoFullAlt = "Full size photo",
        takenBy = "Taken by",
        captured = "Captured",
        unknownTime = "Unknown time",
        unknownTakenBy = "Unknown"
      },
      state = {
        loading = "Loading captures...",
        emptyTitle = "No photos yet.",
        emptySubtitle = "Your latest camera shots will appear here."
      },
      errors = {
        load = "Unable to load gallery.",
        delete = "Unable to delete photo."
      },
      confirm = {
        deleteTitle = "Delete Photo",
        deleteMessage = "Delete this photo? This cannot be undone.",
        deleteConfirm = "Delete",
        deleteCancel = "Cancel"
      },
      mock = {
        caption = "DEV CAPTURE"
      }
    },
    camera = {
      help = {
        focused = "Press Space to enable movement.",
        blurred = "Press Space to use the tablet again."
      },
      mode = {
        photo = "Photo",
        video = "Video",
        switchPhoto = "Switch to photo mode",
        switchVideo = "Switch to video mode"
      },
      capture = {
        photo = "Take photo"
      },
      queue = {
        title = "Queue",
        empty = "No uploads yet.",
        kind = {
          photo = "Photo upload",
          video = "Video upload"
        },
        status = {
          loading = "Uploading...",
          success = "Saved",
          error = "Failed"
        }
      },
      preview = {
        lastShot = "Last shot",
        lastCapture = "Last capture"
      },
      record = {
        start = "Start recording",
        stop = "Stop recording",
        live = "REC",
        saving = "Saving video...",
        name = "Camera Clip",
        description = "Tablet recording",
        errors = {
          config = "Upload config missing.",
          upload = "Upload failed.",
          save = "Unable to save video.",
          unsupported = "Recording unsupported.",
          empty = "No video captured yet.",
          busy = "Recording is busy.",
          notRecording = "Recording already stopped."
        }
      },
      errors = {
        timeout = "Upload timed out.",
        capture = "Unexpected error while taking photo.",
        upload = "Upload failed."
      }
    },
    cctv = {
      eyebrow = "Surveillance Network",
      title = "CCTV",
      listed = "listed",
      actions = {
        refresh = "Refresh"
      },
      search = {
        placeholder = "Search cameras by name, id, or location"
      },
      filters = {
        all = "All cams",
        bodycam = "Bodycams",
        dashcam = "Dashcams",
        cctv = "CCTV Cams",
        speedcam = "Speed Cams"
      },
      types = {
        bodycam = "Bodycam",
        dashcam = "Dashcam",
        speedcam = "Speed Cam",
        cctv = "CCTV Cam"
      },
      status = {
        online = "Online",
        maintenance = "Maintenance",
        offline = "Offline"
      },
      live = {
        active = "Live feed active",
        maintenance = "Feed paused for maintenance",
        offline = "Signal lost",
        placeholderTitle = "Feed unavailable",
        placeholderSubtitle = "Select a bodycam-enabled staff member.",
        speedcamPlaceholderTitle = "Speed cam offline",
        speedcamPlaceholderSubtitle = "Repair or replace the unit to restore the feed."
      },
      labels = {
        speedcamLocation = "Roadside",
        onDuty = "On duty",
        durability = "Durability"
      },
      state = {
        loading = "Loading cameras...",
        empty = "No cameras match the current filters.",
        select = "Select a camera to view its feed."
      },
      controls = {
        tiltUp = "Tilt up",
        panLeft = "Pan left",
        panRight = "Pan right",
        tiltDown = "Tilt down"
      },
      capture = {
        name = "CCTV - {label}",
        description = "{location} ({id})",
        saved = "Saved to gallery.",
        error = "Unable to capture image.",
        action = "Capture",
        loading = "Capturing..."
      },
      record = {
        name = "CCTV Clip - {label}",
        description = "{location} ({id})",
        save = "Save last {minutes} min",
        saving = "Saving...",
        requested = "Save request sent.",
        saved = "Video saved to gallery.",
        errors = {
          config = "Upload config missing.",
          upload = "Upload failed.",
          save = "Unable to save video.",
          unsupported = "Recording unsupported.",
          empty = "No buffer available yet.",
          request = "Unable to request bodycam video.",
          timeout = "Bodycam save timed out.",
          busy = "Recording is busy.",
          notRecording = "Recording already stopped."
        }
      },
      waypoint = {
        set = "Waypoint set.",
        missing = "No location available."
      },
      errors = {
        load = "Unable to load cameras."
      }
    },
    chat = {
      targets = {
        allUnits = "All Units Chat",
        centralDispatch = "Central Dispatch"
      },
      header = {
        eyebrowRoom = "Staff Channel",
        eyebrowPrivate = "Private Line",
        metaRoom = "Room",
        metaDirect = "Direct",
        metaStaff = "Staff"
      },
      sidebar = {
        eyebrow = "Comms",
        title = "Staff Network",
        groupTitle = "Group Chat",
        allUnits = "All Units",
        staffTitle = "Staff",
        loading = "Loading staff...",
        empty = "No staff available."
      },
      staff = {
        unknownMember = "Unknown staff member",
        onDuty = "On duty",
        offDuty = "Off duty",
        grade = "Grade {level}",
        fallback = "Staff"
      },
      composer = {
        placeholderRoom = "Write a unit update...",
        placeholderDirect = "Message {name}...",
        pendingAlt = "Pending share"
      },
      messages = {
        avatarAlt = "Avatar of {name}",
        avatarFallback = "Staff avatar",
        unknownAuthor = "Unknown",
        sharedEvidenceAlt = "Shared evidence",
        tapToExpand = "Tap to expand"
      },
      preview = {
        ready = "Media ready to send"
      },
      profile = {
        action = "Set profile photo",
        galleryTitle = "Set profile photo",
        gallerySubtitle = "Choose a photo for your team avatar.",
        photoAlt = "Profile photo",
        selfPhotoAlt = "Profile photo",
        error = "Unable to update profile photo."
      },
      actions = {
        remove = "Remove",
        send = "Send"
      },
      state = {
        syncing = "Syncing messages...",
        emptyRoom = "No chatter yet.",
        emptyPrivate = "No private messages yet.",
        emptyRoomHint = "Be the first to check in with the unit.",
        emptyPrivateHint = "Start a direct line with this staff member."
      },
      errors = {
        load = "Unable to load chat history.",
        send = "Unable to send message.",
        members = "Unable to load staff."
      }
    },
    bossMenu = {
      header = {
        eyebrow = "Boss Menu",
        title = "Management",
        balanceLabel = "Balance"
      },
      state = {
        loading = "Loading management data..."
      }
    },
    tabletSettings = {
      header = {
        eyebrow = "Tablet Settings",
        title = "Personalization",
        modeLabel = "Mode",
        modeLight = "Light",
        modeDark = "Dark"
      },
      appearance = {
        title = "Appearance",
        description = "Switch the interface between light and dark.",
        light = "Light",
        dark = "Dark"
      },
      wallpaper = {
        title = "Wallpaper",
        description = "Use the default background, pick from gallery, or add your own link.",
        labels = {
          default = "Default background",
          gallery = "Gallery photo",
          url = "Custom URL"
        },
        useDefault = "Use default",
        chooseGallery = "Choose from gallery",
        customUrlLabel = "Custom image URL",
        customUrlPlaceholder = "https://example.com/wallpaper.jpg",
        apply = "Apply",
        hint = "Best results with 1920x1080 or higher images."
      }
    },
    calendar = {
      weekdays = {
        mon = "Mon",
        tue = "Tue",
        wed = "Wed",
        thu = "Thu",
        fri = "Fri",
        sat = "Sat",
        sun = "Sun"
      },
      selectedDateFallback = "Select a date",
      header = {
        eyebrow = "Shared calendar",
        title = "Staff Schedule",
        metaPrimary = "Visible to all staff",
        metaSecondary = "Everyone can add entries",
        hint = "Tap a day to add a shift or event"
      },
      actions = {
        dayEntries = "Day entries",
        addEntry = "Add entry"
      },
      today = "Today",
      more = "+{count} more",
      modal = {
        addEntry = {
          eyebrow = "Add entry",
          titleLabel = "Title",
          titlePlaceholder = "Shift briefing, training, patrol",
          datetimeLabel = "Date & time",
          colorLabel = "Color",
          clear = "Clear",
          submit = "Add to calendar"
        },
        dayEntries = {
          eyebrow = "Day entries",
          empty = "No entries yet. Add a briefing or patrol to share with the unit."
        }
      }
    },
    calculator = {
      header = {
        eyebrow = "Field Tools",
        title = "Calculator",
        modeLabel = "Mode"
      },
      keys = {
        clearAll = "AC",
        clearEntry = "CE"
      },
      mode = {
        standard = "Standard"
      },
      status = {
        resetRequired = "Reset required",
        ready = "Ready"
      },
      errors = {
        error = "Error"
      }
    },
    tabletHome = {
      status = {
        defaultDate = "Monday, Jan 01"
      },
      calendar = {
        eventToday = "Event Today",
        eventTomorrow = "Event Tomorrow",
        allDay = "All day",
        timeAt = " at {time}"
      },
      chat = {
        messageFrom = "Message from {name}",
        newMessage = "New message",
        authorFallback = "Staff",
        messageBody = "{author}: {message}",
        sentPhoto = "{author} sent a photo.",
        sentMessage = "{author} sent a message."
      },
      notifications = {
        title = "Notifications",
        clearAll = "Clear all",
        empty = "All caught up."
      }
    },
    map = {
      eyebrow = "Map Desk",
      title = "San Andreas Grid",
      markerLabel = "Marker",
      signalLost = "Signal lost",
      markerTypes = {
        label = "Marker list",
        dispatch = "Dispatch",
        officers = "Staff",
        speedcams = "Speed cams",
        vehicles = "Vehicles",
        trackers = "Trackers"
      },
      markerList = {
        listed = "listed",
        officersTitle = "Staff Roster",
        speedcamsTitle = "Speed Cam Board",
        vehiclesTitle = "Vehicle Board",
        trackersTitle = "Tracker Board",
        officersEmpty = "No staff on duty.",
        speedcamsEmpty = "No speed cams available.",
        trackersEmpty = "No trackers online.",
        vehiclesEmpty = "No vehicles online."
      },
      dispatch = {
        title = "Dispatch Board",
        empty = "No dispatches right now.",
        status = {
          active = "Active",
          accepted = "Accepted",
          done = "Done"
        },
        panelTitle = "Dispatch Details",
        statusLabel = "Status",
        acceptedBy = "Accepted by",
        doneBy = "Completed by",
        coords = "Coordinates",
        actions = {
          accept = "Accept",
          done = "Mark done",
          delete = "Delete"
        },
        unknown = "Unknown"
      },
      status = {
        available = "Available",
        busy = "Busy",
        pursuit = "In pursuit",
        offDuty = "Off duty"
      },
      vehicle = {
        status = {
          active = "Active",
          offline = "Offline"
        }
      },
      tracker = {
        status = {
          active = "Active",
          offline = "Offline"
        }
      },
      speedcam = {
        status = {
          online = "Online",
          maintenance = "Maintenance",
          offline = "Offline"
        }
      },
      officerPanel = {
        title = "Staff Details",
        callsign = "Callsign {id}",
        rank = "Rank",
        health = "Health",
        coords = "Coordinates",
        lastUpdateUnknown = "Just now"
      },
      speedcamPanel = {
        title = "Speed Cam Details",
        limit = "Limit",
        tolerance = "Tolerance",
        health = "Health",
        coords = "Coordinates"
      },
      vehiclePanel = {
        title = "Vehicle Details",
        plate = "Plate {plate}",
        netId = "Net ID",
        health = "Health",
        coords = "Coordinates"
      },
      trackerPanel = {
        title = "Tracker Details",
        plate = "Plate {plate}",
        attachedBy = "Attached by",
        attachedAt = "Attached",
        netId = "Net ID",
        status = "Status",
        coords = "Coordinates"
      },
      actions = {
        openCctv = "Open CCTV",
        setWaypoint = "Set waypoint"
      },
      waypoint = {
        set = "Waypoint set.",
        missing = "No location available."
      },
      styles = {
        atlas = "Atlas",
        roads = "Roads",
        satellite = "Satellite"
      },
      missing = {
        title = "Map image missing",
        body = "Place the map images in frontend/public/img."
      },
      details = {
        title = "Details",
        empty = "Select a marker to see details."
      },
      zones = {
        title = "Exclusion Zones",
        untitled = "Untitled zone",
        hint = "Click the map to add points. Minimum 3.",
        pointCount = "{count} points",
        empty = "No exclusion zones yet.",
        actions = {
          toggle = "Zones",
          new = "New zone",
          cancel = "Cancel",
          save = "Save zone",
          undo = "Undo",
          clear = "Clear",
          delete = "Delete"
        },
        modal = {
          title = "Name exclusion zone",
          confirm = "Save zone"
        },
        errors = {
          points = "Add at least 3 points.",
          nameRequired = "Enter a zone name.",
          saveFailed = "Unable to save the exclusion zone.",
          deleteFailed = "Unable to delete the exclusion zone."
        }
      },
      monitorZones = {
        title = "Ankle Monitor Zones",
        untitled = "Untitled zone",
        hint = "Click the map to add points. Minimum 3.",
        pointCount = "{count} points",
        empty = "No monitor zones yet.",
        mode = {
          allow = "Allowed zone",
          exclude = "Restricted zone"
        },
        actions = {
          allow = "Allowed zone",
          exclude = "Restricted zone",
          cancel = "Cancel",
          save = "Save zone",
          undo = "Undo",
          clear = "Clear",
          delete = "Delete"
        },
        modal = {
          title = "Name monitor zone",
          confirm = "Save zone"
        },
        errors = {
          points = "Add at least 3 points.",
          nameRequired = "Enter a zone name.",
          noMonitor = "Select an ankle monitor.",
          saveFailed = "Unable to save the monitor zone.",
          deleteFailed = "Unable to delete the monitor zone."
        }
      },
      panic = {
        panelTitle = "Panic Details",
        triggeredBy = "Triggered by",
        createdAt = "Triggered",
        coords = "Coordinates"
      },
      dev = {
        officerName = "Staff Avery Lane",
        callsign = "LIN-23",
        rank = "Sergeant",
        unit = "Central Patrol",
        speedcamName = "Del Perro Speed Cam",
        vehicleName = "Unit 12",
        trackerName = "Tracker ALPHA",
        trackerOfficer = "Staff Ruiz",
        dispatchTitle = "Speed camera damaged",
        dispatchMessage = "Del Perro unit needs maintenance.",
        panicOfficer = "Staff Sinclair",
        panicLocation = "Mission Row"
      }
    },
    employeeGpsJammer = {
      title = "GPS Jammer",
      disabled = "GPS jamming is unavailable.",
      success = "Employee GPS signal disrupted.",
      failed = "Unable to disrupt the GPS signal.",
      targetJammed = "Your duty GPS signal is being disrupted.",
      errors = {
        disabled = "GPS jamming is unavailable.",
        no_players = "No person nearby.",
        too_far = "Move closer before using the GPS jammer.",
        invalid_target = "Unable to locate that person.",
        not_on_duty = "No active duty GPS signal found on this person.",
        protected_job = "This employee GPS signal is protected.",
        missing_item = "You need a GPS jammer to do this.",
        cooldown = "Wait a moment before using the GPS jammer again.",
        failed = "Unable to disrupt the GPS signal."
      }
    },
    panicNotification = {
      badge = "Panic",
      title = "Panic alert",
      subtitle = "{name} pressed the panic button.",
      callsign = "Callsign {id}",
      locationLabel = "Location",
      locationUnknown = "Unknown location",
      hint = "Press {key} to set a waypoint on the in-game map."
    },
    incidentNotification = {
      panic = {
        title = "Panic alert",
        subtitle = "{name} pressed the panic button."
      },
      dispatch = {
        title = "Dispatch alert",
        subtitle = "{name} shared a new dispatch."
      },
      ping = {
        title = "Location ping",
        subtitle = "{name} shared a live location ping."
      },
      actions = {
        openMap = {
          key = "M",
          label = "See in Tablet Map App"
        },
        setWaypoint = {
          key = "G",
          label = "Set Waypoint"
        },
        dismiss = {
          key = "Backspace",
          label = "Dismiss"
        }
      }
    },
    gradeChange = {
      promotedTitle = "Promotion",
      demotedTitle = "Demotion",
      unchangedTitle = "Rank updated",
      previousLabel = "Previous rank",
      newLabel = "Current rank",
      unknownLabel = "Unassigned rank",
      levelFallback = "Grade {level}"
    },
    bonusNotification = {
      title = "Bonus awarded",
      subtitle = "From {name}",
      amountLabel = "Bonus",
      unknownManager = "Management"
    },
    wheelClamp = {
      attached = "A wheelclamp is attached"
    },
    search = {
      previewTitle = "Searching {name}",
      previewSubtitle = "Scanning belongings for weapons and contraband...",
      previewCancel = "Press X to cancel",
      unknownTarget = "Unknown"
    },
    heliCamHud = {
      title = "Heli Cam Controls",
      actions = {
        toggleCam = "Toggle cam",
        vision = "Toggle vision",
        spotlight = "Spotlight mode",
        lockTarget = "Lock target",
        display = "Toggle display",
        takePhoto = "Capture photo",
        rappel = "Rappel",
        brightness = "Brightness",
        radius = "Radius"
      }
    },
    jailHud = {
      title = "Time remaining",
      trashLabel = "Trash",
      trashFull = "Bag full",
      trashDropoff = "Deliver to dumpster"
    },
    jailJobs = {
      title = "Jail work assignments",
      subtitle = "Choose a task to pass the time.",
      actions = {
        cleaning = "Cleaning",
        gardening = "Gardening",
        carry_goods = "Carry goods"
      },
      currentJob = "Current job:",
      stop = "Stop job",
      close = "Close",
      contraband = {
        title = "Contraband",
        message = "You found {item}. Do you take the risk and keep it, or toss it?",
        keep = "Keep",
        toss = "Toss"
      },
      boxInspect = {
        title = "Inspect box",
        message = "Inside you find {item}. {description}",
        take = "Take it",
        leave = "Leave it inside",
        close = "Close"
      }
    },
    socialWork = {
      eyebrow = "Community Service",
      title = "Social Work",
      listed = "listed",
      search = {
        placeholder = "Search by name or id"
      },
      filters = {
        all = "All",
        label = "Status",
        placeholder = "Status"
      },
      actions = {
        refresh = "Refresh",
        back = "Back to list"
      },
      state = {
        loading = "Loading community service...",
        empty = "No community service matches the current filters."
      },
      status = {
        active = "Active",
        overdue = "Overdue",
        completed = "Completed",
        imprisoned = "Imprisoned"
      },
      labels = {
        remainingShort = "left",
        imprison = "Imprison",
        imprisonNotice = "Deadline passed. Imprisonment required.",
        noDeadline = "No deadline",
        expired = "Expired"
      },
      sections = {
        summary = "Service summary",
        summarySubtitle = "Overview of the assigned tasks."
      },
      fields = {
        name = "Name",
        status = "Status",
        remaining = "Remaining tasks",
        completed = "Completed tasks",
        total = "Total tasks",
        assigned = "Assigned",
        deadline = "Deadline",
        timeLeft = "Time left",
        assignedBy = "Assigned by",
        unknown = "Unknown"
      },
      assign = {
        title = "Assign community service",
        subtitle = "Send a nearby player to social work tasks.",
        playerLabel = "Player",
        playerPlaceholder = "Choose player",
        taskLabel = "Tasks",
        taskPlaceholder = "Task count",
        deadlineLabel = "Time limit (minutes)",
        deadlinePlaceholder = "Optional",
        submit = "Assign",
        success = "Community service assigned.",
        error = "Unable to assign community service."
      },
      errors = {
        load = "Unable to load community service."
      },
      date = {
        unknown = "Unknown"
      },
      jobs = {
        title = "Community service",
        subtitle = "Choose a task to complete your sentence.",
        currentJob = "Current task:",
        stop = "Stop task",
        actions = {
          cleaning = "Cleaning",
          carry_goods = "Carry goods"
        }
      },
      hud = {
        title = "Community service",
        remaining = "Tasks remaining",
        completed = "Tasks completed",
        deadline = "Time left",
        expired = "Expired",
        trashLabel = "Trash",
        trashFull = "Bag full",
        trashDropoff = "Deliver to dumpster"
      }
    },
    socialWorkCreator = {
      title = "Social Work Creator",
      description = "Configure community service sites around the city.",
      empty = "No social work sites configured yet.",
      keyboardHint = "Use arrow keys to navigate the list and actions.",
      editTitle = "Social work markers",
      editSubtitle = "Use the map pin button to store your current coordinates.",
      editKeyboardHint = "Use arrow keys to pick a marker, left/right to choose Set/Clear, Enter to run it, Backspace goes back.",
      missingEntry = "Social work site not found.",
      actions = {
        newSite = "New Site"
      },
      status = {
        set = "Set",
        unset = "Unset"
      },
      markers = {
        social_work_job_npc = "Job NPC",
        social_work_dumpster = "Dumpster",
        social_work_box_dropoff = "Carry drop-off"
      },
      modals = {
        createTitle = "Create site",
        createButton = "Create site",
        renameTitle = "Rename site",
        renameButton = "Save name",
        deleteTitle = "Delete site",
        deleteMessage = "Do you really want to remove {name}?",
        deleteConfirmLabel = "Delete",
        deleteCancelLabel = "Cancel"
      }
    },
    impoundCreator = {
      title = "Impound Creator",
      description = "Configure impound lot locations and spawn points.",
      empty = "No impound lots configured yet.",
      keyboardHint = "Use arrow keys to navigate the list and actions.",
      editTitle = "Impound markers",
      editSubtitle = "Use the map pin button to store your current coordinates.",
      editKeyboardHint = "Use arrow keys to pick a marker, left/right to choose Set/Clear/Delete, Enter to run it, Backspace goes back. Move past the list to reach Add buttons.",
      missingEntry = "Impound lot not found.",
      actions = {
        newLot = "New lot",
        add = {
          impound_delivery = "Add drop-off",
          impound_spawn = "Add spawn"
        }
      },
      status = {
        set = "Set",
        unset = "Unset"
      },
      markers = {
        impound_lot = "Impound lot",
        impound_spawn = "Impound spawn",
        impound_delivery = "Impound drop-off"
      },
      modals = {
        createTitle = "Create lot",
        createButton = "Create lot",
        renameTitle = "Rename lot",
        renameButton = "Save name",
        deleteTitle = "Delete lot",
        deleteMessage = "Do you really want to remove {name}?",
        deleteConfirmLabel = "Delete",
        deleteCancelLabel = "Cancel"
      }
    },
    impoundStorage = {
      title = "Impound Storage",
      subtitle = "Order stored vehicles to be delivered to the lot.",
      empty = "No stored vehicles for this lot.",
      emptyAll = "No impounded vehicles found.",
      unknownModel = "Unknown",
      unknownLot = "Unknown",
      sections = {
        impounds = "Active impounds",
        stored = "Stored vehicles"
      },
      columns = {
        plate = "Plate",
        model = "Model",
        stored = "Stored",
        lot = "Lot",
        status = "Status",
        fee = "Storage fee"
      },
      actions = {
        deliver = "Order delivery",
        allowPickup = "Allow pickup",
        seize = "Mark seized",
        seized = "Seized",
        close = "Close",
        refresh = "Refresh"
      },
      status = {
        pickup = "Pickup allowed",
        seized = "Seized"
      },
      time = {
        days = "{count} day(s)"
      },
      errors = {
        load = "Unable to load stored vehicles.",
        deliver = "Unable to order delivery.",
        seized = "This vehicle is seized for investigation.",
        update = "Unable to update impound status."
      }
    },
    impoundDecision = {
      title = "Impound decision",
      message = "Decide if {vehicle} can be picked up or seized for investigation.",
      vehicleFallback = "this vehicle",
      allowPickup = "Allow pickup",
      seize = "Seize for investigation"
    },
    jailCreator = {
      title = "Jail Creator",
      description = "Place jail spawn points and manage locations.",
      empty = "No jails configured yet.",
      keyboardHint = "Use arrow keys to navigate the list and actions.",
      editTitle = "Jail markers",
      editSubtitle = "Use the map pin button to store your current coordinates.",
      editKeyboardHint = "Use arrow keys to pick a marker, left/right to choose Set/Clear/Delete, Enter to run it, Backspace goes back. Move past the list to reach Add buttons.",
      missingEntry = "Jail not found.",
      actions = {
        newJail = "New jail"
      },
      modals = {
        createTitle = "Create jail",
        createButton = "Create jail",
        renameTitle = "Rename jail",
        renameButton = "Save name",
        deleteTitle = "Delete jail",
        deleteMessage = "Do you really want to remove {name}?",
        deleteConfirmLabel = "Delete",
        deleteCancelLabel = "Cancel"
      }
    },
    jailInmates = {
      title = "Inmate trade",
      close = "Close",
      trade = "Make trade",
      requiredLabel = "You give",
      rewardLabel = "You get",
      acceptedLabel = "Accepts",
      contrabandLabel = "Contraband",
      npc = {
        alcoholic = "Cellblock boozer",
        drugDealer = "Laundry room dealer",
        doctor = "Prison doctor",
        canteen = "Canteen cook"
      },
      dialogs = {
        alcoholic = {
          one = "I traded my dessert for a mop once. Best day of my life.",
          two = "If this place had a bar, I would be employee of the month.",
          three = "Got anything that smells like clean floors and bad decisions?",
          four = "I call it prison cologne. You call it cleaning alcohol."
        },
        drugDealer = {
          one = "Got anything spicy from the trash? I pay in smokes.",
          two = "Keep your voice down, the guards think I am a book club.",
          three = "Bring me contraband and I will make your day smokeable.",
          four = "The trash hides treasures. I am the treasure appraiser."
        },
        doctor = {
          one = "Hold still. This will be quick.",
          two = "No charge today. Just stay out of trouble.",
          three = "You look rough. Let me patch you up.",
          four = "Clinic hours never end in here."
        },
        canteen = {
          one = "Fresh tray today. Line up and keep it moving.",
          two = "You want a hot meal or a lecture?",
          three = "Good behavior gets seconds. Mostly.",
          four = "I have seen worse appetites."
        }
      },
      doctor = {
        costLabel = "Cost",
        rewardLabel = "Treatment",
        actionLabel = "Get treatment",
        costValue = "Free",
        rewardValue = "Full treatment"
      },
      canteen = {
        costLabel = "Cost",
        rewardLabel = "Meal",
        actionLabel = "Claim meal",
        costValue = "Free",
        rewardValue = "Food package"
      },
      items = {
        cleaning_alcohol = "Cleaning alcohol",
        cigarettes = "Cigarettes",
        coke = "Coke",
        weed = "Weed",
        burger = "Burger",
        water = "Water"
      }
    },
    invites = {
      title = "Job Invitation",
      description = "Join {job} as {role}?",
      invitedBy = "Invited by {name}",
      expires = "This offer expires soon.",
      accept = "Accept",
      decline = "Decline",
      errors = {
        missing = "Invitation unavailable.",
        failed = "Failed to answer the invitation."
      }
    },
    stationCreator = {
      title = "Station Creator",
      description = "Configure station marker positions.",
      empty = "No stations configured yet.",
      keyboardHint = "Use ↑/↓ to select, ←/→ to switch actions, Enter to confirm, Backspace closes.",
      editTitle = "Station markers",
      editSubtitle = "Use the map pin button to store your current coordinates.",
      editKeyboardHint = "Use ↑/↓ to pick a marker, ←/→ to choose Set/Clear/Delete, Enter to run it, Backspace goes back.",
      sections = {
        markers = "Markers",
        zone = "Jail zone"
      },
      zone = {
        subtitle = "Add zone points to define the jail boundary.",
        hint = "Use the map pin button to add points. Remove points with the trash icon.",
        empty = "No zone points yet.",
        pointLabel = "Zone point {index}",
        actions = {
          add = "Add zone point",
          update = "Update",
          clear = "Clear zone"
        }
      },
      missingStation = "Station not found.",
      actions = {
        newStation = "New Station",
        editJobBlip = "Edit job blip",
        newJail = "New jail",
        add = {
          wardrobe = "Add wardrobe marker",
          garage_vehicle_menu = "Add vehicle garage interaction",
          garage_vehicle_spawn = "Add vehicle garage spawn",
          garage_vehicle_park = "Add vehicle garage parking",
          garage_helicopter_menu = "Add helipad interaction",
          garage_helicopter_spawn = "Add helipad spawn",
          garage_helicopter_park = "Add helipad parking",
          garage_boat_menu = "Add dock interaction",
          garage_boat_spawn = "Add dock spawn",
          garage_boat_park = "Add dock parking",
          boss_menu = "Add boss menu marker",
          wholesale_shop = "Add wholesale shop marker",
          duty_terminal = "Add duty terminal marker",
          public_forms = "Add public forms kiosk",
          jail_solitary_cell = "Add solitary cell"
        }
      },
      status = {
        set = "Set",
        unset = "Unset"
      },
      markers = {
        position = "Station position",
        storage = "Storage",
        locker = "Locker",
        wardrobe = "Wardrobe",
        duty_terminal = "Duty terminal",
        public_forms = "Public forms kiosk",
        boss_menu = "Boss menu",
        garage_vehicle_menu = "Vehicle garage interaction",
        garage_vehicle_spawn = "Vehicle garage spawn",
        garage_vehicle_park = "Vehicle garage parking",
        garage_helicopter_menu = "Helipad interaction",
        garage_helicopter_spawn = "Helipad spawn",
        garage_helicopter_park = "Helipad parking",
        garage_boat_menu = "Dock interaction",
        garage_boat_spawn = "Dock spawn",
        garage_boat_park = "Dock parking",
        wholesale_shop = "Wholesale shop",
        jail_spawn = "Jail spawn",
        jail_release = "Jail release",
        jail_menu = "Jail terminal",
        jail_job_npc = "Jail job NPC",
        jail_inmate_alcoholic = "Inmate: Alcoholic",
        jail_inmate_drugdealer = "Inmate: Drug dealer",
        jail_inmate_doctor = "Inmate: Doctor",
        jail_canteen_cook = "Canteen cook",
        jail_dumpster = "Jail dumpster",
        jail_box_dropoff = "Carry drop-off",
        jail_electric_box = "Electrical box",
        jail_fence_cut = "Fence cut point",
        jail_fence_exit = "Fence exit",
        jail_solitary_cell = "Solitary cell",
        jail_confiscated_return = "Confiscated items",
      },
      modals = {
        createTitle = "Create station",
        createButton = "Create station",
        renameTitle = "Rename station",
        renameButton = "Save name",
        deleteTitle = "Delete station",
        deleteMessage = "Do you really want to remove {name}?",
        deleteConfirmLabel = "Delete",
        deleteCancelLabel = "Cancel",
        jobBlipTitle = "Job blip: {job}",
        jobBlipMessage = "Configure the station blip for this specific job. Disable it if this job should not have a station blip.",
        jobBlipSave = "Save blip",
        jobBlipReset = "Reset",
        jobBlipInvalidNumber = "Invalid value for {field}."
      },
      blip = {
        enabled = "Show blip",
        useStationName = "Append station name",
        shortRange = "Short range",
        name = "Label",
        sprite = "Sprite",
        color = "Color",
        scale = "Scale",
        display = "Display"
      }
    },
    jailAssign = {
      title = "Send to jail",
      selectPlayer = "Select player",
      selectPlayerPlaceholder = "Choose player",
      selectJail = "Select jail",
      selectJailPlaceholder = "Choose jail location",
      solitaryLabel = "Solitary confinement",
      solitaryUnavailable = "No solitary cells configured for this jail.",
      durationLabel = "Duration (months)",
      monthHint = "1 month = {minutes} minutes",
      cancelButton = "Cancel",
      assignButton = "Send to jail",
      assigning = "Sending to jail...",
      noPlayers = "No nearby players within {range} m.",
      noJails = "No jails configured yet. Use the jail creator first.",
      spawnMissing = "This jail has no spawn set.",
      jailStatusReady = "Spawn ready",
      jailStatusMissing = "No spawn set",
      success = "Player sent to jail for {months} months.",
      errors = {
        invalid_target = "Select a nearby player and a jail.",
        spawn_not_set = "This jail has no spawn set.",
        solitary_unavailable = "No solitary cells configured for this jail.",
        failed = "Failed to send player to jail."
      }
    },
    bolos = {
      eyebrow = "BOLO Board",
      title = "BOLOs",
      listed = "listed",
      unknown = "Unknown",
      search = {
        placeholder = "Search BOLOs by title, id, type, or tag"
      },
      actions = {
        refresh = "Refresh",
        manageTypes = "Manage types",
        new = "New BOLO",
        back = "Back to list",
        add = "Add",
        addPhoto = "Add photo",
        remove = "Remove"
      },
      state = {
        loading = "Loading BOLOs...",
        empty = "No BOLOs match the current filters.",
        saving = "Saving...",
        noTags = "No tags assigned.",
        noReports = "No linked reports yet."
      },
      detail = {
        summary = "BOLO Summary",
        untitled = "Untitled BOLO"
      },
      fields = {
        title = "BOLO title",
        id = "BOLO ID",
        type = "Type",
        status = "Status",
        priority = "Priority",
        created = "Created",
        updated = "Last update"
      },
      placeholders = {
        title = "BOLO title",
        id = "Auto-generated if blank",
        type = "Select type",
        description = "Add a description...",
        tag = "Add tag",
        reportSelect = "Select a report"
      },
      sections = {
        description = "Description",
        descriptionSubtitle = "Capture details and instructions.",
        tags = "Tags",
        tagsSubtitle = "Attach quick identifiers for the BOLO.",
        reports = "Linked reports",
        reportsSubtitle = "Attach related report files.",
        gallery = "Gallery",
        gallerySubtitle = "Attach gallery images to the BOLO."
      },
      gallery = {
        title = "Select a photo",
        subtitle = "Choose a gallery image to attach to the BOLO.",
        loading = "Loading gallery...",
        empty = "No gallery photos available.",
        photoAlt = "Gallery photo"
      },
      typesModal = {
        title = "BOLO types",
        subtitle = "Add or remove BOLO types for this device.",
        placeholder = "Add BOLO type",
        empty = "No BOLO types configured."
      },
      types = {
        person = "Person",
        vehicle = "Vehicle",
        property = "Property",
        missing = "Missing",
        other = "Other"
      },
      status = {
        active = "Active",
        located = "Located",
        closed = "Closed",
        cancelled = "Cancelled"
      },
      priority = {
        low = "Low",
        medium = "Medium",
        high = "High",
        critical = "Critical"
      },
      errors = {
        load = "Unable to load BOLOs.",
        save = "Unable to save BOLO.",
        titleRequired = "Enter a BOLO title before saving.",
        typeRequired = "Select a BOLO type before saving.",
        gallery = "Unable to load gallery."
      }
    },
    warrants = {
      eyebrow = "Warrant Vault",
      title = "Warrants",
      listed = "listed",
      unknown = "Unknown",
      search = {
        placeholder = "Search warrants by title, id, type, or tag"
      },
      actions = {
        refresh = "Refresh",
        manageTypes = "Manage types",
        new = "New warrant",
        back = "Back to list",
        add = "Add",
        addPhoto = "Add photo",
        remove = "Remove"
      },
      state = {
        loading = "Loading warrants...",
        empty = "No warrants match the current filters.",
        saving = "Saving...",
        noTags = "No tags assigned.",
        noReports = "No linked reports yet.",
        noOffences = "No offences linked yet."
      },
      detail = {
        summary = "Warrant Summary",
        untitled = "Untitled warrant"
      },
      fields = {
        title = "Warrant title",
        id = "Warrant ID",
        type = "Type",
        status = "Status",
        priority = "Priority",
        created = "Created",
        updated = "Last update"
      },
      placeholders = {
        title = "Warrant title",
        id = "Auto-generated if blank",
        type = "Select type",
        description = "Add a description...",
        tag = "Add tag",
        reportSelect = "Select a report",
        offenceSelect = "Select an offence"
      },
      sections = {
        description = "Description",
        descriptionSubtitle = "Capture the summary and instructions.",
        tags = "Tags",
        tagsSubtitle = "Attach quick identifiers for the warrant.",
        reports = "Linked reports",
        reportsSubtitle = "Attach related report files.",
        offences = "Offences",
        offencesSubtitle = "Link offences tied to this warrant.",
        gallery = "Gallery",
        gallerySubtitle = "Attach gallery images to the warrant."
      },
      gallery = {
        title = "Select a photo",
        subtitle = "Choose a gallery image to attach to the warrant.",
        loading = "Loading gallery...",
        empty = "No gallery photos available.",
        photoAlt = "Gallery photo"
      },
      typesModal = {
        title = "Warrant types",
        subtitle = "Add or remove warrant types for this device.",
        placeholder = "Add warrant type",
        empty = "No warrant types configured."
      },
      types = {
        arrest = "Arrest",
        search = "Search",
        bench = "Bench",
        probation = "Probation"
      },
      status = {
        active = "Active",
        served = "Served",
        expired = "Expired",
        cancelled = "Cancelled"
      },
      priority = {
        low = "Low",
        medium = "Medium",
        high = "High",
        critical = "Critical"
      },
      errors = {
        load = "Unable to load warrants.",
        save = "Unable to save warrant.",
        titleRequired = "Enter a warrant title before saving.",
        typeRequired = "Select a warrant type before saving.",
        gallery = "Unable to load gallery."
      }
    },
    prison = {
      eyebrow = "Detention Log",
      title = "Prison",
      listed = "listed",
      search = {
        placeholder = "Search by name or id"
      },
      filters = {
        all = "All",
        label = "Status",
        placeholder = "Status"
      },
      actions = {
        refresh = "Refresh",
        back = "Back to list",
        saveDuration = "Save duration",
        minusMinutes = "-15 min",
        minusSmall = "-5 min",
        plusSmall = "+5 min",
        plusMinutes = "+15 min",
        saveNotes = "Save notes",
        saveWarrant = "Link warrant",
        addOffence = "Add offence",
        setSolitary = "Send to solitary",
        setGeneral = "Return to general"
      },
      state = {
        loading = "Loading prisoners...",
        empty = "No prisoners match the current filters.",
        saving = "Saving...",
        noOffences = "No offences linked yet."
      },
      labels = {
        mugshot = "Mugshot"
      },
      detail = {
        summary = "Prisoner Summary"
      },
      fields = {
        booked = "Booked",
        remaining = "Time remaining",
        identifier = "Identifier",
        unknown = "Unknown",
        remainingMinutes = "Remaining minutes",
        warrant = "Warrant",
        offences = "Offences",
        housing = "Housing"
      },
      sections = {
        duration = "Sentence duration",
        durationSubtitle = "Adjust remaining time in minutes.",
        notes = "Notes",
        notesSubtitle = "Log observations for this sentence.",
        links = "Linked warrant & offences",
        linksSubtitle = "Attach the warrant and offences tied to this stay.",
        housing = "Housing",
        housingSubtitle = "Switch between solitary and general population."
      },
      placeholders = {
        note = "Add notes...",
        warrant = "Select a warrant",
        offence = "Select an offence"
      },
      status = {
        in_prison = "In prison",
        breaked_out = "Breaked out",
        released = "Released free"
      },
      solitary = {
        active = "Solitary confinement",
        inactive = "General population",
        badge = "Solitary"
      },
      duration = {
        minutesOnly = "{minutes}m left",
        full = "{hours}h {minutes}m left"
      },
      linked = {
        warrantFallback = "Warrant"
      },
      date = {
        unknown = "Unknown"
      },
      errors = {
        load = "Unable to load prisoners.",
        duration = "Unable to update duration.",
        note = "Unable to save note.",
        links = "Unable to update links.",
        solitary = "Unable to update solitary confinement.",
        solitary_unavailable = "No solitary cells configured for this jail."
      }
    },
    workshopConfig = {
      header = {
        title = "Job Configurator"
      },
      sidebar = {
        features = "Features",
        entries = "Jobs",
        interactions = "Interactions"
      },
      sections = {
        general = "General",
        shop = "Shop",
        props = "Props",
        vehicles = "Vehicles",
        locations = "Locations"
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
      features = {
        title = "Features",
        subtitle = "Enable or disable resource features for all configured jobs.",
        instantTuning = { label = "Instant Tuning", description = "Allow direct tuning at configured public tuning locations." },
        partsDelivery = { label = "Parts Delivery", description = "Enable workshop parts delivery orders and delivery bays." },
        carryItems = { label = "Physical Parts Handling", description = "Require delivered parts to be transported through the workshop." },
        nitro = { label = "Nitro", description = "Enable nitro installation and vehicle boost use." },
        antiLag = { label = "Anti-Lag", description = "Enable anti-lag installation and exhaust effects." },
        twoStep = { label = "Two-Step", description = "Enable two-step launch control and exhaust effects." },
        wheelDamage = { label = "Wheel Damage", description = "Enable realistic wheel damage and repairs." },
        customHandling = { label = "Custom Handling", description = "Enable custom drivetrain and handling tuning." },
        mileageHud = { label = "Mileage HUD", description = "Show vehicle mileage information while driving." },
        workshopLift = { label = "Workshop Lift", description = "Enable usable lift points configured in workshops." }
      },
      globalSettings = {
        title = "Global settings",
        notice = "These values apply to all configured jobs. Saving them from this job updates the behavior globally."
      },
      tuning = {
        globalTitle = "Global pricing settings",
        globalBadge = "Global",
        globalNotice = "These values apply to all configured jobs. Saving them from this job updates pricing behavior globally.",
        nitroAccess = "Nitro access for this job",
        nitroAccessHelp = "Override the global Nitro feature for this mechanic job.",
        nitroAccessInherit = "Use global Nitro setting",
        nitroAccessEnabled = "Enable Nitro for this job",
        nitroAccessDisabled = "Disable Nitro for this job"
      },
      fields = {
        allowedJobs = "Allowed jobs",
        bone = "Bone",
        category = "Category",
        blip = "Blip",
        color = "Job color",
        consumeItems = "Consume items",
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
        allowedVehicleClasses = "Workshop vehicle classes",
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
        minGrade = "Min grade",
        livery = "Livery",
        fuelType = "Fuel type",
        primaryColor = "Primary color",
        secondaryColor = "Secondary color",
        pearlescentColor = "Pearlescent color",
        wheelColor = "Wheel color",
        extras = "Extras",
        extraId = "Extra ID",
        propCounts = "Prop limits",
        count = "Limit",
        properties = "Vehicle properties",
        property = "Property",
        type = "Type",
        value = "Value",
        animationDict = "Animation dict",
        animationName = "Animation name",
        x = "X",
        y = "Y",
        z = "Z"
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
        properties = "{ \"windowTint\": 1 }"
      },
      descriptions = {
        color = "Color used by Sky Jobs menus, blips, and job UI accents.",
        jobName = "Framework job name registered for this job.",
        offDutyEnabled = "Enable an off-duty counterpart for this job.",
        offDutyJob = "Job name used when this employee goes off duty.",
        allowedVehicleClasses = "Select the vehicle classes this workshop specializes in. No selection allows every class."
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
      extensions = {
        invalidJson = "Invalid JSON. Correct the syntax before saving.",
        jsonObjectRequired = "Value must be a JSON object.",
        partsDeliveryShop = "Parts delivery shop",
        tuningCostProfile = {
          label = "Tuning Prices",
          description = "Configure this job's performance, appearance, wheel, and special option costs. Costs support required item arrays and staged upgrade objects."
        }
      },
      garageTypes = {
        boat = "Boat",
        helicopter = "Helicopter",
        vehicle = "Vehicle"
      },
      fuelTypes = {
        default = "Default (regular)",
        regular = "Regular",
        plus = "Plus",
        premium = "Premium",
        diesel = "Diesel"
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
        headers = {
          interaction = "Interaction",
          key = "Key",
          marker = "Marker",
          blip = "Blip",
          npc = "NPC"
        },
        tabs = {
          behavior = "Behavior",
          marker = "Marker",
          blip = "Blip",
          npc = "NPC"
        },
        status = {
          on = "On",
          off = "Off"
        },
        fields = {
          public = "Public",
          interaction = "Interaction enabled",
          duty = "Require duty",
          unique = "Unique",
          forceMarkerInteraction = "Force marker interaction",
          interactionDistance = "Interaction distance",
          drawDistance = "Draw distance",
          markerSize = "Marker size",
          placementModel = "Placement model"
        },
        help = {
          public = "Allows players outside the configured jobs to use this interaction.",
          interaction = "Enables the actual interaction prompt or target action for this point.",
          duty = "Requires the player to be on duty before this interaction can be used.",
          unique = "Limits the interaction type to one configured point for a location when enabled.",
          forceMarkerInteraction = "Forces marker-style interaction handling even when target/NPC interaction support is available.",
          interactionDistance = "Maximum distance from the point where the player can use the interaction.",
          drawDistance = "Visual marker draw range. Values below the default buffer do not reduce the base distance.",
          markerSize = "Visual marker size override for this interaction point.",
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
      },
      configs = {
        sky_mechanicjob = {
          title = "Mechanic Jobs",
          subtitle = "Configure mechanic jobs, shops, vehicles, and workshop locations."
        }
      },
      settingSections = {
        general = "General",
        partsTheft = "Parts Theft",
        vehicleCare = "Vehicle Care",
        wear = "Wear",
        wheelDamage = "Wheel Damage",
        mileageHud = "Mileage HUD",
        instantTuning = "Instant Tuning",
        carryItems = "Carry Items"
      },
      settingFields = {
        key = "Key",
        label = "Label",
        name = "Item name",
        amount = "Amount",
        price = "Price",
        item = "Item",
        repair = "Repair with kit",
        classId = "Class ID",
        multiplier = "Multiplier",
        kilometersToZero = "Kilometers to zero",
        removeAfterUse = "Consume item",
        flow = "Install flow",
        transport = "Transport",
        prop = "Prop",
        bone = "Bone",
        x = "X",
        y = "Y",
        z = "Z",
        rx = "Rot X",
        ry = "Rot Y",
        rz = "Rot Z",
        category = "Category"
      },
      settings = {
        primaryColor = { label = "Primary color", description = "Main mechanic configurator color and default job color fallback. Use a hex value such as #EDC001." },
        orderInstallNonMinigameDurationMs = { label = "Simple install duration", description = "Milliseconds used for order install steps that do not run a minigame." },
        tuningWorkshopRequireForInstall = { label = "Require workshop for installs", description = "Require tuning order installs to start and complete near a self-service tuning point." },
        tuningWorkshopRequireForRemoval = { label = "Require workshop for removals", description = "Require tuning removals to start and complete near a self-service tuning point." },
        tuningWorkshopDistance = { label = "Workshop requirement distance", description = "Maximum distance from a self-service tuning point for required install or removal actions." },
        addRevenueToSociety = { label = "Deposit revenue to society", description = "Deposit paid tuning order money into the tuning job society account." },
        publicUsersSeePrices = { label = "Public users see prices", description = "Show regular tuning prices to non-mechanic public users." },
        fallbackVehicleValue = { label = "Fallback vehicle value", description = "Value used when no vehicle price can be resolved." },
        priceType = { label = "Price type", description = "Percentage calculates each tuning cost from the vehicle price. Fixed uses the entered money amount.", options = { percentage = "Percentage", fixed = "Fixed" } },
        freeVehicles = { label = "Free tuning vehicles", description = "Vehicle spawn models that receive free tuning orders.", itemLabel = "Vehicle model" },
        partsTheftItem = { label = "Theft tool item", description = "Inventory item used to steal wheels and catalytic converters." },
        partsTheftRemoveItemAfterUse = { label = "Consume theft tool", description = "Remove the theft tool item after a successful theft action." },
        partsTheftStolenWheelItem = { label = "Stolen wheel item", description = "Inventory item awarded when wheels are stolen." },
        partsTheftCatalyticConverterItem = { label = "Catalytic converter item", description = "Inventory item awarded when a catalytic converter is stolen." },
        partsTheftDealerAccount = { label = "Dealer payout account", description = "Account used for stolen parts dealer payouts, such as money or bank." },
        partsTheftDealerSellDistance = { label = "Dealer sell distance", description = "Maximum distance from the dealer to sell stolen parts." },
        partsTheftDispatchEnabled = { label = "Send police dispatch", description = "Create a police dispatch when a wheel or catalytic converter is stolen." },
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
        wearParts = { label = "Wear parts", description = "Vehicle wear parts, their lifetime distance, required repair item, item consumption, and install flow.", itemLabel = "Wear part", fields = { flow = { options = { wheel = "Wheel", performance = "Performance", underbody_neon = "Underbody / lift", oil_change = "Oil change", fluid_refill = "Fluid refill", catalytic_converter = "Catalytic converter", hood_install = "Hood install" } } } },
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
        carryItems = { label = "Carry items", description = "Delivered parts that should become physical carried props.", itemLabel = "Carry item", fields = { transport = { options = { hand = "Hand", forklift = "Forklift", engine_lift = "Engine Hoist" } } } }
      },
      settingValues = {
        tyres = "Tyres",
        brake_pads = "Brake Pads",
        suspension = "Suspension",
        spark_plugs = "Spark Plugs",
        engine_oil = "Engine Oil",
        coolant = "Coolant",
        brake_fluid = "Brake Fluid",
        transmission_fluid = "Transmission Fluid",
        clutch = "Clutch",
        air_filter = "Air Filter",
        traction_battery = "Traction Battery",
        inverter = "Power Inverter",
        catalytic_converter = "Catalytic Converter",
        vehicleClass_0 = "Compacts",
        vehicleClass_1 = "Sedans",
        vehicleClass_2 = "SUVs",
        vehicleClass_3 = "Coupes",
        vehicleClass_4 = "Muscle",
        vehicleClass_5 = "Sports Classics",
        vehicleClass_6 = "Sports",
        vehicleClass_7 = "Super",
        vehicleClass_8 = "Motorcycles",
        vehicleClass_9 = "Off-road",
        vehicleClass_10 = "Industrial",
        vehicleClass_11 = "Utility",
        vehicleClass_12 = "Vans",
        vehicleClass_13 = "Cycles",
        vehicleClass_14 = "Boats",
        vehicleClass_15 = "Helicopters",
        vehicleClass_16 = "Planes",
        vehicleClass_17 = "Service",
        vehicleClass_18 = "Emergency",
        vehicleClass_19 = "Military",
        vehicleClass_20 = "Commercial",
        vehicleClass_21 = "Trains",
        vehicleClass_22 = "Open Wheel"
      }
    },
    jobConfigurator = {
      actions = {
        backToScripts = "Scripts"
      },
      selector = {
        title = "Jobs Configurator",
        subtitle = "Choose which job script you want to configure.",
        description = "Pick the resource you want to configure.",
        loading = "Loading configurators...",
        comingSoon = "Coming soon",
        emptyTitle = "No configurable scripts available.",
        emptySubtitle = "You do not have permission for any registered job configurator.",
        unavailable = "Not registered"
      }
    },
    billing = {
      title = "Issue bill",
      subtitle = "Charge nearby citizens for services.",
      selectLabel = "Select person",
      selectPlaceholder = "Choose person",
      noPlayers = "No nearby persons within {range} m.",
      amountLabel = "Bill amount",
      reasonLabel = "Reason (short)",
      reasonPlaceholder = "Example: Patrol service",
      presetsLabel = "Offences",
      presetSearchPlaceholder = "Search offence or fine",
      presetNoMatches = "No offences match your search.",
      presetReasonHeader = "Offence",
      presetAmountHeader = "Fine",
      presetCustomAmount = "Custom",
      paperDefaultCategory = "Notice of parking violation",
      ticketReceiptTitle = "Citation notice",
      ticketReceiptSubtitle = "Recorded at",
      ticketReceiptCitizenLabel = "Citizen",
      ticketReceiptOfficerLabel = "Issuing staff",
      ticketReceiptReasonLabel = "Charge summary",
      ticketReceiptAmountLabel = "Total fine",
      ticketReceiptAcknowledge = "Acknowledge",
      cancelButton = "Cancel",
      submitButton = "Issue bill",
      submitting = "Sending...",
      success = "Bill issued successfully.",
      paperTicketNumber = "Ticket No",
      paperDate = "Date",
      paperTime = "Time",
      paperCitizenLabel = "Citizen",
      paperOfficerLabel = "Staff",
      paperViolationLabel = "Violation",
      paperNotice = "Payment due immediately. Failure to pay may result in impound.",
      paperSignatureLabel = "Staff signature",
      paperTotalFine = "Total fine",
      errors = {
        failed = "Unable to issue bill.",
        invalid_target = "Person unavailable.",
        empty_reason = "Provide a brief reason.",
        too_far = "Person moved too far away.",
        not_authorized = "You are not authorized to issue bills.",
        not_on_duty = "You must be on duty to issue bills.",
        amount_out_of_range = "Bill amount outside allowed range.",
        insufficient_funds = "Person cannot afford this charge.",
        player_unavailable = "Person unavailable.",
        disabled = "Billing system disabled."
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
