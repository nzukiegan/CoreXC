using System;
using System.Data.SqlClient;
using System.IO;

class DatabaseInitializer
{
    private readonly string masterConnection;
    private readonly string targetDbName;

    public DatabaseInitializer(string server, string databaseName)
    {
        masterConnection = $"Server={server};Database=master;Trusted_Connection=True;";
        targetDbName = databaseName;
    }

    public void EnsureDatabaseExists()
    {
        using (SqlConnection conn = new SqlConnection(masterConnection))
        {
            conn.Open();
            Console.WriteLine("Connected to master database.");

            string createDbSql = $@"
                IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '{targetDbName}')
                BEGIN
                    CREATE DATABASE [{targetDbName}];
                END";

            using (SqlCommand cmd = new SqlCommand(createDbSql, conn))
            {
                cmd.ExecuteNonQuery();
            }

            Console.WriteLine($"Database '{targetDbName}' is ready.");
        }
    }
}

class Program
{
    static void Main()
    {
        string server = "localhost";
        string dbName = "CoreXCDb";

        var dbInitializer = new DatabaseInitializer(server, dbName);
        dbInitializer.EnsureDatabaseExists();

        string targetDbConnection = $"Server={server};Database={dbName};Trusted_Connection=True;";

        string createTablesSql = File.ReadAllText("Schema.sql");

        using (SqlConnection conn = new SqlConnection(targetDbConnection))
        {
            conn.Open();
            Console.WriteLine($"Connected to database '{dbName}'.");

            using (SqlCommand cmd = new SqlCommand(createTablesSql, conn))
            {
                cmd.ExecuteNonQuery();
            }

            Console.WriteLine("Schema created successfully!");
        }
    }
}