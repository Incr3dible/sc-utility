using System;
using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace SupercellUilityApi.Core
{
    public class Configuration
    {
        [JsonPropertyName("mysql_database")] public string MySqlDatabase { get; set; }
        [JsonPropertyName("mysql_password")] public string MySqlPassword { get; set; }
        [JsonPropertyName("mysql_server")] public string MySqlServer { get; set; }
        [JsonPropertyName("mysql_user")] public string MySqlUserId { get; set; }
        [JsonPropertyName("maintenance")] public bool Maintenance { get; set; }
        [JsonPropertyName("globalLiveMode")] public bool GlobalLiveMode { get; set; }
        [JsonPropertyName("dev_token")] public string DevToken { get; set; }

        /// <summary>
        ///     Loads the configuration
        /// </summary>
        public void Initialize()
        {
            if (File.Exists("config.json"))
                try
                {
                    var config = JsonSerializer.Deserialize<Configuration>(File.ReadAllText("config.json"));

                    MySqlUserId = config.MySqlUserId;
                    MySqlServer = config.MySqlServer;
                    MySqlPassword = config.MySqlPassword;
                    MySqlDatabase = config.MySqlDatabase;

                    DevToken = config.DevToken;
                    Maintenance = config.Maintenance;
                    GlobalLiveMode = config.GlobalLiveMode;
                }
                catch (Exception)
                {
                    Console.WriteLine("Couldn't load configuration.");
                    Console.ReadKey(true);
                    Environment.Exit(0);
                }
            else
                try
                {
                    Save(true);

                    Console.ForegroundColor = ConsoleColor.DarkGreen;
                    Console.WriteLine("Server configuration has been created.\nNow update the config.json for your needs.");
                    Console.ReadKey();
                    Environment.Exit(0);
                }
                catch (Exception)
                {
                    Console.ForegroundColor = ConsoleColor.DarkRed;
                    Console.WriteLine("Couldn't create config file.");
                    Console.ReadKey();
                    Environment.Exit(0);
                }
        }

        public void Save(bool createDefault = false)
        {
            if (createDefault)
            {
                MySqlDatabase = "scudb";
                MySqlPassword = "";
                MySqlServer = "127.0.0.1";
                MySqlUserId = "root";
                Maintenance = false;
                GlobalLiveMode = false;
                DevToken = "your_dev_token_please_change_it"; 
            }

            File.WriteAllText("config.json",
                JsonSerializer.Serialize(this, new JsonSerializerOptions {WriteIndented = true}));
        }
    }
}