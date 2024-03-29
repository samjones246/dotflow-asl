state("RPG_RT", "v0.192")
{
    int levelID : 0xA2BD0, 0x4;
    int switchesPtr : 0xA2B70, 0x20;
    int variablesPtr : 0xA2B70, 0x28;
    bool startFlag : 0xA2B70, 0x4D;
    int frames : 0x9FB8C, 0x0, 0x8;
    int eventID : 0xA2B94, 0x4, 0x8, 0x4, 0x0, 0x1C;
}

startup
{
    vars.Log = (Action<object>)((output) => {
        print("[.flow ASL] " + output);
        using (StreamWriter writer = new StreamWriter("dotflow-asl.log", true)) {
            writer.WriteLine("[" + DateTime.Now.ToString("yyMMdd HH:mm:ss.fff") + "] " + output);
        }
    });
    try{
        vars.Log("--- STARTUP ---");

        Dictionary<int, string> effectNames = new Dictionary<int, string>() {
            {0, "Headphones"},
            {1, "Iron Pipe"},
            {2, "Ghost"},
            {3, "Mono Eye"},
            {4, "Diving Helmet"},
            {5, "Cat"},
            {6, "Broom"},
            {7, "Watering Can"},
            {8, "Whistle"},
            {9, "Gas Mask"},
            {161, "Machine"},
            {162, "Daruma"},
            {163, "Slime"},
            {164, "Arms"},
            {165, "Viscera"},
            {166, "Psychedelic"},
            {167, "Handgun"},
            {168, "Corpse"},
            {169, "Black Hood"},
            {170, "Uniform"},
            {171, "Television"},
            {172, "Tattoo"},
            {173, "Plant"},
            {174, "Dress"}
        };

        vars.effectSwitches = effectNames.Keys;

        settings.Add("splitEffect", true, "Split on effect acquired");
        foreach (int index in effectNames.Keys)
        {
            settings.Add("switch" + index, false, effectNames[index], "splitEffect");
        }

        settings.Add("splitWarp", true, "Split on Arms warp");
    }catch(Exception e){
        vars.Log(e);
        throw e;
    }
}

init
{
    vars.Log("--- INIT ---");
    int fileSize = modules.First().ModuleMemorySize;
    vars.Log("Module Size: " + fileSize.ToString("X"));
    if (fileSize == 0xBD000){
        version = "v0.192";
    }
    vars.startFrames = 0;
    vars.firstUpdate = true;
}

update
{
    try{
        if (vars.firstUpdate){
            vars.firstUpdate = false;
            current.switches = null;
            current.variables = null;
        }
        if (current.switchesPtr == 0){
            return;
        }
        current.switches = game.ReadBytes(new IntPtr(current.switchesPtr), 400);
        current.variables = new int[200];
        byte[] varsBytes = game.ReadBytes(new IntPtr(current.variablesPtr), 200 * 4);
        for (int i = 0; i < 200; i++)
        {
            current.variables[i] = BitConverter.ToInt32(varsBytes, i * 4);
        }

        if (current.levelID != old.levelID) {
            vars.Log("Level changed: " + old.levelID + " -> " + current.levelID);
        }
    }catch(Exception e){
        vars.Log(e);
        throw e;
    }

    for (int i=0;i<400;i++){
        if (current.switches[i] < 2 && old.switches[i] < 2 && current.switches[i] != old.switches[i]){
           vars.Log("Switch " + (i+1) + ": " + (current.switches[i] == 1 ? "ON" : "OFF"));
        }
    }
}


start
{
    try{
        if (current.switchesPtr == 0 && current.startFlag && !old.startFlag){
            vars.Log("--- START ---");
            vars.startFrames = current.frames;
            return true;
        }
    }catch(Exception e){
        vars.Log(e);
        throw e;
    }
}

split
{
    try{
        if (current.switchesPtr == 0 || old.switchesPtr == 0){
            return false;
        }

        // Split on effect acquired
        foreach (int i in vars.effectSwitches){
            if (current.switches[i] != old.switches[i]){
                vars.Log("Switch " + (i+1) + ": " + (current.switches[i] == 1 ? "ON" : "OFF"));
                return current.switches[i] == 1 && settings["switch" + i];
            }
        }

        // Ending Splits
        if (current.levelID == 2 && current.eventID == 5 && old.eventID != 5){
            vars.Log("Door interact");
            vars.Log(current.variables[21]);
            if (current.variables[21] >= 24){
                vars.Log("Normal Ending");
                return true;
            }
            if (current.switches[338] == 1){
                vars.Log("True Ending");
                return true;
            }

            if (current.switches[334] == 1){
                vars.Log("Maid Ending");
                return true;
            }
        }

        if (current.switches[53] == 1 && old.switches[53] == 0){
            vars.Log("Arms warp");
            return settings["splitWarp"];
        }
        return false;
    }catch(Exception e){
        vars.Log(e);
        throw e;
    }
}

reset
{
    try{
        return current.frames < old.frames && old.frames != vars.startFrames;
    }catch(Exception e){
        vars.Log(e);
        throw e;
    }
}

exit
{
    try{
        vars.Log("--- EXIT ---");
    }catch(Exception e){
        vars.Log(e);
        throw e;
    }
}

shutdown
{
    try{
        vars.Log("--- SHUTDOWN ---");
    }catch(Exception e){
        vars.Log(e);
        throw e;
    }
}