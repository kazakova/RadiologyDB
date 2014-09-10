using System;
using System.ComponentModel;
using System.Web.UI.WebControls.WebParts;

using Microsoft.SharePoint.BusinessData.SharedService;
using Microsoft.BusinessData.MetadataModel;
using Microsoft.BusinessData.Runtime;
using Microsoft.SharePoint.Administration;
using Microsoft.SharePoint;

using Microsoft.BusinessData.Infrastructure;
using Microsoft.BusinessData.MetadataModel.Collections;
using System.Drawing;

namespace RadiologyDatabase.UserPickerAndRecords
{
    [ToolboxItemAttribute(false)]
    public partial class UserPickerAndRecords : WebPart
    {
        // Uncomment the following SecurityPermission attribute only when doing Performance Profiling on a farm solution
        // using the Instrumentation method, and then remove the SecurityPermission attribute when the code is ready
        // for production. Because the SecurityPermission attribute bypasses the security check for callers of
        // your constructor, it's not recommended for production purposes.
        // [System.Security.Permissions.SecurityPermission(System.Security.Permissions.SecurityAction.Assert, UnmanagedCode = true)]
        public UserPickerAndRecords()
        {
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            InitializeControl();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
        protected void people_and_records(object sender, EventArgs e)
        {
            string allPeople = peoplepicker.CommaSeparatedAccounts;
            string[] selected = allPeople.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string p in selected)
            {
                string person =p.Substring(13);
                selectedPeople.Items.Add(person);
            }
//make sure that some user id actually got retrieved
            if (selectedPeople.Items.Count != 0)
            {
                //retrieve the key records for that user id
                string username = selectedPeople.Items[0].ToString();
                selectedPeople.Items.Add(username);
               
                try {
                    using (new Microsoft.SharePoint.SPServiceContextScope(SPServiceContext.GetContext(SPContext.Current.Site)))
                        {
                        // Get the BDC service and metadata catalog.
                         BdcService service = SPFarm.Local.Services.GetValue<BdcService>(String.Empty);
                         IMetadataCatalog catalog = service.GetDatabaseBackedMetadataCatalog(SPServiceContext.Current); 
                        // Get the entity by using the specified name and namespace.
                         IEntity entity = catalog.GetEntity("RadiologyDatabase.SQLDataConnection", "userKeyRecordEntity");
                         ILobSystemInstance lobSystemInstance = entity.GetLobSystem().GetLobSystemInstances()[0].Value;

                         // Create an Identity
                         Identity identity = new Identity(username);

                         // Get a method instance for the SpecificFinder method.
                         IMethodInstance method = entity.GetMethodInstance("ReadList",MethodInstanceType.Finder);
                         IParameterCollection parameters = method.GetMethod().GetParameters();
                         //Set Parameters
                         System.Diagnostics.Debug.WriteLine("this is a test2: + " + username);
                         object[] arguments = new object[parameters.Count];
  
                         System.Diagnostics.Debug.WriteLine("this is a test4: + " + parameters.Count);

                         arguments[0] = username;
                         arguments[1] = username;

                         System.Diagnostics.Debug.WriteLine("this is a test3: + " + arguments[0]);
                         entity.Execute(method, lobSystemInstance, ref arguments);
                        entity.
                        }
                    }         
                catch (Exception ex){
                    StatusLabel.ForeColor = Color.Red;
                    StatusLabel.Text = "Unable to create customer." +
                    ex.Message;
                }
               }
        }
    }
    }
  
