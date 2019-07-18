using System;
using System.Collections.Generic;
using System.Text;
using CommandLine;

namespace agsget
{
    [Verb("pack", HelpText = "pack a pair .asc and .ash into a .scm module")]
    public class PackOptions : ProgramOptions
    {
        [Value(0,
            HelpText = "Name used for .asc and .ash filenames.", MetaName = "pairName",
            Required = true)]
        public string PairName { get; set; }
    }
}
