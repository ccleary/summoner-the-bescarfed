package com.binaryscar.Summoner
{
    import org.flixel.system.FlxPreloader;
	
    public class Preloader extends FlxPreloader
    {
        
        public function Preloader():void
        {
            className = "Summoner";
			minDisplayTime = 20;
            super();
        }
        
    }

}