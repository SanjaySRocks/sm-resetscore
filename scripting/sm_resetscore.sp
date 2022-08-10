#include <sourcemod>
#include <cstrike>
#include <multicolors>

//#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
    name        = "[SM] Reset Score",
    author      = "AmS` SanjayS",
    description = "Allows players to reset/restore score instantly",
    version     = "1.0",
    url         = "https://github.com/sanjaysrocks"
};

char tempPrefix[64];
ConVar gCvarEnable;
ConVar gCvarPrefix;
ConVar gCvarMessageMode;

enum struct PlayerData {
    int frags;
    int deaths;
    int assist;
    int mvp;
    int score;
}

PlayerData gPlayers[MAXPLAYERS+1];

public void OnPluginStart()
{
    RegConsoleCmd("sm_rs", funcResetScore);
    RegConsoleCmd("sm_restore", funcRestoreScore);

    gCvarEnable = CreateConVar("resetscore_enable", "1", "Enable/Disable reset score feature", _, true, 0.0, true, 1.0);
    gCvarPrefix = CreateConVar("resetscore_prefix","[SM]", "Chat prefix for messages");
    gCvarMessageMode = CreateConVar("resetscore_message_mode", "1", "This controls how you want to print message to user 1 - Show reset/restore message only to you, 2 - Show reset/restore message to all with name", _, true, 0.0, true, 2.0);

    gCvarPrefix.GetString(tempPrefix, sizeof(tempPrefix));
    gCvarPrefix.AddChangeHook(OnConVarChanged);

    AutoExecConfig(true);
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue){

    if(convar == gCvarPrefix)
    {
        strcopy(tempPrefix, sizeof(tempPrefix), newValue);
    }
}

public Action funcResetScore(int client, int args){
    int iEnable = GetConVarInt(gCvarEnable)
    
    if(!iEnable){
        return Plugin_Handled;
    }
    
    // save players score in case of future use
    gPlayers[client].frags = GetEntProp(client, Prop_Data, "m_iFrags");
    gPlayers[client].deaths = GetEntProp(client, Prop_Data, "m_iDeaths");
    gPlayers[client].mvp = CS_GetMVPCount(client);
    gPlayers[client].assist = CS_GetClientAssists(client);
    gPlayers[client].score = CS_GetClientContributionScore(client);

    // reset score
    SetEntProp(client, Prop_Data, "m_iFrags", 0);
    SetEntProp(client, Prop_Data, "m_iDeaths", 0);
    CS_SetClientAssists(client, 0);
    CS_SetMVPCount(client, 0);
    CS_SetClientContributionScore(client, 0);

    int iMode = GetConVarInt(gCvarMessageMode)
    
    if(iMode > 0){
        if(iMode == 1)
        {
            CPrintToChat(client, "%s {green}You have just reset your score", tempPrefix);
        }
        else if(iMode == 2)
        {
            CPrintToChatAll("%s {darkred}%N {green}has just reset his score", tempPrefix, client)
        }
    }

    return Plugin_Handled;
}

public Action funcRestoreScore(int client, int args){
    int iEnable = GetConVarInt(gCvarEnable)
    
    if(!iEnable){
        return Plugin_Handled;
    }

    // restore score
    SetEntProp(client, Prop_Data, "m_iFrags", gPlayers[client].frags);
    SetEntProp(client, Prop_Data, "m_iDeaths", gPlayers[client].deaths);
    CS_SetClientAssists(client, gPlayers[client].assist);
    CS_SetMVPCount(client, gPlayers[client].mvp);
    CS_SetClientContributionScore(client, gPlayers[client].score);

    int iMode = GetConVarInt(gCvarMessageMode)
    
    if(iMode > 0){
        if(iMode == 1)
        {
            CPrintToChat(client, "%s {green}You have just restore your score", tempPrefix);
        }
        else if(iMode == 2)
        {
            CPrintToChatAll("%s {darkred}%N {green}has just restore his score", tempPrefix, client)
        }
    }

    return Plugin_Handled;
}