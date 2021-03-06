package
{
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.prng.Random;
	import com.hurlant.crypto.rsa.RSAKey;
	import com.hurlant.crypto.symmetric.AESKey;
	import com.hurlant.crypto.symmetric.CTRMode;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.crypto.symmetric.PKCS5;
	import com.hurlant.crypto.tls.CipherSuites;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	import com.hurlant.util.der.PEM;
	
	import flash.display.Sprite;
	import flash.utils.ByteArray;

	public class Demo extends Sprite
	{
		//X509(pem)（和后端不同，后端使用的PKCS#8)
		private static var PRIVATE_KEY:String = "-----BEGIN RSA PRIVATE KEY-----\n"+
			"MIICXQIBAAKBgQDIlz4JOLCrLCpx95xgyBEjH5QvWfeSKrinrsjfz3Sdxu6qP764\n"+
			"AYtKldX4nxPPURCto3XL7fkOIvktluxNxINw6FGAdyqoL1B0YVfWSbN8eRFnivBe\n"+
			"JNqWiBmxyV22IvmW4uOk8MFTXn7SnvptELAj0d+Nt32ExZQYFI2Z3oSSpwIDAQAB\n"+
			"AoGAQomAp3hpie4VikZTVfsnTBpOgkJ6j76iD+U3dp4PFcMGKe0JK2o/tRbsqhLC\n"+
			"dHN0b9SX33Rpt9m8A/ZbHhTAcF2zqjvlkNnDdaxKCOLh3Ze9piFS2PYty+b4BPhk\n"+
			"lskz812z/RdUFNjUDCOPCOGjgJjTk10dgpeGtvtp2+6xM6kCQQDzsqVV1ZaAEiNj\n"+
			"02Sq+IFD3emPL+C662imoTfegXnJ+daDKVyAbQ1LdVtfnfsShWdWBegO02MVduNX\n"+
			"XdaTOlITAkEA0reEDSOBrtDaR1hRG3coRIfegx48X89J5hZ29/LeAxJ3/ZHnveJl\n"+
			"paZ5/vevHU9kdCuPKI3fWlho/Oikom5vnQJBAK71Q+Qy2sEJxKSnoO9qSAu8ZzEo\n"+
			"k3Q/DDwNJLo3RIOwPcSezk1ZfaD+GWK1Xgr3AbBtvyPduZYwa5lOwn2i8kcCQHRI\n"+
			"PaEahQg5zRsuC6RCf4BCEnL9Dog41ikZIJH3/rhnSrwt9lr9QubFFfG0MXjVRTQu\n"+
			"jZPtpuIug9F9eM0CcKkCQQDAs3jjYqxKlzqf+dQZEeExRRHoLVJZ7/y3kDX3DuWn\n"+
			"PTCkoRctURdmBpKiRZj8CMPzRGxv+ynOnkUlVE4MJTfW\n"+
			"-----END RSA PRIVATE KEY-----";
			
		private static var MODULUS:String = "c8973e0938b0ab2c2a71f79c60c811231f942f59f7922ab8a7aec8dfcf749dc6eeaa3fbeb8018b4a95d5f89f13cf5110ada375cbedf90e22f92d96ec4dc48370e85180772aa82f50746157d649b37c7911678af05e24da968819b1c95db622f996e2e3a4f0c1535e7ed29efa6d10b023d1df8db77d84c59418148d99de8492a7"; 
		private static var EXPONENT:String = "10001";
		
		public function Demo()
		{
			

//			testAES();
			testRSA();
			
			//it's not work
//			testPEM2();
		}
		
		public function testAES():void
		{
			var message:String = "this is a plain text. 这是一段文本。";
//			var key:ByteArray = randomKey();
			var a:Array = [71,-67,-38,24,-62,30,-60,-51,46,-109,-7,-110,41,36,-83,-115];
			var key:ByteArray = toByteArray(a);
			
			printByteArray(key);
			var cipher:CTRMode = new CTRMode(new AESKey(key));
			cipher.IV = key;//use key as iv
			
			//加密
			var data:ByteArray = Hex.toArray(Hex.fromString(message));
			cipher.encrypt(data);
			printByteArray(data);
			
			//解密
			cipher.decrypt(data);
			var result:String = Hex.toString(Hex.fromArray(data));
			trace("decrypt:"+result);
			
		}
		
		private static function toByteArray(a:Array):ByteArray
		{
			var ba:ByteArray = new ByteArray();
			for(var i:int = 0; i<a.length;i++)
			{
				ba.writeByte(a[i]);	
			}
			return ba;
		}
		
		
		public function testRSA():void
		{
			var message:String = "this is a plain text. 这是一段文本。";
			//加密
			var rsaKey:RSAKey = RSAKey.parsePublicKey(MODULUS,EXPONENT);
			var data:ByteArray = rsaEncrypt(message,rsaKey);
			var s:String = "";
			data.position = 0;
			for(var i:int = 0;i<data.length;i++){
				s = s + data.readByte() + ",";
			}
			
			//用来给后端解密测试
			trace(s);
			
			//私钥解密
			var privateKey:RSAKey = PEM.readRSAPrivateKey(PRIVATE_KEY);
			var dst:ByteArray = new ByteArray();
			privateKey.decrypt(data,dst,data.length);
			var result:String = Hex.toString(Hex.fromArray(dst));
			trace("decrypt:"+result);
			
			
			//后端的公钥加密( 前端无法正常解密，padding的计算问题）
//			var dataArray:Array = [20, 66, 100, 122, 99, -85, 41, 11, -84, -117, 119, -36, -89, 43, -45, -117, -95, -128, 14, 13, -61, 75, 56, -49, 56, -122, 13, -57, -124, 79, 64, 5, -94, -67, 83, 37, 79, -84, 4, -16, -122, 41, 125, 61, 0, 63, 33, 37, 51, 127, 118, -50, -120, 56, 82, -71, -98, 53, -109, 107, 81, -7, -83, -94, 14, -58, 27, -61, 13, -78, -72, 80, 20, -60, -57, 84, -96, 15, 57, -72, 62, 15, 43, -33, 80, -3, 37, -51, -86, 107, -19, -115, -31, -114, 91, 34, 56, 85, 1, -127, 23, 22, 127, -27, 31, -38, -106, -106, -77, -80, -109, -16, -122, 92, -68, 51, -66, 75, 92, -36, 19, -84, 104, 106, 62, -2, -47, 77];
//			data = toByteArray(dataArray);
//			printByteArray(data);
//			dst = new ByteArray();
//			data.position = 0;
//			privateKey.decrypt(data,dst,data.length);
//			result = Hex.toString(Hex.fromArray(dst));
//			trace("decrypt data from java:",result);

		}
			
		public static function rsaEncrypt(data:String,key:RSAKey):ByteArray
		{
			var src:ByteArray = Hex.toArray(Hex.fromString(data));
			var dst:ByteArray = new ByteArray();
			key.encrypt(src,dst,src.length);//padding为pkcs1pad, mode其实为ECB
			return dst;
		}
		
		//source from lib, it's not work
		public function testPEM2():void 
		{
			var pem:String = "-----BEGIN PUBLIC KEY-----\n" + 
				"MCwwDQYJKoZIhvcNAQEBBQADGwAwGAIRAMkbduS4H0h7uM6V1BNV3M8CAwEAAQ==\n" + 
				"-----END PUBLIC KEY-----";
			var rsa:RSAKey = PEM.readRSAPublicKey(pem);
			trace(rsa.dump());
		}
		
		private static function printByteArray(ba:ByteArray):void
		{
			var s:String = "";
			ba.position = 0;
			for(var i:int = 0;i<ba.length;i++){
				s = s + ba.readByte() + ",";
			}
			trace(s);
		}
		public static function randomKey():ByteArray
		{
			var t:Number = new Date().getTime();
			var rand:Random = new Random();
			rand.autoSeed();
			var bArray:ByteArray = new ByteArray();
			rand.nextBytes(bArray,16);
			return bArray;
		}
		
		public function testArray():void
		{
			var s:ByteArray = new ByteArray();
			var ss:Array = ["ABC", "112121", "kll889"];
			var o:Object = {"a":ss};
			s.writeObject(o);
			
			printByteArray(s);
			
		}
		
		
		
	}
}