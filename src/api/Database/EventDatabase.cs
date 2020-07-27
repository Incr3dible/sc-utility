using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;
using SupercellUilityApi.Helpers;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Database
{
    public class EventDatabase
    {
        private const string Name = "event";
        private static string _connectionString;

        public EventDatabase()
        {
            _connectionString = new MySqlConnectionStringBuilder
            {
                Server = Resources.Configuration.MySqlServer,
                Database = Resources.Configuration.MySqlDatabase,
                UserID = Resources.Configuration.MySqlUserId,
                Password = Resources.Configuration.MySqlPassword,
                SslMode = MySqlSslMode.None,
                CharacterSet = "utf8mb4"
            }.ToString();

            Count = CountSync();

            if (Count > -1) return;

            Logger.Log($"MysqlConnection for {Name} failed [{Resources.Configuration.MySqlServer}]!");
            Program.Exit();
        }

        public static long Count { get; set; }

        public static async Task ExecuteAsync(MySqlCommand cmd)
        {
            #region ExecuteAsync

            try
            {
                cmd.Connection = new MySqlConnection(_connectionString);
                await cmd.Connection.OpenAsync();
                await cmd.ExecuteNonQueryAsync();
            }
            catch (MySqlException exception)
            {
                Logger.Log(exception, Logger.ErrorLevel.Error);
            }
            finally
            {
                if (cmd.Connection != null)
                    await cmd.Connection.CloseAsync();
            }

            #endregion
        }

        public static long CountSync()
        {
            #region CountSync

            try
            {
                long seed;

                using var connection = new MySqlConnection(_connectionString);
                connection.Open();
                using (var cmd = new MySqlCommand($"SELECT COUNT(*) FROM {Name}", connection))
                {
                    seed = Convert.ToInt64(cmd.ExecuteScalar());
                }

                connection.Close();

                return seed;
            }
            catch (Exception exception)
            {
                Logger.Log(exception, Logger.ErrorLevel.Error);

                return -1;
            }

            #endregion
        }

        public static async Task<long> CountAsync()
        {
            #region CountAsync

            try
            {
                long seed;

                await using var connection = new MySqlConnection(_connectionString);
                await connection.OpenAsync();

                await using (var cmd = new MySqlCommand($"SELECT COUNT(*) FROM {Name}", connection))
                {
                    seed = Convert.ToInt64(await cmd.ExecuteScalarAsync());
                }

                await connection.CloseAsync();

                return seed;
            }
            catch (Exception exception)
            {
                Logger.Log(exception, Logger.ErrorLevel.Error);

                return -1;
            }

            #endregion
        }

        public static async Task<bool> ExistsAsync(string gameName, string imageUrl)
        {
            #region ExistsAsync

            try
            {
                bool exists;

                await using var connection = new MySqlConnection(_connectionString);
                await connection.OpenAsync();

                await using (var cmd =
                    new MySqlCommand($"SELECT EXISTS(SELECT * FROM {Name} WHERE Image=@image AND Game=@game)",
                        connection))
                {
                    cmd.Parameters?.AddWithValue("@image", imageUrl);
                    cmd.Parameters?.AddWithValue("@game", gameName);

                    exists = Convert.ToBoolean(await cmd.ExecuteScalarAsync());
                }

                await connection.CloseAsync();

                return exists;
            }
            catch (Exception exception)
            {
                Logger.Log(exception, Logger.ErrorLevel.Error);

                return false;
            }

            #endregion
        }

        public static async Task SaveEvent(EventImageUrl eventImage)
        {
            #region SaveAsync

            var exists = await ExistsAsync(eventImage.GameName, eventImage.ImageUrl);
            if (exists) return;

            try
            {
                await using var cmd =
                    new MySqlCommand(
                        $"INSERT INTO {Name} (`Game`, `Image`,`Timestamp`) VALUES (@game, @image, @timestamp)");
#pragma warning disable 618
                cmd.Parameters?.AddWithValue("@game", eventImage.GameName);
                cmd.Parameters?.AddWithValue("@image", eventImage.ImageUrl);
                cmd.Parameters?.AddWithValue("@timestamp", TimeUtils.CurrentUnixTimestamp);
#pragma warning restore 618

                await ExecuteAsync(cmd);
            }
            catch (Exception exception)
            {
                Logger.Log(exception, Logger.ErrorLevel.Error);
            }

            #endregion
        }

        public static async Task<List<EventImage>> GetEventImages(string gameName)
        {
            #region GetAsync

            var list = new List<EventImage>();

            await using var cmd =
                new MySqlCommand(
                    $"SELECT * FROM {Name} WHERE Game = '{gameName}' ORDER BY `Id` DESC")
                {
                    Connection = new MySqlConnection(_connectionString)
                };

            try
            {
                await cmd.Connection.OpenAsync();

                var reader = await cmd.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    var eventImage = new EventImage
                    {
                        GameName = reader["Game"].ToString(),
                        Timestamp = long.Parse(reader["Timestamp"].ToString() ?? "0")
                    };

                    eventImage.SetUrl(reader["Image"].ToString());
                    list.Add(eventImage);
                }
            }
            catch (Exception exception)
            {
                Logger.Log(exception, Logger.ErrorLevel.Error);
            }
            finally
            {
                if (cmd.Connection != null)
                    await cmd.Connection.CloseAsync();
            }

            return list;

            #endregion
        }
    }
}