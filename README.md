# Apex Roleplay: Redux

A community-driven revival of the classic Half-Life 2 Roleplay gamemode, originally developed by Nova Canterra and the Apex Roleplay team.

## Overview

Apex Roleplay: Redux is a Garry's Mod gamemode that recreates the immersive Half-Life 2 roleplaying experience from the Combine-occupied City 17. The main goal of Redux was to maintain the gamemode at a modern level for Garry's Mod, preserving the classic gameplay while fixing technical issues and modernizing the codebase for contemporary hardware.

The gamemode features:
- Classic Combine vs Resistance faction gameplay
- Extensive job system with custom classes
- Economic system with shops, printers, and trading
- Administrative tools via FAdmin
- Prop protection with Falco's Prop Protection (FPP)
- Custom weapons, entities, and content

## Installation

### Prerequisites
- Garry's Mod server (dedicated or listen server)
- Basic knowledge of Garry's Mod server administration

### Step 1: Download the Gamemode
1. Download the Apex Roleplay: Redux gamemode files
2. Extract the `apex-roleplay` folder to your server's `garrysmod/gamemodes/` directory

### Step 2: Install Required Workshop Addons
The gamemode requires several workshop addons for content. These are automatically downloaded when the server starts, but you can also install them manually:

Required Workshop Addons:
- 104491619 - Metropolice Pack
- 104548572 - Playable Piano
- 105042805 - Combine Admin models
- 105841291 - More Materials!
- 1118211492 - CrowCommunity Content
- 1185975101 - Apex i17 Build 8
- 122969743 - Resistance Turrets
- 128967611 - [Swep] Combine Sniper
- 131410709 - Smoke_Grenade
- 1366149792 - RT Combine Screens
- 173482196 - SProps Workshop Edition
- 175272156 - Metrocop Beta Sounds
- 206166550 - Sabrean's Headcrab Zombie Mod
- 266180263 - Cityruins
- 543527096 - shield
- 593929594 - food mdl
- 618272585 - Industrial Uniforms
- 619791481 - Hl2 beta Playermodels
- 676638642 - BMRP Scientist Models
- 728638542 - Vingard crow 2.o
- 732711970 - Portal
- 733021825 - vins stuff
- 741788352 - Airwatch
- 761228248 - cuffs
- 774902402 - guns
- 798205573 - lockplymodel
- 822075881 - groundwatch
- 844787757 - Broadcast thing

You can install these via the Steam Workshop or use the in-game command `apex_workshop_view` to view and manage them.

### Step 3: Configure the Server
1. Set the gamemode in your server startup parameters: `+gamemode apex-roleplay`
2. Choose an appropriate map (any map starting with `rp_` works, e.g., `rp_city17_build210`)
3. Start the server

### Step 4: Database Setup (Optional)
By default, the gamemode uses SQLite for data storage. For larger servers, you may want to use MySQL:

1. Install the MySQLoo module (gm_mysqloo) on your server
2. Edit `gamemode/mysql.lua`
3. Set `RP_MySQLConfig.EnableMySQL = true`
4. Configure your MySQL connection details:
   - Host
   - Username
   - Password
   - Database name
   - Port (default: 3306)

### Step 5: Configuration
Edit `gamemode/config.lua` to customize gameplay settings such as:
- Starting money and salaries
- Job limits and restrictions
- Weapon and vehicle availability
- Economy settings
- Administrative permissions

## Server Administration

### Admin System
The gamemode includes FAdmin for server administration. Access admin commands via the FAdmin menu or console commands.

### Key Console Commands
- `apex_workshop_view` - View and manage required workshop addons
- `apex_getvehicles_sv` - List available vehicles for custom jobs

### File Structure
```
apex-roleplay/
├── gamemode/
│   ├── client/          # Client-side scripts
│   ├── server/          # Server-side scripts
│   ├── shared/          # Shared scripts
│   ├── fadmin/          # Admin system
│   ├── fpp/            # Prop protection
│   ├── modules/        # Additional modules
│   ├── thirdparty/     # Third-party libraries
│   ├── config.lua      # Main configuration
│   ├── mysql.lua       # Database configuration
│   └── [other core files]
├── entities/           # Custom entities
├── weapons/           # Custom weapons
├── content/           # Materials, models, sounds
└── apex-roleplay.txt  # Gamemode definition
```

## Gameplay Features

### Jobs System
The gamemode features an extensive XP-based job progression system with multiple factions and special mechanics:

