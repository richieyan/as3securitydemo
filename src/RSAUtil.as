package
{
	import com.hurlant.crypto.rsa.RSAKey;
	import com.hurlant.util.Hex;
	import com.hurlant.util.der.PEM;
	
	import flash.utils.ByteArray;

	public class RSAUtil
	{
		public function RSAUtil()
		{
		}
		
		public static function encrypt(data:String,key:RSAKey):ByteArray
		{
			var src:ByteArray = Hex.toArray(Hex.fromString(data));
			var dst:ByteArray = new ByteArray();
			key.encrypt(src,dst,src.length);//padding为pkcs1pad, mode其实为ECB
			return dst;
		}
		
	}
}