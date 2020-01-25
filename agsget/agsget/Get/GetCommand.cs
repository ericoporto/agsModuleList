using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    class GetCommand : Command
    {
        // Downloads a package to package cache.
        public static int Run(GetOptions GetOptions)
        {
            if (GetOptions == null)
            {
                throw new ArgumentNullException(nameof(GetOptions));
            }

            return  GetDo.Do(GetOptions.changeRunDir, GetOptions.PackageName);
        }
    }
}
