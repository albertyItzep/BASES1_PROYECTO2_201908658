const express = require('express');
require('dotenv').config();
const app = express();
//configuracion
app.set('port', process.env.SERVER_PORT || 3000);

app.use(express.json());

app.use(require("./routes/routes"))

module.exports = app;