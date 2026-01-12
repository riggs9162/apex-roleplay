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

### Jobs
- **Citizens**: Basic class with access to tools and basic weapons
- **Civil Worker's Union**: Manufacturing and service roles
- **Combine Units**: Law enforcement and military classes
- **Resistance Members**: Rebel classes with access to contraband
- And many more custom jobs

### Economy
- Money system with printers, shops, and trading
- Property ownership and taxation
- Custom shipments and vending machines

### Combat
- Custom weapon balance for roleplay scenarios
- Combine vs Resistance faction warfare
- Realistic damage and health systems

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
