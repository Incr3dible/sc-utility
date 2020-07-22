using System;
namespace SupercellUilityApi.Helpers
{
    public class TimeUtils
    {
        public static long CurrentUnixTimestamp => DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
    }
}