// Taken from Build8xu and converted to C# for better non-Windows compatability

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace build
{
    public class Signature
    {
        private const int _RADIX = 16;
        private const string _DEFAULT_D = "70B9C23D9EF0E072259990AF5538C5A0F3CE57F" + "379F2059B8149915A27A9C7050D1889078AC306D98A0154CFDDD44F74B7AB2DFA44643FEBF0E0916063D631E1";
        private const string _DEFAULT_N = "BFA2309BF4997D8ED9850F907746E9919E78625" + "11C1B6FEEC23043E6103A38BD84F5421AD04980F79D4EC7D6093D1D1FEF60334E93BF6CD46F82F19B7EF2AB6B";
        private BigInteger _d = new BigInteger(_DEFAULT_D, _RADIX);
        private BigInteger _n = new BigInteger(_DEFAULT_N, _RADIX);
        private BigInteger _hash;

        public Signature(byte[] md5Hash)
        {
            //Convert this to a string
            _hash = new BigInteger(_GetString(md5Hash), _RADIX);
        }

        public Signature(string md5Hash)
        {
            _hash = new BigInteger(md5Hash, _RADIX);
        }

        public string D
        {
            get { return _GetBigIntegerString(_d.getBytes(), _d.getBytes().Length - 1); }
            set { _d = new BigInteger(value, 16); }
        }

        public string N
        {
            get { return _GetBigIntegerString(_n.getBytes(), _n.getBytes().Length - 1); }
            set { _n = new BigInteger(value, 16); }
        }

        public override string ToString()
        {
            byte[] sig = _hash.modPow(_d, _n).getBytes();

            return _GetBigIntegerString(sig, sig.Length - 1);
        }

        public bool Validate()
        {
            BigInteger calculatedHash = new BigInteger(this.ToString(), _RADIX);
            bool ret = true;

            //Calculate the hash
            calculatedHash = calculatedHash.modPow(new BigInteger(17), _n);

            //Compare our real hash and the calculated hash
            byte[] ourHash = _hash.getBytes();
            byte[] myHash = calculatedHash.getBytes();
            if (ourHash.Length == myHash.Length)
            {
                for (int i = 0; i <= ourHash.Length - 1; i++)
                {
                    if (ourHash[i] != myHash[i])
                    {
                        ret = false;

                        break; // TODO: might not be correct. Was : Exit For
                    }
                }
            }
            else
            {
                //Not even the right length, it's crap
                ret = false;
            }

            return ret;
        }

        public static string GetPrivateKeyExponent(string p, string q)
        {
            BigInteger e = new BigInteger(Convert.ToInt64(17));
            BigInteger d = e.modInverse((new BigInteger(p, _RADIX) - 1) * (new BigInteger(q, _RADIX) - 1));

            return d.ToString(_RADIX);
        }

        private string _GetString(byte[] data)
        {
            string ret = string.Empty;

            for (int i = data.Length - 1; i >= 0; i += -1)
            {
                ret = ret + data[i].ToString("X2");
            }

            return ret;
        }

        private string _GetBigIntegerString(byte[] data, int length)
        {
            string ret = string.Empty;

            for (int i = data.Length - 1; i >= 0; i += -1)
            {
                ret = data[i].ToString("X2") + ret;
            }

            return ret;
        }
    }

}
