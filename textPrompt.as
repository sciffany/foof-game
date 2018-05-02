package  {
	import flash.display.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	public class textPrompt extends MovieClip{

		public function textPrompt() {
			this.alpha=0;
			this.x = this.width/2;
			this.y = 442;
			addEventListener(Event.ADDED_TO_STAGE, stageAddHandler);
		}
		
		function stageAddHandler(e:Event){
			
			;
		}
		
		public function appear(textToShow:String)
		{
			this.textShown.text = textToShow;
			this.alpha=100;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, disappear);
		}
		
		public function addWords(textToShow:String)
		{
			this.textShown.appendText(textToShow);
		}
		
		public function changeWords(textToShow:String)
		{
			this.textShown.text = textToShow;
		}
		
		function disappear(e:KeyboardEvent){
			this.alpha=0;
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, disappear);
		}

	}
	
}
