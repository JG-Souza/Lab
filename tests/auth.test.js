// Teste de integração

const loginService = require('../services/auth.service');

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