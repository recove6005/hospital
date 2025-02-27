import mysql from "mysql2";

// mysql 연결
const db = mysql.createConnection({
	host: "localhost",
	user: "root",
	password: "6c656568616e20241104",
	database: "medivice",
	port: 3306, 
});

db.connect((err) => {
	if(err) {
		console.error("MySQL connection failed.", err);
	} else {
		console.error("MySQL connection successful.");
	}
});

export { db };