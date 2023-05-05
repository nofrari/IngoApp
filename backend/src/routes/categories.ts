import express from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';

const prisma = new PrismaClient();
const router = express.Router();

const createSchema = z.object({
    category_name: z.string(),
    color: z.string(),
    user_id: z.string(),
    icon_id: z.string()
});
type CreateSchema = z.infer<typeof createSchema>;

const updateSchema = z.object({
    category_id: z.string(),
    category_name: z.string().optional(),
    color: z.string().optional(),
    icon_id: z.string().optional(),
    //? braucht es user_id -> user_id: z.string().optional()
});
type UpdateSchema = z.infer<typeof updateSchema>;