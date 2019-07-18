using System;
using System.Collections.Generic;
using System.Text;
using CommandLine;

namespace agsget
{
    [Verb("search", HelpText = "search on package index")]
    public class SearchOptions : ProgramOptions
    {
        [Value(0,
            HelpText = "Query to search the index.", MetaName = "searchQuery",
            Required = true)]
        public string SearchQuery { get; set; }
    }
}
