const express = require("express");
const pool = require("./db");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get("/", (req, res) => {
    res.json({
        message: "GitOps-Based Kubernetes Deployment Platform demo app",
        status: "running"
    });
});

app.get("/health", (req, res) => {
    res.json({
        status: "healthy"
    });
});

app.get("/db-check", async (req, res) => {
    try {
        const result = await pool.query("SELECT NOW() as current_time");

        res.json({
            status: "connected",
            database_time: result.rows[0].current_time
        });
    } catch (error) {
        res.status(500).json({
            status: "error",
            message: error.message
        });
    }
});

app.get("/users", async (req, res) => {
    try {
        const result = await pool.query("SELECT * FROM users ORDER BY id ASC");

        res.json({
            data: result.rows
        });
    } catch (error) {
        res.status(500).json({
            status: "error",
            message: error.message
        });
    }
});

app.post("/users", async (req, res) => {
    try {
        const { name, email } = req.body;

        const result = await pool.query(
            "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *",
            [name, email]
        );

        res.status(201).json({
            message: "User created",
            data: result.rows[0]
        });
    } catch (error) {
        res.status(500).json({
            status: "error",
            message: error.message
        });
    }
});

app.listen(PORT, () => {
    console.log(`App is running on port ${PORT}`);
});