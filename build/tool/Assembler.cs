using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BeeDevelopment.Brass3;

namespace build
{
    public class Assembler
    {
        public static void Assemble(string input, string output, params string[] defines)
        {
            var compiler = new Compiler();
            var errors = new List<string>();
            var warnings = new List<string>();
            compiler.ErrorRaised += (s, e) => errors.Add("Error "+ e.Filename + " (" + e.LineNumber + "):" +
                e.Message);
            compiler.WarningRaised += (s, e) => warnings.Add("Warning " + e.Filename + " (" + e.LineNumber + "):" +
                e.Message);
            var project = new Project();
            
        }
    }
}
