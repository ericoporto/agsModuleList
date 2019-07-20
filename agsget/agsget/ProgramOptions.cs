using System;
using System.Collections.Generic;
using System.Text;
using CommandLine;

namespace agsget
{
    // basic options available for all verbs
    public abstract class ProgramOptions
    {
        [Option('c', "changeRunDir", HelpText = "Assume other base dir.")]
        public string changeRunDir { get; set; }

        [Option('v',"verbose", HelpText = "Print verbose output.")]
        public bool Verbose { get; set; }

        [Option('y', "yes", HelpText = "Yes to all questions.")]
        public bool Yes { get; set; }

        [Option('n', "no", HelpText = "No to all questions.")]
        public bool No { get; set; }
    }
}
