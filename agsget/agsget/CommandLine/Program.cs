using System;
using System.Collections.Generic;
using System.Linq;
using CommandLine;


namespace agsget
{
    public class Program
    {
        public static int Main(string[] args)
        {
            int exitcode;
            
            exitcode = CommandLine.Parser.Default
                .ParseArguments<SearchOptions, UpdateOptions,
                                GetOptions, ApplyOptions, PackOptions>(args)
                .MapResult(
                (SearchOptions opts) => SearchCommand.Run(opts),
                (UpdateOptions opts) => UpdateCommand.Run(opts),
                (GetOptions opts) => GetCommand.Run(opts),
                (ApplyOptions opts) => ApplyCommand.Run(opts),
                (PackOptions opts) => PackCommand.Run(opts),
                (parserErrors) => 1
            );

            return exitcode;
        }      

    }

}