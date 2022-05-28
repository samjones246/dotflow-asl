state("RPG_RT", "v0.192")
{
    int levelid : 0xA2BD0, 0x4;
    int switchesPtr : 0xA2B70, 0x20;
    int variablesPtr : 0xA2B70, 0x20;
    int startFlag : 0xA2B70, 0x4D;
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
}


start
{
    try{
        if (current.switchesPtr == 0 && current.startFlag == 1 && old.startFlag == 0){
            vars.Log("--- START ---");
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
        return false;
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