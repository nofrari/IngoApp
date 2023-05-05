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
    account_balance: z.string(),
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

    if (body.account_name) {
        await prisma.account.update({
            where: {
                account_id: body.account_id
            },
            data: {
                account_name: body.account_name
            }
        });

        res.status(200).send();

    } else if (body.account_balance) {
        await prisma.account.update({
            where: {
                account_id: body.account_id
            },
            data: {
                account_balance: parseFloat(body.account_balance)
            }
        });

        res.status(200).send();

    } else {
        res.status(406).send();
        return;
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
        return res.status(404).json({ message: 'Kategorie nicht gefunden' });
    }

    res.json({ message: 'Kategorie erfolgreich gelöscht' });
});

router.get('/accounts', async (req, res) => {
    const accounts = await prisma.account.findMany();
    res.send(accounts);
});

export default router;
