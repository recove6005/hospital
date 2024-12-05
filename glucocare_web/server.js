const express = require('express');
const path = require('path');

const app = express();

app.use(express.static(path.join(__dirname, 'public')));

app.get('/api/data', (req, res) => {
    res.json({ message: 'Hello, this is data from the server!'});
    const user = req.body;
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});