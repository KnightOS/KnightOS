using System;
using System.Diagnostics;
using System.IO;

namespace build
{
    static class RuntimeInfo
    {
        public static bool Is32Bit { get; private set; }
        public static bool Is64Bit { get; private set; }
        public static bool IsMono { get; private set; }
        public static bool IsWindows { get; private set; }
        public static bool IsUnix { get; private set; }
        public static bool IsLinux { get; private set; }
        public static bool IsMacOSX { get; private set; }


        static RuntimeInfo()
        {
            IsMono = Type.GetType("Mono.Runtime") != null;
            int p = (int)Environment.OSVersion.Platform;
            IsUnix = (p == 4) || (p == 6) || (p == 128);
            IsWindows = Path.DirectorySeparatorChar == '\\';

            Is32Bit = IntPtr.Size == 4;
            Is64Bit = IntPtr.Size == 8;

            if (IsUnix)
            {
                var uname = new Process
                {
                    StartInfo =
                    {
                        FileName = "uname",
                        UseShellExecute = false,
                        RedirectStandardOutput = true
                    }
                };
                uname.Start();
                string output = uname.StandardOutput.ReadToEnd();
                uname.WaitForExit();

                output = output.ToUpper().Replace("\n", "").Trim();

                IsMacOSX = output == "DARWIN";
                IsLinux = output == "LINUX";
            }
            else
            {
                IsMacOSX = false;
                IsLinux = false;
            }
        }
    }
}