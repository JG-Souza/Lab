const usersService = require('../services/users.service');

async function index(req, res) {

  const result = await usersService.index();

  return res.json(result);
}

module.exports = {
  index,
};