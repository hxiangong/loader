package wd 
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	public class WDLoader extends EventDispatcher
	{
		private static var _instancesCreated:int = 0;
		private static var _wdLoaders:Dictionary = new Dictionary();
		private static var _sharedObject:SharedObject;
		
		/**loader名称  唯一， 可以通过name获取loader*/		
		private var _name:String;
		/**资源服务器地址*/		
		private var _serverUrl:String;
		
		/**需要加载的资源列表*/		
		private var _resQueueList:Dictionary;
		
		/**已经加载的资源列表*/		
		private var _resLoadedList:Dictionary;
		
		private var _bulkLoader:BulkLoader;
		private var _loader:Loader;
		
		/**解析swf，图片队列*/		
		private var _imgLoadQueue:Array;
		/**是否正在解析swf等*/		
		private var _isLoadingImg:Boolean;
		
		/**是否正在加载*/		
		private var _isLoading:Boolean;
		
		public function WDLoader(name:String=null,serverUrl:String=null)
		{
			super();
			if(!name)name = getUniqueName();
			if(_wdLoaders[name])throw new Error("WDLoader with name'" + name +"' has already been created.");
			
			_serverUrl = serverUrl; 
			_name = name;
			_wdLoaders[name] = this;
			_bulkLoader = new BulkLoader(name);
			_bulkLoader.addEventListener(BulkProgressEvent.COMPLETE,onBulkLoaderComplete);
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaderComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderErrorHandler);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderSecurityErrorHandler);
			
			_resQueueList = new Dictionary();
			_resLoadedList = new Dictionary();
		}
		
		public static function getUniqueName() : String{
			return "WDLoader-" + _instancesCreated;
		}
		
		private static function get lobbyShareObject():SharedObject
		{
			if(_sharedObject)return _sharedObject;
			try{
				_sharedObject = SharedObject.getLocal("lobbyWDLoader");
			}catch(e:Error){
				return null;
			}
			return _sharedObject;
		}
		
		private static function updateShareObject(url:String,date:ByteArray,version:String):void
		{
			lobbyShareObject.data[url] = {date:date,version:version}
		}
		
		
		public function add(url:String, id:String, type:String, version:String = "", md5Code:String = "", checkMD5:String = "auto", weight:int = 0, priority:int = 0, context:* = null):void
		{
			if(id == null || url == null)return;
			//已加载
			if(_resLoadedList[id])return;
			
			var absoluteUrl:String = _serverUrl + url;
			//和本地缓存比对版本号
			var resData:Object = lobbyShareObject.data[absoluteUrl];
			if(resData){
				if(resData.version == version){
					
					return;
				}else{
					delete lobbyShareObject.data[absoluteUrl];
				}
			}
			_resQueueList[id] = {url:url, id:id, type:type, version:version, md5Code:md5Code, checkMD5:checkMD5, weight:weight, priority:priority, context:context};
			var props:Object = {id:id, type:"binary"};
			if(weight > 0)props.weight = weight;
			if(priority > 0)props.priority = priority;
			if(context)props.context = context;
			_bulkLoader.add(absoluteUrl,props).addEventListener(Event.COMPLETE,onBulkLoaderItemComplete);
		}
		
		public function addQueue():void
		{
			
		}
		
		public function start():void
		{
			_bulkLoader.start();
		}
		
		private function onBulkLoaderItemComplete(e:Event):void
		{
			var item:LoadingItem = e.currentTarget as LoadingItem;
			item.removeEventListener(Event.COMPLETE,bulkLoaderItemComplete);
			var resInfo:Object = _resQueueList[item.id];
			if(){
				
			}
		}
		
		private function onBulkLoaderComplete(e:BulkProgressEvent):void
		{
			
		}
		
		private function onLoaderComplete(e:Event):void
		{
			
		}
		private function onLoaderErrorHandler(e:IOErrorEvent):void
		{
			
		}
		private function onLoaderSecurityErrorHandler(e:SecurityErrorEvent):void
		{
			
		}
	}
}