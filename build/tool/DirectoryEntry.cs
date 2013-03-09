using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace build
{
    public class DirectoryEntry : FilesystemEntry
    {
        public string Name { get; set; }
        public ushort ParentId { get; set; }
        public ushort DirectoryId { get; set; }

        public override byte Identifier
        {
            get { return 0xBF; }
        }

        public override byte[] GetEntry()
        {
            return BitConverter.GetBytes(ParentId)
                .Concat(BitConverter.GetBytes(DirectoryId))
                .Concat(new byte[] { 0xFF })
                .Concat(Encoding.ASCII.GetBytes(Name))
                .Concat(new byte[] { 0 }).ToArray();
        }
    }
}
