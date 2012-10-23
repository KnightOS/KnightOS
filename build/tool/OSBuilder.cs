using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Security.Cryptography;

namespace build
{
    public class OSBuilder
    {
        public OSBuilder(bool TI73)
        {
            DeviceType = (byte)(TI73 ? 0x74 : 0x73); // TI-73 is 0x74
        }

        public byte Key;
        public byte MajorVersion { get; set; }
        public byte MinorVersion { get; set; }
        public byte MaxHardwareVersion { get; set; }
        public byte DeviceType { get; set; }

        private const int linesPerPage = 512;
        private const int bytesPerLine = 32;

        public void Write8XU(Dictionary<byte, byte[]> pages, string outputFile, string keyFile)
        {
            using (Stream stream = File.Create(outputFile))
            {
                // TODO: Find what all of this means, instead of just pulling it from Build8xu
                var data = new byte[]
                    {
                        0x80, 0x0F, 0x00, 0x00, 0x00, 0x00,
                        0x80, 0x11, Key,
                        0x80, 0x21, MajorVersion,
                        0x80, 0x31, MinorVersion,
                        0x80, 0xA1, MaxHardwareVersion,
                        0x80, 0x81, (byte)pages.Count,
                        0x80, 0x7F, 0x00, 0x00, 0x00, 0x00
                    };
                data = pages.Aggregate(data, (current, page) => current.Concat(page.Value).ToArray());

                var md5 = new MD5CryptoServiceProvider();
                var hash = md5.ComputeHash(data, 0, data.Length);
                var signatureProvider = new Signature(hash);

                var lines = File.ReadAllLines(keyFile);
                string n = lines[0].Substring(2);
                string p = lines[1].Substring(2);
                string q = lines[2].Substring(2);
                n = ReverseEndianness(n);
                p = ReverseEndianness(p);
                q = ReverseEndianness(q);
                signatureProvider.D = Signature.GetPrivateKeyExponent(p, q);
                signatureProvider.N = n;

                byte[] header = new byte[]
                    {
                        0x2a, 0x2a, 0x54, 0x49, 0x46, 0x4c, 0x2a, 0x2a,
                        0x02, 0x40, 0x01, 0x88, 0x11, 0x26, 0x20, 0x07,
                        0x08, 0x62, 0x61, 0x73, 0x65, 0x63, 0x6f, 0x64,
                        0x65, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                        DeviceType, 0x23, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                        0x00, 0x00, 0x00, 0x00, 0x00, 0x00
                    };
                stream.Write(header, 0, header.Length);

                var str = GetIntelHexString(0, data, 0, 0x1b);
                stream.Write(Encoding.ASCII.GetBytes(str), 0, Encoding.ASCII.GetByteCount(str));
                str = ":00000001FF" + Environment.NewLine;
                stream.Write(Encoding.ASCII.GetBytes(str), 0, Encoding.ASCII.GetByteCount(str));

                int pagePointer = 0;

                foreach (var page in pages)
                {
                    string pageHeader = ":0200000200" + (page.Key & 0x1F).ToString("X2") +
                        (0xFC - (page.Key & 0x1F)).ToString("X2") + Environment.NewLine;
                    stream.Write(Encoding.ASCII.GetBytes(pageHeader), 0, Encoding.ASCII.GetByteCount(pageHeader));

                    for (int i = 0; i < linesPerPage; i++)
                    {
                        int address = i * bytesPerLine;
                        if (page.Key != 0)
                            address = address | 0x4000;
                        int checksum = bytesPerLine;
                        string line = ":20" + address.ToString("X4") + "00";
                        checksum += address & 0xFF;
                        checksum += ((address & 0xFF00) >> 8) & 0xFF;

                        for (int j = 0; j < bytesPerLine; j++)
                        {
                            byte value = data[(address & 0x3FFF) + j + (pagePointer * 0x4000) + 0x1B];
                            line += value.ToString("X2");
                            checksum += value;
                        }

                        line += (((~(checksum & 0xff) & 0xff) + 1) & 0xff).ToString("X2") + Environment.NewLine;

                        stream.Write(Encoding.ASCII.GetBytes(line), 0, Encoding.ASCII.GetByteCount(line));
                    }

                    pagePointer++;
                }

                str = ":00000001FF" + Environment.NewLine;
                stream.Write(Encoding.ASCII.GetBytes(str), 0, Encoding.ASCII.GetByteCount(str));
                var encodedValidation = new byte[68];
                string signature = signatureProvider.ToString();
                byte[] rawValidation = new byte[signature.Length / 2];
                for (int i = rawValidation.Length - 1; i >= 0; i--)
                {
                    rawValidation[i] = Convert.ToByte(signature.Substring(0, 2), 16);
                    signature = signature.Remove(0, 2);
                }
                encodedValidation[0] = 0x02;
                encodedValidation[1] = 0x0D;
                encodedValidation[2] = 0x40;
                for (int i = 0; i < rawValidation.Length; i++)
                    encodedValidation[i + 3] = rawValidation[i];
                str = GetIntelHexString(0, encodedValidation, 0, 0x20);
                stream.Write(Encoding.ASCII.GetBytes(str), 0, str.Length);

                str = GetIntelHexString(0, encodedValidation, 0x20, 0x20);
                stream.Write(Encoding.ASCII.GetBytes(str), 0, str.Length);

                str = GetIntelHexString(0, encodedValidation, 0x40, 0x3);
                stream.Write(Encoding.ASCII.GetBytes(str), 0, str.Length);

                str = ":00000001FF   -- CONVERT 2.6 --" + Environment.NewLine;
                stream.Write(Encoding.ASCII.GetBytes(str), 0, str.Length);
            }
        }

        private static string ReverseEndianness(string data)
        {
            string ret = "";

            while (data.Length != 0)
            {
                ret = data.Substring(0, 2) + ret;
                data = data.Remove(0, 2);
            }

            return ret;
        }

        private static string GetIntelHexString(int address, byte[] data, int offset, int count)
        {
            string ret = ":";

            ret += count.ToString("X2");
            ret += address.ToString("X4");
            ret += "00";
            for (int i = offset; i <= (count + offset) - 1; i++)
                ret += data[i].ToString("X2");
            ret += CalculateChecksum(ret).ToString("X2");
            ret += Environment.NewLine;

            return ret;
        }

        static internal short CalculateChecksum(string line)
        {
            return CalculateChecksum(StringToShortArray(line));
        }

        static internal short CalculateChecksum(short[] line)
        {
            short ret = 0;

            foreach (short s in line)
                ret = Convert.ToInt16((ret + s) & 255);

            ret = Convert.ToInt16(~ret & 255);
            ret += Convert.ToInt16(1);

            return Convert.ToInt16(ret & 255);
        }

        static internal short[] StringToShortArray(string line)
        {
            short[] ret = null;
            line = line.Trim().TrimStart(':').Trim();

            if (line.Length % 2 != 0)
            {
                throw new ArgumentException("Invalid checksum line!");
            }
            else
            {
                int length = Convert.ToInt32(line.Length / 2);

                Array.Resize(ref ret, length);

                for (int i = 0; i <= length - 1; i++)
                {
                    ret[i] = Convert.ToInt16(line.Substring(0, 2), 16);
                    line = line.Remove(0, 2);
                }
            }

            return ret;
        }
    }
}
