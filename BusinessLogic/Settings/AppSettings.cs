namespace ContainerApp_WebApi_Secrets.BusinessLogic.Settings
{
    public class AppSettings
    {
        public string DefaultDBConnectionString { get; set;  }
        public string FCApiKey { get; set; }
        public string Secret1 {  get; set; }
        public string HotterSftpHost { get; set; }
        public string HotterSftpUsername { get; set; }
        public string HotterSftpPassword { get; set; }
    }
}
