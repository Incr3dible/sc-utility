namespace SupercellUilityApi.Models
{
    public class GameVersion
    {
        public int Major { get; set; }
        public int Minor { get; set; }
        public int Build { get; set; }
        public int Key { get; set; }
        public int Protocol { get; set; }

        public override string ToString()
        {
            return $"{Major}.{Build}.{Minor}";
        }
    }
}
