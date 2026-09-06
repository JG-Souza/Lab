const express = require('express');
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/users.routes');
const app = express()

app.use(express.json()); // Serve para transformar os dados JSON em objetos JS

app.use('/auth', authRoutes);
app.use('/users', userRoutes);


module.exports = app;