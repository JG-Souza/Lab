const authService = require('../services/auth.service');

async function register(req, res) {
  const { email, password, username, name } = req.body ?? {};

  try {
    const result = await authService.register({ email, password, username, name });

    return res.status(201).json(result);
  } catch (error) {
    return res
      .status(error.status ?? 500)
      .json({ message: error.status ? error.message : 'Erro interno do servidor' });
  }
}

async function login(req, res) {
  const { email, password } = req.body ?? {}; // Desempacotamento de email e password do corpo da requisição

  try {
    const result = await authService.login(email, password);

    return res.json(result);
  } catch (error) {
    return res
      .status(error.status ?? 500)
      .json({ message: error.status ? error.message : 'Erro interno do servidor' });
  }
}

// O JWT é stateless: o logout acontece no cliente, que descarta o token.
// O token continua válido no servidor até expirar.
async function logout(req, res) {
  return res.json({ message: 'Logout realizado com sucesso' });
}

module.exports = {
  register,
  login,
  logout,
};