#### Citizen Factions
- **Citizen** (XP: 0): Basic class with access to tools and basic weapons. Forced to follow Combine dictatorship. Can choose citizen options for different playstyles (loyalist, resistance, CWU, medical paths)
- **Civil Worker's Union** (XP: 15): Recruited citizens working for the Combine, receiving better rations and benefits. Operate businesses and sell resources for tokens. Access to manufacturing and medical supplies.

#### Combine Factions
- **Civil Protection** (XP: 35): Human police force enforcing Combine laws. Dynamic maximum based on server population (2/5 ratio). Features division system (Dispatch, Medical, etc.) and rank progression. Responsible for population control and law enforcement.
- **Overwatch Transhuman Arm** (XP: 600): Elite military wing of Combine forces. Highly trained super-soldiers called during dire situations. Limited to 8 units maximum. Advanced nightvision and combat capabilities.
- **City Administrator** (XP: 3000): Human appointed by Combine to run the city. Has authority to override other commanders. Handles paperwork and propaganda. Maximum 1 per server.

#### Resistance & Special Classes
- **Vortigaunt** (XP: 1200): Mysterious alien race enslaved by Combine. Wise and peaceful, forced into servitude. Restricted to VIP donators only. Cannot pick up weapons and must roleplay strictly without voice chat. Access to Vortessence energy system.

Jobs include XP requirements, salary systems (most Combine jobs pay 0 tokens), custom loadouts, and death penalties that reset players to Citizen status. XP is earned through playtime (5 tokens for regular players, 10 for VIP every 10 minutes) and can be saved across sessions.

### Economy System
A comprehensive token-based economy with multiple earning and spending mechanics:

#### Earning Money
- **Job Salaries**: Regular paychecks based on job type (most jobs pay 0 tokens)
- **Business Operations**: CWU members can operate businesses and sell resources
- **Property Ownership**: Door ownership with rental income potential (25 tokens base cost)
- **Ration System**: Hourly rations providing food, money, and supplies based on job (Citizens: 150 tokens, CWU: enhanced rations)
- **Trading**: Player-to-player item and token trading
- **Manufacturing**: CWU can produce and sell goods through various entities

#### Spending & Commerce
- **Vending Machines**: Automated dispensers selling food, supplies, and equipment. Different pricing for Combine vs citizens
- **ATMs**: Banking system with PIN protection for secure transactions
- **Property Purchase**: Door ownership (25 tokens base cost) with taxation system
- **Vehicle Ownership**: Custom vehicles with purchase costs
- **Health & Supplies**: Medical kits, food, and equipment purchases

#### Advanced Features
- **Taxation System**: Wallet taxes and property taxes configurable in settings
- **Money Printers**: Illegal income generation (sent_zar3 entity)
- **Cheques**: DarkRP cheque system for secure payments
- **Shipments**: Bulk item purchasing and spawning
- **Food System**: Hunger mechanics with configurable starvation rates (default: 3 health loss per second)
- **Microwave Cooking**: Food preparation system for enhanced nutrition

Starting money: 25 tokens. Various taxes and fees configurable via config.lua.

### Combat System
Realistic Half-Life 2 inspired combat with faction-based restrictions:

#### Weapon Systems
- **Ironsight System**: Advanced ironsight mechanics for all firearms with customizable positioning and recoil
- **Weapon Categories**: Pistols (USP, Glock), SMGs (MP5, custom variants), rifles (M4A1, AR2 variants), shotguns, revolvers (.357), special weapons
- **Custom Weapons**: Modified HL2 weapons with unique stats and behaviors
- **Weapon Restrictions**: Job-based weapon access (citizens need loyalty options for firearms)
- **Ammo Types**: Pistol (9mm), SMG (rifle), buckshot (shotgun), 357 (revolver) with job-based restrictions

#### Combat Mechanics
- **Health System**: 100 starting health, configurable respawn times (30 seconds default)
- **Armor System**: Citizens start with 0 armor, can be upgraded through gameplay
- **Damage System**: Realistic damage values with weapon-specific balancing
- **Death Mechanics**: Configurable death behavior (black screen, weapon dropping, money loss on death)

#### Faction Combat
- **Combine vs Resistance**: Core faction warfare with different weapon access
- **Law Enforcement**: Arrest system with configurable jail times (120 seconds default)
- **Wanted System**: Criminal pursuit mechanics with configurable wanted times
- **No-Respawn Rules**: Dead players cannot immediately rejoin combat

#### Special Combat Features
- **Emplacement Guns**: Mounted AR3 weapons on barricades for defensive positions
- **Grenades & Explosives**: Smoke grenades and other tactical equipment
- **Medical System**: Health restoration through medkits and rations
- **Vortessence**: Special alien energy system for Vortigaunts
- **Nightvision**: Combine units have access to nightvision goggles with color-coded systems

