state("RPG_RT", "v0.192")
{
    int levelid : 0xA2BD0, 0x4;
    int switchesPtr : 0xA2B70, 0x20;
    int variablesPtr : 0xA2B70, 0x20;
    bool startFlag : 0xA2B70, 0x4D;
    int frames : 0x9FB8C, 0x0, 0x8;
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
    }catch(Exception e){
        vars.Log(e);
        throw;
    }
}

init
{
    vars.Log("--- INIT ---");
    int fileSize = modules.First().ModuleMemorySize;
    vars.Log("Module Size: " + fileSize);
    if (fileSize == 0xBD000){
        version = "v0.192";
    }
    vars.startFrames = 0;
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
        throw;
    }
}

split
{
    try{
        return false;
    }catch(Exception e){
        vars.Log(e);
        throw;
    }
}

reset
{
    try{
        return current.frames < old.frames && old.frames != vars.startFrames;
    }catch(Exception e){
        vars.Log(e);
        throw;
    }
}

exit
{
    try{
        vars.Log("--- EXIT ---");
    }catch(Exception e){
        vars.Log(e);
        throw;
    }
}

shutdown
{
    try{
        vars.Log("--- SHUTDOWN ---");
    }catch(Exception e){
        vars.Log(e);
        throw;
    }
}