# Lab — API de Autenticação com JWT

> 🧪 **Este é um laboratório de estudo prático.**
> O objetivo não é entregar um produto pronto para produção, mas sim um espaço para experimentar, errar e aprender na prática conceitos de backend, testes, containers e CI/CD.

Uma API REST simples em Node.js com cadastro, login e rotas protegidas por JWT, persistindo os dados em PostgreSQL via Prisma. Em volta dessa API construí toda a esteira de execução: rodar localmente, rodar em container, rodar os testes isolados em container e rodar os testes automaticamente no GitHub Actions.

---

## 📚 O que aprendi com este projeto

- **JWT e autenticação** — geração e validação de tokens, hash de senhas com `bcrypt`, middleware de proteção de rotas e o fato de que, por ser *stateless*, o logout com JWT acontece no cliente (o token continua válido no servidor até expirar).
- **Testes de integração** — testar o serviço de login contra um banco de dados real, preparando e limpando os dados com `beforeAll` / `afterAll`.
- **Testes automatizados (CI)** — pipeline no GitHub Actions que sobe um PostgreSQL como serviço, aplica as migrations e roda a suíte de testes a cada `push`.
- **Multi-stage build** — um único `Dockerfile` com estágios diferentes para **teste** e **produção**.
- **Dependências de desenvolvimento vs. produção** — na prática, a diferença entre uma imagem com `npm ci` completo (com Jest e Prisma CLI) e uma imagem enxuta com `npm ci --omit=dev`, além de limpar o cache do npm para reduzir o tamanho.
- **Docker Compose** — orquestração da aplicação com o banco, `healthcheck` para só subir a API quando o Postgres estiver pronto, volumes para persistência e sobreposição de arquivos (`compose.yml` + `compose.test.yml`) para criar um ambiente de teste isolado.
- **Rodar o mesmo projeto em ambientes diferentes** — local, container e CI usando a mesma versão do Node (fixada no `.nvmrc`) e configuração via variáveis de ambiente.
- **Prisma ORM** — schema, migrations e uso do adapter `@prisma/adapter-pg`.

---

## 🛠️ Stack

| Camada          | Tecnologia                          |
| --------------- | ----------------------------------- |
| Runtime         | Node.js 24                          |
| Framework       | Express 5                           |
| Banco de dados  | PostgreSQL 15                       |
| ORM             | Prisma 7                            |
| Autenticação    | JSON Web Token + bcrypt             |
| Testes          | Jest                                |
| Containers      | Docker (multi-stage) + Docker Compose |
| CI              | GitHub Actions                      |

---

## 🔌 Endpoints

| Método | Rota             | Protegida | Descrição                          |
| ------ | ---------------- | :-------: | ---------------------------------- |
| POST   | `/auth/register` |           | Cadastra um usuário                |
| POST   | `/auth/login`    |           | Autentica e retorna um token JWT   |
| POST   | `/auth/logout`   |    ✅     | Logout (o cliente descarta o token) |
| GET    | `/users`         |    ✅     | Lista os usuários                  |

Rotas protegidas exigem o header:

```
Authorization: Bearer <token>
```

**Exemplo:**

```bash
# Cadastro
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"joao@example.com","password":"123456","name":"João"}'

# Login
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"joao@example.com","password":"123456"}'

# Rota protegida
curl http://localhost:3000/users -H "Authorization: Bearer <token>"
```

---

## 🚀 Como rodar

### Variáveis de ambiente

Copie o arquivo de exemplo e ajuste os valores:

```bash
cp .env.example .env
```

| Variável       | Descrição                         |
| -------------- | --------------------------------- |
| `DATABASE_URL` | String de conexão do PostgreSQL   |
| `JWT_SECRET`   | Segredo usado para assinar os tokens |

### Opção 1 — Localmente

Pré-requisitos: Node.js 24 (`nvm use`) e um PostgreSQL acessível pela `DATABASE_URL`.

```bash
npm install            # também roda o prisma generate
npm run prisma:migrate # aplica as migrations
npm start              # sobe em http://localhost:3000
```

### Opção 2 — Docker Compose (produção)

Sobe a API (imagem de produção, sem dependências de dev) e o PostgreSQL. As migrations são aplicadas automaticamente antes da aplicação iniciar.

```bash
JWT_SECRET=um_segredo_forte docker compose up --build
```

> O `JWT_SECRET` é obrigatório: se não estiver definido (no shell ou no `.env`), o Compose se recusa a subir.

### Rodando os testes

**Localmente** (com um banco de testes configurado na `DATABASE_URL`):

```bash
npm test
```

**Em container**, em um ambiente totalmente isolado (projeto `lab-test`, banco `app_test`, sem portas expostas):

```bash
JWT_SECRET=test docker compose -f compose.yml -f compose.test.yml up --build --abort-on-container-exit
docker compose -f compose.yml -f compose.test.yml down -v
```

**No CI**, os testes rodam automaticamente a cada `push` pelo workflow em [.github/workflows/github-actions.yml](.github/workflows/github-actions.yml).

---

## 🗺️ Próximos passos

- [ ] **Infraestrutura na AWS com Terraform** — provisionar a infraestrutura como código para publicar a aplicação na nuvem (rede, banco gerenciado, execução dos containers etc.).
- [ ] Estender o pipeline para build e deploy da imagem.
- [ ] Não expor o hash da senha na listagem de `/users`.
- [ ] Ampliar a cobertura de testes (cadastro, middleware e rotas HTTP).

---

## ⚠️ Aviso

Por ser um laboratório de estudos, algumas decisões foram tomadas visando o aprendizado e não a produção (por exemplo, credenciais fixas do Postgres no `compose.yml`). Não utilize este projeto como está em um ambiente real.
