using System;
namespace SupercellUilityApi.Helpers
{
    public class TimeUtils
    {
        public static long CurrentUnixTimestamp => DateTimeOffset.Now.ToUnixTimeMilliseconds();
    }
}