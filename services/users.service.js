const { prisma } = require('../src/prisma/db');

async function index() {
    const users = await prisma.user.findMany();

    return {
        users // Ver forma de não expor senha
    };
}

module.exports = {
    index,
};