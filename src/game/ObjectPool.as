package game 
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	/**
	 * ...
	 * @author imagame
	 */
	public class ObjectPool
	{
		public var group: FlxGroup;
		private var _objClass: Class;
		
		public function ObjectPool(MinSize: uint, ObjClass: Class) 
		{
			trace("ObjectPool");
			group = new FlxGroup();
			
			_objClass = ObjClass;
			for (var i:int = 0; i < MinSize; i++)
			{
				var o:FlxSprite = new ObjClass(i);
				o.kill(); //No recibe gameloop update (no exists && no alive)
				group.add(o);
				//group.add(new ObjClass(i));
			}
		}
		
		public function destroy():void
		{
			group.destroy();
			group = null;
		}		
		
		public function getObj():FlxSprite
		{
			var o:FlxSprite = group.members[0];
			o.reset(0,0); //alive and exists + resets to default 0
			return o;
		}
		
		public function delObj(Obj: FlxSprite):void
		{
			Obj.kill(); 
		}
		/*
		
		private var _pool: Array;
0		private var _objClass: Class;
		
		public function ObjectPool(MinSize: uint, ObjClass: Class) 
		{
			trace("ObjectPool");
			_pool = new Array(MinSize);
			_objClass = ObjClass;
			for (var i:int = 0; i < _pool.length; i++)
			{
				_pool[i] = new ObjClass();
			}
		}
		
		public function destroy():void
		{
			for (var i:int = 0; i < _pool.length; i++)
			{
				_pool[i].destroy();
			}
			_pool = null;
		}
		
		public function getObject(): *
		{
			return new _objClass();
		}
		*/
	}

}