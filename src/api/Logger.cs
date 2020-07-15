using System;

namespace SupercellUilityApi
{
    public class Logger
    {
        public enum ErrorLevel
        {
            Info = 1,
            Warning = 2,
            Error = 3,
            Debug = 4
        }
#if DEBUG
        private static readonly object ConsoleSync = new object();
#endif

        public static void Log(object message, ErrorLevel logType = ErrorLevel.Info)
        {
            switch (logType)
            {
                case ErrorLevel.Info:
                    {
                        Console.ForegroundColor = ConsoleColor.DarkYellow;
                        Console.Write($"[{logType}] ");
                        Console.ResetColor();
                        Console.WriteLine(message);
                        break;
                    }

                case ErrorLevel.Warning:
                    {
#if DEBUG
                        lock (ConsoleSync)
                        {
                            Console.ForegroundColor = ConsoleColor.DarkMagenta;
                            Console.Write($"[{logType}] ");
                            Console.ResetColor();
                            Console.WriteLine(message);
                        }
#endif
                        break;
                    }

                case ErrorLevel.Error:
                    {
#if DEBUG

                        lock (ConsoleSync)
                        {
                            Console.ForegroundColor = ConsoleColor.Red;
                            Console.Write($"[{logType}] ");
                            Console.ResetColor();
                            Console.WriteLine(message);
                        }
#endif
                        break;
                    }

                case ErrorLevel.Debug:
                    {
#if DEBUG

                        lock (ConsoleSync)
                        {
                            Console.ForegroundColor = ConsoleColor.Green;
                            Console.Write($"[{logType}] ");
                            Console.ResetColor();
                            Console.WriteLine(message);
                        }
#endif
                        break;
                    }
            }
        }
    }
}
