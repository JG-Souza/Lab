const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { prisma } = require('../src/prisma/db');

async function login(email, password) {
    const user = await prisma.user.findUnique({
        where: {
            email: email,
        },
    });
    
    if (!user) {
        throw new Error('Usuário ou senha inválidos');
    }

    const passwordIsValid = await bcrypt.compare(
        password, 
        user.password
    );

    if (!passwordIsValid) {
        throw new Error('Usuário ou senha inválidos');
    }

    const token = jwt.sign(
        { id: user.id },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
    );

    return {
    token,
    user: {
        id: user.id,
        email: user.email,
        username: user.username,
        name: user.name,
    },
};
}

module.exports = {
    login,
};