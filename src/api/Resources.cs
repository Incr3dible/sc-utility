using System.Threading.Tasks;
using SupercellUilityApi.Core;

namespace SupercellUilityApi
{
    public static class Resources
    {
        public static GameStatusManager GameStatusManager { get; set; }

        public static async Task Initialize()
        {
            GameStatusManager = new GameStatusManager();

            Logger.Log("Resources initialized.");
        }
    }
}
