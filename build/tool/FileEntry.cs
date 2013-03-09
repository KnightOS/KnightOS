using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace build
{
    public class FileEntry : FilesystemEntry
    {
        public string Name { get; set; }
        public ushort ParentId { get; set; }
        public byte[] Data { get; set; }
        public ushort SectionIdentifier { get; set; }

        public override byte Identifier
        {
            get { return 0x7F;  }
        }

        public override byte[] GetEntry()
        {
            return BitConverter.GetBytes(ParentId)
                .Concat(new byte[] { 0xFF })
                .Concat(BitConverter.GetBytes((ushort)Data.Length))
                .Concat(new byte[] { 0 })
                .Concat(BitConverter.GetBytes(SectionIdentifier))
                .Concat(Encoding.ASCII.GetBytes(Name))
                .Concat(new byte[] { 0 }).ToArray();
        }
    }
}
