using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    public class GameAgfIO
    {
        public static bool Valid()
        {
            // We need to check if an AGF file is valid. 
            // TEMPORARLY For now, we will just check if it exists.
            return BaseFiles.ExistsGameAgf();
        }
    }
}
