
package{
	import flash.events.*;
	import flash.display.*;
	import flash.ui.*;
	
	//WORKING ON CHANGING DIRECTIONS
	
	public class foof extends MovieClip{
		
		var dir:String="O";
		public var facing:String="F";
		
		public function foof():void{
			addEventListener(Event.ADDED_TO_STAGE, stageAddHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, remove);
		}
		
		function stageAddHandler(e:Event){
			stage.addEventListener(KeyboardEvent.KEY_DOWN, walk);
		}
	
		function walk(e:KeyboardEvent):void
		{
			stage.addEventListener(KeyboardEvent.KEY_UP, releaseHold);
			var advDir:String;
			switch (e.keyCode){
				
				case Keyboard.RIGHT:
				advDir="R";
				break;
				
				case Keyboard.LEFT:
				advDir="L";
				break;
				
				case Keyboard.UP:
				advDir="B";
				break;
				
				case Keyboard.DOWN:
				advDir="F";
				break;
				
				default:
				advDir="O";
				
			}
			if (dir!=advDir)
			{
				dir=advDir;
				if (dir!="O")
				{
					this.gotoAndPlay("foof"+dir+"W");
				}
			}
			
		}
		
		function releaseHold(e:KeyboardEvent):void
		{
			if (dir!="O")
			{
				facing=dir;
			}			
			this.gotoAndStop("foof"+facing);
			dir="O";
		}
		
		function remove(e:Event)
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, walk);
		}
		
	}
	
}

