using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    public class ConsoleExtra
    {
        public static bool ConfirmYN(string title)
        {
            ConsoleKey response;
            do
            {
                Console.Write($"{ title } [y/n] ");
                response = Console.ReadKey(false).Key;
                if (response != ConsoleKey.Enter)
                {
                    Console.WriteLine();
                }
            } while (response != ConsoleKey.Y && response != ConsoleKey.N);

            return (response == ConsoleKey.Y);
        }

    }
}
