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
        private static bool vebose = false;
        private static string configuration = "TI84pSE";
        private static Stream output;
        private static Dictionary<string, ushort> labels;
        private static List<byte> pages; 
        
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
                        vebose = true;
                        break;
                    default:
                        Console.WriteLine("Incorrect usage. build.exe --help for help.");
                        return;
                }
            }
            Console.WriteLine("Building configuration: " + configuration);
            Console.WriteLine("Cleaning up previous build");
            CleanUp();
            CreateOutput();
            Console.WriteLine("Building kernel");
            labels = new Dictionary<string, ushort>();
            Build("../src/kernel/build.cfg");
            Console.WriteLine("Buildling userspace");
            Console.WriteLine("Creating 8xu");
            var osBuilder = new OSBuilder();
            var pageData = new Dictionary<byte, byte[]>();
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
                    if (vebose)
                        Console.WriteLine("Assemling " + parts[1]);
                    Spasm(Path.Combine(directory, parts[1]), Path.Combine(directory, parts[2]), null, configuration);
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
                else if (line.StartsWith("jump entry "))
                {

                }
                else if (line.StartsWith("jump finish "))
                {

                }
                else if (line.StartsWith("jump include"))
                {
                    
                }
                else if (line.StartsWith("rm "))
                {
                    string[] parts = line.Substring(3).Split(' ');
                    foreach (var part in parts)
                        File.Delete(Path.Combine(directory, part));
                }
                else if (line.StartsWith("pages "))
                {
                    var parts = line.Substring(6).Split(' ');
                    foreach (var part in parts)
                        pages.Add(byte.Parse(part, NumberStyles.HexNumber));
                }
                else if (line == "endif") { }
                else
                {
                    Console.WriteLine("Unknown build directive: " + line);
                    throw new InvalidOperationException("Unknown build directive");
                }
            }
        }

        private static void LoadLabels(string file)
        {
            string[] lines = File.ReadAllLines(file);
            foreach (var line in lines)
            {
                string[] parts = line.Trim().Split('=');
                labels.Add(parts[0].Trim(), ushort.Parse(parts[1].Trim().Substring(1), NumberStyles.HexNumber));
            }
        }

        private static string Get8XUFile()
        {
            return "../bin/" + configuration + "/KnightOS.8xu";
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

        private static void CreateOutput()
        {
            output = File.Create("../bin/" + configuration + "/KnightOS.rom");
            int flashPages;
            switch (configuration)
            {
                case "TI73":
                case "TI83p":
                    flashPages = 32;
                    break;
                case "TI84p":
                    flashPages = 64;
                    break;
                case "TI83pSE":
                case "TI84pSE":
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

        static void Spasm(string input, string output, string args, params string[] defines)
        {
            string defineString = " ";
            foreach (string define in defines)
                defineString += "-D" + define + " ";
            ProcessStartInfo info = new ProcessStartInfo("SPASM.exe", "-L -T" + defineString +
                "\"" + input + "\" \"" + output + "\"" + (string.IsNullOrWhiteSpace(args) ? "" : " ") + args);
            info.RedirectStandardOutput = true;
            info.RedirectStandardError = true;
            info.UseShellExecute = false;
            info.WindowStyle = ProcessWindowStyle.Hidden;
            Process proc = Process.Start(info);
            string procOutput = proc.StandardOutput.ReadToEnd();
            string procError = proc.StandardError.ReadToEnd();
            proc.WaitForExit();
            if (vebose || !File.Exists(output))
                Console.Write(procOutput);
        }

        static void OutputHelp()
        {
            Console.WriteLine("KnightOS Build Tool\n" +
                              "build.exe [parameters]\n" +
                              "    Parameters:\n" +
                              "--configuration [name]: Builds with the target configuration.\n" +
                              "    Valid values: TI73, TI83p, TI83pSE, TI84p, and TI84pSE");
        }
    }
}
