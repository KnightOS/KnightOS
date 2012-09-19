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
        private static bool BeVerbose = false;
        private static string Configuration = "TI84pSE";
        private static Stream Output;
        private static Dictionary<string, ushort> Labels;
        
        static void Main(string[] args)
        {
            Console.WriteLine("KnightOS Build Tool");
            for (int i = 0; i < args.Length; i++)
            {
                string arg = args[i];
                switch (arg)
                {
                    case "--configuration":
                        Configuration = args[++i];
                        break;
                    case "--help":
                        OutputHelp();
                        break;
                    case "--verbose":
                        BeVerbose = true;
                        break;
                    default:
                        Console.WriteLine("Incorrect usage. build.exe --help for help.");
                        return;
                }
            }
            Console.WriteLine("Building configuration: " + Configuration);
            Console.WriteLine("Cleaning up previous build");
            CleanUp();
            CreateOutput();
            Console.WriteLine("Building kernel");
            Labels = new Dictionary<string, ushort>();
            Build("../src/kernel/build.cfg");
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
                    if (BeVerbose)
                        Console.WriteLine("Assemling " + parts[1]);
                    Spasm(Path.Combine(directory, parts[1]), Path.Combine(directory, parts[2]), null, Configuration);
                }
                else if (line.StartsWith("if "))
                    waitEndIf = Configuration == line.Substring(3);
                else if (line.StartsWith("link "))
                {
                    string[] parts = line.Split(' ');
                    byte[] data = new byte[int.Parse(parts[3], NumberStyles.HexNumber)];
                    using (Stream stream = File.Open(Path.Combine(directory, parts[1]), FileMode.Open))
                        stream.Read(data, 0, (int)stream.Length);
                    Output.Seek(int.Parse(parts[2], NumberStyles.HexNumber), SeekOrigin.Begin);
                    Output.Write(data, 0, data.Length);
                    Output.Flush();
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
                Labels.Add(parts[0].Trim(), ushort.Parse(parts[1].Trim().Substring(1), NumberStyles.HexNumber));
            }
        }

        private static void CreateOutput()
        {
            Output = File.Create("../bin/" + Configuration + "/KnightOS.rom");
            int flashPages;
            switch (Configuration)
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
            Output.Write(new byte[flashPages * 0x4000], 0, flashPages * 0x4000);
            Output.Seek(0, SeekOrigin.Begin);
        }

        private static void CleanUp()
        {
            if (Directory.Exists("../bin/" + Configuration))
                Directory.Delete("../bin/" + Configuration, true);
            Directory.CreateDirectory("../bin/" + Configuration);
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
            if (BeVerbose || !File.Exists(output))
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
