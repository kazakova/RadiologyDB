﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace RadiologyDatabase.SQLDataConnection
{
    /// <summary>
    /// This class contains the properties for Entity1. The properties keep the data for Entity1.
    /// If you want to rename the class, don't forget to rename the entity in the model xml as well.
    /// </summary>
    public partial class userKeyRecord
    {
        //TODO: Implement additional properties here. The property Message is just a sample how a property could look like.
        public Int32 checkOutRecordId { get; set; }
        public string keyNumber { get; set; }
        public DateTime checkedOut { get; set; }
        public DateTime? checkedIn { get; set; }
        public DateTime? lost { get; set; }
        public string paid { get; set; }
        public string valid { get; set; }

    }
}
