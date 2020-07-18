using System;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Database
{
    public class StatusDatabase
    {
        private const string Name = "status";
        private static string _connectionString;

        public StatusDatabase()
        {
            _connectionString = new MySqlConnectionStringBuilder
            {
                Server = Resources.Configuration.MySqlServer,
                Database = Resources.Configuration.MySqlDatabase,
                UserID = Resources.Configuration.MySqlUserId,
                Password = Resources.Configuration.MySqlPassword,
                SslMode = MySqlSslMode.None,
                MinimumPoolSize = 2,
                MaximumPoolSize = 20,
                CharacterSet = "utf8mb4"
            }.ToString();
        }

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

                return 0;
            }

            #endregion
        }

        public static async Task SaveGameStatus(GameStatus gameStatus)
        {
            #region SaveAsync

            try
            {
                await using var cmd =
                    new MySqlCommand(
                        $"INSERT INTO {Name} (`Game`, `Status`, `Timestamp`, `FingerprintSha`, `FingerprintVersion`) VALUES (@game, @status, @timestamp, @fingerprintSha, @fingerprintVersion)");
#pragma warning disable 618
                cmd.Parameters?.AddWithValue("@game", gameStatus.GameName);
                cmd.Parameters?.AddWithValue("@status", gameStatus.Status);
                cmd.Parameters?.AddWithValue("@timestamp", gameStatus.LastUpdated);
                cmd.Parameters?.AddWithValue("@fingerprintSha", gameStatus.LatestFingerprintSha);
                cmd.Parameters?.AddWithValue("@fingerprintVersion", gameStatus.LatestFingerprintVersion);
#pragma warning restore 618

                await ExecuteAsync(cmd);
            }
            catch (Exception exception)
            {
                Logger.Log(exception,Logger.ErrorLevel.Error);
            }

            #endregion
        }
    }
}