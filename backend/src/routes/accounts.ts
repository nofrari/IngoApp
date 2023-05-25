import express from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';

const prisma = new PrismaClient();
const router = express.Router();

const inputSchema = z.object({
    account_name: z.string(),
    account_balance: z.number(),
    user_id: z.string()
});
type InputSchema = z.infer<typeof inputSchema>;

const editSchema = z.object({
    account_id: z.string(),
    account_name: z.string(),
    account_balance: z.number(),
    user_id: z.string()
});
type EditSchema = z.infer<typeof editSchema>;

router.post('/accounts/input', async (req, res) => {
    const body = <InputSchema>req.body;
    const validationResult: any = inputSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(404).send();
        return;
    }

    const account = await prisma.account.create({
        data: {
            account_name: body.account_name,
            account_balance: body.account_balance,
            user_id: body.user_id
        }
    });
    res.send({
        account_id: account.account_id,
        account_name: account.account_name,
        account_balance: account.account_balance,
        user_id: account.user_id
    });
});

router.post('/accounts/edit', async (req, res) => {
    const body = <EditSchema>req.body;
    const validationResult: any = editSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const account = await prisma.account.findUnique({
        where: {
            account_id: body.account_id
        }
    });

    if (!account) {
        res.status(404).send();
        return;
    }

    try {
        await prisma.account.update({
            where: {
                account_id: body.account_id
            },
            data: {
                account_name: body.account_name,
                account_balance: body.account_balance,
            }
        });
        return res.status(200).send();
    } catch (error) {
        return res.status(500).send();
    }
});

router.delete('/accounts/:id', async (req, res) => {

    const account_id = req.params.id;

    const account = await prisma.account.delete({
        where: {
            account_id: account_id
        },
    });

    if (!account) {
        return res.status(404).json({ message: 'Account nicht gefunden' });
    }

    res.json({ message: 'Account erfolgreich gelöscht' });
});

router.get('/accounts/totalAmount/:user_id', async (req, res) => {
    const user_id = req.params.user_id;

    const accounts = await prisma.account.findMany({ where: { user_id: user_id } });
    const totalAmount = accounts.reduce((acc, account) => {
        return acc + account.account_balance;
    }, 0);

    res.send({ totalAmount });
});

router.get('/accounts', async (req, res) => {
    const accounts = await prisma.account.findMany();
    res.send(accounts);
});

router.get('/accounts/:id', async (req, res) => {
    const id = req.params.id;

    const account = await prisma.account.findUnique({ where: { account_id: id } });
    res.send(account);
});

router.get('/accounts/list/:user_id', async (req, res) => {
    const user_id = req.params.user_id;

    const accounts = await prisma.account.findMany({
        where: { user_id: user_id },
    });

    if (!accounts) {
        return res.status(406).json({ message: 'Accounts nicht gefunden' });
    }

    res.send(accounts);
});

export default router;
