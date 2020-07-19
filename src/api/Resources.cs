using System.Threading.Tasks;
using SupercellUilityApi.Core;
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
        public static long TotalRequests { get; set; }

        public static async Task Initialize()
        {
            Configuration = new Configuration();
            Configuration.Initialize();

            StatusDatabase = new StatusDatabase();
            Logger.Log($"Loaded MySql with {await StatusDatabase.CountAsync()} status(es)");

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