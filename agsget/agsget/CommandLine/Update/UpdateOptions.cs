using System;
using System.Collections.Generic;
using System.Text;
using CommandLine;

namespace agsget
{
    [Verb("update", HelpText = "update package index")]
    public class UpdateOptions : ProgramOptions
    {
        [Value(0, 
            HelpText = "URL to get package index from. Gets from default, if empty.", MetaName = "packageIndexURL",
            Required = false)]
        public string PackageIndexURL { get; set; }
    }
}
