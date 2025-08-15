using System;
using System.Data.SqlClient;
using System.IO;

class Program
{
    static void Main()
    {
        string masterConnection = "Server=localhost;Database=master;Trusted_Connection=True;";
        string targetDbName = "CoreXCDb";

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

        string targetDbConnection = $"Server=localhost;Database={targetDbName};Trusted_Connection=True;";

        string createTablesSql = File.ReadAllText("Schema.sql");

        using (SqlConnection conn = new SqlConnection(targetDbConnection))
        {
            conn.Open();
            Console.WriteLine($"Connected to database '{targetDbName}'.");

            using (SqlCommand cmd = new SqlCommand(createTablesSql, conn))
            {
                cmd.ExecuteNonQuery();
            }

            Console.WriteLine("Schema created successfully!");
        }
    }
}
