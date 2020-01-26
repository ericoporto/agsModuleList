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
            return AgsGetCore.AgsGetCore.Search(Console.WriteLine, SearchOptions.changeRunDir, SearchOptions.SearchQuery);
        }
    }
}
