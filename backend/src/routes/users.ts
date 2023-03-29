import express from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();
const router = express.Router();
const inputSchema = z.object({
    username: z.string(),
    password: z.string()
});
type InputSchema = z.infer<typeof inputSchema>;

//create new user (register)
router.post('/users', async (req, res) => {
    const body = <InputSchema>req.body;
    const validationResult = inputSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const hash = await bcrypt.hash(body.password, 10);
    const user = await prisma.user.create({
        data: {
            username: body.username,
            password: hash
        }
    });
    res.send({ id: user.id, username: user.username });
});

router.get('/users', async (req, res) => {
    const users = await prisma.user.findMany();
    res.send(users);
});

router.get('/users/:id', async (req, res) => {
    const user = await prisma.user.findUnique({ where: { id: req.params.id } });
    res.send(user);
});

router.post('/users/login', async (req, res) => {
    const body = <InputSchema>req.body;
    const validationResult = inputSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const user = await prisma.user.findUnique({
        where: {
            username: body.username
        }
    });

    if (!user) {
        res.status(404).send();
        return;
    }

    const match = await bcrypt.compare(body.password, user.password);

    if (!match) {
        res.status(401).send();
        return;
    }

    res.status(200).send();
});

export default router;
