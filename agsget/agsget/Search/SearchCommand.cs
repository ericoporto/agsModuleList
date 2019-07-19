using System;
using System.Collections.Generic;
using System.Text;
using CommandLine;

namespace agsget
{
    class SearchCommand : Command
    {
        public static int Run(SearchOptions SearchOptions)
        {
            Console.WriteLine("NOT IMPLEMENTED YET");
            Console.WriteLine("Search query: '{0}'", SearchOptions.SearchQuery);

            if (string.IsNullOrEmpty(SearchOptions.SearchQuery) == true)
            {
                Console.WriteLine("No query to use for search.");
                return 1;
            }

            Console.WriteLine();
            return 0;
        }
    }
}
