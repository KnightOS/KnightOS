using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Diagnostics;

namespace build
{
    class Program
    {
        private static bool verbose = false;
        private static string configuration = "TI84pSE";
        private static Stream output;
        private static Dictionary<string, long> labels;
        private static List<byte> pages;
        private static string language = "en_us";
        private static Filesystem filesystem;
        
        static void Main(string[] args)
        {
            Console.WriteLine("KnightOS Build Tool");
            for (int i = 0; i < args.Length; i++)
            {
                string arg = args[i];
                switch (arg)
                {
                    case "--configuration":
                        configuration = args[++i];
                        break;
                    case "--help":
                        OutputHelp();
                        break;
                    case "--verbose":
                        verbose = true;
                        break;
                    case "--all":
                        if (verbose)
                        {
                            Main(new[] { "--verbose", "--configuration", "TI73" });
                            Main(new[] { "--verbose", "--configuration", "TI83p" });
                            Main(new[] { "--verbose", "--configuration", "TI83pSE" });
                            Main(new[] { "--verbose", "--configuration", "TI84p" });
                            Main(new[] { "--verbose", "--configuration", "TI84pSE" });
                        }
                        else
                        {
                            Main(new[] { "--configuration", "TI73" });
                            Main(new[] { "--configuration", "TI83p" });
                            Main(new[] { "--configuration", "TI83pSE" });
                            Main(new[] { "--configuration", "TI84p" });
                            Main(new[] { "--configuration", "TI84pSE" });
                        }
                        return;
                    case "--language":
                        language = args[++i];
                        break;
                    default:
                        Console.WriteLine("Incorrect usage. build.exe --help for help.");
                        return;
                }
            }
            Console.WriteLine("Building configuration: " + configuration);
            filesystem = new Filesystem();
            Console.WriteLine("Cleaning up previous build...");
            CleanUp();
            CreateOutput();
            Console.WriteLine("Building kernel...");
            labels = new Dictionary<string, long>();
            Build("../src/kernel/build.cfg");
            Console.WriteLine("Buildling userspace...");
            Build("../src/userspace/build.cfg");
            Console.WriteLine("Creating 8xu...");
            var osBuilder = new OSBuilder(configuration == "TI73");
            var pageData = new Dictionary<byte, byte[]>();
            pages.Sort();
            foreach (var page in pages)
            {
                output.Seek(page * 0x4000, SeekOrigin.Begin);
                byte[] data = new byte[0x4000];
                output.Read(data, 0, data.Length);
                pageData.Add(page, data);
            }
            osBuilder.MaxHardwareVersion = 3;
            osBuilder.MajorVersion = 0;
            osBuilder.MinorVersion = 1; // TODO: Pull from some configuration somewhere
            osBuilder.Write8XU(pageData, Get8XUFile(), GetKeyFile(out osBuilder.Key));
            output.Close();
            Console.WriteLine("Complete.");
        }

