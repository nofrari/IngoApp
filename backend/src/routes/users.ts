import express from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import jwt from 'jsonwebtoken';
import verifyToken from '../middleware/verifyToken';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();
const router = express.Router();
//is used to check the parameters of the request body
const registerSchema = z.object({
    user_name: z.string(),
    user_sirname: z.string(),
    email: z.string(),
    password: z.string()
});
type RegisterSchema = z.infer<typeof registerSchema>;

const loginSchema = z.object({
    email: z.string(),
    password: z.string()
});
type LoginSchema = z.infer<typeof loginSchema>;

const editSchema = z.object({
    user_id: z.string(),
    user_name: z.string().optional(),
    user_sirname: z.string().optional(),
    email: z.string(),
    old_password: z.string().optional(),
    new_password: z.string().optional(),
});
type EditSchema = z.infer<typeof editSchema>;

//edit user
router.post('/users/edit', async (req, res) => {
    const body = <EditSchema>req.body;
    const validationResult = editSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const user = await prisma.user.findUnique({
        where: {
            user_id: body.user_id
        }
    });

    if (!user) {
        res.status(404).send();
        return;
    }

    //if blocks to check which parameter is sent in the request body and then update the database
    if (body.user_name) {
        await prisma.user.update({
            where: {
                user_id: body.user_id
            },
            data: {
                user_name: body.user_name
            }
        });

        res.status(200).send();

    } else if (body.user_sirname) {
        await prisma.user.update({
            where: {
                user_id: body.user_id
            },
            data: {
                user_sirname: body.user_sirname
            }
        });

        res.status(200).send();

    } else if (body.email) {
        await prisma.user.update({
            where: {
                user_id: body.user_id
            },
            data: {
                email: body.email
            }
        });

        res.status(200).send();

    } else if (body.old_password && body.new_password) {
        const match = await bcrypt.compare(body.old_password, user.password);

        if (!match) {
            res.status(401).send();
            return;
        }

        const hash = await bcrypt.hash(body.new_password, 10);

        await prisma.user.update({
            where: {
                user_id: body.user_id
            },
            data: {
                password: hash
            }
        });

        res.status(200).send();

    } else {
        res.status(406).send();
        return;
    }
});


//create new user (register)
router.post('/users/register', async (req, res) => {
    const body = <RegisterSchema>req.body;
    const validationResult = registerSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const existingUser = await prisma.user.findUnique({
        where: {
            email: body.email
        }
    });

    if (existingUser) {
        res.status(409).send();
        console.log(existingUser);
        return;
    }

    const hash = await bcrypt.hash(body.password, 10);
    const user = await prisma.user.create({
        data: {
            user_name: body.user_name,
            user_sirname: body.user_sirname,
            email: body.email,
            password: hash
        }
    });

    // const token = jwt.sign({
    //     userId: user.user_id,
    //     exp: Math.floor(Date.now() / 1000) + (60 * 60)
    // }, <string>process.env.JWT_SECRET);

    res.send({
        //accessToken: token,
        user_id: user.user_id,
        username: user.user_name,
        user_sirname: user.user_sirname,
        email: user.email
    });
});

//Get all users, not really needed in our case
// router.get('/users', async (req, res) => {
//     const users = await prisma.user.findMany();
//     res.send(users);
// });

//get one user by id
//for testing: copy token from login or register and paste it in the authorization header under Bearer token
router.get('/users/:id', async (req, res) => {
    const user = await prisma.user.findUnique({ where: { user_id: req.params.id } });
    res.send(user);
});

//user login
router.post('/users/login', async (req, res) => {
    const body = <LoginSchema>req.body;
    const validationResult = loginSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const user = await prisma.user.findUnique({
        where: {
            email: body.email
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

    // const token = jwt.sign({
    //     userId: user.user_id,
    //     exp: Math.floor(Date.now() / 1000) + (60 * 60 * 24 * 30)
    // }, <string>process.env.JWT_SECRET);

    res.status(200).send({
        //accessToken: token,
        user_id: user.user_id,
        user_name: user.user_name,
        user_sirname: user.user_sirname,
        email: user.email,
        pin: user.pin
    });
});

router.post('/users/init', async (req, res) => {
    try {
        // Hier kannst du deine vordefinierten Werte angeben
        const predefinedInterval = [
            { interval_name: 'Nie' },
            { interval_name: 'Wöchentlich' },
            { interval_name: 'Monatlich' },
            { interval_name: 'Vierteljährlich' },
            { interval_name: 'Halbjährlich' },
            { interval_name: 'Jährlich' },
        ];

        const predefinedTypes = [
            { type_name: 'Einnahmen' },
            { type_name: 'Ausgaben' },
            { type_name: 'Transaktion' },
        ];

        // Hier kannst du den Code zum Speichern der Werte in die Datenbank einfügen
        await prisma.interval.createMany({
            data: predefinedInterval,
        });

        await prisma.type.createMany({
            data: predefinedTypes,
        });

        res.status(200).json({ message: 'Vordefinierte Werte erfolgreich in die Datenbank geschrieben.' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Interner Serverfehler.' });
    }
});

router.get('/types', async (req, res) => {
    const types = await prisma.type.findMany();
    res.send(types);
});

router.get('/intervals', async (req, res) => {

    const intervals = await prisma.interval.findMany();
    res.send(intervals);
});

export default router;
