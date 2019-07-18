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
                (SearchOptions opts) => RunSearchCommand(opts),
                (UpdateOptions opts) => RunUpdateCommand(opts),
                (GetOptions opts) => RunGetCommand(opts),
                (ApplyOptions opts) => RunApplyCommand(opts),
                (PackOptions opts) => RunPackCommand(opts),
                //(AddOptions opts) => RunAddCommand(opts), 
                (parserErrors) => 1
            );

            return exitcode;
        }

        static int RunSearchCommand(SearchOptions SearchOptions)
        {
            WriteProgramOptions(SearchOptions);

            Console.WriteLine("Search query: '{0}'", SearchOptions.SearchQuery);

            if (string.IsNullOrEmpty(SearchOptions.SearchQuery) == true)
            {
                Console.WriteLine("No query to use for search.");
                return 1;
            }

            Console.WriteLine();
            return 0;
        }

        static int RunUpdateCommand(UpdateOptions UpdateOptions)
        {
            WriteProgramOptions(UpdateOptions);

            Console.WriteLine("Looked Directory URL: '{0}'", UpdateOptions.PackageIndexURL);

            if (string.IsNullOrEmpty(UpdateOptions.PackageIndexURL) == true)
            {
                Console.WriteLine("No Directory Specified, will update from Default Module Index.");
                return 0;
            }

            Console.WriteLine();
            return 0;
        }

        static int RunGetCommand(GetOptions GetOptions)
        {
            WriteProgramOptions(GetOptions);

            Console.WriteLine("Get Packaged: '{0}'", GetOptions.PackageName);

            if (string.IsNullOrEmpty(GetOptions.PackageName) == true)
            {
                Console.WriteLine("No Package Specified, will do nothing.");
                return 1;
            }

            Console.WriteLine();
            return 0;
        }

        static int RunApplyCommand(ApplyOptions ApplyOptions)
        {
            WriteProgramOptions(ApplyOptions);

            Console.WriteLine("Install Package: '{0}'", ApplyOptions.PackageName);

            if (string.IsNullOrEmpty(ApplyOptions.PackageName) == true)
            {
                Console.WriteLine("No Package Specified, will do nothing.");
                return 1;
            }

            Console.WriteLine();
            return 0;
        }

        static int RunPackCommand(PackOptions PackOptions)
        {
            WriteProgramOptions(PackOptions);

            Console.WriteLine("Create Package: '{0}'", PackOptions.PairName);

            if (string.IsNullOrEmpty(PackOptions.PairName) == true)
            {
                Console.WriteLine("No Package Name Specified, will do nothing.");
                return 1;
            }

            Console.WriteLine();
            return 0;
        }


        static void WriteProgramOptions(ProgramOptions ProgramOptions)
        {
            Console.WriteLine("ProgramOptions type: {0}", ProgramOptions.GetType().Name);
            Console.WriteLine("Verbose: {0}", ProgramOptions.Verbose);
        }

    }

}