using System;
using System.Data.SqlClient;
using System.IO;

class Program
{
    static void Main()
    {
        string connectionString = "Server=localhost;Database=CoreXCDb;Trusted_Connection=True;";

        string createTablesSql = File.ReadAllText("Schema.sql");

        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            conn.Open();
            Console.WriteLine("Connected to database!");

            using (SqlCommand cmd = new SqlCommand(createTablesSql, conn))
            {
                cmd.ExecuteNonQuery();
            }

            Console.WriteLine("Schema created successfully!");
        }
    }
}