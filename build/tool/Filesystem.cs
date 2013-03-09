using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace build
{
    public class Filesystem
    {
        public const int BlockSize = 256;
        public const int DATStart = 4; // Flash page

        public byte FATStart { get; set; }
        public byte SwapSector { get; set; }

        public Filesystem()
        {
            Entries = new List<FilesystemEntry>();
        }

        public void Load(string model)
        {
            CurrentDirectoryId = 0;
            AddDirectory(0, model);
        }

        private void AddDirectory(ushort parentId, string model)
        {
            var entry = new DirectoryEntry
            {
                ParentId = parentId,
                DirectoryId = ++CurrentDirectoryId,
                Name = Path.GetFileName(model.TrimEnd('\\', '/'))
            };
            Entries.Add(entry);
            foreach (var file in Directory.GetFiles(model))
            {
                var fileEntry = new FileEntry
                {
                    ParentId = entry.DirectoryId,
                    Name = Path.GetFileName(file),
                    Data = File.ReadAllBytes(file)
                };
                Entries.Add(fileEntry);
            }
            foreach (var directory in Directory.GetDirectories(model))
                AddDirectory(entry.ParentId, directory);
        }

        public void WriteTo(Stream stream)
        {
            WriteDAT(stream);
            WriteFAT(stream);
        }

        private void WriteDAT(Stream stream)
        {
            ushort block = (DATStart << 5) | 1;
            byte[] blockData = new byte[BlockSize];
            foreach (var entry in Entries.Where(e => e is FileEntry).Cast<FileEntry>())
            {
                entry.SectionIdentifier = block;
                ushort lastBlock = 0xFFFF;
                for (int i = 0; i < entry.Data.Length; i += BlockSize)
                {
                    // Write one block at a time
                    var page = block >> 5;
                    var dataAddress = block & 0x1F;
                    // Write header
                    stream.Seek(page * 0x4000 + (dataAddress * 4), SeekOrigin.Begin);
                    stream.Write(BitConverter.GetBytes(lastBlock), 0, sizeof(ushort));
                    stream.Write(BitConverter.GetBytes(block), 0, sizeof(ushort));
                    // Write block
                    stream.Seek(page * 0x4000 + (dataAddress * BlockSize), SeekOrigin.Begin);
                    var length = BlockSize;
                    if (i + BlockSize > entry.Data.Length)
                        length = entry.Data.Length - i;
                    stream.Write(entry.Data, i, length);
                    // Update state
                    lastBlock = block++;
                    if ((block & 0x1F) == 0) // Ensure that header blocks are never written to
                        block++;
                }
            }
        }

        private void WriteFAT(Stream stream)
        {
            stream.Seek((FATStart + 1) * 0x4000, SeekOrigin.Begin);
            foreach (var entry in Entries)
            {
                var data = entry.GetEntry();
                var array = new byte[data.Length + 3];
                Array.Copy(data, 0, array, 3, data.Length);
                array[0] = entry.Identifier;
                Array.Copy(BitConverter.GetBytes((ushort)data.Length), 0, array, 1, sizeof(ushort));
                Array.Reverse(array);
                stream.Seek(-array.Length, SeekOrigin.Current);
                stream.Write(array, 0, array.Length);
            }
        }

        private ushort CurrentDirectoryId { get; set; }
        public List<FilesystemEntry> Entries { get; set; }
    }
}
