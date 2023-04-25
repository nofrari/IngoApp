import express from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import jwt from 'jsonwebtoken';
import verifyToken from '../middleware/verifyToken';
import bcrypt from 'bcrypt';
import { request } from 'http';
import { parse } from 'path';

const prisma = new PrismaClient();
const router = express.Router();
//is used to check the parameters of the request body

const testSchema = z.object({
    transaction_name: z.string(),
    transaction_amount: z.number(),
    date: z.string(),
    description: z.string().optional(),
    bill_url: z.string().optional(),
    category_id: z.string(),
    type_id: z.string(),
    interval_id: z.string(),
    account_id: z.string()
});
type TestSchema = z.infer<typeof testSchema>;

router.post('/transactions', (req, res) => {
    res.status(201).send('Hello world2');
});

router.post('/transactions/test', async (req, res) => {
    console.log("request mqde: ", req.body);
    const body = <TestSchema>req.body;
    const validationResult: any = testSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(402).send();
        return;
    }

    //const hash = await bcrypt.hash(body.password, 10);

    const transaction = await prisma.transaction.create({
        data: {
            transaction_name: body.transaction_name,
            transaction_amount: body.transaction_amount,
            date: new Date(body.date),
            description: body.description,
            bill_url: body.bill_url,
            category_id: body.category_id,
            type_id: body.type_id,
            interval_id: body.interval_id,
            account_id: body.account_id,
        }
    });

    // const token = jwt.sign({
    //     userId: user.user_id,
    //     exp: Math.floor(Date.now() / 1000) + (60 * 60)
    // }, <string>process.env.JWT_SECRET);


    res.send({
        transaction_id: transaction.transaction_id,
        transaction_name: transaction.transaction_name,
        transaction_amount: transaction.transaction_amount,
        date: transaction.date,
        description: transaction.description,
        bill_url: transaction.bill_url,
        category_id: transaction.category_id,
        type_id: transaction.type_id,
        interval_id: transaction.interval_id,
        account_id: transaction.account_id,
    });
});

export default router;