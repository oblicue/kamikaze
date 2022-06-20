#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\animscripts\zm_combat;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\shared;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\gametypes_zm\_weapons;
#include maps\mp\gametypes_zm\_spawnlogic;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\gametypes_zm\_gv_actions;
#include maps\mp\gametypes_zm\_damagefeedback;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_score;
#include scripts\zm\zm_bo2_bots;

init() // entry point
{
    level thread onplayerconnect();
}

onplayerconnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
        self.someText = self createFontString( "Objective", 1.5 );
        self.someText setPoint( "CENTER", "TOP", "CENTER", "TOP" );
        self.someText setText( "^1Press 1 for ammo ($1250), 2 for a random perk. ($1500)" ); 
        iprintlnbold("^1Welcome To Kamikaze Item Shop.");

        self thread monitor_buttons();
    }
    
}
perk_hud_create( perk, custom, print)
{
    if ( !IsDefined( self.perk_hud ) )
    {
        self.perk_hud = [];
    }
    shader = "";
    switch( perk )
    {
        //ORIGINAL PERKS
        case "specialty_armorvest_upgrade":
            shader = "specialty_juggernaut_zombies_pro";
            break;
        case "specialty_armorvest":
            shader = "specialty_juggernaut_zombies";
            break;
        case "specialty_quickrevive_upgrade":
            shader = "specialty_quickrevive_zombies_pro";
            break;
        case "specialty_quickrevive":
            shader = "specialty_quickrevive_zombies";
            break;
        case "specialty_fastreload_upgrade":
            shader = "specialty_fastreload_zombies_pro";
            break;
        case "specialty_fastreload":
            shader = "specialty_fastreload_zombies";
            break;
        case "specialty_rof_upgrade":
        case "specialty_rof":
            shader = "specialty_doubletap_zombies";
            break;
        case "specialty_longersprint_upgrade":
        case "specialty_longersprint":
            shader = "specialty_marathon_zombies";
            break;
        case "specialty_flakjacket_upgrade":
        case "specialty_flakjacket":
            shader = "specialty_divetonuke_zombies";
            break;
        case "specialty_deadshot_upgrade":
        case "specialty_deadshot":
            shader = "specialty_ads_zombies";
            break;
        case "specialty_additionalprimaryweapon_upgrade":
        case "specialty_additionalprimaryweapon":
            shader = "specialty_additionalprimaryweapon_zombies";
            break;
        case "specialty_scavenger_upgrade":
        case "specialty_scavenger": 
            shader = "specialty_tombstone_zombies";
            break;
        case "specialty_finalstand":
        case "specialty_finalstand_upgrade": 
            shader = "specialty_chugabud_zombies";
            break;
        case "specialty_nomotionsensor":
            shader = "specialty_vulture_zombies";
            break;
        case "specialty_grenadepulldeath":
            shader = "specialty_electric_cherry_zombie";
            break;
        default:
            shader = "";
            break;
    }

    hud = create_simple_hud( self );
    hud.foreground = 1;
    hud.sort = 1;
    hud.alpha = 1;
	hud.horzAlign = "user_left"; 
	hud.vertAlign = "user_center";
	hud.hidewheninmenu = 1;
	hud.x = 5.5 + (self.perkarray.size * 30);
    hud.y = 146.5;
	if( perk == "Tombstone" )
    {
        hud SetShader( shader, 24, 19 );
    }
    else
    {
        hud SetShader( shader, 24, 24 );
    }
    self.perkarray[self.perkarray.size] = perk;
    self.perk_hud[ perk ] = hud;
}

monitor_buttons(){
    self endon("disconnect");
    for(;;)
    {
        if (self actionslotonebuttonpressed())
        {   
            if (self.score >= 1250) {
                // self iprintlnbold(self.score);
                self iprintlnbold("^3Ammo Refilled");
                self.score = self.score - 750;
                primary_weapons = self getweaponslist( 1 );
                for ( x = 0; x < primary_weapons.size; x++ )
                {
                    curWeapon = primary_weapons[x];
                    if ( level.headshots_only && is_lethal_grenade(curWeapon) ){
                        continue;
                    }

                    if ( isDefined( level.zombie_include_equipment ) && isDefined( level.zombie_include_equipment[curWeapon] ) ){
                        continue;
                    }

                    if ( isDefined( level.zombie_weapons_no_max_ammo ) && isDefined( level.zombie_weapons_no_max_ammo[curWeapon] ) ){
                        continue;
                    }

                    if ( self hasweapon( curWeapon ) ){
                        self givemaxammo( curWeapon );
                        self setweaponammoclip( curWeapon, 300);
                    }

                }
            } else {
                self iprintlnbold("^3You need 750 cash to refill ammo.");
            }
        }
        if (self actionslottwobuttonpressed())
        {
            if (self.score >= 1500) {
                perks = [];
                // very well written code yes 
                perks[1] = "specialty_armorvest";
                perks[2] = "specialty_fastreload";
                perks[3] = "specialty_quickrevive";
                perks[4] = "specialty_rof";
                perks[5] = "specialty_longersprint";
                perks[6] = "specialty_additionalprimaryweapon";
                //perks[7] = "specialty_deadshot";
                //perks[8] = "specialty_scavenger";
                perknum = randomIntRange( 1,  6 );
                perk = perks[perknum];

                self SetPerk( perk );
                self setblur( 4, 0.1 );
                wait(0.1);
                self setblur(0, 0.1);

                self.stats["perks"]++;
                self perk_hud_create(perk, 0, 0);
                if ( !isDefined( self.perks_active ) )
                {
                    self.perks_active = [];
                }
                self.perks_active[ self.perks_active.size ] = perk;
                self notify("perk_acquired");	
                self thread perk_think( perk );
                self.score = self.score - 1500;
                self iprintlnbold(self getperks());
            
            } else if (self.score < 1500) {
                self iprintlnbold("^3You need 1500 cash for a random perk.");
            }
        }
        wait 0.05;
    }

}