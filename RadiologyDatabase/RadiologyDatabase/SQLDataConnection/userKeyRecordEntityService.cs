using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Data.SqlTypes;

namespace RadiologyDatabase.SQLDataConnection
{
    /// <summary>
    /// All the methods for retrieving, updating and deleting data are implemented in this class file.
    /// The samples below show the finder and specific finder method for Entity1.
    /// </summary>
    public class userKeyRecordEntityService
    {
        static SqlConnection getSqlConnection()
        {
            SqlConnection sqlConn = new SqlConnection("Data Source=IS-CAMPBELL1;Initial Catalog=Radiology_Keys;Integrated Security=True");
            return (sqlConn);
        }
        public static userKeyRecord ReadItem(int id)
        {
            return null;
        }

        public static IEnumerable<userKeyRecord> ReadList(string netid)
        {
            System.Diagnostics.Debug.WriteLine("this is a test: + " + netid);
            SqlConnection sqlConn = getSqlConnection();
            try
            {   
                List<userKeyRecord> allRecords = new List<userKeyRecord>();
                sqlConn.Open();
                SqlCommand cmd = new SqlCommand("dbo.Employee_Keys", sqlConn);
                cmd.Connection = sqlConn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new SqlParameter("@netid", netid));
                SqlDataReader rdr = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rdr.Read())
                {
                    userKeyRecord oneRec = new userKeyRecord();
                    oneRec.checkOutRecordId = (Int32)rdr["coId"];
                    oneRec.keyNumber = rdr["tokenNum"].ToString();
                    oneRec.checkedOut = (DateTime)rdr["coDate"];
                    oneRec.checkedIn = rdr.IsDBNull(3) ? (DateTime?) null : (DateTime)rdr["returnDate"];
                    oneRec.lost = rdr.IsDBNull(4) ? (DateTime?)null : (DateTime)rdr["lossDate"];
                    oneRec.paid = rdr["paid"].ToString();
                    oneRec.valid = rdr["tokenValidity"].ToString();
                    allRecords.Add(oneRec);
                }
                userKeyRecord[] userKeyRecordList = new userKeyRecord[allRecords.Count];
                for (int recCounter = 0; recCounter <= allRecords.Count - 1; recCounter++)
                {
                    userKeyRecordList[recCounter] = allRecords[recCounter];
                }
                return (userKeyRecordList);
            }
            catch (Exception ex)
            {
                string TellMe = ex.Message;
                userKeyRecord[] userKeyRecordList = new userKeyRecord[1];
                userKeyRecord rec = new userKeyRecord();
                rec.checkOutRecordId = -1;
                rec.keyNumber = "not available";
                rec.checkedOut = new DateTime(0000, 0, 00);
                rec.checkedIn = new DateTime(0000, 0, 00);
                rec.lost = new DateTime(0000, 0, 00);
                rec.paid = "not available";
                rec.valid = "not available";
                userKeyRecordList[0] = rec;
                return (userKeyRecordList);
            }
            finally
            {
                sqlConn.Dispose();
            }
        }

        public static void CheckIn(int id, out IEnumerable<userKeyRecord> returnParameter)
        {
            throw new System.NotImplementedException();
        }
    }
}
