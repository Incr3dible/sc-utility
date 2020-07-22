using System;
using System.Threading.Tasks;
using SupercellUilityApi.Core;
using SupercellUilityApi.Core.Cache;
using SupercellUilityApi.Core.Manager;
using SupercellUilityApi.Database;

namespace SupercellUilityApi
{
    public static class Resources
    {
        private static readonly object SyncObject = new object();
        public static GameStatusManager GameStatusManager { get; set; }
        public static GameVersionManager GameVersionManager { get; set; }
        public static Configuration Configuration { get; set; }
        public static StatusDatabase StatusDatabase { get; set; }
        public static FingerprintDatabase FingerprintDatabase { get; set; }
        public static FingerprintCache FingerprintCache { get; set; }
        public static Firebase Firebase { get; set; }
        public static Logger Logger { get; set; }
        public static long TotalRequests { get; set; }

        public static async Task Initialize()
        {
            Logger = new Logger();
            Logger.Log(
                $"Starting [{DateTime.Now.ToLongTimeString()}] ...");

            Configuration = new Configuration();
            Configuration.Initialize();

            Firebase = new Firebase();

            StatusDatabase = new StatusDatabase();
            FingerprintDatabase = new FingerprintDatabase();
            Logger.Log($"Loaded MySql with {await StatusDatabase.CountAsync()} status(es) & {await FingerprintDatabase.CountAsync()} fingerprint(s)");

            FingerprintCache = new FingerprintCache();

            GameVersionManager = new GameVersionManager();
            GameStatusManager = new GameStatusManager();

            Logger.Log("Resources initialized.");
        }

        public static void IncrementRequests()
        {
            lock (SyncObject)
            {
                TotalRequests++;
            }
        }
    }
}