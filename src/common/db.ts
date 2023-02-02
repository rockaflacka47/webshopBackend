const MongoClient = require("mongodb").MongoClient;

require("dotenv").config();

//should be retrieved from AWS key management or another provider but due to
//this being a project I do not want to spend money on it is just an environment variable.
const MONGODB_URI = process.env.DB_URL;

// Once we connect to the database once, we'll store that connection and reuse it so that we don't have to connect to the database on every request.
let cachedDb = null;

export async function connectToDatabase() {
  if (cachedDb) {
    return cachedDb;
  }

  const client = await MongoClient.connect(MONGODB_URI);

  const db = await client.db("db");

  cachedDb = db;
  return db;
}
