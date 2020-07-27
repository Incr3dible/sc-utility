using System;
using System.Collections.Generic;
using System.Timers;
using SupercellUilityApi.Database;
using SupercellUilityApi.Models;

namespace SupercellUilityApi.Core.Cache
{
    public class EventCache
    {
        private readonly string[] _games = {"Clash Royale", "Clash of Clans"};
        private readonly object _syncObject = new object();
        private readonly Timer _updateTimer = new Timer(TimeSpan.FromSeconds(10).TotalMilliseconds);

        public Dictionary<string, IEnumerable<EventImage>>
            Events = new Dictionary<string, IEnumerable<EventImage>>();

        public EventCache()
        {
            Update(null, null);

            _updateTimer.Elapsed += Update;
            _updateTimer.Start();
        }

        private async void Update(object sender, ElapsedEventArgs args)
        {
            foreach (var game in _games)
            {
                var eventImages = await EventDatabase.GetEventImages(game);
                UpdateLogs(eventImages, game);
            }
        }

        public void UpdateLogs(IEnumerable<EventImage> eventImages, string gameName)
        {
            lock (_syncObject)
            {
                if (Events.ContainsKey(gameName)) Events[gameName] = eventImages;
                else Events.Add(gameName, eventImages);
            }
        }

        public IEnumerable<EventImage> GetCachedEvents(string gameName)
        {
            lock (_syncObject)
            {
                return Events.ContainsKey(gameName) ? Events[gameName] : new List<EventImage>();
            }
        }
    }
}