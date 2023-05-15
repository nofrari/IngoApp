import express from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import multer from 'multer';
import PDFDocument, { options } from 'pdfkit';
const fs = require('fs');
import jwt from 'jsonwebtoken';
import verifyToken from '../middleware/verifyToken';
import bcrypt from 'bcrypt';
import { request } from 'http';
import path, { parse } from 'path';

const prisma = new PrismaClient();
const router = express.Router();
const parentDir = path.dirname(__dirname);

var storage =
    multer.diskStorage({
        destination: function (req, file, cb) {
            cb(null, parentDir + "/uploads");
            console.log(parentDir);
            //cb(null, __dirname);
        },
        filename: function (req, file, cb) {
            cb(null, file.originalname);
        }
    });

const upload = multer({ storage: storage });

const inputSchema = z.object({
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
type InputSchema = z.infer<typeof inputSchema>;

const editSchema = z.object({
    transaction_id: z.string().optional(),
    transaction_name: z.string().optional(),
    transaction_amount: z.number().optional(),
    date: z.string().optional(),
    description: z.string().optional(),
    bill_url: z.string().optional(),
    category_id: z.string().optional(),
    type_id: z.string().optional(),
    interval_id: z.string().optional(),
    account_id: z.string().optional()
});
type EditSchema = z.infer<typeof editSchema>;

router.post('/transactions', (req, res) => {
    res.status(201).send('Hello world2');
});


router.post('/transactions/input', async (req, res) => {
    const body = <InputSchema>req.body;
    const validationResult: any = inputSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

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

router.post('/transactions/edit', async (req, res) => {
    const body = <EditSchema>req.body;
    const validationResult: any = editSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const transaction = await prisma.transaction.findUnique({
        where: {
            transaction_id: body.transaction_id
        }
    });

    if (!transaction) {
        res.status(404).send();
        return;
    }

    const parsedDate = new Date(body.date!);

    try {
        await prisma.transaction.update({
            where: {
                transaction_id: body.transaction_id
            },
            data: {
                transaction_name: body.transaction_name,
                transaction_amount: body.transaction_amount,
                date: parsedDate,
                description: body.description,
                bill_url: body.bill_url,
                category_id: body.category_id,
                type_id: body.type_id,
                interval_id: body.interval_id,
                account_id: body.account_id,
            }
        });


        res.status(200).send();

    } catch (e) {
        console.log(e);
        res.status(404).send(e);
        return;
    }
})




router.post("/transactions/pdfUpload", upload.single("pdf"), async (req, res) => {
    if (!req.file) {
        return res.status(422).send("At least one image is required");
    }

    res.send('PDF erfolgreich hochgeladen und gespeichert');
});

router.delete('/transactions/:filename', (req, res) => {
    const filePath = parentDir + '/uploads/' + req.params.filename;
    console.log("FILEPFAD:" + filePath.toString());

    fs.unlink(filePath, (err: any) => {
        if (err) {
            console.error(err);
            res.status(500).send('Error deleting file');
        } else {
            console.log(`PDF file ${req.params.filename} deleted successfully`);
            res.send('PDF file deleted successfully');
        }
    });
});

// router.get('/transactions', async (req, res) => {
//     const transactions = await prisma.transaction.findMany();
//     res.send(transactions);
// });

router.get('/transactions/:id', async (req, res) => {
    const id = req.params.id;

    const transaction = await prisma.transaction.findUnique({ where: { transaction_id: id } });
    res.send(transaction);
});

router.get('/transactions/list/:user_id', async (req, res) => {
    const user_id = req.params.user_id;

    const transactions = await prisma.transaction.findMany({
        where: {
            category: {
                user: {
                    user_id: user_id,
                },
            },
        },
    });

    res.send(transactions);
});

export default router;