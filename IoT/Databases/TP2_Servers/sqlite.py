import sqlite3

create_string=""" CREATE TABLE Category(
catID INTEGER PRIMARY KEY AUTOINCREMENT,
catName TEXT)"""

dbname="my.db"

conn=sqlite3.connect(dbname)
curs=conn.cursor()
curs.execute(create_string)

curs.execute("""INSERT INTO Category(catName) VALUES ('Compass')""")

conn.close()