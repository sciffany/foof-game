package  {
	import flash.events.*;
	import flash.display.*;
	
	public class Inventory {

		public var invDic:Object = new Object();
		
		var myParent:MovieClip;
		
		public function Inventory(rootClip:MovieClip) {
			invDic["ID"]=2;
			myParent = rootClip;
		}
		
		function openInv()
		{
			myParent.newMessage.appear("Here are the items in your inventory:\n");
			for (var thing:String in invDic)
			{
				myParent.newMessage.addWords(thing+"x"+ invDic[thing]+", ");
			}
			
		}
		
		public function addStuff(stuff:String)
		{
			if(invDic[stuff])
			{
				invDic[stuff]++;
			}
			else
			{
				invDic[stuff]=1;
			}
			
			myParent.newMessage.appear("Added a scoop of "+stuff+" into your inventory.");
			
		}

	}
	
}
