using System;
using System.Collections.Generic;
using System.Text;
using CommandLine;

namespace agsget
{
    abstract class Command
    {
        public static int Run(ProgramOptions opts)
        {
            Console.WriteLine("Not implemented.");
            return 1;
        }
    }
}
