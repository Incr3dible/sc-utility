using System.Threading.Tasks;
using SupercellUilityApi.Core;
using SupercellUilityApi.Database;

namespace SupercellUilityApi
{
    public static class Resources
    {
        public static GameStatusManager GameStatusManager { get; set; }
        public static Configuration Configuration { get; set; }
        public static StatusDatabase StatusDatabase { get; set; }

        public static async Task Initialize()
        {
            Configuration = new Configuration();
            Configuration.Initialize();

            StatusDatabase = new StatusDatabase();
            Logger.Log($"Loaded MySql with {await StatusDatabase.CountAsync()} status(es)");

            GameStatusManager = new GameStatusManager();

            Logger.Log("Resources initialized.");
        }
    }
}
