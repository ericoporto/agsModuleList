using System;
using System.Collections.Generic;
using System.Text;
using CommandLine;

namespace agsget
{
    [Verb("get", HelpText = "download a single package to cache")]
    public class GetOptions : ProgramOptions
    {
        [Value(0,
            HelpText = "Package name to download.", MetaName = "packageName",
            Required = true)]
        public string PackageName { get; set; }
    }
}
