// Teste de integração
const loginService = require('../services/auth.service');
const { prisma } = require('../src/prisma/db');
const bcrypt = require('bcrypt');

beforeAll(async () => {
    await prisma.user.create({
        data: {
            email: 'admin@example.com',
            password: await bcrypt.hash('admin', 10),
        }
    });
});

afterAll(async () => {
    await prisma.user.deleteMany({ where: { email: 'teste@example.com' } });
    await prisma.$disconnect();
});

describe('login', () => {
    test('login com email e senha válidos', async () => {
        const email = 'admin@example.com';
        const password = 'admin';
        const result = await loginService.login(email, password);

        expect(result).toHaveProperty('token');
        expect(result).toHaveProperty('user');
        expect(result.user.email).toBe(email);
    });

    test('login com email inválido', async () => {
        const email = 'invalid@example.com';
        const password = 'invalid';

        await expect(loginService.login(email, password)).rejects.toThrow('Usuário ou senha inválidos');
    });

    test('login com senha inválida', async () => {
        const email = 'admin@example.com';
        const password = 'invalid';

        await expect(loginService.login(email, password)).rejects.toThrow('Usuário ou senha inválidos');
    });
});