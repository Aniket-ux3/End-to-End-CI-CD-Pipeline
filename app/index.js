const express = require('express');
const app = express();
app.get('/', (_, res) => res.send('Hello from Jenkins + ngrok! - Updated'));
app.listen(3000, () => console.log('Running on 3000'));
