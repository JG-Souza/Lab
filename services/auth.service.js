const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { prisma } = require('../src/prisma/db');

const SALT_ROUNDS = 10;

function httpError(message, status) {
    const error = new Error(message);
    error.status = status;

    return error;
}

async function register({ email, password, username, name }) {
    if (!email || !password) {
        throw httpError('Email e senha são obrigatórios', 400);
    }

    const existingUser = await prisma.user.findUnique({
        where: {
            email: email,
        },
    });

    if (existingUser) {
        throw httpError('Email já cadastrado', 409);
    }

    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    try {
        const user = await prisma.user.create({
            data: {
                email,
                password: hashedPassword,
                username,
                name,
            },
        });

        return {
            user: {
                id: user.id,
                email: user.email,
                username: user.username,
                name: user.name,
            },
        };
    } catch (error) {
        if (error.code === 'P2002') {
            throw httpError('Email já cadastrado', 409);
        }

        throw error;
    }
}

async function login(email, password) {
    const user = await prisma.user.findUnique({
        where: {
            email: email,
        },
    });
    
    if (!user) {
        throw httpError('Usuário ou senha inválidos', 401);
    }

    const passwordIsValid = await bcrypt.compare(
        password, 
        user.password
    );

    if (!passwordIsValid) {
        throw httpError('Usuário ou senha inválidos', 401);
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
    register,
    login,
};