        private static void Build(string file)
        {
            var jumpTable = new Dictionary<string, ushort>();
            string directory = Path.GetDirectoryName(Path.GetFullPath(file));
            string[] lines = File.ReadAllLines(file);
            bool waitEndIf = false;
            foreach (var _line in lines)
            {
                string line = _line.Trim();
                if (line.StartsWith("#") || string.IsNullOrEmpty(line))
                    continue;
                if (waitEndIf)
                {
                    if (line == "endif")
                        waitEndIf = false;
                    else
                        continue;
                }
                if (line.StartsWith("asm "))
                {
                    string[] parts = line.Split(' ');
                    if (verbose)
                        Console.WriteLine("Assemling " + parts[1]);
                    Assemble(Path.Combine(directory, parts[1]), Path.Combine(directory, parts[2]), null, configuration);
                }
                else if (line.StartsWith("if "))
                    waitEndIf = configuration != line.Substring(3);
                else if (line.StartsWith("link "))
                {
                    string[] parts = line.Split(' ');
                    byte[] data = new byte[int.Parse(parts[3], NumberStyles.HexNumber)];
                    for (int i = 0; i < data.Length; i++)
                        data[i] = 0xFF;
                    using (Stream stream = File.Open(Path.Combine(directory, parts[1]), FileMode.Open))
                        stream.Read(data, 0, (int)stream.Length);
                    output.Seek(int.Parse(parts[2], NumberStyles.HexNumber), SeekOrigin.Begin);
                    output.Write(data, 0, data.Length);
                    output.Flush();
                }
                else if (line.StartsWith("echo "))
                    Console.WriteLine(line.Substring(5));
                else if (line.StartsWith("load "))
                    LoadLabels(Path.Combine(directory, line.Substring(5)));
                else if (line.StartsWith("jump finish "))
                {
                    // C3 34 12
                    string[] parts = line.Split(' ');
                    int tableAddress = int.Parse(parts[2], NumberStyles.HexNumber);
                    output.Seek(tableAddress - (jumpTable.Count * 3), SeekOrigin.Begin);
                    string include = "";
                    foreach (var jumpValue in jumpTable.Reverse())
                    {
                        byte[] value = BitConverter.GetBytes(jumpValue.Value);
                        include = jumpValue.Key + " .equ $" + ((ushort)output.Position).ToString("X4") + Environment.NewLine + include;
                        output.Write(new byte[]
                            {
                                0xC3, // jp
                                value[0],
                                value[1]
                            }, 0, 3);
                    }
                    include = ";This file was generated by a tool" + Environment.NewLine + include;
                    File.WriteAllText(Path.Combine(directory, parts[3]), include);
                }
                else if (line.StartsWith("jump include "))
                    jumpTable.Add(line.Substring(13), (ushort)labels[line.Substring(13).ToLower()]);
                else if (line.StartsWith("rm "))
                {
                    string[] parts = line.Substring(3).Split(' ');
                    foreach (var part in parts)
                    {
                        if (File.Exists(Path.Combine(directory, part)))
                            File.Delete(Path.Combine(directory, part));
                        if (Directory.Exists(Path.Combine(directory, part)))
                            Directory.Delete(Path.Combine(directory, part), true);
                    }
                }
                else if (line.StartsWith("cp"))
                {
                    string[] parts = line.Substring(3).Split(' ');
                    File.Copy(Path.Combine(directory, parts[0]), Path.Combine(directory, parts[1]));
                }
                else if (line.StartsWith("mkdir "))
                    Directory.CreateDirectory(Path.Combine(directory, line.Substring(6)));
                else if (line.StartsWith("fscreate "))
                    CreateFilesystem(Path.Combine(directory, line.Substring(9)));
                else if (line.StartsWith("pages "))
                {
                    var parts = line.Substring(6).Split(' ');
                    foreach (var part in parts)
                        AddPage(byte.Parse(part, NumberStyles.HexNumber));
                }
                else if (line == "endif") { }
                else
                {
                    Console.WriteLine("Unknown build directive: " + line);
                    throw new InvalidOperationException("Unknown build directive");
                }
            }
        }

        private static void CreateFilesystem(string path)
        {
            Console.WriteLine("Creating filesystem...");
            filesystem.Load(path);
            filesystem.WriteTo(output);
        }

        private static void LoadLabels(string file)
        {
            string[] lines = File.ReadAllLines(file);
            foreach (var line in lines)
            {
                if (line.StartsWith(";"))
                    continue;
                string[] parts = line.Trim().Split(' ');
                labels.Add(parts[1].Trim().ToLower(), long.Parse(parts[2].Trim().Substring(2), NumberStyles.HexNumber));
            }
        }

        private static string Get8XUFile()
        {
            if (configuration == "TI73")
                return "../bin/" + configuration + "/KnightOS-" + language + ".73u";
            return "../bin/" + configuration + "/KnightOS-" + language + ".8xu";
        }

        private static string GetKeyFile(out byte keyNumber)
        {
            switch (configuration)
            {
                case "TI73":
                    keyNumber = 0x2;
                    return "02.key";
                case "TI83p":
                case "TI83pSE":
                    keyNumber = 0x4;
                    return "04.key";
                case "TI84p":
                case "TI84pSE":
                    keyNumber = 0xA;
                    return "0A.key";
                default:
                    throw new InvalidOperationException("Invalid configuration");
            }
        }

