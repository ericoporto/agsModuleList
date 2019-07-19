using System;
using System.Collections.Generic;
using System.Text;
using CommandLine;

namespace agsget
{
    [Verb("apply", HelpText = "insert a package in a Game.agf project")]
    public class ApplyOptions : ProgramOptions
    {
        [Value(0,
            HelpText = "Package name to insert in Game.agf project.", MetaName = "packageName",
            Required = true)]
        public string PackageName { get; set; }
    }
}
