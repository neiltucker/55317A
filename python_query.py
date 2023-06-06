# Install pyodbc and pandas
# This only needs to be done once on the computer. 
!pip install pyodbc
!pip install pandas
!pip install xlwt

### Query a SQL Server database using Python
# pyodbc is a Python ODBC connector for relational databases
import pyodbc, pandas as pd, xlwt

# Open a database connection
conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};'
                      'SERVER=55317MIASQL;'
                      'DATABASE=AdventureWorks2019;'
                      'Trusted_Connection=yes;')

# Get connection details
crsr_conn_details = conn.cursor()
crsr_conn_details.execute("SELECT SUSER_NAME() AS [User Name], @@SERVERNAME AS [SQLServer Instance], DB_Name() as [Database Name]")
connection_details = crsr_conn_details.fetchall()
print("SQL Server connection details (User, Instance, Database): " + str(connection_details))
crsr_conn_details.close()

# List databases
query = "SELECT name,database_id FROM sys.databases"
crsr_db_list = conn.cursor()
crsr_db_list.execute(query)
print(crsr_db_list.fetchall())
crsr_db_list.close()

# Query database table
query = "SELECT TOP 10 BusinessEntityID as [ID], FirstName, LastName FROM AdventureWorks2019.Person.Person"
crsr_tbl = conn.cursor()
crsr_tbl.execute(query)
print(crsr_tbl.fetchall())
crsr_tbl.close()

# Query view and save data to csv file
query = "SELECT BusinessEntityID,Firstname,LastName,PhoneNumber FROM HumanResources.vEmployee ORDER BY BusinessEntityID"
crsr_vw = conn.cursor()
crsr_vw.execute(query)
columns = [c[0] for c in crsr_vw.description]
rows = crsr_vw.fetchall()
df = pd.DataFrame.from_records(rows, columns=columns)
path = "c:\\classfiles\\"
df.to_csv(path + "vEmployees_python.csv", index=False)
df.to_excel(path + "vEmployees_python.xls", index=False)
print(df)
crsr_vw.close()

# Close the database connection
conn.close()

