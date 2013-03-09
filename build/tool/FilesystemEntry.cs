using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace build
{
    public abstract class FilesystemEntry
    {
        public abstract byte Identifier { get; }
        public abstract byte[] GetEntry();
    }
}
