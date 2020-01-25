using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    class PackCommand : Command
    {
        public static int RunPackCommand(PackOptions PackOptions)
        {
            return PackDo.Do(Console.WriteLine, PackOptions.changeRunDir, PackOptions.PairName);
        }
    }
}