### Communication Systems
Advanced voice and text communication systems for immersive roleplay:

#### Voice Systems
- **Faction Radios**: Combine units have encrypted radio communications with channel system (/radio command)
- **Voice Macros**: Pre-recorded voice lines for different jobs (citizens, CP, Vortigaunts)
- **3D Voice**: Configurable voice distance and falloff
- **Voice Restrictions**: Vortigaunts cannot use voice chat, must use text/emotes

#### Radio System
- **Channel System**: Players can set radio channels (/channel command)
- **Faction Broadcasting**: Combine units can broadcast to their faction
- **Encrypted Communications**: Secure channels for military operations

### Administrative Systems
Comprehensive admin tools for server management:

#### FAdmin System
- **Player Management**: Kick, ban, jail, and teleport commands
- **Server Settings**: Dynamic configuration through admin interface
- **Logging System**: Comprehensive admin action logging
- **MOTD System**: Customizable message of the day
- **RCON Access**: Remote console access for advanced administration

#### Prop Protection (FPP)
- **Ownership System**: Automatic prop ownership and protection
- **Buddy System**: Share prop access with other players
- **Anti-Spam**: Prevents prop spam and lag
- **Tool Restrictions**: Configurable tool access per job
- **Cleanup Tools**: Mass cleanup commands for administrators

### User Interface & HUD
Custom HUD and interface systems for enhanced gameplay:

#### HUD Elements
- **Job Display**: Current job and name display
- **Health/Armor Bars**: Visual health and armor indicators
- **Hunger System**: Food/energy bar with starvation warnings
- **Voice Chat Icons**: Visual indicators for active voice chat
- **Radio Channel Display**: Current radio channel indicator

#### Custom Menus
- **Vending Machine Interface**: Interactive shopping system
- **ATM Interface**: Banking with PIN protection
- **Admin Panel**: FAdmin interface for server management
- **Workshop Viewer**: In-game workshop addon management (/apex_workshop_view)

### Persistence & Saving
Robust data persistence systems:

#### Player Data
- **XP System**: Experience points saved across sessions
- **Money**: Token balances persisted to database
- **Job Progression**: Unlocked jobs and permissions saved
- **RP Names**: Custom roleplay names with cooldowns

#### World Persistence
- **Door Ownership**: Property ownership saved to database
- **Entity Persistence**: Custom entities maintain state
- **Server Configuration**: Settings saved across restarts

### Special Features
Unique gameplay mechanics that enhance the roleplay experience:

#### Citizen Options
- **Loyalist Path**: Access to legal weapons and Combine benefits
- **Resistance Path**: Underground contraband and rebel activities
- **CWU Path**: Manufacturing and business opportunities
- **Medical Path**: Healthcare and ration distribution

#### Combine Hierarchy
- **Division System**: CP units can specialize in different roles
- **Rank Progression**: Advancement through Combine ranks
- **Nightvision Colors**: Color-coded NV systems (GRID, SPEAR, KING, etc.)

#### Environmental Systems
- **Ration Dispensers**: Job-based food distribution systems
- **Theatre System**: In-game movie playback for roleplay events
- **Scanner System**: Combine surveillance drones
- **Report System**: Player reporting system for rule violations

## Troubleshooting

### Common Issues
1. **Workshop addons not downloading**: Ensure the server has internet access and Steam Workshop is enabled
2. **MySQL connection errors**: Verify MySQLoo is installed and connection details are correct
3. **Missing content**: Check that all required workshop addons are subscribed and downloading
4. **Performance issues**: Monitor server tick rate; the gamemode is optimized for modern hardware

### Logs
- Server logs are stored in `garrysmod/data/DarkRP_logs/`
- MySQL errors are prefixed with "MySQL Error:" in server console

## Support

**Support for this gamemode has been ceased.** No further updates, bug fixes, or assistance will be provided.

However, if you encounter major issues or have improvements to contribute:
- Report bugs by creating an issue on the GitHub repository
- Submit changes via pull request (PR) for community review and potential inclusion

## Credits

- **Original Development**: Nova Canterra, TheVingard, Datamats, JamesAMG, Rickster, NightAngel, Robotboy655
- **DarkRP Framework**: FPtje, PCwizdan, Eusion, Drakehawke, Rick Darkaliono, philxyz, Jake Johnson
- **Assets**: Zaubermuffin, numerous asset donors, Aerolite Gaming
- **Legacy Codebases**: Aerolite Gaming (BMRP), Cortex Community, Crow Network

## License

This gamemode is open source, following the tradition of the original Apex Roleplay release.
