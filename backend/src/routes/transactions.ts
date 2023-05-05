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
    transaction_id: z.string(),
    transaction_name: z.string().optional(),
    transaction_amount: z.number().optional(),
    date: z.string().optional(),
    description: z.string().optional().optional(),
    bill_url: z.string().optional(),
    category_id: z.string().optional(),
    type_id: z.string().optional(),
    interval_id: z.string().optional(),
    account_id: z.string().optional()
});
type EditSchema = z.infer<typeof editSchema>;

// router.post('/transactions', (req, res) => {
//     res.status(201).send('Hello world2');
// });




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

    const user = await prisma.transaction.findUnique({
        where: {
            transaction_id: body.transaction_id
        }
    });

    if (!user) {
        res.status(404).send();
        return;
    }

    if (body.transaction_name) {
        await prisma.transaction.update({
            where: {
                transaction_id: body.transaction_id
            },
            data: {
                transaction_name: body.transaction_name
            }
        });

        res.status(200).send();

    } else if (body.transaction_amount) {
        await prisma.transaction.update({
            where: {
                transaction_id: body.transaction_id
            },
            data: {
                transaction_amount: body.transaction_amount
            }
        });

        res.status(200).send();

    } else if (body.date) {
        await prisma.transaction.update({
            where: {
                transaction_id: body.transaction_id
            },
            data: {
                date: body.date
            }
        });

        res.status(200).send();

    } else if (body.description) {
        await prisma.transaction.update({
            where: {
                transaction_id: body.transaction_id
            },
            data: {
                description: body.description
            }
        });

        res.status(200).send();

    } else if (body.bill_url) {
        await prisma.transaction.update({
            where: {
                transaction_id: body.transaction_id
            },
            data: {
                bill_url: body.bill_url
            }
        });

        res.status(200).send();

    } else if (body.category_id) {
        await prisma.transaction.update({
            where: {
                transaction_id: body.transaction_id
            },
            data: {
                category_id: body.category_id
            }
        });

        res.status(200).send();

    } else if (body.type_id) {
        await prisma.transaction.update({
            where: {
                transaction_id: body.transaction_id
            },
            data: {
                type_id: body.type_id
            }
        });

        res.status(200).send();

    } else if (body.interval_id) {
        await prisma.transaction.update({
            where: {
                transaction_id: body.transaction_id
            },
            data: {
                interval_id: body.interval_id
            }
        });

        res.status(200).send();

    } else if (body.account_id) {
        await prisma.transaction.update({
            where: {
                transaction_id: body.transaction_id
            },
            data: {
                account_id: body.account_id
            }
        });

        res.status(200).send();

    } else {
        res.status(406).send();
        return;
    }
});

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

export default router;