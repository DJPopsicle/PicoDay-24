package mechanics;

import mechanics.FunkinMechanic;

class FunkinMechanicManager
{
    var mechanics:Map<String, FunkinMechanic>;
    var mechanicNames:Array<String>;

    public function new ()
    {
        mechanics = new Map<String, FunkinMechanic>();
        mechanicNames = [];

        trace("created");
    }

    public function updateMechanics(elapsed:Float)
    {
        for (i in 0...mechanicNames.length)
        {
            mechanics.get(mechanicNames[i]).update(elapsed);
            //trace(mechanics.get(mechanicNames[i]));
        }

        //trace("updated");
    }

    public function addMechanic(name:String, mechanic:FunkinMechanic)
    {
        mechanics.set(name, mechanic);
        mechanicNames.push(name);
        
        trace("all set");
    }
}