const authService = require('../services/auth.service');

async function login(req, res) {
  const { email, password } = req.body ?? {}; // Desempacotamento de email e password do corpo da requisição

  const result = await authService.login(email, password);

  return res.json(result);
}

module.exports = {
  login,
};