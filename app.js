const express = require('express');
const { prisma } = require('./src/prisma/db');
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/users.routes');
const app = express()
const port = 3000

app.use(express.json()); // Serve para transformar os dados JSON em objetos JS

app.use('/auth', authRoutes);
app.use('/users', userRoutes);

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})