        private static void AddPage(byte page)
        {
            if (!pages.Contains(page))
                pages.Add(page);
            if (!pages.Contains((byte)(page & 0xFC)))
                pages.Add((byte)(page & 0xFC));
        }

        private static void CreateOutput()
        {
            output = File.Create("../bin/" + configuration + "/KnightOS-" + language + ".rom");
            int flashPages;
            switch (configuration)
            {
                case "TI73":
                case "TI83p":
                    filesystem.FATStart = 0x17;
                    filesystem.SwapSector = 0x18;
                    flashPages = 32;
                    break;
                case "TI84p":
                    filesystem.FATStart = 0x37;
                    filesystem.SwapSector = 0x38;
                    flashPages = 64;
                    break;
                case "TI83pSE":
                case "TI84pSE":
                    filesystem.FATStart = 0x77;
                    filesystem.SwapSector = 0x78;
                    flashPages = 128;
                    break;
                default:
                    throw new InvalidOperationException("Invalid configuration");
            }
            for (int i = 0; i < flashPages * 0x4000; i++ )
                output.WriteByte(0xFF); // TODO: Make this better
            output.Seek(0, SeekOrigin.Begin);
            pages = new List<byte>();
        }

        private static void CleanUp()
        {
            if (Directory.Exists("../bin/" + configuration))
                Directory.Delete("../bin/" + configuration, true);
            Directory.CreateDirectory("../bin/" + configuration);
        }

        static void Assemble (string input, string output, string args, params string[] defines)
		{
			string defineString = string.Empty;
			var listingFile = Path.Combine (Path.GetDirectoryName (output), Path.GetFileNameWithoutExtension (output) + ".lst");
			var symbolFile = Path.Combine (Path.GetDirectoryName (output), Path.GetFileNameWithoutExtension (output) + ".sym");
			Array.Resize (ref defines, defines.Length + 1);
			defines [defines.Length - 1] = "lang_" + language;
			foreach (string define in defines)
				defineString += "," + define;
			defineString = defineString.Substring (1);
			string process = "sass.exe";
			string prefix = string.Empty;
			if (RuntimeInfo.IsMono)
			{
				prefix = "\"" + Directory.GetCurrentDirectory() + "/sass.exe\" ";
				process = "mono";
			}
            var info = new ProcessStartInfo(process, prefix + "--encoding \"Windows-1252\" --include \"" +
                Path.Combine(Directory.GetCurrentDirectory(), "..", "inc") + ";" +
                Path.Combine(Directory.GetCurrentDirectory(), "..", "lang", language) + "\""
                + " --listing \"" + listingFile + "\" --symbols \"" + symbolFile + "\" --define \"" + defineString +
                "\" \"" + input + "\" \"" + output + "\"" + (string.IsNullOrEmpty(args) ? "" : " ") + args);
            info.RedirectStandardOutput = true;
            info.RedirectStandardError = true;
            info.UseShellExecute = false;
            info.WindowStyle = ProcessWindowStyle.Hidden;
            info.WorkingDirectory = Path.GetDirectoryName(input);
            Process proc = Process.Start(info);
            string procOutput = proc.StandardOutput.ReadToEnd();
            string procError = proc.StandardError.ReadToEnd();
            proc.WaitForExit();
            if (verbose)
                Console.Write(procOutput);
			Console.Write(procError);
        }

        static void OutputHelp()
        {
            Console.WriteLine("KnightOS Build Tool\n" +
                              "build.exe [parameters]\n" +
                              "    Parameters:\n" +
                              "--configuration [name]: Builds with the target configuration.\n" +
                              "    Valid values: TI73, TI83p, TI83pSE, TI84p, and TI84pSE\n" +
                              "--verbose: Builds in verbose mode with more detailed output.\n" +
                              "--all: Builds with all possible configurations.");
        }
    }
}
