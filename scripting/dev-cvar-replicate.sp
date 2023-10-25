#include <sourcemod>
#include <multicolors>

#pragma newdecls required
#pragma semicolon 1

#define PLUGIN_VERSION "0.0.1"
#define PLUGIN_PREFIX "[ConRep]"

public Plugin myinfo =
{
    name = "[ANY] Dev cvar replicate",
    author = "faketuna",
    description = "Allow to replicate any cheat cvar when you are root admin.",
    version = PLUGIN_VERSION,
    url = ""
}

public void OnPluginStart() {
    RegAdminCmd("sm_replicate", commandReplicate, ADMFLAG_ROOT, "Replicate any cvar to client.");
}

public Action commandReplicate(int client, int args) {
    if(args < 3) {
        CPrintToChat(client, "%s Usage: !replicate <target> <cvar> <value>", PLUGIN_PREFIX);
        return Plugin_Handled;
    }
    if(args > 2) {
        char target[128];
        char targetName[MAX_TARGET_LENGTH];
        int targetList[MAXPLAYERS];
        int targetCount;
        bool tn_is_ml;

        GetCmdArg(1, target, sizeof(target));
        targetCount = ProcessTargetString(
            target,
            client,
            targetList,
            MAXPLAYERS,
            0,
            targetName,
            sizeof(targetName),
            tn_is_ml);
        if (targetCount <= 0) {
            ReplyToTargetError(client, targetCount);
            return Plugin_Handled;
        }

        char cvarName[128];
        char value[128];
        char buff[128];
        GetCmdArg(2, cvarName, sizeof(cvarName));
        for(int i = 3; i <= args; i++) {
            GetCmdArg(i, buff, sizeof(buff));
            Format(value, sizeof(value), "%s %s", value, buff);
        }
        ConVar cvar;
        cvar = FindConVar(cvarName);
        if(cvar == INVALID_HANDLE) {
            CPrintToChat(client, "%s The specified cvar %s is not found.", PLUGIN_PREFIX, cvarName);
            return Plugin_Handled;
        }

        for (int i = 0; i < targetCount; i++) {
            if (IsClientInGame(targetList[i])) {
                SendConVarValue(targetList[i], cvar, value);
            }
        }
        CPrintToChat(client, "%s Sent", PLUGIN_PREFIX);
    }
    return Plugin_Handled;
}
