import express from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
import { CarteVitaleV1 } from 'mindee/src/documents/fr';

const prisma = new PrismaClient();
const router = express.Router();

const inputSchema = z.object({
    category_name: z.string(),
    color: z.string(),
    user_id: z.string(),
    icon_id: z.string()
});
type InputSchema = z.infer<typeof inputSchema>;

const editSchema = z.object({
    category_id: z.string(),
    category_name: z.string().optional(),
    color: z.string().optional(),
    icon_id: z.string().optional()
});
type EditSchema = z.infer<typeof editSchema>;

router.post('/categories/input', async (req, res) => {
    const body = <InputSchema>req.body;
    const validationResult: any = inputSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const category = await prisma.category.create({
        data: {
            category_name: body.category_name,
            color: body.color,
            user_id: body.user_id,
            icon_id: body.icon_id
        }
    });
    res.send({
        category_id: category.category_id,
        category_name: category.category_name,
        color: category.color,
        user_id: category.user_id,
        icon_id: category.icon_id
    });
});

router.post('/categories/edit', async (req, res) => {
    const body = <EditSchema>req.body;
    const validationResult: any = editSchema.safeParse(body);

    if (!validationResult.success) {
        res.status(400).send();
        return;
    }

    const category = await prisma.category.findUnique({
        where: {
            category_id: body.category_id
        }
    });

    if (!category) {
        res.status(404).send();
        return;
    }

    if (body.category_name) {
        await prisma.category.update({
            where: {
                category_id: body.category_id
            },
            data: {
                category_name: body.category_name
            }
        });

        res.status(200).send();

    } else if (body.color) {
        await prisma.category.update({
            where: {
                category_id: body.category_id
            },
            data: {
                color: body.color
            }
        });

        res.status(200).send();

    } else if (body.icon_id) {
        await prisma.category.update({
            where: {
                category_id: body.category_id
            },
            data: {
                icon_id: body.icon_id
            }
        });

        res.status(200).send();

    } else {
        res.status(406).send();
        return;
    }
});

router.delete('/categories/:id', async (req, res) => {

    const category_id = req.params.id;

    const category = await prisma.category.delete({
        where: {
            category_id: category_id
        },
    });

    if (!category) {
        return res.status(404).json({ message: 'Kategorie nicht gefunden' });
    }

    res.json({ message: 'Kategorie erfolgreich gelöscht' });
});

router.get('/categories', async (req, res) => {
    const categories = await prisma.category.findMany();
    res.send(categories);
});

router.get('/categories/:id', async (req, res) => {
    const id = req.params.id;

    const category = await prisma.category.findUnique({ where: { category_id: id } });
    res.send(category);
});

router.get('/categories/:user_id', async (req, res) => {
    const user_id = req.params.user_id;

    const categories = await prisma.category.findMany({
        where: { user_id: user_id },
    });

    res.send(categories);
});

export default router;